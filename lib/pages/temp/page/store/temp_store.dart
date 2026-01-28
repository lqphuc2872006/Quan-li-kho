import '../../../../services/models/temp_tag.dart';
import '../../../../services/models/inventory_tag.dart';

class TempStore {
  static final Map<String, TempTag> _tags = {};

  static List<TempTag> get all =>
      _tags.values.toList(growable: false);

  static bool get hasData => _tags.isNotEmpty;

  static void upsertFromInventory(
      Iterable<InventoryTag> inventoryTags,
      ) {
    for (final inv in inventoryTags) {
      final old = _tags[inv.epc];

      _tags[inv.epc] = old == null
          ? TempTag(
        epc: inv.epc,
        temp: '--',
        antId: '--',
        pc: '--',
        crc: '--',
      )
          : old.copyWith(times: old.times + 1);
    }
  }

  static void clear() {
    _tags.clear();
  }
}
