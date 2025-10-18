class QuadtreeNode {
  int state;
  float alpha;
  color col;
  QuadtreeNode tl, tr, bl, br;
  int x, y, w;
  QuadtreeNode parent;
  QuadtreeManager manager;
  String id;
  QuadtreeNode(int x, int y, int w, QuadtreeNode parent, QuadtreeManager manager) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.id = "";
    this.parent = parent;
    this.manager = manager;
    init();
  }

  QuadtreeNode(int x, int y, int w, String id, QuadtreeNode parent, QuadtreeManager manager) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.id = id;
    this.parent = parent;
    this.manager = manager;
    init();
  }

  void init() {
    if (w == 1) {
      col = manager.getColor(x, y);
      state = alpha(col) > 0 ? 1 : 0;
      alpha = alpha(col) / 255;
    } else {
      color firstColor = manager.getColor(x, y);
      boolean split = false;
    outerLoop:
      for (int j = y; j < y + w; j++) {
        for (int i = x; i < x + w; i++) {
          if (manager.getColor(i, j) != firstColor) {
            split = true;
            break outerLoop;
          }
        }
      }
      if (split) {
        tl = new QuadtreeNode(x, y, w / 2, id + "_TL", this, manager);
        tr = new QuadtreeNode(x + w / 2, y, w / 2, id + "_TR", this, manager);
        bl = new QuadtreeNode(x, y + w / 2, w / 2, id + "_BL", this, manager);
        br = new QuadtreeNode(x + w / 2, y + w / 2, w / 2, id + "_BR", this, manager);
        state = 2;
      } else {
        col = manager.getColor(x, y);
        state = alpha(col) > 0 ? 1 : 0;
        alpha = alpha(col) / 255;
      }
    }
  }

  QuadtreeNode getLeaf(float px, float py) {
    if (px < x || py < y || px >= x + w || py >= y + w) return null;
    if (state == 2) {
      if (px < x + w / 2) {
        if (py < y + w / 2) {
          return tl.getLeaf(px, py);
        } else {
          return bl.getLeaf(px, py);
        }
      } else {
        if (py < y + w / 2) {
          return tr.getLeaf(px, py);
        } else {
          return br.getLeaf(px, py);
        }
      }
    } else {
      return this;
    }
  }

  QuadtreeNode getLeaf(float px, float py, boolean negX, boolean negY) {
    if (px < x || py < y || px > x + w || py > y + w ||
        (px == x && negX) || (px == x + w && !negX) ||
        (py == y && negY) || (py == y + w && !negY)) {
      if(parent != null) {
        return parent.getLeaf(px, py, negX, negY);
      } else {
        return null;
      }
    }
    if (state == 2) {
      int xMid = x + w / 2;
      int yMid = y + w / 2;
      boolean left = px < xMid ? true : px > xMid ? false : negX;
      boolean top = py < yMid ? true : py > yMid ? false : negY;
      return (top ? left ? tl : tr : left ? bl : br).getLeaf(px, py, negX, negY);
    } else {
      return this;
    }
  }

  void show() {
    if (w * manager.scale > 1 && x < manager.worldWidth && y < manager.worldHeight) {
      if (state == 2) {
        tl.show();
        tr.show();
        bl.show();
        br.show();
      } else {
        stroke(255);
        strokeWeight(2);
        fill(col);
        rect(x * manager.scale, y * manager.scale, w * manager.scale, w * manager.scale);
      }
    }
  }

  void show(boolean d) {
    stroke(255, 0, 0);
    strokeWeight(2);
    fill(col);
    rect(x * manager.scale, y * manager.scale, w * manager.scale, w * manager.scale);
  }
}
