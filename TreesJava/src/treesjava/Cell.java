package treesjava;

public abstract class Cell {
  public int x, y;
  public GameManager gameManager;

  public abstract void show(Renderer renderer, int cameraX);
}
