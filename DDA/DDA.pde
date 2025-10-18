GridManager gm;
QuadtreeManager qm;

PImage environmentImg;
boolean run = false;

int samples = 360;
int yOff = 0;
int rowsPerFrame = 2;

void setup() {
  size(600, 600);
  noSmooth();
  selectInput("Select an image:", "fileSelected", dataFile("DDA"));
  background(0);
}

void draw() {
  if (run) {
    loadPixels();
    for (int row = 0; row < rowsPerFrame; row++) {
      for (int x = 0; x < width; x++) {
        float r = 0, g = 0, b = 0;
        //int steps = 0;
        for (float a = 0; a < TWO_PI; a += TWO_PI / samples) {
          Hit hit = qm.DDACast(x, yOff, a);
          r += (hit.hitColor >> 16) & 0xff;
          g += (hit.hitColor >> 8) & 0xff;
          b += hit.hitColor & 0xff;
          //steps += qm.DDASteps(x, yOff, a);
        }
        //pixels[x + yOff * width] = color(steps / 20);
        int R = (int)min(r / samples, 255);
        int G = (int)min(g / samples, 255);
        int B = (int)min(b / samples, 255);
        pixels[x + yOff * width] = 0xff000000 | R << 16 | G << 8 | B;
      }
      yOff++;
      if (yOff >= height) {
        noLoop();
        break;
      }
    }
    updatePixels();
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    exit();
  } else {
    environmentImg = loadImage(selection.getName());
    gm = new GridManager(environmentImg);
    qm = new QuadtreeManager(environmentImg);
    run = true;
  }
}
