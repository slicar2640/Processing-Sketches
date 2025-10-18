class Wire {
  Pin inputPin;
  ArrayList<ArrayList<PVector>> paths = new ArrayList<>();
  ArrayList<PVector> branchPoints = new ArrayList<>();
  boolean building;
  int colorIndex = 0;

  Wire(Pin pin) {
    building = true;
    inputPin = pin;
  }

  void branch(int pathIndex, float pathProgress, PVector branchPoint) {
    //ArrayList<PVector> branchedPath = paths.get(pathIndex);
    //branchedPath.add(ceil(pathProgress), branchPoint);
    //ArrayList<PVector> newPath = new ArrayList<>();
    //newPath.add(branchPoint);
    //paths.add(newPath);
    //building = true;
  }

  void show() {
    stroke((inputPin.state ? lightColors : darkColors)[colorIndex]);
    strokeWeight(4);
    noFill();
    for (int i = 0; i < paths.size() - (building ? 1 : 0); i++) {
      ArrayList<PVector> path = paths.get(i);
      beginShape();
      for (PVector p : path) {
        vertex(p.x, p.y);
      }
      endShape();
    }
    if (building) {
      ArrayList<PVector> path = paths.get(paths.size() - 1);
      beginShape();
      for (PVector p : path) {
        vertex(p.x, p.y);
      }
      vertex(interactionManager.buildWireDisplayPoint.x, interactionManager.buildWireDisplayPoint.y);
      endShape();
    }
    strokeWeight(8);
    for (PVector p : branchPoints) {
      point(p.x, p.y);
    }
  }
}
