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

