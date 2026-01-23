import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../services/rfid_service.dart';
import '../widgets/inventory_settings.dart';
import '../widgets/inventory_action_row.dart';
import '../widgets/time_picker_sheet.dart';
import '../widgets/inventory_info_bar.dart';
import '../../../widgets/app_data_table.dart';

/// ======================
/// MODEL INVENTORY
/// ======================
class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final String time;
  final String status;

  InventoryRow({
    required this.no,
    required this.tagId,
    required this.rssi,
    required this.time,
    required this.status,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _showSettings = false;
  bool _isScanning = false;
  Timer? _scanTimer;
  Timer? _simulateTimer;
  DateTime? _scanStartTime;
  int _totalScanned = 0;
  int _scanSpeed = 0;
  StreamSubscription? _tagSubscription;

  // ======================
  // TIME INVENTORY
  // ======================
  int _timeValue = 5;
  String _timeUnit = 'seconds';

  String get _timeDisplay {
    switch (_timeUnit) {
      case 'minutes':
        return '$_timeValue min';
      case 'hours':
        return '$_timeValue h';
      default:
        return '$_timeValue s';
    }
  }

  int get _durationInSeconds {
    switch (_timeUnit) {
      case 'minutes':
        return _timeValue * 60;
      case 'hours':
        return _timeValue * 3600;
      default:
        return _timeValue;
    }
  }

  // ======================
  // INVENTORY DATA
  // ======================
  final Map<String, InventoryRow> _tagMap = {};
  List<InventoryRow> get _rows => _tagMap.values.toList();

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _stopScanning();
    _tagSubscription?.cancel();
    _scanTimer?.cancel();
    _simulateTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final isConnected = await RfidService.isConnected();
    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa kết nối với thiết bị RFID'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;

    try {
      // Kiểm tra kết nối
      final isConnected = await RfidService.isConnected();
      if (!isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chưa kết nối với thiết bị RFID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Bắt đầu quét
      final success = await RfidService.startInventory();
      if (!success) {
        throw Exception('Không thể bắt đầu quét');
      }

      setState(() {
        _isScanning = true;
        _scanStartTime = DateTime.now();
        _totalScanned = _rows.length;
      });

      // Thiết lập timer để tự động dừng
      final duration = Duration(seconds: _durationInSeconds);
      _scanTimer = Timer(duration, () {
        _stopScanning();
      });

      // Lắng nghe các tag được quét từ native code
      _tagSubscription = RfidService.tagStream.listen(
        (tagData) {
          _onTagScanned(RfidTag.fromMap(tagData));

          // Update scan speed
          if (_scanStartTime != null) {
            final elapsed = DateTime.now().difference(_scanStartTime!).inSeconds;
            if (elapsed > 0) {
              setState(() {
                _scanSpeed = _totalScanned ~/ elapsed;
              });
            }
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi quét: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      // Start periodic speed update
      _updateScanSpeed();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã bắt đầu quét RFID'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopScanning() async {
    if (!_isScanning) return;

    try {
      await RfidService.stopInventory();
      _scanTimer?.cancel();
      _simulateTimer?.cancel();
      _tagSubscription?.cancel();

      setState(() {
        _isScanning = false;
        _scanStartTime = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã dừng quét'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi dừng quét: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onTagScanned(RfidTag tag) {
    setState(() {
      final existingTag = _tagMap[tag.epc];
      if (existingTag != null) {
        // Cập nhật tag đã tồn tại
        _tagMap[tag.epc] = InventoryRow(
          no: existingTag.no,
          tagId: tag.epc,
          rssi: tag.rssi,
          time: tag.timestamp,
          status: 'OK',
        );
      } else {
        // Thêm tag mới
        _tagMap[tag.epc] = InventoryRow(
          no: _tagMap.length + 1,
          tagId: tag.epc,
          rssi: tag.rssi,
          time: tag.timestamp,
          status: 'OK',
        );
      }
      _totalScanned = _tagMap.length;
    });
  }

  // Update scan speed periodically
  void _updateScanSpeed() {
    _simulateTimer?.cancel();
    _simulateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      // Update scan speed
      if (_scanStartTime != null) {
        final elapsed = DateTime.now().difference(_scanStartTime!).inSeconds;
        if (elapsed > 0) {
          setState(() {
            _scanSpeed = _totalScanned ~/ elapsed;
          });
        }
      }
    });
  }

  int _getExecTime() {
    if (_scanStartTime == null) return 0;
    return DateTime.now().difference(_scanStartTime!).inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// SETTINGS
        InventorySettings(
          expanded: _showSettings,
          onToggle: () {
            setState(() {
              _showSettings = !_showSettings;
            });
          },
        ),

        InventoryActionRow(
          timeDisplay: _timeDisplay,
          isScanning: _isScanning,
          onPickTime: () {
            if (!_isScanning) {
              showTimePickerSheet(
                context: context,
                value: _timeValue,
                unit: _timeUnit,
                onApply: (v, u) {
                  setState(() {
                    _timeValue = v;
                    _timeUnit = u;
                  });
                },
              );
            }
          },
          onStart: _isScanning ? _stopScanning : _startScanning,
          onClear: () {
            if (!_isScanning) {
              setState(() {
                _tagMap.clear();
                _totalScanned = 0;
                _scanSpeed = 0;
              });
            }
          },
        ),

        const SizedBox(height: 8),

        InventoryInfoBar(
          tags: _rows.length,
          speed: _scanSpeed,
          total: _totalScanned,
          execTime: _getExecTime(),
        ),

        const SizedBox(height: 8),

        AppDataTable(
          headers: const ['No', 'Tag ID', 'RSSI', 'Time', 'Status'],
          rows: _rows.map((r) {
            return [
              Text(r.no.toString()),
              Text(r.tagId),
              Text(r.rssi),
              Text(r.time),
              Text(
                r.status,
                style: TextStyle(
                  color: r.status == 'OK'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }
}
