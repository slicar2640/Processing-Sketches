package treesjava;

import java.awt.Color;
import java.awt.Font;

public class TreeInspector extends Widget {
  private Tree tree;
  private final Font baseFont = new Font("SansSerif", Font.PLAIN, 1);

  public TreeInspector(Tree tree) {
    this.tree = tree;
    this.gameManager = tree.gameManager;
  }

  @Override
  protected void draw() {
    float fontSize = getHeight() / 24f;
    float fontHeight = fontSize * 72 / 96;
    graphics.setFont(baseFont.deriveFont(fontHeight));
    // for(int i = 0; i < 2; i++) {
    // for(int j = 0; j < 8; j++) {
    // int index = i * 8 + j;
    int numberWidth = (int) (getHeight() / 26);
    graphics.setPaint(Color.RED);
    graphics.fillRect(0, 0, numberWidth, (int) fontHeight);
    graphics.setPaint(Color.WHITE);
    graphics.drawString("00", 0, (int) fontHeight);
    // }
    // }
  }
}
