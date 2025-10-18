class Hit {
  PVector pos;
  int cellX, cellY;
  color hitColor;
  Hit(PVector pos, int cellX, int cellY, color col) {
    this.pos = pos;
    this.cellX = cellX;
    this.cellY = cellY;
    this.hitColor = col;
  }
  
  Hit(PVector pos, color col) {
    this.pos = pos;
    this.hitColor = col;
  }
}
