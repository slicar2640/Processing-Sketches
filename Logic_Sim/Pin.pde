class Pin {
  boolean state;
  Pin inputPin;
  HashSet<Pin> outputPins = new HashSet<>();
  boolean isComputed = false;
  Chip parentChip;
  boolean isInput;
  
  Pin(Chip parentChip, boolean isInput) {
    this.parentChip = parentChip;
    this.isInput = isInput;
  }
  
  void disconnectInput() {
    this.inputPin.removeOutput(this);
    this.inputPin = null;
  }
  
  void reconnectInput(Pin inputPin) {
    this.inputPin.removeOutput(this);
    this.inputPin = inputPin;
    this.inputPin.addOutput(this);
  }
  
  void addOutput(Pin pin) {
    outputPins.add(pin);
  }
  
  void removeOutput(Pin pin) {
    outputPins.remove(pin);
  }
  
  void propogate() {
    for(Pin pin : outputPins) {
      pin.receiveInput(state);
    }
  }
  
  void receiveInput(boolean input) {
    state = input;
    isComputed = true;
    parentChip.computedInputs++;
  }
}
