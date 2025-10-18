ArrayList<EnvironmentObject> randomEnvironment(int num) {
  ArrayList<EnvironmentObject> env = new ArrayList<EnvironmentObject>();
  for (int i = 0; i < num; i++) {
    env.add(randomObject());
  }
  return env;
}

EnvironmentObject randomObject() {
  int randShape = (int) random(4);

  Shape shape = randomShape(randShape);

  Material material = randomMaterial(randShape);

  if (random(100) < 10) { //refractive glass
    shape = new Circle(random(width), random(height), random(20, 100));
    ColorType colorType = new SolidColor(new PVector(255, 255, 255));
    material = new GlassMaterial(colorType, random(1.2, 2));
  }

  EnvironmentObject obj = new EnvironmentObject(shape, material);
  return obj;
}

Shape randomShape(int rand) {
  if (rand == 0) {
    return new Line(random(width), random(height), random(width), random(height));
  } else if (rand == 1) {
    return new Circle(random(width), random(height), random(20, 100));
  } else if (rand == 2) {
    return new Arc(random(width), random(height), random(20, 100), random(TWO_PI), random(TWO_PI));
  } else {
    return new Bezier(random(width), random(height), random(width), random(height), random(width), random(height), random(width), random(height));
  }
}

ColorType randomColorType(int shape) {
  if (shape == 0 || shape == 2 || shape == 3) { //line or arc or bezier
    int rand = (int) random(4);
    if (rand == 0) {
      return new SolidColor(randomColor());
    } else if (rand == 1) {
      return new GradientColor(randomColor(), randomColor());
    } else if (rand == 2) {
      return new HueGradientColor(random(360), random(100));
    } else {
      int numColors = (int) random(2, 5);
      PVector[] colors = new PVector[numColors];
      for (int i = 0; i < numColors; i++) {
        colors[i] = randomColor();
      }
      float[] thresholds = new float[numColors - 1];
      float t = 0;
      for (int i = 0; i < numColors - 1; i++) {
        t += random(0.5 / numColors, 1.5 / numColors);
        thresholds[i] = min(t, 1 - 0.5 / numColors);
      }
      return new SplitColor(colors, thresholds);
    }
  } else { //circle
    int rand = (int) random(3);
    if (rand == 0) {
      return new SolidColor(randomColor());
    } else if (rand == 1) {
      return new HueGradientColor(random(360), random(100));
    } else {
      int numColors = (int) random(2, 5);
      PVector[] colors = new PVector[numColors];
      for (int i = 0; i < numColors; i++) {
        colors[i] = randomColor();
      }
      float[] thresholds = new float[numColors - 1];
      float t = 0;
      for (int i = 0; i < numColors - 1; i++) {
        t += random(0.5 / numColors, 1.5 / numColors);
        thresholds[i] = min(t, 1 - 0.5 / numColors);
      }
      return new SplitColor(colors, thresholds, random(1));
    }
  }
}

Material randomMaterial(int shape) {
  int rand = (int) random(2);
  if (rand == 0) { // single-sided
    ColorType colorType = randomColorType(shape);
    rand = (int) random(2);
    if (rand == 0) {
      return new LightMaterial(colorType);
    } else {
      return new GlassMaterial(colorType);
    }
  } else { //double-sided
    ColorType ct1 = randomColorType(shape);
    ColorType ct2 = randomColorType(shape);
    Material mat1, mat2;
    rand = (int) random(2);
    if(rand == 0) {
      mat1 = new LightMaterial(ct1);
    } else {
      mat1 = new GlassMaterial(ct1);
    }
    rand = (int) random(2);
    if(rand == 0) {
      mat2 = new LightMaterial(ct2);
    } else {
      mat2 = new GlassMaterial(ct2);
    }
    return new DoubleMaterial(mat1, mat2);
  }
}
