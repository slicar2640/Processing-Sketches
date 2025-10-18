abstract class ColorType {
  abstract PVector getColor(float t);
  abstract String getExportString();
}

class SolidColor extends ColorType {
  PVector col;
  SolidColor(PVector c) {
    col = c;
  }

  PVector getColor(float t) {
    return col;
  }

  String getExportString() {
    String exportString = "solid ";
    exportString += col.x +  " ";
    exportString += col.y +  " ";
    exportString += col.z +  " ";
    return exportString;
  }
}

class GradientColor extends ColorType {
  PVector color1, color2;
  GradientColor(PVector c1, PVector c2) {
    color1 = c1;
    color2 = c2;
  }

  PVector getColor(float t) {
    return PVector.lerp(color1, color2, t);
  }

  String getExportString() {
    String exportString = "gradient ";
    exportString += color1.x +  " ";
    exportString += color1.y +  " ";
    exportString += color1.z +  " ";
    exportString += color2.x +  " ";
    exportString += color2.y +  " ";
    exportString += color2.z +  " ";
    return exportString;
  }
}

class HueGradientColor extends ColorType {
  float offset; //0 - 360
  float brightness; //0 - 100
  HueGradientColor(float o, float b) {
    offset = o;
    brightness = b;
  }

  PVector getColor(float t) {
    //HSL
    float hue = (t * 360 + offset) % 360;
    float c = (1 - abs(2 * brightness / 100 - 1));
    float x = c * (1 - abs((hue / 60) % 2 - 1));
    float m = brightness / 100 - c / 2;
    float r, g, b;
    r = hue < 60 ? c : hue < 120 ? x : hue < 180 ? 0 : hue < 240 ? 0 : hue < 300 ? x : c;
    g = hue < 60 ? x : hue < 120 ? c : hue < 180 ? c : hue < 240 ? x : hue < 300 ? 0 : 0;
    b = hue < 60 ? 0 : hue < 120 ? 0 : hue < 180 ? x : hue < 240 ? c : hue < 300 ? c : x;
    return new PVector((r + m) * 255, (g + m) * 255, (b + m) * 255);
  }

  String getExportString() {
    String exportString = "hue-gradient ";
    exportString += offset +  " ";
    exportString += brightness +  " ";
    return exportString;
  }
}

class SplitColor extends ColorType {
  PVector[] colors;
  float[] thresholds;
  float offset = 0;
  SplitColor(PVector[] c, float[] t) {
    colors = c;
    thresholds = t;
  }

  SplitColor(PVector[] c, float[] t, float o) {
    colors = c;
    thresholds = t;
    offset = o;
  }

  PVector getColor(float t) {
    for (int i = 0; i < thresholds.length; i++) {
      if ((t - offset + 1) % 1 < thresholds[i]) {
        return colors[i];
      }
    }
    return colors[colors.length - 1];
  }

  String getExportString() {
    String exportString = "split ";
    for (PVector col : colors) {
      exportString += col.x +  " ";
      exportString += col.y +  " ";
      exportString += col.z +  " ";
    }
    for(float t : thresholds) {
      exportString += t + " ";
    }
    return exportString;
  }
}
