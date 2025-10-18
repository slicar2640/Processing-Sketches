class Flower extends Construct {
  Particle center;
  Flower(float x, float y, float r, int c, color stemColor, color petalColor, BucketManager bm) {
    super();
    center = new Particle(x, y);

    for (int i = 0; i < c; i++) {
      float a = (float)i / c * TWO_PI;
      Particle p;
      p = new Particle(x + r * cos(a), y + r * sin(a), petalColor);
      p.addTo(parts);
      new Stick(center, p, r, stemColor).addTo(stems);
    }
    this.bm = bm;
    bm.add(center);
    bm.addAll(parts);
    stems.forEach(s -> s.addTo(sticks));
  }
}
