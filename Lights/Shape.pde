//TODO: showing of double materials //<>//

abstract class Shape {
  abstract Intersection intersect(Ray ray);
  abstract void show(Material material);
  abstract void matShow(Material material);
  abstract String getExportString();
}

class Line extends Shape {
  PVector p1;
  PVector p2;
  PVector normal;
  Line(PVector p1, PVector p2) {
    this.p1 = p1;
    this.p2 = p2;
    normal = PVector.sub(p2, p1).rotate(HALF_PI).normalize();
  }

  Line(float x1, float y1, float x2, float y2) {
    p1 = new PVector(x1, y1);
    p2 = new PVector(x2, y2);
    normal = PVector.sub(p2, p1).rotate(HALF_PI).normalize();
  }

  Intersection intersect(Ray ray) {
    PVector v1 = ray.origin;
    PVector v2 = PVector.add(ray.origin, ray.direction);
    PVector v3 = p1;
    PVector v4 = p2;
    float denom = (v4.y - v3.y) * (v2.x - v1.x) - (v4.x - v3.x) * (v2.y - v1.y);
    if (denom == 0) {
      return null;
    }
    float ua = ((v4.x - v3.x) * (v1.y - v3.y) - (v4.y - v3.y) * (v1.x - v3.x)) / denom;
    float ub = ((v2.x - v1.x) * (v1.y - v3.y) - (v2.y - v1.y) * (v1.x - v3.x)) / denom;
    if (ua < 0 || ub < 0 || ub > 1) {
      return null;
    }
    return new Intersection(ray, PVector.lerp(p1, p2, ub), normal, ub);
  }

  void show(Material material) {
    ColorType colorType = material.colorType;
    strokeWeight(2);
    if(material instanceof DoubleMaterial) {
      stroke(255, 50);
      line(p1.x, p1.y, p2.x, p2.y);
      return;
    }
    if (colorType instanceof SolidColor) {
      SolidColor c = (SolidColor) colorType;
      stroke(toColor(c.col));
      line(p1.x, p1.y, p2.x, p2.y);
    } else if (colorType instanceof GradientColor) {
      GradientColor c = (GradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        PVector m1 = PVector.lerp(p1, p2, i);
        PVector m2 = PVector.lerp(p1, p2, i + step);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    } else if (colorType instanceof HueGradientColor) {
      HueGradientColor c = (HueGradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        PVector m1 = PVector.lerp(p1, p2, i);
        PVector m2 = PVector.lerp(p1, p2, i + step);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    } else if (colorType instanceof SplitColor) {
      SplitColor c = (SplitColor) colorType;
      for (int i = 0; i < c.colors.length; i++) {
        float before = i == 0 ? 0 : c.thresholds[i - 1];
        float after = i == c.thresholds.length ? 1 : c.thresholds[i];
        stroke(toColor(c.colors[i]));
        PVector m1 = PVector.lerp(p1, p2, before);
        PVector m2 = PVector.lerp(p1, p2, after);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    }
  }

  void matShow(Material material) {
    if (material instanceof DoubleMaterial) {
      DoubleMaterial mat = (DoubleMaterial) material;
      color s1 = 0;
      color s2 = 0;
      if (mat.material1 instanceof LightMaterial) {
        s1 = #FFFFA7;
      } else if (mat.material1 instanceof GlassMaterial) {
        s1 = #B9021D;
      }
      if (mat.material2 instanceof LightMaterial) {
        s2 = #FFFFA7;
      } else if (mat.material2 instanceof GlassMaterial) {
        s2 = #B9021D;
      }
      doubleLine(p1.x, p1.y, p2.x, p2.y, 6, s1, s2);
    } else {
      strokeWeight(6);
      if (material instanceof LightMaterial) {
        stroke(#FFFFA7);
      } else if (material instanceof GlassMaterial) {
        stroke(#B9021D);
      }
      line(p1.x, p1.y, p2.x, p2.y);
    }
    show(material);
  }

  String getExportString() {
    String exportString = "line ";
    exportString += p1.x + " ";
    exportString += p1.y + " ";
    exportString += p2.x + " ";
    exportString += p2.y + " ";
    return exportString;
  }
}

class Circle extends Shape {
  PVector center;
  float radius;
  Circle(PVector c, float r) {
    center = c;
    radius = r;
  }

  Circle(float x, float y, float r) {
    center = new PVector(x, y);
    radius = r;
  }

  Intersection intersect(Ray ray) {
    PVector originToCenter = PVector.sub(center, ray.origin);
    float dotProduct = originToCenter.dot(ray.direction);
    PVector projected = PVector.mult(ray.direction, dotProduct);
    PVector projectedToCenter = PVector.sub(originToCenter, projected);
    float distance = projectedToCenter.mag();
    PVector hitPos;
    if (distance > radius) {
      return null;
    } else {
      float m = sqrt(radius * radius - distance * distance);
      float len1 = projected.mag() * sign(projected.dot(ray.direction)) - m;
      float len2 = projected.mag() * sign(projected.dot(ray.direction)) + m;
      PVector hit1 = PVector.add(ray.origin, PVector.mult(ray.direction, len1));
      PVector hit2 = PVector.add(ray.origin, PVector.mult(ray.direction, len2));
      float d1 = PVector.dist(ray.origin, hit1);
      float d2 = PVector.dist(ray.origin, hit2);
      if (d1 < d2 && len1 > 0) {
        hitPos = hit1;
      } else if (len2 > 0) {
        hitPos = hit2;
      } else {
        return null;
      }
    }
    if (PVector.sub(hitPos, ray.origin).dot(ray.direction) < 0) {
      return null;
    }
    PVector atOrigin = PVector.sub(hitPos, center);
    float t = (atOrigin.heading() / TWO_PI + 1) % 1;
    PVector normal = atOrigin.copy().normalize();
    return new Intersection(ray, hitPos, normal, t);
  }

  void show(Material material) {
    ColorType colorType = material.colorType;
    strokeWeight(2);
    noFill();
    if(material instanceof DoubleMaterial) {
      stroke(255, 50);
      ellipse(center.x, center.y, radius * 2, radius * 2);
      return;
    }
    if (colorType instanceof SolidColor) {
      SolidColor c = (SolidColor) colorType;
      stroke(toColor(c.col));
      ellipse(center.x, center.y, radius * 2, radius * 2);
    } else if (colorType instanceof HueGradientColor) {
      HueGradientColor c = (HueGradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        float a1 = i * TWO_PI;
        float a2 = (i + step) * TWO_PI;
        arc(center.x, center.y, radius * 2, radius * 2, a1, a2);
      }
    } else if (colorType instanceof SplitColor) {
      SplitColor c = (SplitColor) colorType;
      for (int i = 0; i < c.colors.length; i++) {
        float before = (i == 0 ? 0 : c.thresholds[i - 1]) + c.offset;
        float after = (i == c.thresholds.length ? 1 : c.thresholds[i]) + c.offset;
        stroke(toColor(c.colors[i]));
        float a1 = TWO_PI * before;
        float a2 = TWO_PI * after;
        arc(center.x, center.y, radius * 2, radius * 2, a1, a2);
      }
    }
  }

  void matShow(Material material) {
    noFill();
    if (material instanceof DoubleMaterial) {
      DoubleMaterial mat = (DoubleMaterial) material;
      color s1 = 0;
      color s2 = 0;
      if (mat.material1 instanceof LightMaterial) {
        s1 = #FFFFA7;
      } else if (mat.material1 instanceof GlassMaterial) {
        s1 = #B9021D;
      }
      if (mat.material2 instanceof LightMaterial) {
        s2 = #FFFFA7;
      } else if (mat.material2 instanceof GlassMaterial) {
        s2 = #B9021D;
      }
      doubleArc(center.x, center.y, radius * 2, radius * 2, 0, TWO_PI, 6, s1, s2);
    } else {
      strokeWeight(6);
      if (material instanceof LightMaterial) {
        stroke(#FFFFA7);
      } else if (material instanceof GlassMaterial) {
        stroke(#B9021D);
      }
      ellipse(center.x, center.y, radius * 2, radius * 2);
    }
    show(material);
  }

  String getExportString() {
    String exportString = "circle ";
    exportString += center.x + " ";
    exportString += center.y + " ";
    exportString += radius + " ";
    return exportString;
  }
}

class Arc extends Shape {
  PVector center;
  float radius;
  float angle1;
  float angle2;
  Arc(PVector c, float r, float a1, float a2) {
    center = c;
    radius = r;
    angle1 = (a1 + TWO_PI) % TWO_PI;
    angle2 = (a2 + TWO_PI) % TWO_PI;
  }

  Arc(float x, float y, float r, float a1, float a2) {
    center = new PVector(x, y);
    radius = r;
    angle1 = (a1 + TWO_PI) % TWO_PI;
    angle2 = (a2 + TWO_PI) % TWO_PI;
  }

  boolean angleHits(float angle) {
    if (angle2 > angle1) {
      return angle >= angle1 && angle <= angle2;
    } else {
      return angle >= angle1 || angle <= angle2;
    }
  }

  Intersection intersect(Ray ray) {
    PVector originToCenter = PVector.sub(center, ray.origin);
    float dotProduct = originToCenter.dot(ray.direction);
    PVector projected = PVector.mult(ray.direction, dotProduct);
    PVector projectedToCenter = PVector.sub(originToCenter, projected);
    float distance = projectedToCenter.mag();
    PVector hitPos;
    if (distance > radius) {
      return null;
    } else {
      float m = sqrt(radius * radius - distance * distance);
      float len1 = projected.mag() * sign(projected.dot(ray.direction)) - m;
      float len2 = projected.mag() * sign(projected.dot(ray.direction)) + m;
      PVector hit1 = PVector.add(ray.origin, PVector.mult(ray.direction, len1));
      PVector hit2 = PVector.add(ray.origin, PVector.mult(ray.direction, len2));
      float d1 = PVector.dist(ray.origin, hit1);
      float d2 = PVector.dist(ray.origin, hit2);
      float a1 = (PVector.sub(hit1, center).heading() + TWO_PI) % TWO_PI;
      float a2 = (PVector.sub(hit2, center).heading() + TWO_PI) % TWO_PI;
      if (d1 < d2 && len1 > 0 && angleHits(a1)) {
        hitPos = hit1;
      } else if (len2 > 0 && angleHits(a2)) {
        hitPos = hit2;
      } else {
        return null;
      }
    }
    if (PVector.sub(hitPos, ray.origin).dot(ray.direction) < 0) {
      return null;
    }
    PVector atOrigin = PVector.sub(hitPos, center);
    PVector normal = atOrigin.copy().normalize();
    float a = (atOrigin.heading() + TWO_PI) % TWO_PI;
    float t;
    if (angle1 < angle2) {
      t = map(a, angle1, angle2, 0, 1);
    } else {
      if (a  >= angle1) {
        t = map(a, angle1, angle2 + TWO_PI, 0, 1);
      } else {
        t = map(a, angle1 - TWO_PI, angle2, 0, 1);
      }
    }
    return new Intersection(ray, hitPos, normal, t);
  }

  void show(Material material) {
    ColorType colorType = material.colorType;
    float correctAngle2 = angle1 < angle2 ? angle2 : angle2 + TWO_PI;
    strokeWeight(2);
    noFill();
    if(material instanceof DoubleMaterial) {
      stroke(255, 50);
      arc(center.x, center.y, radius * 2, radius * 2, angle1, correctAngle2);
      return;
    }
    if (colorType instanceof SolidColor) {
      SolidColor c = (SolidColor) colorType;
      stroke(toColor(c.col));
      arc(center.x, center.y, radius * 2, radius * 2, angle1, correctAngle2);
    } else if (colorType instanceof GradientColor) {
      GradientColor c = (GradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        float a1 = lerp(angle1, correctAngle2, i);
        float a2 = lerp(angle1, correctAngle2, i + step);
        arc(center.x, center.y, radius * 2, radius * 2, a1, a2);
      }
    } else if (colorType instanceof HueGradientColor) {
      HueGradientColor c = (HueGradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        float a1 = lerp(angle1, correctAngle2, i);
        float a2 = lerp(angle1, correctAngle2, i + step);
        arc(center.x, center.y, radius * 2, radius * 2, a1, a2);
      }
    } else if (colorType instanceof SplitColor) {
      SplitColor c = (SplitColor) colorType;
      for (int i = 0; i < c.colors.length; i++) {
        float before = (i == 0 ? 0 : c.thresholds[i - 1]) + c.offset;
        float after = (i == c.thresholds.length ? 1 : c.thresholds[i]) + c.offset;
        stroke(toColor(c.colors[i]));
        float a1 = lerp(angle1, correctAngle2, before);
        float a2 = lerp(angle1, correctAngle2, after);
        arc(center.x, center.y, radius * 2, radius * 2, a1, a2);
      }
    }
  }

  void matShow(Material material) {
    noFill();
    float correctAngle2 = angle1 < angle2 ? angle2 : angle2 + TWO_PI;
    if (material instanceof DoubleMaterial) {
      DoubleMaterial mat = (DoubleMaterial) material;
      color s1 = 0;
      color s2 = 0;
      if (mat.material1 instanceof LightMaterial) {
        s1 = #FFFFA7;
      } else if (mat.material1 instanceof GlassMaterial) {
        s1 = #B9021D;
      }
      if (mat.material2 instanceof LightMaterial) {
        s2 = #FFFFA7;
      } else if (mat.material2 instanceof GlassMaterial) {
        s2 = #B9021D;
      }
      doubleArc(center.x, center.y, radius * 2, radius * 2, angle1, correctAngle2, 6, s1, s2);
    } else {
      strokeWeight(6);
      if (material instanceof LightMaterial) {
        stroke(#FFFFA7);
      } else if (material instanceof GlassMaterial) {
        stroke(#B9021D);
      }
      arc(center.x, center.y, radius * 2, radius * 2, angle1, correctAngle2);
    }
    show(material);
  }

  String getExportString() {
    String exportString = "arc ";
    exportString += center.x + " ";
    exportString += center.y + " ";
    exportString += radius + " ";
    exportString += angle1 + " ";
    exportString += angle2 + " ";
    return exportString;
  }
}

class Bezier extends Shape {
  PVector p1;
  PVector p2;
  PVector p3;
  PVector p4;
  Bezier(PVector p1, PVector p2, PVector p3, PVector p4) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
    this.p4 = p4;
  }

  Bezier(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    p1 = new PVector(x1, y1);
    p2 = new PVector(x2, y2);
    p3 = new PVector(x3, y3);
    p4 = new PVector(x4, y4);
  }

  Intersection intersect(Ray ray) {
    float A = -ray.direction.y;
    float B = ray.direction.x;
    float C = ray.origin.x * ray.direction.y - ray.origin.y * ray.direction.x;

    float[] bx = {
      -p1.x + 3 * p2.x - 3 * p3.x + p4.x,
      3 * p1.x - 6 * p2.x + 3 * p3.x,
      -3 * p1.x + 3 * p2.x,
      p1.x
    };

    float[] by = {
      -p1.y + 3 * p2.y - 3 * p3.y + p4.y,
      3 * p1.y - 6 * p2.y + 3 * p3.y,
      -3 * p1.y + 3 * p2.y,
      p1.y
    };

    float[] coeffs = {
      A * bx[0] + B * by[0],
      A * bx[1] + B * by[1],
      A * bx[2] + B * by[2],
      A * bx[3] + B * by[3] + C,
    };

    ArrayList<Float> tValues = solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3]);
    ArrayList<Intersection> intersections = (ArrayList<Intersection>) tValues.stream().map(t -> new Intersection(ray, pointAt(t), normalAt(t), t)).collect(Collectors.toList());
    intersections.removeIf(inter -> {
      PVector v = PVector.sub(inter.position, ray.origin);
      return v.dot(ray.direction) < 0;
    }
    );
    if (intersections.size() == 0) return null;

    intersections.sort((a, b) -> (int) (PVector.dist(a.position, ray.origin) - PVector.dist(b.position, ray.origin)));
    return intersections.get(0);
  }

  private ArrayList<Float> solveCubic(float a, float b, float c, float d) {
    if (a == 0) {
      return solveQuadratic(b, c, d);
    }

    b /= a;
    c /= a;
    d /= a;

    var q = (3 * c - b * b) / 9;
    var r = (9 * b * c - 27 * d - 2 * b * b * b) / 54;
    var discriminant = q * q * q + r * r;
    ArrayList<Float> roots = new ArrayList<Float>();

    if (discriminant > 0) {
      float sqrtDiscriminant = sqrt(discriminant);
      float s = (float) Math.cbrt(r + sqrtDiscriminant);
      float t = (float) Math.cbrt(r - sqrtDiscriminant);
      roots.add(-b / 3 + (s + t));
    } else if (discriminant == 0) {
      float s = (float) Math.cbrt(r);
      roots.add(-b / 3 + 2 * s);
      roots.add(-b / 3 - s);
    } else {
      float theta = acos(r / sqrt(-q * q * q));
      float sqrtQ = sqrt(-q);
      roots.add(2 * sqrtQ * cos(theta / 3) - b / 3);
      roots.add(2 * sqrtQ * cos((theta + 2 * PI) / 3) - b / 3);
      roots.add(2 * sqrtQ * cos((theta + 4 * PI) / 3) - b / 3);
    }
    roots.removeIf(root -> root < 0 || root > 1);
    return roots;
  }

  private ArrayList<Float> solveQuadratic(float a, float b, float c) {
    ArrayList<Float> roots = new ArrayList<Float>();
    if (a == 0) {
      if (b == 0) {
        return roots;
      }
      roots.add(-c / b);
      return roots;
    }

    float discriminant = b * b - 4 * a * c;
    if (discriminant < 0) {
      return roots;
    } else if (discriminant == 0) {
      roots.add(-b / (2 * a));
      return roots;
    } else {
      float sqrtDiscriminant = sqrt(discriminant);
      roots.add((-b + sqrtDiscriminant) / (2 * a));
      roots.add((-b - sqrtDiscriminant) / (2 * a));
      return roots;
    }
  }

  PVector pointAt(float t) {
    float x = pow(1 - t, 3) * p1.x + 3 * pow(1 - t, 2) * t * p2.x + 3 * (1 - t) * t * t * p3.x + t * t * t * p4.x;
    float y = pow(1 - t, 3) * p1.y + 3 * pow(1 - t, 2) * t * p2.y + 3 * (1 - t) * t * t * p3.y + t * t * t * p4.y;
    return new PVector(x, y);
  }

  PVector normalAt(float t) {
    float dx = 3 * pow(1 - t, 2) * (p2.x - p1.x) + 6 * (1 - t) * t * (p3.x - p2.x) + 3 * t * t * (p4.x - p3.x);
    float dy = 3 * pow(1 - t, 2) * (p2.y - p1.y) + 6 * (1 - t) * t * (p3.y - p2.y) + 3 * t * t * (p4.y - p3.y);
    return new PVector(dy, -dx).normalize();
  }

  void show(Material material) {
    ColorType colorType = material.colorType;
    strokeWeight(2);
    if(material instanceof DoubleMaterial) {
      stroke(255, 50);
      bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
      return;
    }
    if (colorType instanceof SolidColor) {
      SolidColor c = (SolidColor) colorType;
      stroke(toColor(c.col));
      bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
    } else if (colorType instanceof GradientColor) {
      GradientColor c = (GradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        PVector m1 = pointAt(i);
        PVector m2 = pointAt(i + step);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    } else if (colorType instanceof HueGradientColor) {
      HueGradientColor c = (HueGradientColor) colorType;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        stroke(toColor(c.getColor(i + step / 2)));
        PVector m1 = pointAt(i);
        PVector m2 = pointAt(i + step);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    } else if (colorType instanceof SplitColor) {
      SplitColor c = (SplitColor) colorType;
      int curIdx = 0;
      float step = 1 / (float) gradientDetail;
      for (float i = 0; i < 1 - step; i += step) {
        float t0 = i;
        float t1 = i + step;
        if (curIdx < c.thresholds.length) {
          float curThresh = c.thresholds[curIdx];
          PVector m1 = pointAt(t0);
          PVector m2 = pointAt(t1);
          if (curThresh > t0 && curThresh < t1) {
            PVector mid = pointAt(curThresh);
            stroke(toColor(c.colors[curIdx]));
            line(m1.x, m1.y, mid.x, mid.y);
            stroke(toColor(c.colors[curIdx + 1]));
            line(mid.x, mid.y, m2.x, m2.y);
            curIdx++;
          } else {
            stroke(toColor(c.colors[curIdx]));
            line(m1.x, m1.y, m2.x, m2.y);
          }
        }
        stroke(toColor(c.getColor(i + step / 2)));
        PVector m1 = pointAt(i);
        PVector m2 = pointAt(i + step);
        line(m1.x, m1.y, m2.x, m2.y);
      }
    }
  }

  void matShow(Material material) {
    noFill();
    if (material instanceof DoubleMaterial) {
      DoubleMaterial mat = (DoubleMaterial) material;
      color s1 = 0;
      color s2 = 0;
      if (mat.material1 instanceof LightMaterial) {
        s1 = #FFFFA7;
      } else if (mat.material1 instanceof GlassMaterial) {
        s1 = #B9021D;
      }
      if (mat.material2 instanceof LightMaterial) {
        s2 = #FFFFA7;
      } else if (mat.material2 instanceof GlassMaterial) {
        s2 = #B9021D;
      }
      doubleBezier(p1, p2, p3, p4, 6, s1, s2);
    } else {
      strokeWeight(6);
      if (material instanceof LightMaterial) {
        stroke(#FFFFA7);
      } else if (material instanceof GlassMaterial) {
        stroke(#B9021D);
      }
      bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
    }
    show(material);
  }

  String getExportString() {
    String exportString = "bezier ";
    exportString += p1.x + " ";
    exportString += p1.y + " ";
    exportString += p2.x + " ";
    exportString += p2.y + " ";
    exportString += p3.x + " ";
    exportString += p3.y + " ";
    exportString += p4.x + " ";
    exportString += p4.y + " ";
    return exportString;
  }
}
