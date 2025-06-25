
class RewardItem {
  final String name;
  final int cost;

  RewardItem(this.name, this.cost);
}

class RewardStore {
  final List<RewardItem> items = [
    RewardItem('ธีมภาพพื้นหลัง', 50),
    RewardItem('เสียงแนะนำใหม่', 70),
    RewardItem('ตราสัญลักษณ์พิเศษ', 100),
  ];

  List<RewardItem> getAvailableItems() => items;
}
