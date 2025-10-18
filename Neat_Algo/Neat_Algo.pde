Neat neat;
ArrayList<Rocket> rockets = new ArrayList<>();
int countdown = 600;
PVector target;
float targetRadius = 10;
PWindow win;
void setup() {
  size(600, 600);
  win = new PWindow();
  target = new PVector(width / 3, height / 3);
  neat = new Neat(9, 2, 500);
  neat.mutateLinkProbability = 0.02;
  neat.mutateNodeProbability = 0.005;
  neat.mutateWeightShiftProbability = 0.2;
  neat.mutateWeightRandomProbability = 0.1;
  neat.survivorPercent = 0.3;

  for (Client c : neat.clients.getData()) {
    rockets.add(new Rocket(width / 2, height * 3 / 4, c));
  }

  //for (int inc = 0; inc < 600 * 10; inc++) {
  //  for (Rocket r : rockets) {
  //    r.update();
  //  }
  //  countdown--;
  //  if (countdown == 0) {
  //    countdown = 600;
  //    for (Rocket rocket : rockets) {
  //      if (!rocket.done) {
  //        rocket.client.setScore(1.4 * width / rocket.pos.dist(target));
  //      }
  //    }
  //    neat.evolve();
  //    rockets.clear();
  //    for (Client c : neat.clients.getData()) {
  //      rockets.add(new Rocket(width / 2, height * 3 / 4, c));
  //    }
  //    target.x = random(50, width - 50);
  //    target.y = random(50, height * 3 / 4 - 50);
  //  }
  //}
}

void draw() {
  for (int inc = 0; inc < (mousePressed ? 1 : 30); inc++) {
    background(0);
    fill(255, 0, 0);
    noStroke();
    circle(target.x, target.y, targetRadius * 2);
    boolean done = true;
    for (Rocket r : rockets) {
      r.update();
      done = done && r.done;
      r.show();
    }
    neat.calculateBestClient();
    neat.calculateBestSpecies();
    if(mousePressed) {
      neat.getBestClient().rocket.show(#FF0000);
      //neat.getBestSpecies().getRepresentative().rocket.show(#FFFF00);
    }
    if(done) countdown = 1;
    stroke(0, 255, 0);
    strokeWeight(8);
    line(0, height, countdown * width / 600, height);
    countdown--;
    if (countdown == 0) {
      countdown = 600;
      for (Rocket rocket : rockets) {
        if (!rocket.done) {
          rocket.client.setScore(1.4 * width / rocket.pos.dist(target));
        }
      }
      neat.evolve();
      rockets.clear();
      for (Client c : neat.clients.getData()) {
        rockets.add(new Rocket(width / 2, height * 3 / 4, c));
      }
      target.x = random(50, width - 50);
      target.y = random(50, height * 3 / 4 - 50);
    }
  }
}
