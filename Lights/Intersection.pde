class Intersection {
  Ray ray;
  PVector position;
  PVector normal;
  float factor;
  Intersection(Ray r, PVector p, PVector n, float f) {
    ray = r;
    position = p;
    normal = n;
    factor = f;
  }
}
