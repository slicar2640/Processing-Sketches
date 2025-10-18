class Client {
  Genome genome;
  double score;
  Species species;
  Calculator calculator;
  Rocket rocket;

  void generateCalculator() {
    this.calculator = new Calculator(genome);
  }

  double[] calculate(double... input) {
    if (this.calculator == null) generateCalculator();
    return this.calculator.calculate(input);
  }

  double distance(Client other) {
    return genome.distance(other.getGenome());
  }

  void mutate() {
    genome.mutate();
  }

  Calculator getCalculator() {
    return calculator;
  }

  Genome getGenome() {
    return genome;
  }

  void setGenome(Genome genome) {
    this.genome = genome;
  }

  double getScore() {
    return score;
  }

  void setScore(double score) {
    this.score = score;
  }

  Species getSpecies() {
    return species;
  }

  void setSpecies(Species species) {
    this.species = species;
  }
}
