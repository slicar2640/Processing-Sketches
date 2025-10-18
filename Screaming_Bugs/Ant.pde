class Ant {
  PVector pos;
  PVector direction = PVector.random2D();
  int[] steps;
  int broadcastRadius = 50;
  int currentDestination = 0;
  World world;
  boolean followOthers;
  float speed = random(0.5, 2);
  Ant(float x, float y, int numDestinationTypes, World world) {
    pos = new PVector(x, y);
    steps = new int[numDestinationTypes];
    this.world = world;
    currentDestination = (int) random(numDestinationTypes);
    followOthers = random(100) < 80;
  }

  void update() {
    direction.rotate(random(-0.01, 0.01) * TWO_PI);
    pos.add(PVector.mult(direction, speed));
    for (int i = 0; i < steps.length; i++) {
      steps[i]++;
    }
    for (Destination d : world.destinations) {
      if (d.contains(pos)) {
        steps[d.id] = 0;
        d.relocate(this);
        if (currentDestination == d.id) {
          currentDestination = (currentDestination + 1) % steps.length;
        }
        sendBroadcast();
      }
    }
    if (pos.x < 0 || pos.x > width) {
      pos.x = constrain(pos.x, 0, width);
      direction.x *= -1;
    }
    if (pos.y < 0 || pos.y > height) {
      pos.y = constrain(pos.y, 0, height);
      direction.y *= -1;
    }
  }

  void sendBroadcast() {
    for (Ant ant : world.ants) {
      if (ant == this) continue;
      if (abs(ant.pos.x - pos.x) > broadcastRadius) continue;
      if (abs(ant.pos.y - pos.y) > broadcastRadius) continue;
      if (pos.dist(ant.pos) < broadcastRadius) {
        ant.receiveBroadcast(steps, broadcastRadius, pos);
      }
    }
  }

  void receiveBroadcast(int[] otherSteps, float radius, PVector otherPos) {
    for (int i = 0; i < steps.length; i++) {
      if (otherSteps[i] + radius < steps[i]) {
        steps[i] = otherSteps[i] + (int) radius;
        if (followOthers && i == currentDestination) {
          turnToward(otherPos);
        }
        sendBroadcast();
      }
    }
  }

  void turnToward(PVector otherPos) {
    direction = otherPos.copy().sub(pos).normalize();
  }
}
