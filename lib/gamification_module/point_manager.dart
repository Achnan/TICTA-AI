
class PointManager {
  int _points = 0;

  int get points => _points;

  void addPoints(int value) {
    _points += value;
  }

  bool redeem(int cost) {
    if (_points >= cost) {
      _points -= cost;
      return true;
    }
    return false;
  }
}
