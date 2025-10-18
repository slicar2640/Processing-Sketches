class MenuManager {
  ArrayList<MenuButton> buttons;
  boolean active = false;
  public MenuManager() {
    buttons = new ArrayList<>();
    buttons.add(new MenuButton("p-normal", 50, 50, 120, 50, "Particle", this, () -> {
      stroke(255);
      strokeWeight(0.6);
      point(0, 0);
    }
    ));
    buttons.add(new MenuButton("p-sticky", 50, 110, 170, 50, "StickyParticle", this, () -> {
      stroke(255, 255, 180);
      strokeWeight(0.6);
      point(0, 0);
    }
    ));
    buttons.add(new MenuButton("c-loop", 300, 50, 100, 50, "Loop", this, () -> {
      stroke(255);
      strokeWeight(0.05);
      noFill();
      circle(0, 0, 0.6);
    }
    ));
    buttons.add(new MenuButton("c-triangle", 300, 110, 125, 50, "Triangle", this, () -> {
      stroke(255);
      strokeWeight(0.05);
      noFill();
      triangle(0, -0.3, 0.3, 0.3 * SQRT3_2, -0.3, 0.3 * SQRT3_2);
    }
    ));
    buttons.add(new MenuButton("c-rectangle", 300, 170, 140, 50, "Rectangle", this, () -> {
      stroke(255);
      strokeWeight(0.05);
      noFill();
      rect(-0.3, -0.3, 0.6, 0.6);
    }
    ));
    buttons.add(new MenuButton("c-classicRectangle", 300, 230, 210, 50, "Rectangle (Classic)", this, () -> {
      stroke(255);
      strokeWeight(0.05);
      noFill();
      rect(-0.3, -0.3, 0.6, 0.6);
      line(-0.29, -0.29, 0.29, 0.29);
    }
    ));
  }

  public void click() {
    for (MenuButton button : buttons) {
      if (button.click(mouseX, mouseY)) {
        justExitedMenu = true;
        return;
      }
    }
  }

  public void buttonPress(String id) {
    switch(id) {
    case "p-normal":
      mouseManager.currentInteraction = new AddParticleInteraction(Particle.class, 100, 1);
      break;
    case "p-link":
      mouseManager.currentInteraction = new AddParticleInteraction(LinkableParticle.class, 100, 1);
      break;
    case "p-sticky":
      mouseManager.currentInteraction = new AddParticleInteraction(StickyParticle.class, 100, 1);
      break;
    case "c-loop":
      mouseManager.currentInteraction = new AddConstructInteraction((scale, count) -> particleManager.addLoop(mouseX, mouseY, scale, count), 100, 150, (scale, count) -> {
        noFill();
        stroke(255);
        strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
        circle(mouseX, mouseY, scale * 2);
      }
      );
      break;
    case "c-triangle":
      mouseManager.currentInteraction = new AddConstructInteraction((scale, count) -> particleManager.addTriangle(mouseX, mouseY, count, scale, 1), 50, 5, (scale, count) -> {
        noFill();
        stroke(255);
        strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
        float sideLength = scale * (count - 1);
        beginShape();
        vertex(mouseX, mouseY - sideLength * SQRT3_2 * 2 / 3);
        vertex(mouseX + sideLength / 2, mouseY + sideLength * SQRT3_2 / 3);
        vertex(mouseX - sideLength / 2, mouseY + sideLength * SQRT3_2 / 3);
        endShape(CLOSE);
      }
      );
      break;
      case "c-rectangle":
      mouseManager.currentInteraction = new AddConstructInteraction((scale, count) -> particleManager.addRectangle(mouseX, mouseY, count, firstOddBefore(count), scale, 1, 1, true), 50, 5, (scale, count) -> {
        noFill();
        stroke(255);
        strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
        rect(mouseX - (count - 1) * scale / 2, mouseY - (count - 1) * scale * SQRT3_2 / 2, (count - 1) * scale, (count - 1) * scale * SQRT3_2);
      }
      );
      break;
      case "c-classicRectangle":
      mouseManager.currentInteraction = new AddConstructInteraction((scale, count) -> particleManager.addClassicRectangle(mouseX, mouseY, count, count, scale, 1, 1, true), 50, 5, (scale, count) -> {
        noFill();
        stroke(255);
        strokeWeight(max(0.9 + sin((float)frameCount / 20), 0));
        rect(mouseX - (count - 1) * scale / 2, mouseY - (count - 1) * scale / 2, (count - 1) * scale, (count - 1) * scale);
      }
      );
      break;
    }
    active = false;
  }

  public void show() {
    for (MenuButton button : buttons) {
      button.show();
    }
  }
}
