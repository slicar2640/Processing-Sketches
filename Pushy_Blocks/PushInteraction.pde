class PushInteraction {
  PushType pushType;
  int newId;
  PushInteraction(PushType pushType, int newId) {
    this.pushType = pushType;
    this.newId = newId;
  }
  PushInteraction(PushType pushType) throws IllegalArgumentException {
    if (pushType == PushType.MERGE) {
      throw new IllegalArgumentException("PushInteractions of type MERGE must have a newId");
    } else {
      this.pushType = pushType;
    }
  }
}

enum PushType {
  STOP,
    PUSH,
    MERGE,
    NOTHING
}
