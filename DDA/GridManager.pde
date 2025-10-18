class GridManager {
  int cols, rows;
  float scale;
  int[] colors;
  boolean[] filled;
  PImage displayImage;
  GridManager(float scl) {
    this.scale = scl;
    this.cols = (int) (width / scl);
    this.rows = (int) (height / scl);
    this.colors = new int[cols * rows];
    this.filled = new boolean[cols * rows];
  }

  GridManager(PImage img) {
    this.displayImage = img;
    this.scale = (float)width / img.width;
    this.cols = img.width;
    this.rows = img.height;
    this.colors = new int[cols * rows];
    this.filled = new boolean[cols * rows];
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
        color c = img.pixels[i];
        colors[i] = c;
        filled[i] = alpha(c) > 0;
    }
  }

  void setCell(int x, int y, boolean v) {
    filled[x + y * cols] = v;
  }

  Hit DDACast(float sx, float sy, float a) {
    float x = sx;
    float y = sy;
    int cellX = floor(x / scale);
    int cellY = floor(y / scale);
    float tanA = tan(a);
    boolean negativeY = sin(a) < 0;
    boolean negativeX = cos(a) < 0;
    boolean didHitSomething = false;
    while (x > 0 && x < width - 1 && y > 0 && y < height - 1 &&
      cellX >= 0 && cellX < cols && cellY >= 0 && cellY < rows) {
      if (filled[cellX + cellY * cols]) {
        didHitSomething = true;
        break;
      }
      float dx = (cellX + (negativeX ? 0 : 1)) * scale - x;
      float dy = (cellY + (negativeY ? 0 : 1)) * scale - y;
      float cx, cy;
      boolean topBottom = false;
      if (Math.abs(dy) < Math.abs(dx * tanA)) {
        cx = dy / tanA;
        cy = dy;
        topBottom = true;
      } else {
        cx = dx;
        cy = dx * tanA;
      }
      x += cx;
      y += cy;
      if (topBottom) {
        cellY += cy < 0 ? -1 : cy > 0 ? 1 : negativeY ? -1 : 1;
      } else {
        cellX += cx < 0 ? -1 : cx > 0 ? 1 : negativeX ? -1 : 1;
      }
    }
    cellX = constrain(cellX, 0, cols - 1);
    cellY = constrain(cellY, 0, rows - 1);
    return new Hit(new PVector(x, y), cellX, cellY, didHitSomething ? colors[cellX + cellY * cols] : color(0));
  }

  void show() {
    if (displayImage != null) {
      image(displayImage, 0, 0, width, height);
    } else {
      stroke(0);
      strokeWeight(2);
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          fill(filled[i + j * cols] ? 0 : 255);
          rect(i * scale, j * scale, scale, scale);
        }
      }
    }
  }
}
