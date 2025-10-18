class Vine extends Construct {
  Particle center;
  color stemColor;
  color petalColor;
  ArrayList<Particle> stemParts = new ArrayList<Particle>();
  ArrayList<Particle> petals = new ArrayList<Particle>();
  float stemLength;
  Vine (float x, float y, float d, int n, color stemColor, color petalColor, BucketManager bm) {
    super();
    this.bm = bm;
    center = new Particle(x, y);
    center.addTo(stemParts, parts);
    bm.add(center);
    for (int i = 0; i < n; i++) {
      Particle p = new Particle(new PVector(x, y).add(PVector.random2D().mult(d)), petalColor);
      Stick s = new Stick(center, p, d, stemColor);
      p.addTo(petals, parts);
      bm.add(p);
      s.addTo(stems, sticks);
    }

    this.stemColor = stemColor;
    this.petalColor = petalColor;
    stemLength = d;
  }

  void randomGrow(float branchProbability) {
    if (petals.size() == 0 || random(100) < branchProbability) {
      Particle before = stemParts.get((int) random(stemParts.size()));
      PVector newPos = before.pos.copy().add(PVector.random2D());
      Particle newPetal = new Particle(newPos, petalColor);
      newPetal.addTo(petals, parts);
      bm.add(newPetal);
      Stick newStem = new Stick(before, newPetal, stemLength, stemColor);
      newStem.addTo(stems, sticks);
    } else {
      Particle petal = petals.get((int) random(petals.size()));
      if (petal.sticks.size() == 0) {
        Particle newStem = new Particle(PVector.random2D().add(petal.pos));
        newStem.addTo(parts, stemParts);
        bm.add(newStem);
        Stick s1 = new Stick(newStem, petal, stemLength, stemColor);
        s1.addTo(stems, sticks);
      }
      Particle before = petal.sticks.get(0).bodyA;
      PVector diff = PVector.sub(petal.pos, before.pos);
      PVector newPos = diff.normalize().rotate(constrain(randomGaussian() / 3 * PI / 4, -PI / 4, PI / 4)).add(petal.pos);
      Particle newPetal = new Particle(newPos, petalColor);
      newPetal.addTo(petals, parts);
      bm.add(newPetal);
      Stick newStem = new Stick(petal, newPetal, stemLength, stemColor);
      newStem.addTo(stems, sticks);

      petal.removeFrom(petals);
      petal.doShow = false;
      petal.addTo(stemParts, parts);
    }
  }
}
