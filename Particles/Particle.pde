class Particle {
  PVector target;
  PVector pos;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  Particle(PVector pos) {
    target = pos;
    this.pos = pos;
  }

  Particle(PVector target, PVector pos) {
    this.target = target;
    this.pos = pos;
  }
  
  void approach() {
    PVector diff = PVector.sub(target, pos);
    applyForce(diff.mult(0.005));
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }

  void update() {
    approach();
    
    pos.add(vel);
    vel.add(acc);
    vel.mult(1 - friction);
    acc.set(0, 0);
  }

  void show() {
    stroke(255);
    strokeWeight(2);
    point(pos.x, pos.y);
  }
}
