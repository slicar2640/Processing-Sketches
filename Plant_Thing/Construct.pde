class Construct {
  ArrayList<Particle> parts = new ArrayList<Particle>();
  ArrayList<Stick> stems = new ArrayList<Stick>();
  BucketManager bm;
  ArrayList<ArrayList<Construct>> holders = new ArrayList<ArrayList<Construct>>();

  void destroy() {
    ArrayList<Particle> dParts = new ArrayList<Particle>();
    for (Particle part : parts) {
      dParts.add(part);
    }
    dParts.forEach(s -> s.destroy());

    ArrayList<Stick> dSticks = new ArrayList<Stick>();
    for (Stick stick : sticks) {
      dSticks.add(stick);
    }
    dSticks.forEach(s -> s.destroy());
    
    for (ArrayList<Construct> arr : holders) {
      arr.remove(this);
    }
  }

  void addTo(ArrayList<Construct> ...arrs) {
    for (ArrayList<Construct> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }

  void addTo(ArrayList<ArrayList<Construct>> arrs) {
    for (ArrayList<Construct> arr : arrs) {
      arr.add(this);
      holders.add(arr);
    }
  }

  void addTo(ArrayList<Construct> arr, int index) {
    arr.add(index, this);
    holders.add(arr);
  }

  void removeFrom(ArrayList<Construct> ...arrs) {
    for (ArrayList<Construct> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }

  void removeFrom(ArrayList<ArrayList<Construct>> arrs) {
    for (ArrayList<Construct> arr : arrs) {
      arr.remove(this);
      holders.remove(arr);
    }
  }
}
