color[] destinationColors = {#FF7F29, #29B9FF, #1FFF42, #FF2951};
World world;
void setup() {
  size(600, 600);
  world = new World(3, 1, 2000);
}

void draw() {
  background(0);
  world.update();
  world.show();
}
