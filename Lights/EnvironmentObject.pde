class EnvironmentObject {
  Shape shape;
  Material material;
  EnvironmentObject(Shape s, Material m) {
    shape = s;
    material = m;
  }

  PVector getColor(Intersection intersection) {
    return material.getColor(intersection);
  }

  Intersection intersect(Ray ray) {
    return shape.intersect(ray);
  }

  void show() {
    shape.show(material);
  }

  void matShow() {
    shape.matShow(material);
  }
  
  // shape {shape args} material colorType {colorType args}
  String getExportString() {
    String exportString = "";
    exportString += shape.getExportString();
    exportString += material.getExportString();
    return exportString;
  }
}
