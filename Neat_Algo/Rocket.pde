class Rocket {
  PVector pos;
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  double angle = -HALF_PI;
  double angleChange = 0.05;
  double thrustStrength = 0.2;
  Client client;
  boolean done = false;

  Rocket(float x, float y, Client client) {
    pos = new PVector(x, y);
    this.client = client;
    this.client.rocket = this;
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void update() {
    if (!done) {
      calculate();
      pos.add(vel);
      vel.add(acc);
      vel.mult(0.99);
      acc.set(0, 0);
      client.score += (width * 1.4 - pos.dist(target)) / 5;
      if (pos.dist(target) <= targetRadius) {
        done = true;
        client.setScore(2000 + countdown);
      }
      if (pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height) {
        done = true;
        client.setScore(countdown);
      }
    }
  }

  /* INPUTS:
   bias
   this x
   this y
   this angle
   vel x
   vel y
   target x
   target y
   angle to target
   dist to target
   */
  void calculate() {
    double distToTarget = pos.dist(target);
    double rotAngle = (angle + HALF_PI) % TWO_PI - PI;

    double[] outputs = client.calculate(
      1,
      pos.x,
      pos.y,
      rotAngle,
      vel.x,
      vel.y,
      target.x,
      target.y,
      distToTarget);

    angle += (outputs[1] * 2 - 1) * angleChange;
    angle = (angle + TWO_PI) % TWO_PI;
    applyForce(PVector.fromAngle((float) angle).mult((float) (outputs[0] * thrustStrength)));
  }

  void show() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate((float) angle);
    rectMode(CENTER);
    fill(255, 50);
    noStroke();
    rect(0, 0, 10, 4);
    popMatrix();
  }
  
  void show(color c) {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate((float) angle);
    rectMode(CENTER);
    fill(c, 100);
    noStroke();
    rect(0, 0, 10, 4);
    popMatrix();
  }
}
