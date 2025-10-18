class WorldManager {
  int worldWidth, worldHeight;
  HashMap<Integer, Block> blocks = new HashMap<>();
  ArrayList<Composite> composites = new ArrayList<>();
  HashMap<Integer, HashMap<Integer, PushInteraction>> defaultInteractions = new HashMap<>();
  HashMap<Integer, Integer> idColors = new HashMap<>();
  WallType wallType;
  WorldManager(int w, int h, WallType wallType) {
    this.worldWidth = w;
    this.worldHeight = h;
    this.wallType = wallType;
  }
  
  Block getBlockAtXY(int x, int y) {
    int index = x + y * worldWidth;
    return blocks.get(index);
  }
  
  Movable getItemAtXY(int x, int y) {
    int index = x + y * worldWidth;
    if(blocks.containsKey(index)) {
      return blocks.get(index);
    } else {
      for(Composite composite : composites) {
        if(composite.containsGlobalXY(x, y)) {
          return composite;
        }
      }
    }
    return null;
  }
  
  void removeBlock(Block block) {
    int index = block.x + block.y * worldWidth;
    blocks.remove(index);
  }
  
  void addBlock(Block block) {
    int index = block.x + block.y * worldWidth;
    blocks.put(index, block);
  }
  
  Block addBlock(int x, int y, int id) {
    HashMap<Integer, PushInteraction> interactions = defaultInteractions.get(id);
    Block block = new Block(x, y, id, interactions, this);
    int index = block.x + block.y * worldWidth;
    blocks.put(index, block);
    return block;
  }
  
  void addComposite(Composite composite) {
    composites.add(composite);
  }
  
  void removeComposite(Composite composite) {
    composites.remove(composite);
  }
  
  void addId(int id, int col, HashMap<Integer, PushInteraction> interactions) {
    idColors.put(id, col);
    defaultInteractions.put(id, interactions);
  }
  
  void addId(int id, int col) {
    idColors.put(id, col);
    defaultInteractions.put(id, new HashMap<>());
  }
  
  void setInteraction(int id1, int id2, PushInteraction interaction) {
    defaultInteractions.get(id1).put(id2, interaction);
    defaultInteractions.get(id2).put(id1, interaction);
  }
  
  void showPix() {
    background(0);
    loadPixels();
    for(Block b : blocks.values()) {
      int index = b.x + b.y * worldWidth;
      pixels[index] = idColors.get(b.id);
    }
    for(Composite c : composites) {
      c.showPix();
    }
    updatePixels();
  }
  
  void showRect() {
    background(0);
    noStroke();
    for(Block b : blocks.values()) {
      fill(idColors.get(b.id));
      float scl = (float)width / worldWidth;
      rect(b.x * scl, b.y * scl, scl, scl);
    }
    for(Composite c : composites) {
      c.showRect();
    }
  }
}

enum WallType {
  STOP,
  WRAP,
  DELETE
}
