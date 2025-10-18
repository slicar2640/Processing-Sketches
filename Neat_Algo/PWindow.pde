class PWindow extends PApplet {

  PWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }
  void settings() {
    size(400, 400);
  }

  void draw() {
    background(150);
    try {
      //showGenome(neat.getBestSpecies().getRepresentative().getGenome());
      showGenome(neat.getBestClient().getGenome());
    }
    catch(NullPointerException e) {
    }
  }

  void showGenome(Genome g) {
    for (ConnectionGene con : (ArrayList<ConnectionGene>)g.connections.getData().clone()) {
      if(!con.isEnabled()) continue;
      stroke(map((float)con.getWeight(), 0, -1, 0, 255), map((float)con.getWeight(), 0, 1, 0, 255), 0);
      line((float)con.from.x * width, (float)con.from.y * height, (float)con.to.x * width, (float)con.to.y * height);
    }

    fill(200);
    stroke(0);
    strokeWeight(2);
    for (NodeGene node : (ArrayList<NodeGene>)g.getNodes().getData().clone()) {
      ellipse((float) node.x * width, (float) node.y * height, 10, 10);
    }
  }
  
  void mousePressed() {
    if(mouseButton == RIGHT) {
      println(neat.getBestClient().getGenome().toString());
    }
  }
}
