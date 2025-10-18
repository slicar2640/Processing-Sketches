import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.util.Arrays;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.HashSet;
import java.io.EOFException;

Path outlineFile, indicesFile, outputFile, prefsFile;
String folderPath, puzzleName;
PImage outlineImage, outputImage;

ArrayList<HashSet<Integer>> indicesArr;
HashSet<Integer> filledIndices = new HashSet<>();
HashSet<Integer> dragIndices = new HashSet<>();

int autosaveInterval = 30000;  // 30 seconds
int lastAutosaveTime = 0;

UndoManager undoManager;

boolean isCtrlPressed = false;
boolean isShiftPressed = false;

boolean menuOpen = false;
Toggle dragOnlyOn;

void setup() {
  size(100, 100);
  String userHome = System.getProperty("user.home");
  String pathString = userHome + "/sketchbook/Puzzle_Fill/data";
  Path path = Paths.get(pathString);
  selectFolder("Select a puzzle:", "folderSelected", path.toFile());
  undoManager = new UndoManager();
  registerMethod("dispose", this);
}

void draw() {
  background(0);
  if (outputImage != null) {
    image(outputImage, 0, 0);
  }

  if (millis() - lastAutosaveTime > autosaveInterval) {
    saveEverything();
    lastAutosaveTime = millis();
  }

  if (!menuOpen && mousePressed && mouseButton == RIGHT) {
    int mx = constrain(mouseX, 0, width-1);
    int my = constrain(mouseY, 0, height-1);
    int idx = mx + my * width;
    int pieceID = getIndex(idx);
    dragIndices.add(pieceID);
    if (pieceID >= 0) {
      for (int i : indicesArr.get(pieceID)) {
        outputImage.pixels[i] = #FFFF00;
      }
      outputImage.updatePixels();
    }
  }

  if (menuOpen) {
    fill(0xbb000000);
    noStroke();
    rect(0, 0, width, height);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(30);
    text(puzzleName, 10, 10);
    dragOnlyOn.show();
  }
}

void mousePressed() {
  if (menuOpen) {
    if (dragOnlyOn.isClicked(mouseX, mouseY)) dragOnlyOn.toggle();
  } else {
    int mx = constrain(mouseX, 0, width-1);
    int my = constrain(mouseY, 0, height-1);
    int idx = mx + my * width;
    int pieceID = getIndex(idx);
    if (pieceID < 0) return;
    dragIndices.add(pieceID);
  }
}

void mouseReleased() {
  if (!menuOpen) {
    if (dragOnlyOn.state == false) {
      if (dragIndices.size() > 0) {
        undoManager.flipAction(dragIndices);
      }
    } else {
      undoManager.setAction(dragIndices, !isShiftPressed);
    }
    dragIndices.clear();
  }
}

int getIndex(int pix) {
  for (int i = 0; i < indicesArr.size(); i++) {
    if (indicesArr.get(i).contains(pix)) return i;
  }
  return -1;
}

void keyPressed() {
  if (keyCode == CONTROL && isCtrlPressed == false) isCtrlPressed = true;
  if (keyCode == SHIFT && isShiftPressed == false) isShiftPressed = true;
  if (char(keyCode) == 'Z' && isCtrlPressed == true && !menuOpen) {
    if (isShiftPressed == true) {
      undoManager.redo();
    } else {
      undoManager.undo();
    }
  }
  if (key == 'm') menuOpen = !menuOpen;
}
void keyReleased() {
  if (keyCode == CONTROL) isCtrlPressed = false;
  if (keyCode == SHIFT) isShiftPressed = false;
}
