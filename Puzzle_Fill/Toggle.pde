class Toggle {
  PVector pos;
  float size;
  String label;
  boolean state;
  Toggle(float x, float y, float s, String l, boolean on) {
    pos = new PVector(x, y);
    size = s;
    label = l;
    state = on;
  }
  
  boolean isClicked(float x, float y) {
    return x >= pos.x && x <= pos.x + size && y >= pos.y && y <= pos.y + size;
  }
  
  void toggle() {
    state = !state;
  }
  
  void show() {
    stroke(255);
    strokeWeight(2);
    fill(state ? #FF3636 : 0);
    rect(pos.x, pos.y, size, size);
    textAlign(LEFT, CENTER);
    textSize(size);
    noStroke();
    fill(255);
    text(label, pos.x + size + 2, pos.y + size / 2);
  }
}
