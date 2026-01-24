import 'package:flutter/material.dart';
import '../../services/rfid_service.dart';
import '../home_page.dart';

class SerialConnectionPage extends StatefulWidget {
  const SerialConnectionPage({super.key});

  @override
  State<SerialConnectionPage> createState() => _SerialConnectionPageState();
}

class _SerialConnectionPageState extends State<SerialConnectionPage> {
  bool _isConnecting = false;
  bool _isConnected = false;
  String _selectedPort = '/dev/ttyAS3'; // Default port
  int _selectedBaudRate = 115200;
  final List<String> _availablePorts = [];
  final List<int> _baudRates = [9600, 19200, 38400, 57600, 115200];

  @override
  void initState() {
    super.initState();
    _loadAvailablePorts();
  }

  Future<void> _loadAvailablePorts() async {
    try {
      // Load available serial ports from native code
      final ports = await RfidService.getAvailablePorts();
      setState(() {
        if (ports.isNotEmpty) {
          _availablePorts.addAll(ports);
          // Set default port to ttyAS3 if available, otherwise use first port
          if (_availablePorts.contains('/dev/ttyAS3')) {
            _selectedPort = '/dev/ttyAS3';
          } else {
            _selectedPort = _availablePorts.first;
          }
        } else {
          // Fallback to mock data if no ports found
          _availablePorts.addAll([
            '/dev/ttyAS3',
            '/dev/ttyUSB0',
            '/dev/ttyUSB1',
            'COM1',
            'COM3',
          ]);
          // Set default to ttyAS3
          _selectedPort = '/dev/ttyAS3';
        }
      });
    } catch (e) {
      // Fallback to mock data on error
      setState(() {
        _availablePorts.addAll([
          '/dev/ttyAS3',
          '/dev/ttyUSB0',
          '/dev/ttyUSB1',
          'COM1',
          'COM3',
        ]);
        // Set default to ttyAS3
        _selectedPort = '/dev/ttyAS3';
      });
    }
  }

  Future<void> _connect() async {
    if (_selectedPort.isEmpty) {
      _showError('Vui lòng chọn cổng Serial');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      // Call native method to connect
      final success = await RfidService.connect(_selectedPort, _selectedBaudRate);
      
      if (!success) {
        throw Exception('Không thể kết nối với thiết bị');
      }
      
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      // Navigate to home page after successful connection
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'RFID Scanner'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      _showError('Kết nối thất bại: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Connection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 40),
            Icon(
              Icons.usb,
              size: 80,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Kết nối thiết bị RFID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Port Selection
            const Text(
              'Chọn cổng Serial:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPort.isEmpty ? null : _selectedPort,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_input_component),
              ),
              items: _availablePorts.map((port) {
                return DropdownMenuItem(
                  value: port,
                  child: Text(port),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPort = value ?? '';
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Baud Rate Selection
            const Text(
              'Baud Rate:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedBaudRate,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              items: _baudRates.map((baud) {
                return DropdownMenuItem(
                  value: baud,
                  child: Text('$baud'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBaudRate = value ?? 115200;
                });
              },
            ),
            
            const SizedBox(height: 40),
            
            // Connect Button
            ElevatedButton(
              onPressed: _isConnecting || _isConnected ? null : _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isConnected ? Colors.green : null,
              ),
              child: _isConnecting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang kết nối...'),
                      ],
                    )
                  : Text(
                      _isConnected ? 'Đã kết nối' : 'Kết nối',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
            
            if (_isConnected) ...[
              const SizedBox(height: 12),
              const Text(
                'Kết nối thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}
