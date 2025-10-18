class Destination {
  PVector pos;
  float radius;
  int id;
  Destination(float x, float y, float r, int id) {
    pos = new PVector(x, y);
    radius = r;
    this.id = id;
  }

  boolean contains(PVector antPos) {
    if (abs(antPos.x - pos.x) > radius) return false;
    if (abs(antPos.y - pos.y) > radius) return false;
    return pos.dist(antPos) < radius;
  }
  
  void relocate(Ant ant) {
    PVector diff = ant.pos.copy().sub(pos);
    ant.pos.set(diff.copy().normalize().mult(radius + 1).add(pos));
    ant.direction.set(diff.normalize());
  }

  void show() {
    noStroke();
    fill(destinationColors[id]);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
  }
}
