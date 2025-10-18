class QuadtreeManager {
  PImage img;
  int worldWidth, worldHeight;
  float scale;
  QuadtreeNode rootNode;
  QuadtreeManager(PImage img) {
    this.img = img;
    worldWidth = img.width;
    worldHeight = img.height;
    scale = (float)width / worldWidth;
    int maxwh = max(worldWidth, worldHeight);
    int rootWidth = getRootWidth(maxwh);
    rootNode = new QuadtreeNode(0, 0, rootWidth, null, this);
  }

  int getColor(int x, int y) {
    if (x >= worldWidth || y >= worldHeight) return 0xff000000;
    return img.pixels[x + y * worldWidth];
  }
  
  int DDASteps(float sx, float sy, float a) {
    float x = sx;
    float y = sy;
    float tanA = tan(a);
    boolean negativeY = sin(a) < 0;
    boolean negativeX = cos(a) < 0;
    int steps = 0;
    QuadtreeNode currentLeaf = rootNode.tr;
    while (x > 0 && x < width - 1 && y > 0 && y < height - 1) {
      steps++;
      currentLeaf = currentLeaf.parent.getLeaf(x / scale, y / scale, negativeX, negativeY);
      if (currentLeaf.state == 1) {
        return steps;
      }
      float dx = (currentLeaf.x + (negativeX ? 0 : currentLeaf.w)) * scale - x;
      float dy = (currentLeaf.y + (negativeY ? 0 : currentLeaf.w)) * scale - y;
      if (dx == 0 || dy == 0) {
        println("problem: dx or dy is 0");
        break;
      }
      float cx, cy;
      if (Math.abs(dy) < Math.abs(dx * tanA)) {
        cx = dy / tanA;
        cy = dy;
      } else {
        cx = dx;
        cy = dx * tanA;
      }
      x += cx;
      y += cy;
    }
    return steps;
  }

  Hit DDACast(float sx, float sy, float a) {
    float x = sx;
    float y = sy;
    float tanA = tan(a);
    boolean negativeY = sin(a) < 0;
    boolean negativeX = cos(a) < 0;
    QuadtreeNode currentLeaf = rootNode.tr;
    while (x > 0 && x < width - 1 && y > 0 && y < height - 1) {
      currentLeaf = currentLeaf.parent.getLeaf(x / scale, y / scale, negativeX, negativeY);
      if (currentLeaf.state == 1) {
        return new Hit(new PVector(x, y), currentLeaf.col);
      }
      float dx = (currentLeaf.x + (negativeX ? 0 : currentLeaf.w)) * scale - x;
      float dy = (currentLeaf.y + (negativeY ? 0 : currentLeaf.w)) * scale - y;
      if (dx == 0 || dy == 0) {
        println("problem: dx or dy is 0");
        break;
      }
      float cx, cy;
      if (Math.abs(dy) < Math.abs(dx * tanA)) {
        cx = dy / tanA;
        cy = dy;
      } else {
        cx = dx;
        cy = dx * tanA;
      }
      x += cx;
      y += cy;
    }
    return new Hit(new PVector(x, y), 0xff000000);
  }

  void show() {
    rootNode.show();
  }

  int getRootWidth(int wid) {
    for(int i = 0; i < 20; i++) {
      if(1 << i >= wid) return 1 << i;
    }
    throw new IllegalArgumentException("Width is greater than 2^20 (1,048,576)");
  }
}
