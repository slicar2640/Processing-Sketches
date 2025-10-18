class AnimationManager {
  ArrayList<Animation> animations = new ArrayList<>();
  int frame = 0;
  
  void removeAnimations(ArrayList<Animation> anims) {
    animations.removeAll(anims);
  }
  
  void removeAnimation(Animation anim) {
    animations.remove(anim);
  }
  
  void addAnimation(Animation anim) {
    animations.add(anim);
  }
  
  void setFrame(int f) {
    frame = f;
  }
  
  void update() {
    frame++;
    for(Animation anim : (ArrayList<Animation>)animations.clone()) {
      anim.update();
    }
  }
}
