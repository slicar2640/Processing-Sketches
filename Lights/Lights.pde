import java.time.LocalDateTime; //<>// //<>//
import java.time.temporal.ChronoField;
import java.io.FileReader;
import java.util.Arrays;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Collectors;

ArrayList<EnvironmentObject> environment;
int samples = 360;
int rowsPerFrame = 10;
int currentRow = 0;
int gradientDetail = 40;
int numObjects = 3;

String folderName;
String[] frames;
int curFrame = 0;
int numFrames;
boolean loadFromFile = false;

boolean done = false;
boolean toSave = false;

void setup() {
  size(600, 600);
  if (loadFromFile == true) {
    String[] input = loadStrings("loadStrings.txt");
    folderName = input[0];
    frames = Arrays.copyOfRange(input, 1, input.length);
    numFrames = frames.length;
    try {
      Files.createDirectories(Paths.get("Lights/anims/" + folderName));
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    environment = loadEnvironment(frames[0]);
  } else {
    environment = randomEnvironment(numObjects);
  }
  //String loadString = "circle 391.39978 468.17554 39.96383 light solid 222.9214 134.21037 127.46003 129.6945 117.4337 194.77109 0.5153372 ;arc 430.34088 213.95967 79.417786 1.2235894 4.297378 light solid 32.896885 223.46089 9.570714 59.221844 78.41484 38.940052 ;line 139.96024 125.38944 204.29338 415.3972 glass solid 51.519157 84.81209 57.60713 ;line 442.38324 459.63315 464.525 240.42323 glass solid 130.4614 80.739265 142.10487 49.58143 70.04786 49.004177";
  //environment = loadEnvironment(loadString);
  for (EnvironmentObject obj : environment) {
    obj.matShow();
    obj.show();
  }
  
  //println(environmentExportString());
}

void draw() {
  if (done == false) {
    loadPixels();
    for (int y = currentRow; y < min(currentRow + rowsPerFrame, height); y++) {
      for (int x = 0; x < width; x++) {
        PVector col = new PVector(0, 0, 0);
        for (int i = 0; i < samples; i++) {
          PVector traced = trace(new PVector(x, y), (float) i / samples * TWO_PI);
          col.add(traced);
        }
        col.div(samples);
        pixels[x + y * width] = toColor(col);
      }
    }
    updatePixels();
    currentRow += rowsPerFrame;

    //background(0);
    //float angle = radians(180);
    //float num = 60;
    //for(int i = 0; i < num; i++) {
    //  //trace(new PVector(0, (i - num / 2) * 10).rotate(angle).add(mouseX, mouseY), angle);
    //  trace(new PVector(mouseX, mouseY), (float)i / num * TWO_PI);
    //}
  }

  if (currentRow >= height) {
    done = true;
    noLoop();
    for (EnvironmentObject obj : environment) {
      obj.show();
    }
    if (loadFromFile == true) {
      save("anims/" + folderName + "/frame_" + curFrame + ".png");
      println("Saved Frame " + curFrame);
      if (curFrame < numFrames - 1) {
        done = false;
        loop();
        currentRow = 0;
        curFrame++;
        environment = loadEnvironment(frames[curFrame]);
        background(200);
      } else {
        println("Done!");
        exit();
      }
    } else if (toSave == true) {
      println("Saved");
      toSave = false;
      LocalDateTime now = LocalDateTime.now();
      String timestamp = year() + "-" + now.get(ChronoField.MONTH_OF_YEAR) + "-" + now.get(ChronoField.DAY_OF_MONTH) + " " + zeroFormat(now.get(ChronoField.CLOCK_HOUR_OF_DAY)) + ":" + zeroFormat(now.get(ChronoField.MINUTE_OF_HOUR)) + ":" + zeroFormat(now.get(ChronoField.SECOND_OF_MINUTE));
      save("images/lights (" + timestamp + ").png");
    }
  }
}

void keyPressed() {
  if (key == 'S') {
    println("Image will save after rendering finishes");
    toSave = true;
  } else if (key == 'E') {
    println(environmentExportString());
  }
}

PVector trace(PVector pos, float a) {
  //stroke(255);
  //strokeWeight(8);
  //point(pos.x, pos.y);
  //stroke(0, 255, 0);
  //strokeWeight(2);
  //line(pos.x, pos.y, pos.x + 20 * cos(a), pos.y + 20 * sin(a));
  Ray ray = new Ray(pos, PVector.fromAngle(a));
  PVector col = intersectEnvironment(ray);
  return col.copy();
}

PVector intersectEnvironment(Ray ray) {
  float minDist = 10000;
  PVector col = new PVector(0, 0, 0);
  for (EnvironmentObject obj : environment) {
    Intersection intersection = obj.intersect(ray);
    if (intersection == null) continue;
    float d = PVector.dist(ray.origin, intersection.position);
    if (d < minDist) {
      minDist = d;
      col = obj.getColor(intersection);
    }
  }
  return col;
}

PVector randomColor() {
  return new PVector(random(255), random(255), random(255));
}

float sign(float x) {
  return x < 0 ? -1 : x == 0 ? 0 : 1;
}

color toColor(PVector v) {
  return color(v.x, v.y, v.z);
}

String zeroFormat(int x) {
  return (x < 10 ? "0" : "") + x;
}

void doubleLine(float x1, float y1, float x2, float y2, float weight, color s1, color s2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float q = sqrt(dx * dx + dy * dy);
  float nX = dy / q;
  float nY = -dx / q;
  strokeWeight(weight / 2);
  stroke(s1);
  line(x1 - nX * weight / 4, y1 - nY * weight / 4, x2 - nX * weight / 4, y2 - nY * weight / 4);
  stroke(s2);
  line(x1 - nX * weight / 4, y1 + nY * weight / 4, x2 + nX * weight / 4, y2 + nY * weight / 4);
}

void doubleArc(float x, float y, float w, float h, float a1, float a2, float weight, color s1, color s2) {
  strokeWeight(weight / 2);
  stroke(s1);
  arc(x, y, w + weight / 4, h + weight / 4, a1, a2);
  stroke(s2);
  arc(x, y, w - weight / 4, h - weight / 4, a1, a2);
}

void doubleBezier(PVector p1, PVector p2, PVector p3, PVector p4, float weight, color s1, color s2) {
  float lastX = p1.x;
  float lastY = p1.y;
  println(weight, s1, s2);
  for(float i = 0; i <= gradientDetail; ++i) {
    float t = i / gradientDetail;
    float x = pow(1 - t, 3) * p1.x + 3 * pow(1 - t, 2) * t * p2.x + 3 * (1 - t) * t * t * p3.x + t * t * t * p4.x;
    float y = pow(1 - t, 3) * p1.y + 3 * pow(1 - t, 2) * t * p2.y + 3 * (1 - t) * t * t * p3.y + t * t * t * p4.y;
    doubleLine(lastX, lastY, x, y, weight, s2, s1);
    lastX = x;
    lastY = y;
  }
}
