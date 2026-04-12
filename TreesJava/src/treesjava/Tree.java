package treesjava;

import java.awt.Color;
import java.util.ArrayList;

public class Tree {
  public GameManager gameManager;
  private int energy;
  private int age;
  private int maxAge;
  public int[][] genome;
  public ArrayList<Stem> stems;
  public ArrayList<Offshoot> offshoots;
  public Color color;
  public boolean selected;

  public Tree(Seed seed) {
    gameManager = seed.gameManager;
    energy = gameManager.startEnergy;
    age = 0;
    maxAge = (int) (Math.random() * gameManager.ageLowerBound)
        + (gameManager.ageUpperBound - gameManager.ageLowerBound);
    genome = seed.genome;
    stems = new ArrayList<>();
    offshoots = new ArrayList<>();
    color = seed.color;
    Offshoot offshoot = new Offshoot(seed.x, seed.y, 0, this);
    offshoots.add(offshoot);
    gameManager.grid[seed.x + seed.y * gameManager.width] = offshoot;
    gameManager.seeds.remove(seed);
  }

  public void updateEnergyAndAge() {
    age++;
    energy -= (stems.size() + offshoots.size()) * gameManager.costPerCell;
    for (Stem stem : stems) {
      energy += gameManager.sunEnergy(stem);
    }
    for (Offshoot offshoot : offshoots) {
      offshoot.updateEnergy();
    }
  }

  public boolean isDead() {
    return age > maxAge || energy < 0;
  }

  public String reasonForDeath() {
    return age > maxAge ? "Age" : energy < 0 ? "Energy" : "Unknown";
  }

  public void die() {
    for (Stem stem : stems) {
      gameManager.grid[stem.x + stem.y * gameManager.width] = null;
    }
    for (Offshoot offshoot : offshoots) {
      Seed seed = new Seed(offshoot);
      gameManager.seeds.add(seed);
      gameManager.grid[offshoot.x + offshoot.y * gameManager.width] = seed;
    }
  }

  public void growOffshoots() {
    for (Offshoot offshoot : new ArrayList<>(offshoots)) {
      offshoot.grow();
    }
  }
}
