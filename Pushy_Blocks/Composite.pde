class Composite extends Movable {
  int boundingWidth, boundingHeight;
  HashMap<Integer, Block> blocks = new HashMap<>();
  
  Composite(int x, int y, int w, int h, int[][] ids, WorldManager manager) {
    this.x = x;
    this.y = y;
    this.boundingWidth = w;
    this.boundingHeight = h;
    this.manager = manager;
    for(int i = 0; i < ids.length; i++) {
      for(int j = 0; j < ids.length; j++) {
        int index = i + j * boundingWidth;
        int id = ids[i][j];
        if(id == 0) continue;
        Block b = new Block(i + x, j + y, id, manager.defaultInteractions.get(id), this);
        blocks.put(index, b);
      }
    }
  }
  
  boolean containsLocalXY(int px, int py) {
    if(px < 0 || py < 0 || px >= boundingWidth || py >= boundingHeight) return false;
    int index = px + py * boundingWidth;
    return blocks.containsKey(index);
  }
  
  boolean containsGlobalXY(int px, int py) {
    if(px < x || py < y || px >= x + boundingWidth || py >= y + boundingHeight) return false;
    int index = (px - x) + (py - y) * boundingWidth;
    return blocks.containsKey(index);
  }
  
  Block getBlockAtLocalXY(int px, int py) {
    if(px < 0 || py < 0 || px >= boundingWidth || py >= boundingHeight) return null;
    int index = px + py * boundingWidth;
    return blocks.get(index);
  }
  
  Block getBlockAtGlobalXY(int px, int py) {
    if(px < x || py < y || px >= x + boundingWidth || py >= y + boundingHeight) return null;
    int index = (px - x) + (py - y) * boundingWidth;
    return blocks.get(index);
  }
  
  void resize(int newWidth, int newHeight) {
    HashMap<Integer, Block> newBlocks = new HashMap<>();
    blocks.forEach((Integer idx, Block b) -> {
      int oldX = idx % boundingWidth;
      int oldY = (int)(idx / boundingWidth);
      int newIndex = oldX + oldY * newWidth;
      newBlocks.put(newIndex, b);
    });
    boundingWidth = newWidth;
    boundingHeight = newHeight;
    blocks = newBlocks;
  }
  
  void addBlock(Block block) {
    int index = (block.x - x) + (block.y - y) * boundingWidth;
    blocks.put(index, block);
  }
  
  Block addBlock(int px, int py, int id) {
    HashMap<Integer, PushInteraction> interactions = manager.defaultInteractions.get(id);
    Block block = new Block(px, py, id, interactions, this);
    int index = (block.x - px) + (block.y - py) * boundingWidth;
    blocks.put(index, block);
    return block;
  }
  
  void removeBlock(Block block) {
    if(!blocks.values().contains(block)) return;
    int index = (block.x - x) + (block.y - y) * boundingWidth;
    blocks.remove(index);
  }
  
  boolean canMove(Direction dir) {
    for(Block b : blocks.values()) {
      if(!b.canMove(dir)) return false;
    }
    return true;
  }
  
  void move(Direction dir) {
    for(Block b : blocks.values()) {
      b.move(dir);
    }
    switch(dir) {
    case UP:
      y--;
      break;
    case RIGHT:
      x++;
      break;
    case DOWN:
      y++;
      break;
    case LEFT:
      x--;
      break;
    default:
      return;
    }
  }
  
  void showPix() {
    
  }
  
  void showRect() {
    noStroke();
    for(Block b : blocks.values()) {
      fill(manager.idColors.get(b.id));
      float scl = (float)width / manager.worldWidth;
      rect(b.x * scl, b.y * scl, scl, scl);
    }
  }
}
