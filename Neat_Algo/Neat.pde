class Neat {
  static final int MAX_NODES = 1000000;

  double C1 = 1, C2 = 1, C3 = 1;
  double CP = 4;

  double weightShiftStrength = 0.3;
  double weightRandomStrength = 1;

  double survivorPercent = 0.8;

  double mutateLinkProbability = 0.01;
  double mutateNodeProbability = 0.03;
  double mutateWeightShiftProbability = 0.002;
  double mutateWeightRandomProbability = 0.002;
  double mutateToggleLinkProbability = 0;

  HashMap<ConnectionGene, ConnectionGene> allConnections = new HashMap<>();
  ArrayList<NodeGene> allNodes = new ArrayList<>();

  RandomHashSet<Client> clients = new RandomHashSet<>();
  RandomHashSet<Species> species = new RandomHashSet<>();

  int inputSize;
  int outputSize;
  int maxClients;
  
  Client bestClient;
  Species bestSpecies;

  Neat(int inputSize, int outputSize, int clients) {
    this.reset(inputSize, outputSize, clients);
  }

  Genome emptyGenome() {
    Genome g = new Genome(this);
    for (int i = 0; i < inputSize + outputSize; i++) {
      g.getNodes().add(getNode(i + 1));
    }
    for(int i = 0; i < outputSize; i++) {
      g.getConnections().add(getConnection(getNode(1), getNode(inputSize + 1 + i)));
    }
    return g;
  }

  void reset(int inputSize, int outputSize, int clients) {
    this.inputSize = inputSize;
    this.outputSize = outputSize;
    this.maxClients = clients;

    allConnections.clear();
    allNodes.clear();
    this.clients.clear();

    for (int i = 0; i < inputSize; i++) {
      NodeGene n = getNode();
      n.setX(0.1);
      n.setY((i + 1) / (double)(inputSize + 1));
    }

    for (int i = 0; i < outputSize; i++) {
      NodeGene n = getNode();
      n.setX(0.91);
      n.setY((i + 1) / (double)(outputSize + 1));
    }
    
    for (int i = 0; i < maxClients; i++) {
      Client c = new Client();
      if(i == 0) {
        species.add(new Species(c));
      } else {
        species.get(0).forcePut(c);
      }
      c.setGenome(emptyGenome());
      c.generateCalculator();
      this.clients.add(c);
    }
  }

  Client getClient(int index) {
    return clients.get(index);
  }

  ConnectionGene getConnection(ConnectionGene con) {
    ConnectionGene c = new ConnectionGene(con.getFrom(), con.getTo());
    c.setInnovationNumber(con.getInnovationNumber());
    c.setWeight(con.getWeight());
    c.setEnabled(con.isEnabled());
    return c;
  }

  ConnectionGene getConnection(NodeGene node1, NodeGene node2) {
    ConnectionGene connectionGene = new ConnectionGene(node1, node2);
    if (allConnections.containsKey(connectionGene)) {
      connectionGene.setInnovationNumber(allConnections.get(connectionGene).getInnovationNumber());
    } else {
      connectionGene.setInnovationNumber(allConnections.size() + 1);
      allConnections.put(connectionGene, connectionGene);
    }
    return connectionGene;
  }

  void setReplaceIndex(NodeGene node1, NodeGene node2, int index) {
    allConnections.get(new ConnectionGene(node1, node2)).setReplaceIndex(index);
  }

  int getReplaceIndex(NodeGene node1, NodeGene node2) {
    ConnectionGene con = new ConnectionGene(node1, node2);
    ConnectionGene data = allConnections.get(con);
    if (data == null) return 0;
    return data.getReplaceIndex();
  }

  NodeGene getNode() {
    NodeGene n = new NodeGene(allNodes.size() + 1);
    allNodes.add(n);
    return n;
  }

  NodeGene getNode(int id) {
    if (id <= allNodes.size()) {
      return allNodes.get(id - 1);
    } else {
      return getNode();
    }
  }
  
  void calculateBestClient() {
    Client best = clients.get(0);
    double bestScore = 0;
    for(Client c : clients.getData()) {
      if(c.getScore() > bestScore) {
        best = c;
        bestScore = c.getScore();
      }
    }
    bestClient = best;
  }
  
  void calculateBestSpecies() {
    Species best = species.get(0);
    double bestScore = 0;
    for(Species s : species.getData()) {
      s.evaluateScore();
      if(s.getScore() > bestScore) {
        best = s;
        bestScore = s.getScore();
      }
    }
    bestSpecies = best;
  }
  
  Client getBestClient() {
    return bestClient;
  }
  
  Species getBestSpecies() {
    return bestSpecies;
  }

  void evolve() {
    generateSpecies();
    kill();
    removeExtinctSpecies();
    reproduce();
    mutate();
    for (Client c : clients.getData()) {
      c.generateCalculator();
    }
  }

  void generateSpecies() {
    for (Species s : species.getData()) {
      s.reset();
    }

    for (Client c : clients.getData()) {
      if (c.getSpecies() != null) continue;

      boolean found = false;
      for (Species s : species.getData()) {
        if (s.put(c)) {
          found = true;
          break;
        }
      }
      if (!found) {
        species.add(new Species(c));
      }
    }

    for (Species s : species.getData()) {
      s.evaluateScore();
    }
  }

  void kill() {
    for (Species s : species.getData()) {
      s.kill(1 - survivorPercent);
    }
  }

  void removeExtinctSpecies() {
    for (int i = species.size() - 1; i >= 0; i--) {
      if (species.get(i).size() <= 1) {
        species.get(i).goExtinct();
        species.remove(i);
      }
    }
  }

  void reproduce() {
    RandomSelector<Species> selector = new RandomSelector<>();
    for (Species s : species.getData()) {
      selector.add(s, s.getScore());
    }

    for (Client c : clients.getData()) {
      if (c.getSpecies() == null) {
        Species s = selector.random();
        c.setGenome(s.breed());
        s.forcePut(c);
      }
    }
  }

  void mutate() {
    for (Client c : clients.getData()) {
      c.mutate();
    }
  }

  double getC1() {
    return C1;
  }

  double getC2() {
    return C2;
  }

  double getC3() {
    return C3;
  }

  int getOutputSize() {
    return outputSize;
  }

  int getInputSize() {
    return inputSize;
  }

  double getWeightShiftStrength() {
    return weightShiftStrength;
  }

  double getWeightRandomStrength() {
    return weightRandomStrength;
  }

  double getMutateLinkProbability() {
    return mutateLinkProbability;
  }

  double getMutateNodeProbability() {
    return mutateNodeProbability;
  }

  double getMutateWeightShiftProbability() {
    return mutateWeightShiftProbability;
  }

  double getMutateWeightRandomProbability() {
    return mutateWeightRandomProbability;
  }

  double getMutateToggleLinkProbability() {
    return mutateToggleLinkProbability;
  }

  double getCP() {
    return CP;
  }

  void setCP(double CP) {
    this.CP = CP;
  }
}
