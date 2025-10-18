class World {
  ArrayList<Destination> destinations = new ArrayList<Destination>();
  int numDestinationTypes;
  ArrayList<Ant> ants = new ArrayList<Ant>();
  World(int numDestinationTypes, int destinationsEach, int numAnts) {
    this.numDestinationTypes = numDestinationTypes;
    for(int i = 0; i < numDestinationTypes; i++) {
      for(int j = 0; j < destinationsEach; j++) {
        destinations.add(new Destination(random(width), random(height), 30, i));
      }
    }
    for(int i = 0; i < numAnts; i++) {
      ants.add(new Ant(random(width), random(height), numDestinationTypes, this));
    }
  }
  
  void update() {
    //for(Ant ant : ants) {
    //  ant.sendBroadcast();
    //}
    for(Ant ant : ants) {
      ant.update();
    }
  }
  
  void show() {
    strokeWeight(2);
    for(Ant ant : ants) {
      stroke(destinationColors[ant.currentDestination]);
      point(ant.pos.x, ant.pos.y);
    }
    for(Destination d : destinations) {
      d.show();
    }
  }
}
