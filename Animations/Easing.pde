@FunctionalInterface
interface EasingFunction {
  float ease(float t);
}

class EasingFactory {
  EasingFunction linear, inOutSine, inCirc, outCirc;

  EasingFactory() {
    linear = t -> t;
    inOutSine = t -> (float) -(Math.cos(Math.PI * t) - 1) / 2;
    inCirc = t -> 1 - (float) Math.sqrt(1 - Math.pow(t, 2));
    outCirc = t -> (float) Math.sqrt(1 - Math.pow(t - 1, 2));
  }
}
