//NOTE: I don't know how I want to do wrapping with composites.

WorldManager manager;
Movable mover;

void setup() {
  size(600, 600);
  manager = new WorldManager(width / 10, height / 10, WallType.STOP);
  manager.addId(1, #FFFFFF);
  manager.addId(2, #888888);
  manager.addId(3, #FFFF55);
  manager.addId(4, #FF2244);
  manager.setInteraction(1, 1, new PushInteraction(PushType.PUSH));
  manager.setInteraction(1, 2, new PushInteraction(PushType.STOP));
  manager.setInteraction(1, 3, new PushInteraction(PushType.PUSH));
  manager.setInteraction(1, 4, new PushInteraction(PushType.PUSH));
  manager.setInteraction(2, 3, new PushInteraction(PushType.STOP));
  manager.setInteraction(3, 3, new PushInteraction(PushType.PUSH));
  manager.setInteraction(3, 4, new PushInteraction(PushType.STOP));

  for (int i = 20; i < 30; i++) {
    for (int j = 20; j <= 22; j++) {
      CornerBlock cb = new CornerBlock(i, j, 3, manager.defaultInteractions.get(3), manager);
      manager.addBlock(cb);
    }
  }
  manager.addBlock(19, 19, 4);

  for (int i = 20; i <= 22; i++) {
    manager.addBlock(31, i, 2);
  }

  mover = manager.addBlock(18, 21, 1);

  //int[][] ids = {{1, 1, 1, 1, 1}, {1, 0, 0, 0, 1}, {1, 0, 0, 0, 1}, {1, 0, 0, 0, 1}, {1, 1, 1, 1, 1}};
  //mover = new Composite(8, 18, 5, 5, ids, manager);
  //manager.addComposite((Composite)mover);
}

void draw() {
  manager.showRect();
  stroke(255, 0, 0);
  strokeWeight(4);
}

void keyPressed() {
  Direction dir;
  if (key == 'w' || keyCode == UP) {
    dir = Direction.UP;
  } else if (key == 'd' || keyCode == RIGHT) {
    dir = Direction.RIGHT;
  } else if (key == 's' || keyCode == DOWN) {
    dir = Direction.DOWN;
  } else if (key == 'a' || keyCode == LEFT) {
    dir = Direction.LEFT;
  } else return;
  if (mover.canMove(dir)) {
    mover.move(dir);
  }
}
