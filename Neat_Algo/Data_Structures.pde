import java.util.HashSet;

class RandomHashSet<T> {
  HashSet<T> set;
  ArrayList<T> data;

  RandomHashSet() {
    set = new HashSet<>();
    data = new ArrayList<>();
  }

  boolean contains(T object) {
    return set.contains(object);
  }

  T randomElement() {
    if (set.size() > 0) {
      return data.get((int) random(size()));
    }
    return null;
  }

  int size() {
    return data.size();
  }

  void add(T object) {
    if (!set.contains(object)) {
      set.add(object);
      data.add(object);
    }
  }

  void addSorted(Gene object) {
    for (int i = 0; i < this.size(); i++) {
      int innovation = ((Gene)data.get(i)).getInnovationNumber();
      if (object.getInnovationNumber() < innovation) {
        data.add(i, (T)object);
        set.add((T)object);
        return;
      }
    }
    data.add((T)object);
    set.add((T)object);
  }

  void clear() {
    set.clear();
    data.clear();
  }

  T get(int index) {
    return data.get(index);
  }

  void remove(int index) {
    set.remove(data.get(index));
    data.remove(index);
  }

  void remove(T object) {
    set.remove(object);
    data.remove(object);
  }

  ArrayList<T> getData() {
    return data;
  }
}

class RandomSelector<T> {
  ArrayList<T> objects = new ArrayList<>();
  ArrayList<Double> scores = new ArrayList<>();

  double totalScore = 0;

  void add(T element, double score) {
    objects.add(element);
    scores.add(score);
    totalScore += score;
  }

  T random() {
    double v = Math.random() * totalScore;
    double c = 0;
    for (int i = 0; i < objects.size(); i++) {
      c += scores.get(i);
      if (c > v) {
        return objects.get(i);
      }
    }
    return null;
  }
  
  int size() {
    return objects.size();
  }

  void reset() {
    objects.clear();
    scores.clear();
    totalScore = 0;
  }
}
