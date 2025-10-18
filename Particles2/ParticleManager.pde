class ParticleManager { //<>//
  int particleCount;
  ArrayList<Float> posX = new ArrayList<>();
  ArrayList<Float> posY = new ArrayList<>();
  ArrayList<Float> velX = new ArrayList<>();
  ArrayList<Float> velY = new ArrayList<>();
  ArrayList<Float> accX = new ArrayList<>();
  ArrayList<Float> accY = new ArrayList<>();
  ArrayList<Integer> col = new ArrayList<>();

  float minDist = 20;
  float maxDist = 100;
  float invMinDist = 1 / minDist;
  float invMaxDist = 1 / maxDist;
  float middleDist = (minDist + maxDist) / 2;

  float attractStrength = 0.1;
  float repelStrength = 4;
  float friction = 2e-3;
  ParticleManager(int particleCount) {
    this.particleCount = particleCount;
    for (int i = 0; i < particleCount; i++) {
      posX.add(random(width));
      posY.add(random(height));
      velX.add(0.0);
      velY.add(0.0);
      accX.add(0.0);
      accY.add(0.0);
      col.add((int) random(colors.length));
    }
  }

  void update() {
    int numSubsteps = 10;
    for (int substep = 0; substep < numSubsteps; substep++) {
      for (int i = 0; i < particleCount; i++) {
        float x = posX.get(i);
        float y = posY.get(i);
        float ax = 0;
        float ay = 0;
        for (int j = 0; j < particleCount; j++) {
          if (i == j) continue;
          float x2 = posX.get(j);
          float y2 = posY.get(j);
          float invDist = invSqrt((x-x2)*(x-x2)+(y-y2)*(y-y2));
          if (invDist < invMaxDist) continue;
          float dis = dist(x, y, x2, y2);
          float force = dis < minDist ? repelStrength * (invMinDist * dis - 1) :
            dis < middleDist ? attractStrength / middleDist * (x - minDist) :
            dis < maxDist ? -attractStrength / middleDist * (x - maxDist) : 0;
          ax += attractStrength * (x2-x) * invDist * force * attractionMatrix[col.get(i)][col.get(j)];
          ay += attractStrength * (y2-y) * invDist * force * attractionMatrix[col.get(i)][col.get(j)];
          //ax += G * (x2-x) * invDist * invDist;
          //ay += G * (y2-y) * invDist * invDist;

          float invCenterDist = invSqrt((x - width / 2) * (x - width / 2) + (y - height / 2) * (y - height / 2));
          ax += 0.01 * (width / 2 - x) * invCenterDist;
          ay += 0.01 * (height / 2 - y) * invCenterDist;
        }
        accX.set(i, ax);
        accY.set(i, ay);
      }
      for (int i = 0; i < particleCount; i++) {
        posX.set(i, posX.get(i) + velX.get(i) / numSubsteps);
        posY.set(i, posY.get(i) + velY.get(i) / numSubsteps);
        velX.set(i, velX.get(i) + accX.get(i) / numSubsteps);
        velY.set(i, velY.get(i) + accY.get(i) / numSubsteps);
        velX = (ArrayList<Float>)velX.stream().map(e -> e * (1 - friction / numSubsteps)).collect(Collectors.toList());
        velY = (ArrayList<Float>)velY.stream().map(e -> e * (1 - friction / numSubsteps)).collect(Collectors.toList());
      }
    }
  }

  void show() {
    strokeWeight(4);
    for (int i = 0; i < particleCount; i++) {
      stroke(colors[col.get(i)]);
      point(posX.get(i), posY.get(i));
    }
  }
}
