class UndoManager {
  ArrayList<HashSet<PieceAction>> undo = new ArrayList<>();
  ArrayList<HashSet<PieceAction>> redo = new ArrayList<>();

  void flipAction(HashSet<Integer> indices) {
    redo.clear();
    HashSet<PieceAction> actions = new HashSet<>();
    for(int index : indices) {
      if(index == -1) continue;
      actions.add(new PieceAction(index, filledIndices.contains(index), !filledIndices.contains(index)));
    }
    undo.add(actions);
    setPieces(actions, false);
  }

  void flipAction(int index) {
    if(index == -1) return;
    redo.clear();
    HashSet<PieceAction> actions = new HashSet<>();
    actions.add(new PieceAction(index, filledIndices.contains(index), !filledIndices.contains(index)));
    undo.add(actions);
    setPieces(actions, false);
  }
  
  void setAction(HashSet<Integer> indices, boolean setTo) {
    redo.clear();
    HashSet<PieceAction> actions = new HashSet<>();
    for(int index : indices) {
      if(index == -1) continue;
      actions.add(new PieceAction(index, filledIndices.contains(index), setTo));
    }
    undo.add(actions);
    setPieces(actions, false);
  }
  
  void setAction(int index, boolean setTo) {
    if(index == -1) return;
    redo.clear();
    HashSet<PieceAction> actions = new HashSet<>();
    actions.add(new PieceAction(index, filledIndices.contains(index), setTo));
    undo.add(actions);
    setPieces(actions, false);
  }

  void setPieces(HashSet<PieceAction> actions, boolean reversed) {
    for (PieceAction action : actions) {
      color fillCol;
      if ((reversed ? action.start : action.end) == false) {
        fillCol = color(255);
        filledIndices.remove(action.index);
      } else {
        fillCol = color(255, 0, 0);
        filledIndices.add(action.index);
      }

      for (int i : indicesArr.get(action.index)) {
        outputImage.pixels[i] = fillCol;
      }
    }
    outputImage.updatePixels();
  }

  void undo() {
    if (undo.size() > 0) {
      HashSet<PieceAction> lastAction = undo.remove(undo.size() - 1); //<>//
      setPieces(lastAction, true);
      redo.add(lastAction);
    }
  }

  void redo() {
    if (redo.size() > 0) {
      HashSet<PieceAction> lastAction = redo.remove(redo.size() - 1); //<>//
      setPieces(lastAction, false);
      undo.add(lastAction);
    }
  }
}

class PieceAction {
  int index;
  boolean start;
  boolean end;
  PieceAction(int index, boolean start, boolean end) {
    this.index = index;
    this.start = start;
    this.end = end;
  }
}
