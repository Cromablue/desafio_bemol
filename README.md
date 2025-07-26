# 📱 BSF Câmbio

**BSF Câmbio** é um aplicativo Flutter para cotações de moedas em tempo real e conversão desenvolvido em resposta ao desafio técnico do TalentLab. Ele permite que usuários acompanhem as taxas de câmbio de diversas moedas, definam uma moeda base, pesquisem moedas específicas, marquem as favoritas e realizem conversões de valores de forma interativa.

---

## Agradecimentos e Informações sobre a API

Este aplicativo foi desenvolvido utilizando como base a [ExchangeRate-API](https://app.exchangerate-api.com/dashboard), um serviço gratuito que fornece dados de taxas de câmbio atualizados.

> 🔐 **Atenção**: Para que o BSF Câmbio funcione corretamente, é necessário adquirir uma **chave de API gratuita** diretamente no site da ExchangeRate-API. A chave será usada para autenticar as requisições da aplicação.

A API escolhida oferece um plano gratuito com acesso a uma ampla variedade de moedas, taxas atualizadas e documentação clara — ideal para aplicações educacionais, protótipos e projetos de código aberto como este.

---

## 🔧 Funcionalidades

- **Cotações em Tempo Real**: Visualize as taxas de câmbio atualizadas em relação a uma moeda base selecionada.

    Atenção: Como está sendo utilizado o plano gratuito, é utilizado a ultima atualização do dia anterior, que ocorre as 20 horas da noite no horario de Manaus.
- **Lista de Moedas Abrangente**: Acesse uma lista completa de moedas suportadas com seus códigos e nomes completos.
- **Pesquisa Dinâmica**: Encontre moedas rapidamente usando a funcionalidade de pesquisa por código ou nome.
- **Favoritos**: Marque moedas como favoritas para acesso rápido e fácil.
- **Conversor Interativo**: Converta valores entre a moeda base e qualquer outra moeda suportada com atualização instantânea.
- **Detalhes da Moeda**: Veja informações detalhadas como taxa precisa, volatilidade e última atualização.
- **Persistência de Dados**: As moedas favoritas são salvas localmente no dispositivo.
- **Tratamento de Erros**: Mensagens amigáveis para erros de rede ou carregamento de dados.

---

## 🚀 Primeiros Passos

### ✅ Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
- Editor de código (VS Code ou Android Studio)

### 📥 Instalação

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd bsf_cambio
flutter pub get
```

### ⚙️ Configuração de Ambiente

Crie um arquivo `.env` na raiz do projeto usando o pacote `flutter_dotenv`:

```env
EXCHANGE_RATE_API_KEY=SUA_CHAVE_API_AQUI
```

> Substitua `SUA_CHAVE_API_AQUI` pela sua chave de API real para o serviço de câmbio.

### ▶️ Execução

```bash
flutter run
```

---

## 🗂 Estrutura do Projeto

```
lib/
├── app/
│   └── currency_app.dart
├── models/
│   ├── exchange_rates.dart
│   └── supported_codes.dart
├── screens/
│   ├── converter/
│   │   └── converter_screen.dart
│   ├── currency_detail_screen.dart
│   ├── currency_list_screen.dart
│   ├── home_screen.dart
│   └── navigation_host_screen.dart
├── services/
│   └── currency_service.dart
├── utils/
│   ├── app_colors.dart
│   ├── currency_data.dart
│   ├── currency_input_formatter.dart
│   └── error_handler.dart
└── widgets/
    ├── custom_elevated_button.dart
    └── info_container.dart
```

---

## 🧩 Componentes Principais

### `main.dart`
Inicializa as configurações globais e executa o `CurrencyApp`.

### `CurrencyApp`
Widget raiz do app. Configura o `MaterialApp` e o tema visual.

### `HomeScreen`
Tela de boas-vindas com logo, título e botão de entrada.

### `NavigationHostScreen`
Gerencia navegação entre `CurrencyListScreen` e `ConverterScreen` com `BottomNavigationBar`. Carrega moedas suportadas.

### `CurrencyListScreen`
Lista moedas com suporte a:
- Seleção de moeda base (`DropdownButton`)
- Pesquisa (`TextField`)
- Ordenação (por nome ou valor)
- Marcação de favoritos (`shared_preferences`)
- Abas ("Todas" e "Favoritas")
- Atualização via `RefreshIndicator`

### `CurrencyDetailScreen`
Mostra detalhes e conversão entre moedas:
- Conversor com `TextFormField` bidirecional
- Informações detalhadas (taxa, volatilidade, última atualização)
- Aviso de volatilidade, se aplicável

### `CurrencyService`
Serviço para acessar a API de câmbio. Inclui cache e tratamento de erros.


