/// Status possíveis da conexão VPN.
enum VpnStatus { disconnected, connecting, connected, error, disconnecting }

/// Representa um servidor/localização disponível na rede VPN.
class VpnServer {
  final String id;
  final String countryName;
  final String countryCode; // ex: "BR", "US"
  final String city;
  final int latencyMs; // ping estimado, opcional
  final bool isPremium;

  const VpnServer({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.city,
    this.latencyMs = 0,
    this.isPremium = false,
  });
}

/// Contrato que QUALQUER motor de VPN precisa implementar.
///
/// Hoje existe [MockVpnService] (placeholder, não conecta de verdade).
/// Quando você escolher o provedor white-label (PureVPN, KeepSolid, etc),
/// crie uma nova classe tipo `PureVpnService implements VpnEngine` que
/// chama o SDK real deles — o resto do app (telas, botões) não muda nada.
abstract class VpnEngine {
  Stream<VpnStatus> get statusStream;

  Future<List<VpnServer>> fetchServers();

  Future<void> connect(VpnServer server);

  Future<void> disconnect();

  Future<VpnStatus> currentStatus();
}

