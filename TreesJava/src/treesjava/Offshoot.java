package treesjava;

import java.awt.Color;

public class Offshoot extends Cell {
  private static final int[][] growDirections = { { 0, 1 }, { -1, 0 }, { 0, -1 }, { 1, 0 } }; // start down, CW
  private int state;
  public Tree tree;
  private int energy;

  public Offshoot(int x, int y, int state, Tree tree) {
    this.x = x;
    this.y = y;
    this.state = state;
    this.tree = tree;
    gameManager = tree.gameManager;
  }

  public void grow() {
    int numGrowths = 0;
    for (int i = 0; i < 4; i++) {
      int newState = tree.genome[state][i];
      if (newState < 16) {
        int newX = x + growDirections[i][0];
        int newY = y + growDirections[i][1];
        if (newX >= 0 && newX < gameManager.width && newY >= 0 && newY < gameManager.height
            && gameManager.grid[newX + newY * gameManager.width] == null) {
          numGrowths++;
        }
      }
    }

    int neededEnergy = numGrowths * gameManager.costToGrow;
    if (energy >= neededEnergy) {
      for (int i = 0; i < 4; i++) {
        int newState = tree.genome[state][i];
        if (newState < 16) {
          int newX = (x + growDirections[i][0] + gameManager.width) % gameManager.width;
          int newY = y + growDirections[i][1];
          if (newX >= 0 && newX < gameManager.width && newY >= 0 && newY < gameManager.height
              && gameManager.grid[newX + newY * gameManager.width] == null) {
            Offshoot newShoot = new Offshoot(newX, newY, newState, tree);
            gameManager.grid[newX + newY * gameManager.width] = newShoot;
            tree.offshoots.add(newShoot);
          }
        }
      }
      tree.offshoots.remove(this);
      Stem stem = new Stem(this);
      tree.stems.add(stem);
      gameManager.grid[x + y * gameManager.width] = stem;
    }
  }

  public void updateEnergy() {
    energy += gameManager.sunEnergy(this);
  }

  @Override
  public void show(Renderer renderer, int cameraX) {
    renderer.noStroke();
    renderer.fill(Color.WHITE);
    renderer.rect((x - cameraX) * gameManager.cellSize, y * gameManager.cellSize, gameManager.cellSize,
        gameManager.cellSize);
  }
}
