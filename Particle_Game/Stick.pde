class Stick {
  Particle p1, p2;
  float restLength;
  float stiffness;
  float breakLengthRatio = 0;
  ParticleManager manager;
  
  public Stick(Particle p1, Particle p2, float restLength, float stiffness, float breakLength) {
    this.p1 = p1;
    this.p2 = p2;
    this.restLength = restLength < 0 ? p1.pos.dist(p2.pos) : restLength;
    this.stiffness = stiffness;
    this.breakLengthRatio = breakLength;
    manager = p1.manager;
  }
  
  public Stick(Particle p1, Particle p2, float restLength, float stiffness) {
    this(p1, p2, restLength, stiffness, 0);
  }
  
  public Stick(Particle p1, Particle p2) {
    this(p1, p2, -1, 1, 0);
  }
  
  public void update() {
    PVector diff = PVector.sub(p1.pos, p2.pos);
    float dis = diff.mag();
    if(breakLengthRatio > 1 && dis > restLength * breakLengthRatio) {
      breakSelf();
      return;
    }
    PVector attraction = diff.normalize().mult((dis - restLength) * stiffness / 2);
    p2.applyForce(attraction);
    p1.applyForce(attraction.mult(-1));
  }
  
  public void breakSelf() {
    manager.sticksToRemove.add(this);
  }
  
  public void show() {
    stroke(255);
    strokeWeight(1);
    line(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
  }
}
