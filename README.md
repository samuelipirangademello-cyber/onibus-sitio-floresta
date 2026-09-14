# Ônibus Sítio Floresta

Aplicativo Android (Flutter) para consulta rápida e **offline** dos horários
de ônibus do bairro Sítio Floresta, em Pelotas/RS.

Nome provisório. Aplicativo **independente**, sem qualquer vínculo com
Prefeitura, Prati ou UFPel.

## O que o app faz

Ao abrir, mostra automaticamente em uma única tela:

- o horário atual do celular (relógio em tempo real);
- os dois próximos ônibus no sentido **Centro → Sítio Floresta**;
- os dois próximos ônibus no sentido **Sítio Floresta → Centro**;
- quantos minutos faltam para cada ônibus e a linha correspondente.

Não há login, seleção de sentido/linha, menus ou configuração — tudo é
automático. De segunda a sexta o app mostra os horários; aos sábados e
domingos mostra um aviso e um link para o site
[portalprati.com.br/pelotas/horarios](https://www.portalprati.com.br/pelotas/horarios).

O aplicativo funciona inteiramente offline. A única função que depende de
internet é abrir esse link externo, e apenas quando o usuário toca nele.

## Identificador do pacote

`br.com.onibussitiofloresta` — usado como `applicationId`/`namespace` no
`android/app/build.gradle` e como pacote Kotlin da `MainActivity`. Não há
nenhuma razão técnica para um identificador diferente; foi mantido conforme
sugerido.

## Estrutura do projeto

```
lib/
  main.dart                    # Ponto de entrada, tema do app
  models/
    bus_schedule.dart          # Modelo de um horário de ônibus
  data/
    bus_schedule_data.dart     # Dataset local (não alterar sem necessidade)
  services/
    schedule_service.dart      # Regras: dia útil, próximos ônibus, "em X min"
  screens/
    home_screen.dart           # Tela única, com o Timer centralizado
  widgets/
    current_clock.dart         # Relógio digital
    direction_card.dart        # Cartão de um sentido (lista de ônibus)
    bus_time_card.dart         # Cartão de um horário individual
test/
  schedule_service_test.dart   # Testes da lógica de horários
```

Os dados ficam separados da interface (`lib/data/`), então atualizar os
horários no futuro significa apenas editar esse arquivo — a lógica de
cálculo e a interface não precisam mudar.

## Atualizando os horários no futuro

Edite apenas `lib/data/bus_schedule_data.dart`. Cada linha é um
`BusSchedule(time: 'HH:mm', line: '...')`. Mantenha os horários ordenados
apenas por clareza — o app já ordena e filtra automaticamente.

## Rodando localmente

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install)
instalado e um dispositivo/emulador Android configurado.

```bash
flutter pub get
flutter run
```

Para rodar os testes:

```bash
flutter test
```

## Gerando o APK

```bash
flutter build apk --release
```

O APK fica em `build/app/outputs/flutter-apk/app-release.apk`.

## Build automático via Codemagic

Este repositório já inclui um `codemagic.yaml` na raiz com um único
workflow (`android`) que instala as dependências, roda os testes e gera
o APK release automaticamente — o build usa a assinatura de debug padrão
(suficiente para instalar e testar o APK; para publicar na Play Store,
configure sua própria chave de assinatura em `android/app/build.gradle`).

Este projeto **não tem pasta `/ios`** — é um app Android puro. Se o
Codemagic tentar rodar um build iOS mesmo assim (erro do tipo
`Did not find xcodeproj from .../ios`), o problema não está neste
repositório: significa que o app, no painel do Codemagic, ainda está
configurado para usar o "Workflow Editor" (UI) em vez do
`codemagic.yaml`, ou que sobrou um workflow iOS criado automaticamente
quando o app foi conectado pela primeira vez. Para corrigir, no painel
do Codemagic:

1. Abra o app → **Settings** (ícone de engrenagem).
2. Em **Build configuration**, selecione **"codemagic.yaml"** (em vez de
   "Workflow Editor"), se ainda não estiver selecionado.
3. Caso exista algum workflow iOS criado pela interface (fora do
   `codemagic.yaml`), remova-o ou desative-o em **Workflows**.
4. Ao iniciar um novo build, selecione o workflow **`android`**.

## Ícone do aplicativo

Foi incluído um ícone provisório simples (ônibus estilizado, sem qualquer
logotipo oficial) nas densidades padrão do Android
(`android/app/src/main/res/mipmap-*/ic_launcher.png`). Sinta-se à vontade
para substituí-lo por um ícone definitivo — por exemplo usando o pacote
`flutter_launcher_icons`.

## Permissões

O app não solicita nenhuma permissão especial (sem GPS, câmera, contatos,
etc.). A única entrada no `AndroidManifest.xml` é `INTERNET`, necessária
apenas para abrir o navegador quando o usuário toca no link do site de
referência nos finais de semana.
