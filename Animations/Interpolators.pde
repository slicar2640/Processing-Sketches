interface Interpolator<T> {
  T interpolate(T start, T end, float t);
}

class InterpolatorFactory {
  Interpolator<Integer> intInterpolator;
  Interpolator<Float> floatInterpolator;
  Interpolator<PVector> pVectorInterpolator;

  InterpolatorFactory() {
    intInterpolator = (start, end, t) -> Math.round(start + (end - start) * t);
    floatInterpolator = (start, end, t) -> start + (end - start) * t;
    pVectorInterpolator = (start, end, t) -> PVector.lerp(start, end, t);
  }
}
