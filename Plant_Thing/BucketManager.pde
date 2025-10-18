class BucketManager {
  ArrayList<ArrayList<ArrayList<Particle>>> buckets;
  ArrayList<Particle> particles = new ArrayList<Particle>();
  int cols, rows;
  float bucketSize;
  BucketManager(int cols, int rows, float s) {
    this.cols = cols;
    this.rows = rows;
    bucketSize = s;

    buckets = new ArrayList<ArrayList<ArrayList<Particle>>>();
    for (int i = 0; i < cols; i++) {
      ArrayList<ArrayList<Particle>> col = new ArrayList<ArrayList<Particle>>();
      for (int j = 0; j < rows; j++) {
        ArrayList<Particle> bucket = new ArrayList<Particle>();
        col.add(bucket);
      }
      buckets.add(col);
    }
  }

  void add(Particle p) {
    int[] bucket = bucketAt(p.pos);
    if (!particles.contains(p)) {
      p.addTo(getBucket(bucket[0], bucket[1]));
      p.addTo(particles);
    }
    p.bucketX = bucket[0];
    p.bucketY = bucket[1];
  }

  void addAll(ArrayList<Particle> parts) {
    for (Particle p : parts) {
      int[] bucket = bucketAt(p.pos);
      p.addTo(getBucket(bucket[0], bucket[1]));
      p.addTo(particles);
      p.bucketX = bucket[0];
      p.bucketY = bucket[1];
    }
  }

  void remove(Particle p) {
    p.removeFrom(getBucket(p.bucketX, p.bucketY));
    p.removeFrom(particles);
    p.bucketX = -1;
    p.bucketY = -1;
  }

  ArrayList<Particle> getBucket(int col, int row) {
    return buckets.get(col).get(row);
  }

  ArrayList<Particle> getNeighborhood(int col, int row) {
    ArrayList<Particle> neighborhood = new ArrayList<Particle>();
    for (int i = max(0, col - 1); i <= min(col + 1, cols - 1); i++) {
      for (int j = max(0, row - 1); j <= min(row + 1, rows - 1); j++) {
        neighborhood.addAll(getBucket(i, j));
      }
    }
    return neighborhood;
  }

  int[] bucketAt(float x, float y) {
    int col = constrain(floor(x / bucketSize), 0, cols - 1);
    int row = constrain(floor(y / bucketSize), 0, rows - 1);
    int[] ret = {col, row};
    return ret;
  }

  int[] bucketAt(PVector pos) {
    int col = constrain(floor(pos.x / bucketSize), 0, cols - 1);
    int row = constrain(floor(pos.y / bucketSize), 0, rows - 1);
    int[] ret = {col, row};
    return ret;
  }

  PVector bucketPos(int col, int row) {
    return new PVector(col * bucketSize, row * bucketSize);
  }
  
  boolean isBucket(ArrayList<Particle> arr) {
    for(ArrayList<ArrayList<Particle>> col : buckets) {
      if(col.contains(arr)) return true;
    }
    return false;
  }

  void updateBuckets() {
    for (Particle p : particles) {
      int[] newBucket = bucketAt(p.pos);
      if (p.bucketX != newBucket[0] || p.bucketY != newBucket[1]) {
        p.removeFrom(getBucket(p.bucketX, p.bucketY));
        p.addTo(getBucket(newBucket[0], newBucket[1]));
        p.bucketX = newBucket[0];
        p.bucketY = newBucket[1];
      }
    }
  }

  void update(float dt) {
    for (int i = 0; i < cols; i++) {
      ArrayList<ArrayList<Particle>> col = buckets.get(i);
      for (int j = 0; j < rows; j++) {
        ArrayList<Particle> bucket = col.get(j);
        ArrayList<Particle> neighborhood = getNeighborhood(i, j);
        for (Particle p : bucket) {
          p.attract();
          p.update(neighborhood, dt);
        }
      }
    }
    updateBuckets();
  }

  void show() {
    for (int i = 0; i < cols; i++) {
      ArrayList<ArrayList<Particle>> col = buckets.get(i);
      for (int j = 0; j < rows; j++) {
        ArrayList<Particle> bucket = col.get(j);
        for (Particle p : bucket) {
          p.show();
        }
      }
    }
  }

  void showHidden() {
    for (int i = 0; i < cols; i++) {
      ArrayList<ArrayList<Particle>> col = buckets.get(i);
      for (int j = 0; j < rows; j++) {
        ArrayList<Particle> bucket = col.get(j);
        for (Particle p : bucket) {
          if (p.doShow == false) {
            p.show(color(255, 50));
          }
        }
      }
    }
  }
}
