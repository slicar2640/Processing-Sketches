class Stick {
  Particle bodyA;
  Particle bodyB;
  float restLength;
  color col;
  ArrayList<ArrayList<Stick>> holders = new ArrayList<ArrayList<Stick>>();
  boolean autoSplit = false;
  float autoSplitLength;

  Stick(Particle a, Particle b, float len, color col) {
    bodyA = a;
    bodyB = b;
    bodyA.sticks.add(this);
    bodyB.sticks.add(this);
    restLength = len;
    this.col = col;
  }

  Stick(Particle a, Particle b, color col) {
    bodyA = a;
    bodyB = b;
    bodyA.sticks.add(this);
    bodyB.sticks.add(this);
    restLength = PVector.dist(a.pos, b.pos);
    this.col = col;
  }

  void setAutoSplit(float len) {
    autoSplit = true;
    autoSplitLength = len;
  }

  void setAutoSplitFactor(float fac) {
    autoSplit = true;
    autoSplitLength = restLength * fac;
  }

  void setAutoSplit(boolean doSplit) {
    autoSplit = doSplit;
    autoSplitLength = doSplit ? 2 * restLength : 0;
  }

  void update() {
    PVector diff = PVector.sub(bodyB.pos, bodyA.pos);
    float dis = diff.mag();

    if (dis > restLength) {
      PVector attraction = diff.copy()
        .normalize()
        .mult((dis - this.restLength) * stickStrength)
        .mult(0.5);

      bodyA.applyForce(attraction);
      bodyB.applyForce(attraction.mult(-1));
    }
  }

  void update(ArrayList<Stick> currentArr, ArrayList<Stick> newSticks) {
    PVector diff = PVector.sub(bodyB.pos, bodyA.pos);
    float dis = diff.mag();

    if (dis > restLength) {
      PVector attraction = diff.copy()
        .normalize()
        .mult((dis - this.restLength) * stickStrength)
        .mult(0.5);

      bodyA.applyForce(attraction);
      bodyB.applyForce(attraction.mult(-1));
    }

    if (autoSplit == true && dis > autoSplitLength) {
      split(currentArr, newSticks);
    }
  }

  Particle split(ArrayList<Stick> currentArr, ArrayList<Stick> newSticks) {
    PVector midpoint = PVector.add(bodyA.pos, bodyB.pos).div(2);
    Particle mid = bodyA.doShow == true ? new Particle(midpoint, bodyA.col) : new Particle(midpoint);
    bucketManager.add(mid);
    ArrayList<ArrayList<Particle>> pHolders = (ArrayList<ArrayList<Particle>>) bodyA.holders.clone();
    pHolders.removeIf(h -> h == bucketManager.particles || bucketManager.isBucket(h));
    mid.addTo(pHolders);
    Stick s1 = new Stick(bodyA, mid, restLength, col);
    if(autoSplit == true) {
      s1.setAutoSplit(autoSplitLength);
    }
    bodyA = mid;
    for (ArrayList<Stick> arr : holders) {
      if (arr.equals(currentArr)) {
        newSticks.add(s1);
      } else {
        s1.addTo(arr);
      }
    }
    return mid;
  }

  Particle split() {
    PVector midpoint = PVector.add(bodyA.pos, bodyB.pos).div(2);
    Particle mid = bodyA.doShow == true ? new Particle(midpoint, bodyA.col) : new Particle(midpoint);
    mid.addTo(bodyA.holders);
    Stick s1 = new Stick(bodyA, mid, restLength, col);
    if (autoSplit == true) {
      s1.setAutoSplit(autoSplitLength);
    }
    bodyA = mid;
    for (ArrayList<Stick> arr : holders) {
      s1.addTo(arr);
    }
    return mid;
  }

  void show() {
    stroke(col);
    strokeWeight(4);
    line(bodyA.pos.x, bodyA.pos.y, bodyB.pos.x, bodyB.pos.y);
  }

  void show(color dStroke) {
    stroke(dStroke);
    strokeWeight(4);
    line(bodyA.pos.x, bodyA.pos.y, bodyB.pos.x, bodyB.pos.y);
  }

  void setLength(float l) {
    restLength = l;
  }

  void setLength() {
    restLength = PVector.dist(bodyA.pos, bodyB.pos);
  }

  void addTo(ArrayList<Stick> ...arrs) {
    for (ArrayList<Stick> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }

  void addTo(ArrayList<ArrayList<Stick>> arrs) {
    for (ArrayList<Stick> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }

  void addTo(ArrayList<Stick> arr, int index) {
    arr.add(index, this);
    holders.add(arr);
  }

  void removeFrom(ArrayList<Stick> ...arrs) {
    for (ArrayList<Stick> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }

  void removeFrom(ArrayList<ArrayList<Stick>> arrs) {
    for (ArrayList<Stick> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }

  void destroy() {
    for (ArrayList<Stick> arr : holders) {
      arr.remove(this);
    }
    bodyA.sticks.remove(this);
    bodyB.sticks.remove(this);
  }
}
