import java.util.function.BiConsumer;

interface MouseInteraction {
  public void mouseClick();
  public void mouseDown();
  public void updateScale(float delta);
  public void updateCount(int delta);
  public void show();
}

class PushInteraction implements MouseInteraction {
  float strength, radius;
  public PushInteraction(float strength, float radius) {
    this.strength = strength;
    this.radius = radius;
  }

  public void mouseClick() {
    mouseDown();
  }

  public void mouseDown() {
    PVector mousePos = new PVector(mouseX, mouseY);
    ArrayList<Particle> parts = particleManager.getAllParticles();
    for (Particle p : parts) {
      PVector diff = PVector.sub(p.pos, mousePos);
      float dis = diff.mag();
      if (dis < 0.01) return;
      if (dis < radius) {
        PVector repulsion = diff.normalize()
          .mult((1 - dis / radius) * strength);
        p.applyForce(repulsion);
      }
    }
  }

  public void updateScale(float delta) {
    radius += delta;
    if (radius < 0) radius = 0;
  }

  public void updateCount(int delta) {
    strength += delta;
  }

  public void show() {
    noFill();
    stroke(0, 200, 0, 150);
    strokeWeight(1);
    circle(mouseX, mouseY, radius * 2);
  }
}

class DeleteInteraction implements MouseInteraction {
  float radius;
  public DeleteInteraction(float radius) {
    this.radius = radius;
  }

  public void mouseClick() {
    mouseDown();
  }

  public void mouseDown() {
    PVector mousePos = new PVector(mouseX, mouseY);
    ArrayList<Particle> parts = particleManager.getAllParticles();
    for (Particle p : parts) {
      if (p.pos.dist(mousePos) < radius) {
        particleManager.removeParticle(p);
      }
    }
  }

  public void updateScale(float delta) {
    radius += delta;
    if (radius < 0) radius = 0;
  }

  public void updateCount(int delta) {
  }

  public void show() {
    noFill();
    stroke(255, 0, 0);
    strokeWeight(1);
    circle(mouseX, mouseY, radius * 2);
  }
}

class AddParticleInteraction implements MouseInteraction {
  Class<? extends Particle> particleClass;
  float radius;
  int count;
  public AddParticleInteraction(Class<? extends Particle> clazz, float radius, int count) {
    particleClass = clazz;
    this.radius = radius;
    this.count = count;
  }

  public void mouseClick() {
    if (mouseButton == RIGHT) {
      addParticle();
    }
  }

  public void mouseDown() {
    if (mouseButton == LEFT) {
      addParticle();
    }
  }

  void addParticle() {
    try {
      PVector pos = new PVector();
      for (int i = 0; i < count; i++) {
        pos.set(0, 0);
        PVector.random2D(pos);
        pos.mult(sqrt(random(1))* radius);
        pos.add(mouseX, mouseY);
        particleManager.addParticle(pos.x, pos.y, 1, particleClass);
      }
    }
    catch (ReflectiveOperationException e) {
      e.printStackTrace();
    }
  }

  public void updateScale(float delta) {
    radius += delta;
    if (radius < 0) radius = 0;
  }

  public void updateCount(int delta) {
    count += delta;
    if (count < 1) count = 1;
  }

  public void show() {
    noFill();
    stroke(255);
    strokeWeight(1);
    circle(mouseX, mouseY, radius * 2);
  }
}

class AddConstructInteraction implements MouseInteraction {
  float scale;
  int count;
  BiConsumer<Float, Integer> constructFunction;
  BiConsumer<Float, Integer> showFunction;
  public AddConstructInteraction(BiConsumer<Float, Integer> constructFunction, float scale, int count, BiConsumer<Float, Integer> showFunction) {
    this.constructFunction = constructFunction;
    this.scale = scale;
    this.count = count;
    this.showFunction = showFunction;
  }

  public void mouseClick() {
    constructFunction.accept(scale, count);
  }

  public void mouseDown() {
  }

  public void updateScale(float delta) {
    scale += delta;
    if (scale < 0) scale = 0;
  }

  public void updateCount(int delta) {
    count += delta;
    if (count < 1) count = 1;
  }

  public void show() {
    showFunction.accept(scale, count);
  }
}

class AddStickInteraction implements MouseInteraction {
  float length;
  float stiffness;
  Particle p1;

  public AddStickInteraction(float length, float stiffness) {
    this.length = length;
    this.stiffness = stiffness;
  }

  private Particle closestParticle() {
    ArrayList<Particle> neighbors = particleManager.neighborParticles(mouseX, mouseY);
    Particle closest = null;
    float closestDist = particleManager.repelDist;
    for (Particle p : neighbors) {
      if (dist(p.pos.x, p.pos.y, mouseX, mouseY) < closestDist) {
        closest = p;
        closestDist = dist(p.pos.x, p.pos.y, mouseX, mouseY);
      }
    }
    return closest;
  }

  public void mouseClick() {
    if (p1 != null) {
      Particle closest = closestParticle();
      if (closest != null && closest != p1) {
        if (shiftPressed) {
          particleManager.addStick(new Stick(p1, closest)).stiffness = stiffness;
        } else {
          particleManager.addStick(new Stick(p1, closest, length, stiffness));
        }
        p1 = null;
      }
    } else {
      Particle closest = closestParticle();
      if (closest != null) {
        p1 = closest;
      }
    }
  }

  public void mouseDown() {
  }

  public void updateScale(float delta) {
    length += delta;
    if (length < 0) length = 0;
  }

  public void updateCount(int delta) {
    stiffness += 0.1 * delta;
    if (stiffness < 0) stiffness = 0;
  }

  public void show() {
    if (p1 != null) {
      if (shiftPressed) {
        stroke((2 - stiffness) * 255, stiffness * 255, stiffness * 255);
        strokeWeight(2);
        line(p1.pos.x, p1.pos.y, mouseX, mouseY);
      } else {
        PVector p2 = PVector.add(p1.pos, new PVector(mouseX, mouseY).sub(p1.pos).normalize().mult(length));
        stroke((2 - stiffness) * 255, stiffness * 255, stiffness * 255);
        strokeWeight(2);
        line(p1.pos.x, p1.pos.y, p2.x, p2.y);
      }

      stroke(255, 80);
      strokeWeight(5 + sin(frameCount / 15));
      ellipse(p1.pos.x, p1.pos.y, 20, 20);
    }


    Particle closest = closestParticle();
    if (closest != null) {
      stroke(255, 30);
      strokeWeight(6);
      ellipse(closest.pos.x, closest.pos.y, 20, 20);
    }
  }
}
