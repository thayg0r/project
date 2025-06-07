# 📅 Agendamento de Postagens no Instagram

Aplicativo Flutter que permite agendar postagens localmente com título, descrição, data e hora. Ideal para organizar publicações futuras sem depender de conexão externa com redes sociais. As postagens são armazenadas no dispositivo e exibidas em um calendário interativo, facilitando a visualização e o controle do conteúdo agendado.

## 🎯 Objetivo

Permitir que o usuário agende uma postagem contendo a descrição e fotos a ser publicado.

## ✅ Funcionalidades implementadas

- [x] Tela de agendamento com título, descrição, data e hora
- [x] Botão de "Agendar"
- [x] Lista de postagens agendadas para a data selecionada
- [x] Exibição de indicadores visuais no calendário (bolinhas abaixo dos dias com postagens agendadas)
- [x] Persistência local com `SharedPreferences`
- [x] Suporte à edição e exclusão de postagens
- [x] Uso de `setState` para gerenciamento de estado
- [x] Organização modular dos arquivos
- [x] Swipe (deslizar) para deletar agendamento

## 🖼️ Pré-visualização

### Tela Postagens Agendadas

<img src="assets/images/postagens-agendadas.png" width="300" height="500" />

### Tela Agendar Postagem

<img src="assets/images/agendar-postagem.png" width="300" height="500" />

## 🗂 Como rodar o aplicativo

Clone o repositório:

`git clone https://github.com/seu-usuario/agendamento-postagens.git`
`cd agendamento-postagens`

Instale as dependências:

`flutter pub get`

Execute o projeto em um emulador ou dispositivo físico:

`flutter run`

## 🗂 Detalhes da implementação

Desenvolvido com Flutter, utilizando setState para gerenciamento de estado.

A persistência local dos dados é feita por meio do pacote SharedPreferences, com os dados armazenados no formato JSON.

A visualização interativa das postagens é feita com o pacote table_calendar, permitindo ao usuário navegar por datas e ver os agendamentos do dia.

## 🗂 Estrutura do projeto

```bash
lib/
├── data/
│   └── local/
│       └── post_storage.dart
│
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart
│   │
│   ├── scheduling/
│   │   └── presentation/
│   │       └── scheduling_screen.dart
│
├── main.dart

```
