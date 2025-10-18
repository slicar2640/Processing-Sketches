class Animation<T> {
  AnimationManager manager;
  Animatable controlled;
  Consumer<T> setter;
  Interpolator<T> interpolator;
  int startFrame, endFrame;
  T startValue, endValue;
  Supplier<T> startSupplier, endSupplier;
  EasingFunction easingFunction;
  Runnable endAction;
  Animation(Animatable controlled, Consumer<T> setter, int startFrame, int endFrame, T startValue, T endValue, Interpolator<T> interpolator, EasingFunction easingFunction) {
    this.controlled = controlled;
    this.setter = setter;
    this.manager = controlled.manager;
    this.startFrame = startFrame;
    this.endFrame = endFrame;
    this.startValue = startValue;
    this.endValue = endValue;
    this.easingFunction = easingFunction;
    this.interpolator = interpolator;
  }
  
  Animation(Animatable controlled, Consumer<T> setter, int startFrame, int endFrame, Supplier<T> startSupplier, T endValue, Interpolator<T> interpolator, EasingFunction easingFunction) {
    this.controlled = controlled;
    this.setter = setter;
    this.manager = controlled.manager;
    this.startFrame = startFrame;
    this.endFrame = endFrame;
    this.startSupplier = startSupplier;
    this.endValue = endValue;
    this.easingFunction = easingFunction;
    this.interpolator = interpolator;
  }
  
  Animation(Animatable controlled, Consumer<T> setter, int startFrame, int endFrame, T startValue, Supplier<T> endSupplier, Interpolator<T> interpolator, EasingFunction easingFunction) {
    this.controlled = controlled;
    this.setter = setter;
    this.manager = controlled.manager;
    this.startFrame = startFrame;
    this.endFrame = endFrame;
    this.startValue = startValue;
    this.endSupplier = endSupplier;
    this.easingFunction = easingFunction;
    this.interpolator = interpolator;
  }
  
  Animation(Animatable controlled, Consumer<T> setter, int startFrame, int endFrame, Supplier<T> startSupplier, Supplier<T> endSupplier, Interpolator<T> interpolator, EasingFunction easingFunction) {
    this.controlled = controlled;
    this.setter = setter;
    this.manager = controlled.manager;
    this.startFrame = startFrame;
    this.endFrame = endFrame;
    this.startSupplier = startSupplier;
    this.endSupplier = endSupplier;
    this.easingFunction = easingFunction;
    this.interpolator = interpolator;
  }

  void update() {
    if(manager.frame == startFrame) {
      if(startSupplier != null) startValue = startSupplier.get();
      if(endSupplier != null) endValue = endSupplier.get();
    }
    if (manager.frame >= startFrame && manager.frame <= endFrame) {
      setter.accept(getValue());
    }
    if(manager.frame == endFrame) {
      if(endAction != null) {
        endAction.run();
      }
    }
  }

  T getValue() {
    int frame = manager.frame;
    float factor = easingFunction.ease(map((float)frame, startFrame, endFrame, 0, 1));
    return interpolator.interpolate(startValue, endValue, factor);
  }
  
  void remove() {
    controlled.animations.remove(this);
    manager.removeAnimation(this);
  }
}
