abstract class Material {
  ColorType colorType;

  abstract PVector getColor(Intersection intersection);
  abstract String getExportString();
}

class LightMaterial extends Material {
  LightMaterial(ColorType ct) {
    colorType = ct;
  }

  PVector getColor(Intersection intersection) {
    return colorType.getColor(intersection.factor);
  }

  String getExportString() {
    String exportString = "light ";
    exportString += colorType.getExportString();
    return exportString;
  }
}

class GlassMaterial extends Material {
  float IOR = 1;
  GlassMaterial(ColorType ct, float ior) {
    colorType = ct;
    IOR = ior;
  }

  GlassMaterial(ColorType ct) {
    colorType = ct;
  }

  PVector getColor(Intersection intersection) {
    PVector throughColor = new PVector(0, 0, 0);
    if(IOR == 1) {
      throughColor = trace(intersection.position.add(intersection.ray.direction), intersection.ray.direction.heading());
    } else {
      float dot = intersection.ray.direction.dot(intersection.normal);
      float n1 = dot < 0 ? 1 : IOR;
      float n2 = dot < 0 ? IOR : 1;
      float a1 = (intersection.ray.direction.heading() - (PI * (dot > 0 ? 0 : 1)) - intersection.normal.heading() + TWO_PI + HALF_PI) % TWO_PI - HALF_PI;
      float a2 = intersection.normal.heading() + (PI * (dot > 0 ? 0 : 1)) + asin(n1 * sin(a1) / n2);
      if(!Float.isNaN(a2)) throughColor = trace(intersection.position.add(intersection.ray.direction), a2);
    }
    PVector transmission = colorType.getColor(intersection.factor).copy();
    transmission.div(255);
    return new PVector(throughColor.x * transmission.x, throughColor.y * transmission.y, throughColor.z * transmission.z);
  }

  //material colorType {colorType args}
  String getExportString() {
    String exportString = "glass ";
    exportString += IOR + " ";
    exportString += colorType.getExportString();
    return exportString;
  }
}

class DoubleMaterial extends Material {
  Material material1, material2;
  DoubleMaterial(Material mat1, Material mat2) {
    material1 = mat1;
    material2 = mat2;
  }
  
  PVector getColor(Intersection intersection) {
    if(intersection.ray.direction.dot(intersection.normal) < 0) {
      return material1.getColor(intersection);
    } else {
      return material2.getColor(intersection);
    }
  }
  
  String getExportString() {
    String exportString = "double ";
    exportString += material1.getExportString();
    exportString += material2.getExportString();
    return exportString;
  }
}
