
import 'point_manager.dart';

class PointService {
  static final PointService _instance = PointService._internal();
  final PointManager _manager = PointManager();

  factory PointService() {
    return _instance;
  }

  PointService._internal();

  int get currentPoints => _manager.points;

  void addPointsForCourseCompletion() {
    _manager.addPoints(10); // ได้ 10 แต้มต่อคอร์ส
  }

  bool tryRedeem(int cost) {
    return _manager.redeem(cost);
  }
}
