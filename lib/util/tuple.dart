part of tetris_attack;

/// Simple tuple class to quickly compare a pair of coordinates.
class Tuple<T> {

  T first;
  T second;

  Tuple(this.first, this.second);

  bool equals(Tuple tuple) {
    return first == tuple.first && second == tuple.second;
  }
}