class InventoryConfig {
  bool fastTid;
  bool tagFocus;
  bool fastSwitch;
  bool phase;
  bool freezer;

  String antenna;
  String session;
  String target;

  InventoryConfig({
    this.fastTid = false,
    this.tagFocus = false,
    this.fastSwitch = false,
    this.phase = false,
    this.freezer = false,
    this.antenna = '1',
    this.session = 'S0',
    this.target = 'A',
  });

  InventoryConfig copyWith({
    bool? fastTid,
    bool? tagFocus,
    bool? fastSwitch,
    bool? phase,
    bool? freezer,
    String? antenna,
    String? session,
    String? target,
  }) {
    return InventoryConfig(
      fastTid: fastTid ?? this.fastTid,
      tagFocus: tagFocus ?? this.tagFocus,
      fastSwitch: fastSwitch ?? this.fastSwitch,
      phase: phase ?? this.phase,
      freezer: freezer ?? this.freezer,
      antenna: antenna ?? this.antenna,
      session: session ?? this.session,
      target: target ?? this.target,
    );
  }
}
