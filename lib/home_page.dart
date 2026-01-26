import 'package:flutter/material.dart';
import 'rfid_plugin.dart';

class HomePage extends StatefulWidget {
  final RfidPlugin rfidPlugin;

  const HomePage({super.key, required this.rfidPlugin});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isScanning = false;
  List<String> _scannedTags = [];
  String _statusMessage = 'Ready to scan';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupRfidCallbacks();
  }

  void _setupRfidCallbacks() {
    widget.rfidPlugin.onTagScanned = (epc, rssi) {
      setState(() {
        if (!_scannedTags.contains(epc)) {
          _scannedTags.insert(0, epc);
          if (_scannedTags.length > 100) {
            _scannedTags.removeLast();
          }
        }
        _statusMessage = 'Tag scanned: $epc (RSSI: $rssi)';
      });
    };

    widget.rfidPlugin.onScanEnd = () {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan ended';
      });
    };

    widget.rfidPlugin.onError = (error) {
      setState(() {
        _statusMessage = 'Error: $error';
        _errorMessage = 'RFID Error: $error';
        _isScanning = false;
      });
    };
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        _errorMessage = null;
        _isScanning = true;
        _statusMessage = 'Scanning...';
      });
      await widget.rfidPlugin.startInventory();
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $e';
        _errorMessage = 'Start scan error: $e';
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      await widget.rfidPlugin.stopInventory();
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan stopped';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Stop scan error: $e';
      });
    }
  }

  void _clearTags() {
    setState(() {
      _scannedTags.clear();
      _statusMessage = 'Tags cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Scanner - Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_statusMessage',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Scan Control Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Scan Control',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isScanning ? null : _startScan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Start Scan'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isScanning ? _stopScan : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Stop Scan'),
                          ),
                        ),
                      ],
                    ),
                    if (_isScanning)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Scanned Tags Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scanned Tags (${_scannedTags.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearTags,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _scannedTags.isEmpty
                          ? const Center(
                              child: Text('No tags scanned yet'),
                            )
                          : ListView.builder(
                              itemCount: _scannedTags.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.nfc),
                                  title: Text(
                                    _scannedTags[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  subtitle: Text('Tag #${index + 1}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
