class CornerBlock extends Block {
  int sideOffset = 0;
  boolean didGoStraight = true;
  CornerBlock(int x, int y, int id, HashMap<Integer, PushInteraction> pushInteractions, WorldManager manager) {
    super(x, y, id, pushInteractions, manager);
    if (random(1) < 0.5) sideOffset = 1;
  }

  @Override
    boolean canMove(Direction dir) {
    didGoStraight = true;
    if (super.canMove(dir)) return true;
    didGoStraight = false;
    Direction[] perps = perpendiculars(dir);
    if (super.canMove(perps[sideOffset])) return true;
    sideOffset = (sideOffset + 1) % 2;
    return super.canMove(perps[sideOffset]);
  }

  @Override
    void move(Direction dir) {
    if (didGoStraight) {
      super.move(dir);
    } else {
      Direction[] perps = perpendiculars(dir);
      super.move(perps[sideOffset]);
    }
    if (random(1) < 0.5) sideOffset = (sideOffset + 1) % 2;
  }
}
