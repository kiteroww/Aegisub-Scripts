script_name = "Chronorow Master"
script_description = "Ultimate Timing & Styling Suite"
script_author = "Kiterow"
script_version = "3.0"
menu_embedding = "Kite-Macros/"
include("karaskel.lua")
local LANG = {
    en = {
        btn_execute = "EXECUTE", btn_kpp = "KPP", btn_lazy = "LazyTimer",
        btn_extract_kf = "Extract KF", btn_config = "Config",
        lbl_kite_audit = "Kite Audit:", hint_kite_audit = "Select mode to run on Execute",
        lbl_comment_purge = "C. Purge:", hint_comment_purge = "Handle commented lines",
        dd_cp_delete = "Delete", dd_cp_start = "Move to Start", dd_cp_end = "Move to End",
        tool_blank = "Blank Eraser (Clear text)", tool_join = "Join Same Text (Merge lines)",
        tool_time = "Time Picker (Select by time)", tool_style = "Style Sentinel (Filter/Del)",
        tool_caption = "Caption Clarifier (Rm [notes])", tool_leblanc = "LeBlanc Six (Inject Line Breaks \\N)",
        tool_copyt = "Copy Times (From 1st line)", tool_extt = "Extract Tags (Move to Effect)",
        tool_inst = "Reinsert Tags (From Effect)", tool_sort = "Sort by Length (Longest 1st)",
        tool_p_ex = "Punctuation ¡! (Add inverted)", tool_p_qu = "Punctuation ¿? (Add inverted)",
        tool_p_both = "Punctuation ¡! & ¿? (Add both)", tool_swap = "Swap Comment (Text <-> {Comm})",
        tool_an8 = "Add an8 (Top align)", tool_fold = "Copy Fold Group (To clipboard)",
        tool_dital = "Double Italics (Fix \\i1...\\i0)", tool_fte = "Frame to Effect (Start Frame)",
        tool_transplant = "Import Text (Source Timing)",
        tool_ellipsis = "Ellipsis Eraser (Clean ...)",
        tool_dramaturgy = "Actor Parser (Split & Format)",
        tool_motion = "AE Keyframe Export (Full Data) [Log]",
        tool_stutter = "Stutter Manager (Auto/TT Check)",
        tool_actor_rep = "Actor Manager (Rename/Merge)",
        tool_kitetiming = "Kite Timing (Lead-in/out + KF Snap)",
        tool_remplacer = "Remplacer (Text Replacer)",
        lbl_kpp_title = "KPP v5.0 (FPS: %s)",
        lbl_timing = "Timing (frames)",
        lbl_leadin = "Lead-in:", lbl_leadout = "Lead-out:", lbl_kfsnap = "KF snap range:",
        lbl_chaining = "─── Chaining (frames) ──────────────────────────────────────────",
        lbl_chainmax = "Chain max gap:", lbl_kfchain = "KF chain dist:",
        lbl_ignore_comments = "Ignore comments", lbl_mark_changes = "Mark in Effect",
        lbl_show_stats = "Show statistics", btn_process = "Process",
        msg_kpp_done = "KPP v5 Done!\n\nModified: %d\nKF snap start: %d\nKF snap end: %d\nChained: %d",
        btn_help = "HELP", btn_cancel = "Cancel", btn_ok = "OK", btn_save = "Save",
        btn_yes = "Yes", btn_no = "No", btn_continue = "Continue",
        btn_mark_gaps = "Mark Gaps", btn_filter = "Filter", btn_proceed = "Yes, proceed",
        lbl_apply_to = "Apply to:", lbl_mode = "Mode:", lbl_twin_kf = "Twin KF (ms):",
        lbl_miss_kf = "Miss KF (ms):", lbl_overtime = "Max Duration (ms):",
        lbl_timing_markers = "──── TIMING & MARKERS ────",
        lbl_cps_tools = "─── CPS Tools ───", lbl_text_tools = "──── TEXT TOOLS ────",
        lbl_other_tools = "─── Other Tools ───", lbl_utility = "─── Utility ───",
        lbl_marabunta = "─── MARABUNTA ───",lbl_divine_dividing = "Divine Dividing:",
        lbl_gap_marker = "Gap Marker - Detect subtitle blinks",
        lbl_max_gap = "Max gap (ms):", lbl_custom_tag = "Custom tag:",
        lbl_selected_lines = "Selected: %d lines",
        lbl_format_dialogue = "Format: Dialogue: L,Start,End,...",
        lbl_language = "Language:",
        lbl_header_timing = "═══ TIMING AUDIT MODULE ═══════════════",
        lbl_header_text = "══ TEXT PROCESSING ENGINE ═══════════════",
        lbl_header_data = "DATA IMPORT (MARABUNTA)",
        lbl_header_cps = "CPS METRICS",
        lbl_header_tools = "QUICK TOOLS:",
        lbl_sep_h = "───────────────────────────────────────────────────────────────────────────────",
        lbl_close_left = "═══════════════════════════════════════",
        lbl_close_mid = "═",
        lbl_close_right = "═══════════════════════════════════════",
        lbl_filter = "Filter:",
        chk_keyframe_seal = "Keyframe Seal", chk_overlap_alert = "Overlap Alert",
        chk_gap_marker = "Gap Marker (auto)", chk_mark_uppercase = "Mark Uppercase",
        chk_cps_ranker = "CPS Ranker", chk_show_avg = "Show Avg",
        chk_divide = "  Divide (.?!)", chk_preview = "  Preview",
        chk_include_commas = "  Include commas", chk_line_cleaver = "Line Cleaver \\N",
        chk_kana_beat = "Kana-Beat {\\k}", chk_mark_miss_punct = "Mark Miss Punct",
        chk_as_comment = "As comment {...}",
        chk_mark_continuous = "Also mark continuous lines (gap = 0ms)",
        chk_ignore_keyframes = "Ignore when previous line ends on keyframe",
        dd_all_selected = "All Selected", dd_by_style = "By Style", dd_by_actor = "By Actor",
        dd_by_effect = "By Effect", dd_by_layer = "By Layer",
        dd_end_only = "End Only", dd_start_only = "Start Only", dd_both = "Both",
        dd_ant_effects = "Ant Effects", dd_ant_lines = "Ant Lines", dd_ant_actor = "Ant Actor",
        dd_ant_songs = "Ant Songs", dd_ant_twins = "Ant Twins",
        err_no_selection = "No selection",
        err_no_tool = "Error: Must select a tool\nfrom Utility menu.",
        err_not_fold = "Selected line is not a fold marker.\nPosition cursor on line with {=N}.",
        err_invalid_twin = "Twin KF must be a number ≥ 0",
        err_invalid_miss = "Miss KF must be a number ≥ 0",
        err_invalid_ov = "Overtime must be a number ≥ 0",
        err_filter_zero = "Filter resulted in 0 lines.",
        err_avoid_combo = "⚠ Avoid combining Divine Dividing\nwith Line Cleaver (duplicates)",
        err_invalid_gap = "Invalid gap value",
        err_must_specify_tag = "Must specify a tag",
        err_need_two_lines = "Need 2+ lines\nfor this operation",
        err_no_video = "No video loaded.",
        err_scxvid_not_found = "SCXvid not found:\n%s",
        err_ffmpeg_not_found = "FFmpeg not found:\n%s",
        msg_tagged_lines = "Tagged %d lines.",
        msg_deleted_lines = "Deleted %d lines.",
        msg_process_started = "Process started.\nLog: %s",
        msg_avg_cps = "Average CPS (%d lines): %.2f",
        msg_fold_copied = "Fold copied (%d lines)",
        msg_time_range = "%s - %s | %s | %d lines",
        msg_config_saved = "Configuration saved successfully!",
        hint_filter_value = "Filter value (style, actor, etc.)",
        hint_mode = "End Only: end only | Start Only: start only | Both: both",
        hint_twin_kf = "Twin KF detection. 0=off, 500-1000 rec",
        hint_miss_kf = "Miss KF detection. 0=off, 500-1000 rec",
        hint_overtime = "Marks lines longer than X ms. 0=disabled",
        hint_keyframe_seal = "Marks lines ending on keyframe",
        hint_overlap_alert = "Marks overlapping lines",
        hint_gap_marker = "Mark small gaps. Config in menu.",
        hint_mark_uppercase = "Marks lines in CAPITALS",
        hint_cps_ranker = "Sorts lines by CPS",
        hint_show_avg = "Show average CPS of selection",
        hint_divide = "Divides by sentence delimiters",
        hint_preview = "Only mark [NS], no actual divide",
        hint_include_commas = "Also divide by commas/hyphens",
        hint_line_cleaver = "Divide by backslash-N",
        hint_kana_beat = "Karaoke timing from romaji",
        hint_mark_miss_punct = "Mark missing final punctuation",
        hint_utility = "Quick tools: select one and press Execute to run",
        hint_marabunta = "Paste Dialogue. Songs: L50 sync.",
        hint_marabunta_mode = "Import format mode",
        hint_as_comment = "Import as comment {...}",
        lbl_transplant_mode = "Import Text Source:",
        hint_transplant_mode = "Box: Paste into dialog | Clipboard: Read system clipboard",
        tt_box_title = "Import Text (Source Timing)",
        tt_box_label = "Paste lines here (Timing will be taken from selection):",
        tt_err_invalid = "No content to import.",
        lbl_actor_replace = "ACTOR MANAGER",
        lbl_original = "Original",
        lbl_new = "New (Leave empty to keep)",
        msg_actors_replaced = "Updated %d actors in %d lines.",
        btn_copy = "Copy", btn_paste = "Paste", btn_time = "Time",
        lbl_focus = "Focus:", lbl_active_line = "Active Line:",
        chk_video = "Video", chk_audio = "Audio",
        msg_macros_loaded = "Macros loaded",
    },
    es = {
        btn_execute = "EJECUTAR", btn_kpp = "KPP", btn_lazy = "LazyTimer",
        btn_extract_kf = "Extraer KF", btn_config = "Config",
        lbl_kite_audit = "Kite Audit:", hint_kite_audit = "Modo de auditoría al Ejecutar",
        lbl_comment_purge = "C. Purge:", hint_comment_purge = "Manejar líneas comentadas",
        dd_cp_delete = "Borrar", dd_cp_start = "Mover al inicio", dd_cp_end = "Mover al final",
        tool_blank = "Borrar Vacías (Elimina líneas)", tool_join = "Unir Texto (Fusiona idénticos)",
        tool_time = "Selector Tiempo (Sel. por tiempo)", tool_style = "Centinela Estilo (Filtra/Borra)",
        tool_caption = "Clarificador (Quita [notas])", tool_leblanc = "LeBlanc Six (Insertar saltos \\N)",
        tool_copyt = "Copiar Tiempos (De 1ra línea)", tool_extt = "Extraer Tags (Mover a Effect)",
        tool_inst = "Reinsertar Tags (Desde Effect)", tool_sort = "Ordenar Longitud (Largo 1ro)",
        tool_p_ex = "Puntuación ¡! (Añadir invertido)", tool_p_qu = "Puntuación ¿? (Añadir invertido)",
        tool_p_both = "Puntuación Ambos (Añadir ambos)", tool_swap = "Intercambiar (Texto <-> {Com})",
        tool_an8 = "Añadir an8 (Alinear arriba)", tool_fold = "Copiar Grupo (Al portapapeles)",
        tool_dital = "Doble Cursiva (Corrige \\i1)", tool_fte = "Frame a Effect (Frame inicial)",
        tool_transplant = "Import Text (Source Timing)",
        tool_ellipsis = "Ellipsis Eraser (Clean ...)",
        tool_dramaturgy = "Actor Parser (Split & Format)",
        tool_motion = "AE Keyframe Export (Full Data) [Log]",
        tool_stutter = "Stutter Manager (Auto/TT Check)",
        tool_actor_rep = "Actor Manager (Rename/Merge)",
        tool_kitetiming = "Kite Timing (Lead-in/out + KF Snap)",
        tool_remplacer = "Remplacer (Reemplazar Texto)",
        lbl_kpp_title = "KPP v5.0 (FPS: %s)",
        lbl_timing = "Timing (frames)",
        lbl_leadin = "Lead-in:", lbl_leadout = "Lead-out:", lbl_kfsnap = "Rango Snap KF:",
        lbl_chaining = "─── Encadenado (frames) ────────────────────────────────────────",
        lbl_chainmax = "Max Gap Chain:", lbl_kfchain = "Dist Chain KF:",
        lbl_ignore_comments = "Ignorar comentarios", lbl_mark_changes = "Marcar en Effect",
        lbl_show_stats = "Mostrar estadísticas", btn_process = "Procesar",
        msg_kpp_done = "KPP v5 Finalizado!\n\nModificados: %d\nKF snap inicio: %d\nKF snap fin: %d\nEncadenados: %d",
        btn_help = "AYUDA", btn_cancel = "Cancelar", btn_ok = "OK", btn_save = "Guardar",
        btn_yes = "Sí", btn_no = "No", btn_continue = "Continuar",
        btn_mark_gaps = "Marcar Gaps", btn_filter = "Filtrar", btn_proceed = "Sí, proceder",
        lbl_apply_to = "Aplicar a:", lbl_mode = "Modo:", lbl_twin_kf = "Twin KF (ms):",
        lbl_miss_kf = "Miss KF (ms):", lbl_overtime = "Duración Máx (ms):",
        lbl_timing_markers = "──── TIMING Y MARCADORES ────",
        lbl_cps_tools = "─── Herram. CPS ───", lbl_text_tools = "──── HERRAM. TEXTO ────",
        lbl_other_tools = "─── Otras Herram. ───", lbl_utility = "─── Utilidad ───",
        lbl_marabunta = "─── MARABUNTA ───", lbl_divine_dividing = "Divine Dividing:",
        lbl_gap_marker = "Gap Marker - Detectar parpadeos de subtítulos",
        lbl_max_gap = "Gap máximo (ms):", lbl_custom_tag = "Etiqueta personal:",
        lbl_selected_lines = "Seleccionadas: %d líneas",
        lbl_format_dialogue = "Formato: Dialogue: L,Inicio,Fin,...",
        lbl_language = "Idioma:",
        lbl_header_timing = "═══ MÓDULO AUDITORÍA TIMING ═══════════",
        lbl_header_text = "══ PROCESAMIENTO DE TEXTO ═══════════════",
        lbl_header_data = "IMPORTAR DATOS (MARABUNTA)",
        lbl_header_cps = "MÉTRICAS CPS",
        lbl_header_tools = "HERRAMIENTAS:",
        lbl_sep_h = "───────────────────────────────────────────────────────────────────────────────",
        lbl_close_left = "═══════════════════════════════════════",
        lbl_close_mid = "═",
        lbl_close_right = "═══════════════════════════════════════",
        lbl_filter = "Filtro:",
        chk_keyframe_seal = "Sello Keyframe", chk_overlap_alert = "Alerta Solapam.",
        chk_gap_marker = "Gap Marker (auto)", chk_mark_uppercase = "Marcar Mayúsc.",
        chk_cps_ranker = "Ranker CPS", chk_show_avg = "Mostrar Prom.",
        chk_divide = "  Dividir (.?!)", chk_preview = "  Previsualizar",chk_include_commas = "  Incluir comas", chk_line_cleaver = "Line Cleaver \\N",
        chk_kana_beat = "Kana-Beat {\\k}", chk_mark_miss_punct = "Marcar Falta Punt.",
        chk_as_comment = "Como comentario {...}",
        chk_mark_continuous = "También marcar líneas continuas (gap = 0ms)",
        chk_ignore_keyframes = "Ignorar cuando línea anterior termina en keyframe",
        dd_all_selected = "Todo Seleccionado", dd_by_style = "Por Estilo", dd_by_actor = "Por Actor",
        dd_by_effect = "Por Efecto", dd_by_layer = "Por Capa",
        dd_end_only = "Solo Fin", dd_start_only = "Solo Inicio", dd_both = "Ambos",
        dd_ant_effects = "Ant Effects", dd_ant_lines = "Ant Lines", dd_ant_actor = "Ant Actor",
        dd_ant_songs = "Ant Songs", dd_ant_twins = "Ant Twins",
        err_no_selection = "Sin selección",
        err_no_tool = "Error: Debe seleccionar herramienta\ndel menú Utilidad.",
        err_not_fold = "No es un marcador de fold.\nUsar línea con {=N}.",
        err_invalid_twin = "Twin KF debe ser un número ≥ 0",
        err_invalid_miss = "Miss KF debe ser un número ≥ 0",
        err_invalid_ov = "Overtime debe ser un número ≥ 0",
        err_filter_zero = "El filtro resultó en 0 líneas.",
        err_avoid_combo = "⚠ Evitar combinar Divine Dividing\ncon Line Cleaver (duplicará)",
        err_invalid_gap = "Valor de gap inválido",
        err_must_specify_tag = "Debe especificar una etiqueta",
        err_need_two_lines = "Se necesitan 2+ líneas\npara esta operación",
        err_no_video = "No hay video cargado.",
        err_scxvid_not_found = "SCXvid no encontrado:\n%s",
        err_ffmpeg_not_found = "FFmpeg no encontrado:\n%s",
        msg_tagged_lines = "Etiquetadas %d líneas.",
        msg_deleted_lines = "Eliminadas %d líneas.",
        msg_process_started = "Proceso iniciado.\nLog: %s",
        msg_avg_cps = "CPS promedio (%d líneas): %.2f",
        msg_fold_copied = "Fold copiado (%d líneas)",
        msg_time_range = "%s - %s | %s | %d líneas",
        msg_config_saved = "¡Configuración guardada exitosamente!",
        hint_filter_value = "Valor de filtro (estilo, actor, etc.)",
        hint_mode = "Solo Fin: solo final | Solo Inicio: solo inicio | Ambos: ambos",
        hint_twin_kf = "Detecta KF gemelos. 0=off, 500-1000 rec",
        hint_miss_kf = "Detecta KF perdidos. 0=off, 500-1000 rec",
        hint_overtime = "Marca líneas más largas que X ms. 0=desactivado",
        hint_keyframe_seal = "Marca líneas que terminan en keyframe",
        hint_overlap_alert = "Marca líneas superpuestas",
        hint_gap_marker = "Marcar gaps. Config en menú.",
        hint_mark_uppercase = "Marca líneas en MAYÚSCULAS",
        hint_cps_ranker = "Ordena líneas por CPS",
        hint_show_avg = "Muestra CPS promedio de selección",
        hint_divide = "Divide por delimitadores de oración",
        hint_preview = "Solo marcar [NS], sin dividir",
        hint_include_commas = "También dividir por comas/guiones",
        hint_line_cleaver = "Dividir por barra-N",
        hint_kana_beat = "Timing karaoke desde romaji",
        hint_mark_miss_punct = "Marcar puntuación final faltante",
        hint_utility = "Herramientas rápidas: selecciona una y pulsa Ejecutar",
        hint_marabunta = "Pegar Dialogue. Songs: L50 sincro.",
        hint_marabunta_mode = "Modo de formato de importación",
        hint_as_comment = "Importar como comentario {...}",
        lbl_transplant_mode = "Fuente Importar Texto:",
        hint_transplant_mode = "Caja: Pegar en diálogo | Portapapeles: Leer del sistema",
        tt_box_title = "Importar Texto (Tiempos Origen)",
        tt_box_label = "Pega líneas aquí (Tiempos se toman de selección):",
        tt_err_invalid = "Sin contenido para importar.",
        lbl_actor_replace = "GESTOR ACTORES",
        lbl_original = "Original",
        lbl_new = "Nuevo (Vacío para mantener)",
        msg_actors_replaced = "Actualizados %d actores en %d líneas.",
        btn_copy = "Copiar", btn_paste = "Pegar", btn_time = "Tiempo",
        lbl_focus = "Foco:", lbl_active_line = "Línea Activa:",
        chk_video = "Video", chk_audio = "Audio",
        msg_macros_loaded = "Macros cargadas",
    },
    pt = {
        btn_execute = "EXECUTAR", btn_kpp = "KPP", btn_lazy = "LazyTimer",
        btn_extract_kf = "Extrair KF", btn_config = "Config",
        lbl_kite_audit = "Kite Audit:", hint_kite_audit = "Modo de auditoria ao Executar",
        lbl_comment_purge = "C. Purge:", hint_comment_purge = "Lidar com linhas comentadas",
        dd_cp_delete = "Apagar", dd_cp_start = "Mover p/ Início", dd_cp_end = "Mover p/ Final",
        tool_blank = "Apagar Vazias (Remove linhas)", tool_join = "Unir Texto (Mescla idênticos)",
        tool_time = "Seletor Tempo (Sel. por tempo)", tool_style = "Sentinela Estilo (Filtra/Apaga)",
        tool_caption = "Clarificador (Remove [notas])", tool_leblanc = "LeBlanc Six (Inserir quebras \\N)",
        tool_copyt = "Copiar Tempos (Da 1ª linha)", tool_extt = "Extrair Tags (Mover p/ Effect)",
        tool_inst = "Reinserir Tags (Do Effect)", tool_sort = "Ordenar Comprimento (Longo 1º)",
        tool_p_ex = "Pontuação ¡! (Add invertido)", tool_p_qu = "Pontuação ¿? (Add invertido)",
        tool_p_both = "Pontuação Ambos (Add ambos)", tool_swap = "Trocar (Texto <-> {Com})",
        tool_an8 = "Add an8 (Alinear topo)", tool_fold = "Copiar Grupo (P/ àrea transf.)",
        tool_dital = "Duplo Itálico (Corrige \\i1)", tool_fte = "Frame p/ Effect (Frame inicial)",
        tool_transplant = "Importar Texto (Tempos Origem)",
        tool_ellipsis = "Apagar Reticências (Limpar ...)",
        tool_dramaturgy = "Processar Atores (Dividir/Formato)",
        tool_motion = "Exportar Keyframes AE (Dados Completos)",
        tool_stutter = "Gerador Gagueira (L-Lpalavra)",
        tool_actor_rep = "Gerenciador Atores (Unir/Renomear)",
        tool_kitetiming = "Kite Timing (Lead-in/out + KF Snap)",
        tool_remplacer = "Remplacer (Substituir Texto)",
        lbl_kpp_title = "KPP v5.0 (FPS: %s)",
        lbl_timing = "Timing (frames)",
        lbl_leadin = "Lead-in:", lbl_leadout = "Lead-out:", lbl_kfsnap = "Alcance Snap KF:",
        lbl_chaining = "─── Encadeamento (frames) ──────────────────────────────────────",
        lbl_chainmax = "Max Gap Chain:", lbl_kfchain = "Dist Chain KF:",
        lbl_ignore_comments = "Ignorar comentários", lbl_mark_changes = "Marcar em Effect",
        lbl_show_stats = "Mostrar estatísticas", btn_process = "Processar",
        msg_kpp_done = "KPP v5 Concluído!\n\nModificados: %d\nKF snap início: %d\nKF snap fim: %d\nEncadeados: %d",
        btn_help = "AJUDA", btn_cancel = "Cancelar", btn_ok = "OK", btn_save = "Salvar",
        btn_yes = "Sim", btn_no = "Não", btn_continue = "Continuar",
        btn_mark_gaps = "Marcar Gaps", btn_filter = "Filtrar", btn_proceed = "Sim, prosseguir",
        lbl_apply_to = "Aplicar em:", lbl_mode = "Modo:", lbl_twin_kf = "Twin KF (ms):",
        lbl_miss_kf = "Miss KF (ms):", lbl_overtime = "Duração Máx (ms):",
        lbl_timing_markers = "──── TIMING E MARCADORES ────",
        lbl_cps_tools = "─── Ferram. CPS ───", lbl_text_tools = "──── FERRAM. TEXTO ────",
        lbl_other_tools = "─── Outras Ferram. ───", lbl_utility = "─── Utilidade ───",
        lbl_marabunta = "─── MARABUNTA ───", lbl_divine_dividing = "Divine Dividing:",
        lbl_gap_marker = "Gap Marker - Detectar piscadas de legendas",
        lbl_max_gap = "Gap máximo (ms):", lbl_custom_tag = "Tag personalizada:",
        lbl_selected_lines = "Selecionadas: %d linhas",
        lbl_format_dialogue = "Formato: Dialogue: L,Início,Fim,...",
        lbl_language = "Idioma:",
        lbl_header_timing = "═══ MÓDULO AUDITORIA TIMING ═══════════",
        lbl_header_text = "══ PROCESSAMENTO DE TEXTO ═══════════════",
        lbl_header_data = "IMPORTAR DADOS (MARABUNTA)",
        lbl_header_cps = "MÉTRICAS CPS",
        lbl_header_tools = "FERRAMENTAS:",
        lbl_sep_h = "───────────────────────────────────────────────────────────────────────────────",
        lbl_close_left = "═══════════════════════════════════════",
        lbl_close_mid = "═",
        lbl_close_right = "═══════════════════════════════════════",
        lbl_filter = "Filtro:",
        chk_keyframe_seal = "Selo Keyframe", chk_overlap_alert = "Alerta Sobrep.",
        chk_gap_marker = "Gap Marker (auto)", chk_mark_uppercase = "Marcar Maiúsc.",
        chk_cps_ranker = "Ranker CPS", chk_show_avg = "Mostrar Média",
        chk_divide = "  Dividir (.?!)", chk_preview = "  Pré-visualizar",
        chk_include_commas = "  Incluir vírgulas", chk_line_cleaver = "Line Cleaver \\N",
        chk_kana_beat = "Kana-Beat {\\k}", chk_mark_miss_punct = "Marcar Falta Pont.",
        chk_as_comment = "Como comentário {...}",
        chk_mark_continuous = "Também marcar linhas contínuas (gap = 0ms)",
        lbl_transplant_mode = "Fonte Importar Texto:",
        hint_transplant_mode = "Caixa: Colar no diálogo | Área Transf: Ler do sistema",
        tt_box_title = "Importar Texto (Tempos Origem)",
        tt_box_label = "Cole linhas aqui (Tempos vêm da seleção):",
        tt_err_invalid = "Sem conteúdo para importar.",
        lbl_actor_replace = "GERENCIADOR ATORES",
        lbl_original = "Original",
        lbl_new = "Novo (Deixe vazio p/ manter)",
        msg_actors_replaced = "Atualizados %d atores em %d linhas.",
        chk_ignore_keyframes = "Ignorar quando linha anterior termina em keyframe",
        dd_all_selected = "Tudo Selecionado", dd_by_style = "Por Estilo", dd_by_actor = "Por Ator",
        dd_by_effect = "Por Efeito", dd_by_layer = "Por Camada",
        dd_end_only = "Apenas Fim", dd_start_only = "Apenas Início", dd_both = "Ambos",
        dd_ant_effects = "Ant Effects", dd_ant_lines = "Ant Lines", dd_ant_actor = "Ant Actor",
        dd_ant_songs = "Ant Songs", dd_ant_twins = "Ant Twins",
        err_no_selection = "Sem seleção",
        err_no_tool = "Erro: Deve selecionar ferramenta\ndo menu Utilidade.",
        err_not_fold = "Não é um marcador fold.\nUse linha com {=N}.",
        err_invalid_twin = "Twin KF deve ser um número ≥ 0",
        err_invalid_miss = "Miss KF deve ser um número ≥ 0",
        err_invalid_ov = "Overtime deve ser um número ≥ 0",
        err_filter_zero = "Filtro resultou em 0 linhas.",
        err_avoid_combo = "⚠ Evitar combinar Divine Dividing\ncom Line Cleaver (duplicará)",
        err_invalid_gap = "Valor de gap inválido",
        err_must_specify_tag = "Deve especificar uma tag",
        err_need_two_lines = "Precisa 2+ linhas\npara esta operação",
        err_no_video = "Nenhum vídeo carregado.",
        err_scxvid_not_found = "SCXvid não encontrado:\n%s",
        err_ffmpeg_not_found = "FFmpeg não encontrado:\n%s",
        msg_tagged_lines = "Marcadas %d linhas.",
        msg_deleted_lines = "Deletadas %d linhas.",
        msg_process_started = "Proceso iniciado.\nLog: %s",
        msg_avg_cps = "CPS média (%d linhas): %.2f",
        msg_fold_copied = "Fold copiado (%d linhas)",
        msg_time_range = "%s - %s | %s | %d linhas",
        msg_config_saved = "Configuração salva com sucesso!",
        hint_filter_value = "Valor do filtro (estilo, ator, etc.)",
        hint_mode = "Apenas Fim: apenas final | Apenas Início: apenas início | Ambos: ambos",
        hint_twin_kf = "Detecta KF gêmeos. 0=off, 500-1000 rec",
        hint_miss_kf = "Detecta KF perdidos. 0=off, 500-1000 rec",
        hint_overtime = "Marca linhas mais longas que X ms. 0=desativado",
        hint_keyframe_seal = "Marca linhas que terminam em keyframe",
        hint_overlap_alert = "Marca linhas sobrepostas",
        hint_gap_marker = "Marcar gaps. Config em menu.",
        hint_mark_uppercase = "Marca linhas em MAIÚSCULAS",
        hint_cps_ranker = "Ordena linhas por CPS",
        hint_show_avg = "Mostra CPS média da seleção",
        hint_divide = "Divide por delimitadores de frase",
        hint_preview = "Apenas marcar [NS], sem dividir",
        hint_include_commas = "Também dividir por vírgulas/hífens",
        hint_line_cleaver = "Dividir por barra-N",
        hint_kana_beat = "Timing karaoke de romaji",
        hint_mark_miss_punct = "Marcar pontuação final faltante",
        hint_utility = "Ferramentas rápidas: selecione uma e clique Executar",
        hint_marabunta = "Colar Dialogue. Songs: L50 sincro.",
        hint_marabunta_mode = "Modo de formato de importação",
        hint_as_comment = "Importar como comentário {...}",
        btn_copy = "Copiar", btn_paste = "Colar", btn_time = "Tempo",
        lbl_focus = "Foco:", lbl_active_line = "Linha Ativa:",
        chk_video = "Vídeo", chk_audio = "Áudio",
        msg_macros_loaded = "Macros carregadas",
    }
}
local current_lang = "en"
local function L(key)
    return (LANG[current_lang] and LANG[current_lang][key]) or LANG["en"][key] or key
end
local DEFAULT_CONFIG = {
    language = "en",
    lazy_method = "Cluster (±ms)",
    lazy_limit = "800",
    lazy_apply_start = true,
    lazy_apply_end = true,
    lazy_enable_tagging = true,
    lazy_tag_mode = "Both",
    lazy_tag_scope = "Both",
    gap_max_gap = "300",
    gap_ignore_keyframes = false,
    gap_mark_continuous = false,
    gap_tag = "SmallGap",
    scxvid_path = "",
    ffmpeg_path = "",
    scxvid_suffix = "_keyframes.log",
    time_transplant_mode = "Box",
    lead_in_f = 4,
    lead_out_f = 8,
    kf_snap_f = 14,
    chain_max_f = 19,
    kf_chain_f = 7,
    ignore_comments = true,
    mark_changes = true,
    show_stats = true,
    style_filter = "All",
    extra_style = "",
    kt_lead_in_base = 150,
    kt_lead_in_max = 300,
    kt_lead_out_base = 350,
    kt_lead_out_max = 600,
    kt_lead_out_chain = 500,
    kt_chain_gap_max = 800,
}
local current_config = {}
local config_path = aegisub.decode_path("?user/chronorow_config.lua")
local function loadConfig()
    local f = io.open(config_path, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local chunk, err = loadstring("return " .. content)
        if chunk then
            local success, loaded = pcall(chunk)
            if success and type(loaded) == "table" then
                current_config = loaded
                for k, v in pairs(DEFAULT_CONFIG) do
                    if current_config[k] == nil then
                        current_config[k] = v
                    end
                end
                current_lang = current_config.language or "en"
                return true
            end
        end
    end
    current_config = {} 
    for k, v in pairs(DEFAULT_CONFIG) do
        current_config[k] = v
    end
    current_lang = "en"
    return false
end
local function saveConfig()
    local f = io.open(config_path, "w")
    if not f then return false end
    f:write("{\n")
    for k, v in pairs(current_config) do
        if type(v) == "string" then
            f:write(string.format("    %s = %q,\n", k, v))
        elseif type(v) == "boolean" then
            f:write(string.format("    %s = %s,\n", k, tostring(v)))
        else
            f:write(string.format("    %s = %s,\n", k, tostring(v)))
        end
    end
    f:write("}\n")
    f:close()
    return true
end
loadConfig()
local unicode = aegisub.unicode or {}
local DEBUG = false
local function log(msg) if DEBUG then aegisub.debug.out(msg.."\n") end end
local function showMsg(msg) aegisub.dialog.display({{class="label",label=msg,x=0,y=0,width=25,height=4}},{L("btn_ok")}) end
local function showConfigDialog()
    local lang_display = current_config.language == "es" and "Español" 
                        or current_config.language == "pt" and "Português" 
                        or "English"
    local dlg = {
        {class="label", label=L("lbl_language"), x=0, y=0, width=2, height=1},
        {class="dropdown", name="language", 
         items={"English", "Español", "Português"}, 
         value=lang_display, x=2, y=0, width=2, height=1},
        {class="label", label="─── LazyTimer (EFS v2) ───", x=0, y=1, width=4, height=1},
        {class="label", label="Method:", x=0, y=2, width=1, height=1},
        {class="dropdown", name="lazy_method", 
         items={"LazyFusion", "Cluster (±ms)", "Table (±ms)"},
         value=current_config.lazy_method, x=1, y=2, width=3, height=1},
        {class="label", label="Limit (±ms):", x=0, y=3, width=1, height=1},
        {class="edit", name="lazy_limit", value=current_config.lazy_limit, x=1, y=3, width=1},
        {class="checkbox", name="lazy_apply_start", label="Apply Start", 
         value=current_config.lazy_apply_start, x=0, y=4, width=2, height=1},
        {class="checkbox", name="lazy_apply_end", label="Apply End", 
         value=current_config.lazy_apply_end, x=2, y=4, width=2, height=1},
        {class="checkbox", name="lazy_enable_tagging", label="Enable Tagging", 
         value=current_config.lazy_enable_tagging, x=0, y=5, width=2, height=1},
        {class="dropdown", name="lazy_tag_mode", 
         items={"Both", "Only changes", "Only 0ms", "None"},
         value=current_config.lazy_tag_mode, x=2, y=5, width=2, height=1},
        {class="dropdown", name="lazy_tag_scope", 
         items={"Both", "Start only", "End only"},
         value=current_config.lazy_tag_scope, x=0, y=6, width=2, height=1},
        {class="label", label="─── GapMarker Settings ───", x=0, y=7, width=4, height=1},
        {class="label", label=L("lbl_max_gap"), x=0, y=8, width=1, height=1},
        {class="edit", name="gap_max_gap", value=current_config.gap_max_gap, x=1, y=8, width=1},
        {class="label", label=L("lbl_custom_tag"), x=0, y=9, width=1, height=1},
        {class="edit", name="gap_tag", value=current_config.gap_tag, x=1, y=9, width=1},
        {class="checkbox", name="gap_mark_continuous", 
         label=L("chk_mark_continuous"),
         value=current_config.gap_mark_continuous, x=0, y=10, width=4, height=1},
        {class="checkbox", name="gap_ignore_keyframes", 
         label=L("chk_ignore_keyframes"),
         value=current_config.gap_ignore_keyframes, x=0, y=11, width=4, height=1},
        {class="label", label="─── SCXvid Settings ───", x=0, y=12, width=4, height=1},
        {class="label", label="SCXvid path:", x=0, y=13, width=1, height=1},
        {class="edit", name="scxvid_path", value=current_config.scxvid_path, x=1, y=13, width=3},
        {class="label", label="FFmpeg path:", x=0, y=14, width=1, height=1},
        {class="edit", name="ffmpeg_path", value=current_config.ffmpeg_path, x=1, y=14, width=3},
        {class="label", label="Log suffix:", x=0, y=15, width=1, height=1},
        {class="edit", name="scxvid_suffix", value=current_config.scxvid_suffix, x=1, y=15, width=1},
        {class="label", label="─── Import Text Settings ───", x=0, y=16, width=4, height=1},
        {class="label", label=L("lbl_transplant_mode"), x=0, y=17, width=1, height=1},
        {class="dropdown", name="time_transplant_mode", items={"Box", "Clipboard"}, value=current_config.time_transplant_mode, hint=L("hint_transplant_mode"), x=1, y=17, width=3, height=1},
        {class="label", label="─── Kite Timing ───", x=0, y=18, width=4, height=1},
        {class="label", label="Lead-in base (ms):", x=0, y=19, width=1, height=1},
        {class="intedit", name="kt_lead_in_base", value=current_config.kt_lead_in_base, x=1, y=19, width=1, min=0, max=2000},
        {class="label", label="Lead-in max (ms):", x=2, y=19, width=1, height=1},
        {class="intedit", name="kt_lead_in_max", value=current_config.kt_lead_in_max, x=3, y=19, width=1, min=0, max=2000},
        {class="label", label="Lead-out base (ms):", x=0, y=20, width=1, height=1},
        {class="intedit", name="kt_lead_out_base", value=current_config.kt_lead_out_base, x=1, y=20, width=1, min=0, max=2000},
        {class="label", label="Lead-out max (ms):", x=2, y=20, width=1, height=1},
        {class="intedit", name="kt_lead_out_max", value=current_config.kt_lead_out_max, x=3, y=20, width=1, min=0, max=2000},
        {class="label", label="Chain out reach (ms):", x=0, y=21, width=1, height=1},
        {class="intedit", name="kt_lead_out_chain", value=current_config.kt_lead_out_chain, x=1, y=21, width=1, min=0, max=2000},
        {class="label", label="Chain gap max (ms):", x=2, y=21, width=1, height=1},
        {class="intedit", name="kt_chain_gap_max", value=current_config.kt_chain_gap_max, x=3, y=21, width=1, min=0, max=2000},
    }
    local buttons = {L("btn_save"), L("btn_cancel")}
    local pressed, result = aegisub.dialog.display(dlg, buttons)
    if pressed == L("btn_save") then
        current_config.language = result.language == "Español" and "es"
                                 or result.language == "Português" and "pt"
                                 or "en"
        local old_lang = current_lang
        current_lang = current_config.language
        current_config.lazy_method = result.lazy_method
        current_config.lazy_limit = result.lazy_limit
        current_config.lazy_apply_start = result.lazy_apply_start
        current_config.lazy_apply_end = result.lazy_apply_end
        current_config.lazy_enable_tagging = result.lazy_enable_tagging
        current_config.lazy_tag_mode = result.lazy_tag_mode
        current_config.lazy_tag_scope = result.lazy_tag_scope
        current_config.gap_max_gap = result.gap_max_gap
        current_config.gap_tag = result.gap_tag
        current_config.gap_mark_continuous = result.gap_mark_continuous
        current_config.gap_ignore_keyframes = result.gap_ignore_keyframes
        current_config.scxvid_path = result.scxvid_path
        current_config.ffmpeg_path = result.ffmpeg_path
        current_config.scxvid_suffix = result.scxvid_suffix
        current_config.time_transplant_mode = result.time_transplant_mode
        current_config.kt_lead_in_base = result.kt_lead_in_base
        current_config.kt_lead_in_max = result.kt_lead_in_max
        current_config.kt_lead_out_base = result.kt_lead_out_base
        current_config.kt_lead_out_max = result.kt_lead_out_max
        current_config.kt_lead_out_chain = result.kt_lead_out_chain
        current_config.kt_chain_gap_max = result.kt_chain_gap_max
        saveConfig()
        showMsg(L("msg_config_saved"))
        if old_lang ~= current_lang then
            showMsg("Language changed. Restart Aegisub.")
        end
    end
end
local function trim(s) return s and s:gsub("^%s*(.-)%s*$","%1") or "" end
local function cloneLine(l) if type(l.copy)=="function" then return l:copy() end local d={class=l.class or"dialogue"} for k,v in pairs(l)do if type(v)=="table" then d[k]={} for ki,vi in pairs(v)do d[k][ki]=vi end else d[k]=v end end setmetatable(d,getmetatable(l)) return d end
local function stripTags(t) return (t:gsub("{[^}]*}",""):gsub("%[.-%]",""):gsub("\\N","")) end
local function charCount(t) local stripped = stripTags(t):gsub("%s",""):gsub("%p","") return unicode.len and unicode.len(stripped) or #stripped end
local function safeUpper(t) return unicode.to_upper and unicode.to_upper(t) or t:upper() end
local function isUppercase(t) local c=stripTags(t):gsub("%s+",""):gsub("%p+","") return c~="" and c==safeUpper(c) end
local function safeDelete(subs,idxs) table.sort(idxs,function(a,b) return a>b end) for _,i in ipairs(idxs)do subs.delete(i) end end
local function validateDuration(l) return l.end_time and l.start_time and l.end_time > l.start_time end
local function addTag(l, tag, force) if not l.effect then l.effect = "" end local clean_tag = tag:gsub("[%[%]]", "") if force or not l.effect:match("%["..clean_tag:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1").."[^%]]*%]") then l.effect = (l.effect == "" and tag or l.effect .. " " .. tag) end end
local function getTargetedSelection(subs,sel,c) if not c or c.mode==L("dd_all_selected") then return sel end local f={} for _,i in ipairs(sel)do local l=subs[i] local m=false if c.mode==L("dd_by_style") and l.style==c.value then m=true elseif c.mode==L("dd_by_actor") and l.actor==c.value then m=true elseif c.mode==L("dd_by_layer") and l.layer==tonumber(c.value) then m=true elseif c.mode==L("dd_by_effect") and l.effect:find(c.value,1,true) then m=true end if m then table.insert(f,i) end end return f end
local DELIMS_BASE, DELIMS_COMMA = "。？！?!…‥.", "、，,;；"
local function sliceSentences(t, mode_comma)
  local parts = {}
  local current_part = ""
  local chars = {}
  for c in t:gmatch("[%z\1-\127\194-\244][\128-\191]*") do table.insert(chars, c) end
  local i = 1
  while i <= #chars do
    local c = chars[i]
    local next_c = chars[i+1] or ""
    local prev_c = chars[i-1] or ""
    local is_split = false
    if c:match("[%.%?!]") or c == "。" or c == "？" or c == "！" or c == "…" or c == "‥" then is_split = true end
    if mode_comma and (c:match("[,;]") or c == "、" or c == "，" or c == "；") then is_split = true end
    if c == "-" and prev_c == " " and next_c == " " then is_split = true end
    current_part = current_part .. c
    if is_split then
      while chars[i+1] and (
        chars[i+1]:match("[%.%?!]") or chars[i+1] == "。" or chars[i+1] == "？" or chars[i+1] == "！" or chars[i+1] == "…" or chars[i+1] == "‥" or
        (mode_comma and (chars[i+1]:match("[,;]") or chars[i+1] == "、" or chars[i+1] == "，" or chars[i+1] == "；"))
      ) do
        i = i + 1
        current_part = current_part .. chars[i]
      end
      table.insert(parts, current_part)
      current_part = ""
      while chars[i+1] and chars[i+1]:match("%s") do i = i + 1 end
    end
    i = i + 1
  end
  if current_part ~= "" then table.insert(parts, current_part) end
  local clean_parts = {}
  for _, p in ipairs(parts) do
    local txt = p:gsub("{[^}]*}", ""):gsub("%s+", "")
    if txt ~= "" then table.insert(clean_parts, p) end
  end
  return clean_parts
end
local function allocDur(seg,T) local c=0 for _,s in ipairs(seg)do c=c+charCount(s) end local d,r={},T if c==0 then local s=math.floor(T/#seg) for i=1,#seg do d[i]=s end d[#seg]=T-s*(#seg-1) return d end for i,s in ipairs(seg)do if i==#seg then d[i]=math.max(1,r) else local v=math.floor(T*charCount(s)/c) d[i],r=v,r-v end end return d end
local function addSentenceTag(l,n) if n<2 then return end addTag(l, string.format("[%dS]",n)) end
local function sentenceTool(subs,sel,o) 
  table.sort(sel,function(a,b)return a>b end) 
  aegisub.progress.task("Divine Dividing...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    if not validateDuration(ln) then 
      log("Skipping line "..i.." - invalid duration")
      goto n 
    end
    local head=ln.text:match("^({[^}]*})+")or"" 
    local body=ln.text:gsub("^({[^}]*})+","") 
    local parts=sliceSentences(body,o.comma) 
    if #parts<2 then goto n end 
    if o.preview then 
      addSentenceTag(ln,#parts) 
      subs[i]=ln 
    else 
      local segs={} 
      for _,p in ipairs(parts)do 
        local cleanP = p:gsub("{[^}]*}",""):gsub("%s+",""):gsub("%p+","")
        local charLen = unicode.len and unicode.len(cleanP) or #cleanP
        if charLen > 0 then
          segs[#segs+1]=head..p 
        end
      end
      if #segs < 2 then goto n end
      local dur=allocDur(segs,ln.end_time-ln.start_time) 
      ln.text,segs[1]=segs[1],nil 
      ln.end_time=ln.start_time+dur[1] 
      subs[i]=ln 
      local t=ln.end_time 
      for j=2,#dur do 
        local nl=cloneLine(ln) 
        nl.text=segs[j] 
        nl.start_time=t 
        nl.end_time=t+dur[j] 
        subs.insert(i+j-1,nl) 
        t=nl.end_time 
      end 
    end 
    ::n:: 
  end 
end
local function splitByNtag(t) local o,last={},1 while true do local p=t:find("\\N",last,true) if not p then o[#o+1]=t:sub(last) break else o[#o+1]=t:sub(last,p-1) last=p+2 end end return o end
local function splitByN(subs,sel) 
  table.sort(sel,function(a,b)return a>b end) 
  aegisub.progress.task("Line Cleaver \\\\N...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    if not ln.text:find("\\N",1,true)then goto sk end 
    if not validateDuration(ln) then 
      log("Skipping line "..i.." - invalid duration")
      goto sk 
    end
    local parts=splitByNtag(ln.text) 
    if #parts<2 then goto sk end 
    local head=ln.text:match("^({[^}]*})+")or"" 
    local segs={} 
    for _,pt in ipairs(parts) do 
      segs[#segs+1]=(pt:match("^%{") and pt or head..pt) 
    end 
    local dur=allocDur(segs,ln.end_time-ln.start_time) 
    ln.text=segs[1] 
    ln.end_time=ln.start_time+dur[1] 
    subs[i]=ln 
    local t=ln.end_time 
    for p=2,#segs do 
      local nl=cloneLine(ln) 
      nl.text=segs[p] 
      nl.start_time=t 
      nl.end_time=t+dur[p] 
      subs.insert(i+p-1,nl) 
      t=nl.end_time 
    end 
    ::sk:: 
  end 
end
local function splitRomaji(w) local t,pos,len={},1,#w local function peek(n) return pos+n-1<=len and w:sub(pos,pos+n-1) or nil end local function consume(n) local s=w:sub(pos,pos+n-1); pos=pos+n; return s end local function isVowel(c) return c and c:match("[aiueo]") end while pos<=len do local found=false local c1,c2,c3,c4=peek(1),peek(2),peek(3),peek(4) if c4 then local p4={"kky[auo]","ssy[auo]","tty[auo]","ppy[auo]","ggy[auo]","zzy[auo]","ddy[auo]","bby[auo]","mmy[auo]","nny[auo]","rry[auo]","hhy[auo]"} for _,p in ipairs(p4)do if c4:match("^"..p.."$")then t[#t+1]=consume(4) found=true break end end end if not found and c3 then local p3={"nn[aiueo]","mm[aiueo]","kk[aiueo]","ss[aiueo]","tt[aiueo]","pp[aiueo]","gg[aiueo]","zz[aiueo]","dd[aiueo]","bb[aiueo]","rr[aiueo]","hh[aiueo]","yy[aiueo]","kya","kyu","kyo","gya","gyu","gyo","sha","shu","sho","cha","chu","cho","nya","nyu","nyo","hya","hyu","hyo","bya","byu","byo","pya","pyu","pyo","mya","myu","myo","rya","ryu","ryo","tsu","shi","chi","tta","kka","ssa","ppa","gga","zza","dda","bba","mma","nna","rra","hha","yya"} for _,p in ipairs(p3)do if c3:match("^"..p.."$")then t[#t+1]=consume(3) found=true break end end end if not found and c2 then local p2={"ka","ki","ku","ke","ko","ga","gi","gu","ge","go","sa","si","su","se","so","za","zi","zu","ze","zo","ta","ti","tu","te","to","da","di","du","de","do","na","ni","nu","ne","no","ha","hi","hu","he","ho","ba","bi","bu","be","bo","pa","pi","pu","pe","po","ma","mi","mu","me","mo","ya","yu","yo","ra","ri","ru","re","ro","wa","wi","wu","we","wo","nn","n'","aa","ii","uu","ee","oo","ou","oa","oe","oi","ue","ua","ui","ai","au","ei","ia","ie","iu","uo"} for _,p in ipairs(p2)do if c2:match("^"..p.."$")then if p=="nn"and isVowel(peek(3))then t[#t+1]=consume(1) found=true break else t[#t+1]=consume(2) found=true break end end end end if not found and c1 then if c1:match("[aiueon]")then t[#t+1]=consume(1) found=true elseif c1=="n"then if not isVowel(peek(2))and not (peek(2)and peek(2):match("[yp]"))then t[#t+1]=consume(1) found=true end end end if not found then t[#t+1]=consume(1) end end if #t==0 then t[1]=w end return t end
local function romajiKara(subs,sel) 
  aegisub.progress.task("Kana-Beat {\\\\k}...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    local groups={} 
    for w in ln.text:gmatch("%S+")do groups[#groups+1]=splitRomaji(w) end 
    local tot=0 
    for _,g in ipairs(groups)do tot=tot+#g end 
    if tot==0 then tot=1 end 
    local cs=math.floor((ln.end_time-ln.start_time)/10+0.5) 
    local base,rem=math.floor(cs/tot),cs%tot 
    local out,idx="",1 
    for wi,g in ipairs(groups)do 
      for _,sy in ipairs(g)do 
        local d=base+(idx<=rem and 1 or 0) 
        out=out..("{\\k"..d.."}"..sy) 
        idx=idx+1 
      end 
      if wi<#groups then out=out.." " end 
    end 
    ln.text=out 
    subs[i]=ln 
  end 
end
local function calcCPS(l) local d=(l.end_time-l.start_time)/1000 return d>0 and charCount(l.text)/d or 0 end
local function sortByCPS(subs,sel) local tmp={} for _,i in ipairs(sel)do tmp[#tmp+1]=subs[i] end table.sort(tmp,function(a,b)return calcCPS(a)>calcCPS(b) end) for k,l in ipairs(tmp)do subs[sel[k]]=l end end
local function showAvgCPS(subs,sel) local ch,ms=0,0 for _,i in ipairs(sel)do local ln=subs[i] ch=ch+charCount(ln.text) ms=ms+(ln.end_time-ln.start_time) end local avg=(ms>0)and ch/(ms/1000)or 0 showMsg(string.format(L("msg_avg_cps"),#sel,avg)) end
local _kf_cache = nil
local _kf_set = nil
local function loadKeyframeCache()
  if _kf_cache == nil then
    _kf_cache = aegisub.keyframes() or {}
    _kf_set = {}
    for _,k in ipairs(_kf_cache) do _kf_set[k] = true end
  end
  return _kf_cache, _kf_set
end
local function isKeyframe(ms) 
  local kfs, kf_set = loadKeyframeCache()
  if #kfs==0 then 
    log("Warning: No keyframes loaded")
    return false 
  end 
  local f=aegisub.frame_from_ms(ms) 
  if not f then return false end
  return kf_set[f] == true 
end
local function hasKFinRange(t1,t2) 
  local kfs = loadKeyframeCache()
  if #kfs==0 then return false end 
  local f1,f2=aegisub.frame_from_ms(t1),aegisub.frame_from_ms(t2) 
  if not f1 or not f2 then return false end
  for _,k in ipairs(kfs)do if k>=f1 and k<f2 then return true end end 
  return false 
end
local function tagTiming(subs,sel,o) 
  aegisub.progress.task("Applying timing markers...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    local dur=ln.end_time-ln.start_time 
    local mode=o.mode or L("dd_end_only") 
    if o.kf then
      if mode==L("dd_end_only") and isKeyframe(ln.end_time) then 
        addTag(ln,"[KF-E]") 
      elseif mode==L("dd_start_only") and isKeyframe(ln.start_time) then 
        addTag(ln,"[KF-S]") 
      elseif mode==L("dd_both") then
        if isKeyframe(ln.end_time) then addTag(ln,"[KF-E]") end
        if isKeyframe(ln.start_time) then addTag(ln,"[KF-S]") end
      end
    end
    if o.ov>0 and dur>o.ov then addTag(ln,"[Overtime]") end 
    if mode==L("dd_end_only") or mode==L("dd_both") then 
      if o.twin>0 and isKeyframe(ln.end_time) then 
        local search_start = math.max(ln.start_time, ln.end_time - o.twin)
        if hasKFinRange(search_start, ln.end_time - 1) then 
          addTag(ln,"[Twin-E]") 
        end 
      end 
      if o.miss>0 and not isKeyframe(ln.end_time) then 
        local search_start = math.max(ln.start_time, ln.end_time - o.miss)
        if hasKFinRange(search_start, ln.end_time - 1) then 
          addTag(ln,"[Miss-E]") 
        end 
      end 
    end 
    if mode==L("dd_start_only") or mode==L("dd_both") then 
      if o.twin>0 and isKeyframe(ln.start_time) then 
        local search_start = math.max(0, ln.start_time - o.twin)
        if hasKFinRange(search_start, ln.start_time - 1) then 
          addTag(ln,"[Twin-S]") 
        end 
      end 
      if o.miss>0 and not isKeyframe(ln.start_time) then 
        local search_start = math.max(0, ln.start_time - o.miss)
        if hasKFinRange(search_start, ln.start_time - 1) then 
          addTag(ln,"[Miss-S]") 
        end 
      end 
    end 
    subs[i]=ln 
  end 
end
local function tagOverlaps(subs,sel) 
  if #sel<2 then return end
  aegisub.progress.task("Detecting overlaps...")
  table.sort(sel,function(a,b)return subs[a].start_time<subs[b].start_time end) 
  for p=1,#sel-1 do 
    aegisub.progress.set(p/(#sel-1)*100)
    local a,b=subs[sel[p]],subs[sel[p+1]] 
    if a.end_time>b.start_time then 
      for _,ln in ipairs{a,b}do addTag(ln,"[Overlap]") end 
    end 
    subs[sel[p]],subs[sel[p+1]]=a,b 
  end 
end
local function markSmallGaps(subs,sel,opt) 
  local maxGap=math.min(opt.maxGap or 300, 5000)
  aegisub.progress.task("Marking gaps...")
  local lines={} 
  for i,idx in ipairs(sel)do 
    lines[i]={index=idx,line=subs[idx],start_time=subs[idx].start_time,end_time=subs[idx].end_time} 
  end 
  table.sort(lines,function(a,b)return a.start_time<b.start_time end) 
  local cnt=0 
  for i=1,#lines-1 do 
    aegisub.progress.set(i/(#lines-1)*100)
    local c,n=lines[i],lines[i+1] 
    local gap=n.start_time-c.end_time 
    local mark=false 
    if opt.markContinuous and gap==0 then mark=true 
    elseif gap>0 and gap<maxGap then mark=true end 
    if mark then 
      if opt.ignoreKeyframes and isKeyframe(c.end_time) then mark=false end 
      if mark then 
        local t="["..opt.gapTag..(gap==0 and " 0ms]" or " "..gap.."ms]") 
        addTag(c.line,t) 
        addTag(n.line,t) 
        subs[c.index]=c.line 
        subs[n.index]=n.line 
        cnt=cnt+2 
      end 
    end 
  end 
  return cnt 
end
local function markUppercase(subs,sel) for _,i in ipairs(sel)do local l=subs[i] if isUppercase(l.text) then addTag(l,"[Uppercase]") subs[i]=l end end end
local function markMissingPunctuation(subs,sel) for _,i in ipairs(sel)do local l=subs[i] local c=stripTags(l.text):gsub("%s+$","") if c~="" and not c:match("[%.,!?！？]%s*$") then addTag(l,"[Missing Final Punctuation]") subs[i]=l end end end
local function parseTime(t) t=t:gsub("^%s+",""):gsub("%s+$","") local h,m,s=t:match("(%d+):(%d+):(%d+%.%d+)") return h and (tonumber(h)*3600+tonumber(m)*60+tonumber(s))*1000 end
local function timeInt(s1,e1,s2,e2) local s,e=math.max(s1,s2),math.min(e1,e2) return s<e and e-s or 0 end
local function parseDialogue(l) 
  l=trim(l) 
  if not l:match("^Dialogue:") then return nil end 
  local c,p={},1 
  while p do 
    p=l:find(",",p) 
    if p then table.insert(c,p) p=p+1 end 
  end 
  if #c<9 then 
    log("Error: Invalid dialogue format, less than 9 fields")
    return nil 
  end 
  local sp,f=l:find(":",1,true)+1,{} 
  for i=1,8 do 
    table.insert(f,trim(l:sub(sp,c[i]-1))) 
    sp=c[i]+1 
  end 
  table.insert(f,trim(l:sub(sp,c[9]-1))) 
  table.insert(f,trim(l:sub(c[9]+1))) 
  return f 
end
local function antEffects(subs,sel,raw) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,ef=parseTime(f[2]),parseTime(f[3]),f[9] if s and e and ef~="" then table.insert(src,{start=s,end_time=e,effect=ef}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local add={} for _,s in ipairs(src)do if timeInt(l.start_time,l.end_time,s.start,s.end_time)>0 then table.insert(add,s.effect) end end if #add>0 then if l.effect~="" then table.insert(add,1,l.effect) end l.effect=table.concat(add,"; ") mod=mod+1 end subs[i]=l end return mod end
local function antLines(subs,sel,raw,comm) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,tx=parseTime(f[2]),parseTime(f[3]),f[10] if s and e and tx~="" and not tx:match("^{=%d+}$") then table.insert(src,{start=s,end_time=e,text=tx}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local add="" for _,s in ipairs(src)do if timeInt(l.start_time,l.end_time,s.start,s.end_time)>0 then local t=comm and "{"..s.text.."}" or s.text add=(add=="" and t or add.." "..t) end end if add~="" then l.text=l.text.." "..add mod=mod+1 end subs[i]=l end return mod end
local function antActor(subs,sel,raw) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,ac=parseTime(f[2]),parseTime(f[3]),f[5] if s and e and ac~="" then table.insert(src,{start=s,end_time=e,actor=ac}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local ba,bd=nil,0 for _,s in ipairs(src)do local d=timeInt(l.start_time,l.end_time,s.start,s.end_time) if d>bd then bd,ba=d,s.actor end end if ba then l.actor=ba mod=mod+1 end subs[i]=l end return mod end
local function sp_parseTime(timeStr)
    local h, m, s, cs = timeStr:match("(%d+):(%d+):(%d+)%.(%d+)")
    if not h then return nil end
    return (tonumber(h) * 3600000) + (tonumber(m) * 60000) + (tonumber(s) * 1000) + (tonumber(cs) * 10)
end
local function sp_ms_to_timecode(ms)
    local h = math.floor(ms / 3600000)
    local m = math.floor((ms % 3600000) / 60000)
    local s = math.floor((ms % 60000) / 1000)
    local cs = math.floor((ms % 1000) / 10)
    return string.format("%d:%02d:%02d.%02d", h, m, s, cs)
end
local function sp_parseDialogue_line(line)
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    local line_type = nil
    if line:match("^Comment:") then
        line_type = "comment"
        line = line:gsub("^Comment:", "Dialogue:")
    elseif line:match("^Dialogue:") then
        line_type = "dialogue"
    else
        return nil
    end
    if not line:match("^Dialogue:") then return nil end
    local commas = {}
    local pos = 1
    while pos do
        pos = line:find(",", pos)
        if pos then
            table.insert(commas, pos)
            pos = pos + 1
        end
    end
    if #commas < 9 then return nil end
    local start_pos = line:find(":", 1, true) + 1
    local fields = {}
    for i = 1, 9 do
        table.insert(fields, line:sub(start_pos, commas[i] - 1))
        start_pos = commas[i] + 1
    end
    table.insert(fields, line:sub(start_pos))
    return {
        line_type = line_type,
        layer = tonumber(fields[1]) or 0,
        start_time = fields[2],
        end_time = fields[3],
        style = fields[4],
        actor = fields[5],
        margin_l = tonumber(fields[6]) or 0,
        margin_r = tonumber(fields[7]) or 0,
        margin_t = tonumber(fields[8]) or 0,
        effect = fields[9],
        text = fields[10]
    }
end
local function sp_parse_group(input_text)
    local group = {}
    local sync_point = nil
    for line in input_text:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            local parsed = sp_parseDialogue_line(line)
            if parsed then
                if parsed.line_type == "comment" and parsed.layer == 50 then
                    local sync_time = sp_parseTime(parsed.start_time)
                    if sync_time then
                        sync_point = sync_time
                    end
                end
                table.insert(group, parsed)
            end
        end
    end
    return group, sync_point
end
local function sp_create_shifted_line(parsed, time_shift, group_marker)
    local start_ms = sp_parseTime(parsed.start_time)
    local end_ms = sp_parseTime(parsed.end_time)
    if not start_ms or not end_ms then return nil end
    local new_start = start_ms + time_shift
    local new_end = end_ms + time_shift
    if new_start < 0 or new_end < 0 then return nil end
    local new_line = {
        class = "dialogue",
        comment = (parsed.line_type == "comment"),
        layer = parsed.layer,
        start_time = new_start,
        end_time = new_end,
        style = parsed.style,
        actor = group_marker or parsed.actor,
        margin_l = parsed.margin_l,
        margin_r = parsed.margin_r,
        margin_t = parsed.margin_t,
        effect = parsed.effect,
        text = parsed.text
    }
    return new_line
end
local function antSongs(subs, sel, raw)
    if not sel or #sel == 0 then return 0 end
    if not raw or raw:gsub("%s", "") == "" then return 0 end
    local group, sync_point = sp_parse_group(raw)
    if not sync_point then
        aegisub.dialog.display({
            {class="label", label="Error: No sync point found!\\n\\nNeed Comment line with layer 50", x=0, y=0}
        }, {L("btn_ok")})
        return 0
    end
    if #group == 0 then return 0 end
    local lines_added = 0
    local insert_pos = sel[#sel]
    for idx = #sel, 1, -1 do
        local target_line = subs[sel[idx]]
        if target_line and target_line.start_time then
            local target_time = target_line.start_time
            local time_shift = target_time - sync_point
            local group_marker = target_line.effect or ""
            for i = #group, 1, -1 do
                local new_line = sp_create_shifted_line(group[i], time_shift, group_marker)
                if new_line then
                    subs.insert(insert_pos + 1, new_line)
                    lines_added = lines_added + 1
                end
            end
        end
    end
    return lines_added
end
local function antTwins(subs, sel, raw, comm)
    if not sel or #sel == 0 then return 0 end
    if not raw or raw:gsub("%s", "") == "" then return 0 end
    local src = {}
    for l in raw:gmatch("[^\r\n]+") do
        local f = parseDialogue(l)
        if f then
            local s, e, tx, ly = parseTime(f[2]), parseTime(f[3]), f[10], tonumber(f[1]) or 0
            if s and e and tx ~= "" and not tx:match("^{=%d+}$") then
                table.insert(src, {start = s, end_time = e, text = tx, layer = ly})
            end
        end
    end
    if #src == 0 then return 0 end
    local mod = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        local target_layer = l.layer or 0
        local add = ""
        for _, s in ipairs(src) do
            if s.layer == target_layer then
                if timeInt(l.start_time, l.end_time, s.start, s.end_time) > 0 then
                    local t = comm and "{"..s.text.."}" or s.text
                    add = (add == "" and t or add .. " " .. t)
                end
            end
        end
        if add ~= "" then
            l.text = l.text .. " " .. add
            mod = mod + 1
        end
        subs[i] = l
    end
    return mod
end
local lazyConfig={weights={proximity=0.30,silence_q=0.22,source_c=0.13,clarity=0.08,vad=0.30,flux=0.30},cluster_max_dist=120,min_cluster_mass=0.6,min_score_threshold=0.25,min_duration=200,max_duration=8000,epsilon=50,thresholds={[30]={min_silence_dur=350,reliability=1.0},[40]={min_silence_dur=120,reliability=0.9},[50]={min_silence_dur=120,reliability=0.6}}}
local tableConfig={merge_gap_ms=120,min_noise_ms=80,edge_drop_ms=60,w_cov=0.65,w_prox=0.25,w_frag=0.10,sigma_ms=200,eps=1}
local g_aux_vad, g_aux_flux = nil, nil
local function normalizeProximity(d,w) if w<=0 then return 0 end return math.exp(-(d*d)/(w*w)) end
local function normalizeSilenceQuality(d) if d<100 then return 0.1 elseif d<500 then return 0.3+0.4*(d-100)/400 elseif d<1500 then return 0.7+0.2*(d-500)/1000 else return 0.9+0.1*(1-math.exp(-(d-1500)/1000)) end end
local function getSourceConfidence(t) return (lazyConfig.thresholds[t] and lazyConfig.thresholds[t].reliability) or 0.5 end
local function normalizeContextClarity(d) return 1/(1+d*d) end
local function calculateScore(c,rt,sw,sd) local d=math.abs(c.time-rt) local fp=normalizeProximity(d,sw) local fq=normalizeSilenceQuality(c.duration or 0) local fc=getSourceConfidence(c.threshold) local fl=normalizeContextClarity(sd) local fflux, fvad = (c.flux_boost or 0), (c.vad_align or 0) return (fp*lazyConfig.weights.proximity)+(fq*lazyConfig.weights.silence_q)+(fc*lazyConfig.weights.source_c)+(fl*lazyConfig.weights.clarity)+(fflux*lazyConfig.weights.flux)+(fvad*lazyConfig.weights.vad) end
local function findClusters(cs,md) if not cs or #cs==0 then return{} end if #cs<2 then return{cs} end table.sort(cs,function(a,b)return a.time<b.time end) local cls,ccl={},{cs[1]} for i=2,#cs do if cs[i].time-ccl[#ccl].time<=md then table.insert(ccl,cs[i]) else table.insert(cls,ccl) ccl={cs[i]} end end table.insert(cls,ccl) return cls end
local function weighted_median_time(cl) table.sort(cl,function(a,b)return a.time<b.time end) local sum=0 for _,p in ipairs(cl)do sum=sum+(p.score or 0) end if sum<=0 then local mid=math.floor((#cl+1)/2) return cl[mid].time end local acc=0 for _,p in ipairs(cl)do acc=acc+(p.score or 0) if acc>=sum*0.5 then return p.time end end return cl[#cl].time end
local function addLazyTag(l,t) addTag(l, "[LZ "..t.."]" , true) end
local function getLazyPath(t) return aegisub.dialog.open(t,"","","*.txt;*.log",false,true) end
local function validateIntra(ns,ne,os,oe) if ns<os or ne>oe then return false,"out_of_range" end if ne-ns<lazyConfig.min_duration then return false,"min_dur" end return true end
local function clampIntra(ns,ne,os,oe) local ns2,ne2=math.max(ns,os),math.min(ne,oe) if ne2-ns2<lazyConfig.min_duration then return false,"min_dur",ns,ne end return true,nil,ns2,ne2 end
local function getDensity(t,s,ws) ws=ws or 5000 local c,sw,ew=0,t-ws/2,t+ws/2 for _,seg in ipairs(s)do local ov=not(seg["end"]<=sw or seg.start>=ew) if ov then c=c+1 end end return c/(ws/1000) end
local function parseLazyFile(fp,t) 
  local segs={} 
  local fh=io.open(fp,"r") 
  if not fh then 
    log("Error: Cannot open lazy file: "..fp)
    return segs 
  end 
  local cs=nil 
  local line_count = 0
  for l in fh:lines()do 
    line_count = line_count + 1
    local ss=l:match("silence_start:%s*([%d%.]+)") 
    if ss then cs=tonumber(ss)*1000 end 
    local se,sd=l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)") 
    if se and cs then 
      local dms=tonumber(sd)*1000 
      if dms>=((lazyConfig.thresholds[t] and lazyConfig.thresholds[t].min_silence_dur)or 100) then 
        table.insert(segs,{start=cs,["end"]=tonumber(se)*1000,duration=dms,threshold=t}) 
      end 
      cs=nil 
    end 
  end 
  fh:close() 
  log("Loaded "..#segs.." silence segments from "..fp.." ("..line_count.." lines)")
  return segs 
end
local function parseVADtsv(path) local segs={} local f=io.open(path,"r") if not f then return segs end local first=true for line in f:lines()do if first then first=false else local a,b=line:match("([%d%.]+)%s+([%d%.]+)") if a and b then table.insert(segs,{start=tonumber(a),["end"]=tonumber(b)}) end end end f:close() return segs end
local function parseFLUXtsv(path) local cands={} local f=io.open(path,"r") if not f then return cands end local first=true for line in f:lines()do if first then first=false else local t,ty,sc=line:match("([%d%.]+)%s+(%a+)%s+([%d%.]+)") if t and ty and sc then table.insert(cands,{time=tonumber(t),type=ty,score=tonumber(sc)}) end end end f:close() return cands end
local function getVADSegmentsInRange(vad, start_s, end_s)
    local result = {}
    for _, seg in ipairs(vad or {}) do
        if seg.start < end_s and seg["end"] > start_s then
            table.insert(result, {start = seg.start, ["end"] = seg["end"]})
        end
    end
    table.sort(result, function(a, b) return a.start < b.start end)
    return result
end
local function findSilenceEndingBefore(all_silences, target_ms, line_start_ms)
    local best_end = nil
    local search_window = 2000
    for _, seg in ipairs(all_silences) do
        local seg_end = seg["end"]
        if seg_end <= target_ms and seg_end >= line_start_ms and seg_end >= (target_ms - search_window) then
            if not best_end or seg_end > best_end then
                best_end = seg_end
            end
        end
    end
    return best_end
end
local function findSilenceStartingAfter(all_silences, target_ms, line_end_ms)
    local best_start = nil
    local search_window = 2000
    for _, seg in ipairs(all_silences) do
        local seg_start = seg.start
        if seg_start >= target_ms and seg_start <= line_end_ms and seg_start <= (target_ms + search_window) then
            if not best_start or seg_start < best_start then
                best_start = seg_start
            end
        end
    end
    return best_start
end
local function enrich_with_aux(cands,flux,vad,want_type) local function nearest_flux(t) local best_d,best_s=math.huge,0 for _,c in ipairs(flux or{})do if c.type==want_type then local d=math.abs(c.time-t) if d<best_d then best_d,best_s=d,c.score end end end if best_d<=40 then return(1-best_d/40)*best_s else return 0 end end local function vad_margin(t)
        local best = math.huge
        for _, s in ipairs(vad or {}) do
            local vs, ve = s.start, s["end"]
            if ve and ve < 10000 then
                vs = (vs or 0) * 1000
                ve = ve * 1000
            end
            local d1 = math.abs((vs or 0) - t)
            local d2 = math.abs((ve or 0) - t)
            local d = (d1 < d2) and d1 or d2
            if d < best then best = d end
        end
        if best == math.huge then return 0 end
        return math.exp(-(best*best)/1600)
    end for _,c in ipairs(cands)do c.flux_boost=nearest_flux(c.time) c.vad_align=vad_margin(c.time) end end
local function loadLazyData(fps) local rs={} for t,p in pairs(fps)do for _,s in ipairs(parseLazyFile(p,t))do table.insert(rs,s) end end table.sort(rs,function(a,b)return a.start<b.start end) local ss,se={},{} for _,s in ipairs(rs)do table.insert(ss,{time=s["end"],duration=s.duration,threshold=s.threshold}) table.insert(se,{time=s.start,duration=s.duration,threshold=s.threshold}) end return ss,se,rs end
local function copyCandidate(ev) return{time=ev.time,duration=ev.duration,threshold=ev.threshold} end
local function round_ms(x) return math.floor(x+0.5) end
local function ordered_by_start(subs,sel) local arr={} for _,i in ipairs(sel)do table.insert(arr,{i=i,st=subs[i].start_time}) end table.sort(arr,function(a,b)return a.st<b.st end) local out={} for _,e in ipairs(arr)do table.insert(out,e.i) end return out end
local function stripLZ(effect) effect=effect or"" return(effect:gsub("%s*%[LZ[^%]]*%]","")) end
local function tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) if not enable_tagging or tag_mode=="None" then return end local chs=(apply_start and ns~=os) local che=(apply_end and ne~=oe) local scope_s=(tag_scope=="Both" or tag_scope=="Start only") local scope_e=(tag_scope=="Both" or tag_scope=="End only") if tag_mode=="Only 0ms" then if scope_s and apply_start and not chs then addLazyTag(l,"~0ms-s") end if scope_e and apply_end and not che then addLazyTag(l,"~0ms-e") end elseif tag_mode=="Only changes" then if scope_s and chs then addLazyTag(l,string.format("Δs=%+dms",ns-os)) end if scope_e and che then addLazyTag(l,string.format("Δe=%+dms",ne-oe)) end elseif tag_mode=="Both" then if scope_s and apply_start then addLazyTag(l,chs and string.format("Δs=%+dms",ns-os) or "~0ms-s") end if scope_e and apply_end then addLazyTag(l,che and string.format("Δe=%+dms",ne-oe) or "~0ms-e") end end end
local function rank_fusion_pick(cands,rt,is_start) local M=#cands if M==0 then return nil end if M==1 then return cands[1] end local function rank_by(fn,desc) local t={} for i,c in ipairs(cands)do t[i]={i=i,v=fn(c)} end table.sort(t,function(a,b)if desc then return a.v>b.v else return a.v<b.v end end) local r={} for k,rec in ipairs(t)do r[rec.i]=k end return r end local r_flux=rank_by(function(c)return c.flux_boost or 0 end,true) local r_vad=rank_by(function(c)return c.vad_align or 0 end,true) local r_prox=rank_by(function(c)return math.abs(c.time-rt)end,false) local r_dur=rank_by(function(c)return c.duration or 0 end,true) local r_src=rank_by(function(c)return getSourceConfidence(c.threshold)end,true) local best_i,best_sum=1,1e9 for i=1,M do local s=(r_flux[i]/M)+(r_vad[i]/M)+(r_prox[i]/M)+(r_dur[i]/M)+(r_src[i]/M) if s<best_sum then best_sum=s best_i=i end end return cands[best_i] end
local function pick_time_for_start(sc,os,lim,den) local scls=findClusters(sc,lazyConfig.cluster_max_dist) local bc,bcm=nil,0 for _,cl in ipairs(scls)do local cm=0 for _,p in ipairs(cl)do cm=cm+(p.score or 0) end if cm>bcm then bcm=cm bc=cl end end if bc then local k=math.min(3,#bc) local bcm_norm=bcm/k if bcm_norm>lazyConfig.min_cluster_mass then return weighted_median_time(bc),true end end table.sort(sc,function(a,b)return(a.score or 0)>(b.score or 0)end) if sc[1] and (sc[1].score or 0)>lazyConfig.min_score_threshold then return sc[1].time,true end local alt=rank_fusion_pick(sc,os,true) if alt then return alt.time,true end return os,false end
local function pick_time_for_end(ec,oe,lim,den) local ecls=findClusters(ec,lazyConfig.cluster_max_dist) local bc,bcm=nil,0 for _,cl in ipairs(ecls)do local cm=0 for _,p in ipairs(cl)do cm=cm+(p.score or 0) end if cm>bcm then bcm=cm bc=cl end end if bc then local k=math.min(3,#bc) local bcm_norm=bcm/k if bcm_norm>lazyConfig.min_cluster_mass then return weighted_median_time(bc),true end end table.sort(ec,function(a,b)return(a.score or 0)>(b.score or 0)end) if ec[1] and (ec[1].score or 0)>lazyConfig.min_score_threshold then return ec[1].time,true end local alt=rank_fusion_pick(ec,oe,false) if alt then return alt.time,true end return oe,false end
local function runClusterAnalysis(subs,sel,lim,files,opts) local ss,se,asg=loadLazyData(files) if #ss==0 then return 0 end local modified=0 local apply_start=opts.apply_start local apply_end=opts.apply_end local enable_tagging=opts.enable_tagging local tag_mode=opts.tag_mode local tag_scope=opts.tag_scope aegisub.progress.task("Analyzing (Cluster, intra ±"..tostring(lim).." ms)...") local seq=ordered_by_start(subs,sel) for idx,ii in ipairs(seq)do aegisub.progress.set(idx/#seq*100) local l=subs[ii] if l.class=="dialogue" then local os,oe=l.start_time,l.end_time local ns,ne=os,oe local den=getDensity((os+oe)/2,asg) if apply_start then local sc={} for _,ev in ipairs(ss)do if ev.time>=os and ev.time<=math.min(os+lim,oe-lazyConfig.min_duration) then local c=copyCandidate(ev) table.insert(sc,c) end end if g_aux_flux or g_aux_vad then enrich_with_aux(sc,g_aux_flux,g_aux_vad,"onset") end for _,cv in ipairs(sc)do cv.score=calculateScore(cv,os,lim,den) end if #sc>0 then local pt,ok=pick_time_for_start(sc,os,lim,den) if ok then ns=round_ms(pt) end end end if apply_end then local ec={} for _,ev in ipairs(se)do if ev.time<=oe and ev.time>=math.max(oe-lim,os+lazyConfig.min_duration) then local c=copyCandidate(ev) table.insert(ec,c) end end if g_aux_flux or g_aux_vad then enrich_with_aux(ec,g_aux_flux,g_aux_vad,"offset") end for _,cv in ipairs(ec)do cv.score=calculateScore(cv,oe,lim,den) end if #ec>0 then local pt,ok=pick_time_for_end(ec,oe,lim,den) if ok then ne=round_ms(pt) end end end if apply_start or apply_end then local changed=(ns~=os) or (ne~=oe) if changed then local ok,why=validateIntra(ns,ne,os,oe) if not ok then local ok2,why2,ns2,ne2=clampIntra(ns,ne,os,oe) if ok2 then l.start_time=ns2 l.end_time=ne2 modified=modified+1 tag_decider(l,os,oe,ns2,ne2,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) else if enable_tagging then addLazyTag(l,"Reject:"..(why2 or why)) end end else l.start_time=ns l.end_time=ne modified=modified+1 tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) end else tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) end subs[ii]=l end end end return modified end
local function normalize_vad_to_ms(vad_data)
    if not vad_data or #vad_data == 0 then return {} end
    local vad_max = 0
    for _, seg in ipairs(vad_data) do
        if seg["end"] and seg["end"] > vad_max then vad_max = seg["end"] end
    end
    local vad_in_ms = (vad_max > 10000)
    local out = {}
    for _, seg in ipairs(vad_data) do
        local s = vad_in_ms and seg.start or (seg.start * 1000)
        local e = vad_in_ms and seg["end"] or (seg["end"] * 1000)
        table.insert(out, {start = s, ["end"] = e})
    end
    table.sort(out, function(a, b) return a.start < b.start end)
    return out
end
local function merge_silence_to_intervals(files)
    local all_silences = {}
    for threshold, path in pairs(files or {}) do
        local fh = io.open(path, "r")
        if fh then
            local cur_start = nil
            for line in fh:lines() do
                local ss = line:match("silence_start:%s*([%d%.]+)")
                if ss then cur_start = tonumber(ss) * 1000 end
                local se = line:match("silence_end:%s*([%d%.]+)")
                if se and cur_start then
                    table.insert(all_silences, {start = cur_start, ["end"] = tonumber(se) * 1000, threshold = threshold})
                    cur_start = nil
                end
            end
            fh:close()
        end
    end
    table.sort(all_silences, function(a, b) return a.start < b.start end)
    local merged = {}
    for _, sil in ipairs(all_silences) do
        if #merged == 0 then
            table.insert(merged, {start = sil.start, ["end"] = sil["end"], count = 1})
        else
            local last = merged[#merged]
            if sil.start <= last["end"] + 50 then
                last["end"] = math.max(last["end"], sil["end"])
                last.count = (last.count or 1) + 1
            else
                table.insert(merged, {start = sil.start, ["end"] = sil["end"], count = 1})
            end
        end
    end
    return merged
end
local function get_vad_activity(t, vad_ms)
    for _, seg in ipairs(vad_ms) do
        if t >= seg.start and t <= seg["end"] then return 1.0 end
        if seg.start > t then break end
    end
    return 0.0
end
local function get_silence_confidence(t, silences)
    for _, sil in ipairs(silences) do
        if t >= sil.start and t <= sil["end"] then
            local dur = sil["end"] - sil.start
            local conf = math.min(1.0, dur / 500) * math.min(1.0, (sil.count or 1) / 2)
            return conf
        end
        if sil.start > t then break end
    end
    return 0.0
end
local function get_flux_score(t, flux_data, want_type, decay_ms)
    decay_ms = decay_ms or 100
    local best_score = 0
    for _, f in ipairs(flux_data or {}) do
        if f.type == want_type then
            local d = math.abs(f.time - t)
            if d <= decay_ms then
                local score = (1 - d / decay_ms) * (f.score or 0.5)
                if score > best_score then best_score = score end
            end
        end
    end
    return best_score
end
local function vad_covers(t, vad_ms)
    if not vad_ms or #vad_ms == 0 then return 1.0 end
    for _, seg in ipairs(vad_ms) do
        if t >= seg.start and t <= seg["end"] then return 1.0 end
        if seg.start > t then break end
    end
    return 1.0
end
local function not_in_silence(t, silences)
    if not silences or #silences == 0 then return 1.0 end
    for _, sil in ipairs(silences) do
        if t >= sil.start and t <= sil["end"] then return 0.0 end
        if sil.start > t then break end
    end
    return 1.0
end
local function flux_evidence(t, flux_data, want_type)
    if not flux_data or #flux_data == 0 then return 0.0 end
    local best = 0
    local sigma = 50
    for _, f in ipairs(flux_data) do
        if f.type == want_type then
            local dist = math.abs((f.time or 0) - t)
            if dist <= 100 then
                local score = (f.score or 0.5) * math.exp(-(dist * dist) / (sigma * sigma))
                if score > best then best = score end
            end
        end
    end
    return best
end
local function compute_efs(t, vad_ms, silences, flux_data, mode)
    local vad = vad_covers(t, vad_ms)
    local sil = 1 - not_in_silence(t, silences)
    local flux_type = (mode == "start") and "onset" or "offset"
    local flux = flux_evidence(t, flux_data, flux_type)
    local activity = math.max(vad, 1 - sil)
    if sil == 1 then activity = 0 end
    return activity * (1 + flux)
end
local function find_flux_exact(t, flux_data, want_type, tolerance)
    tolerance = tolerance or 20
    for _, f in ipairs(flux_data or {}) do
        if f.type == want_type then
            if math.abs((f.time or 0) - t) <= tolerance then
                return f.time
            end
        end
    end
    return nil
end
local function find_activity_bounds(os_ms, oe_ms, vad_ms, silences, flux_data, threshold)
    local step = 5
    local t_start, t_end = nil, nil
    local has_flux_start, has_flux_end = false, false
    for t = os_ms, oe_ms, step do
        local efs = compute_efs(t, vad_ms, silences, flux_data, "start")
        if efs > 0 then
            t_start = t
            local flux_exact = find_flux_exact(t, flux_data, "onset", 30)
            if flux_exact and flux_exact >= os_ms then
                t_start = flux_exact
                has_flux_start = true
            end
            break
        end
    end
    for t = oe_ms, os_ms, -step do
        local efs = compute_efs(t, vad_ms, silences, flux_data, "end")
        if efs > 0 then
            t_end = t
            local flux_exact = find_flux_exact(t, flux_data, "offset", 30)
            if flux_exact and flux_exact <= oe_ms then
                t_end = flux_exact
                has_flux_end = true
            end
            break
        end
    end
    return t_start, t_end, has_flux_start, has_flux_end
end
local function runLazyFusionAnalysis(subs, sel, files, opts, vad_data, flux_data)
    local vad_ms = normalize_vad_to_ms(vad_data)
    local silences = merge_silence_to_intervals(files)
    local apply_start = opts.apply_start
    local apply_end = opts.apply_end
    local enable_tagging = opts.enable_tagging
    local tag_mode = opts.tag_mode
    local tag_scope = opts.tag_scope
    local modified = 0
    local seq = ordered_by_start(subs, sel)
    aegisub.progress.task("Analyzing (LazyFusion v2 EFS)...")
    for idx, ii in ipairs(seq) do
        aegisub.progress.set(idx / #seq * 100)
        local l = subs[ii]
        if l.class == "dialogue" then
            local os_ms, oe_ms = l.start_time, l.end_time
            local ns, ne = os_ms, oe_ms
            local t_start, t_end, has_flux_start, has_flux_end = find_activity_bounds(os_ms, oe_ms, vad_ms, silences, flux_data, nil)
            if t_start and t_end then
                local pad_start = has_flux_start and 0 or 15
                local pad_end = has_flux_end and 0 or 15
                if apply_start then
                    ns = t_start - pad_start
                    if ns < 0 then ns = 0 end
                end
                if apply_end then
                    ne = t_end + pad_end
                end
                if ne - ns < lazyConfig.min_duration then
                    local center = (t_start + t_end) / 2
                    local half_min = lazyConfig.min_duration / 2
                    ns = center - half_min
                    ne = center + half_min
                    if ns < 0 then ns = 0 end
                end
            else
                if enable_tagging then addLazyTag(l, "NoActivity") end
            end
            local changed = (math.abs(ns - os_ms) > 1) or (math.abs(ne - oe_ms) > 1)
            if changed then
                local ok, why = validateIntra(ns, ne, os_ms, oe_ms)
                if not ok then
                    local ok2, why2, ns2, ne2 = clampIntra(ns, ne, os_ms, oe_ms)
                    if ok2 then
                        l.start_time = round_ms(ns2)
                        l.end_time = round_ms(ne2)
                        modified = modified + 1
                        tag_decider(l, os_ms, oe_ms, ns2, ne2, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                    else
                        if enable_tagging then addLazyTag(l, "Reject:"..(why2 or why)) end
                    end
                else
                    l.start_time = round_ms(ns)
                    l.end_time = round_ms(ne)
                    modified = modified + 1
                    tag_decider(l, os_ms, oe_ms, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                end
            else
                tag_decider(l, os_ms, oe_ms, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
            end
            subs[ii] = l
        end
    end
    return modified
end
local function clamp(x,a,b) if x<a then return a elseif x>b then return b else return x end end
local function merge_intervals(ints,eps) table.sort(ints,function(a,b)return a.start<b.start end) local out={} for _,it in ipairs(ints)do if #out==0 then out[1]={start=it.start,["end"]=it["end"]} else local L=out[#out] if it.start<=L["end"]+(eps or 0) then if it["end"]>L["end"] then L["end"]=it["end"] end else out[#out+1]={start=it.start,["end"]=it["end"]} end end end return out end
local function intersect(a1,a2,b1,b2) local s=math.max(a1,b1) local e=math.min(a2,b2) if s<e then return s,e end end
local function noise_in_window(merged_silence,W1,W2,eps) local cut={} for _,si in ipairs(merged_silence)do local s,e=intersect(W1,W2,si.start,si["end"]) if s and e then cut[#cut+1]={start=s,["end"]=e} end end cut=merge_intervals(cut,eps) local noise={} local cur=W1 for _,si in ipairs(cut)do if si.start>cur+(eps or 0) then noise[#noise+1]={start=cur,["end"]=si.start} end cur=math.max(cur,si["end"]) end if cur<W2-(eps or 0) then noise[#noise+1]={start=cur,["end"]=W2} end return noise end
local function total_ms(ints) local s=0 for _,x in ipairs(ints)do s=s+(x["end"]-x.start) end return s end
local function merge_noise_small_gaps(noise,gap_ms) if #noise<=1 then return noise end local out={{start=noise[1].start,["end"]=noise[1]["end"]}} for i=2,#noise do local L=out[#out] local g=noise[i].start-L["end"] if g<=gap_ms then if noise[i]["end"]>L["end"] then L["end"]=noise[i]["end"] end else out[#out+1]={start=noise[i].start,["end"]=noise[i]["end"]} end end return out end
local function drop_edge_inconclusives(noise,W1,W2,edge_ms) if #noise==0 then return noise end local has_inner=false for _,n in ipairs(noise)do if n.start>W1 and n["end"]<W2 then has_inner=true break end end if not has_inner then return noise end local out={} for k,n in ipairs(noise)do local len=n["end"]-n.start local edge_left=(n.start<=W1+tableConfig.eps) local edge_right=(n["end"]>=W2-tableConfig.eps) if (edge_left or edge_right) and len<=edge_ms then else out[#out+1]=n end end return (#out>0) and out or noise end
local function center(t1,t2) return(t1+t2)/2 end
local function group_noise(noise,merge_gap_ms) if #noise==0 then return{} end local groups={} local cur={noise[1]} for i=2,#noise do local g=noise[i].start-noise[i-1]["end"] if g<=merge_gap_ms then cur[#cur+1]=noise[i] else groups[#groups+1]=cur cur={noise[i]} end end groups[#groups+1]=cur return groups end
local function cluster_span(G) return G[1].start,G[#G]["end"] end
local function cluster_score(G,W1,W2) local gs=total_ms(G) local s,e=cluster_span(G) local width=math.max(1,e-s) local cov=gs/width local prox=math.exp(-((center(s,e)-center(W1,W2))^2)/(tableConfig.sigma_ms^2)) local frag=(#G-1)/#G return tableConfig.w_cov*cov+tableConfig.w_prox*prox-tableConfig.w_frag*frag end
local function parseLazyFileTable(fp,t) local segs,duration_ms={},nil local fh=io.open(fp,"r") if not fh then return segs,duration_ms end local cur_start=nil for l in fh:lines()do local H,M,S=l:match("Duration:%s*(%d+):(%d+):([%d%.]+)") if H then duration_ms=(tonumber(H)*3600+tonumber(M)*60+tonumber(S))*1000 end local ss=l:match("silence_start:%s*([%d%.]+)") if ss then cur_start=tonumber(ss)*1000 end local se,sd=l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)") if se and cur_start then local dms=tonumber(sd)*1000 if dms>=((lazyConfig.thresholds[t] and lazyConfig.thresholds[t].min_silence_dur)or 100) then table.insert(segs,{start=cur_start,["end"]=tonumber(se)*1000,duration=dms,threshold=t}) end cur_start=nil end end fh:close() return segs,duration_ms end
local function loadLazyDataTable(fps) local rs,maxdur={},0 for t,p in pairs(fps)do local lst,dur=parseLazyFileTable(p,t) if dur and dur>maxdur then maxdur=dur end for _,s in ipairs(lst)do table.insert(rs,s) end end table.sort(rs,function(a,b)return a.start<b.start end) local ss,se={},{} for _,s in ipairs(rs)do table.insert(ss,{time=s["end"],duration=s.duration,threshold=s.threshold}) table.insert(se,{time=s.start,duration=s.duration,threshold=s.threshold}) end return ss,se,rs,maxdur end
local function buildNoiseTable(merged_silences,W1,W2,save_path) local noise=noise_in_window(merged_silences,W1,W2,tableConfig.eps) noise=merge_noise_small_gaps(noise,tableConfig.merge_gap_ms) if save_path then local f=io.open(save_path,"w") if f then f:write("start_ms,end_ms,duration_ms\n") for _,n in ipairs(noise)do f:write(string.format("%d,%d,%d\n",n.start,n["end"],n["end"]-n.start)) end f:close() end end return noise end
local function runTableAnalysis(subs,sel,lim,files,opts) local _,_,rs,maxdur=loadLazyDataTable(files) if not rs or #rs==0 then return 0 end local raw_sil={} for _,s in ipairs(rs)do raw_sil[#raw_sil+1]={start=s.start,["end"]=s["end"]} end local merged_sil=merge_intervals(raw_sil,tableConfig.eps) local base_folder=files[40] or files[30] or files[50] if base_folder and maxdur and maxdur>0 then local path_folder=base_folder:gsub("[^\\/]+$","") local out_csv=path_folder.."noise_table_global.csv" buildNoiseTable(merged_sil,0,maxdur,out_csv) end local apply_start=opts.apply_start local apply_end=opts.apply_end local enable_tag=opts.enable_tagging local tag_mode=opts.tag_mode local tag_scope=opts.tag_scope local modified=0 local seq=ordered_by_start(subs,sel) aegisub.progress.task("Analyzing (Table, intra ±"..tostring(lim).." ms)...") for idx,ii in ipairs(seq)do aegisub.progress.set(idx/#seq*100) local l=subs[ii] if l.class=="dialogue" then local os,oe=l.start_time,l.end_time local min_d=lazyConfig.min_duration local Slo,Shi=os,math.min(oe-min_d,os+lim) local Elo,Ehi=math.max(os+min_d,oe-lim),oe if Shi<Slo then Shi=Slo end if Ehi<Elo then Elo=Ehi end local noise=noise_in_window(merged_sil,os,oe,tableConfig.eps) noise=merge_noise_small_gaps(noise,tableConfig.merge_gap_ms) noise=drop_edge_inconclusives(noise,os,oe,tableConfig.edge_drop_ms) if #noise>1 then local pruned={} for _,n in ipairs(noise)do if(n["end"]-n.start)>=tableConfig.min_noise_ms then pruned[#pruned+1]=n end end if #pruned>0 then noise=pruned end end local ns,ne=os,oe local changed=false if #noise==0 then elseif #noise==1 then local n=noise[1] if apply_start then ns=clamp(n.start,Slo,Shi) end if apply_end then ne=clamp(n["end"],Elo,Ehi) end if ne-ns<min_d then local c=center(n.start,n["end"]) ns=clamp(math.floor(c-min_d/2+0.5),Slo,Shi) ne=clamp(ns+min_d,Elo,Ehi) end changed=(ns~=os) or (ne~=oe) else local groups=group_noise(noise,tableConfig.merge_gap_ms) local bestG,bestScore=groups[1],-1e9 for _,G in ipairs(groups)do local sc=cluster_score(G,os,oe) if sc>bestScore then bestScore,bestG=sc,G end end local cs,ce=cluster_span(bestG) if bestG[1].start<=os+tableConfig.eps and(bestG[1]["end"]-bestG[1].start)<=tableConfig.edge_drop_ms and #bestG>1 then cs=bestG[2].start end if bestG[#bestG]["end"]>=oe-tableConfig.eps and(bestG[#bestG]["end"]-bestG[#bestG].start)<=tableConfig.edge_drop_ms and #bestG>1 then ce=bestG[#bestG-1]["end"] end if apply_start then ns=clamp(cs,Slo,Shi) end if apply_end then ne=clamp(ce,Elo,Ehi) end if ne-ns<min_d then local big=bestG[1] local blen=big["end"]-big.start for _,n in ipairs(bestG)do local len=n["end"]-n.start if len>blen then big,blen=n,len end end ns=clamp(big.start,Slo,Shi) ne=clamp(big["end"],Elo,Ehi) if ne-ns<min_d then local c=center(ns,ne) ns=clamp(math.floor(c-min_d/2+0.5),Slo,Shi) ne=clamp(ns+min_d,Elo,Ehi) end end changed=(ns~=os) or (ne~=oe) end if apply_start or apply_end then if changed then local ok,why=validateIntra(ns,ne,os,oe) if not ok then local ok2,why2,ns2,ne2=clampIntra(ns,ne,os,oe) if ok2 then l.start_time,l.end_time=ns2,ne2 modified=modified+1 tag_decider(l,os,oe,ns2,ne2,apply_start,apply_end,enable_tag,tag_mode,tag_scope) else if enable_tag then addLazyTag(l,"Reject:"..(why2 or why)) end end else l.start_time,l.end_time=ns,ne modified=modified+1 tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tag,tag_mode,tag_scope) end subs[ii]=l else tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tag,tag_mode,tag_scope) subs[ii]=l end end end end return modified end
local function hd_extract_tags(subs,sel) for _,i in ipairs(sel)do local l=subs[i] local t=l.text local g=t:match("^{[^}]*}") if g then t=t:gsub("^{[^}]*}",""):gsub("^%s*(.-)%s*$","%1") l.effect=g else l.effect="" end l.text=t subs[i]=l end aegisub.set_undo_point("Extract Tags") end
local function hd_reinsert_tags(subs,sel) for _,i in ipairs(sel)do local l=subs[i] if l.effect~="" then l.text=l.effect:gsub(";",",")..l.text l.effect="" end subs[i]=l end aegisub.set_undo_point("Reinsert Tags") end
local function hd_copy_times(subs,sel) if #sel<2 then return end local f=subs[sel[1]] local s,e=f.start_time,f.end_time for i=2,#sel do local l=subs[sel[i]] l.start_time=s l.end_time=e subs[sel[i]]=l end aegisub.set_undo_point("Copy Times") end
local function hd_swap_comment(subs,sel)
    for _,i in ipairs(sel) do
        local l=subs[i]
        local out=""
        local last_idx=1
        for s,tag,e in l.text:gmatch("()({[^}]*})()") do
            local pre=l.text:sub(last_idx,s-1)
            if pre~="" then
                if pre:match("^%s+$") then
                    out=out..pre
                else
                    out=out.."{"..pre.."}"
                end
            end
            if tag:match("^{\\") or tag:match("^{%s*\\") then
                out=out..tag
            else
                out=out..tag:sub(2,-2)
            end
            last_idx=e
        end
        local post=l.text:sub(last_idx)
        if post~="" then
            if post:match("^%s+$") then
                out=out..post
            else
                out=out.."{"..post.."}"
            end
        end
        l.text=out
        subs[i]=l
    end
    aegisub.set_undo_point("Swap Comment")
end
local function processPunctuation(subs,sel,ptype) for _,i in ipairs(sel)do local l=subs[i] local t=l.text local c=t:gsub("{[^}]*}","") if c~="" then local p,s="","" if ptype==1 then p,s="¡","!" elseif ptype==2 then p,s="¿","?" elseif ptype==3 then p,s="¡¿","?!" end c=c:gsub("%.%s*$",""):gsub("%s+$","") local esc_p=p:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])","%%%1") local esc_s=s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])","%%%1") if not c:match("^"..esc_p) then c=p..c end if not c:match(esc_s.."$") then c=c..s end l.text=t:gsub("[^{}]+$",c) subs[i]=l end end end
local function hd_punct_exclamation(subs,sel) processPunctuation(subs,sel,1) aegisub.set_undo_point("Add Exclamation") end
local function hd_punct_question(subs,sel) processPunctuation(subs,sel,2) aegisub.set_undo_point("Add Question") end
local function hd_punct_both(subs,sel) processPunctuation(subs,sel,3) aegisub.set_undo_point("Add Both Marks") end
local function hd_sort_by_length(subs,sel) local t={} for _,i in ipairs(sel)do table.insert(t,{l=subs[i],n=charCount(subs[i].text),idx=i}) end table.sort(t,function(a,b)return a.n>b.n end) for k,v in ipairs(t)do subs[sel[k]]=v.l end aegisub.set_undo_point("Sort by Length") end
local function double_italics(subs,sel)
  local n=0
  for _,i in ipairs(sel) do
    local l=subs[i]
    local first_block=l.text:match("^{[^}]*}")
    if first_block and first_block:match("\\i1") then
      local rest=l.text:sub(#first_block+1)
      if rest:match("\\i0") then
        if l.effect=="" then l.effect="[CurE]" else
          if not l.effect:find("%[CurE%]") then l.effect=l.effect.." [CurE]" end
        end
        subs[i]=l
        n=n+1
      end
    end
  end
  aegisub.dialog.display({{class="label",label=string.format("Double Italics: Marked %d lines",n)}},{L("btn_ok")})
  aegisub.set_undo_point("Double Italics")
end
local function blank_eraser(subs,sel) local d={} for _,i in ipairs(sel)do if stripTags(subs[i].text):gsub("%s+","")=="" then table.insert(d,i) end end safeDelete(subs,d) aegisub.dialog.display({{class="label",label="Deleted "..#d.." lines."}},{L("btn_ok")}) aegisub.set_undo_point("Blank Eraser") end
local function join_same_text(subs,sel) table.sort(sel,function(a,b)return a>b end) for _,i in ipairs(sel)do if subs[i] then local l=subs[i] if i>1 and subs[i-1] and subs[i-1].text==l.text then local p=subs[i-1] p.end_time=math.max(p.end_time,l.end_time) subs[i-1]=p subs.delete(i) end end end aegisub.set_undo_point("Join Same Text") end
local function time_picker(subs, sel)
    if #sel == 0 then
        aegisub.dialog.display({{class="label", label="Error: No lines selected."}}, {L("btn_ok")})
        return sel
    end
    local config = {
        {
            class = "checkbox",
            name = "include_partial",
            label = "Include partially overlapping lines",
            value = true
        }
    }
    local button, result = aegisub.dialog.display(config, {"OK", "Cancel"})
    if button == "Cancel" then
        return sel
    end
    local include_partial = result.include_partial
    local min_start = nil
    local max_end = nil
    for _, line_index in ipairs(sel) do
        local line = subs[line_index]
        if line.class == "dialogue" and not line.comment then
            if min_start == nil or line.start_time < min_start then
                min_start = line.start_time
            end
            if max_end == nil or line.end_time > max_end then
                max_end = line.end_time
            end
        end
    end
    if min_start == nil or max_end == nil then
        aegisub.dialog.display({{class="label", label="Error: No valid active dialogue lines found."}}, {L("btn_ok")})
        return sel
    end
    local new_selection = {}
    local count = 0
    for i = 1, #subs do
        local line = subs[i]
        if line.class == "dialogue" and not line.comment then
            local line_in_range = false
            if include_partial then
                line_in_range = (line.start_time < max_end) and (line.end_time > min_start)
            else
                line_in_range = (line.start_time >= min_start) and (line.end_time <= max_end)
            end
            if line_in_range then
                table.insert(new_selection, i)
                count = count + 1
            end
        end
    end
    local function ms_to_time(ms)
        local centiseconds = math.floor(ms / 10)
        local seconds = math.floor(centiseconds / 100)
        local minutes = math.floor(seconds / 60)
        local hours = math.floor(minutes / 60)
        centiseconds = centiseconds % 100
        seconds = seconds % 60
        minutes = minutes % 60
        return string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
    end
    local start_str = ms_to_time(min_start)
    local end_str = ms_to_time(max_end)
    local mode_str = include_partial and "partial" or "complete"
    local message = string.format(
        "Time range: %s - %s\nMode: %s\nActive dialogue lines selected: %d",
        start_str, end_str, mode_str, count
    )
    aegisub.dialog.display({{class="label", label=message}}, {L("btn_ok")})
    return new_selection
end
local function style_sentinel(subs, selected_lines)
    local styles_found = {}
    local styles_list = ""
    for _, line_index in ipairs(selected_lines) do
        local line = subs[line_index]
        if line.class == "dialogue" then
            local style_name = line.style
            if not styles_found[style_name] then
                styles_found[style_name] = true
                if styles_list == "" then
                    styles_list = style_name
                else
                    styles_list = styles_list .. "\n" .. style_name
                end
            end
        end
    end
    if styles_list == "" then
        aegisub.dialog.display({{class="label", label="No styles found in selected lines."}}, {L("btn_ok")})
        return
    end
    local dialog_config = {
        {
            class = "label",
            label = "Styles found in selected lines:\n(Remove styles you DO NOT want to keep)",
            x = 0, y = 0, width = 3, height = 1
        },
        {
            class = "textbox",
            name = "styles_to_keep",
            text = styles_list,
            x = 0, y = 1, width = 3, height = 8
        },
        {
            class = "label",
            label = "Lines with styles NOT in the above list will be DELETED.",
            x = 0, y = 9, width = 3, height = 1
        }
    }
    local buttons = {"Filter", "Cancel"}
    local button_pressed, results = aegisub.dialog.display(dialog_config, buttons)
    if button_pressed == "Cancel" or not button_pressed then
        return
    end
    local styles_to_keep = {}
    local styles_input = results.styles_to_keep or ""
    for style in styles_input:gmatch("[^\n]+") do
        local clean_style = style:match("^%s*(.-)%s*$")
        if clean_style ~= "" then
            styles_to_keep[clean_style] = true
        end
    end
    if next(styles_to_keep) == nil then
        local confirm_config = {
            {
                class = "label",
                label = "WARNING!\nNo styles in the list to keep.\nThis will delete ALL selected lines.\nContinue?",
                x = 0, y = 0, width = 2, height = 1
            }
        }
        local confirm_buttons = {"Yes, delete all", "Cancel"}
        local confirm_pressed = aegisub.dialog.display(confirm_config, confirm_buttons)
        if confirm_pressed == "Cancel" or not confirm_pressed then
            return
        end
    end
    local lines_to_delete = {}
    local deleted_count = 0
    local kept_count = 0
    local sorted_selected = {}
    for _, line_index in ipairs(selected_lines) do
        table.insert(sorted_selected, line_index)
    end
    table.sort(sorted_selected, function(a, b) return a > b end)
    for _, line_index in ipairs(sorted_selected) do
        local line = subs[line_index]
        if line.class == "dialogue" then
            if not styles_to_keep[line.style] then
                table.insert(lines_to_delete, line_index)
                deleted_count = deleted_count + 1
            else
                kept_count = kept_count + 1
            end
        end
    end
    if deleted_count > 0 then
        local summary_config = {
            {
                class = "label",
                label = string.format("Operation summary:\n\nLines to keep: %d\nLines to delete: %d\n\nProceed with deletion?",
                                    kept_count, deleted_count),
                x = 0, y = 0, width = 2, height = 1
            }
        }
        local summary_buttons = {"Yes, proceed", "Cancel"}
        local summary_pressed = aegisub.dialog.display(summary_config, summary_buttons)
        if summary_pressed == "Cancel" or not summary_pressed then
            return
        end
        for _, line_index in ipairs(lines_to_delete) do
            subs.delete(line_index)
        end
        aegisub.dialog.display({{class="label", label=string.format("Operation completed.\n\nLines deleted: %d\nLines kept: %d", deleted_count, kept_count)}}, {L("btn_ok")})
    else
        aegisub.dialog.display({{class="label", label="No lines to delete.\nAll selected lines have styles to keep."}}, {L("btn_ok")})
    end
end
local function caption_clarifier(subs, selected_lines)
    local modified_count = 0
    for _, line_index in ipairs(selected_lines) do
        local line          = subs[line_index]
        local original_text = line.text
        local modified_text = original_text
        repeat
            local old_text = modified_text
            modified_text = modified_text:gsub("（[^（）]*）", "")
            if modified_text == old_text then
                modified_text = modified_text:gsub("（.*）", "")
            end
        until modified_text == old_text
        repeat
            local old_text = modified_text
            modified_text = modified_text:gsub("%([^%(%)]*%)", "")
            if modified_text == old_text then
                modified_text = modified_text:gsub("%(.*%)", "")
            end
        until modified_text == old_text
        local saved_tags = {}
        modified_text = modified_text:gsub("{(\\[^}]*)}", function(tag) saved_tags[#saved_tags+1] = "{"..tag.."}" return "\0TAG"..#saved_tags.."\0" end)
        local patterns = {
            "［[^［］]*］",
            "［.*］",
            "%[[^%[%]]*%]",
            "%[.*%]",
            "｛[^｛｝]*｝",
            "｛.*｝",
            "〈[^〈〉]*〉",
            "〈.*〉",
            "《[^《》]*》",
            "《.*》",
            "「[^「」]*」",
            "「.*」",
            "『[^『』]*』",
            "『.*』",
            "【[^【】]*】",
            "【.*】",
            "〔[^〔〕]*〕",
            "〔.*〕",
            "＜[^＜＞]*＞",
            "＜.*＞",
        }
        for _, pattern in ipairs(patterns) do
            repeat
                local old_text = modified_text
                modified_text = modified_text:gsub(pattern, "")
            until modified_text == old_text
        end
        modified_text = modified_text:gsub("\0TAG(%d+)\0", function(n) return saved_tags[tonumber(n)] or "" end)
        modified_text = modified_text:gsub("%s+", " ")
        modified_text = modified_text:gsub("^%s+", "")
        modified_text = modified_text:gsub("%s+$", "")
        if modified_text == "" then
            modified_text = " "
        end
        if modified_text ~= original_text then
            line.text            = modified_text
            subs[line_index] = line
            modified_count       = modified_count + 1
        end
    end
    local msg = modified_count > 0
        and string.format("Modified %d lines.", modified_count)
        or "No annotations found to remove."
    aegisub.dialog.display({{class="label",label=msg,x=0,y=0,width=1,height=1}}, {L("btn_ok")})
end
local function ms_to_ass_time(ms)
    local h = math.floor(ms / 3600000)
    local m = math.floor((ms % 3600000) / 60000)
    local s = math.floor((ms % 60000) / 1000)
    local cs = math.floor((ms % 1000) / 10)
    return string.format("%d:%02d:%02d.%02d", h, m, s, cs)
end
local function getFoldLevel(text)
    local level = text:match("^{=(%d+)}")
    return level and tonumber(level) or nil
end
local function isFoldMarker(line)
    if type(line) == "table" then
        return getFoldLevel(line.text) ~= nil
    else
        return getFoldLevel(line) ~= nil
    end
end
local function fold_copy(subs, sel)
    if #sel == 0 then 
        aegisub.dialog.display({{class="label",label="No lines selected."}},{L("btn_ok")})
        return
    end
    local act = sel[1]
    local function parseLineFold(line)
        if not line.extra then return nil end
        local info = line.extra["_aegi_folddata"]
        if not info then return nil end
        local side, collapsed, id = info:match("^(%d+);(%d+);(%d+)$")
        if not side then return nil end
        return {side=tonumber(side), collapsed=tonumber(collapsed), id=tonumber(id)}
    end
    local foldStack, newSelection, foldAroundLine = {}, {}
    for i = 1, #subs do
        if subs[i].class ~= "dialogue" then goto continue end
        local line = subs[i]
        local folddata = parseLineFold(line)
        if folddata and folddata.side == 0 then
            table.insert(foldStack, {index=i, id=folddata.id})
        end
        if i == act then
            if #foldStack == 0 then
                aegisub.dialog.display({
                    {class="label", label="Active line is not inside a fold.\\nMove to a line within a fold group."}
                }, {L("btn_ok")})
                return
            end
            foldAroundLine = foldStack[#foldStack]
            newSelection = {}
            for j = foldAroundLine.index, i do
                table.insert(newSelection, j)
            end
        elseif i > act and foldAroundLine then
            table.insert(newSelection, i)
        end
        if folddata and folddata.side == 1 then
            if #foldStack > 0 and foldStack[#foldStack].id == folddata.id then
                table.remove(foldStack)
                if foldAroundLine and foldAroundLine.id == folddata.id then
                    break
                end
            end
        end
        ::continue::
    end
    if not foldAroundLine or #newSelection == 0 then
        aegisub.dialog.display({
            {class="label", label="Could not find complete fold group."}
        }, {L("btn_ok")})
        return
    end
    local clipboard_lines = {}
    for _, idx in ipairs(newSelection) do
        local l = subs[idx]
        if l.class == "dialogue" then
            local line_str = string.format(
                "%s: %d,%s,%s,%s,%s,%d,%d,%d,%s,%s",
                l.comment and "Comment" or "Dialogue",
                l.layer,
                ms_to_ass_time(l.start_time),
                ms_to_ass_time(l.end_time),
                l.style,
                l.actor,
                l.margin_l or 0,
                l.margin_r or 0,
                l.margin_t or l.margin_v or 0,
                l.effect,
                l.text
            )
            table.insert(clipboard_lines,line_str)
        end
    end
    local clipboard_text = table.concat(clipboard_lines, "\n")
    aegisub.dialog.display({
        {class="label", label=string.format("Fold group found (%d lines)\\nCopy text below manually:", #newSelection), x=0, y=0, width=40, height=1},
        {class="textbox", name="clipboard", text=clipboard_text, x=0, y=1, width=40, height=20}
    }, {L("btn_ok")})
    return newSelection
end
local lb_cfg={minLength=15,widthDiffPenalty=100,shortCharsPenalty=500,minChars=5,shortWordsPenalty=1000,minWords=2}
local function isWS(c) return c==" " or c=="\t" end
local function cntW(t) if not t or t=="" then return 0 end local count=0 local inWord=false for i=1,#t do local c=t:sub(i,i) if isWS(c) then inWord=false else if not inWord then count=count+1 inWord=true end end end return count end
local function measW(t,s) if not t or t=="" then return 0 end return aegisub.text_extents(s,stripTags(t)) or 0 end
local function findBP(t) local p,inT={},false for i=1,#t do local c=t:sub(i,i) if c=="{" then inT=true elseif c=="}" then inT=false elseif not inT and isWS(c) then table.insert(p,i) end end return p end
local function splT(t,p) local a=t:sub(1,p) local s=p+1 while s<=#t and isWS(t:sub(s,s)) do s=s+1 end return a,t:sub(s) end
local function fBest(t,s,mw) local bp=findBP(t) if #bp==0 then return nil end local bc,bi=math.huge,nil for _,p in ipairs(bp)do local p1,p2=splT(t,p) local w1,w2=measW(p1,s),measW(p2,s) local diff=math.abs(w1-w2) local c=lb_cfg.widthDiffPenalty*diff if #stripTags(p2)<lb_cfg.minChars then c=c+lb_cfg.shortCharsPenalty end if cntW(stripTags(p2))<lb_cfg.minWords then c=c+lb_cfg.shortWordsPenalty end if c<bc then bc=c bi=p end end return bi end
local function insN(t,p) return t:sub(1,p).."\\N"..t:sub(p+1) end
local function leblanc_six(subs,sel) 
  local vw=aegisub.video_size()
  if type(vw)=="table" and vw.width then 
    vw=vw.width 
  else 
    vw=1920 
  end 
  local st={} 
  for i=1,#subs do 
    if subs[i].class=="style" then st[subs[i].name]=subs[i] end 
  end 
  aegisub.progress.task("LeBlanc Six Auto-Break...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local l=subs[i] 
    local s=st[l.style] 
    if s and not l.text:find("\\N") and #stripTags(l.text)>lb_cfg.minLength then 
      local av=vw-(l.margin_l>0 and l.margin_l or s.margin_l)-(l.margin_r>0 and l.margin_r or s.margin_r) 
      if measW(l.text,s)>av then 
        local bp=fBest(l.text,s,av) 
        if bp then 
          l.text=insN(l.text,bp) 
          subs[i]=l 
        end 
      end 
    end 
  end 
end
local hd_items={"","Kite Timing","Frame to Effect","Blank Eraser","Join Same Text","Time Picker","Caption Clarifier","Style Sentinel","LeBlanc Six","Copy Times","Extract Tags","Reinsert Tags","Sort by Length","Punctuation: ¡!","Punctuation: ¿?","Punctuation: ¡¿?!","Swap Comment","Add an8","Copy Fold Group","Double Italics"}
local hd_info={
    ["Blank Eraser"]="Removes empty lines (no visible text)",
    ["Join Same Text"]="Joins consecutive lines with identical text",
    ["LeBlanc Six"]="Divides lines automatically by video width",
    ["Style Sentinel"]="Filters lines by style with confirmation dialogs",
    ["Time Picker"]="Selects active dialogue lines within time range (dialog only)",
    ["Caption Clarifier"]="Removes annotations and cleans whitespace (comprehensive)",
    ["Sort by Length"]="Sorts selection by character count",
    ["Copy Times"]="Copies times from first line to others",
    ["Extract Tags"]="Extracts tags to Effect field",
    ["Reinsert Tags"]="Reinserts tags from Effect to text",
    ["Swap Comment"]="Swaps text with comment in curly braces",
    ["Add an8"]="Adds the tag {\\an8} (top alignment) to lines",
    ["Copy Fold Group"]="Copies fold group {=N} and all its lines to dialog for manual clipboard copy",
    ["Double Italics"]="Marks lines where \\i1 at start is broken by \\i0 later [CurE]",
    ["Frame to Effect"]="Puts current video frame number in Effect field",
    ["Kite Timing"]="Lead-in/out with keyframe snap and chaining"
}
local function hd_add_an8(subs,sel)
    for _,i in ipairs(sel)do
        local l=subs[i]
        local existing_tags=l.text:match("^{[^}]*}")
        if existing_tags then
            if not existing_tags:match("\\an%d") then
                l.text=l.text:gsub("^({[^}]*)","%1\\an8")
            end
        else
            l.text="{\\an8}"..l.text
        end
        subs[i]=l
    end
end
local function lazyTimer(subs, sel)
    if not sel or #sel == 0 then return end
    local res = {
        method = current_config.lazy_method,
        lim = current_config.lazy_limit,
        apply_start = current_config.lazy_apply_start,
        apply_end = current_config.lazy_apply_end,
        enable_tagging = current_config.lazy_enable_tagging,
        tag_mode = current_config.lazy_tag_mode,
        tag_scope = current_config.lazy_tag_scope
    }
    local files = {}
    if res.method == "LazyFusion" then
        local f30 = getLazyPath("Silence file (-30 dB) [optional - CANCEL to skip]")
        if f30 then
            local f40 = getLazyPath("Silence file (-40 dB) [optional - CANCEL to skip]")
            local f50 = getLazyPath("Silence file (-50 dB) [optional - CANCEL to skip]")
            files = {[30] = f30}
            if f40 then files[40] = f40 end
            if f50 then files[50] = f50 end
        end
    elseif res.method == "Table (±ms)" then
        local ftable = getLazyPath("Silence file (any threshold)")
        if not ftable then return end
        files = {[40] = ftable}
    else 
        local f30 = getLazyPath("Silence file (-30 dB)")
        if not f30 then return end
        local f40 = getLazyPath("Silence file (-40 dB)")
        if not f40 then return end
        local f50 = getLazyPath("Silence file (-50 dB)")
        if not f50 then return end
        files = {[30] = f30, [40] = f40, [50] = f50}
    end
    local f_vad, f_flux
    if res.method == "LazyFusion" then
        f_flux = aegisub.dialog.open("Flux candidates (.tsv) [optional]", "", "", "*.tsv", false, true)
        f_vad = aegisub.dialog.open("VAD file (.tsv) [optional but recommended]", "", "", "*.tsv", false, true)
    else
        f_flux = aegisub.dialog.open("Flux candidates (.tsv) [optional - CANCEL to skip]", "", "", "*.tsv", false, true)
        f_vad = aegisub.dialog.open("VAD segments (.tsv) [optional - CANCEL to skip]", "", "", "*.tsv", false, true)
    end
    g_aux_vad = f_vad and parseVADtsv(f_vad) or nil
    g_aux_flux = f_flux and parseFLUXtsv(f_flux) or nil
    local ot = {}
    for _, i in ipairs(sel) do
        if subs[i].class == "dialogue" then
            ot[i] = {st = subs[i].start_time, et = subs[i].end_time}
            subs[i].effect = stripLZ(subs[i].effect)
        end
    end
    local opts = {
        apply_start = res.apply_start,
        apply_end = res.apply_end,
        enable_tagging = res.enable_tagging,
        tag_mode = res.tag_mode,
        tag_scope = res.tag_scope
    }
    local sil_count = 0
    for _ in pairs(files or {}) do sil_count = sil_count + 1 end
    if res.method == "LazyFusion" then
        local modified = runLazyFusionAnalysis(subs, sel, files, opts, g_aux_vad, g_aux_flux)
        aegisub.debug.out(string.format("\n=== LAZYFUSION (ADF) ===\nLines processed: %d\nLines modified: %d\nVAD: %s\nFLUX: %s\nSilences: %d files\n", #sel, modified, g_aux_vad and "YES" or "NO", g_aux_flux and "YES" or "NO", sil_count))
    elseif res.method == "Cluster (±ms)" then
        local lim = tonumber(res.lim) or 500
        local modified = runClusterAnalysis(subs, sel, lim, files, opts)
        aegisub.debug.out(string.format("\n=== CLUSTER (INTRA) ===\nLines processed: %d\nLines modified: %d\nLimit: ±%d ms\nVAD: %s\nFLUX: %s\n", #sel, modified, lim, g_aux_vad and "YES" or "NO", g_aux_flux and "YES" or "NO"))
    else 
        local lim = tonumber(res.lim) or 500
        local modified = runTableAnalysis(subs, sel, lim, files, opts)
        aegisub.debug.out(string.format("\n=== TABLE (INTRA) ===\nLines processed: %d\nLines modified: %d\n(noise-table logic)\n", #sel, modified))
    end
    g_aux_vad = nil
    g_aux_flux = nil
end
local function hd_frame_to_effect(subs, sel)
    local props = aegisub.project_properties()
    if not props or not props.video_position then
        aegisub.dialog.display({{class="label",label=L("err_no_video")}},{L("btn_ok")})
        return
    end
    local frame = props.video_position
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class == "dialogue" then
            if l.effect == "" then
                l.effect = tostring(frame)
            else
                l.effect = l.effect .. " " .. tostring(frame)
            end
            subs[i] = l
        end
    end
    aegisub.set_undo_point("Frame to Effect")
end
local function runScxvid()
    local scx_path = current_config.scxvid_path
    local ffmpeg_path = current_config.ffmpeg_path
    local log_suffix = current_config.scxvid_suffix
    local props=aegisub.project_properties()
    local video=props.video_file
    if not video or video=="" then
        aegisub.dialog.display({{class="label",label=L("err_no_video")}},{L("btn_ok")})
        return
    end
    local function fExists(p) 
        if p=="" then return false end
        local f=io.open(p) 
        if f then f:close() return true end 
        return false
    end
    local function dirName(p) return p:match("^(.*)[\\/]")or"" end
    local function baseName(p) return (p:gsub("^.*[\\/]",""):gsub("%.[^.]+$","")) end
    local scx = (scx_path~="" and scx_path or "scxvid.exe")
    local ffm = (ffmpeg_path~="" and ffmpeg_path or "ffmpeg")
    if scx_path~="" and not fExists(scx_path) then
        aegisub.dialog.display({{class="label",label=string.format(L("err_scxvid_not_found"),scx_path)}},{L("btn_ok")})
        return
    end
    if ffmpeg_path~="" and not fExists(ffmpeg_path) then
        aegisub.dialog.display({{class="label",label=string.format(L("err_ffmpeg_not_found"),ffmpeg_path)}},{L("btn_ok")})
        return
    end
    local dir = dirName(video)
    local outLog = dir .. (dir ~= "" and "\\" or "") .. baseName(video) .. (log_suffix ~= "" and log_suffix or "_keyframes.log")
    local bat=aegisub.decode_path("?temp/scxvid_run.bat")
    local f=io.open(bat,"w")
    if not f then
        aegisub.dialog.display({{class="label",label="Error: Cannot create temp batch file"}},{L("btn_ok")})
        return
    end
    f:write("@echo off\n\""..ffm.."\" -i \""..video.."\" -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | \""..scx.."\" \""..outLog.."\"\npause\n")
    f:close()
    os.execute('start "" "'..bat..'"')
    aegisub.dialog.display({
        {class="label",label=string.format(L("msg_process_started"),outLog)}
    },{L("btn_ok")})
end
local globalHelpText = [[
Chronorow Master v3.0 — Help
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────────────────────────┐
   HOW IT WORKS                       
└─────────────────────────────────────┘
  Enable the tools you need, set values in milliseconds, then press EXECUTE.
  Nothing changes until you do — experiment freely!
┌─────────────────────────────────────┐
   TIMING AUDIT MODULE                
└─────────────────────────────────────┘
  Mode: Controls which boundary to check
    • End Only    → Checks line endings only
    • Start Only  → Checks line starts only
    • Both        → Checks both boundaries
  Kite Audit (Dropdown):
    Selects a preset mode (Ends/Start/Both/Overtime) and runs it on Execute.
  Comment Purge (Dropdown):
    Handle commented lines: Delete, Move to Start, or Move to End.
  Keyframe Snap Seal [KF]
    Marks lines sitting on keyframes: [KF-E] / [KF-S]
  Twin KF Threshold (ms)
    Detects duplicate keyframes nearby. Line must already be on KF.
    Marks [Twin-E] / [Twin-S] if another KF exists within range.
    Recommended: 1000ms (0 = disabled)
  Miss KF Threshold (ms)
    Detects missed keyframes. Line must NOT be on KF.
    Marks [Miss-E] / [Miss-S] if a KF exists within range before.
    Recommended: 1000ms (0 = disabled)
  Max Duration (ms)
    Marks [Overtime] if line exceeds this length.
    Recommended: 5500ms for dialogue (0 = disabled)
  Other markers:
    • Overlap Detector   → [Overlap] on overlapping lines
    • Gap/Blink Detector → Configurable gap marking (see Config)
    • Uppercase Flagging → [UPPER] on all-caps lines
┌─────────────────────────────────────┐
   TEXT PROCESSING ENGINE             
└─────────────────────────────────────┘
  Sentence Splitter (.?!)
    Divides lines at sentence boundaries.
    └ Include Commas: Also splits at (,;)
    └ Simulation Mode: Only tags [2S][3S], no actual split
  Line Break Injector
    Splits lines at existing \\N tags.
  Romaji Karaoke Gen
    Converts romaji words to {\\k} syllable timing.
  Punctuation Check
    Marks lines missing final punctuation.
┌─────────────────────────────────────┐
   DATA IMPORT (MARABUNTA)            
└─────────────────────────────────────┘
  Paste Dialogue: lines to import data by time overlap.
  Modes:
    • Ant Effects → Imports Effect field
    • Ant Lines  → Imports text content
    • Ant Actor  → Assigns Actor by best overlap
    • Ant Songs  → Duplicates group using sync point (Comment layer 50)
    • Ant Twins  → Like Ant Lines, but same-layer only
┌─────────────────────────────────────┐
   CPS METRICS                        
└─────────────────────────────────────┘
  • CPS Ranker   → Sorts selection by characters/second
  • Show Avg CPS → Displays average CPS of selection
┌─────────────────────────────────────┐
   QUICK TOOLS (via EXECUTE)          
└─────────────────────────────────────┘
  Select a tool from dropdown at bottom. When EXECUTE is pressed,
  if a tool is selected it will run. Leave blank to skip tools.
  Kite Timing        → Lead-in/out with KF snap and chaining (Config values)
  Blank Eraser       → Deletes empty/whitespace-only lines
  Join Same Text     → Merges consecutive lines with identical text
  Time Picker        → Selects lines within a time range (dialog only)
  Style Sentinel     → Filters/deletes by style with confirmation
  Caption Clarifier  → Removes [text] (annotation) patterns
  LeBlanc Six        → Auto line-break by video width
  Copy Times         → Copies start/end from first line to rest
  Extract Tags       → Moves {tags} to Effect field
  Reinsert Tags      → Returns Effect back to text
  Sort by Length     → Sorts by character count (longest first)
  Punctuation ¡!/¿?  → Adds opening/closing punctuation
  Swap Comment       → Exchanges visible text with {comment}
  Add an8            → Inserts {\\an8} at start (top alignment)
  Copy Fold Group    → Copies fold group to clipboard
  Double Italics     → Marks broken \\i1...\\i0 patterns
  Import Text (Source Timing) -> Insert lines from clipboard, applied to selection's time
  Ellipsis Eraser (Clean ...) -> Removes leading ellipses/dots
  Actor Parser (Split & Format) -> Split (A)...(B) lines, italicize <thoughts>, sticky actor
  AE Keyframe Export (Full Data) -> Export Position, Scale, Rotation to AE keyframe data file
  Stutter Generator (L-Lword) -> Add stutter with punctuation support (¡¿)
  Actor Manager (Rename/Merge) -> Bulk rename or merge actors in selection
  Remplacer (Text Replacer) -> Bulk replace visible text, preserving tags

┌─────────────────────────────────────┐
   OTHER BUTTONS                      
└─────────────────────────────────────┘
  • KPP       → Kite Post-Processor: Lead-in/out, KF snapping & Chaining
  • LazyTimer → Auto-timing from FFmpeg silence analysis
  • Extract KF → Generate keyframes via SCXvid
  • Config    → Language, LazyTimer, GapMarker, Time Transplant Mode (Box/Clipboard)
]]
local function getHelpText()
    if current_lang == "es" then
        return [[
Chronorow Master v3.0 — Ayuda
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────────────────────────┐
   CÓMO FUNCIONA                      
└─────────────────────────────────────┘
  Activa las herramientas, configura valores en milisegundos y pulsa EJECUTAR.
  Nada cambia hasta que lo hagas. ¡Experimenta libremente!
┌─────────────────────────────────────┐
   MÓDULO AUDITORÍA TIMING            
└─────────────────────────────────────┘
  Modo: Controla qué extremo verificar
    • Solo Fin    → Verifica solo finales de línea
    • Solo Inicio → Verifica solo inicios de línea
    • Ambos       → Verifica ambos extremos
  Kite Audit (Dropdown):
    Selecciona un modo preset (Ends/Start/Both/Overtime) y lo ejecuta.
  Comment Purge (Dropdown):
    Maneja líneas comentadas: Borrar, Mover al inicio, Mover al final.
  Keyframe Snap Seal [KF]
    Marca líneas posicionadas en keyframes: [KF-E] / [KF-S]
  Twin KF Threshold (ms)
    Detecta keyframes duplicados cercanos. La línea debe estar en KF.
    Marca [Twin-E] / [Twin-S] si hay otro KF dentro del rango.
    Recomendado: 1000ms (0 = desactivado)
  Miss KF Threshold (ms)
    Detecta keyframes perdidos. La línea NO debe estar en KF.
    Marca [Miss-E] / [Miss-S] si hay un KF cercano antes.
    Recomendado: 1000ms (0 = desactivado)
  Duración Máx (ms)
    Marca [Overtime] si la línea supera esta duración.
    Recomendado: 5500ms para diálogo (0 = desactivado)
  Otros marcadores:
    • Overlap Detector   → [Overlap] en líneas superpuestas
    • Gap/Blink Detector → Marcado configurable (ver Config)
    • Uppercase Flagging → [UPPER] en líneas TODO MAYÚSCULAS
┌─────────────────────────────────────┐
   PROCESAMIENTO DE TEXTO             
└─────────────────────────────────────┘
  Sentence Splitter (.?!)
    Divide líneas en límites de oración.
    └ Include Commas: También divide en (,;)
    └ Simulation Mode: Solo etiqueta [2S][3S], no divide
  Line Break Injector
    Divide líneas en etiquetas \\N existentes.
  Romaji Karaoke Gen
    Convierte palabras romaji a timing silábico {\\k}.
  Punctuation Check
    Marca líneas sin puntuación final.
┌─────────────────────────────────────┐
   IMPORTAR DATOS (MARABUNTA)         
└─────────────────────────────────────┘
  Pega líneas Dialogue: para importar datos por superposición temporal.
  Modos:
    • Ant Effects → Importa campo Effect
    • Ant Lines  → Importa contenido de texto
    • Ant Actor  → Asigna Actor por mejor superposición
    • Ant Songs  → Duplica grupo usando sync point (Comment capa 50)
    • Ant Twins  → Como Ant Lines, pero solo misma capa
┌─────────────────────────────────────┐
   MÉTRICAS CPS                       
└─────────────────────────────────────┘
  • CPS Ranker   → Ordena selección por caracteres/segundo
  • Show Avg CPS → Muestra CPS promedio de la selección
┌─────────────────────────────────────┐
   HERRAMIENTAS (vía EJECUTAR)        
└─────────────────────────────────────┘
  Selecciona una herramienta del dropdown inferior. Al pulsar EJECUTAR,
  si hay herramienta seleccionada se ejecutará. Deja en blanco para omitir.
  Kite Timing        → Lead-in/out con snap a KF y encadenado (valores en Config)
  Blank Eraser       → Elimina líneas vacías/solo espacios
  Join Same Text     → Une líneas consecutivas con texto idéntico
  Time Picker        → Selecciona líneas en rango de tiempo (solo diálogo)
  Style Sentinel     → Filtra/elimina por estilo con confirmación
  Caption Clarifier  → Elimina patrones [texto] (anotaciones)
  LeBlanc Six        → Salto de línea automático por ancho de video
  Copy Times         → Copia inicio/fin de primera línea al resto
  Extract Tags       → Mueve {tags} al campo Effect
  Reinsert Tags      → Devuelve Effect al texto
  Sort by Length     → Ordena por cantidad de caracteres (mayor primero)
  Punctuation ¡!/¿?  → Añade signos de apertura/cierre
  Swap Comment       → Intercambia texto visible con {comentario}
  Add an8            → Inserta {\\an8} al inicio (alineación arriba)
  Copy Fold Group    → Copia grupo fold al portapapeles
  Double Italics     → Marca patrones rotos \\i1...\\i0
  Importar Texto (Tiempos Origen) -> Inserta líneas del portapapeles con tiempos de la selección
  Borrador Elipsis (Limpiar ...) -> Elimina puntos suspensivos iniciales
  Procesar Actores (Dividir/Formato) -> Divide líneas (A)...(B), cursiva en <pensamientos>
  Exportar Keyframes AE (Datos Completos) -> Exporta Posición, Escala, Rotación a archivo AE
  Generador Tartamudeo (L-Lpalabra) -> Añade tartamudeo soportando puntuación (¡¿)
  Gestor Actores (Unir/Renombrar) -> Renombra o fusiona actores en la selección
  Remplacer (Reemplazar Texto) -> Reemplaza textos visibles en masa, preservando tags
┌─────────────────────────────────────┐
   OTROS BOTONES                      
└─────────────────────────────────────┘
  • KPP       → Kite Post-Processor: Lead-in/out, Snapping a KF y Encadenado
  • LazyTimer → Auto-timing desde análisis de silencios FFmpeg
  • Extract KF → Genera keyframes con SCXvid
  • Config    → Idioma, LazyTimer, GapMarker, Modo Trasplante (Caja/Clipboard)
]]
    elseif current_lang == "pt" then
        return [[
Chronorow Master v3.0 — Ajuda
═══════════════════════════════════════════════════════════════════════════════
┌─────────────────────────────────────┐
   COMO FUNCIONA                      
└─────────────────────────────────────┘
  Ative as ferramentas, configure valores em milissegundos e clique EXECUTAR.
  Nada muda até você fazer isso. Experimente à vontade!
┌─────────────────────────────────────┐
   MÓDULO AUDITORIA TIMING            
└─────────────────────────────────────┘
  Modo: Controla qual extremidade verificar
    • Apenas Fim    → Verifica apenas finais de linha
    • Apenas Início → Verifica apenas inícios de linha
    • Ambos         → Verifica ambas extremidades
  Kite Audit (Dropdown):
    Seleciona um modo preset (Ends/Start/Both/Overtime) e executa.
  Comment Purge (Dropdown):
    Lida com linhas comentadas: Apagar, Mover p/ Início, Mover p/ Final.
  Keyframe Snap Seal [KF]
    Marca linhas posicionadas em keyframes: [KF-E] / [KF-S]
  Twin KF Threshold (ms)
    Detecta keyframes duplicados próximos. A linha deve estar em KF.
    Marca [Twin-E] / [Twin-S] se houver outro KF no intervalo.
    Recomendado: 1000ms (0 = desativado)
  Miss KF Threshold (ms)
    Detecta keyframes perdidos. A linha NÃO deve estar em KF.
    Marca [Miss-E] / [Miss-S] se houver um KF próximo antes.
    Recomendado: 1000ms (0 = desativado)
  Duração Máx (ms)
    Marca [Overtime] se a linha exceder esta duração.
    Recomendado: 5500ms para diálogo (0 = desativado)
  Outros marcadores:
    • Overlap Detector   → [Overlap] em linhas sobrepostas
    • Gap/Blink Detector → Marcação configurável (ver Config)
    • Uppercase Flagging → [UPPER] em linhas TUDO MAIÚSCULO
┌─────────────────────────────────────┐
   PROCESSAMENTO DE TEXTO             
└─────────────────────────────────────┘
  Sentence Splitter (.?!)
    Divide linhas em limites de frase.
    └ Include Commas: Também divide em (,;)
    └ Simulation Mode: Apenas marca [2S][3S], não divide
  Line Break Injector
    Divide linhas em tags \\N existentes.
  Romaji Karaoke Gen
    Converte palavras romaji para timing silábico {\\k}.
  Punctuation Check
    Marca linhas sem pontuação final.
┌─────────────────────────────────────┐
   IMPORTAR DATOS (MARABUNTA)         
└─────────────────────────────────────┘
  Cole linhas Dialogue: para importar dados por sobreposição temporal.
  Modos:
    • Ant Effects → Importa campo Effect
    • Ant Lines  → Importa conteúdo de texto
    • Ant Actor  → Atribui Actor pela melhor sobreposição
    • Ant Songs  → Duplica grupo usando sync point (Comment camada 50)
    • Ant Twins  → Como Ant Lines, mas apenas mesma camada
┌─────────────────────────────────────┐
   MÉTRICAS CPS                       
└─────────────────────────────────────┘
  • CPS Ranker   → Ordena seleção por caracteres/segundo
  • Show Avg CPS → Mostra CPS média da seleção
┌─────────────────────────────────────┐
   FERRAMENTAS (via EXECUTAR)         
└─────────────────────────────────────┘
  Selecione uma ferramenta do dropdown na parte inferior. Ao clicar EXECUTAR,
  se houver ferramenta selecionada ela será executada. Deixe em branco para pular.
  Kite Timing        → Lead-in/out com snap a KF e encadeamento (valores em Config)
  Blank Eraser       → Deleta linhas vazias/só espaços
  Join Same Text     → Une linhas consecutivas com texto idêntico
  Time Picker        → Seleciona linhas em intervalo de tempo (só diálogo)
  Style Sentinel     → Filtra/deleta por estilo com confirmação
  Caption Clarifier  → Remove padrões [texto] (anotações)
  LeBlanc Six        → Quebra de linha automática por largura do vídeo
  Copy Times         → Copia início/fim da primeira linha para resto
  Extract Tags       → Move {tags} para campo Effect
  Reinsert Tags      → Devolve Effect ao texto
  Sort by Length     → Ordena por quantidade de caracteres (maior primeiro)
  Punctuation ¡!/¿?  → Adiciona sinais de abertura/fechamento
  Swap Comment       → Troca texto visível com {comentário}
  Add an8            → Insere {\\an8} no início (alinhamento topo)
  Copy Fold Group    → Copia grupo fold para área de transferência
  Double Italics     → Marca padrões quebrados \\i1...\\i0
  Importar Texto (Tempos Origem) -> Insere linhas da área de transferência com tempos da seleção
  Apagar Reticências (Limpar ...) -> Remove reticências iniciais
  Processar Atores (Dividir/Formato) -> Divide linhas (A)...(B), itálico em <pensamentos>
  Exportar Keyframes AE (Dados Completos) -> Exporta Posição, Escala, Rotação para arquivo AE
  Gerador Gagueira (L-Lpalavra) -> Adiciona gagueira suportando pontuação (¡¿)
  Gerenciador Atores (Unir/Renomear) -> Renomeia ou mescla atores na seleção
  Remplacer (Substituir Texto) -> Substitui textos visíveis em massa, preservando tags
┌─────────────────────────────────────┐
   OUTROS BOTÕES                      
└─────────────────────────────────────┘
  • KPP       → Kite Post-Processor: Lead-in/out, Snapping a KF e Encadeamento
  • LazyTimer → Auto-timing a partir de análise de silêncios FFmpeg
  • Extract KF → Gera keyframes com SCXvid
  • Config    → Idioma, LazyTimer, GapMarker, Modo Trasplante (Box/Transf)
]]
    else
        return globalHelpText
    end
end
local fr,ms=aegisub.frame_from_ms,aegisub.ms_from_frame
local function get_fps()
    local m1,m0=ms(1),ms(0)
    return (m1 and m0 and m1~=m0) and 1000/(m1-m0) or 23.976
end
local function to_frame(t) local f=fr(t) if f then return f end return math.floor(t*get_fps()/1000+0.5) end
local function to_ms(f) local m=ms(f) if m then return m end return math.floor(f*1000/get_fps()+0.5) end
local function get_kf_set()
    local kfs=aegisub.keyframes()
    if not kfs or #kfs==0 then return {},{}end
    table.sort(kfs)
    local set={} for _,k in ipairs(kfs) do set[k]=true end
    return kfs,set
end
local function find_next_kf(f,kfs)
    for _,k in ipairs(kfs) do if k>f then return k end end
    return nil
end
local function find_prev_kf(f,kfs)
    local best=nil
    for _,k in ipairs(kfs) do
        if k<f then best=k
        elseif k>=f then break end
    end
    return best
end
local function kf_between(a,b,kfs)
    local r={}
    for _,k in ipairs(kfs) do if k>a and k<b then r[#r+1]=k end end
    return r
end
local function kt_snap(t)
    local f=fr(t); if not f then return t end; return ms(f)
end
local function kt_is_on_kf(t_ms,kfs)
    local f=fr(t_ms); if not f then return false end
    for _,k in ipairs(kfs) do
        if k==f then return true end
        if k>f then break end
    end
    return false
end
local function kt_find_kf_forward(orig,max_ms,kfs)
    local f0=fr(orig); local fl=fr(orig+max_ms)
    if not f0 or not fl then return nil end
    for _,k in ipairs(kfs) do
        if k>f0 and k<=fl then return ms(k) end
        if k>fl then break end
    end
    return nil
end
local function kt_find_kf_backward(orig,max_ms,kfs)
    local f0=fr(orig); local fl=fr(orig-max_ms)
    if not f0 or not fl then return nil end
    local best=nil
    for _,k in ipairs(kfs) do
        if k>=fl and k<f0 then best=k end
        if k>=f0 then break end
    end
    if best then return ms(best) end
    return nil
end
local function kt_calc_lead_in(orig_start,boundary,kfs,cfg)
    local hard=boundary or 0
    local kf=kt_find_kf_backward(orig_start,cfg.kt_lead_in_max,kfs)
    if kf and kf>=hard then return kf end
    return kt_snap(math.max(orig_start-cfg.kt_lead_in_base,hard))
end
local function kt_calc_lead_out(orig_end,boundary,kfs,cfg)
    local kf=kt_find_kf_forward(orig_end,cfg.kt_lead_out_max,kfs)
    if kf and (not boundary or kf<=boundary) then return kf end
    local base=orig_end+cfg.kt_lead_out_base
    if boundary then base=math.min(base,boundary) end
    return kt_snap(base)
end
local function kite_timing(subs,sel)
    if not fr(0) then showMsg(L("err_no_video")); return end
    local kfs=aegisub.keyframes() or {}; table.sort(kfs)
    local cfg=current_config
    local si=sel[1]
    local cur=subs[si]
    if not cur or cur.class~="dialogue" then return end
    local prev_idx,next_idx=nil,nil
    for j=si-1,1,-1 do if subs[j].class=="dialogue" and not subs[j].comment then prev_idx=j; break end end
    for j=si+1,#subs do if subs[j].class=="dialogue" and not subs[j].comment then next_idx=j; break end end
    local new_s,new_e=cur.start_time,cur.end_time
    if not prev_idx and not kt_is_on_kf(cur.start_time,kfs) then
        new_s=kt_calc_lead_in(cur.start_time,nil,kfs,cfg)
    end
    if next_idx then
        local nxt=subs[next_idx]
        local orig_e1,orig_s2=cur.end_time,nxt.start_time
        local e1_locked=kt_is_on_kf(orig_e1,kfs)
        local s2_locked=kt_is_on_kf(orig_s2,kfs)
        local gap=orig_s2-orig_e1
        local new_e1,new_s2=orig_e1,orig_s2
        if e1_locked and s2_locked then
        elseif e1_locked then
            if gap>0 then
                if gap<=cfg.kt_lead_in_max and gap<=cfg.kt_chain_gap_max then new_s2=orig_e1
                else new_s2=kt_calc_lead_in(orig_s2,orig_e1,kfs,cfg) end
            elseif gap<0 then
                new_s2=kt_calc_lead_in(orig_s2,nil,kfs,cfg)
                if new_s2<0 then new_s2=0 end
            end
        elseif s2_locked then
            if gap>0 then
                local reach=orig_s2-orig_e1
                if reach>=0 and reach<=cfg.kt_lead_out_chain and gap<=cfg.kt_chain_gap_max then new_e1=orig_s2
                else new_e1=kt_calc_lead_out(orig_e1,orig_s2,kfs,cfg) end
            elseif gap<0 then
                new_e1=kt_calc_lead_out(orig_e1,nil,kfs,cfg)
            end
        elseif gap>0 then
            local kf1=kt_find_kf_forward(orig_e1,cfg.kt_lead_out_max,kfs)
            if kf1 and kf1>orig_s2 then kf1=nil end
            local kf2=kt_find_kf_backward(orig_s2,cfg.kt_lead_in_max,kfs)
            if kf2 and kf2<orig_e1 then kf2=nil end
            local base_e1=kt_snap(math.min(orig_e1+cfg.kt_lead_out_base,orig_s2))
            local base_s2=kt_snap(math.max(orig_s2-cfg.kt_lead_in_base,orig_e1))
            if kf1 and kf2 then
                new_e1=kf1; new_s2=kf2
                if new_e1>new_s2 then local mid=kt_snap((new_e1+new_s2)/2); new_e1=mid; new_s2=mid end
            elseif kf1 and not kf2 then
                new_e1=kf1
                local reach=orig_s2-kf1
                if reach>=0 and reach<=cfg.kt_lead_in_max and gap<=cfg.kt_chain_gap_max then new_s2=kf1 else new_s2=base_s2 end
            elseif not kf1 and kf2 then
                new_s2=kf2
                local reach=kf2-orig_e1
                if reach>=0 and reach<=cfg.kt_lead_out_chain and gap<=cfg.kt_chain_gap_max then new_e1=kf2 else new_e1=base_e1 end
            else
                if gap<=cfg.kt_chain_gap_max and gap<=(cfg.kt_lead_out_chain+cfg.kt_lead_in_max) then
                    new_s2=base_s2; new_e1=new_s2
                else
                    new_e1=base_e1; new_s2=base_s2
                    if new_e1>new_s2 then local mid=kt_snap((new_e1+new_s2)/2); new_e1=mid; new_s2=mid end
                end
            end
        elseif gap<0 then
            new_e1=kt_calc_lead_out(orig_e1,nil,kfs,cfg)
            new_s2=kt_calc_lead_in(orig_s2,nil,kfs,cfg)
            if new_s2<0 then new_s2=0 end
        end
        new_e=new_e1
        nxt.start_time=new_s2; subs[next_idx]=nxt
    else
        if not kt_is_on_kf(cur.end_time,kfs) then
            new_e=kt_calc_lead_out(cur.end_time,nil,kfs,cfg)
        end
    end
    cur.start_time=new_s; cur.end_time=new_e; subs[si]=cur
end
local function strip_tags(t) return t:gsub("{[^}]*}",""):gsub("\\[Nn]"," ") end
local function char_count(t)
    local c=strip_tags(t):gsub("%s+"," "):match("^%s*(.-)%s*$")
    local n=0 for _ in c:gmatch("[%z\1-\127\194-\244][\128-\191]*") do n=n+1 end return n
end
local function collect_styles(subs,sel)
    local st,seen={"All","All Default","Default+Alt"},{}
    for _,i in ipairs(sel) do
        if subs[i].class=="dialogue" and not seen[subs[i].style] then
            seen[subs[i].style]=true st[#st+1]=subs[i].style
        end
    end
    return st
end
local function style_ok(ls,flt,ext)
    if flt=="All" then return true end
    if flt=="All Default" and ls:match("Defa") then return true end
    if flt=="Default+Alt" and (ls:match("Defa") or ls:match("Alt")) then return true end
    return ls==flt or (ext and ext~="" and ls==ext)
end
local function process_lines(lines,kfs,kf_set,opts)
    local N=#lines
    if N==0 then return end
    local LI,LO=opts.lead_in_f,opts.lead_out_f
    local KF_SNAP,CHAIN_MAX,KF_CHAIN=opts.kf_snap_f,opts.chain_max_f,opts.kf_chain_f
    local KF_SNAP_S=math.floor(KF_SNAP/2)
    for i=1,N do
        local ln=lines[i]
        if kf_set[ln.sf] then ln.new_sf=ln.sf; ln.snap_s=true
        else
            local pk=find_prev_kf(ln.sf,kfs)
            if pk and ln.sf-pk<=KF_SNAP_S then ln.new_sf=pk; ln.snap_s=true
            else ln.new_sf=ln.sf-LI; ln.snap_s=false end
        end
        ln.new_ef=nil
        ln.snap_e=false ln.chained=false
    end
    for i=1,N-1 do
        local cur,nxt=lines[i],lines[i+1]
        local ef_locked=kf_set[cur.ef] and true or false
        local sf_locked=kf_set[nxt.sf] and true or false
        if ef_locked and sf_locked then
            cur.new_ef=cur.ef
            nxt.new_sf=nxt.sf
        elseif ef_locked then
            cur.new_ef=cur.ef
            local raw_gap=nxt.sf-cur.ef
            if raw_gap>0 and raw_gap<=CHAIN_MAX and raw_gap<=KF_CHAIN then
                nxt.new_sf=cur.ef; cur.chained=true
            end
        elseif sf_locked then
            nxt.new_sf=nxt.sf
            local raw_gap=nxt.sf-cur.ef
            if raw_gap>0 and raw_gap<=CHAIN_MAX then
                local kfb=kf_between(cur.ef,nxt.sf,kfs)
                if #kfb>0 and nxt.sf-kfb[1]<=KF_CHAIN then
                    cur.new_ef=kfb[1]; cur.snap_e=true; cur.chained=true
                else
                    cur.new_ef=nxt.sf; cur.chained=true
                end
            elseif not cur.new_ef then
                local nk=find_next_kf(cur.ef,kfs)
                if nk and nk-cur.ef<=KF_SNAP then cur.new_ef=nk cur.snap_e=true
                else cur.new_ef=cur.ef+LO end
            end
        else
            local raw_gap=nxt.sf-cur.ef
            local kfb=kf_between(cur.ef,nxt.sf,kfs)
            local do_chain,chain_kf=false,nil
            if raw_gap<=CHAIN_MAX then
                if #kfb==0 then
                    do_chain=true
                else
                    if nxt.sf-kfb[1]<=KF_CHAIN then do_chain=true chain_kf=kfb[1] end
                end
            end
            if do_chain then
                if chain_kf then
                    cur.new_ef=chain_kf nxt.new_sf=chain_kf
                    cur.snap_e=true nxt.snap_s=true
                else
                    cur.new_ef=nxt.new_sf
                end
                cur.chained=true
            elseif not cur.new_ef then
                local nk=find_next_kf(cur.ef,kfs)
                if nk and nk-cur.ef<=KF_SNAP then cur.new_ef=nk cur.snap_e=true
                else cur.new_ef=cur.ef+LO end
            end
        end
    end
    local last=lines[N]
    if not last.new_ef then
        if kf_set[last.ef] then last.new_ef=last.ef last.snap_e=true
        else
            local nk=find_next_kf(last.ef,kfs)
            if nk and nk-last.ef<=KF_SNAP then last.new_ef=nk last.snap_e=true
            else last.new_ef=last.ef+LO end
        end
    end
    for i=1,N do
        if not lines[i].new_ef then lines[i].new_ef=lines[i].ef+LO end
        if lines[i].new_ef<=lines[i].new_sf then lines[i].new_ef=lines[i].new_sf+1 end
    end
end
local function build_gui(styles,fps)
    return {
        {x=0,y=0,width=8,class="label",label=string.format(L("lbl_kpp_title"),string.format("%.3f",fps))},
        {x=8,y=0,width=2,class="dropdown",name="style_filter",items=styles,value=current_config.style_filter},
        {x=10,y=0,width=2,class="edit",name="extra_style",value=current_config.extra_style},
        {x=0,y=1,width=12,class="label",label=L("lbl_timing")},
        {x=0,y=2,width=2,class="label",label=L("lbl_leadin")},
        {x=2,y=2,width=1,class="intedit",name="lead_in_f",value=current_config.lead_in_f,min=0,max=10},
        {x=3,y=2,width=2,class="label",label=L("lbl_leadout")},
        {x=5,y=2,width=1,class="intedit",name="lead_out_f",value=current_config.lead_out_f,min=0,max=30},
        {x=6,y=2,width=3,class="label",label=L("lbl_kfsnap")},
        {x=9,y=2,width=1,class="intedit",name="kf_snap_f",value=current_config.kf_snap_f,min=0,max=50},
        {x=0,y=3,width=12,class="label",label=L("lbl_chaining")},
        {x=0,y=4,width=3,class="label",label=L("lbl_chainmax")},
        {x=3,y=4,width=1,class="intedit",name="chain_max_f",value=current_config.chain_max_f,min=0,max=60},
        {x=5,y=4,width=4,class="label",label=L("lbl_kfchain")},
        {x=9,y=4,width=1,class="intedit",name="kf_chain_f",value=current_config.kf_chain_f,min=0,max=20},
        {x=0,y=5,width=3,class="checkbox",name="ignore_comments",label=L("lbl_ignore_comments"),value=current_config.ignore_comments},
        {x=3,y=5,width=3,class="checkbox",name="mark_changes",label=L("lbl_mark_changes"),value=current_config.mark_changes},
        {x=6,y=5,width=3,class="checkbox",name="show_stats",label=L("lbl_show_stats"),value=current_config.show_stats},
    }
end
local function run_kpp(subs,sel,opts)
    local kfs,kf_set=get_kf_set()
    local lines={}
    for _,i in ipairs(sel) do
        local line=subs[i]
        if line.class=="dialogue" and not(opts.ignore_comments and line.comment) and style_ok(line.style,opts.style_filter,opts.extra_style) then
            lines[#lines+1]={idx=i,line=line,sf=to_frame(line.start_time),ef=to_frame(line.end_time),chars=char_count(line.text)}
        end
    end
    if #lines==0 then return {total=0,snap_s=0,snap_e=0,chain=0} end
    table.sort(lines,function(a,b) return a.sf<b.sf end)
    process_lines(lines,kfs,kf_set,opts)
    local stats={total=0,snap_s=0,snap_e=0,chain=0}
    for _,ln in ipairs(lines) do
        local ns,ne=to_ms(ln.new_sf),to_ms(ln.new_ef)
        local changed=ns~=ln.line.start_time or ne~=ln.line.end_time
        if changed then
            stats.total=stats.total+1
            local marks={}
            if ln.snap_s then marks[#marks+1]="KF_S" stats.snap_s=stats.snap_s+1 end
            if ln.snap_e then marks[#marks+1]="KF_E" stats.snap_e=stats.snap_e+1 end
            if ln.chained then marks[#marks+1]="CHAIN" stats.chain=stats.chain+1 end
            if opts.mark_changes and #marks>0 then ln.line.effect=ln.line.effect.."["..table.concat(marks,"][").."]" end
        end
        ln.line.start_time=ns ln.line.end_time=ne
        subs[ln.idx]=ln.line
    end
    return stats
end
local function kpp_main(subs,sel)
    if not sel or #sel==0 then aegisub.dialog.display({{class="label",label=L("err_no_selection")}},{L("btn_ok")}) return end
    local fps=get_fps()
    local styles=collect_styles(subs,sel)
    
    while true do
        local pressed,res=aegisub.dialog.display(build_gui(styles,fps),{L("btn_process"),L("btn_save"),L("btn_cancel")},{cancel=L("btn_cancel")})
        
        if res then
            current_config.lead_in_f = res.lead_in_f
            current_config.lead_out_f = res.lead_out_f
            current_config.kf_snap_f = res.kf_snap_f
            current_config.chain_max_f = res.chain_max_f
            current_config.kf_chain_f = res.kf_chain_f
            current_config.ignore_comments = res.ignore_comments
            current_config.mark_changes = res.mark_changes
            current_config.show_stats = res.show_stats
            current_config.style_filter = res.style_filter
            current_config.extra_style = res.extra_style
        end
        
        if pressed==L("btn_save") then
            saveConfig()
            aegisub.dialog.display({{class="label",label=L("msg_config_saved")}},{L("btn_ok")})
        elseif pressed==L("btn_process") then
            local opts={
                lead_in_f=res.lead_in_f,lead_out_f=res.lead_out_f,
                kf_snap_f=res.kf_snap_f,chain_max_f=res.chain_max_f,kf_chain_f=res.kf_chain_f,
                ignore_comments=res.ignore_comments,mark_changes=res.mark_changes,
                style_filter=res.style_filter,extra_style=res.extra_style,
            }
            local stats=run_kpp(subs,sel,opts)
            if res.show_stats then
                aegisub.dialog.display({{class="label",label=string.format(
                    L("msg_kpp_done"),
                    stats.total,stats.snap_s,stats.snap_e,stats.chain)}},{L("btn_ok")})
            end
            aegisub.set_undo_point("KPP v5")
            return
        else
            return
        end
    end
end
local function sliceByActors(t)
    local parts = {}
    local current_part = ""
    local chars = {}
    for c in t:gmatch("[%z\1-\127\194-\244][\128-\191]*") do table.insert(chars, c) end
    
    local i = 1
    while i <= #chars do
        local c = chars[i]
        local is_start_marker = false
        if c:match("[(%[（［]") then
            local j = i + 1
            local name = ""
            while j <= #chars do
                local c2 = chars[j]
                if c2:match("[)%]）］]") then
                    if #name > 0 and #name < 30 then 
                        is_start_marker = true
                    end
                    break
                end
                name = name .. c2
                j = j + 1
            end
        end
        if is_start_marker and i > 1 and current_part:match("%S") then 
             table.insert(parts, current_part)
             current_part = ""
        end
        current_part = current_part .. c
        i = i + 1
    end
    if current_part ~= "" then table.insert(parts, current_part) end
    return parts
end


local function get_clipboard_windows()
    local temp_file = aegisub.decode_path("?temp") .. "\\tt_clipboard.txt"
    local ps_cmd = string.format('powershell -WindowStyle Hidden -NoProfile -NonInteractive -Command "$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Clipboard | Out-File -FilePath \'%s\' -Encoding UTF8"', temp_file)
    os.execute(ps_cmd)
    
    local wait_start = os.clock()
    while os.clock() - wait_start < 0.2 do end 
    
    local file = io.open(temp_file, "rb")
    if not file then return "" end
    local content = file:read("*all")
    file:close()
    os.remove(temp_file)
    
    if content:sub(1,3) == "\239\187\191" then content = content:sub(4) end
    return content
end

local function parseDialogueRaw(line)
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    if not line:match("^Dialogue:") then return nil end
    local commas = {}
    local pos = 1
    while pos do
        pos = line:find(",", pos)
        if pos then table.insert(commas, pos); pos = pos + 1 end
    end
    if #commas < 9 then return nil end
    
    local fields = {}
    local start_pos = line:find(":", 1, true) + 1
    local field_indices = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    for i, idx in ipairs(field_indices) do
        table.insert(fields, line:sub(start_pos, commas[idx]-1))
        start_pos = commas[idx] + 1
    end
    table.insert(fields, line:sub(start_pos)) 
    return fields
end

local function hd_time_transplant(subs, sel)
    if #sel ~= 1 then
        showMsg("Select exactly 1 line as timing reference.") 
        return
    end

    local source_line = subs[sel[1]]
    local start_time = source_line.start_time
    local end_time = source_line.end_time
    local content = ""

    if current_config.time_transplant_mode == "Box" then
        local dlg = {
            {class="label", label=L("tt_box_title"), x=0, y=0, width=80, height=1},
            {class="label", label=L("tt_box_label"), x=0, y=1, width=80, height=1},
            {class="textbox", name="paste", text="", x=0, y=2, width=80, height=20}
        }
        local btn, res = aegisub.dialog.display(dlg, {L("btn_ok"), L("btn_cancel")})
        if btn ~= L("btn_ok") then return end
        content = res.paste
    else
        content = get_clipboard_windows()
    end

    if not content or content:match("^%s*$") then 
        aegisub.dialog.display({{class="label", label=L("tt_err_invalid")}}, {L("btn_ok")})
        return 
    end

    local lines_added = 0
    local insert_pos = sel[1] + 1
    
    for line in content:gmatch("[^\r\n]+") do
        local fields = parseDialogueRaw(line)
        if fields then
            local new_line = cloneLine(source_line) 
            new_line.layer = tonumber(fields[1]) or 0
            new_line.start_time = start_time 
            new_line.end_time = end_time     
            new_line.style = fields[4]:gsub("^%s+", ""):gsub("%s+$", "")
            new_line.actor = fields[5]:gsub("^%s+", ""):gsub("%s+$", "")
            new_line.margin_l = tonumber(fields[6]) or 0
            new_line.margin_r = tonumber(fields[7]) or 0
            new_line.margin_t = tonumber(fields[8]) or 0
            new_line.effect = fields[9]:gsub("^%s+", ""):gsub("%s+$", "")
            new_line.text = fields[10]
            new_line.comment = false
            
            subs.insert(insert_pos, new_line)
            insert_pos = insert_pos + 1
            lines_added = lines_added + 1
        end
    end

    if lines_added > 0 then
        subs.delete(sel[1]) 
        aegisub.set_undo_point("Time Transplant")
    else
        aegisub.dialog.display({{class="label", label=L("tt_err_invalid")}}, {L("btn_ok")})
    end
end

local function hd_ellipsis_eraser(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local text = l.text
        local tags = text:match("^({[^}]*})")
        if tags then
             local after = text:sub(#tags + 1)
             after = after:gsub("^%s*%.%.%.+%s*", "")
             after = after:gsub("^%s*…+%s*", "")
             l.text = tags .. after
        else
             l.text = text:gsub("^%s*%.%.%.+%s*", ""):gsub("^%s*…+%s*", "")
        end
        subs[i] = l
    end
    aegisub.set_undo_point("Ellipsis Eraser")
end

local function hd_dramaturgy_plus(subs, sel)
    local function utf8_len(str)
        local _, count = string.gsub(str, "[^\128-\193]", "")
        return count
    end

    local function allocDur(seg, T)
        local c = 0
        for _, s in ipairs(seg) do
             local txt = s.text:gsub("{[^}]*}", ""):gsub("%s+", "")
             c = c + (utf8_len(txt) or #txt)
        end
        local d = {}
        local r = T
        if c == 0 then
            local s = math.floor(T / #seg)
            for i = 1, #seg do d[i] = s end
            d[#seg] = T - s * (#seg - 1)
        else
            for i, s in ipairs(seg) do
                local txt = s.text:gsub("{[^}]*}", ""):gsub("%s+", "")
                local len = utf8_len(txt) or #txt
                if i == #seg then
                    d[i] = r
                else
                    local v = math.floor(T * len / c)
                    d[i] = v
                    r = r - v
                end
            end
        end
        return d
    end

    local function parse_actors_and_split(text)
        local segments = {}
        local current_text = ""
        local current_actor = nil
        local i = 1
        local len = text:len()
        
        while i <= len do
            local sub = text:sub(i)
            local actor_match = nil
            local match_len = 0
            
            local patterns = {
                { "^%s*（(.-)）", 3 },
                { "^%s*%((.-)%)", 1 },
                { "^%s*%[(.-)%]", 1 },
                { "^%s*【(.-)】", 3 },
                { "^%s*［(.-)］", 3 },
                { "^%s*｛(.-)｝", 3 },
                { "^%s*〈(.-)〉", 3 },
                { "^%s*《(.-)》", 3 },
                { "^%s*「(.-)」", 3 },
                { "^%s*『(.-)』", 3 },
                { "^%s*〔(.-)〕", 3 }
            }
            
            for _, pat in ipairs(patterns) do
                local s, e, cap = sub:find(pat[1])
                if s then
                    actor_match = cap
                    match_len = e - s + 1
                    break
                end
            end
            
            if actor_match then
                if current_text ~= "" and current_text:match("%S") then
                     table.insert(segments, {actor = current_actor, text = current_text})
                     current_text = ""
                end
                
                i = i + match_len
                current_actor = actor_match
            else
                local b = text:byte(i)
                local char_len = (b >= 240) and 4 or (b >= 224) and 3 or (b >= 192) and 2 or 1
                current_text = current_text .. text:sub(i, i + char_len - 1)
                i = i + char_len
            end
        end
        
        if current_text ~= "" then
            table.insert(segments, {actor = current_actor, text = current_text})
        end
        return segments
    end

    local last_actor = nil 
    table.sort(sel)
    local shifts = 0
    
    for _, ix in ipairs(sel) do
        local i = ix + shifts
        local l = subs[i]
        local text = l.text
        text = text:gsub("<([^>]+)>", "{\\i1}%1{\\i0}")
        text = text:gsub("＜(.-)＞", "{\\i1}%1{\\i0}") -- Full-width angle brackets as thoughts
        
        local parts = parse_actors_and_split(text)
        
        if #parts == 0 then
            if last_actor then l.actor = last_actor; subs[i] = l end
        elseif #parts == 1 then
            local p = parts[1]
            if p.actor then
                l.actor = p.actor
                last_actor = p.actor
            elseif last_actor then
                l.actor = last_actor
            end
            l.text = p.text:gsub("^%s+", ""):gsub("%s+$", "")
            subs[i] = l
        else
            local dur = allocDur(parts, l.end_time - l.start_time)
            local t = l.start_time
            
            for j, p in ipairs(parts) do
                local nl = cloneLine(l)
                nl.start_time = t
                nl.end_time = t + dur[j]
                t = nl.end_time
                
                if p.actor then
                    nl.actor = p.actor
                    last_actor = p.actor
                elseif last_actor then
                    nl.actor = last_actor
                end
                nl.text = p.text:gsub("^%s+", ""):gsub("%s+$", "")
                
                if j == 1 then
                    subs[i] = nl
                else
                    subs.insert(i + j - 1, nl)
                    shifts = shifts + 1 
                end
            end
        end
    end
    aegisub.set_undo_point("Dramaturgy+")
end

local function hd_extract_motion(subs, sel)
    local FPS = (aegisub.frame_from_ms(1000) and 1000/aegisub.ms_from_frame(aegisub.frame_from_ms(1000))) or 23.976
    local vw, vh = aegisub.video_size()
    if not vw then vw, vh = 1920, 1080 end
    local frame_ms = 1000 / FPS
    local out_pos = {"Adobe After Effects 6.0 Keyframe Data\n", "\tUnits Per Second\t" .. FPS .. "\n", 
                     "\tSource Width\t"..vw.."\n", "\tSource Height\t"..vh.."\n", "\tSource Pixel Aspect Ratio\t1\n", 
                     "\tComp Pixel Aspect Ratio\t1\n\n", "Position\n\tFrame\tX pixels\tY pixels\tZ pixels\n"}
    local out_scale = {"\nScale\n\tFrame\tX percent\tY percent\tZ percent\n"}
    local out_rotate = {"\nRotation\n\tFrame\tDegrees\n"}
    local global_frame = 0
    
    for _, idx in ipairs(sel) do
        local line = subs[idx]
        local num_frames = math.max(1, math.floor((line.end_time - line.start_time) / frame_ms + 0.5))
        local x = line.text:match("\\pos%(([%d%.-]+),") or "960"
        local y = line.text:match("\\pos%([%d%.-]+,([%d%.-]+)%)") or "540"
        local fscx = line.text:match("\\fscx([%d%.-]+)") or "100"
        local fscy = line.text:match("\\fscy([%d%.-]+)") or "100"
        local frz = line.text:match("\\frz([%d%.-]+)") or "0"
        
        for _ = 1, num_frames do
            table.insert(out_pos, string.format("\t%d\t%s\t%s\t0\n", global_frame, x, y))
            table.insert(out_scale, string.format("\t%d\t%s\t%s\t%s\n", global_frame, fscx, fscy, fscx))
            table.insert(out_rotate, string.format("\t%d\t%s\n", global_frame, frz))
            global_frame = global_frame + 1
        end
    end
    
    table.insert(out_rotate, "\nEnd of Keyframe Data")
    aegisub.log(table.concat(out_pos) .. table.concat(out_scale) .. table.concat(out_rotate))
    aegisub.set_undo_point("AE Keyframe Export")
end

local function hd_add_stutter(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local has_TT = l.effect:match("TT")
        
        local pre, text = l.text:match("^({[^}]*})(.*)")
        if not pre then pre = ""; text = l.text end
        
        local punct, rest = text:match("^([¡¿%s]+)(.*)")
        if not punct then punct = ""; rest = text end
        
        local chars = {}
        for c in rest:gmatch("[%z\1-\127\194-\244][\128-\191]*") do table.insert(chars, c) end
        
        if #chars > 0 and chars[1]:match("[%a\128-\255]") then
             local base = chars[1]:upper()
             local is_stutter = (#chars >= 3 and chars[2] == "-" and chars[3]:lower() == chars[1]:lower())
             
             if is_stutter then
                 local res = {}
                 local mode = true
                 for _, c in ipairs(chars) do
                     if mode then
                        if c == "-" then table.insert(res, "-")
                        elseif c:lower() == base:lower() then table.insert(res, base)
                        else 
                            mode = false
                            table.insert(res, c)
                        end
                     else
                        table.insert(res, c)
                     end
                 end
                 l.text = pre .. punct .. table.concat(res)
             elseif has_TT then
                 local tail = table.concat(chars, "", 2)
                 local new_word = base .. "-" .. base .. tail
                 l.text = pre .. punct .. new_word
             end
        end
        subs[i] = l
    end
    aegisub.set_undo_point("Stutter Manager")
end

local function hd_actor_replace(subs, sel)
    local unique_actors = {}
    local seen = {}
    for _, i in ipairs(sel) do
        local a = subs[i].actor
        if not seen[a] then
            seen[a] = true
            table.insert(unique_actors, a)
        end
    end
    table.sort(unique_actors)
    
    local original_text = table.concat(unique_actors, "\n")
    
    local dlg = {
        {class="label", label=L("lbl_original"), x=0, y=0, width=15, height=1},
        {class="label", label=L("lbl_new"), x=15, y=0, width=15, height=1},
        {class="textbox", name="src", text=original_text, x=0, y=1, width=15, height=20},
        {class="textbox", name="dest", text=original_text, x=15, y=1, width=15, height=20}
    }
    
    local btn, res = aegisub.dialog.display(dlg, {L("btn_process"), L("btn_cancel")})
    if btn ~= L("btn_process") then return end
    
    local function parse_multiline(str)
        local t = {}
        str = str:gsub("\r\n", "\n"):gsub("\r", "\n")
        local i = 1
        while true do
            local next_i = str:find("\n", i)
            if not next_i then
                table.insert(t, str:sub(i))
                break
            end
            table.insert(t, str:sub(i, next_i - 1))
            i = next_i + 1
        end
        return t
    end
    
    local new_actors = parse_multiline(res.dest)
    local actor_map = {}
    
    for i, original in ipairs(unique_actors) do
        local new = new_actors[i]
        if new ~= nil and new ~= original then
            actor_map[original] = new
        end
    end
    
    local changed_lines = 0
    for _, idx in ipairs(sel) do
        local l = subs[idx]
        if actor_map[l.actor] ~= nil then
            l.actor = actor_map[l.actor]
            subs[idx] = l
            changed_lines = changed_lines + 1
        end
    end
    
    local unique_changed = 0 for _ in pairs(actor_map) do unique_changed = unique_changed + 1 end
    aegisub.dialog.display({{class="label", label=string.format(L("msg_actors_replaced"), unique_changed, changed_lines)}}, {L("btn_ok")})
    aegisub.set_undo_point("Actor Manager")
end

local function hd_text_replacer(subs,sel)
    if #sel<1 then showMsg(L("err_no_selection")); return end
    local dialog={
        {class="label",x=0,y=0,width=40,height=1,label="ORIGINAL TEXT"},
        {class="textbox",x=0,y=1,width=40,height=10,name="original",text=""},
        {class="label",x=41,y=0,width=40,height=1,label="REPLACEMENT TEXT"},
        {class="textbox",x=41,y=1,width=40,height=10,name="replacement",text=""},
        {class="label",x=0,y=11,width=81,height=1,label="Each line in Original matches corresponding line in Replacement. Tags preserved."}
    }
    local ret,res=aegisub.dialog.display(dialog,{"Replace All","Cancel"},{ok="Replace All",close="Cancel"})
    if ret=="Cancel" or not ret then return end
    local originales={}; for line in res.original:gmatch("[^\r\n]+") do table.insert(originales,line) end
    local reemplazos={}; for line in res.replacement:gmatch("[^\r\n]+") do table.insert(reemplazos,line) end
    if #originales~=#reemplazos or #originales==0 then return end
    local mapa={}; for i,orig in ipairs(originales) do mapa[orig]=reemplazos[i] end
    local mod=0
    for _,i in ipairs(sel) do
        local line=subs[i]
        local vis=line.text:gsub("{[^}]-}","")
        local repl=mapa[vis]
        if repl then
            local tags=line.text:match("^({[^}]-})") or ""
            line.text=tags..repl; line.effect="Remplacer"; subs[i]=line; mod=mod+1
        end
    end
    aegisub.set_undo_point("Remplacer")
end

local function row_master_gui(subs,sel)
    if not sel or #sel == 0 then
        aegisub.dialog.display({{class="label",label=L("err_no_selection")}},{L("btn_ok")})
        return
    end
    local p={twin="0",miss="0",ov="0",mode=L("dd_end_only"),kf=false,ovl=false,gap=false,upp=false,punct=false,
             sent=false,preview=false,comma=false,splitN=false,romaji=false,cps=false,avg=false,
             tm=L("dd_all_selected"),tv="",ht="",mm=L("dd_ant_effects"),mr="",mc=false,kite_audit="",comment_purge=""}
    while true do
        local hd_items = {
            "",
            L("tool_kitetiming"),
            L("tool_blank"), L("tool_join"), L("tool_time"), L("tool_style"), L("tool_caption"),
            L("tool_leblanc"), L("tool_copyt"), L("tool_extt"), L("tool_inst"), L("tool_sort"),
            L("tool_p_ex"), L("tool_p_qu"), L("tool_p_both"), L("tool_swap"), L("tool_an8"),
            L("tool_fold"), L("tool_dital"), L("tool_fte"),
            L("tool_transplant"), L("tool_ellipsis"), L("tool_dramaturgy"), L("tool_motion"), L("tool_stutter"),
            L("tool_actor_rep"),
            L("tool_remplacer")
        }
        local d={
            {class="label",label=L("lbl_apply_to"),x=0,y=0,width=4,height=1},
            {class="dropdown",name="tm",items={L("dd_all_selected"),L("dd_by_style"),L("dd_by_actor"),L("dd_by_effect"),L("dd_by_layer")},value=p.tm,x=4,y=0,width=8,height=1},
            {class="label",label="   "..L("lbl_filter"),x=12,y=0,width=4,height=1},
            {class="edit",name="tv",value=p.tv,hint=L("hint_filter_value"),x=16,y=0,width=8,height=1},
            {class="label",label=L("lbl_header_timing"),x=0,y=1,width=11,height=1},
            {class="label",label=" ",x=11,y=1,width=1,height=1},
            {class="label",label=L("lbl_header_text"),x=12,y=1,width=12,height=1},
            {class="label",label=L("lbl_mode"),x=0,y=2,width=4,height=1},
            {class="dropdown",name="mode",items={L("dd_end_only"),L("dd_start_only"),L("dd_both")},value=p.mode,hint=L("hint_mode"),x=4,y=2,width=7,height=1},
            {class="label",label="│",x=11,y=2,width=1,height=1},
            {class="checkbox",name="sent",label="Sentence Splitter (.?!)",value=p.sent,hint=L("hint_divide"),x=12,y=2,width=12,height=1},
            {class="label",label="Twin KF Threshold (ms):",x=0,y=3,width=7,height=1},
            {class="edit",name="twin",value=p.twin,hint=L("hint_twin_kf"),x=7,y=3,width=4,height=1},
            {class="label",label="│",x=11,y=3,width=1,height=1},
            {class="checkbox",name="comma",label="  └ Include Commas (,;)",value=p.comma,hint=L("hint_include_commas"),x=12,y=3,width=12,height=1},
            {class="label",label="Miss KF Threshold (ms):",x=0,y=4,width=7,height=1},
            {class="edit",name="miss",value=p.miss,hint=L("hint_miss_kf"),x=7,y=4,width=4,height=1},
            {class="label",label="│",x=11,y=4,width=1,height=1},
            {class="checkbox",name="preview",label="  └ Simulation Mode (Tags only)",value=p.preview,hint=L("hint_preview"),x=12,y=4,width=12,height=1},
            {class="label",label=L("lbl_overtime"),x=0,y=5,width=7,height=1},
            {class="edit",name="ov",value=p.ov,hint=L("hint_overtime"),x=7,y=5,width=4,height=1},
            {class="label",label="│",x=11,y=5,width=1,height=1},
            {class="checkbox",name="splitN",label="Line Break Injector (Split by \\N)",value=p.splitN,hint=L("hint_line_cleaver"),x=12,y=5,width=12,height=1},
            {class="checkbox",name="kf",label="Keyframe Snap Seal [KF]",value=p.kf,hint=L("hint_keyframe_seal"),x=0,y=6,width=11,height=1},
            {class="label",label="│",x=11,y=6,width=1,height=1},
            {class="checkbox",name="romaji",label="Romaji Karaoke Gen (Word -> \\k)",value=p.romaji,hint=L("hint_kana_beat"),x=12,y=6,width=12,height=1},
            {class="checkbox",name="ovl",label="Overlap Detector [Overlap]",value=p.ovl,hint=L("hint_overlap_alert"),x=0,y=7,width=11,height=1},
            {class="label",label="│",x=11,y=7,width=1,height=1},
            {class="checkbox",name="punct",label="Punctuation Check (Missing final)",value=p.punct,hint=L("hint_mark_miss_punct"),x=12,y=7,width=12,height=1},
            {class="checkbox",name="gap",label="Gap/Blink Detector [Gap]",value=p.gap,hint=L("hint_gap_marker"),x=0,y=8,width=11,height=1},
            {class="label",label="│",x=11,y=8,width=1,height=1},
            {class="checkbox",name="upp",label="Uppercase Flagging [UPPER]",value=p.upp,hint=L("hint_mark_uppercase"),x=12,y=8,width=12,height=1},
            {class="label",label=L("lbl_kite_audit"),x=0,y=9,width=4,height=1},
            {class="dropdown",name="kite_audit",items={"","Ends Only","Start Only","Both","Overtime"},value=p.kite_audit,hint=L("hint_kite_audit"),x=4,y=9,width=7,height=1},
            {class="label",label="│",x=11,y=9,width=1,height=1},
            {class="label",label=L("lbl_comment_purge"),x=12,y=9,width=3,height=1},
            {class="dropdown",name="comment_purge",items={"",L("dd_cp_delete"),L("dd_cp_start"),L("dd_cp_end")},value=p.comment_purge,hint=L("hint_comment_purge"),x=15,y=9,width=9,height=1},
            {class="label",label=L("lbl_close_left"),x=0,y=10,width=11,height=1},
            {class="label",label=L("lbl_close_mid"),x=11,y=10,width=1,height=1},
            {class="label",label=L("lbl_close_right"),x=12,y=10,width=12,height=1},
            {class="label",label=L("lbl_header_data"),x=0,y=11,width=11,height=1},
            {class="label",label=" ",x=11,y=11,width=1,height=1},
            {class="label",label=L("lbl_header_cps"),x=12,y=11,width=12,height=1},
            {class="label",label="Import Mode:",x=0,y=12,width=4,height=1},
            {class="dropdown",name="mm",items={L("dd_ant_effects"),L("dd_ant_lines"),L("dd_ant_actor"),L("dd_ant_songs"),L("dd_ant_twins")},value=p.mm,hint=L("hint_marabunta_mode"),x=4,y=12,width=7,height=1},
            {class="label",label=" ",x=11,y=12,width=1,height=1},
            {class="checkbox",name="cps",label="CPS Ranker (Sort)",value=p.cps,hint=L("hint_cps_ranker"),x=12,y=12,width=6,height=1},
            {class="checkbox",name="avg",label="Show Avg CPS",value=p.avg,hint=L("hint_show_avg"),x=18,y=12,width=6,height=1},
            {class="textbox",name="mr",value=p.mr,hint=L("hint_marabunta"),x=0,y=13,width=24,height=4},
            {class="checkbox",name="mc",label="Wrap imported text as comments {...}",value=p.mc,hint=L("hint_as_comment"),x=0,y=17,width=12,height=1},
            {class="label",label="Paste 'Dialogue:...' lines above",x=12,y=17,width=12,height=1},
            {class="label",label=L("lbl_sep_h"),x=0,y=18,width=24,height=1},
            {class="label",label=L("lbl_header_tools"),x=0,y=19,width=4,height=1},
            {class="dropdown",name="ht",items=hd_items,value=p.ht,hint=L("hint_utility"),x=4,y=19,width=20,height=1},
        }
        local buttons={L("btn_execute"),L("btn_kpp"),L("btn_lazy"),L("btn_extract_kf"),L("btn_config"),L("btn_help"),L("btn_cancel")}
        local b,r=aegisub.dialog.display(d,buttons)
        if b==L("btn_cancel") or not b then return end 
        p=r
        if b==L("btn_help") then
            aegisub.dialog.display({{class="textbox",text=getHelpText(),x=0,y=0,width=60,height=30}},{L("btn_ok")})
        elseif b==L("btn_kpp") then 
            local tsel_kpp=getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
            if #tsel_kpp==0 then
                showMsg(L("err_filter_zero"))
                goto continue
            else
                kpp_main(subs, tsel_kpp)
                aegisub.set_undo_point("Chronorow Master - KPP")
                return sel
            end
        elseif b==L("btn_lazy") then 
            lazyTimer(subs, sel)
            aegisub.set_undo_point("Chronorow Master - LazyTimer")
            return sel
        elseif b==L("btn_extract_kf") then 
            runScxvid()
            return sel
        elseif b==L("btn_config") then 
            showConfigDialog()
            goto continue
        elseif b==L("btn_execute") then
            if r.ht ~= "" then
                local tsel_tool=getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
                if #tsel_tool==0 then 
                    aegisub.dialog.display({{class="label",label=L("err_filter_zero")}},{L("btn_ok")}) 
                    goto continue
                end
                if r.ht==L("tool_blank") then blank_eraser(subs,tsel_tool) 
                elseif r.ht==L("tool_join") then join_same_text(subs,tsel_tool) 
                elseif r.ht==L("tool_time") then 
                    local new_sel = time_picker(subs,tsel_tool)
                    aegisub.set_undo_point("Chronorow Master - "..r.ht)
                    return new_sel
                elseif r.ht==L("tool_style") then style_sentinel(subs,tsel_tool) 
                elseif r.ht==L("tool_caption") then caption_clarifier(subs,tsel_tool) 
                elseif r.ht==L("tool_leblanc") then leblanc_six(subs,tsel_tool) 
                elseif r.ht==L("tool_copyt") then hd_copy_times(subs,tsel_tool) 
                elseif r.ht==L("tool_extt") then hd_extract_tags(subs,tsel_tool) 
                elseif r.ht==L("tool_inst") then hd_reinsert_tags(subs,tsel_tool) 
                elseif r.ht==L("tool_sort") then hd_sort_by_length(subs,tsel_tool) 
                elseif r.ht==L("tool_p_ex") then hd_punct_exclamation(subs,tsel_tool) 
                elseif r.ht==L("tool_p_qu") then hd_punct_question(subs,tsel_tool) 
                elseif r.ht==L("tool_p_both") then hd_punct_both(subs,tsel_tool) 
                elseif r.ht==L("tool_swap") then hd_swap_comment(subs,tsel_tool) 
                elseif r.ht==L("tool_an8") then hd_add_an8(subs,tsel_tool)
                elseif r.ht==L("tool_fold") then 
                    local new_sel = fold_copy(subs,tsel_tool)
                    aegisub.set_undo_point("Chronorow Master - Copy Fold")
                    return new_sel or sel
                elseif r.ht==L("tool_dital") then double_italics(subs,tsel_tool)
                elseif r.ht==L("tool_fte") then hd_frame_to_effect(subs,tsel_tool)
                elseif r.ht==L("tool_transplant") then hd_time_transplant(subs,tsel_tool)
                elseif r.ht==L("tool_ellipsis") then hd_ellipsis_eraser(subs,tsel_tool)
                elseif r.ht==L("tool_dramaturgy") then hd_dramaturgy_plus(subs,tsel_tool)
                elseif r.ht==L("tool_motion") then hd_extract_motion(subs,tsel_tool)
                elseif r.ht==L("tool_stutter") then hd_add_stutter(subs,tsel_tool)
                elseif r.ht==L("tool_actor_rep") then hd_actor_replace(subs,tsel_tool)
                elseif r.ht==L("tool_kitetiming") then kite_timing(subs,tsel_tool)
                elseif r.ht==L("tool_remplacer") then hd_text_replacer(subs,tsel_tool)
                end
                aegisub.set_undo_point("Chronorow Master - "..r.ht) 
                return
            end
            if r.comment_purge and r.comment_purge ~= "" then
                local act = r.comment_purge
                if act == L("dd_cp_delete") then
                    local tsel_cp = getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
                    if #tsel_cp == 0 then
                        aegisub.dialog.display({{class="label",label=L("err_filter_zero")}},{L("btn_ok")})
                        goto continue
                    end
                    table.sort(tsel_cp, function(a, b) return a > b end)
                    local del_cnt = 0
                    for _, idx in ipairs(tsel_cp) do
                        if subs[idx].comment then subs.delete(idx) del_cnt=del_cnt+1 end
                    end
                    showMsg(string.format("Deleted %d comments", del_cnt))
                elseif act == L("dd_cp_start") or act == L("dd_cp_end") then
                     local tsel_cp = getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
                    if #tsel_cp == 0 then
                        showMsg(L("err_filter_zero"))
                        goto continue
                    end
                    table.sort(tsel_cp) 
                    local commented = {}
                    local non_commented = {}
                    for _, idx in ipairs(tsel_cp) do
                        local line = subs[idx]
                        if line.comment then table.insert(commented, line) else table.insert(non_commented, line) end
                    end
                    local new_order = {}
                    if act == L("dd_cp_start") then
                        for i = 1, #commented do table.insert(new_order, commented[i]) end
                        for i = 1, #non_commented do table.insert(new_order, non_commented[i]) end
                    else
                        for i = 1, #non_commented do table.insert(new_order, non_commented[i]) end
                        for i = 1, #commented do table.insert(new_order, commented[i]) end
                    end
                    for i, idx in ipairs(tsel_cp) do subs[idx] = new_order[i] end
                end
                aegisub.set_undo_point("Comment Purge")
                return
            end
            if r.kite_audit and r.kite_audit ~= "" then
                local ka = r.kite_audit
                if ka == "Ends Only" then
                    r.twin, r.miss, r.ov, r.mode = 1000, 1000, 0, L("dd_end_only")
                elseif ka == "Start Only" then
                    r.twin, r.miss, r.ov, r.mode = 300, 300, 0, L("dd_start_only")
                elseif ka == "Both" then
                    local ka_tsel = getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
                    if #ka_tsel > 0 then
                        tagTiming(subs,ka_tsel,{kf=r.kf,twin=300,miss=300,ov=0,mode=L("dd_start_only")})
                    end
                    r.twin, r.miss, r.ov, r.mode = 1000, 1000, 0, L("dd_end_only")
                elseif ka == "Overtime" then
                    r.twin, r.miss = 0, 0
                end
            end
            local twin_val = tonumber(r.twin)
            local miss_val = tonumber(r.miss)
            local ov_val = tonumber(r.ov)
            if not twin_val or twin_val < 0 then
                showMsg(L("err_invalid_twin"))
                goto continue
            end
            if not miss_val or miss_val < 0 then
                showMsg(L("err_invalid_miss"))
                goto continue
            end
            if not ov_val or ov_val < 0 then
                showMsg(L("err_invalid_ov"))
                goto continue
            end
            local tsel=getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
            if #tsel==0 then 
                showMsg(L("err_filter_zero")) 
                goto continue
            end
            if r.sent and r.splitN then
                showMsg(L("err_avoid_combo"))
                goto continue
            end
            aegisub.progress.task("Processing...")
            if r.preview then sentenceTool(subs,tsel,{comma=r.comma,preview=true}) 
            elseif r.sent then sentenceTool(subs,tsel,{comma=r.comma,preview=false}) end
            if r.splitN then splitByN(subs,tsel) end
            if r.romaji then romajiKara(subs,tsel) end
            if r.cps then sortByCPS(subs,tsel) end
            if r.kf or tonumber(r.twin)>0 or tonumber(r.miss)>0 or tonumber(r.ov)>0 then 
                tagTiming(subs,tsel,{kf=r.kf,twin=tonumber(r.twin)or 0,miss=tonumber(r.miss)or 0,ov=tonumber(r.ov)or 0,mode=r.mode}) 
            end
            if r.ovl then tagOverlaps(subs,tsel) end
            if r.gap then 
                markSmallGaps(subs,tsel,{
                    maxGap=tonumber(current_config.gap_max_gap) or 300,
                    ignoreKeyframes=current_config.gap_ignore_keyframes,
                    markContinuous=current_config.gap_mark_continuous,
                    gapTag=current_config.gap_tag
                })
            end
            if r.upp then markUppercase(subs,tsel) end
            if r.punct then markMissingPunctuation(subs,tsel) end
            if r.mr~="" then 
                if r.mm==L("dd_ant_effects") then antEffects(subs,tsel,r.mr) 
                elseif r.mm==L("dd_ant_lines") then antLines(subs,tsel,r.mr,r.mc) 
                elseif r.mm==L("dd_ant_actor") then antActor(subs,tsel,r.mr) 
                elseif r.mm==L("dd_ant_songs") then antSongs(subs,tsel,r.mr)
                elseif r.mm==L("dd_ant_twins") then antTwins(subs,tsel,r.mr,r.mc)
                end 
            end
            if r.avg then showAvgCPS(subs,tsel) end
            aegisub.set_undo_point("Chronorow Master - Executed") 
            return
        end
        ::continue::
    end
end
aegisub.register_macro(menu_embedding..script_name,script_description,row_master_gui)
aegisub.register_macro(menu_embedding.."Utility/Extract Tags","Extract Tags",hd_extract_tags)
aegisub.register_macro(menu_embedding.."Utility/Reinsert Tags","Reinsert Tags",hd_reinsert_tags)
aegisub.register_macro(menu_embedding.."Utility/Kite Timing (Lead-in-out + KF Snap)","Lead-in/out with keyframe snap and chaining",kite_timing)
aegisub.register_macro(menu_embedding.."Utility/Copy Times","Copy Times",hd_copy_times)
aegisub.register_macro(menu_embedding.."Utility/Swap Comment","Swap Comment",hd_swap_comment)
aegisub.register_macro(menu_embedding.."Utility/Blank Eraser","Delete empty",blank_eraser)
aegisub.register_macro(menu_embedding.."Utility/Join Same Text","Join Identical",join_same_text)
aegisub.register_macro(menu_embedding.."Utility/Time Picker","Select range",function(s,sel) return time_picker(s,sel) end)
aegisub.register_macro(menu_embedding.."Utility/Style Sentinel","Filter Styles",style_sentinel)
aegisub.register_macro(menu_embedding.."Utility/Caption Clarifier","Remove brackets",caption_clarifier)
aegisub.register_macro(menu_embedding.."Utility/LeBlanc Six","Auto Break",leblanc_six)
aegisub.register_macro(menu_embedding.."Utility/Sort by Length","Sort length",hd_sort_by_length)
aegisub.register_macro(menu_embedding.."Utility/Mark Uppercase","Mark Uppercase",markUppercase)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Exclamation","¡!",hd_punct_exclamation)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Question","¿?",hd_punct_question)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Both","¡¿?!",hd_punct_both)
aegisub.register_macro(menu_embedding.."Utility/Add an8","Add top alignment",hd_add_an8)
aegisub.register_macro(menu_embedding.."Utility/Copy Fold Group","Copy fold to clipboard",function(s,sel) return fold_copy(s,sel) end)
aegisub.register_macro(menu_embedding.."Utility/Double Italics","Mark broken italics [CurE]",double_italics)
aegisub.register_macro(menu_embedding.."Utility/Frame to Effect","Put current frame number in Effects field",hd_frame_to_effect)
aegisub.register_macro(menu_embedding.."Utility/Import Text (Source Timing)","Import lines keeping selection's timing",hd_time_transplant)
aegisub.register_macro(menu_embedding.."Utility/Ellipsis Eraser (Clean ...)","Remove leading ellipsis/dots",hd_ellipsis_eraser)
aegisub.register_macro(menu_embedding.."Utility/Actor Parser (Split & Format)","Format actors, thoughts, and split lines",hd_dramaturgy_plus)
aegisub.register_macro(menu_embedding.."Utility/AE Keyframe Export (Full Data)","Export full motion data for AE",hd_extract_motion)
aegisub.register_macro(menu_embedding.."Utility/Stutter Generator (L-Lword)","Add stutter with punctuation support",hd_add_stutter)
aegisub.register_macro(menu_embedding.."Utility/Actor Manager (Rename-Merge)","Find, replace, and merge actors",hd_actor_replace)
aegisub.register_macro(menu_embedding.."Utility/Remplacer (Text Replacer)","Bulk replace visible text",hd_text_replacer)
