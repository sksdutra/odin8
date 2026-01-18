# Odin8 - Emulador CHIP-8

Um emulador simples de [CHIP-8](https://en.wikipedia.org/wiki/CHIP-8) escrito na linguagem de programação **Odin**, utilizando a biblioteca **Raylib** para gráficos, entrada e áudio.

![odin8 rodando Space Invaders](https://github.com/sksdutra/odin8/blob/main/img/screen.png)

## 🚀 Funcionalidades

- Emulação do set de instruções padrão do CHIP-8.
- Renderização gráfica 64x32 escalonada para 800x450.
- Suporte a som (Bip gerado proceduralmente via onda quadrada).
- Entrada via teclado mapeada para o layout hexadecimal.
- Carregamento de ROMs via linha de comando.
- Timer de Delay e Som (60Hz).

## 🛠️ Pré-requisitos

- **Compilador Odin**: Certifique-se de ter o Odin instalado e no seu PATH.
- **Bibliotecas de Desenvolvimento (Linux)**: Como o projeto usa Raylib, você pode precisar de dependências do sistema (X11, GL, ALSA, etc).
  - *Exemplo no Ubuntu:* `sudo apt install libx11-dev libxcursor-dev libxrandr-dev libxinerama-dev libxi-dev libgl1-mesa-dev libasound2-dev`

## 📦 Como Compilar

O projeto inclui um script de build para facilitar a compilação no Linux.

1. Dê permissão de execução ao script:
   ```bash
   chmod +x build.sh
   ```

2. Execute o script:
   ```bash
   ./build.sh
   ```

Isso irá gerar o executável `odin8` na raiz do projeto.

## 🎮 Como Usar

Para rodar um jogo, passe o caminho da ROM como argumento pela linha de comando:

```bash
./odin8 roms/PONG
```

*(Certifique-se de que o arquivo da ROM existe no caminho especificado).*

## ⌨️ Controles

O teclado do CHIP-8 (hexadecimal 0-F) está mapeado para o teclado do computador da seguinte forma:

| Teclado CHIP-8 | Teclado Físico (Mapeamento) |
| :---: | :---: |
| **1** | `1` |
| **2** | `2` |
| **3** | `3` |
| **C** | `4` |
| **4** | `Q` |
| **5** | `W` |
| **6** | `E` |
| **D** | `R` |
| **7** | `A` |
| **8** | `S` |
| **9** | `D` |
| **E** | `F` |
| **A** | `Z` |
| **0** | `X` |
| **B** | `C` |
| **F** | `V` |

## 📂 Estrutura do Projeto

- `src/main.odin`: Ponto de entrada, leitura de argumentos.
- `src/emulator/`: Lógica central do emulador (CPU, Memória, Instruções).
- `src/ui/`: Interface gráfica, loop de renderização e áudio com Raylib.
- `roms/`: Pasta sugerida para armazenar seus jogos.

## 📜 Licença

MIT. Ver o arquivo [LICENSE](https://github.com/sksdutra/odin8/blob/main/LICENSE).
