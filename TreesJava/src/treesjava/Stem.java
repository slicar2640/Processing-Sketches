package treesjava;

public class Stem extends Cell {
  public Tree tree;

  public Stem(Offshoot offshoot) {
    this.x = offshoot.x;
    this.y = offshoot.y;
    this.gameManager = offshoot.gameManager;
    this.tree = offshoot.tree;
  }

  @Override
  public void show(Renderer renderer, int cameraX) {
    if (tree.selected) {
      renderer.fill(tree.color.brighter());
    } else {
      renderer.noStroke();
      renderer.fill(tree.color);
    }
    renderer.rect((x - cameraX) * gameManager.cellSize, y * gameManager.cellSize, gameManager.cellSize,
        gameManager.cellSize);
  }
}
