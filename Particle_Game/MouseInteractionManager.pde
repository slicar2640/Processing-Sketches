class MouseInteractionManager {
  MouseInteraction currentInteraction;

  public MouseInteractionManager(MouseInteraction first) {
    currentInteraction = first;
  }

  public void mouseClick() {
    currentInteraction.mouseClick();
  }

  public void mouseDown() {
    currentInteraction.mouseDown();
  }
  
  public void mouseUp() {
    currentInteraction.mouseUp();
  }
  
  public void updateScale(float delta) {
    currentInteraction.updateScale(delta);
  }
  
  public void updateCount(int delta) {
    currentInteraction.updateCount(delta);
  }

  public void show() {
    currentInteraction.show();
  //  switch(mode) {
  //  case ADD_LOOP:
  //    noFill();
  //    stroke(255);
  //    strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
  //    circle(mouseX, mouseY, radii.get(mode) * 2);
  //    break;
  //  case ADD_TRIANGLE:
  //    {
  //      float spacing = radii.get(mode);
  //      float count = counts.get(mode);
  //      float sideLength = spacing * (count - 1);
  //      noFill();
  //      stroke(255);
  //      strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
  //      beginShape();
  //      vertex(mouseX, mouseY - sideLength * SQRT3_2 * 2 / 3);
  //      vertex(mouseX + sideLength / 2, mouseY + sideLength * SQRT3_2 / 3);
  //      vertex(mouseX - sideLength / 2, mouseY + sideLength * SQRT3_2 / 3);
  //      endShape(CLOSE);
  //      break;
  //    }
  //  case ADD_RECTANGLE:
  //    float spacing = radii.get(mode);
  //    float count = counts.get(mode);
  //    noFill();
  //    stroke(255);
  //    strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
  //    rect(mouseX - (count - 0.5) * spacing / 2, mouseY - (count - 1) * spacing * SQRT3_2 / 2, (count - 1) * spacing, (count - 1) * spacing * SQRT3_2);
  //    break;
  //  default:
  //    break;
  //  }
  }
}
