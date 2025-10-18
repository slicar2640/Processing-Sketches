class Connection {
  Node from;
  Node to;

  double weight;
  boolean enabled = true;

  Connection(Node from, Node to) {
    this.from = from;
    this.to = to;
  }

  Node getFrom() {
    return from;
  }

  void setFrom(Node from) {
    this.from = from;
  }

  Node getTo() {
    return to;
  }

  void setTo(Node to) {
    this.to = to;
  }

  double getWeight() {
    return weight;
  }

  void setWeight(double weight) {
    this.weight = weight;
  }

  boolean isEnabled() {
    return enabled;
  }

  void setEnabled(boolean enabled) {
    this.enabled = enabled;
  }
}

class Node implements Comparable<Node> {
  double x;
  double output;
  ArrayList<Connection> connections = new ArrayList<>();

  Node(double x) {
    this.x = x;
  }

  void calculate() {
    double sum = 0;
    for (Connection c : connections) {
      if (c.isEnabled()) {
        sum += c.getWeight() * c.getFrom().getOutput();
      }
    }
    output = activationFunction(sum);
  }

  double activationFunction(double x) {
    return 1d / (1 + Math.exp(-x));
  }

  double getX() {
    return x;
  }

  void setX(double x) {
    this.x = x;
  }

  double getOutput() {
    return output;
  }

  void setOutput(double output) {
    this.output = output;
  }

  ArrayList<Connection> getConnections() {
    return connections;
  }

  void setConnections(ArrayList<Connection> connections) {
    this.connections = connections;
  }

  int compareTo(Node o) {
    if (this.x > o.x) return -1;
    if (this.x < o.x) return 1;
    return 0;
  }
}

class Calculator {
  ArrayList<Node> inputNodes = new ArrayList<>();
  ArrayList<Node> hiddenNodes = new ArrayList<>();
  ArrayList<Node> outputNodes = new ArrayList<>();

  Calculator(Genome g) {
    RandomHashSet<NodeGene> nodes = g.getNodes();
    RandomHashSet<ConnectionGene> cons = g.getConnections();

    HashMap<Integer, Node> nodeHashMap = new HashMap<>();

    for (NodeGene n : nodes.getData()) {
      Node node = new Node(n.getX());
      nodeHashMap.put(n.getInnovationNumber(), node);

      if (n.getX() <= 0.1) {
        inputNodes.add(node);
      } else if (n.getX() > 0.9) {
        outputNodes.add(node);
      } else {
        hiddenNodes.add(node);
      }
    }

    hiddenNodes.sort((o1, o2) -> o1.compareTo(o2));

    for (ConnectionGene c : cons.getData()) {
      NodeGene from = c.getFrom();
      NodeGene to = c.getTo();

      Node nodeFrom = nodeHashMap.get(from.getInnovationNumber());
      Node nodeTo = nodeHashMap.get(to.getInnovationNumber());

      Connection con = new Connection(nodeFrom, nodeTo);
      con.setWeight(c.getWeight());
      con.setEnabled(c.isEnabled());

      nodeTo.getConnections().add(con);
    }
  }

  double[] calculate(double... input) {
    if (input.length != inputNodes.size()) throw new RuntimeException("Data no fit");
    for (int i = 0; i < inputNodes.size(); i++) {
      inputNodes.get(i).setOutput(input[i]);
    }
    for (Node n : hiddenNodes) {
      n.calculate();
    }

    double[] output = new double[outputNodes.size()];
    for (int i = 0; i < outputNodes.size(); i++) {
      outputNodes.get(i).calculate();
      output[i] = outputNodes.get(i).getOutput();
    }
    return output;
  }
}
