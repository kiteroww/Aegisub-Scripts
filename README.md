# Aegisub‑Scripts
Aegisub automation scripts

---

# ENGLISH

## Chronorow Master v2.0

**Chronorow Master** is the ultimate "Swiss Army Knife" for Aegisub. It combines timing verification, smart text splitting, and bulk editing tools into one massive macro. Version 2.0 integrates the **Hot Dog Utils** suite and **Marabunta** directly into the interface, plus it adds **LazyTimer** for automated timing workflows.

### Core Timing & Text Tools

| Tool | What it does |
|------|--------------|
| **Keyframe Seal [KF]** | Slaps a `[KF-E]` (end) or `[KF-S]` (start) tag if the line snaps exactly to a keyframe. |
| **Twin / Miss KF** | Tags `[Twin]` if there's another KF right before the current one, or `[Miss]` if you missed a KF nearby. |
| **Overtime / Overlap** | Flags lines that drag on too long or overlap with others. |
| **Lazy Timer** | **New!** Auto-timing magic using silence detection files (Cluster or Table modes). |
| **Divine Dividing** | Slices sentences at punctuation (.?!) or commas and reallocates time proportionally. |
| **Line Cleaver \N** | Chops lines at `\N` breaks and splits the duration evenly. |
| **Kana-Beat {\k}** | Generates `{\k}` karaoke tags from romaji text. |
| **CPS Ranker / Avg** | Sorts lines by speed (Char/Sec) and calculates the average for the selection. |
| **Gap Marker** | Hunts down "blinks" (tiny, annoying gaps) between subtitles. |
| **Extract KFs** | Helper to run FFmpeg + SCXvid to dump a keyframe log. |

### Hot Dog Utils (Editing Suite)
*Check the "Doggo Mode" box to run ONLY the selected Hot Dog tool. This ignores all other timing settings.*

| Utility | Description |
|---------|-------------|
| **LeBlanc Six** | Smart line breaking based on the actual video width. |
| **Style Sentinel** | Filters your selection by Style (lets you keep specific styles and nuke the rest). |
| **Caption Clarifier** | Cleans up the mess—removes brackets, parentheses, and extra whitespace. |
| **Time Picker** | Selects active dialogue lines within a specific time range (ignores comments). |
| **Extract / Reinsert Tags** | Moves tags `{...}` to the *Effect* field so you can edit text safely, then puts them back. |
| **Blank Eraser** | Wipes out empty lines that have no visible text. |
| **Add \an8** | Quick fix to slap `{\an8}` (top alignment) on selected lines. |
| **Punctuation** | Adds Spanish inverted marks (¡! ¿?) to your text automatically. |

### Marabunta (Sync & Import)
The content devourer. Paste `Dialogue:` lines from another script to sync data based on time overlaps.

| Mode | Function |
|------|----------|
| **Ant Effects** | Steals the *Effect* field from the pasted lines if they overlap in time. |
| **Ant Lines** | Grabs the *Text* from pasted lines (option to wrap as `{comments}`). |
| **Ant Actor** | Assigns the *Actor* field based on time overlap. |

---

## LazyTimer Setup

**LazyTimer** is the powerhouse of this suite, but it needs fuel to run. It relies on pre-generated silence and voice activity logs to make its decisions. Without these files, it won't work.

### Requirements

1.  **FFmpeg:** Must be installed and added to your system's `PATH`.
2.  **vadflux.exe:** Required for the advanced Voice Activity Detection and Spectral Flux analysis.
3.  **Generator Script:** Use the included `LazyTimer_Gen.bat` (formerly `RT 3.bat`).

### How to Generate the Logs

We've included a batch script (`LazyTimer_Gen.bat`) that automates the boring stuff. It performs audio pre-processing (highpass/lowpass filters and dynamic normalization) before analysis to ensure accurate timing.

1.  Drop your video/audio file, `vadflux.exe`, and the `.bat` script into the same folder.
2.  Run the `.bat` script.
3.  **Input 1:** Enter the filename (e.g., `video.mp4`).
4.  **Input 2:** Enter a chapter number or prefix (e.g., `01`).
5.  Wait for the process to finish. The script will generate:
    * `*_30.txt`, `*_40.txt`, `*_50.txt` (Silence logs at different dB thresholds).
    * `*_vad.tsv` (Voice Activity Detection data).
    * `*_flux.tsv` (Spectral Flux data).

### Usage in Aegisub

1.  Open **Chronorow Master** > **LazyTimer**.
2.  **Cluster Mode (Recommended):** Click the buttons to load the `-30dB`, `-40dB`, and `-50dB` files.
    * *(Optional but recommended)*: Load the `.tsv` files when prompted for VAD/Flux to improve accuracy.
3.  **Table Mode:** Only requires one silence file (usually the `-40dB` one).
4.  Hit **Run** and watch it retime your lines.

---

## Kite Styles Manager v3.4

**Kite Styles Manager** handles actor-specific coloring in Aegisub like a pro. It lets you apply colors via direct tags or by cloning styles, finds inconsistencies, and keeps your palette consistent across episodes.

### Main Features

| Macro | Description |
|-------|-------------|
| **Manage Colors** | The main hub. Assign or edit colors per actor. Choose between applying tags or cloning styles. |
| **Conflict Hunter** | Spots actors with mismatched colors (primary, outline, shadow, etc.). |
| **Scrub Tags** | Selectively wipes specific color tags from the lines. |
| **Deep Analysis** | Generates a report per actor: line count, colors in use, and WCAG contrast ratios. |
| **Styles → Tags** | Hardcodes the style's colors into the line as tags. |
| **Tags → Styles** | Creates a clone style ("BaseStyle_Actor") and moves the tag info into the style definition. |
| **Import / Export** | Save or load your color assignments from a `.txt` file. |

### What's new in v3.4
* Full support for VSFilterMod `vc()` tags.
* Automatic conflict detection and contrast calculation.
* Import/Export palettes to `.txt` files.
* Auto-creation of clone styles per actor.

---

# PORTUGUÊS

## Chronorow Master v2.0

**Chronorow Master** é o "canivete suíço" definitivo para Aegisub. Ele combina verificação de timing, divisão inteligente de texto e ferramentas de edição em massa numa macro robusta. A versão 2.0 integra o pacote **Hot Dog Utils** e o **Marabunta** diretamente na interface, além de adicionar o **LazyTimer** para fluxos de timing automatizados.

### Ferramentas de Texto e Timing

| Ferramenta | O que faz |
|------------|-----------|
| **Keyframe Seal [KF]** | Carimba uma tag `[KF-E]` (fim) ou `[KF-S]` (início) se a linha bater exatamente no keyframe. |
| **Twin / Miss KF** | Marca `[Twin]` se houver outro KF logo antes, ou `[Miss]` se você deixou passar um KF próximo. |
| **Overtime / Overlap** | Sinaliza linhas que duram tempo demais ou sobrepõem outras. |
| **Lazy Timer** | **Novo!** Timing automático usando arquivos de detecção de silêncio (modos Cluster ou Tabela). |
| **Divine Dividing** | Fatia frases na pontuação (.?!) ou vírgulas e redistribui o tempo proporcionalmente. |
| **Line Cleaver \N** | Corta as linhas nas quebras `\N` e divide a duração igualmente. |
| **Kana-Beat {\k}** | Gera tags de karaokê `{\k}` a partir de texto em romaji. |
| **CPS Ranker / Avg** | Ordena linhas por velocidade (Char/Seg) e calcula a média da seleção. |
| **Gap Marker** | Caça os "blinks" (aqueles gaps minúsculos e chatos) entre legendas. |
| **Extract KFs** | Ajuda a rodar FFmpeg + SCXvid para gerar o log de keyframes. |

### Hot Dog Utils (Suíte de Edição)
*Marque a caixa "Doggo Mode" para rodar APENAS a ferramenta Hot Dog selecionada. Isso ignora as outras configurações de timing.*

| Utilitário | Descrição |
|------------|-----------|
| **LeBlanc Six** | Quebra de linha inteligente baseada na largura real do vídeo. |
| **Style Sentinel** | Filtra sua seleção por Estilo (permite manter estilos específicos e apagar o resto). |
| **Caption Clarifier** | Limpa a bagunça — remove colchetes, parênteses e espaços extras. |
| **Time Picker** | Seleciona linhas de diálogo ativas num intervalo de tempo específico (ignora comentários). |
| **Extract / Reinsert Tags** | Move tags `{...}` para o campo *Effect* pra você editar o texto sem medo, depois devolve. |
| **Blank Eraser** | Apaga linhas vazias que não têm texto visível. |
| **Add \an8** | Jeito rápido de jogar a tag `{\an8}` (alinhamento topo) nas linhas selecionadas. |
| **Punctuation** | Adiciona os sinais invertidos de espanhol (¡! ¿?) ao texto automaticamente. |

### Marabunta (Sincronia e Importação)
O devorador de conteúdo. Cole linhas `Dialogue:` de outro script para sincronizar dados baseando-se na sobreposição de tempo.

| Modo | Função |
|------|--------|
| **Ant Effects** | Rouba o campo *Effect* das linhas coladas se elas coincidirem no tempo. |
| **Ant Lines** | Pega o *Texto* das linhas coladas (opção de envolver como `{comentários}`). |
| **Ant Actor** | Atribui o campo *Actor* baseado na sobreposição temporal. |

---

## Configuração do LazyTimer

O **LazyTimer** é o motorzão dessa suíte, mas precisa de combustível. Ele depende de logs pré-gerados de silêncio e atividade de voz. Sem esses arquivos, ele não funciona.

### Requisitos

1.  **FFmpeg:** Deve estar instalado e adicionado ao `PATH` do sistema.
2.  **vadflux.exe:** Necessário para a Detecção de Atividade de Voz (VAD) e análise de Fluxo Espectral.
3.  **Script Gerador:** Use o `LazyTimer_Gen.bat` incluso (antigo `RT 3.bat`).

### Como gerar os logs

Incluímos um script em lote (`LazyTimer_Gen.bat`) que automatiza a parte chata. Ele faz o pré-processamento de áudio (filtros highpass/lowpass e normalização dinâmica) antes da análise para garantir um timing preciso.

1.  Jogue seu arquivo de vídeo/áudio, o `vadflux.exe` e o script `.bat` na mesma pasta.
2.  Rode o script `.bat`.
3.  **Input 1:** Digite o nome do arquivo (ex: `video.mp4`).
4.  **Input 2:** Digite o número do capítulo ou prefixo (ex: `01`).
5.  Espere o processo terminar. O script vai gerar:
    * `*_30.txt`, `*_40.txt`, `*_50.txt` (Logs de silêncio em diferentes limiares de dB).
    * `*_vad.tsv` (Dados de VAD).
    * `*_flux.tsv` (Dados de Fluxo Espectral).

### Uso no Aegisub

1.  Abra **Chronorow Master** > **LazyTimer**.
2.  **Modo Cluster (Recomendado):** Clique nos botões para carregar os arquivos `-30dB`, `-40dB` e `-50dB`.
    * *(Opcional, mas recomendado)*: Carregue os arquivos `.tsv` quando pedir VAD/Flux para melhorar a precisão.
3.  **Modo Tabela:** Requer apenas um arquivo de silêncio (geralmente o de `-40dB`).
4.  Aperte **Run** e veja ele retimar suas linhas.

---

## Kite Styles Manager v3.4

O **Kite Styles Manager** automatiza a gestão de cores por ator nos arquivos ASS dentro do Aegisub. Ele permite aplicar cores via tags ou estilos clonados, caça inconsistências e mantém a paleta uniforme ao longo dos episódios.

### Funcionalidades Principais

| Macro | Descrição |
|-------|-----------|
| **Gerenciar Cores** | Painel principal para atribuir ou editar cores por ator. Escolha entre aplicar tags ou clonar estilos. |
| **Caçar Conflitos** | Detecta atores com cores inconsistentes (primário, borda, sombra, etc.). |
| **Limpar Tags** | Remove seletivamente as tags de cor indicadas. |
| **Análise Detalhada** | Relatório por ator: contagem de linhas, cores em uso e taxas de contraste (WCAG). |
| **Converter Estilos → Tags** | Insere as cores definidas no estilo diretamente na linha como tags. |
| **Converter Tags → Estilos** | Cria um estilo clone ("BaseStyle_Ator") e move as cores da tag para a definição do estilo. |
| **Importar / Exportar** | Salva ou carrega suas atribuições de cor de um arquivo `.txt`. |

### Novidades na v3.4
* Suporte total a tags `vc()` do VSFilterMod.
* Detecção automática de conflitos e cálculo de contraste.
* Importação e exportação de paletas em `.txt`.
* Criação automática de estilos clone por ator.

---

# ESPAÑOL

## Chronorow Master v2.0

**Chronorow Master** es la "navaja suiza" definitiva para Aegisub. Combina verificación de timing, división inteligente de texto y herramientas de edición masiva en una macro robusta. La versión 2.0 integra la suite **Hot Dog Utils** y **Marabunta** directamente en la interfaz, además de añadir **LazyTimer** para flujos de timing automatizados.

### Herramientas de Timing y Texto

| Herramienta | Qué hace |
|-------------|----------|
| **Keyframe Seal [KF]** | Te planta una etiqueta `[KF-E]` (final) o `[KF-S]` (inicio) si la línea clava exactamente el keyframe. |
| **Twin / Miss KF** | Marca `[Twin]` si hay otro KF justo antes, o `[Miss]` si se te escapó un KF cercano. |
| **Overtime / Overlap** | Señala líneas que duran demasiado o se pisan con otras. |
| **Lazy Timer** | **¡Nuevo!** Magia de auto-timing usando archivos de detección de silencio (modos Cluster o Tabla). |
| **Divine Dividing** | Corta frases en la puntuación (.?!) o comas y reparte el tiempo proporcionalmente. |
| **Line Cleaver \N** | Hacha las líneas en los saltos `\N` y divide la duración equitativamente. |
| **Kana-Beat {\k}** | Genera etiquetas de karaoke `{\k}` a partir de texto en romaji. |
| **CPS Ranker / Avg** | Ordena líneas por velocidad (Car/Seg) y calcula la media de la selección. |
| **Gap Marker** | Rastrea los "blinks" (esos huecos minúsculos y molestos) entre subtítulos. |
| **Extract KFs** | Ayuda a ejecutar FFmpeg + SCXvid para generar el log de keyframes. |

### Hot Dog Utils (Suite de Edición)
*Marca la casilla "Doggo Mode" para ejecutar SOLO la herramienta Hot Dog seleccionada. Esto ignora el resto de ajustes de timing.*

| Utilidad | Descripción |
|----------|-------------|
| **LeBlanc Six** | Salto de línea inteligente basado en el ancho real del vídeo. |
| **Style Sentinel** | Filtra tu selección por Estilo (te permite conservar estilos específicos y purgar el resto). |
| **Caption Clarifier** | Limpia el desorden: elimina corchetes, paréntesis y espacios extra. |
| **Time Picker** | Selecciona líneas de diálogo activas en un rango de tiempo específico (ignora comentarios). |
| **Extract / Reinsert Tags** | Mueve etiquetas `{...}` al campo *Effect* para que edites texto sin miedo, luego las devuelve. |
| **Blank Eraser** | Borra líneas vacías que no tienen texto visible. |
| **Add \an8** | Forma rápida de pegar la etiqueta `{\an8}` (alineación superior) a las líneas seleccionadas. |
| **Punctuation** | Añade los signos invertidos (¡! ¿?) al texto automáticamente. |

### Marabunta (Sincro e Importación)
El devorador de contenido. Pega líneas `Dialogue:` de otro script para sincronizar datos basándose en la superposición de tiempo.

| Modo | Función |
|------|--------|
| **Ant Effects** | Le roba el campo *Effect* a las líneas pegadas si coinciden en tiempo. |
| **Ant Lines** | Pilla el *Texto* de las líneas pegadas (opción de envolver como `{comentarios}`). |
| **Ant Actor** | Asigna el campo *Actor* basándose en la superposición temporal. |

---

## Configuración de LazyTimer

**LazyTimer** es el motor de esta suite, pero necesita gasolina. Depende de logs pre-generados de silencio y actividad de voz para tomar decisiones. Sin esos archivos, no arranca.

### Requisitos

1.  **FFmpeg:** Debe estar instalado y añadido al `PATH` del sistema.
2.  **vadflux.exe:** Necesario para la Detección de Actividad de Voz (VAD) y análisis de Flujo Espectral.
3.  **Script Generador:** Usa el `LazyTimer_Gen.bat` incluido (antes `RT 3.bat`).

### Cómo generar los logs

Hemos incluido un script por lotes (`LazyTimer_Gen.bat`) que automatiza lo tedioso. Realiza pre-procesamiento de audio (filtros highpass/lowpass y normalización dinámica) antes del análisis para asegurar un timing preciso.

1.  Tira tu archivo de vídeo/audio, el `vadflux.exe` y el script `.bat` en la misma carpeta.
2.  Ejecuta el script `.bat`.
3.  **Input 1:** Introduce el nombre del archivo (ej: `video.mp4`).
4.  **Input 2:** Introduce el número de capítulo o prefijo (ej: `01`).
5.  Espera a que termine el proceso. El script generará:
    * `*_30.txt`, `*_40.txt`, `*_50.txt` (Logs de silencio a diferentes umbrales de dB).
    * `*_vad.tsv` (Datos de VAD).
    * `*_flux.tsv` (Datos de Flujo Espectral).

### Uso en Aegisub

1.  Abre **Chronorow Master** > **LazyTimer**.
2.  **Modo Cluster (Recomendado):** Haz clic en los botones para cargar los archivos `-30dB`, `-40dB` y `-50dB`.
    * *(Opcional pero recomendado)*: Carga los archivos `.tsv` cuando pida VAD/Flux para mejorar la precisión.
3.  **Modo Tabla:** Requiere solo un archivo de silencio (usualmente el de `-40dB`).
4.  Dale a **Run** y mira cómo retimea tus líneas.

---

## Kite Styles Manager v3.4

**Kite Styles Manager** automatiza la gestión de colores por actor en archivos ASS dentro de Aegisub. Permite aplicar colores mediante tags o estilos clonados, detecta inconsistencias y mantiene una paleta uniforme a lo largo de los episodios.

### Funcionalidades principales

| Macro | Descripción |
|-------|-------------|
| **Gestionar colores** | Panel principal para asignar o editar colores por actor. Elige entre aplicar tags o clonar estilos. |
| **Buscar conflictos** | Detecta actores con colores incoherentes (primario, contorno, sombra, etc.). |
| **Limpiar tags** | Elimina selectivamente los tags de color indicados. |
| **Análisis detallado** | Informe por actor: número de líneas, colores en uso y relación de contraste (WCAG). |
| **Convertir estilos → tags** | Inserta en cada diálogo los colores definidos en su estilo como tags. |
| **Convertir tags → estilos** | Crea estilos clon ("EstiloBase_Actor") y traslada los colores de los tags a la definición del estilo. |
| **Importar / Exportar** | Guarda o carga asignaciones de color desde un archivo `.txt`. |

### Novedades en v3.4
* Soporte completo para tags `vc()` de VSFilterMod.
* Detección de conflictos y cálculo automático de contraste.
* Importación y exportación de paletas en `.txt`.
* Creación automática de estilos clon por actor.
