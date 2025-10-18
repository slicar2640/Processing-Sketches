class Cell {
  int x, y;
  int state;
  int energy = 0;
  Tree tree;
  World world;
  Cell parent;
  Cell(int x, int y, int state, Tree tree, World world) {
    this.x = x;
    this.y = y;
    this.state = state;
    this.tree = tree;
    this.world = world;
    world.collision[x][y] = -tree.id;
  }

  Cell(int x, int y, int state, Tree tree, Cell parent, World world) {
    this.x = x;
    this.y = y;
    this.state = state;
    this.tree = tree;
    this.world = world;
    world.collision[x][y] = -tree.id;
    this.parent = parent;
  }

  void grow() {
    int[] genomeSpot = tree.genome[state];
    int condition = genomeSpot[4];
    int parameter = genomeSpot[5];
    if (conditionMet(condition, parameter)) {
      if (genomeSpot[6] >= 16) {
        int command = genomeSpot[6] - 16;
        boolean cont = true;
        switch(command) {
        case 0:
          cont = false; //skip a turn
          break;
        case 1:
          retract();
          cont = false;
          break;
        case 2:
          becomeSeed();
          cont = false;
          break;
        }
        if (cont == false) {
          return;
        }
      }
    }

    int growCost = 0;
    for (int i = 0; i < 4; i++) {
      int growth = getGrowth(i);
      if (growth <= 15) growCost += 18;
    }

    if (energy < growCost) return;
    energy -= growCost;
    tree.energy += energy;
    energy = 0;
    for (int i = 0; i < 4; i++) {
      int growX = growDirections[i][0];
      int growY = growDirections[i][1];
      int newX = (x + growX + world.cols) % world.cols;
      int newY = y + growY;
      if (y + growY >= 0 && y + growY < world.rows) {
        if (world.collision[newX][newY] == 0) {
          int newState = getGrowth(i);
          if (newState > 15) continue;
          Cell newCell = new Cell(newX, newY, newState, tree, this, world);
          tree.ends.add(newCell);
        }
      }
    }
    tree.ends.remove(this);
    tree.body.add(this);
    world.collision[x][y] = tree.id;
  }

  int getGrowth(int dirIndex) {
    int[] genomeSpot = tree.genome[state];
    int condition = genomeSpot[4];
    int parameter = genomeSpot[5];
    if (conditionMet(condition, parameter)) {
      if (genomeSpot[6] < 16) {
        return tree.genome[genomeSpot[6]][dirIndex];
      } else {
        return 31;
      }
    } else {
      return genomeSpot[dirIndex];
    }
  }

  boolean conditionMet(int condition, int parameter) {
    if (condition > 18) return false;
    switch(condition) {
    case 0:
      return world.rows - y < parameter;
    case 1:
      return world.rows - y > parameter;
    case 2:
      return world.rows - y == parameter;
    case 3:
      return tree.body.size() + tree.ends.size() < parameter * 8;
    case 4:
      return tree.body.size() + tree.ends.size() > parameter * 8;
    case 5:
      return tree.body.size() + tree.ends.size() == parameter * 8;
    case 6:
      return tree.getHeight() < parameter;
    case 7:
      return tree.getHeight() > parameter;
    case 8:
      return tree.getHeight() == parameter;
    case 9:
      return tree.lifespan - tree.age < parameter * 2;
    case 10:
      return tree.lifespan - tree.age > parameter * 2;
    case 11:
      return tree.lifespan - tree.age == parameter * 2;
    case 12:
      return tree.energy < parameter * 100;
    case 13:
      return tree.energy > parameter * 100;
    case 14:
      return tree.energy == parameter * 100;
    case 15:
      return getEnergy() < parameter;
    case 16:
      return getEnergy() > parameter;
    case 17:
      return getEnergy() == parameter;
    case 18:
      return tree.turnSunEnergy < tree.turnBodyCost;
    }
    return false;
  }

  int cellsAbove() {
    int covers = 0;
    for (int i = 0; i < y; i++) {
      if (world.collision[x][i] != 0) {
        covers++;
      }
    }
    return covers;
  }

  int gapsAbove() {
    int gaps = 0;
    boolean started = false;
    for (int i = 0; i < y; i++) {
      if (world.collision[x][i] != 0) {
        started = true;
      } else {
        if (started == true) {
          gaps++;
        }
      }
    }
    return gaps;
  }

  int getEnergy() {
    int layers = world.getSun(x);
    int sun = 3;
    int covers = cellsAbove();
    int gaps = gapsAbove();
    if (covers >= layers) return 0;
    int mult = sun - covers + gaps;
    mult = constrain(mult, 0, sun);
    int nrg = (layers - covers) * mult;
    //int fogHeight = 5;
    //if(y >= world.rows - fogHeight) {
    //  nrg -= 10;
    //}
    return nrg;
  }

  void becomeSeed() {
    state = 0;
    Tree t = new Tree(x, y, tree.lifespan, tree.showColor, world, tree.genome);
    t.falling = true;
    t.mutate();
    world.trees.add(t);
    tree.ends.remove(this);
  }

  void retract() {
    tree.ends.remove(this);
    world.collision[x][y] = 0;
    tree.energy += energy / 2;
    if (parent != null) {
      tree.body.remove(parent);
      tree.ends.add(parent);
    }
  }
}
