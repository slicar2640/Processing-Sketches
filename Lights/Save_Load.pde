// shape {shape args} material colorType {colorType args}; next
ArrayList<EnvironmentObject> loadEnvironment(String input) {
  ArrayList<EnvironmentObject> env = new ArrayList<EnvironmentObject>();
  String[] objects = input.trim().split(";");
  for (int objIndex = 0; objIndex < objects.length; objIndex++) {
    String objString = objects[objIndex];
    int curIdx = 0;
    String[] components = objString.trim().split(" ");
    String shapeType = components[curIdx++];
    Shape shape;
    switch(shapeType) {
    case "line":
      float x1 = Float.parseFloat(components[curIdx++]);
      float y1 = Float.parseFloat(components[curIdx++]);
      float x2 = Float.parseFloat(components[curIdx++]);
      float y2 = Float.parseFloat(components[curIdx++]);
      shape = new Line(x1, y1, x2, y2);
      break;
    case "circle":
      {
        float x = Float.parseFloat(components[curIdx++]);
        float y = Float.parseFloat(components[curIdx++]);
        float r = Float.parseFloat(components[curIdx++]);
        shape = new Circle(x, y, r);
        break;
      }
    case "arc":
      float x = Float.parseFloat(components[curIdx++]);
      float y = Float.parseFloat(components[curIdx++]);
      float r = Float.parseFloat(components[curIdx++]);
      float a1 = Float.parseFloat(components[curIdx++]);
      float a2 = Float.parseFloat(components[curIdx++]);
      shape = new Arc(x, y, r, a1, a2);
      break;
    default:
      println("Invalid shape [" + shapeType + "] (#" + objIndex + "/" + (objects.length - 1));
      continue;
    }

    String matType = components[curIdx++];
    float ior = 1;
    if(matType.equals("glass")) {
      ior = Float.parseFloat(components[curIdx++]);
    }

    String colType = components[curIdx++];
    ColorType colorType;
    switch(colType) {
    case "solid":
      {
        float r = Float.parseFloat(components[curIdx++]);
        float g = Float.parseFloat(components[curIdx++]);
        float b = Float.parseFloat(components[curIdx++]);
        colorType = new SolidColor(new PVector(r, g, b));
        break;
      }
    case "gradient":
      float r1 = Float.parseFloat(components[curIdx++]);
      float g1 = Float.parseFloat(components[curIdx++]);
      float b1 = Float.parseFloat(components[curIdx++]);
      float r2 = Float.parseFloat(components[curIdx++]);
      float g2 = Float.parseFloat(components[curIdx++]);
      float b2 = Float.parseFloat(components[curIdx++]);
      colorType = new GradientColor(new PVector(r1, g1, b1), new PVector(r2, g2, b2));
      break;
    case "hue-gradient":
      float offset = Float.parseFloat(components[curIdx++]);
      float brightness = Float.parseFloat(components[curIdx++]);
      colorType = new HueGradientColor(offset, brightness);
      break;
    case "split":
      int numColors = Integer.parseInt(components[curIdx++]);
      PVector[] colors = new PVector[numColors];
      float[] thresholds = new float[numColors - 1];
      for (int i = 0; i < numColors; i++) {
        float r = Float.parseFloat(components[curIdx++]);
        float g = Float.parseFloat(components[curIdx++]);
        float b = Float.parseFloat(components[curIdx++]);
        colors[i] = new PVector(r, g, b);
      }
      for (int i = 0; i < numColors - 1; i++) {
        float t = Float.parseFloat(components[curIdx++]);
        thresholds[i] = t;
      }
      colorType = new SplitColor(colors, thresholds);
      break;
    default:
      println("Invalid color type [" + colType + "] (#" + objIndex + "/" + (objects.length - 1));
      continue;
    }

    Material material;
    switch(matType) {
    case "light":
      material = new LightMaterial(colorType);
      break;
    case "glass":
      material = new GlassMaterial(colorType, ior);
      break;
    default:
      println("Invalid material [" + matType + "] (#" + objIndex + "/" + (objects.length - 1));
      continue;
    }

    EnvironmentObject obj = new EnvironmentObject(shape, material);
    env.add(obj);
  }
  return env;
}

String environmentExportString() {
  String exportString = "";
  for (EnvironmentObject obj : environment) {
    exportString += obj.getExportString() + ";";
  }
  return exportString.substring(0, exportString.length() - 1);
}
