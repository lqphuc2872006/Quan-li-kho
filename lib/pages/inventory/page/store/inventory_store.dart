import '../../../../services/models/inventory_tag.dart';

class InventoryStore {
  static final Map<String, InventoryTag> tags = {};

  // 🔁 UPSERT TAG (RFID STREAM GỌI)
  static void upsert(InventoryTag tag) {
    final old = tags[tag.epc];

    tags[tag.epc] = old == null
        ? tag
        : old.copyWith(
      rssi: tag.rssi,
      lastSeen: tag.lastSeen,
      count: old.count + 1,
    );
  }

  // 📦 READ
  static List<InventoryTag> get all =>
      tags.values.toList(growable: false);

  static int get total => tags.length;

  // 🧹 CLEAR
  static void clear() {
    tags.clear();
  }
}
