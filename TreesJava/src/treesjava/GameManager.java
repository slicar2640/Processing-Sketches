package treesjava;

import java.awt.Color;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.ArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.swing.JFrame;

public class GameManager implements MouseListener, MouseMotionListener, KeyListener {
  public final int maxCellsAbove = 2;
  public final int groundEnergy = 6;
  public final int costPerCell = 13;
  public final int costToGrow = 18;
  public final float mutateChance = 0.25f;
  public final float crossChance = 0.1f;
  public final int startEnergy = 500;
  public final int ageLowerBound = 80;
  public final int ageUpperBound = 90;
  public final int numResetSeeds = 3;

  private ScheduledExecutorService schedule;
  private int targetFPS = 60;
  public int frameCount = 0;
  public float frameRate;
  public long lastFrameTime = 0;

  public int width, height, cameraWidth, cellSize;
  private int cameraX;
  private int mouseDownX, mouseDownCameraX;
  private boolean paused = false;

  public Renderer renderer;
  public Cell[] grid;
  public ArrayList<Tree> trees;
  public ArrayList<Seed> seeds;

  public StackedTracker deathTracker;

  private Tree selectedTree;

  public GameManager(int width, int height, int cellSize, int cameraWidth, boolean centerCamera) {
    renderer = new Renderer(cameraWidth * cellSize, height * cellSize, this);
    renderer.addMouseListener(this);
    renderer.addMouseMotionListener(this);
    renderer.addKeyListener(this);
    this.width = width;
    this.height = height;
    this.cameraWidth = cameraWidth;
    this.cellSize = cellSize;
    cameraX = centerCamera ? (int) (width / 2f - cameraWidth / 2f) : 0;
    grid = new Cell[width * height];
    trees = new ArrayList<>();
    seeds = new ArrayList<>();
    deathTracker = new StackedTracker(this, 5);
    deathTracker.addCategory("Age", Color.RED);
    deathTracker.addCategory("Energy", Color.YELLOW);
  }

  public void start() {
    schedule = Executors.newSingleThreadScheduledExecutor();
    schedule.scheduleAtFixedRate(this::run, 0, 1000 / targetFPS, TimeUnit.MILLISECONDS);
    lastFrameTime = System.currentTimeMillis();
  }

  public void run() {
    if (!paused) {
      updateTreeEnergies();
      growCells();
      fallSeeds();
      removeDeadTrees();
    }
    renderer.render();
    frameCount++;
    long elapsedMillis = System.currentTimeMillis() - lastFrameTime;
    frameRate = 1000f / elapsedMillis;
    lastFrameTime = System.currentTimeMillis();
  }

  private void growCells() {
    for (Tree tree : trees) {
      tree.growOffshoots();
    }
  }

  private void fallSeeds() {
    for (Seed seed : new ArrayList<>(seeds)) {
      seed.fall();
    }
  }

  private void updateTreeEnergies() {
    for (Tree tree : trees) {
      tree.updateEnergyAndAge();
    }
  }

  private void removeDeadTrees() {
    ArrayList<Tree> deadTrees = new ArrayList<>();
    int ageDeaths = 0;
    int energyDeaths = 0;
    for (Tree tree : trees) {
      if (tree.isDead()) {
        deadTrees.add(tree);
        switch (tree.reasonForDeath()) {
          case "Age":
            ageDeaths++;
            break;
          case "Energy":
            energyDeaths++;
            break;
        }
      }
    }
    if (deadTrees.size() > 0) {
      deathTracker.addEntry("Age", ageDeaths);
      deathTracker.addEntry("Energy", energyDeaths);
    }
    for (Tree tree : deadTrees) {
      tree.die();
    }
    trees.removeAll(deadTrees);
    if (trees.isEmpty() && seeds.isEmpty()) {
      for (int i = 1; i < numResetSeeds + 1; i++) {
        addRandomSeed((int) ((float) i / (numResetSeeds + 1) * width), height / 2);
      }
    }
  }

  public void addSeed(int x, int y, int[][] genome) {
    Seed seed = new Seed(x, y, this, genome);
    seeds.add(seed);
    grid[x + y * width] = seed;
  }

  public void addSeed(int x, int y, int[][] genome, Color color) {
    Seed seed = new Seed(x, y, this, genome, color);
    seeds.add(seed);
    grid[x + y * width] = seed;
  }

  public void addRandomSeed(int x, int y) {
    int[][] genome = new int[16][4];
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 4; j++) {
        genome[i][j] = (int) (Math.random() * 32);
      }
    }
    addSeed(x, y, genome, Color.getHSBColor((float) Math.random(), 0.8f, 1f));
  }

  public int sunEnergy(Cell cell) {
    int cellsAbove = 0;
    for (int i = cell.y - 1; i >= 0; i--) {
      if (grid[i * width + cell.x] != null || grid[i * width + cell.x] instanceof Seed) {
        cellsAbove++;
      }
      if (cellsAbove > maxCellsAbove) {
        return 0;
      }
    }
    return (1 + maxCellsAbove - cellsAbove) * (groundEnergy + height - cell.y);
  }

  public void drawGrid() {
    for (int y = 0; y < height; y++) {
      for (int x = cameraX; x < Math.min(cameraX + cameraWidth, width); x++) {
        if (grid[x + y * width] != null) {
          grid[x + y * width].show(renderer, cameraX);
        }
      }
      for (int x = width; x < cameraX + cameraWidth; x++) {
        if (grid[x - width + y * width] != null) {
          grid[x - width + y * width].show(renderer, cameraX - width);
        }
      }
    }
  }

  public void drawCameraBar() {
    renderer.stroke(new Color(1, 1, 1, 0.5f));
    renderer.strokeWeight(4);
    renderer.line((float) cameraX / width * renderer.width, 6, (float) (cameraX + cameraWidth) / width * renderer.width,
        6);
    renderer.line((float) (cameraX - width) / width * renderer.width, 6,
        (float) (cameraX + cameraWidth - width) / width * renderer.width, 6);
  }

  private void selectTree(Tree tree) {
    selectedTree = tree;
    tree.selected = true;
  }

  private void deselectTree() {
    if (selectedTree != null) {
      selectedTree.selected = false;
      selectedTree = null;
    }
  }

  private void openTreeInspector() {
    if (selectedTree != null) {
      JFrame frame = renderer.getFrame();
      new TreeInspector(selectedTree).openWindow(frame.getX() + frame.getWidth(),
          frame.getY() - 32, 400, frame.getHeight());
    }
  }

  @Override
  public void mousePressed(MouseEvent e) {
    deselectTree();
    if (e.isControlDown()) {
      int mouseCellX = cameraX + (int) (e.getX() / cellSize);
      int mouseCellY = (int) (e.getY() / cellSize);
      Cell cell = grid[mouseCellX + mouseCellY * width];
      if (cell != null) {
        Tree tree = switch (cell) {
          case Stem stem -> stem.tree;
          case Offshoot offshoot -> offshoot.tree;
          default -> null;
        };
        if (tree != null) {
          selectTree(tree);
        }
      }
    }
    mouseDownX = e.getX();
    mouseDownCameraX = cameraX;
  }

  @Override
  public void mouseDragged(MouseEvent e) {
    cameraX = mouseDownCameraX - (e.getX() - mouseDownX) / cellSize;
    while (cameraX < 0) {
      cameraX += width;
    }
    cameraX %= width;
  }

  @Override
  public void keyPressed(KeyEvent e) {
    if (e.getKeyChar() == ' ') {
      paused = !paused;
    } else if (e.getKeyCode() == KeyEvent.VK_T && e.isControlDown()) {
      JFrame frame = renderer.getFrame();
      deathTracker.openWindow(frame.getX(),
          frame.getY() + frame.getHeight(), frame.getWidth(), 200);
    } else if (e.getKeyCode() == KeyEvent.VK_I && e.isControlDown()) {
      openTreeInspector();
    }
  }

  @Override
  public void mouseMoved(MouseEvent e) {
  }

  @Override
  public void mouseClicked(MouseEvent e) {
  }

  @Override
  public void mouseReleased(MouseEvent e) {
  }

  @Override
  public void mouseEntered(MouseEvent e) {
  }

  @Override
  public void mouseExited(MouseEvent e) {
  }

  @Override
  public void keyTyped(KeyEvent e) {
  }

  @Override
  public void keyReleased(KeyEvent e) {
  }
}
