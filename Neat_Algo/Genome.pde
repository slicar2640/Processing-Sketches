class Genome {
  RandomHashSet<NodeGene> nodes = new RandomHashSet<>();
  RandomHashSet<ConnectionGene> connections = new RandomHashSet<>();

  Neat neat;

  Genome(Neat neat) {
    this.neat = neat;
  }

  double distance(Genome g2) {
    Genome g1 = this;

    int highestInnovationGene1 = 0;
    if (g1.getConnections().size() != 0) {
      highestInnovationGene1 = g1.getConnections().get(g1.getConnections().size() - 1).getInnovationNumber();
    }
    int highestInnovationGene2 = 0;
    if (g2.getConnections().size() != 0) {
      highestInnovationGene2 = g2.getConnections().get(g2.getConnections().size() - 1).getInnovationNumber();
    }

    if (highestInnovationGene1 < highestInnovationGene2) {
      Genome g = g1;
      g1 = g2;
      g2 = g;
    }

    int indexG1 = 0;
    int indexG2 = 0;

    int disjoint = 0;
    int excess = 0;
    double weightDiff = 0;
    int similar = 0;

    while (indexG1 < g1.getConnections().size() && indexG2 < g2.getConnections().size()) {
      ConnectionGene gene1 = g1.getConnections().get(indexG1);
      ConnectionGene gene2 = g2.getConnections().get(indexG2);

      int in1 = gene1.getInnovationNumber();
      int in2 = gene2.getInnovationNumber();

      if (in1 == in2) { //similar gene
        indexG1++;
        indexG2++;
        similar++;
        weightDiff += Math.abs(gene1.getWeight() - gene2.getWeight());
      } else if (in1 > in2) { //disjoint gene of b
        indexG2++;
        disjoint++;
      } else { //disjoint gene of a
        indexG1++;
        disjoint++;
      }
    }
    weightDiff /= similar;
    excess = g1.getConnections().size() - indexG1;

    double N = Math.max(g1.getConnections().size(), g2.getConnections().size());
    if (N < 20) {
      N = 1;
    }
    return neat.getC1() * disjoint / N + neat.getC2() * excess / N + neat.getC3() * weightDiff / N;
  }

  Genome crossOver(Genome g2) { //not static because Processing dumb
    Genome g1 = this;

    Neat neat = g1.getNeat();
    Genome child = neat.emptyGenome();

    int indexG1 = 0;
    int indexG2 = 0;

    while (indexG1 < g1.getConnections().size() && indexG2 < g2.getConnections().size()) {
      ConnectionGene gene1 = g1.getConnections().get(indexG1);
      ConnectionGene gene2 = g2.getConnections().get(indexG2);

      int in1 = gene1.getInnovationNumber();
      int in2 = gene2.getInnovationNumber();

      if (Math.random() > 0.5) {
        child.getConnections().add(neat.getConnection(gene1));
      } else {
        child.getConnections().add(neat.getConnection(gene2));
      }

      if (in1 == in2) { //similar gene
        indexG1++;
        indexG2++;
      } else if (in1 > in2) { //disjoint gene of b
        indexG2++;
      } else { //disjoint gene of a
        indexG1++;
        child.getConnections().add(neat.getConnection(gene1));
      }
    }

    while (indexG1 < g1.getConnections().size()) {
      ConnectionGene gene1 = g1.getConnections().get(indexG1);
      child.getConnections().add(neat.getConnection(gene1));
      indexG1++;
    }

    for (ConnectionGene c : child.getConnections().getData()) {
      child.getNodes().add(c.getFrom());
      child.getNodes().add(c.getTo());
    }
    return child;
  }

  void mutate() {
    if (Math.random() < neat.getMutateLinkProbability()) {
      mutateLink();
    }
    if (Math.random() < neat.getMutateNodeProbability()) {
      mutateNode();
    }
    if (Math.random() < neat.getMutateWeightShiftProbability()) {
      mutateWeightShift();
    }
    if (Math.random() < neat.getMutateWeightRandomProbability()) {
      mutateWeightRandom();
    }
    if (Math.random() < neat.getMutateToggleLinkProbability()) {
      mutateToggleLink();
    }
  }

  void mutateLink() {
    for (int i = 0; i < 100; i++) {
      NodeGene a = nodes.randomElement();
      NodeGene b = nodes.randomElement();

      if (a.getX() == b.getX()) {
        continue;
      }

      ConnectionGene con;
      if (a.getX() < b.getX()) {
        con = new ConnectionGene(a, b);
      } else {
        con = new ConnectionGene(b, a);
      }

      con = neat.getConnection(con.getFrom(), con.getTo());
      con.setWeight((Math.random() * 2 - 1) * neat.getWeightRandomStrength());

      connections.addSorted(con);
      return;
    }
  }

  void mutateNode() {
    ConnectionGene con = connections.randomElement();
    if (con == null) return;

    NodeGene from = con.getFrom();
    NodeGene to = con.getTo();

    int replaceIndex = neat.getReplaceIndex(from, to);
    NodeGene middle;
    if (replaceIndex == 0) {
      middle = neat.getNode();
      middle.setX((from.getX() + to.getX()) / 2);
      middle.setY((from.getY() + to.getY()) / 2 + Math.random() * 0.1 - 0.05);
    } else {
      middle = neat.getNode(replaceIndex);
    }

    ConnectionGene con1 = neat.getConnection(from, middle);
    ConnectionGene con2 = neat.getConnection(middle, to);

    con1.setWeight(1);
    con2.setWeight(con.getWeight());
    con2.setEnabled(con.isEnabled());

    connections.remove(con);
    connections.add(con1);
    connections.add(con2);

    nodes.add(middle);
  }

  void mutateWeightShift() {
    ConnectionGene con = connections.randomElement();
    if (con != null) {
      con.setWeight(con.getWeight() + (Math.random() * 2 - 1) * neat.getWeightShiftStrength());
    }
  }

  void mutateWeightRandom() {
    ConnectionGene con = connections.randomElement();
    if (con != null) {
      con.setWeight((Math.random() * 2 - 1) * neat.getWeightRandomStrength());
    }
  }

  void mutateToggleLink() {
    ConnectionGene con = connections.randomElement();
    if (con != null) {
      con.setEnabled(!con.isEnabled());
    }
  }

  RandomHashSet<ConnectionGene> getConnections() {
    return connections;
  }

  RandomHashSet<NodeGene> getNodes() {
    return nodes;
  }

  Neat getNeat() {
    return neat;
  }
  
  @Override
  String toString() {
    String ret = "nodes: ";
    for(NodeGene node : nodes.getData()) {
      ret += node.getInnovationNumber() + ", ";
      ret += nf((float)node.getX(), 0, 0) + ", ";
      ret += nf((float)node.getY(), 0, 0) + "; ";
    }
    ret += "connections: ";
    for(ConnectionGene con : connections.getData()) {
      ret += con.getFrom().getInnovationNumber() + "-";
      ret += con.getTo().getInnovationNumber() + ", ";
      ret += nf((float)con.getWeight(), 0, 0) + "; ";
    }
    return ret;
  }
}
