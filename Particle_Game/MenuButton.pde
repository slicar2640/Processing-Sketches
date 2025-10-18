class MenuButton {
  float x, y, w, h;
  String id, label;
  DrawFunction show;
  MenuManager manager;
  public MenuButton(String id, float x, float y, float w, float h, String label, MenuManager manager, DrawFunction show) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.show = show;
    this.manager = manager;
  }
  
  public boolean click(float mx, float my) {
    if(mx >= x && mx <= x + w && my >= y && my <= y + h) {
      manager.buttonPress(id);
      return true;
    }
    return false;
  }
  
  public void show() {
    stroke(100);
    strokeWeight(2);
    fill(100);
    rect(x, y, w, h);
    fill(50);
    noStroke();
    rect(x + 1, y + 1, h - 2, h - 2);
    push();
    translate(x + h / 2, y + h / 2);
    scale(h, h);
    show.run();
    pop();
    fill(255);
    noStroke();
    textSize(20);
    textAlign(LEFT, CENTER);
    text(label, x + h, y + h / 2);
  }
}

@FunctionalInterface
interface DrawFunction {
  void run();
}
