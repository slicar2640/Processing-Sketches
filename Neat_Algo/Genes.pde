class Gene {
  int innovationNumber;

  Gene(int innovationNumber) {
    this.innovationNumber = innovationNumber;
  }

  int getInnovationNumber() {
    return innovationNumber;
  }

  void setInnovationNumber(int innovationNumber) {
    this.innovationNumber = innovationNumber;
  }
}

class NodeGene extends Gene {
  double x, y;

  NodeGene(int innovationNumber) {
    super(innovationNumber);
  }

  double getX() {
    return x;
  }

  void setX(double x) {
    this.x = x;
  }

  double getY() {
    return y;
  }

  void setY(double y) {
    this.y = y;
  }

  boolean equals(Object o) {
    if (!(o instanceof NodeGene)) return false;
    return innovationNumber == ((NodeGene) o).getInnovationNumber();
  }

  int hashCode() {
    return innovationNumber;
  }
}

class ConnectionGene extends Gene {
  NodeGene from;
  NodeGene to;

  double weight;
  boolean enabled = true;

  int replaceIndex;

  ConnectionGene(NodeGene from, NodeGene to) {
    super(-1);
    this.from = from;
    this.to = to;
  }

  NodeGene getFrom() {
    return from;
  }

  void setFrom(NodeGene from) {
    this.from = from;
  }

  NodeGene getTo() {
    return to;
  }

  void setTo(NodeGene to) {
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

  int getReplaceIndex() {
    return replaceIndex;
  }

  void setReplaceIndex(int replaceIndex) {
    this.replaceIndex = replaceIndex;
  }

  boolean equals(Object o) {
    if (!(o instanceof ConnectionGene)) return false;
    ConnectionGene c = (ConnectionGene) o;
    return (from.equals(c.from) && to.equals(c.to));
  }

  int hashCode() {
    return from.getInnovationNumber() * Neat.MAX_NODES + to.getInnovationNumber();
  }
}
