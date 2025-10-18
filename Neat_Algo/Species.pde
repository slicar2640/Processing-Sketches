class Species {
  RandomHashSet<Client> clients = new RandomHashSet<>();
  Client representative;
  double score;

  Species(Client rep) {
    representative = rep;
    representative.setSpecies(this);
    clients.add(representative);
  }

  boolean put(Client client) {
    if (client.distance(representative) < representative.getGenome().getNeat().getCP()) {
      client.setSpecies(this);
      clients.add(client);
      return true;
    }
    return false;
  }

  void forcePut(Client client) {
    client.setSpecies(this);
    clients.add(client);
  }

  void goExtinct() {
    for (Client c : clients.getData()) {
      c.setSpecies(null);
    }
  }

  void evaluateScore() {
    double v = 0;
    for (Client c : clients.getData()) {
      v += c.getScore();
    }
    score = v / clients.size();
  }

  void reset() {
    representative = clients.randomElement();
    for (Client c : clients.getData()) {
      c.setSpecies(null);
    }
    clients.clear();

    clients.add(representative);
    representative.setSpecies(this);
    score = 0;
  }

  void kill(double percentage) {
    clients.getData().sort((o1, o2) -> Double.compare(o1.getScore(), o2.getScore()));

    double amount = percentage * clients.size();
    for (int i = 0; i < amount; i++) {
      clients.get(0).setSpecies(null);
      clients.remove(0);
    }
  }

  Genome breed() {
    Client c1 = clients.randomElement();
    Client c2 = clients.randomElement();

    if (c1.getScore() > c2.getScore()) {
      return c1.getGenome().crossOver(c2.getGenome());
    } else {
      return c2.getGenome().crossOver(c1.getGenome());
    }
  }

  int size() {
    return clients.size();
  }

  RandomHashSet<Client> getClients() {
    return clients;
  }

  Client getRepresentative() {
    return representative;
  }

  double getScore() {
    return score;
  }
}
