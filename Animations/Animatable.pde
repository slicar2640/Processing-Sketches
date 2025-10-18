abstract class Animatable {
  AnimationManager manager;
  ArrayList<Animation> animations;
  
  Animatable(AnimationManager manager) {
    animations = new ArrayList<>();
    this.manager = manager;
  }
  
  void clearAnimations() {
    manager.removeAnimations(animations);
    animations.clear();
  }
  
  void animate(Animation anim) {
    animations.add(anim);
    manager.addAnimation(anim);
  }
  
  int firstFrame() {
    int first = 100000;
    for(Animation anim : animations) {
      if(anim.startFrame < first) first = anim.startFrame;
    }
    return first;
  }
  
  int lastFrame() {
    int last = 0;
    for(Animation anim : animations) {
      if(anim.endFrame > last) last = anim.endFrame;
    }
    return last;
  }
}

class Rectangle extends Animatable {
  float x, y;
  float w, h;
  PVector fillColor = new PVector(255, 255, 255);
  PVector strokeColor = new PVector(0, 0, 0);
  float strokeWeight = 1;
  Rectangle(float x, float y, float w, float h, AnimationManager manager) {
    super(manager);
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  Animation animate(String prop, int startF, int endF, float startV, float endV, EasingFunction easingFunc) {
    Consumer<Float> setter;
    switch(prop) {
      case "x":
        setter = this::setX;
        break;
      case "y":
        setter = this::setY;
        break;
      case "w":
        setter = this::setW;
        break;
      case "h":
        setter = this::setH;
        break;
      case "strokeWeight":
        setter = this::setStrokeWeight;
        break;
      default:
        return null;
    }
    Animation<Float> anim = new Animation<>(this, setter, startF, endF, startV, endV, interpolators.floatInterpolator, easingFunc);
    animate(anim);
    return anim;
  }
  
  Animation animate(String prop, int startF, int endF, PVector startV, PVector endV, EasingFunction easingFunc) {
    Consumer<PVector> setter;
    switch(prop) {
      case "fill":
        setter = this::setFill;
        break;
      case "stroke":
        setter = this::setStroke;
        break;
      default:
        return null;
    }
    Animation<PVector> anim = new Animation<>(this, setter, startF, endF, startV, endV, interpolators.pVectorInterpolator, easingFunc);
    animate(anim);
    return anim;
  }
  
  void setX(float x) {
    this.x = x;
  }
  
  void setY(float y) {
    this.y = y;
  }
  
  void setW(float w) {
    this.w = w;
  }
  
  void setH(float h) {
    this.h = h;
  }
  
  void setFill(PVector f) {
    fillColor.set(f);
  }
  
  void setStroke(PVector s) {
    strokeColor.set(s);
  }
  
  void setStrokeWeight(float w) {
    strokeWeight = w;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  float getW() {
    return w;
  }
  
  float getH() {
    return h;
  }
  
  PVector getFill() {
    return fillColor;
  }
  
  PVector getStroke() {
    return strokeColor;
  }
  
  float getStrokeWeight() {
    return strokeWeight;
  }
  
  void show() {
    fill(fillColor.x, fillColor.y, fillColor.z);
    stroke(strokeColor.x, strokeColor.y, strokeColor.z);
    strokeWeight(strokeWeight);
    rect(x, y, w, h);
  }
}
