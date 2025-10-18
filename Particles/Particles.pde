ArrayList<Particle> particles = new ArrayList<Particle>();
float friction = 0.05;
boolean circl = true;
void setup() {
  size(600, 600);
  for (int i = 0; i < 10000; i++) {
    particles.add(new Particle(PVector.random2D().mult(100).add(width / 2, height / 2), new PVector(random(width), random(height))));
  }
}

void draw() {
  background(0);
  for (Particle p : particles) {
    p.update();
    p.show();
  }

  if (mousePressed) {
    for (Particle p : particles) {
      PVector diff = new PVector(mouseX, mouseY).sub(p.pos);
      float dis = diff.mag();
      if (dis < 50) {
        diff.normalize();
        diff.mult(-1);
        diff.rotate(random(-0.2, 0.2));
        p.applyForce(diff);
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    if (circl) {
      circl = false;
      for (Particle p : particles) {
        p.target = new PVector(random(width), random(height));
        p.applyForce(PVector.random2D().mult(random(10, 20)));
      }
    } else {
      circl = true;
      for (Particle p : particles) {
        p.target = PVector.random2D().mult(100).add(width / 2, height / 2);
        p.applyForce(PVector.random2D().mult(random(10, 20)));
      }
    }
  }
}
