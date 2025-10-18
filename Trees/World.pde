class World {
  int cols, rows;
  int screenWidth;
  int screenX;
  float cellSize;
  ArrayList<Tree> trees = new ArrayList<Tree>();
  int[][] collision;
  int startEnergy = 300;
  int lifespanMin = 50;
  int lifespanMax = 100;
  int sunEnergy = 10, moonEnergy = 10;
  int sunX, sunWidth;
  World(int cols, int rows, int screenWidth, int screenX, int sunX, int sunWidth, float size) {
    this.cols = cols;
    this.rows = rows;
    collision = new int[cols][rows]; //0: empty; -n: offshoot with id n; +n: body of tree with id n
    cellSize = size;
    this.screenWidth = screenWidth;
    this.screenX = screenX;
    this.sunX = sunX;
    this.sunWidth = sunWidth;
  }

  World(int cols, int rows, float size) {
    this.cols = cols;
    this.rows = rows;
    collision = new int[cols][rows];
    cellSize = size;
    this.screenWidth = cols;
    this.screenX = 0;
  }

  void update() {
    for (int[] row : collision) {
      Arrays.fill(row, 0);
    }
    for (Tree tree : trees) {
      for (Cell cell : tree.body) {
        world.collision[cell.x][cell.y] = tree.id;
      }
      for (Cell cell : tree.ends) {
        world.collision[cell.x][cell.y] = -tree.id;
      }
    }
    for (Tree tree : (ArrayList<Tree>)trees.clone()) {
      tree.update();
    }
    sunX = (sunX + 1) % cols;
  }

  void start() {
    Tree tree = new Tree(cols / 2, rows / 2, color(100, 90, 100), this);
    tree.falling = true;
    trees.add(tree);
  }

  void start(int x, int y) {
    Tree tree = new Tree(x, y, color(100, 90, 100), this);
    tree.falling = true;
    trees.add(tree);
  }

  void start(int[][] startGenome) {
    Tree tree = new Tree(cols / 2, rows / 2, (int) random(lifespanMin, lifespanMax), color(100, 90, 100), this, startGenome);
    tree.falling = true;
    trees.add(tree);
  }

  void start(int x, int y, int[][] startGenome) {
    Tree tree = new Tree(x, y, (int) random(lifespanMin, lifespanMax), color(100, 90, 100), this, startGenome);
    tree.falling = true;
    trees.add(tree);
  }

  int getSun(int x) {
    return (x >= sunX && x < sunX + sunWidth) || (x + cols >= sunX && x + cols < sunX + sunWidth) ? sunEnergy : moonEnergy;
  }

  Tree treeAtPos(int x, int y) {
    if (x < 0 || x >= cols || y < 0 || y >= rows) return null;
    if (collision[x][y] == 0) return null;
    return getTreeById(collision[x][y]);
  }

  int[] mouseToCell(int mx, int my) {
    int cellY = floor(my / cellSize);
    int cellX = floor(mx / cellSize) + screenX;
    int[] arr = {cellX, cellY};
    return arr;
  }

  int nextId() {
    for (int i = 1; i < 10000; i++) {
      for (Tree t : trees) {
        boolean used = false;
        if (t.id == i) {
          used = true;
          break;
        }
        if (!used) {
          return i;
        }
      }
    }
    return 10001;
  }

  Tree getTreeById(int id) {
    for (Tree t : trees) {
      if (t.id == id) return t;
    }
    return null;
  }

  boolean isInScreen(int x) {
    return (x >= screenX && x < screenX + screenWidth) || (x + cols >= screenX && x + cols < screenX + screenWidth);
  }

  void show() {
    //for(int i = 0; i < cols; i++) {
    //  for(int j = 0; j < rows; j++) {
    //    fill(collision[i][j] == 2 ? 255 : 0, 0, collision[i][j] == 1 ? 255 : 0);
    //    noStroke();
    //    rect(i * cellSize, j * cellSize, cellSize, cellSize);
    //  }
    //}
    for (Tree tree : trees) {
      tree.show();
    }

    //screen scrollbar
    stroke(0, 0, 50);
    strokeWeight(6);
    line((float) screenX / cols * width, 20, (float) (screenX + screenWidth) / cols * width, 20);
    line((float) screenX / cols * width - width, 20, (float) (screenX + screenWidth) / cols * width - width, 20);

    //world sun bar
    stroke(#FFBC00);
    strokeWeight(2);
    line((float) sunX / cols * width, 10, (float) (sunX + sunWidth) / cols * width, 10);
    line((float) sunX / cols * width - width, 10, (float) (sunX + sunWidth) / cols * width - width, 10);
    stroke(#2C00E3);
    line((float) (sunX + sunWidth) / cols * width, 10, width, 10);
    line((float) (sunX + sunWidth - cols) / cols * width, 10, (float) sunX / cols * width, 10);

    //screen sun bar
    fill(#FFBC00, 50);
    noStroke();
    rect((sunX - screenX) * cellSize, 30, sunWidth * cellSize, 40);
    rect((sunX + cols - screenX) * cellSize, 30, sunWidth * cellSize, 40);
    rect((sunX - cols - screenX) * cellSize, 30, sunWidth * cellSize, 40);
  }
}
