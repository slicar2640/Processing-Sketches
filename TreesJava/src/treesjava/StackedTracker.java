package treesjava;

import java.awt.Color;
import java.awt.geom.Path2D;
import java.util.ArrayList;

public class StackedTracker extends Widget {
  private ArrayList<String> names;
  private ArrayList<ArrayList<Integer>> values;
  private ArrayList<Integer> maxValues;
  private ArrayList<Integer> binCounts;
  private int binSize;
  private ArrayList<Color> colors;

  public StackedTracker(GameManager gameManager, int binSize) {
    this.gameManager = gameManager;
    this.binSize = binSize;
    names = new ArrayList<>();
    values = new ArrayList<>();
    maxValues = new ArrayList<>();
    binCounts = new ArrayList<>();
    colors = new ArrayList<>();
  }

  public void addCategory(String name, Color color) {
    names.add(name);
    values.add(new ArrayList<>());
    values.getLast().add(0);
    maxValues.add(0);
    binCounts.add(0);
    colors.add(color);
  }

  protected void draw() {
    int width = getWidth();
    int height = getHeight();
    graphics.setPaint(Color.BLACK);
    graphics.fillRect(0, 0, width, height);
    ArrayList<Color> colorsCopy;
    ArrayList<ArrayList<Integer>> valuesCopy;
    int maxHeight = 0;
    synchronized (values) {
      colorsCopy = new ArrayList<>(colors);
      valuesCopy = new ArrayList<ArrayList<Integer>>();
      for (int i = 0; i < values.size(); i++) {
        valuesCopy.add(new ArrayList<>(values.get(i)));
        maxHeight += maxValues.get(i);
      }
    }
    maxHeight = Math.max(1, maxHeight);
    ArrayList<Integer> runningSums = new ArrayList<>();
    for (int i = 0; i < valuesCopy.get(0).size(); i++) {
      runningSums.add(0);
    }
    ArrayList<Path2D> paths = new ArrayList<>();
    for (int category = 0; category < valuesCopy.size(); category++) {
      Path2D path = new Path2D.Float();
      paths.add(path);
      ArrayList<Integer> amounts = valuesCopy.get(category);
      path.moveTo(0, height);
      for (int i = 0; i < amounts.size(); i++) {
        runningSums.set(i, runningSums.get(i) + amounts.get(i));
        path.lineTo((float) i / (amounts.size() - 1) * width,
            (float) (maxHeight - runningSums.get(i)) / maxHeight * height);
      }
      path.lineTo(width, height);
    }
    for (int i = paths.size() - 1; i >= 0; i--) {
      graphics.setPaint(colorsCopy.get(i));
      graphics.fill(paths.get(i));
    }
  }

  public void addEntry(String category, int value) {
    synchronized (values) {
      int index = names.indexOf(category);
      if (index >= 0) {
        values.get(index).set(values.get(index).size() - 1, values.get(index).getLast() + value);
        binCounts.set(index, binCounts.get(index) + 1);
        if (binCounts.get(index) == binSize) {
          if (values.get(index).getLast() > maxValues.get(index)) {
            maxValues.set(index, values.get(index).getLast());
          }
          values.get(index).add(0);
          binCounts.set(index, 0);
        }
      }
    }
  }
}
