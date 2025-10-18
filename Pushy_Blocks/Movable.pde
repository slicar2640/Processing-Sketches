abstract class Movable {
  int x, y;
  WorldManager manager;
  abstract boolean canMove(Direction dir);
  abstract void move(Direction dir);
}

enum Direction {
  UP,
    RIGHT,
    DOWN,
    LEFT
}

Direction[] perpendiculars(Direction dir) {
  if(dir == Direction.UP || dir == Direction.DOWN) {
    Direction[] perps = {Direction.RIGHT, Direction.LEFT};
    return perps;
  } else {
    Direction[] perps = {Direction.UP, Direction.DOWN};
    return perps;
  }
}
