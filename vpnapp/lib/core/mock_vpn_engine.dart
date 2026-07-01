import 'dart:async';
import 'vpn_engine.dart';

/// Implementação FALSA do motor de VPN, só pra podermos construir e testar
/// todas as telas do app antes de ter um provedor white-label configurado.
///
/// ⚠️ Isso NÃO criptografa nada de verdade. É só pra desenvolvimento.
/// Troque por uma implementação real (ex: PureVpnEngine) antes de publicar.
class MockVpnEngine implements VpnEngine {
  final _statusController = StreamController<VpnStatus>.broadcast();
  VpnStatus _status = VpnStatus.disconnected;

  @override
  Stream<VpnStatus> get statusStream => _statusController.stream;

  @override
  Future<VpnStatus> currentStatus() async => _status;

  void _setStatus(VpnStatus s) {
    _status = s;
    _statusController.add(s);
  }

  @override
  Future<List<VpnServer>> fetchServers() async {
    // Lista de exemplo — depois isso vem da API do provedor escolhido.
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      VpnServer(id: 'br-1', countryName: 'Brasil', countryCode: 'BR', city: 'São Paulo', latencyMs: 12),
      VpnServer(id: 'us-1', countryName: 'Estados Unidos', countryCode: 'US', city: 'Miami', latencyMs: 85),
      VpnServer(id: 'pt-1', countryName: 'Portugal', countryCode: 'PT', city: 'Lisboa', latencyMs: 140),
      VpnServer(id: 'jp-1', countryName: 'Japão', countryCode: 'JP', city: 'Tóquio', latencyMs: 210, isPremium: true),
    ];
  }

  @override
  Future<void> connect(VpnServer server) async {
    _setStatus(VpnStatus.connecting);
    await Future.delayed(const Duration(seconds: 2)); // simula handshake
    _setStatus(VpnStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    _setStatus(VpnStatus.disconnecting);
    await Future.delayed(const Duration(milliseconds: 800));
    _setStatus(VpnStatus.disconnected);
  }

  void dispose() => _statusController.close();
}

