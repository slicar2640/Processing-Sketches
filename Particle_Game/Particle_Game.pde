ParticleManager particleManager;
MouseInteractionManager mouseManager;
MenuManager menuManager;
final float SQRT3_2 = 0.86602540378;
final float SQRT2 = 1.41421356237;
boolean justExitedMenu = false;
boolean paused = false;
boolean shiftPressed = false, ctrlPressed = false, altPressed = false;
ArrayList<String> millises = new ArrayList<>();
int lastMillis = 0;

void setup() {
  size(600, 600);
  particleManager = new ParticleManager(0, 10);
  mouseManager = new MouseInteractionManager(pushInteraction);
  menuManager = new MenuManager();
}

void draw() {
  background(0);
  if (menuManager.active) {
    menuManager.show();
  } else {
    if (!paused) {
      particleManager.update(1, 20);
    }
    if (mousePressed) {
      if (!justExitedMenu) {
        mouseManager.mouseDown();
      }
    }
    particleManager.show();

    if (keyPressed) {
      if (key == 'd') {
        fill(255, 150);
        noStroke();
        textAlign(LEFT, TOP);
        textSize(20);
        text(particleManager.numParticles + ", " + particleManager.numSticks() + "\n" + frameRate, 10, 10);
        //mouseManager.showDebug();
      }
    }

    mouseManager.show();
  }
}

void mouseWheel(MouseEvent e) {
  mouseManager.updateScale(-e.getCount());
}

void mousePressed() {
  if (menuManager.active) {
    menuManager.click();
  } else if (!justExitedMenu) {
    mouseManager.mouseClick();
  }
}

void mouseReleased() {
  justExitedMenu = false;
  if(!menuManager.active) {
    mouseManager.mouseUp();
  }
}

void keyPressed() {
  if (keyCode == SHIFT) shiftPressed = true;
  if (keyCode == CONTROL) ctrlPressed = true;
  if (keyCode == ALT) altPressed = true;
  if (!menuManager.active) {
    switch(key) {
    case '1':
      mouseManager.currentInteraction = pushInteraction;
      break;
    case '2':
      mouseManager.currentInteraction = deleteInteraction;
      break;
    case '3':
      menuManager.active = true;
      break;
    case '4':
      mouseManager.currentInteraction = addStickInteraction;
      addStickInteraction.p1 = null;
      break;
    case '5':
      mouseManager.currentInteraction = new GrabInteraction(0.1);
      break;
    case '-':
      mouseManager.updateCount(-1);
      break;
    case '=':
      mouseManager.updateCount(1);
      break;
    case ' ':
      paused = !paused;
      break;
    }
  }
}

void keyReleased() {
  if (keyCode == SHIFT) shiftPressed = false;
  if (keyCode == CONTROL) ctrlPressed = false;
  if (keyCode == ALT) altPressed = false;
}

int firstOddBefore(int x) {
  return floor((x - 1) / 2) * 2 + 1;
}
