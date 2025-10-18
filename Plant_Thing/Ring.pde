class Ring extends Construct {
  ArrayList<Particle> innerParts = new ArrayList<Particle>();
  ArrayList<Particle> outerParts;
  ArrayList<Stick> ringStems = new ArrayList<Stick>();
  ArrayList<Stick> fringeStems;
  boolean hasFringe;
  float fringeLength;
  color stemColor;
  color petalColor;
  Ring(float x, float y, float r, int c, color stemColor, BucketManager bm) {
    super();
    for (int i = 0; i < c; i++) {
      float a = (float)i / c * TWO_PI;
      new Particle(x + r * cos(a), y + r * sin(a)).addTo(parts, innerParts);
    }
    for (int i = 0; i < c; i++) {
      Particle p1 = innerParts.get(i);
      Particle p2 = innerParts.get((i + 1) % c);
      new Stick(p1, p2, stemColor).addTo(stems, ringStems);
    }
    this.bm = bm;
    bm.addAll(parts);
    stems.forEach(s -> s.addTo(sticks));
    hasFringe = false;
    this.stemColor = stemColor;
  }

  Ring(float x, float y, float r, int c, float fringeLength, color stemColor, color petalColor, BucketManager bm) {
    super();
    outerParts = new ArrayList<Particle>();
    fringeStems = new ArrayList<Stick>();
    for (int i = 0; i < c; i++) {
      float a = (float)i / c * TWO_PI;
      new Particle(x + r * cos(a), y + r * sin(a)).addTo(parts, innerParts);
    }
    for (int i = 0; i < c; i++) {
      Particle p1 = innerParts.get(i);
      Particle p2 = innerParts.get((i + 1) % c);
      new Stick(p1, p2, stemColor).addTo(stems, ringStems);
    }
    for (int i = 0; i < c; i++) {
      float a = (float)i / c * TWO_PI;
      Particle p = new Particle(x + (r + fringeLength) * cos(a), y + (r + fringeLength) * sin(a), petalColor);
      p.addTo(parts, outerParts);
      new Stick(innerParts.get(i), p, fringeLength, stemColor).addTo(stems, fringeStems);
    }
    this.bm = bm;
    bm.addAll(parts);
    stems.forEach(s -> s.addTo(sticks));
    hasFringe = true;
    this.fringeLength = fringeLength;
    this.stemColor = stemColor;
    this.petalColor = petalColor;
  }

  void grow() {
    PVector center = new PVector(0, 0);
    for (Particle p : parts) {
      center.add(p.pos);
    }
    center.div(parts.size());
    
    if(ringStems.size() == 0) { 
      return;
    }
    Stick chosenStem = ringStems.get((int) random(ringStems.size()));
    Particle inner = chosenStem.split();

    if (hasFringe) {
      PVector outerPos = PVector.sub(inner.pos, center);
      outerPos.mult(1 + fringeLength / outerPos.mag());
      outerPos.add(center);
      Particle outer = new Particle(outerPos, petalColor);
      outer.addTo(parts, outerParts);
      Stick io = new Stick(inner, outer, fringeLength, stemColor);
      io.addTo(stems, fringeStems);
      bm.add(outer);
      io.addTo(sticks);
    }
  }
}

float mod(float a, float b) {
  return (a % b + b) % b;
}

int mod(int a, int b) {
  return (a % b + b) % b;
}
