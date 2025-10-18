class Tree { //<>// //<>//
  ArrayList<Cell> body = new ArrayList<Cell>();
  ArrayList<Cell> ends = new ArrayList<Cell>();
  World world;
  int lifespan;
  int age = 0;
  int energy;
  boolean falling = false;
  color showColor;
  int[][] genome;
  int id;
  int turnSunEnergy, turnBodyCost;
  Tree(int x, int y, int life, color showColor, World world, int[][] genome) {
    this.genome = genome;
    Cell seed = new Cell(x, y, 0, this, world);
    ends.add(seed);
    this.world = world;
    energy = world.startEnergy;
    this.showColor = showColor;
    lifespan = life;
    id = world.nextId();
  }

  Tree(int x, int y, color showColor, World world) {
    genome = new int[16][7];
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 7; j++) {
        genome[i][j] = randomGenomeNumber(j);
      }
    }
    Cell seed = new Cell(x, y, 0, this, world);
    ends.add(seed);
    this.world = world;
    energy = world.startEnergy;
    this.showColor = showColor;
    lifespan = (int) random(world.lifespanMin, world.lifespanMax);
    id = world.nextId();
  }

  void update() {
    if (falling) {
      Cell seed = this.ends.get(0);
      if (seed.y == world.rows - 1) {
        falling = false;
      } else {
        if (world.collision[seed.x][seed.y + 1] == 0) {
          world.collision[seed.x][seed.y] = 0;
          seed.y++;
          world.collision[seed.x][seed.y] = -id;
        } else if (world.collision[seed.x][seed.y + 1] < 0) { //seed or offshoot
          die(true);
        } else { //body
          //die(true);
        }
      }
    } else {
      if (ends.size() == 0) {
        die();
        return;
      }
      turnSunEnergy = 0;
      for (Cell cell : body) {
        int nrg = cell.getEnergy();
        energy += nrg;
        turnSunEnergy += nrg;
      }
      for (Cell cell : ends) {
        int nrg = cell.getEnergy();
        cell.energy += nrg;
      }

      turnBodyCost = body.size() * 13;
      if (turnBodyCost <= energy) {
        energy -= turnBodyCost;
      } else {
        die(true);
        return;
      }

      //int energyPerEnd = (int) (energy / ends.size());

      for (Cell cell : (ArrayList<Cell>)ends.clone()) {
        //int given = min(energyPerEnd, max(0, cell.growCost - cell.energy));
        //cell.energy += given;
        //energy -= given;
        cell.grow();
      }

      age++;
      if (age == lifespan) {
        die();
      }
    }
  }

  void mutate() {
    //for (int i = 0; i < genome.length; i++) {
    //  if (random(100) < 5) {
    //    genome[i] = floor(random(32));
    //  }
    //}
    if (random(100) < 25) {
      int [][] newGenome = new int[genome.length][];
      for (int i = 0; i < genome.length; i++) {
        newGenome[i] = genome[i].clone();
      }
      genome = newGenome;

      int j = (int) random(7);
      genome[(int) random(16)][j] = randomGenomeNumber(j);
      showColor = color((hue(showColor) + random(-40, 40) + 360) % 360, 90, 100);
      lifespan += round(random(-2, 2));
      lifespan = constrain(lifespan, world.lifespanMin, world.lifespanMax);
    }
  }

  int randomGenomeNumber(int j) {
    return (int) random(j < 4 ? 32 : j < 6 ? 64 : (16 + 1)); // 3 commands -drop seed -retract
  }

  int getHeight() {
    int minY = 0;
    for (Cell cell : body) {
      if (cell.y < minY) minY = cell.y;
    }
    return world.rows - 1 - minY;
  }

  void die() {
    die(false);
  }

  void die(boolean deleteSeeds) {
    if (deleteSeeds == false) {
      ArrayList<Tree> newTrees = new ArrayList<Tree>();
      for (Cell cell : ends) {
        cell.state = 0;
        Tree t = new Tree(cell.x, cell.y, lifespan, showColor, world, genome);
        t.falling = true;
        t.mutate();
        newTrees.add(t);
      }
      world.trees.addAll(newTrees);
    }
    world.trees.remove(this);
    for (Cell cell : body) {
      world.collision[cell.x][cell.y] = 0;
    }
  }

  void show() {
    stroke(darken(showColor));
    strokeWeight(1);
    fill(showColor);
    for (Cell c : body) {
      if (world.isInScreen(c.x)) {
        rect(((c.x - world.screenX + world.cols) % world.cols) * world.cellSize, c.y * world.cellSize, world.cellSize, world.cellSize);
      }
    }
    stroke(0, 0, 80);
    fill(0, 0, 100);
    for (Cell c : ends) {
      if (world.isInScreen(c.x)) {
        rect(((c.x - world.screenX + world.cols) % world.cols) * world.cellSize, c.y * world.cellSize, world.cellSize, world.cellSize);
      }
    }
  }

  String genomeString() {
    return Arrays.deepToString(genome);
  }
}
