class InteractionManager {
  boolean buildingWire = false;
  PVector buildWireDisplayPoint;
  
  InteractionManager() {
    
  }
  
  PVector wireBuildDisplayPoint() {
    return new PVector(0, 0);
  }
}
