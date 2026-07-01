import 'package:flutter/material.dart';
import '../core/vpn_engine.dart';
import '../core/mock_vpn_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔌 PONTO DE TROCA: quando tiver o provedor real, troque MockVpnEngine()
  // por, por exemplo, PureVpnEngine(apiKey: ...). O resto da tela não muda.
  final VpnEngine _engine = MockVpnEngine();

  VpnStatus _status = VpnStatus.disconnected;
  List<VpnServer> _servers = [];
  VpnServer? _selectedServer;

  @override
  void initState() {
    super.initState();
    _engine.statusStream.listen((s) => setState(() => _status = s));
    _loadServers();
  }

  Future<void> _loadServers() async {
    final servers = await _engine.fetchServers();
    setState(() {
      _servers = servers;
      _selectedServer ??= servers.isNotEmpty ? servers.first : null;
    });
  }

  Future<void> _toggleConnection() async {
    if (_selectedServer == null) return;
    if (_status == VpnStatus.connected) {
      await _engine.disconnect();
    } else if (_status == VpnStatus.disconnected) {
      await _engine.connect(_selectedServer!);
    }
  }

  String get _statusLabel {
    switch (_status) {
      case VpnStatus.connected:
        return 'Conectado';
      case VpnStatus.connecting:
        return 'Conectando...';
      case VpnStatus.disconnecting:
        return 'Desconectando...';
      case VpnStatus.error:
        return 'Erro na conexão';
      case VpnStatus.disconnected:
        return 'Desconectado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _status == VpnStatus.connected;
    final busy = _status == VpnStatus.connecting || _status == VpnStatus.disconnecting;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(_statusLabel, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: busy ? null : _toggleConnection,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? Colors.greenAccent.withOpacity(0.15) : Colors.white10,
                  border: Border.all(
                    color: connected ? Colors.greenAccent : Colors.white24,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.power_settings_new,
                  size: 56,
                  color: connected ? Colors.greenAccent : Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  final selected = server.id == _selectedServer?.id;
                  return Card(
                    color: selected ? Colors.white12 : Colors.white.withOpacity(0.04),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: const Icon(Icons.public, color: Colors.white70),
                      title: Text('${server.countryName} · ${server.city}',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${server.latencyMs} ms',
                          style: const TextStyle(color: Colors.white38)),
                      trailing: server.isPremium
                          ? const Icon(Icons.star, color: Colors.amber, size: 18)
                          : null,
                      onTap: busy || connected
                          ? null
                          : () => setState(() => _selectedServer = server),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

