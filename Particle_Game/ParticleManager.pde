import java.lang.reflect.Constructor;
import java.util.Iterator;

class ParticleManager {
  private ArrayList<HashSet<Particle>> buckets = new ArrayList<>();
  private ArrayList<HashSet<Particle>> neighborBuckets = new ArrayList<>();
  private HashSet<Stick> sticks = new HashSet<>();
  public ArrayList<Particle> particlesToRemove = new ArrayList<>();
  public ArrayList<Particle> particlesToAdd = new ArrayList<>();
  public ArrayList<Stick> sticksToRemove = new ArrayList<>();
  private int cols, rows;
  private float bucketSize;
  public int numParticles;
  private float repelStrength = 0.25;
  private float repelDist;

  public ParticleManager(int num, float repelDist) {
    numParticles = num;
    this.repelDist = repelDist;
    bucketSize = repelDist * 2;
    cols = floor(width / bucketSize);
    rows = floor(height / bucketSize);
    for (int i = 0; i < cols * rows; i++) {
      buckets.add(new HashSet<>());
    }
    for (int i = 0; i < num; i++) {
      addParticle(random(width), random(height));
    }
  }

  public void update(float dt) {
    repelNeighbors();
    updateSticks();
    updateParticles(dt);
    checkForChangedBuckets();
  }

  public void update(float timestep, int substeps) {
    for (int i = 0; i < substeps; i++) {
      update(timestep / substeps);
    }
  }

  private void updateParticles(float dt) {
    for (HashSet<Particle> bucket : buckets) {
      for (Particle particle : bucket) {
        particle.update(dt);
      }
    }
  }

  private void updateSticks() {
    for (Stick stick : sticks) {
      stick.update();
    }
    sticks.removeAll(sticksToRemove);
    sticksToRemove.clear();
  }

  private void checkForChangedBuckets() {
    ArrayList<ArrayList<Particle>> toRemove = new ArrayList<>();
    for (int i = 0; i < buckets.size(); i++) {
      HashSet<Particle> bucket = buckets.get(i);
      toRemove.add(new ArrayList<>());
      for (Particle particle : bucket) {
        int bucketColumn = particle.bucketIndex % cols;
        int bucketRow = floor(particle.bucketIndex / cols);
        if (particle.isOutsideBox(bucketColumn * bucketSize, bucketRow * bucketSize, bucketSize)) {
          int newCol = constrain(floor(particle.pos.x / bucketSize), 0, cols - 1);
          int newRow = constrain(floor(particle.pos.y / bucketSize), 0, rows - 1);
          toRemove.get(i).add(particle);
          particle.bucketIndex = newCol + newRow * cols;
        }
      }
    }
    for (int i = 0; i < buckets.size(); i++) {
      ArrayList<Particle> removedFromBucket = toRemove.get(i);
      for (Particle particle : removedFromBucket) {
        buckets.get(i).remove(particle);
        buckets.get(particle.bucketIndex).add(particle);
      }
    }
  }

  private void repelNeighbors() {
    neighborBuckets.clear();
    for (HashSet<Particle> bucket : buckets) {
      for (Particle particle : bucket) {
        HashSet<Particle> neighbors = neighborParticles(particle.pos.x, particle.pos.y);
        for (Particle other : neighbors) {
          particle.repelFrom(other);
        }
      }
    }
    removeParticles(particlesToRemove);
    particlesToRemove.clear();
    addParticles(particlesToAdd);
    particlesToAdd.clear();
  }

  public HashSet<Particle> neighborParticles(float x, float y) {
    x = constrain(x, 0, width - 1);
    y = constrain(y, 0, height - 1);
    int leftCol = (int)((x - bucketSize / 2) / bucketSize);
    int topRow = (int)((y - bucketSize / 2) / bucketSize);
    int neighborBucketIndex = leftCol + 1 + (topRow + 1) * cols;
    if (neighborBuckets.size() > neighborBucketIndex && neighborBuckets.get(neighborBucketIndex) != null) {
      return neighborBuckets.get(neighborBucketIndex);
    }
    HashSet<Particle> neighbors = new HashSet<>();
    for (int col = max(0, leftCol); col <= min(leftCol + 1, cols - 1); col++) {
      for (int row = max(0, topRow); row <= min(topRow + 1, rows - 1); row++) {
        int index = col + row * cols;
        neighbors.addAll(buckets.get(index));
      }
    }
    if (neighborBuckets.size() > neighborBucketIndex) {
      neighborBuckets.set(neighborBucketIndex, neighbors);
    } else {
      for (int i = neighborBuckets.size(); i < neighborBucketIndex; i++) {
        neighborBuckets.add(null);
      }
      neighborBuckets.add(neighbors);
    }
    return neighbors;
  }

  public HashSet<Particle> getAllParticles() {
    HashSet<Particle> particles = new HashSet<>();
    for (HashSet<Particle> bucket : buckets) {
      particles.addAll(bucket);
    }
    return particles;
  }

  public HashSet<Particle> getParticlesInRange(float x1, float y1, float x2, float y2) {
    HashSet<Particle> particles = new HashSet<>();
    int minX = constrain((int)(x1/bucketSize), 0, cols - 1);
    int maxX = constrain((int)(x2/bucketSize), 0, cols - 1);
    int minY = constrain((int)(y1/bucketSize), 0, rows - 1);
    int maxY = constrain((int)(y2/bucketSize), 0, rows - 1);
    for (int i = minX; i <= maxX; i++) {
      for (int j = minY; j <= maxY; j++) {
        int index = i + j * cols;
        particles.addAll(buckets.get(index));
      }
    }
    return particles;
  }

  public Particle randomParticle() {
    if (numParticles == 0) return null;
    HashSet allParts = getAllParticles();
    int index = (int)(random(allParts.size()));
    Iterator<Object> iter = allParts.iterator();
    for (int i = 0; i < index; i++) {
      iter.next();
    }
    return (Particle)iter.next();
  }

  public Stick addStick(Stick s) {
    sticks.add(s);
    return s;
  }

  public int numSticks() {
    return sticks.size();
  }

  public Particle addParticle(Particle p) {
    buckets.get(p.bucketIndex).add(p);
    numParticles++;
    return p;
  }

  public <T extends Particle> T addParticle(float x, float y, float mass, Class<T> clazz) throws ReflectiveOperationException {
    int index = getBucketIndex(x, y);
    Constructor<T> constructor = clazz.getConstructor(Particle_Game.class, float.class, float.class, float.class, int.class, getClass());
    T p = constructor.newInstance(Particle_Game.this, x, y, mass, index, this);
    addParticle(p);
    return p;
  }

  public Particle addParticle(float x, float y, float mass) {
    int index = getBucketIndex(x, y);
    Particle p = new Particle(x, y, mass, index, this);
    return addParticle(p);
  }

  public Particle addParticle(float x, float y) {
    return addParticle(x, y, 1);
  }

  public Particle addParticle(PVector p) {
    return addParticle(p.x, p.y);
  }

  public void addParticles(ArrayList<Particle> parts) {
    for (Particle p : parts) {
      buckets.get(p.bucketIndex).add(p);
      numParticles++;
    }
  }

  public void addLoop(float cx, float cy, float radius, int count) {
    Particle first = addParticle(cx + radius, cy);
    Particle last = first;
    for (int i = 1; i < count; i++) {
      float x = cx + radius * cos((float)i / count * TWO_PI);
      float y = cy + radius * sin((float)i / count * TWO_PI);
      Particle p = addParticle(x, y);
      addStick(new Stick(last, p, -1, 1));
      last = p;
    }
    addStick(new Stick(last, first));
  }

  public void addTriangle(float x, float y, int sideCount, float spacing, float stiffness) {
    float yOff = -spacing * (sideCount - 1) * SQRT3_2 * 2 / 3;
    Particle[][] parts = new Particle[sideCount][];
    parts[0] = new Particle[1];
    parts[0][0] = addParticle(x, y + yOff);
    for (int i = 1; i < sideCount; i++) {
      parts[i] = new Particle[i + 1];
      for (int j = 0; j <= i; j++) {
        float x0 = x + ((float) -i / 2 + j) * spacing;
        float y0 = y + yOff + i * SQRT3_2 * spacing;
        parts[i][j] = addParticle(x0, y0);
      }
      for (int k = 0; k < i; k++) {
        Particle top = parts[i - 1][k];
        Particle left = parts[i][k];
        Particle right = parts[i][k + 1];
        addStick(new Stick(top, left, spacing, stiffness));
        addStick(new Stick(top, right, spacing, stiffness));
        addStick(new Stick(left, right, spacing, stiffness));
      }
    }
  }

  public void addRectangle(float ox, float oy, int widthCount, int heightCount, float spacing, float stiffness, float mass, boolean centered) {
    float xOff = centered ? -(widthCount - 1) * spacing / 2 : 0;
    float yOff = centered ? -(heightCount - 1) * spacing * SQRT3_2 / 2 : 0;
    Particle[][] parts = new Particle[heightCount][];
    for (int i = 0; i < heightCount; i++) {
      parts[i] = new Particle[widthCount - ((i + 1) % 2)];
      for (int j = 0; j < widthCount - ((i + 1) % 2); j++) {
        float x = ox + xOff + (((i + 1) % 2) * 0.5 + j) * spacing;
        float y = oy + yOff + i * SQRT3_2 * spacing;
        parts[i][j] = addParticle(x, y, mass);
        if (j > 0) {
          addStick(new Stick(parts[i][j - 1], parts[i][j], spacing, stiffness));
        }
        if (i > 0) {
          if (i % 2 == 0) {
            addStick(new Stick(parts[i - 1][j], parts[i][j], spacing, stiffness));
            addStick(new Stick(parts[i - 1][j + 1], parts[i][j], spacing, stiffness));
          } else {
            if (j > 0) {
              addStick(new Stick(parts[i - 1][j - 1], parts[i][j], spacing, stiffness));
            }
            if (j < widthCount - 1) {
              addStick(new Stick(parts[i - 1][j], parts[i][j], spacing, stiffness));
            }
          }
        }
      }
    }
  }

  public void addClassicRectangle(float ox, float oy, int widthCount, int heightCount, float spacing, float stiffness, float mass, boolean centered) {
    float xOff = centered ? -(widthCount - 1) * spacing / 2 : 0;
    float yOff = centered ? -(heightCount - 1) * spacing / 2 : 0;
    Particle[][] parts = new Particle[heightCount][widthCount];
    for (int i = 0; i < heightCount; i++) {
      for (int j = 0; j < widthCount; j++) {
        float x = ox + xOff + j * spacing;
        float y = oy + yOff + i * spacing;
        parts[i][j] = addParticle(x, y, mass);
        if (j > 0) {
          addStick(new Stick(parts[i][j - 1], parts[i][j], spacing, stiffness));
        }
        if (i > 0) {
          addStick(new Stick(parts[i - 1][j], parts[i][j], spacing, stiffness));
          if (j > 0) {
            addStick(new Stick(parts[i - 1][j - 1], parts[i][j], spacing * SQRT2, stiffness));
          }
        }
      }
    }
  }

  public void addWall(float x1, float y1, float x2, float y2) {
    Particle p1 = addParticle(x1, y1);
    p1.isStatic = true;
    Particle p2 = addParticle(x2, y2);
    p2.isStatic = true;
    Stick stick = new WallStick(p1, p2);
    sticks.add(stick);
  }

  public void subdivideStick(Stick initial) {
    sticks.remove(initial);
    Particle mid = addParticle(PVector.lerp(initial.p1.pos, initial.p2.pos, 0.5));
    addStick(new Stick(initial.p1, mid, initial.restLength / 2, initial.stiffness));
    addStick(new Stick(mid, initial.p2, initial.restLength / 2, initial.stiffness));
  }

  public ArrayList<Stick> reconnectSticks(Particle oldP, Particle newP) {
    ArrayList<Stick> reconnected = new ArrayList<>();
    for (Stick stick : sticks) {
      boolean didReconnect = false;
      if (stick.p1 == oldP) {
        stick.p1 = newP;
        didReconnect = true;
      }
      if (stick.p2 == oldP) {
        stick.p2 = newP;
        didReconnect = true;
      }
      if (didReconnect) {
        reconnected.add(stick);
      }
    }
    return reconnected;
  }

  public void removeParticle(Particle p) {
    buckets.get(p.bucketIndex).remove(p);
    numParticles--;
    for (Stick stick : sticks) {
      if (stick.p1 == p || stick.p2 == p) {
        sticksToRemove.add(stick);
      }
    }
    sticks.removeAll(sticksToRemove);
  }

  public void removeParticles(ArrayList<Particle> parts) {
    for (Particle p : parts) {
      buckets.get(p.bucketIndex).remove(p);
      numParticles--;
    }
    for (Stick stick : sticks) {
      for (Particle p : parts) {
        if (p == stick.p1 || p == stick.p2) {
          sticksToRemove.add(stick);
        }
      }
    }
    sticks.removeAll(sticksToRemove);
  }

  int getBucketIndex(float x, float y) {
    int col = constrain(floor(x / bucketSize), 0, cols - 1);
    int row = constrain(floor(y / bucketSize), 0, rows - 1);
    return col + row * cols;
  }

  public void show() {
    for (Stick stick : sticks) {
      stick.show();
    }
    for (HashSet<Particle> bucket : buckets) {
      for (Particle particle : bucket) {
        particle.show();
      }
    }
    //GRIDLINES
    //stroke(100);
    //strokeWeight(1);
    //for(float i = 0; i < width; i += bucketSize) {
    //  line(i, 0, i, height);
    //}
    //for(float i = 0; i < height; i += bucketSize) {
    //  line(0, i, width, i);
    //}

    //int mouseCol = constrain(floor(mouseX / bucketSize), 0, cols - 1);
    //int mouseRow = constrain(floor(mouseY / bucketSize), 0, rows - 1);
    //int index = mouseCol + mouseRow * rows;
    //stroke(255, 0, 255);
    //strokeWeight(4);
    //for(Particle p : buckets.get(index)) {
    //  point(p.pos.x, p.pos.y);
    //}

    //stroke(0, 255, 0);
    //strokeWeight(4);
    //ArrayList<Particle> neighbors = neighborParticles(mouseX, mouseY);
    //for(Particle p : neighbors) {
    //  point(p.pos.x, p.pos.y);
    //}
    //strokeWeight(1);
    //noFill();
    //rect(mouseCol * bucketSize, mouseRow * bucketSize, bucketSize, bucketSize);
    //ellipse(mouseX, mouseY, bucketSize, bucketSize);
  }
}
