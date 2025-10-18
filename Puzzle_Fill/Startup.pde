final int[][] directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}};

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    exit();
  } else {
    setupFolder(selection);
  }
}

void setupFolder(File folder) {
  folderPath = folder.getAbsolutePath();
  puzzleName = folderPath.substring((System.getProperty("user.home") + "/sketchbook/Puzzle_Fill/data").length() + 1);
  outlineFile = Paths.get(folderPath + "/outline.png");
  if (Files.exists(outlineFile)) {
    outlineImage = loadImage(puzzleName + "/outline.png");
    outlineImage.loadPixels();
    windowResize(outlineImage.width, outlineImage.height);
  } else {
    println("no outline");
    exit();
  }
  indicesFile = Paths.get(folderPath + "/indices.dat");
  if (Files.exists(indicesFile)) {
    try {
      ObjectInputStream in = new ObjectInputStream(new FileInputStream(folderPath + "/indices.dat"));
      indicesArr = (ArrayList<HashSet<Integer>>)in.readObject();
      in.close();
    }
    catch (EOFException e) {
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    try {
      ObjectInputStream in = new ObjectInputStream(new FileInputStream(folderPath + "/filledIndices.dat"));
      filledIndices = (HashSet<Integer>)in.readObject();
      in.close();
    }
    catch (EOFException e) {
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  } else {
    createIndices();
  }
  outputFile = Paths.get(folderPath + "/output.png");
  if (Files.exists(outputFile)) {
    outputImage = loadImage(folderPath + "/output.png");
  } else {
    createOutputImage();
  }
  prefsFile = Paths.get(folderPath + "/prefs.dat");
  if (Files.exists(prefsFile)) {
    try {
      ObjectInputStream in = new ObjectInputStream(new FileInputStream(folderPath + "/prefs.dat"));
      HashMap<String, Boolean> prefs = (HashMap<String, Boolean>)in.readObject();
      setupToggles(prefs);
      in.close();
    }
    catch (EOFException e) {
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    try {
      ObjectInputStream in = new ObjectInputStream(new FileInputStream(folderPath + "/filledIndices.dat"));
      filledIndices = (HashSet<Integer>)in.readObject();
      in.close();
    }
    catch (EOFException e) {
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  } else {
    setupToggles();
  }
}

void createIndices() {
  try {
    BufferedImage outlineBI = ImageIO.read(outlineFile.toFile());
    int[] outlinePix = new int[width * height];
    outlineBI.getRGB(0, 0, width, height, outlinePix, 0, width);
    indicesArr = new ArrayList<>();
    HashSet<Integer> checkedIndices = new HashSet<>();
    int counter = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int index = x + y * width;
        if (!checkedIndices.contains(index) && outlinePix[index] == 0xFFFFFFFF) {
          floodFill(outlinePix, indicesArr, checkedIndices, width, height, x, y, counter, -1);
          counter++;
        }
      }
    }
    ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(folderPath + "/indices.dat"));
    out.writeObject(indicesArr);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void floodFill(int[] outlines, ArrayList<HashSet<Integer>> indices, HashSet<Integer> checked, int w, int h, int x, int y, int val, int from) {
  checked.add(x + y * w);
  if (indices.size() <= val) indices.add(val, new HashSet<Integer>());
  indices.get(val).add(x + y * w);
  if (from == -1) {
    for (int i = 0; i < 4; i++) {
      int nx = x + directions[i][0];
      int ny = y + directions[i][1];
      if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
      if (!checked.contains(nx + ny * w) && outlines[nx + ny * w] == 0xFFFFFFFF) {
        floodFill(outlines, indices, checked, w, h, nx, ny, val, (i + 2) % 4);
      }
    }
  } else {
    for (int i = 1; i < 4; i++) {
      int dirIdx = (i + from) % 4;
      int nx = x + directions[dirIdx][0];
      int ny = y + directions[dirIdx][1];
      if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
      if (!checked.contains(nx + ny * w) && outlines[nx + ny * w] == 0xFFFFFFFF) {
        floodFill(outlines, indices, checked, w, h, nx, ny, val, (i + 2) % 4);
      }
    }
  }
}

void createOutputImage() {
  try {
    Files.copy(outlineFile, Paths.get(folderPath + "/output.png"));
    outputImage = loadImage(folderPath + "/output.png");
  }
  catch(IOException e) {
    System.err.println(e.getMessage());
  }
}

void setupToggles() {
  dragOnlyOn = new Toggle(20, 60, 20, "Drag turns all pieces on or [SHIFT] for all off", false);

  HashMap<String, Boolean> prefs = new HashMap<>();
  prefs.put("dragOnlyOn", false);
  try {
    ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(folderPath + "/prefs.dat"));
    out.writeObject(prefs);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

void setupToggles(HashMap<String, Boolean> prefs) {
  dragOnlyOn = new Toggle(20, 60, 20, "Drag turns all pieces on or [SHIFT] for all off", prefs.get("dragOnlyOn"));
}
