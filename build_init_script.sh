#!/bin/bash
set -e
echo "Recriando o projeto vpnapp..."
mkdir -p vpnapp/lib/{core,screens,models,widgets}
mkdir -p vpnapp/.github/workflows
mkdir -p $(dirname "vpnapp/pubspec.yaml")
cat > "vpnapp/pubspec.yaml" << 'FILEEOF'
name: vpnapp
description: "App de VPN multiplataforma (Android, iOS, Desktop)"
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6

  # Backend / autenticação / dados
  supabase_flutter: ^2.5.0

  # Gerenciamento de estado
  flutter_riverpod: ^2.5.1

  # Utilidades
  flutter_dotenv: ^5.1.0      # para guardar chaves (Supabase URL/key, API do provedor VPN)
  fl_country_code_picker: ^3.0.1  # útil pra lista de países/servidores

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/

FILEEOF
mkdir -p $(dirname "vpnapp/.env.example")
cat > "vpnapp/.env.example" << 'FILEEOF'
# Renomeie este arquivo para ".env" e preencha com seus dados reais.
# NUNCA suba o arquivo ".env" real pro GitHub/repositório público.

# --- Supabase ---
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_ANON_KEY=SUA_ANON_KEY_AQUI

# --- Provedor White-Label de VPN (preencher quando escolher) ---
VPN_PROVIDER_API_URL=
VPN_PROVIDER_API_KEY=

FILEEOF
mkdir -p $(dirname "vpnapp/README.md")
cat > "vpnapp/README.md" << 'FILEEOF'
# Meu App de VPN — Roteiro até a publicação (meta: janeiro/2027)

## O que já existe neste projeto
- Estrutura base em **Flutter** (compartilha código entre Android, iOS e Desktop)
- Autenticação por e-mail/senha usando **Supabase**
- Tela de entrada (onboarding), login, e tela principal com botão de conectar + lista de servidores
- Camada `VpnEngine` **abstrata** — hoje usando `MockVpnEngine` (fake, só pra testar a interface).
  Quando o provedor white-label for escolhido, criamos uma implementação real sem mexer nas telas.

## O que falta (nessa ordem)

### 1. Preparar o ambiente na sua máquina
- Instalar o [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Instalar o Android Studio (pra compilar Android) e, se for mexer em iOS, um Mac com Xcode
- Rodar `flutter pub get` dentro da pasta do projeto

### 2. Configurar o Supabase
- Copiar `.env.example` para `.env` e preencher com a URL e a chave anônima do seu projeto Supabase
- Criar as tabelas necessárias (usuários, assinaturas/planos, histórico de conexão se for logar)

### 3. Escolher e integrar o provedor white-label de VPN
- Fechar com o provedor (PureVPN, KeepSolid, Symlex, FastestVPN, etc.)
- Pegar as chaves de API e o SDK Android deles
- Criar uma classe nova, ex. `lib/core/pure_vpn_engine.dart`, implementando `VpnEngine`
- Trocar `MockVpnEngine()` por essa classe real em `home_screen.dart`

### 4. Colocar suas imagens/identidade visual
- Me envie as 2 imagens de entrada que você tem — eu ajusto `onboarding_screen.dart` e `login_screen.dart` pra usar elas
- Definir paleta de cores, ícone do app, nome final

### 5. Testar de verdade
- Testar em ao menos 2 celulares Android físicos diferentes
- Testar em rede wifi e rede móvel
- Verificar: kill switch, reconexão automática, troca de servidor

### 6. Preparar a conta e os documentos legais
- Criar conta no **Google Play Console** (taxa única de US$25)
- Escrever uma **Política de Privacidade** (obrigatória para apps de VPN) e publicar num link público
- Preencher o formulário de **Data Safety** no console com precisão
- Definir termos de uso e política de reembolso (se for pago)

### 7. Configurar cobrança (se o app for pago/assinatura)
- Integrar **Google Play Billing** para assinaturas
- Definir planos (mensal/anual) e período de teste grátis, se houver

### 8. Publicar
- Subir o app na faixa de **teste interno** primeiro
- Convidar alguns testadores (você + amigos)
- Corrigir o que aparecer
- Promover para produção — reserve pelo menos **2-3 semanas de folga antes de janeiro**, pois apps de VPN passam por revisão mais rigorosa da Google e podem levar mais tempo que o normal

## Sobre iOS e Desktop (Windows/Mac/Linux)
Este projeto já está estruturado para reaproveitar a maior parte do código nessas plataformas,
mas cada uma tem exigências próprias:
- **iOS**: exige Apple Developer Program (US$99/ano), um Mac, e a extensão especial
  `NetworkExtension` (Apple aprova com critério essa permissão para apps de VPN)
- **Desktop**: cada sistema operacional tem sua própria forma de criar a interface de rede (TUN/TAP)
  e a distribuição não passa pela Play Store — cada um tem seu próprio processo

**Recomendação:** lançar primeiro no Android (sua meta original), validar com usuários reais,
e só depois expandir pra iOS/Desktop com o aprendizado do lançamento inicial.

FILEEOF
mkdir -p $(dirname "vpnapp/.github/workflows/build.yml")
cat > "vpnapp/.github/workflows/build.yml" << 'FILEEOF'
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch: {}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - name: Criar .env de exemplo (troque pelos seus valores reais como Secret depois)
        run: |
          echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" >> .env
          echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env

      - name: Instalar dependências
        run: flutter pub get

      - name: Compilar APK (release)
        run: flutter build apk --release

      - name: Publicar o APK como artefato para download
        uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

FILEEOF
mkdir -p $(dirname "vpnapp/lib/main.dart")
cat > "vpnapp/lib/main.dart" << 'FILEEOF'
import 'package:flutter/material.dart';
import 'core/supabase_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const VpnApp());
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: SupabaseService.isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

FILEEOF
mkdir -p $(dirname "vpnapp/lib/core/supabase_service.dart")
cat > "vpnapp/lib/core/supabase_service.dart" << 'FILEEOF'
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Inicializa e expõe o cliente Supabase usado em todo o app.
///
/// Chame [SupabaseService.initialize] uma única vez, no main.dart,
/// antes de rodar o app.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}

FILEEOF
mkdir -p $(dirname "vpnapp/lib/core/vpn_engine.dart")
cat > "vpnapp/lib/core/vpn_engine.dart" << 'FILEEOF'
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

FILEEOF
mkdir -p $(dirname "vpnapp/lib/core/mock_vpn_engine.dart")
cat > "vpnapp/lib/core/mock_vpn_engine.dart" << 'FILEEOF'
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

FILEEOF
mkdir -p $(dirname "vpnapp/lib/screens/onboarding_screen.dart")
cat > "vpnapp/lib/screens/onboarding_screen.dart" << 'FILEEOF'
import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Tela de entrada / boas-vindas.
///
/// SUBSTITUA: quando você me mandar suas 2 imagens de entrada, eu troco
/// o conteúdo visual daqui mantendo essa mesma estrutura de navegação.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              // Placeholder do logo/ilustração — troque por Image.asset('assets/images/sua_imagem.png')
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.shield_outlined, size: 72, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              const Text(
                'Navegue com privacidade',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Conecte-se em segundos e proteja seus dados em qualquer rede.',
                style: TextStyle(color: Colors.white60, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Começar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

FILEEOF
mkdir -p $(dirname "vpnapp/lib/screens/login_screen.dart")
cat > "vpnapp/lib/screens/login_screen.dart" << 'FILEEOF'
import 'package:flutter/material.dart';
import '../core/supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _error = 'Não foi possível entrar. Verifique seus dados.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Verifique seu e-mail para confirmar.')),
      );
    } catch (e) {
      setState(() => _error = 'Não foi possível criar a conta.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('E-mail'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: _inputDecoration('Senha'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loading ? null : _signUp,
                child: const Text('Criar conta nova', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }
}

FILEEOF
mkdir -p $(dirname "vpnapp/lib/screens/home_screen.dart")
cat > "vpnapp/lib/screens/home_screen.dart" << 'FILEEOF'
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

FILEEOF
echo "Projeto recriado com sucesso em ./vpnapp"
echo "Agora rode:"
echo "  cd vpnapp"
echo "  git init -b main 2>/dev/null || true"
echo "  git add ."
echo "  git commit -m 'Primeiro commit do app de VPN'"
echo "  git branch -M main"
echo "  git remote add origin SEU_LINK_DO_REPOSITORIO_AQUI"
echo "  git push -u origin main"
