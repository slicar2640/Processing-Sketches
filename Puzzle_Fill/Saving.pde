  void dispose() {
  if (puzzleName != null) {
    println("Disposing: saving everything");
    saveEverything();
  }
}

void saveEverything() {
  try {
    if (filledIndices != null) {
      ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(folderPath + "/filledIndices.dat"));
      out.writeObject(filledIndices);
      out.close();
    }
    if (outputImage != null) {
      outputImage.save("data/" + puzzleName + "/output.png");
    }
    if (dragOnlyOn != null) {
      HashMap<String, Boolean> prefs = new HashMap<>();
      prefs.put("dragOnlyOn", dragOnlyOn.state);
      
      ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(folderPath + "/prefs.dat"));
      out.writeObject(prefs);
      out.close();
    }
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}
