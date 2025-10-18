class Block extends Movable {
  int id;
  HashMap<Integer, PushInteraction> pushInteractions;
  Composite parentComposite;

  Block(int x, int y, int id, HashMap<Integer, PushInteraction> pushInteractions, WorldManager manager) {
    this.x = x;
    this.y = y;
    this.id = id;
    this.pushInteractions = pushInteractions;
    this.manager = manager;
  }

  Block(int x, int y, int id, HashMap<Integer, PushInteraction> pushInteractions, Composite parentComposite) {
    this.x = x;
    this.y = y;
    this.id = id;
    this.pushInteractions = pushInteractions;
    this.parentComposite = parentComposite;
    this.manager = parentComposite.manager;
  }

  PushInteraction getInteractionWith(int id) {
    PushInteraction interaction = pushInteractions.get(id);
    return interaction != null ? interaction : new PushInteraction(PushType.NOTHING);
  }

  boolean canMove(Direction dir) {
    int newX, newY;
    switch(dir) {
    case UP:
      newX = x;
      newY = y - 1;
      break;
    case RIGHT:
      newX = x + 1;
      newY = y;
      break;
    case DOWN:
      newX = x;
      newY = y + 1;
      break;
    case LEFT:
      newX = x - 1;
      newY = y;
      break;
    default:
      return false;
    }
    if (newX < 0 || newY < 0 || newX >= manager.worldWidth || newY >= manager.worldHeight) {
      switch(manager.wallType) {
      case STOP:
        return false;
      case WRAP:
        newX = (newX + manager.worldWidth) % manager.worldWidth;
        newY = (newY + manager.worldHeight) % manager.worldHeight;
      case DELETE:
        return true;
      default:
        return false;
      }
    }
    Movable itemAtNewSpot = manager.getItemAtXY(newX, newY);
    int newSpotId;
    if (itemAtNewSpot instanceof Composite) {
      Composite composite = (Composite) itemAtNewSpot;
      if (composite == parentComposite) return true;
      newSpotId = composite.getBlockAtGlobalXY(newX, newY).id;
    } else if (itemAtNewSpot instanceof Block) {
      Block b = (Block) itemAtNewSpot;
      newSpotId = b.id;
    } else {
      return true;
    }
    PushInteraction interaction = getInteractionWith(newSpotId);
    switch(interaction.pushType) {
    case STOP:
      return false;
    case PUSH:
      return itemAtNewSpot.canMove(dir);
    case MERGE:
      return true;
    case NOTHING:
      return true;
    default:
      return false;
    }
  }

  PushInteraction nextPushInteraction(Direction dir) {
    int newX, newY;
    switch(dir) {
    case UP:
      newX = x;
      newY = y - 1;
      break;
    case RIGHT:
      newX = x + 1;
      newY = y;
      break;
    case DOWN:
      newX = x;
      newY = y + 1;
      break;
    case LEFT:
      newX = x - 1;
      newY = y;
      break;
    default:
      return new PushInteraction(PushType.NOTHING);
    }
    if (newX < 0 || newY < 0 || newX >= manager.worldWidth || newY >= manager.worldHeight) {
      switch(manager.wallType) {
      case WRAP:
        newX = (newX + manager.worldWidth) % manager.worldWidth;
        newY = (newY + manager.worldHeight) % manager.worldHeight;
        break;
      case DELETE:
        manager.removeBlock(this);
        return new PushInteraction(PushType.NOTHING);
      default:
        return new PushInteraction(PushType.NOTHING);
      }
    }
    Movable itemAtNewSpot = manager.getItemAtXY(newX, newY);
    int newSpotId;
    if (itemAtNewSpot instanceof Composite) {
      Composite composite = (Composite) itemAtNewSpot;
      if (composite == parentComposite) {
        newSpotId = 0;
      } else {
        newSpotId = composite.getBlockAtGlobalXY(newX, newY).id;
      }
    } else {
      Block b = (Block) itemAtNewSpot;
      if (b == null) {
        newSpotId = 0;
      } else {
        newSpotId = b.id;
      }
    }
    PushInteraction interaction = getInteractionWith(newSpotId);
    return interaction;
  }

  void move(Direction dir) {
    int newX, newY;
    switch(dir) {
    case UP:
      newX = x;
      newY = y - 1;
      break;
    case RIGHT:
      newX = x + 1;
      newY = y;
      break;
    case DOWN:
      newX = x;
      newY = y + 1;
      break;
    case LEFT:
      newX = x - 1;
      newY = y;
      break;
    default:
      return;
    }
    if (newX < 0 || newY < 0 || newX >= manager.worldWidth || newY >= manager.worldHeight) {
      switch(manager.wallType) {
      case WRAP:
        newX = (newX + manager.worldWidth) % manager.worldWidth;
        newY = (newY + manager.worldHeight) % manager.worldHeight;
        break;
      case DELETE:
        manager.removeBlock(this);
        return;
      default:
        return;
      }
    }
    Movable itemAtNewSpot = manager.getItemAtXY(newX, newY);
    int newSpotId;
    if (itemAtNewSpot instanceof Composite) {
      Composite composite = (Composite) itemAtNewSpot;
      if (composite == parentComposite) {
        newSpotId = 0;
      } else {
        newSpotId = composite.getBlockAtGlobalXY(newX, newY).id;
      }
    } else {
      Block b = (Block) itemAtNewSpot;
      if (b == null) {
        newSpotId = 0;
      } else {
        newSpotId = b.id;
      }
    }
    PushInteraction interaction = getInteractionWith(newSpotId);
    if (interaction == null) {
      moveSelf(newX, newY);
    } else {
      switch(interaction.pushType) {
      case PUSH:
        itemAtNewSpot.move(dir);
        moveSelf(newX, newY);
        break;
      case MERGE:
        if (itemAtNewSpot instanceof Composite) { //just push the composite instead of merging
          itemAtNewSpot.move(dir);
          moveSelf(newX, newY);
        } else {
          Block mergedBlock = (Block)itemAtNewSpot;
          manager.removeBlock(mergedBlock);
          mergeSelf(newX, newY, interaction.newId);
        }
        break;
      case NOTHING:
        moveSelf(newX, newY);
      default:
        break;
      }
    }
  }

  void moveSelf(int newX, int newY) {
    if (parentComposite == null) manager.removeBlock(this);
    x = newX;
    y = newY;
    if (parentComposite == null) manager.addBlock(this);
  }

  void mergeSelf(int newX, int newY, int newId) {
    if (parentComposite == null) manager.removeBlock(this);
    x = newX;
    y = newY;
    id = newId;
    if (parentComposite == null) manager.addBlock(this);
  }
}
