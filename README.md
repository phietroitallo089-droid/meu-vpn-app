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

