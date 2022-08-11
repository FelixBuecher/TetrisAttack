part of tetris_attack;

class Tuple<T> {

  T first;
  T second;

  Tuple(this.first, this.second);

  bool equals(Tuple tuple) {
    return first == tuple.first && second == tuple.second;
  }
}