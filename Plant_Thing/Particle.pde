class Particle {
  PVector pos;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  color col;
  boolean doShow;
  ArrayList<Stick> sticks = new ArrayList<Stick>();
  ArrayList<ArrayList<Particle>> holders = new ArrayList<ArrayList<Particle>>();
  int bucketX, bucketY;

  Particle(float x, float y, color col) {
    pos = new PVector(x, y);
    this.col = col;
    doShow = true;
  }

  Particle(PVector pos, color col) {
    this.pos = pos.copy();
    this.col = col;
    doShow = true;
  }

  Particle(float x, float y) {
    pos = new PVector(x, y);
  }

  Particle(PVector pos) {
    this.pos = pos.copy();
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void applyForce(float x, float y) {
    acc.add(x, y);
  }

  void update(ArrayList<Particle> parts, float dt) {
    repel(parts);
    contain();

    pos.add(PVector.mult(vel, dt));
    vel.add(PVector.mult(acc, dt));
    vel.mult(1 - friction * dt);
    acc.set(0, 0);
  }

  void repel(ArrayList<Particle> parts) {
    for (Particle other : parts) {
      PVector diff = PVector.sub(pos, other.pos);
      float dis = diff.mag();
      if (dis < 0.01) continue;
      if (dis < repelDist) {
        PVector repulsion = diff.copy()
          .normalize()
          .mult((1 - dis / repelDist) * repelStrength);
        applyForce(repulsion);
      }
    }
  }

  void attract() {
    PVector diff = new PVector(width / 2, height / 2).sub(pos);
    if (diff.mag() < 0.01) return;
    PVector attraction = diff.copy()
      .normalize()
      .mult(attractStrength);
    applyForce(attraction);
  }

  void contain() {
    if (pos.x < borderDist) {
      applyForce((borderDist - pos.x) * repelStrength, 0);
    } else if (pos.x > width - borderDist) {
      applyForce((width - borderDist - pos.x) * repelStrength, 0);
    }

    if (pos.y < borderDist) {
      applyForce(0, (borderDist - pos.y) * repelStrength);
    } else if (pos.y > height - borderDist) {
      applyForce(0, (height - borderDist - pos.y) * repelStrength);
    }
  }

  void show() {
    if (doShow) {
      stroke(col);
    } else {
      noStroke();
    }
    strokeWeight(8);
    point(pos.x, pos.y);
  }

  void show(color dStroke) {
    stroke(dStroke);
    strokeWeight(8);
    point(pos.x, pos.y);
  }

  void addTo(ArrayList<Particle> ...arrs) {
    for (ArrayList<Particle> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }
  
  void addTo(ArrayList<ArrayList<Particle>> arrs) {
    for (ArrayList<Particle> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }

  void addTo(ArrayList<Particle> arr, int index) {
    arr.add(index, this);
    holders.add(arr);
  }

  void removeFrom(ArrayList<Particle> ...arrs) {
    for (ArrayList<Particle> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }
  
  void removeFrom(ArrayList<ArrayList<Particle>> arrs) {
    for (ArrayList<Particle> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }

  void destroy() {
    for (ArrayList<Particle> arr : holders) {
      arr.remove(this);
    }
    ArrayList<Stick> toDestroy = new ArrayList<Stick>();
    for (Stick stick : sticks) {
      toDestroy.add(stick);
    }
    toDestroy.forEach(s -> s.destroy());
  }
}
