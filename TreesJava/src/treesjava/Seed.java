package treesjava;

import java.awt.Color;
import java.util.Arrays;

public class Seed extends Cell {
  public int[][] genome;
  public Color color;

  public Seed(Offshoot offshoot) {
    x = offshoot.x;
    y = offshoot.y;
    gameManager = offshoot.gameManager;
    genome = Arrays.stream(offshoot.tree.genome).map(int[]::clone).toArray(int[][]::new);
    if (Math.random() < gameManager.mutateChance) {
      genome[(int) (Math.random() * 16)][(int) (Math.random() * 4)] = (int) (Math.random() * 32);
    }
    color = shiftColor(offshoot.tree.color);
  }

  public Seed(int x, int y, GameManager gameManager, int[][] genome, Color color) {
    this.x = x;
    this.y = y;
    this.gameManager = gameManager;
    this.genome = genome;
    this.color = color;
  }

  public Seed(int x, int y, GameManager gameManager, int[][] genome) {
    this.x = x;
    this.y = y;
    this.gameManager = gameManager;
    this.genome = genome;
    this.color = new Color(100, 255, 100);
  }

  public void fall() {
    if (y < gameManager.height - 1) {
      if (gameManager.grid[x + (y + 1) * gameManager.width] == null) {
        gameManager.grid[x + (y + 1) * gameManager.width] = this;
        gameManager.grid[x + y * gameManager.width] = null;
        y++;
      } else {
        gameManager.seeds.remove(this);
        gameManager.grid[x + y * gameManager.width] = null;
      }
    } else if (y == gameManager.height - 1) {
      gameManager.trees.add(new Tree(this));
    }
  }

  private Color shiftColor(Color col) {
    int shiftAmount = 10;
    int red = Math.clamp(col.getRed() + (int) ((Math.random() - 0.5) * shiftAmount), 0, 255);
    int green = Math.clamp(col.getGreen() + (int) ((Math.random() - 0.5) * shiftAmount), 0, 255);
    int blue = Math.clamp(col.getBlue() + (int) ((Math.random() - 0.5) * shiftAmount), 0, 255);
    return new Color(red, green, blue);
  }

  public void crossGenome(int[][] other) {
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 4; j++) {
        if (Math.random() < 0.5) {
          genome[i][j] = other[i][j];
        }
      }
    }
  }

  @Override
  public void show(Renderer renderer, int cameraX) {
    renderer.noStroke();
    renderer.fill(Color.PINK);
    renderer.rect((x - cameraX) * gameManager.cellSize, y * gameManager.cellSize, gameManager.cellSize,
        gameManager.cellSize);
  }
}
