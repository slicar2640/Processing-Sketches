import java.util.Arrays;
int[][] growDirections = {
  {0, -1},
  {1, 0},
  {0, 1},
  {-1, 0}
};

int scrollStart, mouseStart;

int[][] testGenome = {{11, 21, 19, 26, 40, 30, 14}, {27, 18, 19, 27, 55, 8, 0}, {4, 1, 2, 15, 2, 36, 5}, {29, 9, 27, 4, 26, 38, 9}, {27, 19, 22, 4, 22, 8, 0}, {10, 4, 25, 21, 48, 24, 17}, {21, 11, 20, 16, 59, 30, 14}, {7, 28, 2, 8, 59, 10, 11}, {8, 31, 31, 23, 62, 52, 4}, {0, 13, 2, 30, 56, 11, 17}, {24, 30, 16, 15, 18, 10, 12}, {18, 14, 0, 23, 18, 56, 17}, {27, 13, 30, 2, 18, 56, 5}, {20, 6, 22, 18, 39, 47, 8}, {3, 27, 29, 29, 38, 23, 4}, {2, 14, 2, 16, 23, 5, 3}};

World world;
int fullWidth = 2000;
int screenWidth = 400;
boolean paused = false;

void setup() {
  size(1200, 600);
  colorMode(HSB, 360, 100, 100);
  int s = width / screenWidth;
  int sx = fullWidth / 2 - screenWidth / 2;
  world = new World(fullWidth, screenWidth / 2, screenWidth, sx, fullWidth / 4, fullWidth / 2, s);
  for (int i = -50 * 3; i <= 50 * 3; i += 50) {
    world.start(fullWidth / 2 + i, 50);
  }
  //world.start(testGenome);
  //frameRate(2);
}

void draw() {
  background(0);
  if (world.trees.size() == 0) {
    for (int i = -50 * 3; i <= 50 * 3; i += 50) {
      world.sunX = fullWidth / 4;
      world.start(fullWidth / 2 + i, 50);
    }
  }
  if (!paused) {
    world.update();
  }
  world.show();

  if (mousePressed) {
    world.screenX = scrollStart - round((mouseX - mouseStart) / world.cellSize);
    world.screenX = (world.screenX + world.cols) % world.cols;
  }
  textAlign(LEFT, TOP);
  textSize(20);
  fill(255);
  stroke(255);
  strokeWeight(1);
  text("Sun energy: " + (world.sunEnergy < 10 ? "0" : "") + world.sunEnergy + " + / -", 5, 80);
  text("Moon energy: " + (world.moonEnergy < 10 ? "0" : "") + world.moonEnergy + " + / -", 5, 100);
}

void mousePressed() {
  if(abs(mouseX - 137) <= 8 && abs(mouseY - 88) <= 8) {
    world.sunEnergy++;
  }
  if(abs(mouseX - 160) <= 8 && abs(mouseY - 88) <= 8) {
    world.sunEnergy--;
    world.sunEnergy = max(0, world.sunEnergy);
  }
  if(abs(mouseX - 152) <= 8 && abs(mouseY - 108) <= 8) {
    world.moonEnergy++;
  }
  if(abs(mouseX - 175) <= 8 && abs(mouseY - 108) <= 8) {
    world.moonEnergy--;
    world.moonEnergy = max(0, world.moonEnergy);
  }
  
  scrollStart = world.screenX;
  mouseStart = mouseX;
  if (mouseButton == RIGHT) {
    int[] mouseCell = world.mouseToCell(mouseX, mouseY);
    Tree hovered = world.treeAtPos(mouseCell[0], mouseCell[1]);
    if(hovered != null) {
      println(hovered.genomeString());
    }
  }
}

void mouseWheel(MouseEvent event) {
  int dx = (int) (event.getCount() * 5);
  world.screenX += dx;
  world.screenX = (world.screenX + world.cols) % world.cols;
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
  if(key == 's') {
    world.update();
  }
}

color darken(color c) {
  return color(hue(c), saturation(c), brightness(c) * 0.7);
}
