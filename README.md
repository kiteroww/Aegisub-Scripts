# Aegisub‑Scripts
Aegisub automation scripts

## Chronorow Master

Chronorow Master is an Aegisub macro that speeds up subtitle timing by stamping keyframes, splitting text intelligently, generating basic karaoke tags, and offering CPS utilities. It also detects blinks, extracts keyframes via FFmpeg + SCXvid, and ships with a ready‑to‑use “Kite” preset.

### Key Features

| Tool | Purpose |
|------|---------|
| **Keyframe Seal [KF]** | Adds `[KF]` if a line ends exactly on a video keyframe. |
| **Twin / Missing** | Tags `[Twin]` when a keyframe lies ≤ *window ms* before the end; `[Missing]` if no keyframe appears within that window. |
| **Overtime** | Marks `[Overtime]` on lines longer than a set duration. |
| **Overlap Alert** | Flags `[Overlap]` when subtitle lines overlap. |
| **Divine Dividing** | Splits sentences at punctuation and distributes time proportionally. |
| **Vision Only** | Previews splits by inserting `[2S]` / `[3S]` in *Effect* instead of cutting. |
| **Comma Blessed** | Treats commas and semicolons as extra split points. |
| **Line Cleaver (\N)** | Splits at each `\N`, dividing time evenly. |
| **Kana‑Beat ({\k})** | Generates `{\k}` tags from romaji syllables. |
| **CPS Ranker / Avg** | Sorts lines by characters‑per‑second and shows average CPS. |
| **Gap Marker** | Detects and labels brief gaps (“blinks”) shorter than *n ms*. |
| **Extract KFs** | Runs FFmpeg → SCXvid to create a keyframe `.log` file. |
| **Preset “Kite”** | Loads default values: Twin = 1000 ms, Missing = 1000 ms, Overtime = 5500 ms. |

### Quick Workflow

1. **Select** the subtitle lines you want to process.  
2. Open the dialog, tick the tools you need, and adjust the millisecond values.  
3. *(Optional)* Press **Kite** to pre‑load the recommended defaults.  
4. Click **Run** — everything can be undone with **Ctrl + Z**.

You can combine several tools in one pass (e.g. stamp keyframes, split sentences, and rank by CPS simultaneously).

### Tips

- *Keyframe Seal* and *Twin / Missing* require video loaded and a keyframe log present.  
- For *Gap Marker*, 50–250 ms is a good range to spot “blinks.”  
- The dialog starts clean on each run; no changes are made until you press **Run**. 

---

## Froggie Tags

### Description
A versatile Aegisub script that allows you to move ASS tags between the text and effects fields. This script is particularly useful for subtitle editors who need to temporarily store or manipulate tag information separately from the text content.

### Features
- **Extract Tags**: Moves initial tags (enclosed in curly braces) from the text field to the effects field.  
- **Reinsert Tags**: Moves tags from the effects field back to the text field.  
- **Automatic Format Conversion**: Converts semicolons (;) to commas (,) when reinserting tags, ensuring proper tag formatting.

### Usage
1. Select one or more subtitle lines in Aegisub.  
2. Run “Froggie Tags/Extract” to move tags to the effects field.  
3. Edit or manipulate the text content as needed.  
4. Run “Froggie Tags/Reinsert” to restore the tags to the text field.

---

## Kite Styles Manager v3.4

Kite Styles Manager automatiza la gestión de colores por actor en archivos ASS dentro de Aegisub. Permite aplicar colores mediante *tags* o estilos clonados, detectar inconsistencias y mantener una paleta uniforme a lo largo de varios episodios.

### Visión general
- **Cobertura completa**: maneja `\c`, `\1c–\4c` y sus equivalentes `\1vc–\4vc` (VSFilterMod).  
- **Aplicación selectiva**: actúa solo sobre las líneas que seleccione el usuario.  
- **Persistencia**: exporta e importa asignaciones en archivos `.txt` para reutilizarlas.

### Funcionalidades principales

| Macro | Descripción |
|-------|-------------|
| **Gestionar colores** | Ventana principal para asignar o editar colores por actor. Se puede elegir entre aplicar *tags* o clonar estilos. |
| **Buscar conflictos** | Detecta actores con colores incoherentes (primario, contorno, sombra, etc.). |
| **Limpiar tags** | Elimina selectivamente los tags de color indicados. |
| **Análisis detallado** | Informe por actor: número de líneas, colores en uso y relación (basado en WCAG). |
| **Convertir estilos → tags** | Inserta en cada diálogo los colores definidos en su estilo. |
| **Convertir tags → estilos** | Crea estilos clon (“EstiloBase_Actor”) y traslada los colores de los *tags*. |
| **Importar / Exportar** | Guarda o carga asignaciones de color desde un archivo `.txt`. |

### Cambios clave respecto a v1.4
- Soporte completo para tags `vc()` de VSFilterMod.  
- Detección de conflictos y cálculo automático de contraste.  
- Importación y exportación de paletas en `.txt`.  
- Creación automática de estilos clon por actor.

### Consejos de uso
- Ingrese colores como `#RRGGBB`; el script los convierte a BGR internamente. 

---

## Marabunta

**Marabunta** is an Aegisub macro that “devours” pasted subtitle lines and reapplies their info to the lines you have selected. It copies *Effect*, text, and actor data from external `Dialogue:` blocks, eliminating countless manual steps when you sync alternate versions or reuse styling from other files.

### Key Features

| Tool | What it does |
|------|--------------|
| **Ant Effects** | Finds time‑overlapping lines and appends the *effect* from the pasted reference to the selected line. If the line already has an *Effect*, both are merged using `; `. |
| **Ant Lines** | Inserts the reference text into the selected line:<br>• **Plain text** pastes it as is.<br>• **As comment** wraps it in `{}` so it stays hidden on‑screen. |
| **Ant Actor** | Assigns the actor whose line overlaps the most in time with each selected line. |

> All tools compare the `start` and `end` times of the pasted lines against the selected ones. If no time overlap exists, nothing is copied.

### Quick Workflow

1. **Select** the destination lines in your main script.  
2. Run **Marabunta** and choose the desired tool from the dropdown.  
3. Paste the `Dialogue:` lines that will serve as the template into the text box and click **Run**.  
4. Check the confirmation message — if the result isn’t what you wanted, just **Ctrl + Z** and try again.  
5. When using **Ant Lines**, pick *As comment* if you don’t want the reference text to appear on screen.
