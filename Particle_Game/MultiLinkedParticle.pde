class MultiLinkedParticle extends Particle {
  ArrayList<LinkableParticle> particles = new ArrayList<>();
  ArrayList<ArrayList<Stick>> sticks = new ArrayList<>();
  public MultiLinkedParticle(LinkedParticle p1, LinkableParticle p2) {
    super(p1.pos.x, p1.pos.y, p1.mass, p1.bucketIndex, p1.manager);
    particles.add(p1.p1);
    particles.add(p1.p2);
    particles.add(p2);
    sticks.add(p1.p1Sticks);
    sticks.add(p1.p2Sticks);
    manager.reconnectSticks(p1, this);
    sticks.add(manager.reconnectSticks(p2, this));
  }
  
  public void addParticle(LinkableParticle p) {
    particles.add(p);
    sticks.add(manager.reconnectSticks(p, this));
  }
}
