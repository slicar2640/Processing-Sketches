color[] palette = {color(255), color(255, 0, 0), color(255, 135, 0), color(255, 210, 0), color(25, 255, 0), color(0, 150, 0), color(0, 230, 255), color(0, 60, 255), color(175, 0, 255), color(255, 0, 250), color(120)};

int particleCount = 100;
ArrayList<Stick> sticks = new ArrayList<Stick>();
ArrayList<Construct> constructs = new ArrayList<Construct>();

int mouseDisplayCountdown = 0;

float mouseDist = 60;
float repelDist = 40;
float repelStrength = 0.1;
float attractStrength = 4e-3;
float borderDist = 20;
float friction = 0.05;
float stickStrength = 0.2;

int substeps = 10;

BucketManager bucketManager;

void setup() {
  size(600, 600);
  bucketManager = new BucketManager(ceil(width / repelDist), ceil(height / repelDist), repelDist);
  //for (int i = 0; i < particleCount; i++) {
  //  particles.add(new Particle(random(width), random(height), palette[0]));
  //}

  //int numConstructs = (int)random(1, 4);
  //for (int i = 0; i < numConstructs; i++) {
  //  if (random(1) < 0.5) {
  //    constructs.add(new Flower(random(width), random(height), random(20, 50), (int)random(5, 10), palette[(int)random(palette.length)], palette[(int)random(palette.length)], bucketManager));
  //  } else {
  //    constructs.add(new Ring(random(width), random(height), random(20, 50), (int)random(5, 10), random(10, 20), palette[(int)random(palette.length)], palette[(int)random(palette.length)], bucketManager));
  //  }
  //}

  Ring ring = new Ring(width / 2, height / 2, 10, 20, palette[0], bucketManager);
  ring.addTo(constructs);
  ring.stems.forEach(s -> s.setAutoSplitFactor(8));

  Vine v1 = new Vine(width / 2, height / 2, 4, 3, palette[5], palette[1], bucketManager);
  v1.addTo(constructs);

  //for(int i = 0; i < 30; i++) {
  //  bucketManager.add(new Particle(new PVector(width / 2, height / 2).add(PVector.random2D().mult(sqrt(random(1)) * 100)), palette[10]));
  //}
}

void draw() {
  background(0);

  ArrayList<Stick> toAdd = new ArrayList<Stick>();
  for (Stick s : sticks) {
    s.update(sticks, toAdd);
  }
  toAdd.forEach(s -> s.addTo(sticks));

  for (int i = 0; i < substeps; i++) {
    bucketManager.update(1 / (float) substeps);
  }

  for (Stick s : sticks) {
    s.show();
  }

  bucketManager.show();

  ArrayList<Construct> toDestroy = new ArrayList<Construct>();
  for (Construct c : constructs) {
    if (c.parts.size() == 0) {
      toDestroy.add(c);
    }
  }
  toDestroy.forEach(c -> c.destroy());

  if (random(10) < 1) {
    for (Construct c : constructs) {
      if (c instanceof Vine) {
        Vine v = (Vine) c;
        if (random(2) < 1) {
          v.randomGrow(10);
        }
      } else if (c instanceof Ring) {
        Ring r = (Ring) c;
        if (random(20) < 1) {
          r.grow();
        }
      }
    }
  }

  if (mouseDisplayCountdown > 0) {
    stroke(255, 0, 0, map(mouseDisplayCountdown, 30, 0, 255, 0));
    strokeWeight(2);
    noFill();
    ellipse(mouseX, mouseY, mouseDist * 2, mouseDist * 2);
    mouseDisplayCountdown--;
  }

  //if (frameCount < 200) {
  //  for (Construct c : constructs) {
  //    if (c instanceof Ring) {
  //      Ring ring = (Ring) c;
  //      ring.grow((int) random(ring.sides));
  //    }
  //  }
  //}

  if (keyPressed) {
    if (keyCode == CONTROL) {
      bucketManager.showHidden();
      noStroke();
      fill(255, 50);
      textSize(20);
      textAlign(LEFT, TOP);
      text(frameRate, 10, 10);
    }
  }

  if (mousePressed) {
    if (mouseButton == LEFT) {
      if (keyPressed) {
        if (keyCode == SHIFT && frameCount % 2 == 0) {
          bucketManager.add(new Particle(mouseX + random(-1, 1), mouseY + random(-1, 1), palette[0]));
        } else if (keyCode == CONTROL) {
          stroke(255, 100, 255);
          strokeWeight(2);
          noFill();
          rect(floor(mouseX / repelDist) * repelDist, floor(mouseY / repelDist) * repelDist, repelDist, repelDist);
          stroke(255, 100, 100);
          rect((floor(mouseX / repelDist) - 1) * repelDist, (floor(mouseY / repelDist) - 1) * repelDist, repelDist * 3, repelDist * 3);
          int[] mouseBucket = bucketManager.bucketAt(mouseX, mouseY);
          ArrayList<Particle> neighborhood = bucketManager.getNeighborhood(mouseBucket[0], mouseBucket[1]);
          for (Particle p : neighborhood) {
            p.show(color(255, 0, 255));
          }
        }
      } else {
        for (Particle p : bucketManager.particles) {
          float distToMouse = dist(mouseX, mouseY, p.pos.x, p.pos.y);
          if (distToMouse < mouseDist) {
            p.applyForce(PVector.sub(p.pos, new PVector(mouseX, mouseY)).normalize().mult(1 - distToMouse / mouseDist).mult(0.5 * substeps));
          }
        }
      }
    } else if (mouseButton == RIGHT) {
      ArrayList<Particle> toDelete = new ArrayList<Particle>();
      for (Particle p : bucketManager.particles) {
        float distToMouse = dist(mouseX, mouseY, p.pos.x, p.pos.y);
        if (distToMouse < mouseDist) {
          toDelete.add(p);
        }
      }
      toDelete.forEach(p -> p.destroy());
    }
  }
}

void keyPressed() {
  if(key == 'S') {
    println(getExportString());
  }
}

void mouseWheel(MouseEvent event) {
  float amt = event.getCount();
  mouseDist = constrain(mouseDist - amt, 5, width);
  mouseDisplayCountdown = 30;
}

//shape {shape args} material colorType {colorType args}; next
String getExportString() {
  String exportString = "";
  for(Stick s : sticks) {
    exportString += "line " +
    s.bodyA.pos.x + " " +
    s.bodyA.pos.y + " " +
    s.bodyB.pos.x + " " +
    s.bodyB.pos.y + " " +
    "light solid " +
    red(s.col) + " " +
    green(s.col) + " " +
    blue(s.col) + "; ";
  }
  for(Particle p : bucketManager.particles) {
    if(p.doShow == false) continue;
    exportString += "circle " +
    p.pos.x + " " +
    p.pos.y + " " +
    "4 " +
    "light solid " +
    red(p.col) + " " +
    green(p.col) + " " +
    blue(p.col) + "; ";
  }
  return exportString.trim();
}
