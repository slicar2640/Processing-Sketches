import java.util.stream.Collectors;
color[] colors = {#FFFFFF, #FF0000, #00FF00, #0000FF};
float[][] attractionMatrix;
ParticleManager pm;
void setup() {
  size(600, 600);
  pm = new ParticleManager(200);
  attractionMatrix = new float[colors.length][colors.length];
  for(int i = 0; i < colors.length; i++) {
    for(int j = 0; j < colors.length; j++) {
      attractionMatrix[i][j] = random(-1, 1);
    }
  }
}

void draw() {
  background(0);
  pm.update();
  pm.show();
}

float invSqrt(float x) {
    float xhalf = 0.5f * x;
    int i = Float.floatToIntBits(x);
    i = 0x5f3759df - (i >> 1);
    x = Float.intBitsToFloat(i);
    x *= (1.5f - xhalf * x * x);
    return x;
}
