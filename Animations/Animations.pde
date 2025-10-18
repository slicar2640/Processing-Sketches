import java.util.function.Consumer;
import java.util.function.Supplier;

AnimationManager am = new AnimationManager();
InterpolatorFactory interpolators = new InterpolatorFactory();
EasingFactory easingFunctions = new EasingFactory();
Rectangle rect1 = new Rectangle(100, 100, 20, 20, am);
boolean paused = false;
void setup() {
  size(600, 600);
  rect1.animate("x", 30, 90, 100, 300, easingFunctions.linear);
  rect1.animate("y", 30, 90, 100, 200, t -> -4 * t * t + 4 * t);
  rect1.animate("fill", 30, 90, new PVector(255, 255, 255), new PVector(255, 0, 0), easingFunctions.inOutSine);
}

void draw() {
  if (!paused) {
    background(200);
    am.update();
    rect1.show();
  }
}

void mousePressed() {
  int startFrame = max(rect1.lastFrame(), am.frame + 1);
  Animation<Float> xAnim = new Animation<>(rect1, rect1::setX, startFrame, startFrame + 60, rect1::getX, (float) mouseX, interpolators.floatInterpolator, easingFunctions.linear);
  xAnim.endAction = () -> xAnim.remove();
  Animation<Float> yAnim = new Animation<>(rect1, rect1::setY, startFrame, startFrame + 60, rect1::getY, (float) mouseY, interpolators.floatInterpolator, easingFunctions.linear);
  yAnim.endAction = () -> yAnim.remove();
  
  rect1.animate(xAnim);
  rect1.animate(yAnim);
}

void keyPressed() {
  paused = !paused;
}
