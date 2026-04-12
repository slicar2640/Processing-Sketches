package treesjava;

public class App {
  public static void main(String[] args) throws Exception {
    GameManager gm = new GameManager(750, 80, 5, 200, true);
    gm.start();
  }
}
