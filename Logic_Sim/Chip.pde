class Chip {
  int numInputs;
  ArrayList<Pin> inputs = new ArrayList<>();
  int numOutputs;
  ArrayList<Pin> outputs = new ArrayList<>();
  String name;
  int computedInputs = 0;
  ArrayList<Chip> subChips = new ArrayList<>();
  Chip(int inputs, int outputs, String name) {
    numInputs = inputs;
    numOutputs = outputs;
    this.name = name;
  }
}
