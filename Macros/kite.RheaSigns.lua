script_name        = "Rhea Signs"
script_description = "Typesetting and sign operations suite"
script_author      = "Kiterow"
script_version     = "1.0.0"
script_namespace   = "kite.RheaSigns"

include("karaskel.lua")


local DependencyControl = require("l0.DependencyControl")
local depRec = DependencyControl{
    feed        = "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
    {
        { "l0.ASSFoundation", version = "0.5.0",
          url  = "https://github.com/TypesettingTools/ASSFoundation",
          feed = "https://raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json" },
        { "l0.Functional",   version = "0.6.0",
          url  = "https://github.com/TypesettingTools/Functional",
          feed = "https://raw.githubusercontent.com/TypesettingTools/Functional/master/DependencyControl.json" },
        { "arch.Perspective", version = "1.0.0",
          url  = "https://github.com/arch1t3cht/Aegisub-Scripts",
          feed = "https://raw.githubusercontent.com/arch1t3cht/Aegisub-Scripts/main/DependencyControl.json" },
        { "arch.Util", version = "0.1.0",
          url  = "https://github.com/arch1t3cht/Aegisub-Scripts",
          feed = "https://raw.githubusercontent.com/arch1t3cht/Aegisub-Scripts/main/DependencyControl.json" },
        { "a-mo.LineCollection", version = "1.3.0",
          url  = "https://github.com/TypesettingTools/Aegisub-Motion",
          feed = "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json" },
        { "a-mo.Line", version = "1.5.3",
          url  = "https://github.com/TypesettingTools/Aegisub-Motion",
          feed = "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json" },
        { "a-mo.ConfigHandler", version = "1.1.4",
          url  = "https://github.com/TypesettingTools/Aegisub-Motion",
          feed = "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json" },
    },
}
local ASS, Functional, ArchPersp, ArchUtil, LineCollection, AMLine, ConfigHandler = depRec:requireModules()

local FunctionalString  = Functional.string
local FunctionalMath    = Functional.math
local FunctionalList    = Functional.list
local FunctionalTable   = Functional.table
local FunctionalUnicode = Functional.unicode
local FunctionalUtil    = Functional.util

local unicode = require("aegisub.unicode")


local LANG = {
    en = {
        title_perspectiva = "PERSPECTIVE",
        title_signlayout = "SIGN",
        title_masks = "MASKS",
        title_transforms = "TRANSFORMS",
        title_colorbar = "COLOR KEYS",
        lbl_color = "Color:",
        lbl_fx = "FX:",
        lbl_fx_c1 = "FX 1:",
        lbl_fx_c2 = "FX 2:",
        lbl_language = "Language:",
        lbl_action = "Action:",
        lbl_align = "Align:",
        lbl_mode = "Mode:",
        lbl_map = "Map:",
        lbl_org = "Org:",
        lbl_rescale = "Rescale:",
        lbl_preset = "Preset:",
        lbl_shape = "Shape:",
        lbl_steps = "Steps:",
        lbl_delay = "Delay:",
        lbl_time = "Time:",
        lbl_step = "Step:",
        lbl_amount = "Amount:",
        lbl_quad = "Quad%:",
        lbl_sign = "Sign:",
        lbl_type = "Type:",
        lbl_rot = "Rot:",
        lbl_radius = "Radius:",
        lbl_track = "Track:",
        lbl_mask = "Mask:",
        lbl_source = "Source:",
        lbl_tag = "Tag:",
        lbl_stops = "Stops:",
        btn_execute = "EXECUTE",
        btn_mass_signs = "Signs Editor",
        btn_fastsigns = "FastSigns",
        btn_tagops = "TagOps",
        btn_config = "Config",
        btn_help = "Help",
        btn_save = "Save",
        btn_cancel = "Cancel",
        btn_continue = "Continue",
        btn_ok = "OK",
        err_no_selection = "No selection.",
        hint_picker = "Empty dropdown = skip.",
        lbl_initial = "Initial",
        lbl_final = "Final",
        lbl_kf = "KF",
        lbl_name = "Name",
        lbl_x = "x",
        lbl_y = "y",
        lbl_accel = "Accel",
        lbl_strip = "Strip",
        lbl_char = "Char",
        lbl_layer = "Layer",
        lbl_inv = "Inv",
        lbl_del = "Del",
        lbl_replace = "Replace",
        lbl_alpha = "Alpha",
        lbl_center = "Center",
        lbl_text = "Text",
        lbl_border = "Border",
        lbl_shadow = "Shadow",
        lbl_blur = "Blur",
        lbl_box = "Box",
        lbl_glow = "Glow",
        lbl_fade = "Fade",
        lbl_pad_x = "Pad X",
        lbl_pad_y = "Pad Y",
        lbl_top = "Top",
        lbl_gap = "Gap",
        lbl_max_width = "Max %",
        lbl_box_blur = "Box blur",
        lbl_glow_border = "Glow b",
        lbl_glow_blur = "Glow blur",
        lbl_text_blur = "Text blur",
        lbl_drop_p = "Drop P",
        lbl_drop_r = "Drop R",
        tagops_title = "TAG OPS",
        tagops_replace = "Replace matching tags",
        tagops_read_all = "Read all source blocks",
        tagops_append = "Append inside first block",
        tagops_show_result = "Show result",
        tagops_err_measure_select = "Select at least one line with a vector clip.",
        tagops_err_copy_select = "Select at least two dialogue lines. Same Effect copies within each group; otherwise the first selected line is the source.",
        tagops_err_select_tag = "Select at least one tag.",
        tagops_err_source_tag = "The source line does not contain any selected tag.",
        tagops_err_adjust_select = "Select at least one line.",
        tagops_err_numeric = "Value must be numeric.",
        tagops_err_no_adjust_tags = "No adjustable numeric tags or style values found.",
        tagops_err_transition = "In-Out needs exactly two selected dialogue lines.",
        tagops_choose_text = "The two lines have different text. Which text should be kept?",
        tagops_use_line1 = "Use line 1",
        tagops_use_line2 = "Use line 2",
        tagops_transition_done = "Tag Ops created one In-Out line.",
        tagops_no_clip = "no clip",
        tagops_bad_clip = "clip is not a vector path",
        tagops_few_segments = "needs at least two m-l segments",
        tagops_zero_segment = "first segment distance is zero",
        tagops_line = "Line",
        tagops_first = "First",
        tagops_second = "Second",
        tagops_change = "Change",
        tagops_skipped = "Skipped",
        tagops_copied = "Copied",
        tagops_targets = "Targets changed",
        tagops_lines_changed = "Lines changed",
        tagops_tags_changed = "Tags changed",
    },
    es = {
        title_perspectiva = "PERSPECTIVA",
        title_signlayout = "CARTEL",
        title_masks = "MASCARAS",
        title_transforms = "TRANSFORMACIONES",
        title_colorbar = "CLAVES DE COLOR",
        lbl_color = "Color:",
        lbl_fx = "FX:",
        lbl_fx_c1 = "FX 1:",
        lbl_fx_c2 = "FX 2:",
        lbl_language = "Idioma:",
        lbl_action = "Accion:",
        lbl_align = "Alinear:",
        lbl_mode = "Modo:",
        lbl_map = "Mapa:",
        lbl_org = "Org:",
        lbl_rescale = "Reescalar:",
        lbl_preset = "Preset:",
        lbl_shape = "Forma:",
        lbl_steps = "Pasos:",
        lbl_delay = "Retardo:",
        lbl_time = "Tiempo:",
        lbl_step = "Paso:",
        lbl_amount = "Cantidad:",
        lbl_quad = "Quad%:",
        lbl_sign = "Cartel:",
        lbl_type = "Tipo:",
        lbl_rot = "Rot:",
        lbl_radius = "Radio:",
        lbl_track = "Track:",
        lbl_mask = "Mascara:",
        lbl_source = "Fuente:",
        lbl_tag = "Tag:",
        lbl_stops = "Pasos:",
        btn_execute = "EJECUTAR",
        btn_mass_signs = "Editor de carteles",
        btn_fastsigns = "FastSigns",
        btn_tagops = "TagOps",
        btn_config = "Config",
        btn_help = "Ayuda",
        btn_save = "Guardar",
        btn_cancel = "Cancelar",
        btn_continue = "Continuar",
        btn_ok = "OK",
        err_no_selection = "Sin seleccion.",
        hint_picker = "Dropdown vacio = omitir.",
        lbl_initial = "Inicial",
        lbl_final = "Final",
        lbl_kf = "KF",
        lbl_name = "Nombre",
        lbl_x = "x",
        lbl_y = "y",
        lbl_accel = "Accel",
        lbl_strip = "Quitar",
        lbl_char = "Caracter",
        lbl_layer = "Capa",
        lbl_inv = "Inv",
        lbl_del = "Borrar",
        lbl_replace = "Reemplazar",
        lbl_alpha = "Alfa",
        lbl_center = "Centro",
        lbl_text = "Texto",
        lbl_border = "Borde",
        lbl_shadow = "Sombra",
        lbl_blur = "Blur",
        lbl_box = "Caja",
        lbl_glow = "Brillo",
        lbl_fade = "Fade",
        lbl_pad_x = "Pad X",
        lbl_pad_y = "Pad Y",
        lbl_top = "Arriba",
        lbl_gap = "Espacio",
        lbl_max_width = "Max %",
        lbl_box_blur = "Blur caja",
        lbl_glow_border = "Borde glow",
        lbl_glow_blur = "Blur glow",
        lbl_text_blur = "Blur texto",
        lbl_drop_p = "Quitar P",
        lbl_drop_r = "Quitar R",
        tagops_title = "TAG OPS",
        tagops_replace = "Reemplazar tags iguales",
        tagops_read_all = "Leer todos los bloques",
        tagops_append = "Anexar en primer bloque",
        tagops_show_result = "Mostrar resultado",
        tagops_err_measure_select = "Selecciona al menos una linea con clip vectorial.",
        tagops_err_copy_select = "Selecciona al menos dos lineas de dialogo. Mismo Effect copia dentro de cada grupo; si no, la primera seleccionada es la fuente.",
        tagops_err_select_tag = "Selecciona al menos un tag.",
        tagops_err_source_tag = "La linea fuente no contiene ningun tag seleccionado.",
        tagops_err_adjust_select = "Selecciona al menos una linea.",
        tagops_err_numeric = "El valor debe ser numerico.",
        tagops_err_no_adjust_tags = "No se encontraron tags numericos ni valores de estilo ajustables.",
        tagops_err_transition = "In-Out necesita exactamente dos lineas de dialogo seleccionadas.",
        tagops_choose_text = "Las dos lineas tienen texto distinto. Cual texto se debe conservar?",
        tagops_use_line1 = "Usar linea 1",
        tagops_use_line2 = "Usar linea 2",
        tagops_transition_done = "Tag Ops creo una linea In-Out.",
        tagops_no_clip = "sin clip",
        tagops_bad_clip = "el clip no es vectorial",
        tagops_few_segments = "necesita al menos dos segmentos m-l",
        tagops_zero_segment = "la primera distancia es cero",
        tagops_line = "Linea",
        tagops_first = "Primera",
        tagops_second = "Segunda",
        tagops_change = "Cambio",
        tagops_skipped = "Omitidas",
        tagops_copied = "Copiados",
        tagops_targets = "Destinos cambiados",
        tagops_lines_changed = "Lineas cambiadas",
        tagops_tags_changed = "Tags cambiados",
    },
    pt = {
        title_perspectiva = "PERSPECTIVA",
        title_signlayout = "PLACA",
        title_masks = "MASCARAS",
        title_transforms = "TRANSFORMACOES",
        title_colorbar = "CHAVES DE COR",
        lbl_color = "Cor:",
        lbl_fx = "FX:",
        lbl_fx_c1 = "FX 1:",
        lbl_fx_c2 = "FX 2:",
        lbl_language = "Idioma:",
        lbl_action = "Acao:",
        lbl_align = "Alinhar:",
        lbl_mode = "Modo:",
        lbl_map = "Mapa:",
        lbl_org = "Org:",
        lbl_rescale = "Redim.:",
        lbl_preset = "Preset:",
        lbl_shape = "Forma:",
        lbl_steps = "Passos:",
        lbl_delay = "Atraso:",
        lbl_time = "Tempo:",
        lbl_step = "Passo:",
        lbl_amount = "Valor:",
        lbl_quad = "Quad%:",
        lbl_sign = "Placa:",
        lbl_type = "Tipo:",
        lbl_rot = "Rot:",
        lbl_radius = "Raio:",
        lbl_track = "Track:",
        lbl_mask = "Mascara:",
        lbl_source = "Fonte:",
        lbl_tag = "Tag:",
        lbl_stops = "Passos:",
        btn_execute = "EXECUTAR",
        btn_mass_signs = "Editor de placas",
        btn_fastsigns = "FastSigns",
        btn_tagops = "TagOps",
        btn_config = "Config",
        btn_help = "Ajuda",
        btn_save = "Salvar",
        btn_cancel = "Cancelar",
        btn_continue = "Continuar",
        btn_ok = "OK",
        err_no_selection = "Sem selecao.",
        hint_picker = "Dropdown vazio = ignorar.",
        lbl_initial = "Inicial",
        lbl_final = "Final",
        lbl_kf = "KF",
        lbl_name = "Nome",
        lbl_x = "x",
        lbl_y = "y",
        lbl_accel = "Accel",
        lbl_strip = "Remover",
        lbl_char = "Caractere",
        lbl_layer = "Camada",
        lbl_inv = "Inv",
        lbl_del = "Apagar",
        lbl_replace = "Substituir",
        lbl_alpha = "Alfa",
        lbl_center = "Centro",
        lbl_text = "Texto",
        lbl_border = "Borda",
        lbl_shadow = "Sombra",
        lbl_blur = "Blur",
        lbl_box = "Caixa",
        lbl_glow = "Brilho",
        lbl_fade = "Fade",
        lbl_pad_x = "Pad X",
        lbl_pad_y = "Pad Y",
        lbl_top = "Topo",
        lbl_gap = "Espaco",
        lbl_max_width = "Max %",
        lbl_box_blur = "Blur caixa",
        lbl_glow_border = "Borda glow",
        lbl_glow_blur = "Blur glow",
        lbl_text_blur = "Blur texto",
        lbl_drop_p = "Remover P",
        lbl_drop_r = "Remover R",
        tagops_title = "TAG OPS",
        tagops_replace = "Substituir tags iguais",
        tagops_read_all = "Ler todos os blocos",
        tagops_append = "Anexar no primeiro bloco",
        tagops_show_result = "Mostrar resultado",
        tagops_err_measure_select = "Selecione ao menos uma linha com clip vetorial.",
        tagops_err_copy_select = "Selecione ao menos duas linhas de dialogo. Mesmo Effect copia dentro de cada grupo; senao, a primeira selecionada e a fonte.",
        tagops_err_select_tag = "Selecione ao menos um tag.",
        tagops_err_source_tag = "A linha fonte nao contem nenhum tag selecionado.",
        tagops_err_adjust_select = "Selecione ao menos uma linha.",
        tagops_err_numeric = "O valor deve ser numerico.",
        tagops_err_no_adjust_tags = "Nenhum tag numerico ou valor de estilo ajustavel encontrado.",
        tagops_err_transition = "In-Out precisa de exatamente duas linhas de dialogo selecionadas.",
        tagops_choose_text = "As duas linhas tem texto diferente. Qual texto deve ser mantido?",
        tagops_use_line1 = "Usar linha 1",
        tagops_use_line2 = "Usar linha 2",
        tagops_transition_done = "Tag Ops criou uma linha In-Out.",
        tagops_no_clip = "sem clip",
        tagops_bad_clip = "o clip nao e vetorial",
        tagops_few_segments = "precisa de ao menos dois segmentos m-l",
        tagops_zero_segment = "a primeira distancia e zero",
        tagops_line = "Linha",
        tagops_first = "Primeira",
        tagops_second = "Segunda",
        tagops_change = "Mudanca",
        tagops_skipped = "Ignoradas",
        tagops_copied = "Copiados",
        tagops_targets = "Destinos alterados",
        tagops_lines_changed = "Linhas alteradas",
        tagops_tags_changed = "Tags alterados",
    },
}
local EXTRA_LANG = {
    en = {
        lang_en = "English", lang_es = "Spanish", lang_pt = "Portuguese",
        btn_delete = "Delete", btn_apply = "Apply", btn_copy_tags = "Copy Tags", btn_keep_only = "Keep Only",
        op_apply_chain = "Apply chain", op_apply_mask = "Apply mask", op_create_layer = "Create layer",
        op_replace_mask = "Replace mask", op_save_shape = "Save shape", op_delete_shape = "Delete shape", op_clean_dr = "Clean DR",
        op_typewriter = "Typewriter", op_vertical_drop = "Vertical drop", op_circle_text = "Circle text", op_curve_text = "Curve text",
        op_align_clip = "Align to clip", op_clean_sio = "Clean SiO", op_borders = "Borders", op_preset = "Preset",
        op_clean_cal = "Clean CAL", choice_frame = "Frame", choice_duration = "Duration", choice_normal = "Normal",
        choice_inverted = "Inverted", choice_vertical = "Vertical", choice_from_clip = "From clip",
        pk_copy_exact = "Copy exact (same plane)", pk_copy_static = "Copy static plane (keep \\pos)", pk_copy_move_plane = "Copy move plane (whole plane)",
        pk_copy_swap = "Copy with corner swap", pk_copy_translate = "Copy translate (keep \\pos)", pk_copy_transport = "Copy transport (\\org -> \\pos)",
        pk_mass_fsc = "Mass FSC (lock quad)", pk_scale_quad = "Scale quad (3D box)", pk_clip_persp = "Clip to perspective",
        pk_rescale_clip = "Rescale to clip", pk_bake_extra = "Bake extradata", pk_restore_extra = "Restore extradata",
        pk_identity = "Identity reproject", map_abcd = "ABCD (exact copy)", map_badc = "BADC (horizontal mirror)",
        map_dcba = "DCBA (vertical mirror)", map_cdab = "CDAB (rotate 180)", map_bcda = "BCDA (rotate 90 CW)",
        map_dabc = "DABC (rotate 90 CCW)", map_abdc = "ABDC (swap CD)", map_bacd = "BACD (swap AB)",
        map_ab_cd = "AB source + CD target", map_cd_ab = "CD source + AB target", map_ac_bd = "AC source + BD target",
        map_bd_ac = "BD source + AC target", org_keep = "Keep target org", org_center = "Quad center", org_min_fax = "Minimize fax",
        res_fit = "Fit (uniform)", res_fill = "Fill (uniform)", res_stretch = "Stretch (per-axis)",
        shape_once = "Once (one-way)", shape_round = "Out and back", shape_yoyo = "Yoyo (N cycles)",
        shape_pulse = "Pulse (ms)", shape_steps = "Steps (N)", shape_custom = "Custom keyframes",
        delay_none = "No delay", delay_ms = "ms from start", delay_frame = "Current frame", delay_percent = "Percent (%)",
        fx_blur_in = "Blur in", fx_blur_out = "Blur out", fx_fade_in = "Fade in", fx_fade_out = "Fade out",
        fx_scale_up = "Scale up", fx_scale_down = "Scale down", fx_pop_in = "Pop in", fx_pop_out = "Pop out",
        fx_color_flash = "Color flash", fx_color_pulse = "Color pulse", fx_to_color = "To color (frame)",
        fx_to_style = "To style (frame)", fx_border_pulse = "Border pulse", fx_glow_pulse = "Glow pulse",
        fx_shake_v = "Shake V", fx_shake_h = "Shake H", fx_shake_xy = "Shake XY", fx_wobble = "Wobble (frz)",
        fx_glitch = "Glitch", fx_dramatic_pulse = "Dramatic pulse", fx_flashback = "Flashback (fad)", fx_split_line = "Split line",
        fx_split_line_fad = "Split line fad", fx_split_title = "Split title",
        cal_decompose = "Decompose (fill + border)", cal_blur_glow = "Blur + glow", cal_shadtrick = "Shadtrick (shadow layer)",
        cal_double_border = "Double border blur", cal_clean_layers = "Clean layers (flatten)",
        tagops_measure = "Measure & Transform Clip", tagops_adjust = "Adjust tags", tagops_clip_scale_adjust = "Adjust by Clip Scale",
        tagops_copy_no_change = "Copy Tags: no target lines changed.",
        tagops_adjust_no_change = "Adjust tags: no values changed.",
        tagops_keep_only_changed = "Keep Only changed %d line(s).",
        tagops_keep_only_no_change = "Keep Only: no tags were removed.",
        tagops_transition = "In-Out tags", tagops_pos_align = "Pos align", tagops_add = "Add", tagops_percent = "Percent",
        tagops_keep_org = "Keep org (pos only)", tagops_move_org = "Move org",
        tagops_axis = "Axis", tagops_angle = "FRZ angle", tagops_clip_hotkey = "Clip hotkey",
        tagops_angle_transform = "Transform angle", tagops_angle_first = "First angle",
        tagops_clip_cal_x = "Calibrate clip X", tagops_clip_cal_y = "Calibrate clip Y",
        tagops_clip_rect = "Rectangle from diagonal", tagops_clip_toggle = "Toggle clip/iclip",
        tagops_clip_copy = "Copy clip/iclip",
        tagops_no_clip_changed = "No editable clip found.",
        tagops_clip_changed = "Clip lines changed: %d",
        tagops_clip_transform_done = "Clip transforms: %d",
        tagops_err_align_select = "Select at least two dialogue lines. The first selected line is the source and the second is the reference.",
        tagops_err_source_pos = "The first selected line has no \\pos.",
        tagops_err_reference_pos = "The second selected line has no \\pos.",
        tagops_align_no_delta = "The first and second selected lines have no usable \\pos or \\org delta.",
        tagops_align_done = "Pos Align moved %d lines.",
        msg_layout_mismatch_layout = "LayoutResY (%s) does not match PlayResY (%s).",
        msg_layout_mismatch_play = "PlayResY (%s) does not match the video height (%s).",
        msg_layout_depth_scale = "Perspective will use depth scale %.4f. If the script or video resolution is wrong, the generated plane can appear outside the clip.",
        msg_layout_recommended = "Recommended: resample the script or set LayoutResY/PlayResY to match before applying.",
        msg_continue_anyway = "Continue anyway?",
        msg_need_two_copy_lines = "Select >=2 lines. Same Effect = group; empty Effect = one group; otherwise first line copies to all.",
        msg_no_video = "No video loaded.",
        msg_frame_time_unresolved = "Unable to resolve frame time.",
        msg_line_duration_zero = "Line %d: duration 0",
        msg_frame_unavailable = "Frame unavailable.",
        msg_frame_out_of_range = "Frame %dms out of range (%d-%d).",
        msg_line_frame_out_of_range = "Line %d: frame out of range (%d-%d)",
        msg_style_not_found = "style not found",
        msg_missing_pipe = "missing | marker",
        msg_marker_error = "marker error",
        msg_delete_dr_marked = "Delete %d DR-marked lines?",
        msg_no_dr_marked = "No DR-marked lines found.",
        msg_no_dr_marked_selection = "No DR-marked lines in selection.",
        msg_no_vector_curve = "No vector clip found in selection for curve.",
        msg_no_vector_align = "No vector clip found in selection for align.",
        msg_no_usable_path_align = "Vector clip has no usable path for align.",
        msg_no_cal_marked = "No CAL-marked lines found.",
        msg_delete_cal_marked = "Delete %d CAL-marked lines?",
        signs_editor_title = "== SIGNS EDITOR ==",
        signs_skip_vec = "Skip vector drawings (\\p1)",
        signs_auto_gbc = "Auto-detect and regenerate GBC gradients",
        signs_use_cap = "Apply character limit",
        signs_no_editable = "No editable lines found in selection.",
        signs_original = "ORIGINAL (read-only)",
        signs_modified = "MODIFIED (edit here)",
        signs_regen_gbc = "Regenerate GBC gradients on modified lines",
        signs_info = "%d unique texts, %d total lines. %d GBC detected.",
        signs_skipped_vectors = " Skipped %d vectors.",
        signs_skipped_over_limit = " Skipped %d over limit.",
        signs_line_mismatch = "Line count mismatch: expected %d, got %d.\nNo changes applied.",
    },
    es = {
        lang_en = "Ingles", lang_es = "Espanol", lang_pt = "Portugues",
        btn_delete = "Borrar", btn_apply = "Aplicar", btn_copy_tags = "Copiar tags", btn_keep_only = "Keep Only",
        op_apply_chain = "Aplicar cadena", op_apply_mask = "Aplicar mascara", op_create_layer = "Crear capa",
        op_replace_mask = "Reemplazar mascara", op_save_shape = "Guardar forma", op_delete_shape = "Borrar forma", op_clean_dr = "Limpiar DR",
        op_typewriter = "Maquina de escribir", op_vertical_drop = "Caida vertical", op_circle_text = "Texto circular", op_curve_text = "Texto en curva",
        op_align_clip = "Alinear a clip", op_clean_sio = "Limpiar SiO", op_borders = "Bordes", op_preset = "Preset",
        op_clean_cal = "Limpiar CAL", choice_frame = "Frame", choice_duration = "Duracion", choice_normal = "Normal",
        choice_inverted = "Invertido", choice_vertical = "Vertical", choice_from_clip = "Desde clip",
        pk_copy_exact = "Copiar exacto (mismo plano)", pk_copy_static = "Copiar plano estatico (mantener \\pos)", pk_copy_move_plane = "Copiar plano con \\move",
        pk_copy_swap = "Copiar intercambiando esquinas", pk_copy_translate = "Copiar traslacion (mantener \\pos)", pk_copy_transport = "Transportar copia (\\org -> \\pos)",
        pk_mass_fsc = "FSC masivo (bloquear quad)", pk_scale_quad = "Escalar quad (caja 3D)", pk_clip_persp = "Clip a perspectiva",
        pk_rescale_clip = "Reescalar a clip", pk_bake_extra = "Guardar extradata", pk_restore_extra = "Restaurar extradata",
        pk_identity = "Reproyectar identidad", map_abcd = "ABCD (copia exacta)", map_badc = "BADC (espejo horizontal)",
        map_dcba = "DCBA (espejo vertical)", map_cdab = "CDAB (rotar 180)", map_bcda = "BCDA (rotar 90 horario)",
        map_dabc = "DABC (rotar 90 antihorario)", map_abdc = "ABDC (intercambiar CD)", map_bacd = "BACD (intercambiar AB)",
        map_ab_cd = "AB fuente + CD destino", map_cd_ab = "CD fuente + AB destino", map_ac_bd = "AC fuente + BD destino",
        map_bd_ac = "BD fuente + AC destino", org_keep = "Mantener org destino", org_center = "Centro del quad", org_min_fax = "Minimizar fax",
        res_fit = "Encajar (uniforme)", res_fill = "Rellenar (uniforme)", res_stretch = "Estirar (por eje)",
        shape_once = "Una vez (ida)", shape_round = "Ida y vuelta", shape_yoyo = "Yoyo (N ciclos)",
        shape_pulse = "Pulso (ms)", shape_steps = "Pasos (N)", shape_custom = "Keyframes personalizados",
        delay_none = "Sin retardo", delay_ms = "ms desde inicio", delay_frame = "Frame actual", delay_percent = "Porcentaje (%)",
        fx_blur_in = "Blur entrada", fx_blur_out = "Blur salida", fx_fade_in = "Fade entrada", fx_fade_out = "Fade salida",
        fx_scale_up = "Escalar arriba", fx_scale_down = "Escalar abajo", fx_pop_in = "Pop entrada", fx_pop_out = "Pop salida",
        fx_color_flash = "Flash de color", fx_color_pulse = "Pulso de color", fx_to_color = "A color (frame)",
        fx_to_style = "A estilo (frame)", fx_border_pulse = "Pulso de borde", fx_glow_pulse = "Pulso de brillo",
        fx_shake_v = "Sacudir V", fx_shake_h = "Sacudir H", fx_shake_xy = "Sacudir XY", fx_wobble = "Tambaleo (frz)",
        fx_glitch = "Glitch", fx_dramatic_pulse = "Pulso dramatico", fx_flashback = "Flashback (fad)", fx_split_line = "Dividir linea",
        fx_split_line_fad = "Dividir linea con fad", fx_split_title = "Dividir titulo",
        cal_decompose = "Descomponer (relleno + borde)", cal_blur_glow = "Blur + brillo", cal_shadtrick = "Truco de sombra (capa sombra)",
        cal_double_border = "Doble borde blur", cal_clean_layers = "Limpiar capas (aplanar)",
        tagops_measure = "Medir y transformar clip", tagops_adjust = "Ajustar tags", tagops_clip_scale_adjust = "Ajustar por escala de clip",
        tagops_copy_no_change = "Copiar tags: no cambio ninguna linea destino.",
        tagops_adjust_no_change = "Ajustar tags: no cambio ningun valor.",
        tagops_keep_only_changed = "Keep Only cambio %d linea(s).",
        tagops_keep_only_no_change = "Keep Only: no se quitaron tags.",
        tagops_transition = "Tags In-Out", tagops_pos_align = "Alinear pos", tagops_add = "Sumar", tagops_percent = "Porcentaje",
        tagops_keep_org = "Conservar org (solo pos)", tagops_move_org = "Mover org",
        tagops_axis = "Eje", tagops_angle = "Angulo FRZ", tagops_clip_hotkey = "Hotkey clip",
        tagops_angle_transform = "Transformar angulo", tagops_angle_first = "Primer angulo",
        tagops_clip_cal_x = "Calibrar clip X", tagops_clip_cal_y = "Calibrar clip Y",
        tagops_clip_rect = "Rectangulo desde diagonal", tagops_clip_toggle = "Alternar clip/iclip",
        tagops_clip_copy = "Copiar clip/iclip",
        tagops_no_clip_changed = "No se encontro clip editable.",
        tagops_clip_changed = "Lineas de clip cambiadas: %d",
        tagops_clip_transform_done = "Transformaciones de clip: %d",
        tagops_err_align_select = "Selecciona al menos dos lineas de dialogo. La primera seleccionada es la fuente y la segunda es la referencia.",
        tagops_err_source_pos = "La primera linea seleccionada no tiene \\pos.",
        tagops_err_reference_pos = "La segunda linea seleccionada no tiene \\pos.",
        tagops_align_no_delta = "La primera y segunda linea seleccionadas no tienen delta usable de \\pos ni de \\org.",
        tagops_align_done = "Pos Align movio %d lineas.",
        msg_layout_mismatch_layout = "LayoutResY (%s) no coincide con PlayResY (%s).",
        msg_layout_mismatch_play = "PlayResY (%s) no coincide con la altura del video (%s).",
        msg_layout_depth_scale = "Perspectiva usara escala de profundidad %.4f. Si la resolucion del script o del video esta mal, el plano generado puede quedar fuera del clip.",
        msg_layout_recommended = "Recomendado: remuestrea el script o ajusta LayoutResY/PlayResY para que coincidan antes de aplicar.",
        msg_continue_anyway = "Continuar de todos modos?",
        msg_need_two_copy_lines = "Selecciona >=2 lineas. Mismo Effect = grupo; Effect vacio = un grupo; si no, la primera copia a todas.",
        msg_no_video = "No hay video cargado.",
        msg_frame_time_unresolved = "No se pudo resolver el tiempo del frame.",
        msg_line_duration_zero = "Linea %d: duracion 0",
        msg_frame_unavailable = "Frame no disponible.",
        msg_frame_out_of_range = "Frame %dms fuera de rango (%d-%d).",
        msg_line_frame_out_of_range = "Linea %d: frame fuera de rango (%d-%d)",
        msg_style_not_found = "estilo no encontrado",
        msg_missing_pipe = "sin marcador |",
        msg_marker_error = "error con marcador",
        msg_delete_dr_marked = "Borrar %d lineas marcadas DR?",
        msg_no_dr_marked = "No se encontraron lineas marcadas DR.",
        msg_no_dr_marked_selection = "No hay lineas marcadas DR en la seleccion.",
        msg_no_vector_curve = "No se encontro clip vectorial en la seleccion para curva.",
        msg_no_vector_align = "No se encontro clip vectorial en la seleccion para alinear.",
        msg_no_usable_path_align = "El clip vectorial no tiene ruta usable para alinear.",
        msg_no_cal_marked = "No se encontraron lineas marcadas CAL.",
        msg_delete_cal_marked = "Borrar %d lineas marcadas CAL?",
        signs_editor_title = "== EDITOR DE CARTELES ==",
        signs_skip_vec = "Omitir dibujos vectoriales (\\p1)",
        signs_auto_gbc = "Detectar y regenerar gradientes GBC automaticamente",
        signs_use_cap = "Aplicar limite de caracteres",
        signs_no_editable = "No se encontraron lineas editables en la seleccion.",
        signs_original = "ORIGINAL (solo lectura)",
        signs_modified = "MODIFICADO (editar aqui)",
        signs_regen_gbc = "Regenerar gradientes GBC en lineas modificadas",
        signs_info = "%d textos unicos, %d lineas totales. %d GBC detectados.",
        signs_skipped_vectors = " %d vectores omitidos.",
        signs_skipped_over_limit = " %d omitidas por limite.",
        signs_line_mismatch = "Cantidad de lineas incorrecta: se esperaban %d, hay %d.\nNo se aplicaron cambios.",
    },
    pt = {
        lang_en = "Ingles", lang_es = "Espanhol", lang_pt = "Portugues",
        btn_delete = "Apagar", btn_apply = "Aplicar", btn_copy_tags = "Copiar tags", btn_keep_only = "Keep Only",
        op_apply_chain = "Aplicar cadeia", op_apply_mask = "Aplicar mascara", op_create_layer = "Criar camada",
        op_replace_mask = "Substituir mascara", op_save_shape = "Salvar forma", op_delete_shape = "Apagar forma", op_clean_dr = "Limpar DR",
        op_typewriter = "Maquina de escrever", op_vertical_drop = "Queda vertical", op_circle_text = "Texto circular", op_curve_text = "Texto em curva",
        op_align_clip = "Alinhar ao clip", op_clean_sio = "Limpar SiO", op_borders = "Bordas", op_preset = "Preset",
        op_clean_cal = "Limpar CAL", choice_frame = "Frame", choice_duration = "Duracao", choice_normal = "Normal",
        choice_inverted = "Invertido", choice_vertical = "Vertical", choice_from_clip = "Do clip",
        pk_copy_exact = "Copiar exato (mesmo plano)", pk_copy_static = "Copiar plano estatico (manter \\pos)", pk_copy_move_plane = "Copiar plano com \\move",
        pk_copy_swap = "Copiar trocando cantos", pk_copy_translate = "Copiar translacao (manter \\pos)", pk_copy_transport = "Transportar copia (\\org -> \\pos)",
        pk_mass_fsc = "FSC em lote (travar quad)", pk_scale_quad = "Escalar quad (caixa 3D)", pk_clip_persp = "Clip para perspectiva",
        pk_rescale_clip = "Redimensionar ao clip", pk_bake_extra = "Gravar extradata", pk_restore_extra = "Restaurar extradata",
        pk_identity = "Reprojetar identidade", map_abcd = "ABCD (copia exata)", map_badc = "BADC (espelho horizontal)",
        map_dcba = "DCBA (espelho vertical)", map_cdab = "CDAB (rotacionar 180)", map_bcda = "BCDA (rotacionar 90 horario)",
        map_dabc = "DABC (rotacionar 90 anti-horario)", map_abdc = "ABDC (trocar CD)", map_bacd = "BACD (trocar AB)",
        map_ab_cd = "AB fonte + CD destino", map_cd_ab = "CD fonte + AB destino", map_ac_bd = "AC fonte + BD destino",
        map_bd_ac = "BD fonte + AC destino", org_keep = "Manter org destino", org_center = "Centro do quad", org_min_fax = "Minimizar fax",
        res_fit = "Ajustar (uniforme)", res_fill = "Preencher (uniforme)", res_stretch = "Esticar (por eixo)",
        shape_once = "Uma vez (ida)", shape_round = "Ida e volta", shape_yoyo = "Yoyo (N ciclos)",
        shape_pulse = "Pulso (ms)", shape_steps = "Passos (N)", shape_custom = "Keyframes personalizados",
        delay_none = "Sem atraso", delay_ms = "ms desde inicio", delay_frame = "Frame atual", delay_percent = "Porcentagem (%)",
        fx_blur_in = "Blur entrada", fx_blur_out = "Blur saida", fx_fade_in = "Fade entrada", fx_fade_out = "Fade saida",
        fx_scale_up = "Escalar acima", fx_scale_down = "Escalar abaixo", fx_pop_in = "Pop entrada", fx_pop_out = "Pop saida",
        fx_color_flash = "Flash de cor", fx_color_pulse = "Pulso de cor", fx_to_color = "Para cor (frame)",
        fx_to_style = "Para estilo (frame)", fx_border_pulse = "Pulso de borda", fx_glow_pulse = "Pulso de brilho",
        fx_shake_v = "Tremer V", fx_shake_h = "Tremer H", fx_shake_xy = "Tremer XY", fx_wobble = "Oscilar (frz)",
        fx_glitch = "Glitch", fx_dramatic_pulse = "Pulso dramatico", fx_flashback = "Flashback (fad)", fx_split_line = "Dividir linha",
        fx_split_line_fad = "Dividir linha com fad", fx_split_title = "Dividir titulo",
        cal_decompose = "Decompor (preenchimento + borda)", cal_blur_glow = "Blur + brilho", cal_shadtrick = "Truque de sombra (camada sombra)",
        cal_double_border = "Borda dupla blur", cal_clean_layers = "Limpar camadas (achatar)",
        tagops_measure = "Medir e transformar clip", tagops_adjust = "Ajustar tags", tagops_clip_scale_adjust = "Ajustar por escala de clip",
        tagops_copy_no_change = "Copiar tags: nenhuma linha destino foi alterada.",
        tagops_adjust_no_change = "Ajustar tags: nenhum valor foi alterado.",
        tagops_keep_only_changed = "Keep Only alterou %d linha(s).",
        tagops_keep_only_no_change = "Keep Only: nenhuma tag foi removida.",
        tagops_transition = "Tags In-Out", tagops_pos_align = "Alinhar pos", tagops_add = "Somar", tagops_percent = "Porcentagem",
        tagops_keep_org = "Manter org (so pos)", tagops_move_org = "Mover org",
        tagops_axis = "Eixo", tagops_angle = "Angulo FRZ", tagops_clip_hotkey = "Hotkey clip",
        tagops_angle_transform = "Transformar angulo", tagops_angle_first = "Primeiro angulo",
        tagops_clip_cal_x = "Calibrar clip X", tagops_clip_cal_y = "Calibrar clip Y",
        tagops_clip_rect = "Retangulo pela diagonal", tagops_clip_toggle = "Alternar clip/iclip",
        tagops_clip_copy = "Copiar clip/iclip",
        tagops_no_clip_changed = "Nenhum clip editavel encontrado.",
        tagops_clip_changed = "Linhas de clip alteradas: %d",
        tagops_clip_transform_done = "Transformacoes de clip: %d",
        tagops_err_align_select = "Selecione ao menos duas linhas de dialogo. A primeira selecionada e a fonte e a segunda e a referencia.",
        tagops_err_source_pos = "A primeira linha selecionada nao tem \\pos.",
        tagops_err_reference_pos = "A segunda linha selecionada nao tem \\pos.",
        tagops_align_no_delta = "A primeira e segunda linhas selecionadas nao tem delta usavel de \\pos nem de \\org.",
        tagops_align_done = "Pos Align moveu %d linhas.",
        msg_layout_mismatch_layout = "LayoutResY (%s) nao coincide com PlayResY (%s).",
        msg_layout_mismatch_play = "PlayResY (%s) nao coincide com a altura do video (%s).",
        msg_layout_depth_scale = "Perspectiva usara escala de profundidade %.4f. Se a resolucao do script ou do video estiver errada, o plano gerado pode ficar fora do clip.",
        msg_layout_recommended = "Recomendado: reamostre o script ou ajuste LayoutResY/PlayResY para coincidirem antes de aplicar.",
        msg_continue_anyway = "Continuar mesmo assim?",
        msg_need_two_copy_lines = "Selecione >=2 linhas. Mesmo Effect = grupo; Effect vazio = um grupo; senao, a primeira copia para todas.",
        msg_no_video = "Nao ha video carregado.",
        msg_frame_time_unresolved = "Nao foi possivel resolver o tempo do frame.",
        msg_line_duration_zero = "Linha %d: duracao 0",
        msg_frame_unavailable = "Frame indisponivel.",
        msg_frame_out_of_range = "Frame %dms fora do intervalo (%d-%d).",
        msg_line_frame_out_of_range = "Linha %d: frame fora do intervalo (%d-%d)",
        msg_style_not_found = "estilo nao encontrado",
        msg_missing_pipe = "sem marcador |",
        msg_marker_error = "erro com marcador",
        msg_delete_dr_marked = "Apagar %d linhas marcadas DR?",
        msg_no_dr_marked = "Nenhuma linha marcada DR encontrada.",
        msg_no_dr_marked_selection = "Nao ha linhas marcadas DR na selecao.",
        msg_no_vector_curve = "Nenhum clip vetorial encontrado na selecao para curva.",
        msg_no_vector_align = "Nenhum clip vetorial encontrado na selecao para alinhar.",
        msg_no_usable_path_align = "O clip vetorial nao tem caminho usavel para alinhar.",
        msg_no_cal_marked = "Nenhuma linha marcada CAL encontrada.",
        msg_delete_cal_marked = "Apagar %d linhas marcadas CAL?",
        signs_editor_title = "== EDITOR DE PLACAS ==",
        signs_skip_vec = "Ignorar desenhos vetoriais (\\p1)",
        signs_auto_gbc = "Detectar e regenerar gradientes GBC automaticamente",
        signs_use_cap = "Aplicar limite de caracteres",
        signs_no_editable = "Nenhuma linha editavel encontrada na selecao.",
        signs_original = "ORIGINAL (somente leitura)",
        signs_modified = "MODIFICADO (editar aqui)",
        signs_regen_gbc = "Regenerar gradientes GBC nas linhas modificadas",
        signs_info = "%d textos unicos, %d linhas totais. %d GBC detectados.",
        signs_skipped_vectors = " %d vetores ignorados.",
        signs_skipped_over_limit = " %d ignoradas por limite.",
        signs_line_mismatch = "Quantidade de linhas incorreta: esperadas %d, recebidas %d.\nNenhuma alteracao aplicada.",
    },
}
for code, tbl in pairs(EXTRA_LANG) do
    LANG[code] = LANG[code] or {}
    for key, value in pairs(tbl) do LANG[code][key] = value end
end
local current_lang = "en"
local function L(key)
    local localValue = (LANG[current_lang] and LANG[current_lang][key]) or LANG.en[key]
    if localValue then return localValue end
    if type(_G.OlympusL) == "function" then
        local v = _G.OlympusL(key); if type(v) == "string" and v ~= "" and v ~= key then return v end
    end
    return key
end

local function sectionTitle(key)
    return "== " .. L(key) .. " =="
end


local DEFAULT_CONFIG = {
    language = "en",
    fx_color1 = "#FFCC00", fx_color2 = "#00CCFF", mask_color = "#000000",
    color1 = "#FFFFFF", color2 = "#000000", color3 = "#FF0000", color4 = "#00FF00",
    fastsign_box_color = "#151515", fastsign_box_alpha = "80",
    fastsign_text_color = "#FFFFFF", fastsign_glow_color = "#000000",
    fastsign_glow_alpha = "20", fastsign_fade_ms = 250,
    fastsign_margin_h = 24, fastsign_margin_v = 16,
    fastsign_top_offset = 30, fastsign_horz_gap = 35,
    fastsign_max_width = 95, fastsign_box_blur = 1.5,
    fastsign_glow_border = 2.5, fastsign_glow_blur = 3,
    fastsign_text_blur = 0.2,
    tagops_action = "Measure & Transform Clip", tagops_amount = 0, tagops_mode = "Add",
    tagops_align_org = "Keep org", tagops_clip_axis = "", tagops_angle_mode = "", tagops_clip_hotkey = "",
    tagops_replace = true, tagops_all_blocks = false, tagops_append = false, tagops_info = false,
    tagops_pos = false, tagops_move = false, tagops_org = false, tagops_clip = false, tagops_iclip = false,
    tagops_fad = false, tagops_fade = false, tagops_t = false, tagops_r = false, tagops_an = false,
    tagops_a = false, tagops_q = false, tagops_fn = false, tagops_fs = false, tagops_fsp = false,
    tagops_fscx = false, tagops_fscy = false, tagops_frz = false, tagops_frx = false, tagops_fry = false,
    tagops_fax = false, tagops_fay = false, tagops_bord = false, tagops_xbord = false, tagops_ybord = false,
    tagops_shad = false, tagops_xshad = false, tagops_yshad = false, tagops_blur = false, tagops_be = false,
    tagops_b = false, tagops_i = false, tagops_u = false, tagops_s = false, tagops_c = false,
    tagops_2c = false, tagops_3c = false, tagops_4c = false, tagops_alpha = false,
    tagops_1a = false, tagops_2a = false, tagops_3a = false, tagops_4a = false,
    tagops_k = false, tagops_kf = false, tagops_ko = false, tagops_p = false, tagops_pbo = false,
    tagops_fe = false,
}
local CONFIG_HANDLER
local RheaConfig = { defaults = {}, sections = {} }
local config_loaded = false
local current_config = FunctionalTable.union(DEFAULT_CONFIG)

local function loadGlobalConfig()
    if not CONFIG_HANDLER then
        local section = {}
        local function addConfigValue(k, v)
            section[k] = { value = v, config = true, name = k, class = "edit" }
        end
        for k, v in pairs(DEFAULT_CONFIG) do addConfigValue(k, v) end
        if RheaConfig and RheaConfig.defaults and RheaConfig.key then
            for prefix, defaults in pairs(RheaConfig.defaults) do
                for key, value in pairs(defaults or {}) do
                    addConfigValue(RheaConfig.key(prefix, key), value)
                end
            end
        end
        CONFIG_HANDLER = ConfigHandler({ rhea = section }, "rhea_signs_config.json", true, script_version)
    end
    if config_loaded then return true end
    local f = io.open(CONFIG_HANDLER.fileName, "r")
    if f then
        f:close()
    else
        CONFIG_HANDLER:write()
    end
    CONFIG_HANDLER:read()
    current_config = CONFIG_HANDLER.configuration.rhea
    current_lang = current_config.language or "en"
    config_loaded = true
    return true
end

local function saveGlobalConfig()
    if CONFIG_HANDLER then CONFIG_HANDLER:write(); return true end
    return false
end

local function resolveConfig()
    loadGlobalConfig()
    if _G.Olympus and type(_G.Olympus.config) == "table" then
        for k, v in pairs(_G.Olympus.config) do
            if current_config[k] == nil and RheaConfig.isKnownKey(k) then current_config[k] = v end
        end
        current_lang = _G.Olympus.config.language or current_lang
    end
end


local function showMsg(msg, buttons, opts, dialogOpts)
    opts = opts or {}
    return aegisub.dialog.display({{
        class = "label", label = tostring(msg),
        x = 0, y = 0, width = opts.width or 25, height = opts.height or 4,
    }}, buttons or {L("btn_ok")}, dialogOpts)
end

local Rhea = {}

Rhea.trim             = FunctionalString.trim
Rhea.escapePattern    = FunctionalString.escLuaExp
Rhea.clamp            = FunctionalUtil.clamp
Rhea.round            = FunctionalMath.round
Rhea.roundTo          = function(n, d) return FunctionalMath.round(tonumber(n) or 0, d or 0) end

function Rhea.cloneLine(l)
    if type(l.copy) == "function" then return l:copy() end
    local d = { class = l.class or "dialogue" }
    for k, v in pairs(l) do
        if type(v) == "table" then
            d[k] = {}; for ki, vi in pairs(v) do d[k][ki] = vi end
        else d[k] = v end
    end
    setmetatable(d, getmetatable(l)); return d
end

function Rhea.stripTags(t) return tostring(t or ""):gsub("{[^}]*}", "") end
function Rhea.visibleText(t) return Rhea.stripTags(t):gsub("\\[Nnh]", " ") end
function Rhea.visibleLines(t)
    local clean = Rhea.stripTags(t):gsub("\\[Nn]", "\n"):gsub("\\h", " ")
    local lines = {}
    for line in (clean .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line ~= "" and line or " "
    end
    return #lines > 0 and lines or {" "}
end

function Rhea.isDialogue(l) return type(l) == "table" and (l.class == nil or l.class == "dialogue") end

function Rhea.htmlToAss(html)
    if not html or html == "" then return "&H000000&" end
    html = tostring(html)
    local hex = html:match("&[Hh]([%xA-Fa-f]+)&?")
    if hex then
        if #hex > 6 then hex = hex:sub(-6) end
        while #hex < 6 do hex = "0" .. hex end
        return "&H" .. hex:upper() .. "&"
    end
    local r, g, b = html:match("^#?(%x%x)(%x%x)(%x%x)$")
    if not r then r, g, b = html:match("^#?(%x%x)(%x%x)(%x%x)%x%x$") end
    if r then return "&H" .. b:upper() .. g:upper() .. r:upper() .. "&" end
    return "&H000000&"
end

function Rhea.assToHtml(ass)
    if not ass or ass == "" then return "#FFFFFF" end
    local hex = ass:match("&[Hh]([%xA-Fa-f]+)&?")
    if hex then
        if #hex > 6 then hex = hex:sub(-6) end
        while #hex < 6 do hex = "0" .. hex end
        local b, g, r = hex:sub(1, 2), hex:sub(3, 4), hex:sub(5, 6)
        return "#" .. r:upper() .. g:upper() .. b:upper()
    end
    if ass:match("^#") then return ass end
    return "#FFFFFF"
end

function Rhea.styleMap(subs)
    local s = {}
    for i = 1, #subs do
        if subs[i].class == "style" then s[subs[i].name] = subs[i] end
    end
    return s
end
function Rhea.formatNum(n, decimals)
    decimals = decimals or 4
    n = tonumber(n)
    if not n or n ~= n or n == math.huge or n == -math.huge then return "0" end
    if n == math.floor(n) then return string.format("%d", math.floor(n + 0.5)) end
    local s = string.format("%." .. decimals .. "f", n)
    s = s:gsub("0+$", ""):gsub("%.$", "")
    if s == "-0" or s == "" then s = "0" end
    return s
end

function Rhea.colorNorm(c)
    if not c or c == "" then return "&HFFFFFF&" end
    if type(c) == "number" then
        if c < 0 then c = c + 4294967296 end
        return string.format("&H%06X&", c % 16777216)
    end
    local h = tostring(c):match("&[Hh]([%xA-Fa-f]+)&?")
    if h then
        if #h > 6 then h = h:sub(-6) end
        while #h < 6 do h = "0" .. h end
        local b, g, r = h:sub(1, 2), h:sub(3, 4), h:sub(5, 6)
        return tostring(ASS:createTag("color1", tonumber(b, 16), tonumber(g, 16), tonumber(r, 16))):match("&H%x%x%x%x%x%x&")
    end
    local r, g, b = tostring(c):match("#?(%x%x)(%x%x)(%x%x)")
    if r then
        return tostring(ASS:createTag("color1", tonumber(b, 16), tonumber(g, 16), tonumber(r, 16))):match("&H%x%x%x%x%x%x&")
    end
    return "&HFFFFFF&"
end
function Rhea.colorFromStyle(n)
    if type(n) == "string" then return Rhea.colorNorm(n) end
    if type(n) ~= "number" then return "&HFFFFFF&" end
    if n < 0 then n = n + 4294967296 end
    return string.format("&H%06X&", n % 16777216)
end

function Rhea.firstBlock(text)
    return tostring(text or ""):match("^({[^}]*})") or ""
end
function Rhea.injectFirst(text, payload)
    if not payload or payload == "" then return text end
    local fb = Rhea.firstBlock(text)
    if fb ~= "" then
        return "{" .. payload .. fb:sub(2, -2) .. "}" .. text:sub(#fb + 1)
    end
    return "{" .. payload .. "}" .. text
end
function Rhea.isVectorLine(text)
    return tostring(text or ""):find("\\p[1-9]") ~= nil
end

function Rhea.tokenize(text)
    local tokens, pos = {}, 1
    text = tostring(text or "")
    local n = #text
    while pos <= n do
        local b = text:sub(pos, pos)
        if b == "{" then
            local close = text:find("}", pos + 1, true)
            if close then
                local content = text:sub(pos, close)
                tokens[#tokens + 1] = { type = "tag", content = content }
                pos = close + 1
            else
                tokens[#tokens + 1] = { type = "char", content = "{" }
                pos = pos + 1
            end
        elseif b == "\\" and pos < n then
            local nx = text:sub(pos + 1, pos + 1)
            if nx == "N" or nx == "n" or nx == "h" then
                tokens[#tokens + 1] = { type = "break", content = "\\" .. nx }
                pos = pos + 2
            else
                tokens[#tokens + 1] = { type = "char", content = b }
                pos = pos + 1
            end
        else
            local ch
            for c in unicode.chars(text:sub(pos)) do ch = c; break end
            if ch and ch ~= "" then
                tokens[#tokens + 1] = { type = "char", content = ch }
                pos = pos + #ch
            else
                tokens[#tokens + 1] = { type = "char", content = b }
                pos = pos + 1
            end
        end
    end
    return tokens
end
function Rhea.tokenizeVisible(text)
    local out = {}
    for _, tk in ipairs(Rhea.tokenize(text)) do
        if tk.type ~= "tag" then out[#out + 1] = { type = tk.type, content = tk.content } end
    end
    return out
end

local RHEA_BREAK_SENTINELS = {
    ["\\N"] = string.char(238, 128, 128),
    ["\\n"] = string.char(238, 128, 129),
    ["\\h"] = string.char(238, 128, 130),
}

local RHEA_BREAK_FROM_SENTINEL = {}
for breakText, sentinel in pairs(RHEA_BREAK_SENTINELS) do
    RHEA_BREAK_FROM_SENTINEL[sentinel] = breakText
end

function Rhea.protectVisibleBreaks(text)
    local out = {}
    for _, tk in ipairs(Rhea.tokenize(text)) do
        out[#out + 1] = tk.type == "break" and RHEA_BREAK_SENTINELS[tk.content] or tk.content
    end
    return table.concat(out)
end

function Rhea.restoreVisibleBreaks(text)
    text = tostring(text or "")
    for sentinel, breakText in pairs(RHEA_BREAK_FROM_SENTINEL) do
        text = text:gsub(Rhea.escapePattern(sentinel), breakText)
    end
    return text
end

function Rhea.readMarker(line, prefix)
    return (line and line.effect or ""):match("%[" .. prefix .. "%-([%w]+)%]")
end

local RheaFoundation = setmetatable({}, { __index = Rhea })

local RHEA_TAG_TO_ASS = {
    pos = "position", move = "move", org = "origin",
    clip = "clip_vect", iclip = "iclip_vect",
    fad = "fade_simple", fade = "fade",
    t = "transform", r = "reset",
    an = "align", a = "align",
    q = "wrapstyle", fn = "fontname",
    fs = "fontsize", fsp = "spacing",
    fscx = "scale_x", fscy = "scale_y",
    frz = "angle", fr = "angle",
    frx = "angle_x", fry = "angle_y",
    fax = "shear_x", fay = "shear_y",
    bord = "outline", xbord = "outline_x", ybord = "outline_y",
    shad = "shadow", xshad = "shadow_x", yshad = "shadow_y",
    blur = "blur", be = "blur_edges",
    b = "bold", i = "italic", u = "underline", s = "strikeout",
    c = "color1", ["1c"] = "color1",
    ["2c"] = "color2", ["3c"] = "color3", ["4c"] = "color4",
    alpha = "alpha",
    ["1a"] = "alpha1", ["2a"] = "alpha2", ["3a"] = "alpha3", ["4a"] = "alpha4",
    k = "karaoke", kf = "karaoke_sweep", K = "karaoke_sweep", ko = "karaoke_outline",
    p = "drawing", pbo = "drawing_offset", fe = "encoding",
}

local RHEA_KNOWN_NAMES = {}
for k in pairs(RHEA_TAG_TO_ASS) do RHEA_KNOWN_NAMES[#RHEA_KNOWN_NAMES + 1] = k end
table.sort(RHEA_KNOWN_NAMES, function(a, b) return #a > #b end)

function RheaFoundation.balancedParenEnd(text, startPos)
    local depth = 0
    for i = startPos, #text do
        local c = text:sub(i, i)
        if c == "(" then depth = depth + 1
        elseif c == ")" then
            depth = depth - 1
            if depth == 0 then return i end
        end
    end
    return #text
end

function RheaFoundation.iterTagBlocks(text)
    local blocks, i = {}, 1
    text = tostring(text or "")
    while true do
        local s = text:find("{", i, true); if not s then break end
        local e = text:find("}", s + 1, true); if not e then break end
        blocks[#blocks + 1] = {
            openPos = s, closePos = e,
            content = text:sub(s + 1, e - 1),
        }
        i = e + 1
    end
    return blocks
end

function RheaFoundation.parseTagBlock(block)
    block = tostring(block or "")
    local tags, i = {}, 1
    while i <= #block do
        if block:sub(i, i) == "\\" then
            local nameStart = i + 1
            local name
            for _, known in ipairs(RHEA_KNOWN_NAMES) do
                if block:sub(nameStart, nameStart + #known - 1) == known then
                    name = known
                    break
                end
            end
            if not name then name = block:sub(nameStart):match("^[1-4]?[A-Za-z]+") or "" end
            if name ~= "" then
                local j = nameStart + #name
                local tokenEnd
                if block:sub(j, j) == "(" then
                    tokenEnd = RheaFoundation.balancedParenEnd(block, j)
                else
                    tokenEnd = j - 1
                    while tokenEnd + 1 <= #block and block:sub(tokenEnd + 1, tokenEnd + 1) ~= "\\" do
                        tokenEnd = tokenEnd + 1
                    end
                end
                tags[#tags + 1] = {
                    name = name,
                    raw = block:sub(i, tokenEnd),
                    value = block:sub(j, tokenEnd),
                    startPos = i,
                    endPos = tokenEnd,
                }
                i = tokenEnd + 1
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    return tags
end

function RheaFoundation.tagNumbers(value)
    local nums = {}
    for n in tostring(value or ""):gmatch("[%+%-]?%d+%.?%d*") do
        nums[#nums + 1] = tonumber(n)
    end
    return nums
end

function RheaFoundation.namesToASS(rawNames)
    local list, seen = {}, {}
    local function addMapped(mapped)
        if not seen[mapped] then seen[mapped] = true; list[#list + 1] = mapped end
    end
    local function add(n)
        if n == "clip" then
            addMapped("clip_vect")
            addMapped("clip_rect")
        elseif n == "iclip" then
            addMapped("iclip_vect")
            addMapped("iclip_rect")
        else
            addMapped(RHEA_TAG_TO_ASS[n] or n)
        end
    end
    if type(rawNames) == "string" then add(rawNames)
    elseif type(rawNames) == "table" then
        if rawNames[1] ~= nil then
            for _, n in ipairs(rawNames) do add(n) end
        else
            for n, v in pairs(rawNames) do if v then add(n) end end
        end
    end
    return list
end

local ASS_LINE_DEFAULTS = {
    class = "dialogue", comment = false, layer = 0,
    start_time = 0, end_time = 0, style = "Default",
    actor = "", margin_l = 0, margin_r = 0, margin_t = 0,
    effect = "", text = "",
}

function RheaFoundation.toASSLine(textOrLine)
    if type(textOrLine) == "table" and textOrLine.__class then return textOrLine end
    local src = type(textOrLine) == "table" and textOrLine or { text = tostring(textOrLine or "") }
    local line = {}
    for k, v in pairs(ASS_LINE_DEFAULTS) do line[k] = v end
    for k, v in pairs(src) do line[k] = v end
    line.text = tostring(line.text or "")
    return AMLine(line, src.parentCollection, {})
end

function RheaFoundation.parseLine(textOrLine)
    if type(textOrLine) == "table" and textOrLine.class == ASS.LineContents then return textOrLine end
    return ASS:parse(RheaFoundation.toASSLine(textOrLine))
end

function RheaFoundation.tryParseLine(textOrLine)
    local ok, data = pcall(RheaFoundation.parseLine, textOrLine)
    return ok and data or nil
end

function RheaFoundation.removeTags(text, rawNames)
    if not text or text == "" then return text end
    local data = RheaFoundation.tryParseLine(text)
    if not data then return text end
    data:removeTags(RheaFoundation.namesToASS(rawNames))
    return data:getString()
end

function RheaFoundation.insertTags(text, payload, mode)
    if not payload or payload == "" then return text end
    if mode == "append" then
        local fb = Rhea.firstBlock(text)
        if fb ~= "" then
            return fb:sub(1, -2) .. payload .. "}" .. text:sub(#fb + 1)
        end
        return "{" .. payload .. "}" .. text
    end
    return Rhea.injectFirst(text, payload)
end

function RheaFoundation.stripAutoMarkers(text)
    return (tostring(text or ""):gsub("{%*[^}]*}", ""))
end

function RheaFoundation.firstClipTag(textOrLine)
    local ok, eff = pcall(function()
        local data = RheaFoundation.parseLine(textOrLine)
        return data:getEffectiveTags(-1, false, true, false).tags
    end)
    if not ok or not eff then return nil end
    return eff.clip_vect or eff.iclip_vect or eff.clip_rect or eff.iclip_rect
end

function RheaFoundation.clipKind(clip)
    local name = clip and clip.__tag and clip.__tag.name or ""
    return name:match("^iclip") and "iclip" or "clip"
end

function RheaFoundation.clipCommandList(clip)
    if not clip then return {} end
    if clip.commands then return clip.commands end
    local out = {}
    for _, contour in ipairs(clip.contours or {}) do
        for _, cmd in ipairs(contour.commands or contour) do
            out[#out + 1] = cmd
        end
    end
    return out
end

function RheaFoundation.clipPoints(clip)
    if not clip then return nil end
    if clip.topLeft and clip.bottomRight then
        local tl, br = clip.topLeft, clip.bottomRight
        return { { tl.x, tl.y }, { br.x, tl.y }, { br.x, br.y }, { tl.x, br.y } }
    end
    local pts = {}
    local function addPoint(p)
        local x = tonumber(p and (p.x or p[1]))
        local y = tonumber(p and (p.y or p[2]))
        if x and y then pts[#pts + 1] = { x, y } end
    end
    for _, cmd in ipairs(RheaFoundation.clipCommandList(clip)) do
        local usedGetter = false
        if type(cmd.getPoints) == "function" then
            local ok, points = pcall(function() return cmd:getPoints(true) end)
            if ok and type(points) == "table" then
                for _, p in ipairs(points) do addPoint(p) end
                usedGetter = true
            end
        end
        if not usedGetter and cmd.x and cmd.y then addPoint(cmd) end
    end
    return pts
end

function RheaFoundation.clipBBox(clip)
    if not clip then return nil end
    if clip.topLeft and clip.bottomRight then
        local tl, br = clip.topLeft, clip.bottomRight
        return math.min(tl.x, br.x), math.min(tl.y, br.y), math.max(tl.x, br.x), math.max(tl.y, br.y)
    end
    local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
    for _, p in ipairs(RheaFoundation.clipPoints(clip) or {}) do
        local x, y = p[1], p[2]
        if x < minx then minx = x end
        if y < miny then miny = y end
        if x > maxx then maxx = x end
        if y > maxy then maxy = y end
    end
    if minx == math.huge then return nil end
    return minx, miny, maxx, maxy
end

function RheaFoundation.anchorPointFromAlign(an, x1, y1, x2, y2)
    an = tonumber(an) or 5
    local h = (an - 1) % 3
    local v = math.floor((an - 1) / 3)
    local x = h == 0 and x1 or (h == 1 and (x1 + x2) / 2 or x2)
    local y = v == 0 and y2 or (v == 1 and (y1 + y2) / 2 or y1)
    return x, y
end

function RheaFoundation.setPositionTag(text, x, y, opts)
    text = tostring(text or "")
    if opts and opts.keepMove and text:match("\\move%(") then return text end
    local pos = string.format("\\pos(%.3f,%.3f)", tonumber(x) or 0, tonumber(y) or 0)
    if text:match("\\pos%(") then return (text:gsub("\\pos%([^%)]*%)", pos, 1)) end
    return Rhea.injectFirst(text, pos)
end

function RheaFoundation.setAlignTag(text, an)
    text = tostring(text or "")
    local align = string.format("\\an%d", tonumber(an) or 5)
    if text:match("\\an[1-9]") then return (text:gsub("\\an[1-9]", align, 1)) end
    return Rhea.injectFirst(text, align)
end

function RheaFoundation.clipCommands(clip)
    if not clip then return nil end
    if clip.topLeft and clip.bottomRight then
        local tl, br = clip.topLeft, clip.bottomRight
        return {
            { type = "m", pts = { tl.x, tl.y } },
            { type = "l", pts = { br.x, tl.y, br.x, br.y, tl.x, br.y, tl.x, tl.y } },
        }
    end
    local out = {}
    for _, cmd in ipairs(RheaFoundation.clipCommandList(clip)) do
        local t = cmd.__tag and cmd.__tag.name
        if t == "m" or t == "l" or t == "n" then
            out[#out + 1] = { type = t == "n" and "m" or t, pts = { cmd.x, cmd.y } }
        elseif t == "b" then
            out[#out + 1] = { type = "b", pts = {
                cmd.x1 or cmd.p1 and cmd.p1.x, cmd.y1 or cmd.p1 and cmd.p1.y,
                cmd.x2 or cmd.p2 and cmd.p2.x, cmd.y2 or cmd.p2 and cmd.p2.y,
                cmd.x or cmd.p3 and cmd.p3.x, cmd.y or cmd.p3 and cmd.p3.y,
            } }
        end
    end
    return #out > 0 and out or nil
end

function RheaFoundation.lineBoundsSize(line, text, style)
    if not line then return nil end
    local sample = Rhea.cloneLine(line)
    if text ~= nil then sample.text = tostring(text or "") end
    local ok, bw, bh = pcall(function()
        local data = RheaFoundation.parseLine(sample)
        local bounds = data:getLineBounds(true)
        if bounds then return bounds.w, bounds.h end
    end)
    if ok and bw and bh then return bw, bh end
    style = style or line.styleref or line.styleRef
    if style then
        local w, h = RheaFoundation.multilineTextExtents(style, sample.text)
        local outline = tonumber(style.outline) or 0
        return w + outline * 2, h + outline * 2
    end
    return nil
end

function RheaFoundation.textExtents(style, text)
    return aegisub.text_extents(style, tostring(text or ""))
end

function RheaFoundation.multilineTextExtents(style, text)
    local width, height = 0, 0
    for _, line in ipairs(Rhea.visibleLines(text)) do
        local w, h = RheaFoundation.textExtents(style, line)
        width = math.max(width, tonumber(w) or 0)
        height = height + math.max(tonumber(h) or 0, 0)
    end
    return width, height
end

function RheaFoundation.groupByTagState(ass, tagName)
    local groups, group = {}, nil
    ass:callback(function(section, sections, i)
        local isAnchor = (i == 1) or (section.instanceOf and section.instanceOf[ASS.Section.Tag] and #section:getTags(tagName) > 0)
        if isAnchor then
            local state = section:getEffectiveTags(true).tags[tagName]
            if group then group.endTagState = state end
            group = { sections = {}, startTagState = state, firstLineIndex = i }
            groups[#groups + 1] = group
        elseif i == #sections then
            group.endTagState = section:getEffectiveTags(true).tags[tagName]
        end
        if group then group.sections[#group.sections + 1] = section end
    end)
    return groups
end

function RheaFoundation.lerpGroup(sections, startTagState, endTagState)
    if not startTagState or not endTagState then return false end
    local totalCharCount = 0
    for _, section in ipairs(sections) do
        if section.instanceOf and section.instanceOf[ASS.Section.Text] then
            totalCharCount = totalCharCount + section.len
        end
    end
    if totalCharCount == 0 then return false end

    local processedCharCount = 0
    local lerpedSections, l = {}, 1
    for s, section in ipairs(sections) do
        if not (section.instanceOf and section.instanceOf[ASS.Section.Text]) then
            lerpedSections[l] = section
            l = l + 1
        else
            local charCount = section.len
            local previousSection = sections[s - 1]
            local startIdx
            if previousSection and previousSection.instanceOf and previousSection.instanceOf[ASS.Section.Tag] then
                previousSection:removeTags(startTagState.__tag.name)
                previousSection:insertTags(startTagState:lerp(endTagState, processedCharCount / totalCharCount))
                local left, right = section:splitAtChar(2, true)
                lerpedSections[l] = left
                section = right
                l = l + 1
                startIdx = 2
            else
                startIdx = 1
            end
            for i = startIdx, charCount do
                local tag = startTagState:lerp(endTagState, (processedCharCount + i - 1) / totalCharCount)
                lerpedSections[l] = ASS.Section.Tag({ tag })
                local left, right = section:splitAtChar(2, true)
                lerpedSections[l + 1] = left
                section = right
                l = l + 2
            end
            processedCharCount = processedCharCount + charCount
        end
    end
    return lerpedSections
end

function RheaFoundation.visibleFromASS(ass)
    local out = {}
    ass:callback(function(section)
        if section.instanceOf and section.instanceOf[ASS.Section.Text] then
            out[#out + 1] = section.value
        end
    end)
    return table.concat(out)
end

function RheaFoundation.replaceVisibleText(ass, newVisible)
    local sections, sizes, total = {}, {}, 0
    ass:callback(function(section)
        if section.instanceOf and section.instanceOf[ASS.Section.Text] then
            sections[#sections + 1] = section
            local size = #Rhea.tokenizeVisible(section.value)
            sizes[#sizes + 1] = size
            total = total + size
        end
    end)
    if #sections == 0 then return false end
    local elems = Rhea.tokenizeVisible(newVisible)
    local newTotal = #elems
    if total == 0 then
        sections[1].value = newVisible
        for i = 2, #sections do sections[i].value = "" end
        return true
    end
    local used = 0
    for i, section in ipairs(sections) do
        local chunk
        if i == #sections then
            chunk = newTotal - used
        else
            local proportional = Rhea.round(newTotal * (sizes[i] / total))
            local leftAfter = newTotal - used - proportional
            local needForRest = #sections - i
            if leftAfter < needForRest then
                proportional = math.max(0, newTotal - used - needForRest)
            end
            chunk = proportional
        end
        local pieces = {}
        for j = 1, chunk do pieces[j] = elems[used + j].content end
        section.value = table.concat(pieces)
        used = used + chunk
    end
    return true
end

function RheaFoundation.detectGBCTag(text)
    local star = tostring(text or ""):match("{%*([^}]+)}")
    if not star then return nil end
    local raw = star:match("^\\([1-4]?[A-Za-z]+)")
    if not raw then return nil end
    return RHEA_TAG_TO_ASS[raw] or raw
end

function RheaFoundation.lerpLine(ass, tagName)
    local groups = RheaFoundation.groupByTagState(ass, tagName)
    local insertOffset = 0
    local applied = false
    for _, group in ipairs(groups) do
        local lerped = RheaFoundation.lerpGroup(group.sections, group.startTagState, group.endTagState)
        if lerped then
            ass:removeSections(insertOffset + group.firstLineIndex, insertOffset + group.firstLineIndex + #group.sections - 1)
            ass:insertSections(lerped, insertOffset + group.firstLineIndex)
            insertOffset = insertOffset + #lerped - #group.sections
            applied = true
        end
    end
    if applied then ass:cleanTags(4) end
    return applied
end

function RheaConfig.key(prefix, key)
    return tostring(prefix or "rhea") .. "_" .. tostring(key)
end

function RheaConfig.isKnownKey(key)
    if DEFAULT_CONFIG[key] ~= nil then return true end
    local rawKey = tostring(key or "")
    for prefix, defaults in pairs(RheaConfig.defaults) do
        local prefixText = tostring(prefix or "rhea") .. "_"
        if rawKey:sub(1, #prefixText) == prefixText then
            local localKey = rawKey:sub(#prefixText + 1)
            return defaults and defaults[localKey] ~= nil
        end
    end
    return false
end

function RheaConfig.read(prefix, defaults)
    local cfg = {}
    for key, value in pairs(defaults or {}) do
        local globalKey = RheaConfig.key(prefix, key)
        if current_config[globalKey] == nil then current_config[globalKey] = value end
        cfg[key] = current_config[globalKey]
    end
    return cfg
end

function RheaConfig.write(prefix, updates, defaults)
    local cfg = RheaConfig.read(prefix, defaults)
    for key, value in pairs(updates or {}) do
        if not defaults or defaults[key] ~= nil then
            current_config[RheaConfig.key(prefix, key)] = value
            cfg[key] = value
        else
            current_config[RheaConfig.key(prefix, key)] = nil
        end
    end
    saveGlobalConfig()
    return cfg
end

function RheaConfig.section(prefix, defaults)
    local section = {
        read = function() return RheaConfig.read(prefix, defaults) end,
        write = function(updates) return RheaConfig.write(prefix, updates, defaults) end,
        defaults = defaults,
    }
    RheaConfig.defaults[prefix] = defaults
    RheaConfig.sections[prefix] = section
    return section
end

function RheaFoundation.nextMarkerSeq(current, used)
    used = used or {}
    local id = (tonumber(current) or 0) + 1
    if id > 9999 then id = 1 end
    while used[id] do
        id = id + 1
        if id > 9999 then id = 1 end
    end
    used[id] = true
    return id, id
end

function RheaFoundation.stampMarker(line, prefix, seq)
    line.effect = line.effect or ""
    local pat = "%[" .. prefix .. "%-%d+%]"
    local cleaned = FunctionalString.trim(line.effect:gsub(pat, "")):gsub("%s+", " ")
    local tag = string.format("[%s-%03d]", prefix, seq)
    line.effect = cleaned ~= "" and (tag .. " " .. cleaned) or tag
end

function RheaFoundation.markerTools(prefix)
    local seq = 0
    local tools = {}
    function tools.next(used)
        local id
        seq, id = RheaFoundation.nextMarkerSeq(seq, used)
        return id
    end
    function tools.reset()
        seq = 0
    end
    function tools.stamp(line, markerID)
        RheaFoundation.stampMarker(line, prefix, tonumber(markerID) or tools.next())
    end
    function tools.read(line)
        return Rhea.readMarker(line, prefix)
    end
    return tools
end

function RheaFoundation.choose(value, items, defaultValue)
    for _, item in ipairs(items or {}) do
        if value == item then return value end
    end
    return defaultValue or items and items[1]
end

function RheaFoundation.chooseAlias(value, aliases, items, defaultValue)
    local aliased = aliases and aliases[tostring(value or "")] or value
    return RheaFoundation.choose(aliased, items, defaultValue)
end

function RheaFoundation.selectionEffectGroups(subs, sel)
    local groups, order = {}, {}
    for _, i in ipairs(sel or {}) do
        local line = subs[i]
        if Rhea.isDialogue(line) then
            local effect = Rhea.trim(tostring(line.effect or ""))
            local key = "effect:" .. effect
            local group = groups[key]
            if not group then
                group = { key = key, effect = effect, source = i, targets = {}, indices = { i } }
                groups[key] = group
                order[#order + 1] = group
            else
                group.targets[#group.targets + 1] = i
                group.indices[#group.indices + 1] = i
            end
        end
    end
    return order
end

function RheaFoundation.selectionDialogueIndices(subs, sel)
    local indices = {}
    for _, i in ipairs(sel or {}) do
        if Rhea.isDialogue(subs[i]) then indices[#indices + 1] = i end
    end
    return indices
end

function RheaFoundation.selectionCopyGroups(subs, sel)
    local runGroups, skipped = {}, 0
    for _, group in ipairs(RheaFoundation.selectionEffectGroups(subs, sel)) do
        if #group.targets > 0 then
            runGroups[#runGroups + 1] = group
        else
            skipped = skipped + #group.indices
        end
    end
    if #runGroups == 0 then
        local indices = RheaFoundation.selectionDialogueIndices(subs, sel)
        if #indices >= 2 then
            local targets = {}
            for n = 2, #indices do targets[#targets + 1] = indices[n] end
            runGroups[1] = { key = "selection:first", effect = "", source = indices[1], targets = targets, indices = indices }
            skipped = 0
        end
    end
    return runGroups, skipped
end

function RheaFoundation.selectionAfterDeletedLines(sel, deleted)
    local deletedSet, deletedNums = {}, {}
    for _, item in ipairs(deleted or {}) do
        local n = type(item) == "table" and tonumber(item.number) or tonumber(item)
        if n then
            deletedSet[n] = true
            deletedNums[#deletedNums + 1] = n
        end
    end
    if #deletedNums == 0 then return sel or {} end
    table.sort(deletedNums)
    local out = {}
    for _, rawIndex in ipairs(sel or {}) do
        local index = tonumber(rawIndex)
        if index and not deletedSet[index] then
            local shift = 0
            for _, deletedIndex in ipairs(deletedNums) do
                if deletedIndex < index then shift = shift + 1 else break end
            end
            out[#out + 1] = index - shift
        end
    end
    return out
end

function RheaFoundation.tagValue(tag, defaultValue)
    if type(tag) == "table" then
        local n = tonumber(tag.value)
        if n == nil then n = tonumber(tag.dim_value) end
        if n ~= nil then return n end
    end
    return defaultValue
end

function RheaFoundation.setTagValue(tag, value)
    if type(tag) ~= "table" then return end
    local n = tonumber(value) or 0
    tag.value = n
    tag.dim_value = n
end

function RheaFoundation.syncDimTags(tags)
    if type(tags) ~= "table" then return tags end
    for _, name in ipairs({"align", "scale_x", "scale_y", "angle", "angle_x", "angle_y", "shear_x", "shear_y", "fontsize", "outline_x", "outline_y", "shadow_x", "shadow_y"}) do
        if type(tags[name]) == "table" then RheaFoundation.setTagValue(tags[name], RheaFoundation.tagValue(tags[name], 0)) end
    end
    return tags
end

function RheaFoundation.assNumber(n)
    n = tonumber(n)
    if not n then return "0" end
    return tostring(Rhea.roundTo(n))
end

function RheaFoundation.configNumber(value, defaultValue, minValue, maxValue)
    local n = tonumber(value)
    if n == nil then n = tonumber(defaultValue) or 0 end
    if minValue ~= nil and n < minValue then n = minValue end
    if maxValue ~= nil and n > maxValue then n = maxValue end
    return n
end

function RheaFoundation.mapNumbers(text, fn)
    return tostring(text or ""):gsub("([%+%-]?%d+%.?%d*[eE]?[%+%-]?%d*)", function(n)
        local v = tonumber(n)
        return v and tostring(fn(v)) or n
    end)
end

function RheaFoundation.transformTag(t1, t2, tags, accel)
    tags = tostring(tags or "")
    if tags == "" then return "" end
    t1 = math.floor((tonumber(t1) or 0) + 0.5)
    t2 = math.floor((tonumber(t2) or 0) + 0.5)
    if t2 < t1 then t1, t2 = t2, t1 end
    if accel and accel > 0 and accel ~= 1 then
        return string.format("\\t(%d,%d,%.3f,%s)", t1, t2, accel, tags)
    end
    return string.format("\\t(%d,%d,%s)", t1, t2, tags)
end

function RheaFoundation.sanitizeAlpha(a, defaultAlpha)
    local fallback = tostring(defaultAlpha or "80"):upper():match("^%x%x$") or "80"
    local value = tostring(a or ""):upper()
    return value:match("^%x%x$") or value:match("^&H(%x%x)&$") or value:match("(%x%x)") or fallback
end

function RheaFoundation.layerOf(line)
    return tonumber(line and line.layer) or 0
end

function RheaFoundation.segmentLength(segment)
    if not segment then return 0 end
    local dx, dy = segment.x2 - segment.x1, segment.y2 - segment.y1
    return math.sqrt(dx * dx + dy * dy)
end

function RheaFoundation.atan2(dy, dx)
    dy, dx = tonumber(dy) or 0, tonumber(dx) or 0
    if math.atan2 then return math.atan2(dy, dx) end
    if dx > 0 then return math.atan(dy / dx) end
    if dx < 0 and dy >= 0 then return math.atan(dy / dx) + math.pi end
    if dx < 0 then return math.atan(dy / dx) - math.pi end
    if dy > 0 then return math.pi / 2 end
    if dy < 0 then return -math.pi / 2 end
    return 0
end

function RheaFoundation.segmentAngle(segment)
    if not segment then return 0 end
    local dx, dy = segment.x2 - segment.x1, segment.y2 - segment.y1
    return math.deg(RheaFoundation.atan2(dy, dx))
end

function RheaFoundation.distanceToSegment(px, py, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local len2 = dx * dx + dy * dy
    if len2 == 0 then
        local ddx, ddy = px - x1, py - y1
        return math.sqrt(ddx * ddx + ddy * ddy), x1, y1
    end
    local t = ((px - x1) * dx + (py - y1) * dy) / len2
    t = math.max(0, math.min(1, t))
    local bx, by = x1 + t * dx, y1 + t * dy
    local ddx, ddy = px - bx, py - by
    return math.sqrt(ddx * ddx + ddy * ddy), bx, by
end

function RheaFoundation.bezierPoint(t, p0, p1, p2, p3)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t
    return {
        x = uuu * p0.x + 3 * uu * t * p1.x + 3 * u * tt * p2.x + ttt * p3.x,
        y = uuu * p0.y + 3 * uu * t * p1.y + 3 * u * tt * p2.y + ttt * p3.y,
    }
end

function RheaFoundation.bezierDerivative(t, p0, p1, p2, p3)
    local u = 1 - t
    local uu = u * u
    local tt = t * t
    return {
        x = 3 * uu * (p1.x - p0.x) + 6 * u * t * (p2.x - p1.x) + 3 * tt * (p3.x - p2.x),
        y = 3 * uu * (p1.y - p0.y) + 6 * u * t * (p2.y - p1.y) + 3 * tt * (p3.y - p2.y),
    }
end

function RheaFoundation.samplePath(cmds, segments, atan2fn)
    local pts = {}
    local cur = {x=0, y=0}
    local atan = atan2fn or RheaFoundation.atan2
    segments = math.max(1, tonumber(segments) or 30)
    for _, cmd in ipairs(cmds or {}) do
        if cmd.type == "m" and #cmd.pts >= 2 then
            cur = {x = cmd.pts[1], y = cmd.pts[2]}
            pts[#pts + 1] = {p = cur, dist = 0, angle = 0}
        elseif cmd.type == "l" then
            if #pts == 0 then pts[#pts + 1] = {p = cur, dist = 0, angle = 0} end
            for i=1, #cmd.pts - 1, 2 do
                local nx, ny = cmd.pts[i], cmd.pts[i+1]
                local dx, dy = nx - cur.x, ny - cur.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist > 0 then
                    local ang = atan(dy, dx)
                    for j=1, segments do
                        local t = j / segments
                        pts[#pts + 1] = {p = {x=cur.x + dx * t, y=cur.y + dy * t}, dist = dist / segments, angle = ang}
                    end
                end
                cur = {x = nx, y = ny}
            end
        elseif cmd.type == "b" then
            if #pts == 0 then pts[#pts + 1] = {p = cur, dist = 0, angle = 0} end
            for i=1, #cmd.pts - 5, 6 do
                local p1 = {x = cmd.pts[i], y = cmd.pts[i+1]}
                local p2 = {x = cmd.pts[i+2], y = cmd.pts[i+3]}
                local p3 = {x = cmd.pts[i+4], y = cmd.pts[i+5]}
                for j=1, segments do
                    local t = j / segments
                    local pt = RheaFoundation.bezierPoint(t, cur, p1, p2, p3)
                    local dp = RheaFoundation.bezierDerivative(t, cur, p1, p2, p3)
                    local prev = pts[#pts] and pts[#pts].p or cur
                    pts[#pts + 1] = {
                        p = pt,
                        dist = math.sqrt((pt.x - prev.x)^2 + (pt.y - prev.y)^2),
                        angle = atan(dp.y, dp.x),
                    }
                end
                cur = p3
            end
        end
    end
    local totalDist = 0
    for i=2, #pts do
        totalDist = totalDist + pts[i].dist
        pts[i].accDist = totalDist
    end
    if #pts > 0 then pts[1].accDist = 0 end
    return pts, totalDist
end

function RheaFoundation.pathSegments(cmds, segments)
    local sampled, totalLen = RheaFoundation.samplePath(cmds, segments or 30)
    local segs = {}
    if not sampled or totalLen <= 0 then return segs end
    for i = 2, #sampled do
        local a, b = sampled[i - 1], sampled[i]
        if a and b and a.p and b.p and (b.dist or 0) > 0 then
            local dx, dy = b.p.x - a.p.x, b.p.y - a.p.y
            if dx * dx + dy * dy > 0 then
                segs[#segs + 1] = {x1 = a.p.x, y1 = a.p.y, x2 = b.p.x, y2 = b.p.y}
            end
        end
    end
    return segs
end

function RheaFoundation.firstPathSegments(cmds, count, bezierSegments)
    local out = {}
    local cur = nil
    local steps = math.max(1, tonumber(bezierSegments) or 8)
    for _, cmd in ipairs(cmds or {}) do
        if cmd.type == "m" and #cmd.pts >= 2 then
            cur = { x = cmd.pts[1], y = cmd.pts[2] }
        elseif cmd.type == "l" and cur then
            for i = 1, #cmd.pts - 1, 2 do
                local nx, ny = cmd.pts[i], cmd.pts[i + 1]
                if nx and ny and (nx ~= cur.x or ny ~= cur.y) then
                    out[#out + 1] = { x1 = cur.x, y1 = cur.y, x2 = nx, y2 = ny }
                    if #out >= count then return out end
                end
                cur = { x = nx, y = ny }
            end
        elseif cmd.type == "b" and cur then
            for i = 1, #cmd.pts - 5, 6 do
                local p1 = { x = cmd.pts[i], y = cmd.pts[i + 1] }
                local p2 = { x = cmd.pts[i + 2], y = cmd.pts[i + 3] }
                local p3 = { x = cmd.pts[i + 4], y = cmd.pts[i + 5] }
                local prev = cur
                for step = 1, steps do
                    local pt = RheaFoundation.bezierPoint(step / steps, cur, p1, p2, p3)
                    if pt.x ~= prev.x or pt.y ~= prev.y then
                        out[#out + 1] = { x1 = prev.x, y1 = prev.y, x2 = pt.x, y2 = pt.y }
                        if #out >= count then return out end
                    end
                    prev = pt
                end
                cur = p3
            end
        end
    end
    return out
end

function RheaFoundation.pointOnPath(sampled, targetDist)
    if #sampled == 0 then return nil end
    if targetDist <= 0 then return sampled[1] end
    if targetDist >= sampled[#sampled].accDist then return sampled[#sampled] end
    for i=2, #sampled do
        if sampled[i].accDist >= targetDist then
            local p1, p2 = sampled[i-1], sampled[i]
            local d = p2.accDist - p1.accDist
            if d == 0 then return p2 end
            local t = (targetDist - p1.accDist) / d
            return {
                p = {
                    x = p1.p.x + (p2.p.x - p1.p.x) * t,
                    y = p1.p.y + (p2.p.y - p1.p.y) * t,
                },
                angle = p1.angle + (p2.angle - p1.angle) * t,
            }
        end
    end
    return sampled[#sampled]
end

function RheaFoundation.replaceNumericTagValue(text, tag, factor, formatter)
    formatter = formatter or Rhea.formatNum
    return (tostring(text or ""):gsub("\\" .. tag .. "(%-?[%d%.]+)", function(v)
        local n = tonumber(v)
        if not n then return nil end
        return "\\" .. tag .. formatter(n * factor)
    end))
end

function RheaFoundation.rescaleDimensionalTags(text, style, fx, fy, opts, formatter)
    fy = fy or fx
    formatter = formatter or Rhea.formatNum
    local fu = math.sqrt(math.max(fx * fy, 0))
    if fu == 0 then fu = (fx + fy) / 2 end

    local function inject(tag, base_val, factor)
        if text:match("\\" .. tag .. "%-?[%d%.]+") then
            text = RheaFoundation.replaceNumericTagValue(text, tag, factor, formatter)
        else
            if not base_val or base_val == 0 then return end
            if math.abs(factor - 1) < 1e-4 then return end
            local injected = "\\" .. tag .. formatter(base_val * factor)
            if text:match("^{") then
                text = text:gsub("^{", "{" .. injected, 1)
            else
                text = "{" .. injected .. "}" .. text
            end
        end
    end

    if opts.scale_fs then
        inject("fscx", style.scale_x or 100, fx)
        inject("fscy", style.scale_y or 100, fy)
    end
    if opts.scale_fsp then inject("fsp", style.spacing or 0, fx) end
    if opts.scale_bord then
        inject("bord", style.outline or 0, fu)
        text = RheaFoundation.replaceNumericTagValue(text, "xbord", fx, formatter)
        text = RheaFoundation.replaceNumericTagValue(text, "ybord", fy, formatter)
    end
    if opts.scale_shad then
        inject("shad", style.shadow or 0, fu)
        text = RheaFoundation.replaceNumericTagValue(text, "xshad", fx, formatter)
        text = RheaFoundation.replaceNumericTagValue(text, "yshad", fy, formatter)
    end
    if opts.scale_blur then
        if text:match("\\blur") then text = RheaFoundation.replaceNumericTagValue(text, "blur", fu, formatter) end
        if text:match("\\be") then text = RheaFoundation.replaceNumericTagValue(text, "be", fu, formatter) end
    end
    return text
end

function RheaFoundation.applyInlineStyleTags(style, tags)
    local data = RheaFoundation.tryParseLine("{" .. tostring(tags or ""):gsub("[{}]", "") .. "}x")
    if not data then return style end
    local eff = data:getEffectiveTags(-1, false, true, false).tags
    if eff.fontsize then style.fontsize = RheaFoundation.tagValue(eff.fontsize, style.fontsize) end
    if eff.scale_x then style.scale_x = RheaFoundation.tagValue(eff.scale_x, style.scale_x) end
    if eff.scale_y then style.scale_y = RheaFoundation.tagValue(eff.scale_y, style.scale_y) end
    if eff.spacing then style.spacing = RheaFoundation.tagValue(eff.spacing, style.spacing) end
    return style
end

function RheaFoundation.cleanByMarker(subs, sel, scope, prefix, confirmFmt, emptyMsg, undoLabel)
    local pool = {}
    if scope == "all" then
        for i = 1, #subs do pool[#pool + 1] = i end
    else
        for _, i in ipairs(sel or {}) do pool[#pool + 1] = i end
    end
    local lines = LineCollection(subs, pool)
    local toDelete = {}
    lines:runCallback(function(_, line)
        if Rhea.readMarker(line, prefix) then toDelete[#toDelete + 1] = line end
    end)
    if #toDelete == 0 then
        if emptyMsg then showMsg(emptyMsg) end
        return sel, false
    end
    if confirmFmt then
        local delete, cancel = L("btn_delete"), L("btn_cancel")
        local btn = aegisub.dialog.display(
            {{class="label", label=string.format(confirmFmt, #toDelete)}},
            {delete, cancel})
        if btn ~= delete then return sel, false end
    end
    lines:deleteLines(toDelete)
    local label = type(undoLabel) == "function" and undoLabel(#toDelete) or undoLabel
    aegisub.set_undo_point(label or string.format("Rhea Signs: clean %s markers", prefix))
    return RheaFoundation.selectionAfterDeletedLines(sel, toDelete), true, #toDelete
end

local function sortedLineEntries(map)
    local entries = {}
    for line, newLines in pairs(map or {}) do
        if newLines and newLines.class then newLines = { newLines } end
        if type(newLines) == "table" and #newLines > 0 then
            entries[#entries + 1] = { line = line, newLines = newLines }
        end
    end
    table.sort(entries, function(a, b) return a.line.number < b.line.number end)
    return entries
end

function RheaFoundation.replaceCollectedLines(lines, replacements, selectLast)
    local toDelete = {}
    local deletedBefore, insertedBefore = 0, 0
    for _, entry in ipairs(sortedLineEntries(replacements)) do
        local insertAt = entry.line.number - deletedBefore + insertedBefore
        for i, newLine in ipairs(entry.newLines) do
            local selected = selectLast == nil and true or (selectLast and i == #entry.newLines)
            lines:addLine(newLine, function() return true end, selected, insertAt + i - 1)
        end
        toDelete[#toDelete + 1] = entry.line
        deletedBefore = deletedBefore + 1
        insertedBefore = insertedBefore + #entry.newLines
    end
    lines:deleteLines(toDelete, false)
    lines:insertLines()
    local newSel = lines:getSelection()
    return #newSel > 0 and newSel or nil
end

function RheaFoundation.insertCollectedLinesAfter(lines, additions, selectLast)
    lines:replaceLines()
    local insertedBefore = 0
    for _, entry in ipairs(sortedLineEntries(additions)) do
        local insertAt = entry.line.number + insertedBefore + 1
        for i, newLine in ipairs(entry.newLines) do
            local selected = selectLast == nil and true or (selectLast and i == #entry.newLines)
            lines:addLine(newLine, function() return true end, selected, insertAt + i - 1)
        end
        insertedBefore = insertedBefore + #entry.newLines
    end
    lines:insertLines()
    local newSel = lines:getSelection()
    return #newSel > 0 and newSel or nil
end


local RheaOps = {
    Perspective = {},
    Animation = {},
    Masks = {},
    Sign = {},
    Colors = {},
    Tools = {},
    TagOps = { U = {} },
}

-- RheaOps.Perspective
do
local Quad, transformPoints, tagsFromQuad = ArchPersp.Quad, ArchPersp.transformPoints, ArchPersp.tagsFromQuad
local prepareForPerspective = ArchPersp.prepareForPerspective


local DEFAULTS = {
    mode = "Copy w/ corner swap", map = "ABCD (exact copy)",
    orgm = "3 minimize fax",
    set_sx = false, sx = 100, set_sy = false, sy = 100, qscale = 100,
    remove_persp_clip = true,
    rescale_mode = "Fit (uniform)", remove_clip = true, recenter = true,
    scale_fs = true, scale_bord = true, scale_shad = true,
    scale_blur = true, scale_fsp = true,
}

local MODE_ITEMS = {
    "Copy Exact (same plane)",
    "Copy Static Plane (keep \\pos)",
    "Copy Move Plane (whole plane)",
    "Copy w/ corner swap",
    "Mass FSC (lock quad)",
    "Scale Quad (3D Box)",
    "Clip to Persp",
    "Rescale to Clip",
    "Bake Extradata",
    "Restore Extradata",
    "Identity reproject",
}

local ORG_ITEMS = {"1 keep dst org", "2 quad center", "3 minimize fax"}
local RESCALE_ITEMS = {"Fit (uniform)", "Fill (uniform)", "Stretch (per-axis)"}

local LAYOUT_SCALE = 1
local LAYOUT_SCALE_INFO = { scale = 1 }
local PK_LAYOUT_WARNED = {}

local function compute_layout_scale(meta)
    meta = meta or {}
    local play_y = tonumber(meta.PlayResY or meta.playresy or meta.res_y)
    local layout_y = tonumber(meta.LayoutResY or meta.layoutresy)
    local source = layout_y and "LayoutResY" or "video height"
    if not layout_y and aegisub.video_size then
        local ok, _, video_y = pcall(aegisub.video_size)
        if ok then layout_y = tonumber(video_y) end
    end
    local scale = 1
    if play_y and layout_y and play_y > 0 and layout_y > 0 then
        scale = play_y / layout_y
    end
    LAYOUT_SCALE_INFO = {
        scale = scale,
        play_y = play_y,
        layout_y = layout_y,
        source = source,
    }
    return scale
end

local function perspective_mode_uses_layout_scale(mode)
    return mode == "Clip to Persp"
        or mode == "Scale Quad (3D Box)"
        or mode == "Identity reproject"
        or mode == "Mass FSC (lock quad)"
        or (type(mode) == "string" and mode:match("^Copy") ~= nil)
end

local function layout_warning_key()
    local filename = ""
    if aegisub.file_name then
        local ok, name = pcall(aegisub.file_name)
        if ok then filename = tostring(name or "") end
    end
    local info = LAYOUT_SCALE_INFO or {}
    return table.concat({
        filename,
        tostring(info.play_y or ""),
        tostring(info.layout_y or ""),
        tostring(info.source or ""),
    }, "|")
end

local function confirm_layout_scale()
    local info = LAYOUT_SCALE_INFO or {}
    local scale = tonumber(info.scale) or 1
    if math.abs(scale - 1) < 0.0001 then return true end
    local key = layout_warning_key()
    if PK_LAYOUT_WARNED[key] then return true end

    local detail
    if info.source == "LayoutResY" then
        detail = string.format(L("msg_layout_mismatch_layout"),
            tostring(info.layout_y or "?"), tostring(info.play_y or "?"))
    else
        detail = string.format(L("msg_layout_mismatch_play"),
            tostring(info.play_y or "?"), tostring(info.layout_y or "?"))
    end
    local msg = detail
        .. string.format("\n\n" .. L("msg_layout_depth_scale"), scale)
        .. "\n\n" .. L("msg_layout_recommended")
        .. "\n\n" .. L("msg_continue_anyway")

    local continue = L("btn_continue")
    local cancel = L("btn_cancel")
    local pressed = aegisub.dialog.display(
        {{class="label", label=msg, x=0, y=0, width=72, height=8}},
        {cancel, continue},
        {cancel=cancel, close=cancel, ok=continue}
    )
    if pressed ~= continue then return false end
    PK_LAYOUT_WARNED[key] = true
    return true
end

local PK_CONFIG = RheaConfig.section("pk", DEFAULTS)


local function dim_tag(v)
    v = tonumber(v) or 0
    return { value = v, dim_value = v }
end

local function perspective_meta(meta)
    meta = meta or {}
    local out = {}
    for k, v in pairs(meta) do out[k] = v end
    out.PlayResX = tonumber(out.PlayResX or out.playresx or out.res_x) or 1920
    out.PlayResY = tonumber(out.PlayResY or out.playresy or out.res_y) or 1080
    if out.LayoutResY == nil then out.LayoutResY = out.layoutresy end
    return out
end

local function perspective_style(style, name)
    local out = {}
    if type(style) == "table" then
        for k, v in pairs(style) do out[k] = v end
    end
    local raw = out.raw
    out.class = out.class or "style"
    out.name = out.name or name or "Default"
    out.fontname = out.fontname or "Arial"
    out.fontsize = tonumber(out.fontsize) or 20
    out.scale_x = tonumber(out.scale_x) or 100
    out.scale_y = tonumber(out.scale_y) or 100
    out.angle = tonumber(out.angle) or 0
    out.spacing = tonumber(out.spacing) or 0
    out.outline = tonumber(out.outline) or 0
    out.shadow = tonumber(out.shadow) or 0
    out.margin_l = tonumber(out.margin_l) or 0
    out.margin_r = tonumber(out.margin_r) or 0
    out.margin_t = tonumber(out.margin_t or out.margin_v) or 0
    out.align = tonumber(out.align) or 5
    out.bold = out.bold or false
    out.italic = out.italic or false
    out.underline = out.underline or false
    out.strikeout = out.strikeout or false
    out.color1 = out.color1 or "&H00FFFFFF"
    out.color2 = out.color2 or "&H00FFFFFF"
    out.color3 = out.color3 or "&H00000000"
    out.color4 = out.color4 or "&H00000000"
    out.raw = raw or table.concat({
        out.name, out.fontname, out.fontsize, out.scale_x, out.scale_y, out.angle,
        out.spacing, out.outline, out.shadow, out.margin_l, out.margin_r, out.margin_t,
        out.align, tostring(out.bold), tostring(out.italic), tostring(out.underline),
        tostring(out.strikeout), out.color1, out.color2, out.color3, out.color4,
    }, "|")
    return out
end

local function perspective_styles(styles, lineStyle, style)
    local out = {}
    if type(styles) == "table" then
        for name, st in pairs(styles) do
            if type(st) == "table" then
                out[name] = perspective_style(st, name)
            end
        end
    end
    local styleName = lineStyle or (type(style) == "table" and style.name) or "Default"
    out[styleName] = perspective_style(type(style) == "table" and style or out[styleName], styleName)
    if not out.Default then out.Default = out[styleName] end
    return out
end

local function line_for_perspective(line, style, meta, styles)
    local copy = {}
    for k, v in pairs(line or {}) do copy[k] = v end
    copy.text = tostring(copy.text or "")
    copy.style = copy.style or (type(style) == "table" and style.name) or "Default"
    local pstyles = perspective_styles(styles, copy.style, style)
    copy.styleRef = pstyles[copy.style] or pstyles.Default
    copy.parentCollection = {
        meta = perspective_meta(meta),
        styles = pstyles,
    }
    return copy
end

local function build_tags(line, style, meta, styles)
    local data = RheaFoundation.parseLine(line_for_perspective(line, style, meta, styles))
    local eff  = data:getEffectiveTags(-1, true, true, true).tags
    local pos  = eff.position or { x = 640, y = 360 }
    local org  = eff.origin or pos
    return {
        align     = eff.align    or dim_tag(style and style.align or 5),
        scale_x   = eff.scale_x  or dim_tag(style and style.scale_x or 100),
        scale_y   = eff.scale_y  or dim_tag(style and style.scale_y or 100),
        angle     = eff.angle    or dim_tag(style and style.angle or 0),
        angle_x   = eff.angle_x  or dim_tag(0),
        angle_y   = eff.angle_y  or dim_tag(0),
        shear_x   = eff.shear_x  or dim_tag(0),
        shear_y   = eff.shear_y  or dim_tag(0),
        fontsize  = eff.fontsize or dim_tag(style and style.fontsize or 20),
        position  = { x = pos.x, y = pos.y },
        origin    = { x = org.x, y = org.y },
        outline_x = eff.outline_x or eff.outline or dim_tag(style and style.outline or 0),
        outline_y = eff.outline_y or eff.outline or dim_tag(style and style.outline or 0),
        shadow_x  = eff.shadow_x or eff.shadow or dim_tag(style and style.shadow or 0),
        shadow_y  = eff.shadow_y or eff.shadow or dim_tag(style and style.shadow or 0),
    }
end

local function serialize_into(line, t)
    RheaFoundation.syncDimTags(t)
    local stripped = RheaFoundation.removeTags(line.text,
        {"fr","frx","fry","frz","fax","fay","fscx","fscy","pos","org"})
    local s = string.format(
        "\\frx%.4f\\fry%.4f\\frz%.4f\\fax%.6f\\fay%.6f\\fscx%.4f\\fscy%.4f\\org(%.3f,%.3f)\\pos(%.3f,%.3f)",
        RheaFoundation.tagValue(t.angle_x, 0), RheaFoundation.tagValue(t.angle_y, 0), RheaFoundation.tagValue(t.angle, 0),
        RheaFoundation.tagValue(t.shear_x, 0), RheaFoundation.tagValue(t.shear_y, 0),
        RheaFoundation.tagValue(t.scale_x, 100), RheaFoundation.tagValue(t.scale_y, 100),
        t.origin.x, t.origin.y,
        t.position.x, t.position.y
    )
    if stripped:match("^{") then
        line.text = stripped:gsub("^{", "{" .. s, 1)
    else
        line.text = "{" .. s .. "}" .. stripped
    end
    line.text = line.text:gsub("{}", "")
end

local function parse_plane_points(raw)
    if raw == nil then return nil end
    raw = tostring(raw):gsub("#7C", "|"):gsub("^e", "")
    local pts = {}
    for x, y in raw:gmatch("([%+%-]?[%d%.]+[eE%+%-]*)%s*;%s*([%+%-]?[%d%.]+[eE%+%-]*)") do
        x, y = tonumber(x), tonumber(y)
        if x and y then
            pts[#pts + 1] = {x, y}
            if #pts >= 4 then break end
        end
    end
    return #pts == 4 and pts or nil
end

local function parse_baked_plane(text)
    local body = tostring(text or ""):match("{\\_persp%(([^%)]*)%)}")
    if not body then return nil end
    local nums = {}
    for n in body:gmatch("[%+%-]?[%d%.]+[eE%+%-]*") do
        nums[#nums + 1] = tonumber(n)
        if #nums >= 8 then break end
    end
    if #nums < 8 then return nil end
    return {
        {nums[1], nums[2]},
        {nums[3], nums[4]},
        {nums[5], nums[6]},
        {nums[7], nums[8]},
    }
end

local function plane_extra_string(pts)
    if type(pts) ~= "table" or #pts < 4 then return nil end
    return string.format("%.3f;%.3f|%.3f;%.3f|%.3f;%.3f|%.3f;%.3f",
        pts[1][1], pts[1][2], pts[2][1], pts[2][2],
        pts[3][1], pts[3][2], pts[4][1], pts[4][2])
end

local function plane_marker(pts)
    if type(pts) ~= "table" or #pts < 4 then return nil end
    return string.format("{\\_persp(%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f)}",
        pts[1][1], pts[1][2], pts[2][1], pts[2][2],
        pts[3][1], pts[3][2], pts[4][1], pts[4][2])
end

local function set_plane_extra(line, quad)
    local plane = plane_extra_string(quad)
    if not plane then return false end
    if type(line.extra) ~= "table" then line.extra = {} end
    line.extra["_aegi_perspective_ambient_plane"] = plane
    return true
end


local function bake_extradata(line)
    if type(line.extra) ~= "table" then return false end
    local pts = parse_plane_points(line.extra["_aegi_perspective_ambient_plane"])
    local comment = plane_marker(pts)
    if comment then
        if line.text:match("^{\\_persp%(") then
            line.text = line.text:gsub("^{\\_persp%([^%)]+%)}", comment, 1)
        else
            line.text = comment .. line.text
        end
        return true
    end
    return false
end

local function restore_extradata(line)
    if not line or not line.text then return false end
    local pts = parse_baked_plane(line.text)
    local plane = plane_extra_string(pts)
    if plane then
        if type(line.extra) ~= "table" then line.extra = {} end
        line.extra["_aegi_perspective_ambient_plane"] = plane
        line.text = line.text:gsub("{\\_persp%([^%)]+%)}", "")
        return true
    end
    return false
end



local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge and math.abs(n) < 1e7
end

local function valid_dim(n)
    return finite(n) and n > 0.0001
end

local function valid_quad(q)
    if type(q) ~= "table" then return false end
    local area = 0
    for i = 1, 4 do
        if type(q[i]) ~= "table" or not finite(q[i][1]) or not finite(q[i][2]) then
            return false
        end
        local j = (i % 4) + 1
        if q[j] then area = area + q[i][1] * q[j][2] - q[j][1] * q[i][2] end
    end
    return math.abs(area) > 0.01
end

local function tags_are_finite(tags)
    local scalar_tags = {"scale_x", "scale_y", "angle", "angle_x", "angle_y", "shear_x", "shear_y"}
    for _, name in ipairs(scalar_tags) do
        if not tags[name] or not finite(RheaFoundation.tagValue(tags[name])) then return false end
    end
    return tags.position and tags.origin
        and finite(tags.position.x) and finite(tags.position.y)
        and finite(tags.origin.x) and finite(tags.origin.y)
end

local function apply_tags_from_quad(tags, quad, w, h, orgMode)
    if not valid_quad(quad) or not valid_dim(w) or not valid_dim(h) then
        return false
    end
    RheaFoundation.syncDimTags(tags)
    local ok = pcall(function()
        local Q = Quad{quad[1], quad[2], quad[3], quad[4]}
        tagsFromQuad(tags, Q, w, h, orgMode or 3, LAYOUT_SCALE)
    end)
    if not ok then return false end
    RheaFoundation.syncDimTags(tags)
    return tags_are_finite(tags)
end

local function remove_clip_tag(text)
    return RheaFoundation.removeTags(text, {"clip","iclip"})
end

local function shape_extents_for_perspective(text)
    if not Rhea.isVectorLine(text) then return nil end
    local body = tostring(text or ""):gsub("{[^}]*}", " ")
    local minx, maxx, miny, maxy = math.huge, -math.huge, math.huge, -math.huge
    local found = false
    for sx, sy in body:gmatch("([%+%-]?[%d%.]+[eE%+%-]*)%s+([%+%-]?[%d%.]+[eE%+%-]*)") do
        local x, y = tonumber(sx), tonumber(sy)
        if x and y then
            found = true
            if x < minx then minx = x end
            if x > maxx then maxx = x end
            if y < miny then miny = y end
            if y > maxy then maxy = y end
        end
    end
    if not found then return nil end
    return math.max(maxx - minx, 0.01), math.max(maxy - miny, 0.01)
end

local function measure_style_for_perspective(line, style)
    local s = {}
    for k, v in pairs(style or {}) do s[k] = v end
    local head = tostring(line and line.text or ""):match("^{(.-)}") or ""
    RheaFoundation.applyInlineStyleTags(s, head)
    local fn = head:match("\\fn([^\\}]*)")
    if fn and fn ~= "" then s.fontname = fn end
    local b = head:match("\\b([01])")
    if b then s.bold = (b == "1") end
    local i = head:match("\\i([01])")
    if i then s.italic = (i == "1") end
    return s
end

local function get_extents(line, style, tags)
    local sw, sh = shape_extents_for_perspective(line and line.text)
    if valid_dim(sw) and valid_dim(sh) then return sw, sh end

    local clean = Rhea.visibleText(line and line.text or "")
    if clean == "" or clean:match("^%s*$") then return 100, 100 end

    local measureStyle = measure_style_for_perspective(line, style)
    local ok, w, h = pcall(RheaFoundation.multilineTextExtents, measureStyle, line and line.text or "")
    if not ok or not valid_dim(w) or not valid_dim(h) then return 100, 100 end

    local sx = RheaFoundation.tagValue(tags and tags.scale_x, tonumber(measureStyle.scale_x) or 100)
    local sy = RheaFoundation.tagValue(tags and tags.scale_y, tonumber(measureStyle.scale_y) or 100)
    if valid_dim(sx) then w = w / (sx / 100) end
    if valid_dim(sy) then h = h / (sy / 100) end
    if not valid_dim(w) or not valid_dim(h) then return 100, 100 end
    return math.max(w, 0.01), math.max(h, 0.01)
end

local function prepare_tags_for_perspective(line, style, meta, styles)
    local data = RheaFoundation.parseLine(line_for_perspective(line, style, meta, styles))
    if type(prepareForPerspective) == "function" then
        local ok, tags, w, h = pcall(prepareForPerspective, ASS, data)
        if ok and tags and valid_dim(w) and valid_dim(h) then
            if tostring(line and line.text or ""):find("\\N", 1, true)
                or tostring(line and line.text or ""):find("\\n", 1, true) then
                local mw, mh = get_extents(line, style, tags)
                if valid_dim(mw) and valid_dim(mh) then w, h = mw, mh end
            end
            return tags, w, h
        end
    end
    local tags = build_tags(line, style, meta, styles)
    local w, h = get_extents(line, style, tags)
    return tags, w, h
end

local function build_quad_for(line, style, meta, styles)
    local t, w, h = prepare_tags_for_perspective(line, style, meta, styles)
    RheaFoundation.syncDimTags(t)
    local pts = transformPoints(t, w, h, nil, LAYOUT_SCALE)
    local q = {}
    for i = 1, 4 do q[i] = {pts[i][1], pts[i][2]} end
    return q, t, w, h
end

local function safe_build_quad_for(line, style, meta, styles)
    if not line or not style or not line.text then return nil end
    local ok, q, t, w, h = pcall(build_quad_for, line, style, meta, styles)
    if not ok then return nil end
    if not valid_quad(q) or not valid_dim(w) or not valid_dim(h) then
        return nil
    end
    return q, t, w, h
end

local function get_quad_center(q)
    local cx, cy = 0, 0
    for i=1,4 do cx=cx+q[i][1]; cy=cy+q[i][2] end
    return cx/4, cy/4
end

local function scale_quad(q, scale_pct)
    local cx, cy = get_quad_center(q)
    local f = scale_pct / 100
    local nq = {}
    for i=1,4 do
        nq[i] = {
            cx + (q[i][1] - cx) * f,
            cy + (q[i][2] - cy) * f
        }
    end
    return nq
end

local MAPPINGS = {
    {"ABCD (exact copy)",  {1,2,3,4}},
    {"BADC (h-mirror)",    {2,1,4,3}},
    {"DCBA (v-mirror)",    {4,3,2,1}},
    {"CDAB (rot 180)",     {3,4,1,2}},
    {"BCDA (rot 90 CW)",   {2,3,4,1}},
    {"DABC (rot 90 CCW)",  {4,1,2,3}},
    {"ABDC (swap CD)",     {1,2,4,3}},
    {"BACD (swap AB)",     {2,1,3,4}},
    {"AB src + CD dst",    "AB_src_CD_dst"},
    {"CD src + AB dst",    "CD_src_AB_dst"},
    {"AC src + BD dst",    "AC_src_BD_dst"},
    {"BD src + AC dst",    "BD_src_AC_dst"},
}

local function map_names()
    return FunctionalList.map(MAPPINGS, function(v) return v[1] end)
end

local function find_mapping(name)
    for _, v in ipairs(MAPPINGS) do
        if v[1] == name then return v[2] end
    end
    return {1,2,3,4}
end

local function normalizePerspectiveMode(mode)
    if type(mode) == "string" and mode:find("Copy Exact", 1, true) then
        return "Copy Exact (same plane)"
    end
    if type(mode) == "string" and (mode:find("Copy Static Plane", 1, true) or mode:find("Copy Translate", 1, true)) then
        return "Copy Static Plane (keep \\pos)"
    end
    if type(mode) == "string" and (mode:find("Copy Move Plane", 1, true) or mode:find("Copy Transport", 1, true)) then
        return "Copy Move Plane (whole plane)"
    end
    return mode
end

local function normalizePerspectiveMap(name)
    name = tostring(name or "")
    if name:find("^ABCD") then return "ABCD (exact copy)" end
    if name:find("^BADC") then return "BADC (h-mirror)" end
    if name:find("^DCBA") then return "DCBA (v-mirror)" end
    if name:find("^CDAB") then return "CDAB (rot 180)" end
    if name:find("^BCDA") then return "BCDA (rot 90 CW)" end
    if name:find("^DABC") then return "DABC (rot 90 CCW)" end
    if name:find("^ABDC") then return "ABDC (swap CD)" end
    if name:find("^BACD") then return "BACD (swap AB)" end
    if name:find("^AB src") or name:find("^AB source") then return "AB src + CD dst" end
    if name:find("^CD src") or name:find("^CD source") then return "CD src + AB dst" end
    if name:find("^AC src") or name:find("^AC source") then return "AC src + BD dst" end
    if name:find("^BD src") or name:find("^BD source") then return "BD src + AC dst" end
    return name
end

local function remap_quad(src_q, dst_q, m)
    if type(m) == "string" then
        if m == "AB_src_CD_dst" then return {src_q[1], src_q[2], dst_q[3], dst_q[4]}
        elseif m == "CD_src_AB_dst" then return {dst_q[1], dst_q[2], src_q[3], src_q[4]}
        elseif m == "AC_src_BD_dst" then return {src_q[1], dst_q[2], src_q[3], dst_q[4]}
        elseif m == "BD_src_AC_dst" then return {dst_q[1], src_q[2], dst_q[3], src_q[4]}
        end
    end
    return {src_q[m[1]], src_q[m[2]], src_q[m[3]], src_q[m[4]]}
end

local function copy_tag_value(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, value in pairs(v) do out[k] = value end
    return out
end

local PERSPECTIVE_COPY_TAGS = {"angle", "angle_x", "angle_y", "shear_x", "shear_y", "scale_x", "scale_y"}

local function copy_perspective_state(dst, src)
    for _, key in ipairs(PERSPECTIVE_COPY_TAGS) do
        dst[key] = copy_tag_value(src[key])
    end
end

local function quad_from_tags(tags, w, h)
    if not valid_dim(w) or not valid_dim(h) then return nil end
    RheaFoundation.syncDimTags(tags)
    local ok, pts = pcall(transformPoints, tags, w, h, nil, LAYOUT_SCALE)
    if not ok or type(pts) ~= "table" then return nil end
    local q = {}
    for i = 1, 4 do
        if type(pts[i]) ~= "table" then return nil end
        q[i] = {pts[i][1], pts[i][2]}
    end
    return valid_quad(q) and q or nil
end

local function apply_copied_plane(line, tags, w, h, removeClip)
    if not tags_are_finite(tags) then return false end
    local q = quad_from_tags(tags, w, h)
    if not q then return false end
    serialize_into(line, tags)
    set_plane_extra(line, q)
    if removeClip then line.text = remove_clip_tag(line.text) end
    return true
end

local function scale_clip_path(path, scale)
    local factor = 2 ^ ((tonumber(scale) or 1) - 1)
    if factor == 0 then return path end
    return RheaFoundation.mapNumbers(path, function(v) return v / factor end)
end

local function exact_quad_points(pts)
    local out = {}
    for _, p in ipairs(pts or {}) do
        local x, y = tonumber(p and p[1]), tonumber(p and p[2])
        if x and y then out[#out + 1] = {x, y} end
    end
    if #out == 5 then
        local first, last = out[1], out[5]
        if math.abs(first[1] - last[1]) < 0.001 and math.abs(first[2] - last[2]) < 0.001 then
            table.remove(out, 5)
        end
    end
    return #out == 4 and out or nil
end

local function quad_edge_len(a, b)
    local dx, dy = (b[1] or 0) - (a[1] or 0), (b[2] or 0) - (a[2] or 0)
    return math.sqrt(dx * dx + dy * dy)
end

local function rotate_quad(q, startIndex, reversed)
    local out = {}
    for i = 1, 4 do
        local idx
        if reversed then
            idx = ((startIndex - i) % 4) + 1
        else
            idx = ((startIndex + i - 2) % 4) + 1
        end
        out[i] = { q[idx][1], q[idx][2] }
    end
    return out
end

local function quad_area(q)
    local area = 0
    for i = 1, 4 do
        local j = (i % 4) + 1
        area = area + q[i][1] * q[j][2] - q[j][1] * q[i][2]
    end
    return area / 2
end

local function orient_quad_for_extents(q, w, h)
    if not valid_quad(q) then return q end
    local target_aspect = valid_dim(w) and valid_dim(h) and (w / h) or 1
    local best, bestScore
    for _, reversed in ipairs({false, true}) do
        for startIndex = 1, 4 do
            local c = rotate_quad(q, startIndex, reversed)
            local width_len = (quad_edge_len(c[1], c[2]) + quad_edge_len(c[4], c[3])) / 2
            local height_len = (quad_edge_len(c[2], c[3]) + quad_edge_len(c[1], c[4])) / 2
            if width_len > 0 and height_len > 0 then
                local score = math.abs(math.log((width_len / height_len) / target_aspect))
                local top_y = (c[1][2] + c[2][2]) / 2
                local bottom_y = (c[3][2] + c[4][2]) / 2
                if top_y > bottom_y then score = score + 2 end
                if c[1][1] > c[2][1] then score = score + 0.5 end
                if quad_area(c) < 0 then score = score + 0.25 end
                if not bestScore or score < bestScore then
                    best, bestScore = c, score
                end
            end
        end
    end
    return best or q
end

local function quad_bbox_rect(q)
    if not valid_quad(q) then return nil end
    local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
    for i = 1, 4 do
        local x, y = q[i][1], q[i][2]
        if x < minx then minx = x end
        if y < miny then miny = y end
        if x > maxx then maxx = x end
        if y > maxy then maxy = y end
    end
    return minx, miny, maxx, maxy
end

local function quad_bbox_size(q)
    local x1, y1, x2, y2 = quad_bbox_rect(q)
    if not x1 then return nil end
    return x2 - x1, y2 - y1
end

local function scale_quad_xy(q, fx, fy, ax, ay)
    local out = {}
    for i = 1, 4 do
        out[i] = {
            ax + (q[i][1] - ax) * fx,
            ay + (q[i][2] - ay) * fy,
        }
    end
    return out
end

local function translate_quad(q, dx, dy)
    local out = {}
    for i = 1, 4 do out[i] = { q[i][1] + dx, q[i][2] + dy } end
    return out
end

local function apply_quad_mapping(q, mapName)
    local mapping = find_mapping(mapName)
    if type(mapping) ~= "table" then return q end
    return { q[mapping[1]], q[mapping[2]], q[mapping[3]], q[mapping[4]] }
end

local function parse_clip_quad_text(text)
    text = tostring(text or "")
    local scale, c = text:match("\\i?clip%(%s*(%d+)%s*,%s*m%s*([^%)]+)%)")
    if c then c = scale_clip_path(c, scale) end
    if not c then c = text:match("\\i?clip%(%s*m%s*([^%)]+)%)") end
    if not c then
        local x1, y1, x2, y2 = text:match(
            "\\i?clip%(%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*%)")
        x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
        if x1 and y1 and x2 and y2 then
            return exact_quad_points({{x1,y1}, {x2,y1}, {x2,y2}, {x1,y2}})
        end
        return nil
    end
    local pts = {}
    for x, y in c:gmatch("([%d%.%-eE%+]+)%s+([%d%.%-eE%+]+)") do
        pts[#pts + 1] = {tonumber(x), tonumber(y)}
    end
    return exact_quad_points(pts)
end

local function parse_clip_quad(text)
    local ok, clip = pcall(RheaFoundation.firstClipTag, text)
    if ok and clip then
        local q = exact_quad_points(RheaFoundation.clipPoints(clip))
        if q then return q end
    end
    return parse_clip_quad_text(text)
end


local function get_clip_bbox_text(text)
    text = tostring(text or "")
    local x1, y1, x2, y2 = text:match(
        "\\i?clip%(%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*%)")
    if x1 then
        x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
        return math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2)
    end
    local scale, path = text:match("\\i?clip%(%s*(%d+)%s*,%s*m%s*([^%)]+)%)")
    if path then path = scale_clip_path(path, scale) end
    if not path then path = text:match("\\i?clip%(%s*m%s*([^%)]+)%)") end
    if not path then return nil end
    local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
    for sx, sy in path:gmatch("([%+%-]?[%d%.]+[eE%+%-]*)%s+([%+%-]?[%d%.]+[eE%+%-]*)") do
        local x, y = tonumber(sx), tonumber(sy)
        if x and y then
            if x < minx then minx = x end
            if y < miny then miny = y end
            if x > maxx then maxx = x end
            if y > maxy then maxy = y end
        end
    end
    if minx == math.huge then return nil end
    return minx, miny, maxx, maxy
end

local function get_clip_bbox(text)
    local tx1, ty1, tx2, ty2 = get_clip_bbox_text(text)
    if tx1 then return tx1, ty1, tx2, ty2 end
    local ok, clip = pcall(RheaFoundation.firstClipTag, text)
    if ok and clip then
        local x1, y1, x2, y2 = RheaFoundation.clipBBox(clip)
        if x1 then return x1, y1, x2, y2 end
    end
    return nil
end

local function apply_quad(line, tags, quad, w, h, orgMode, removeClip)
    if not apply_tags_from_quad(tags, quad, w, h, orgMode) then
        return false
    end
    serialize_into(line, tags)
    set_plane_extra(line, quad)
    if removeClip then line.text = remove_clip_tag(line.text) end
    return true
end

local function apply_quad_locked_scale(line, tags, quad, w, h, target_fscx, target_fscy, removeClip)
    if (target_fscx and not valid_dim(target_fscx)) or (target_fscy and not valid_dim(target_fscy)) then
        return false
    end
    local probe = {}
    for k, v in pairs(tags) do
        if type(v) == "table" then
            probe[k] = {}
            for k2, v2 in pairs(v) do probe[k][k2] = v2 end
        end
    end
    if not apply_tags_from_quad(probe, quad, w, h, 3) then
        return false
    end
    local nat_sx = RheaFoundation.tagValue(probe.scale_x, 100)
    local nat_sy = RheaFoundation.tagValue(probe.scale_y, 100)
    local fake_w, fake_h = w, h
    if target_fscx then fake_w = w * nat_sx / target_fscx end
    if target_fscy then fake_h = h * nat_sy / target_fscy end
    if not apply_tags_from_quad(tags, quad, fake_w, fake_h, 3) then
        return false
    end
    if target_fscx then RheaFoundation.setTagValue(tags.scale_x, target_fscx) end
    if target_fscy then RheaFoundation.setTagValue(tags.scale_y, target_fscy) end
    if not tags_are_finite(tags) then return false end
    serialize_into(line, tags)
    set_plane_extra(line, quad)
    if removeClip then line.text = remove_clip_tag(line.text) end
    return true
end

local function rescale_line_to_clip(line, style, opts)
    if Rhea.isVectorLine(line.text) then
        return false, "vector"
    end
    opts = opts or {}
    local cx1, cy1, cx2, cy2 = get_clip_bbox(line.text)
    if not cx1 then return false, "no_clip" end
    local clip_w = cx2 - cx1
    local clip_h = cy2 - cy1
    if clip_w <= 0 or clip_h <= 0 then return false, "bad_clip" end

    local perspectiveQuad, tw, th
    if opts.scale_fs and RheaOps.Perspective.isPerspectiveLine(line) then
        local q = safe_build_quad_for(line, style, opts.meta, opts.styles)
        if q then
            local qw, qh = quad_bbox_size(q)
            if valid_dim(qw) and valid_dim(qh) then
                perspectiveQuad, tw, th = q, qw, qh
            end
        end
    end
    if not valid_dim(tw) or not valid_dim(th) then
        tw, th = RheaFoundation.lineBoundsSize(line, nil, style)
    end
    if not valid_dim(tw) or not valid_dim(th) then return false, "no_text" end

    local fx = clip_w / tw
    local fy = clip_h / th
    if opts.mode == "Fit (uniform)" then
        local f = math.min(fx, fy); fx, fy = f, f
    elseif opts.mode == "Fill (uniform)" then
        local f = math.max(fx, fy); fx, fy = f, f
    end

    local originalText = line.text
    local targetQuad
    if perspectiveQuad then
        local an = tonumber(line.text:match("\\an([1-9])")) or style.align or 5
        local qx1, qy1, qx2, qy2 = quad_bbox_rect(perspectiveQuad)
        local ax, ay = RheaFoundation.anchorPointFromAlign(an, qx1, qy1, qx2, qy2)
        targetQuad = scale_quad_xy(perspectiveQuad, fx, fy, ax, ay)
        if opts.recenter then
            local tx, ty = RheaFoundation.anchorPointFromAlign(an, cx1, cy1, cx2, cy2)
            local sx1, sy1, sx2, sy2 = quad_bbox_rect(targetQuad)
            local sx, sy = RheaFoundation.anchorPointFromAlign(an, sx1, sy1, sx2, sy2)
            targetQuad = translate_quad(targetQuad, tx - sx, ty - sy)
        end
    end

    line.text = RheaFoundation.rescaleDimensionalTags(line.text, style, fx, fy, opts, Rhea.formatNum)

    if targetQuad then
        local tags, w, h = prepare_tags_for_perspective(line, style, opts.meta, opts.styles)
        local sx = RheaFoundation.tagValue(tags and tags.scale_x, 100)
        local sy = RheaFoundation.tagValue(tags and tags.scale_y, 100)
        if not tags or not apply_quad_locked_scale(line, tags, targetQuad, w, h, sx, sy, false) then
            line.text = originalText
            return false, "perspective"
        end
    elseif opts.recenter then
        local an = tonumber(line.text:match("\\an([1-9])")) or style.align or 5
        local nx, ny = RheaFoundation.anchorPointFromAlign(an, cx1, cy1, cx2, cy2)
        line.text = RheaFoundation.setPositionTag(line.text, nx, ny, { keepMove = true })
    end

    if opts.remove_clip then
        line.text = remove_clip_tag(line.text)
    end
    return true
end


local function build_styles(subs)
    local meta, styles = karaskel.collect_head(subs, false)
    return meta or {}, styles or {}
end

local function perspective_pick_style(styles, name)
    if type(styles) ~= "table" then return nil end
    local style = styles[name]
    if type(style) ~= "table" then style = styles.Default end
    if type(style) ~= "table" then return nil end
    return style
end

function RheaOps.Perspective.context(subs)
    return build_styles(subs)
end

function RheaOps.Perspective.isPerspectiveLine(line)
    if type(line) ~= "table" then return false end
    if type(line.extra) == "table"
        and parse_plane_points(line.extra["_aegi_perspective_ambient_plane"]) then
        return true
    end
    local text = tostring(line.text or "")
    if parse_baked_plane(text) then return true end
    return text:match("\\frx") ~= nil
        or text:match("\\fry") ~= nil
        or text:match("\\fax") ~= nil
        or text:match("\\fay") ~= nil
end

function RheaOps.Perspective.captureQuad(line, style, meta, styles)
    if not RheaOps.Perspective.isPerspectiveLine(line) then return nil end
    local q = safe_build_quad_for(line, style, meta, styles)
    return q
end

function RheaOps.Perspective.reprojectLineToQuad(line, style, meta, styles, quad, selected)
    if not valid_quad(quad) then return false end
    local tags, w, h = prepare_tags_for_perspective(line, style, meta, styles)
    if not tags or not valid_dim(w) or not valid_dim(h) then return false end
    local target_sx = selected and selected.fscx and RheaFoundation.tagValue(tags.scale_x, 100) or nil
    local target_sy = selected and selected.fscy and RheaFoundation.tagValue(tags.scale_y, 100) or nil
    if target_sx or target_sy then
        return apply_quad_locked_scale(line, tags, quad, w, h, target_sx, target_sy, false)
    end
    return apply_quad(line, tags, quad, w, h, 3, false)
end

local function perspectiveFinish(label, changed, zeroMsg)
    if (tonumber(changed) or 0) <= 0 then
        if zeroMsg and zeroMsg ~= "" then showMsg(zeroMsg) end
        return false
    end
    aegisub.set_undo_point(label)
    return true
end

local function run_copy_mode(subs, sel, styles, res, orgMode, meta)
    local is_exact = res.mode == "Copy Exact (same plane)"
    local is_static = res.mode == "Copy Static Plane (keep \\pos)"
    local is_move_plane = res.mode == "Copy Move Plane (whole plane)"
    if not sel or #sel < 2 then
        showMsg(L("msg_need_two_copy_lines"))
        return false
    end
    local mapping = find_mapping(res.map)
    local removeCopyClip = false
    local pairs_done, groups_done = 0, 0
    local run_groups, skipped = RheaFoundation.selectionCopyGroups(subs, sel)
    if #run_groups == 0 then
        showMsg(L("msg_need_two_copy_lines"))
        return false
    end

    for _, g in ipairs(run_groups) do
            local src_line = subs[g.source]
            local src_style = perspective_pick_style(styles, src_line.style)
            local src_q, src_t = safe_build_quad_for(src_line, src_style, meta, styles)
            if src_q then
                for _, i in ipairs(g.targets) do
                    local line = subs[i]
                    local style = perspective_pick_style(styles, line.style)
                    if style then
                        local dst_q, dst_t, dst_w, dst_h = safe_build_quad_for(line, style, meta, styles)
                        if dst_q then
                            local out_q, applyOrgMode = nil, orgMode
                            if is_exact then
                                copy_perspective_state(dst_t, src_t)
                                dst_t.position = { x = src_t.position.x, y = src_t.position.y }
                                dst_t.origin = { x = src_t.origin.x, y = src_t.origin.y }
                                if apply_copied_plane(line, dst_t, dst_w, dst_h, removeCopyClip) then
                                    subs[i] = line
                                    pairs_done = pairs_done + 1
                                else
                                    skipped = skipped + 1
                                end
                            elseif is_static then
                                copy_perspective_state(dst_t, src_t)
                                dst_t.origin = { x = src_t.origin.x, y = src_t.origin.y }
                                if apply_copied_plane(line, dst_t, dst_w, dst_h, removeCopyClip) then
                                    subs[i] = line
                                    pairs_done = pairs_done + 1
                                else
                                    skipped = skipped + 1
                                end
                            elseif is_move_plane then
                                copy_perspective_state(dst_t, src_t)
                                local dx = dst_t.position.x - src_t.position.x
                                local dy = dst_t.position.y - src_t.position.y
                                dst_t.position = { x = src_t.position.x + dx, y = src_t.position.y + dy }
                                dst_t.origin = { x = src_t.origin.x + dx, y = src_t.origin.y + dy }
                                if apply_copied_plane(line, dst_t, dst_w, dst_h, removeCopyClip) then
                                    subs[i] = line
                                    pairs_done = pairs_done + 1
                                else
                                    skipped = skipped + 1
                                end
                            else
                                out_q = remap_quad(src_q, dst_q, mapping)
                                if apply_quad(line, dst_t, out_q, dst_w, dst_h, applyOrgMode, removeCopyClip) then
                                    subs[i] = line
                                    pairs_done = pairs_done + 1
                                else
                                    skipped = skipped + 1
                                end
                            end
                        else
                            skipped = skipped + 1
                        end
                    else
                        skipped = skipped + 1
                    end
                end
                groups_done = groups_done + 1
            else
                skipped = skipped + 1
            end
    end
    local tag = is_exact and "exact" or (is_static and "static-plane" or (is_move_plane and "move-plane" or "copy"))
    return perspectiveFinish(
        string.format("Rhea Signs - Perspective: %s (%d grupos, %d destinos, %d omitidos)",
            tag, groups_done, pairs_done, skipped),
        pairs_done,
        string.format("Perspective Copy: 0 lines changed (%d groups, %d skipped).", groups_done, skipped)
    )
end

local function pk_dispatch(subs, sel, opts)
    if not subs or not sel or #sel == 0 then return end
    local meta, styles = build_styles(subs)
    LAYOUT_SCALE = compute_layout_scale(meta)
    local C = PK_CONFIG.read()
    C = FunctionalTable.union(opts or {}, C, DEFAULTS)
    C.mode = normalizePerspectiveMode(C.mode)
    C.map = normalizePerspectiveMap(C.map)
    C.mode = RheaFoundation.choose(C.mode, MODE_ITEMS, DEFAULTS.mode)
    C.map = RheaFoundation.choose(C.map, map_names(), DEFAULTS.map)
    C.orgm = RheaFoundation.choose(C.orgm, ORG_ITEMS, DEFAULTS.orgm)
    C.rescale_mode = RheaFoundation.choose(C.rescale_mode, RESCALE_ITEMS, DEFAULTS.rescale_mode)
    PK_CONFIG.write(C)
    local res = C
    local orgMode = tonumber(res.orgm:sub(1,1)) or 3
    if perspective_mode_uses_layout_scale(res.mode) and not confirm_layout_scale() then
        return
    end

    if res.mode == "Bake Extradata" then
        local done = 0
        for _, i in ipairs(sel) do
            local line = subs[i]
            if bake_extradata(line) then
                subs[i] = line
                done = done + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Bake Extradata", done,
            "Bake Extradata: 0 lines changed (no perspective ambient plane data).")
    end
    if res.mode == "Restore Extradata" then
        local done = 0
        for _, i in ipairs(sel) do
            local line = subs[i]
            if restore_extradata(line) then
                subs[i] = line
                done = done + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Restore Extradata", done,
            "Restore Extradata: 0 lines changed (no baked \\_persp marker).")
    end
    if res.mode == "Clip to Persp" then
        local applied, skipped = 0, {}
        for _, i in ipairs(sel) do
            local line = subs[i]
            local style = perspective_pick_style(styles, line.style)
            local pts = parse_clip_quad(line.text)
            if not pts then
                skipped[#skipped + 1] = "no clip quad"
            elseif not style then
                skipped[#skipped + 1] = "no style"
            else
                local t, w, h = prepare_tags_for_perspective(line, style, meta, styles)
                pts = apply_quad_mapping(orient_quad_for_extents(pts, w, h), res.map)
                if not valid_quad(pts) then
                    skipped[#skipped + 1] = "bad quad"
                elseif apply_quad(line, t, pts, w, h, orgMode, res.remove_persp_clip) then
                    subs[i] = line
                    applied = applied + 1
                else
                    skipped[#skipped + 1] = "apply failed"
                end
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Clip to Persp", applied,
            "Clip to Persp: 0 lines changed (" .. (skipped[1] or "unknown") .. ").")
    end
    if res.mode == "Scale Quad (3D Box)" then
        local changed, skipped = 0, 0
        for _, i in ipairs(sel) do
            local line = subs[i]
            local style = perspective_pick_style(styles, line.style)
            if style then
                local q, t, w, h = safe_build_quad_for(line, style, meta, styles)
                if q then
                    local nq = scale_quad(q, res.qscale)
                    if apply_quad(line, t, nq, w, h, orgMode, false) then
                        subs[i] = line
                        changed = changed + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    skipped = skipped + 1
                end
            else
                skipped = skipped + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Scale Quad", changed,
            string.format("Scale Quad: 0 lines changed (%d skipped).", skipped))
    end
    if res.mode == "Identity reproject" then
        local changed, skipped = 0, 0
        for _, i in ipairs(sel) do
            local line = subs[i]
            local style = perspective_pick_style(styles, line.style)
            if style then
                local q, t, w, h = safe_build_quad_for(line, style, meta, styles)
                if q then
                    if apply_quad(line, t, q, w, h, orgMode, false) then
                        subs[i] = line
                        changed = changed + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    skipped = skipped + 1
                end
            else
                skipped = skipped + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Identity Reproject", changed,
            string.format("Identity reproject: 0 lines changed (%d skipped).", skipped))
    end
    if res.mode == "Mass FSC (lock quad)" then
        local changed, skipped = 0, 0
        for _, i in ipairs(sel) do
            local line = subs[i]
            local style = perspective_pick_style(styles, line.style)
            if style then
                local q, t, w, h = safe_build_quad_for(line, style, meta, styles)
                if q then
                    local fx = res.set_sx and res.sx or RheaFoundation.tagValue(t.scale_x, 100)
                    local fy = res.set_sy and res.sy or RheaFoundation.tagValue(t.scale_y, 100)
                    if apply_quad_locked_scale(line, t, q, w, h, fx, fy, false) then
                        subs[i] = line
                        changed = changed + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    skipped = skipped + 1
                end
            else
                skipped = skipped + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Mass FSC", changed,
            string.format("Mass FSC: 0 lines changed (%d skipped).", skipped))
    end
    if res.mode == "Rescale to Clip" then
        local changed, skipped = 0, 0
        local opts2 = {
            mode = res.rescale_mode, recenter = res.recenter, remove_clip = res.remove_clip,
            scale_fs = res.scale_fs, scale_bord = res.scale_bord, scale_shad = res.scale_shad,
            scale_blur = res.scale_blur, scale_fsp = res.scale_fsp,
            meta = meta, styles = styles,
        }
        for _, i in ipairs(sel) do
            local line = subs[i]
            local style = perspective_pick_style(styles, line.style)
            if style and rescale_line_to_clip(line, style, opts2) then
                subs[i] = line
                changed = changed + 1
            else
                skipped = skipped + 1
            end
        end
        return perspectiveFinish("Rhea Signs - Perspective Rescale to Clip", changed,
            string.format("Rescale to Clip: 0 lines changed (%d skipped).", skipped))
    end
    if res.mode and res.mode:match("^Copy") then
        return run_copy_mode(subs, sel, styles, res, orgMode, meta)
    end
end

RheaOps.Perspective.run = pk_dispatch
RheaOps.Perspective.loadConfig = function()
    local C = PK_CONFIG.read()
    C = FunctionalTable.union(C, DEFAULTS)
    C.mode = normalizePerspectiveMode(C.mode)
    C.map = normalizePerspectiveMap(C.map)
    C.mode = RheaFoundation.choose(C.mode, MODE_ITEMS, DEFAULTS.mode)
    C.map = RheaFoundation.choose(C.map, map_names(), DEFAULTS.map)
    C.orgm = RheaFoundation.choose(C.orgm, ORG_ITEMS, DEFAULTS.orgm)
    C.rescale_mode = RheaFoundation.choose(C.rescale_mode, RESCALE_ITEMS, DEFAULTS.rescale_mode)
    return C
end
RheaOps.Perspective.modes = MODE_ITEMS
RheaOps.Perspective.mapNames = map_names
RheaOps.Perspective.orgModes = ORG_ITEMS
RheaOps.Perspective.rescaleModes = RESCALE_ITEMS
end

do


-- RheaOps.Animation
local FX = {}

local SHAPE_ITEMS = {
    "Una vez (ida)",
    "Ida y vuelta",
    "Yoyo (N ciclos)",
    "Pulso (ms)",
    "Pasos (N)",
    "Custom keyframes",
}

local DELAY_ITEMS = {
    "Sin retardo",
    "ms desde inicio",
    "Frame actual",
    "Porcentaje (%)",
}

local FX_ITEMS = {
    "",
    "Blur In", "Blur Out",
    "Fade In", "Fade Out",
    "Scale Up", "Scale Down",
    "Pop In", "Pop Out",
    "Color Flash", "Color Pulse", "To Color (frame)",
    "To Style (frame)",
    "Border Pulse", "Glow Pulse",
    "Shake V", "Shake H", "Shake XY",
    "Wobble (frz)",
    "Glitch",
    "Dramatic Pulse",
    "Flashback (fad)",
    "Split Line", "Split Line Fad", "Split Title",
}


local function frameMs()
    local props = aegisub.project_properties and aegisub.project_properties()
    if not props or not props.video_position then return nil, L("msg_no_video") end
    local ms = ArchUtil.exact_ms_from_frame(props.video_position)
    if not ms then return nil, L("msg_frame_time_unresolved") end
    return ms, nil
end


local CFG_KEYS = {
    "tags_ini","tags_fin","shape","shape_val","accel","use_accel",
    "delay_mode","delay_val","strip_existing","fx_color","fx_color2",
    "fx_step_ms","fx_amount","fx_preset","custom_kf",
}

local PT_DEFAULTS = {
    tags_ini = "", tags_fin = "", shape = "Una vez (ida)", shape_val = 3,
    accel = 1.0, use_accel = false, delay_mode = "Sin retardo", delay_val = 0,
    strip_existing = true, fx_color = "&H00CCFF&", fx_color2 = "&HFFCC00&",
    fx_step_ms = 50, fx_amount = 0.12, fx_preset = "", custom_kf = "",
}

local SHAPE_ALIASES = {
    ["Once (one-way)"] = "Una vez (ida)",
    ["Once (out)"] = "Una vez (ida)",
    ["Out and back"] = "Ida y vuelta",
    ["Yoyo (N cycles)"] = "Yoyo (N ciclos)",
    ["Pulse (ms)"] = "Pulso (ms)",
    ["Steps (N)"] = "Pasos (N)",
}

local DELAY_ALIASES = {
    ["No delay"] = "Sin retardo",
    ["ms from start"] = "ms desde inicio",
    ["Current frame"] = "Frame actual",
    ["Current video frame"] = "Frame actual",
    ["Percent (%)"] = "Porcentaje (%)",
    ["Percentage (%)"] = "Porcentaje (%)",
}

local function normalizeAnimationConfig(cfg)
    cfg = FunctionalTable.union(cfg or {}, PT_DEFAULTS)
    cfg.shape = RheaFoundation.chooseAlias(cfg.shape, SHAPE_ALIASES, SHAPE_ITEMS, PT_DEFAULTS.shape)
    cfg.delay_mode = RheaFoundation.chooseAlias(cfg.delay_mode, DELAY_ALIASES, DELAY_ITEMS, PT_DEFAULTS.delay_mode)
    return cfg
end

local PT_CONFIG = RheaConfig.section("pt", PT_DEFAULTS)

local function saveAnimationConfig(cfg)
    cfg = normalizeAnimationConfig(cfg)
    local clean = {}
    for _, key in ipairs(CFG_KEYS) do
        local value = cfg and cfg[key]
        if value ~= nil then
            if type(value) == "number" and (value ~= value or value == math.huge or value == -math.huge) then value = 0 end
            clean[key] = value
        end
    end
    PT_CONFIG.write(clean)
    return true
end

local function loadAnimationConfig()
    return normalizeAnimationConfig(PT_CONFIG.read())
end


local function stripTransforms(text)
    if not text or text == "" then return text end
    return RheaFoundation.removeTags(text, "t")
end

local function resolveOffset(line, dur, cfg)
    local mode = cfg.delay_mode or "Sin retardo"
    if mode == "Sin retardo" then return 0 end
    if mode == "ms desde inicio" then
        return Rhea.clamp(math.floor(cfg.delay_val or 0), 0, dur)
    end
    if mode == "Porcentaje (%)" then
        local p = Rhea.clamp((cfg.delay_val or 0) / 100, 0, 1)
        return math.floor(dur * p)
    end
    if mode == "Frame actual" then
        local fms = frameMs()
        if not fms then return 0 end
        return Rhea.clamp(fms - line.start_time, 0, dur)
    end
    return 0
end

local function interpolateSimple(ini, fin, f)
    if not ini or not fin then return fin or "" end
    local prefix1, num1 = ini:match("^(.-)([%-%d%.]+)$")
    local prefix2, num2 = fin:match("^(.-)([%-%d%.]+)$")
    if num1 and num2 and prefix1 == prefix2 then
        local n1 = tonumber(num1)
        local n2 = tonumber(num2)
        if n1 and n2 then
            return string.format("%s%.2f", prefix2, n1 + (n2 - n1) * f):gsub("%.00$", "")
        end
    end
    return fin
end

local function buildChain(line, cfg)
    local dur = line.end_time - line.start_time
    if dur <= 0 then return "" end

    local offset = resolveOffset(line, dur, cfg)
    local effDur = dur - offset
    if effDur <= 0 then return "" end

    local tagsIni = cfg.tags_ini or ""
    local tagsFin = cfg.tags_fin or ""
    local accel   = cfg.use_accel and (cfg.accel or 1.0) or nil
    local shape   = cfg.shape or "Una vez (ida)"

    local payload = tagsIni
    local tEnd = offset + effDur

    if shape == "Una vez (ida)" then
        if tagsFin ~= "" then
            payload = payload .. RheaFoundation.transformTag(offset, tEnd, tagsFin, accel)
        end

    elseif shape == "Ida y vuelta" then
        local mid = offset + effDur / 2
        if tagsFin ~= "" then payload = payload .. RheaFoundation.transformTag(offset, mid, tagsFin, accel) end
        if tagsIni ~= "" then payload = payload .. RheaFoundation.transformTag(mid, tEnd, tagsIni, accel) end

    elseif shape == "Yoyo (N ciclos)" then
        local cycles = math.max(1, math.floor(cfg.shape_val or 1))
        local seg = effDur / (cycles * 2)
        for i = 0, cycles*2 - 1 do
            local t1 = offset + seg * i
            local t2 = offset + seg * (i + 1)
            if i % 2 == 0 then
                if tagsFin ~= "" then payload = payload .. RheaFoundation.transformTag(t1, t2, tagsFin, accel) end
            else
                if tagsIni ~= "" then payload = payload .. RheaFoundation.transformTag(t1, t2, tagsIni, accel) end
            end
        end

    elseif shape == "Pulso (ms)" then
        local half = math.max(20, math.floor(cfg.shape_val or 200))
        local t = offset
        local forward = true
        while t < tEnd do
            local t2 = math.min(t + half, tEnd)
            if forward then
                if tagsFin ~= "" then payload = payload .. RheaFoundation.transformTag(t, t2, tagsFin, accel) end
            else
                if tagsIni ~= "" then payload = payload .. RheaFoundation.transformTag(t, t2, tagsIni, accel) end
            end
            t = t2
            forward = not forward
        end

    elseif shape == "Pasos (N)" then
        local n = math.max(2, math.floor(cfg.shape_val or 4))
        for i = 1, n do
            local f = (i - 1) / (n - 1)
            local t1 = offset + (effDur / n) * (i - 1)
            local t2 = offset + (effDur / n) * i
            local stepTags = interpolateSimple(tagsIni, tagsFin, f)
            payload = payload .. RheaFoundation.transformTag(t1, t2, stepTags, accel)
        end

    elseif shape == "Custom keyframes" then
        local kf = cfg.custom_kf or ""
        local prevT = offset
        for chunk in kf:gmatch("[^;]+") do
            local tStr, tg = chunk:match("^%s*(%-?[%d%.]+)%s*:%s*(.-)%s*$")
            local t = tonumber(tStr or "")
            if t and tg and tg ~= "" then
                local ta = offset + t
                payload = payload .. RheaFoundation.transformTag(prevT, ta, tg, accel)
                prevT = ta
            end
        end
    end

    return payload
end

local function applyChain(subs, sel, cfg)
    local cnt, errs = 0, {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur <= 0 then
                table.insert(errs, string.format(L("msg_line_duration_zero"), i))
            else
                local chain = buildChain(l, cfg)
                if chain ~= "" then
                    local newText = l.text
                    if cfg.strip_existing then
                        newText = stripTransforms(newText)
                    end
                    l.text = Rhea.injectFirst(newText, chain)
                    subs[i] = l
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt, errs
end


local function withFrameInRange(line, fms)
    if not fms then return nil, L("msg_frame_unavailable") end
    if fms < line.start_time or fms > line.end_time then
        return nil, string.format(L("msg_frame_out_of_range"), fms, line.start_time, line.end_time)
    end
    return fms - line.start_time, nil
end

local function stripKaraokeTags(text)
    return tostring(text or ""):gsub("%b{}", function(block)
        local body = block:sub(2, -2):gsub("\\[kK][fo]?[%d%.]+", "")
        if Rhea.trim(body) == "" then return "" end
        return "{" .. body .. "}"
    end)
end

local function karaokeCue(text)
    local elapsed, seen = 0, 0
    text = tostring(text or "")
    for s, block, e in text:gmatch("()(%b{})()") do
        for value in block:gmatch("\\[kK][fo]?([%d%.]+)") do
            seen = seen + 1
            if seen == 2 then
                return elapsed, stripKaraokeTags(text:sub(1, s - 1)), stripKaraokeTags(text:sub(s))
            end
            elapsed = elapsed + math.floor((tonumber(value) or 0) * 10 + 0.5)
        end
    end
    return nil
end

local function fxOffset(line)
    local off = karaokeCue(line.text)
    if off and off > 0 and off < line.end_time - line.start_time then return off, true end
    return 0, false
end

local function fxText(line, usesKaraoke)
    return usesKaraoke and stripKaraokeTags(line.text) or line.text
end

local function injectFX(line, payload, strip)
    if strip then
        line.text = stripTransforms(line.text)
    end
    line.text = Rhea.injectFirst(line.text, payload)
    return line
end


local function fxFromIniFin(ini, fin)
    return function(subs, sel, cfg)
        local cnt = 0
        for _, i in ipairs(sel) do
            local l = subs[i]
            if Rhea.isDialogue(l) then
                local dur = l.end_time - l.start_time
                if dur > 0 then
                    local offset, usesKaraoke = fxOffset(l)
                    l.text = fxText(l, usesKaraoke)
                    local payload = ini .. RheaFoundation.transformTag(offset, dur, fin, cfg.use_accel and cfg.accel or nil)
                    subs[i] = injectFX(l, payload, cfg.strip_existing)
                    cnt = cnt + 1
                end
            end
        end
        return cnt
    end
end

FX["Blur In"]   = fxFromIniFin("\\blur8",            "\\blur0")
FX["Blur Out"]  = fxFromIniFin("\\blur0",            "\\blur8")
FX["Fade In"]   = fxFromIniFin("\\alpha&HFF&",       "\\alpha&H00&")
FX["Fade Out"]  = fxFromIniFin("\\alpha&H00&",       "\\alpha&HFF&")
FX["Scale Up"]  = fxFromIniFin("\\fscx100\\fscy100", "\\fscx115\\fscy115")
FX["Scale Down"]= fxFromIniFin("\\fscx115\\fscy115", "\\fscx100\\fscy100")
FX["Pop In"]    = fxFromIniFin("\\fscx40\\fscy40\\alpha&HFF&", "\\fscx100\\fscy100\\alpha&H00&")
FX["Pop Out"]   = fxFromIniFin("\\fscx100\\fscy100\\alpha&H00&", "\\fscx40\\fscy40\\alpha&HFF&")
FX["Border Pulse"] = fxFromIniFin("\\bord2", "\\bord6")
FX["Glow Pulse"]   = fxFromIniFin("\\blur1\\bord2", "\\blur8\\bord4")


FX["Color Flash"] = function(subs, sel, cfg)
    local c1 = Rhea.colorNorm(cfg.fx_color  or "&HFFFFFF&")
    local c2 = Rhea.colorNorm(cfg.fx_color2 or "&H0000FF&")
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                l.text = fxText(l, usesKaraoke)
                local mid = offset + math.floor((dur - offset) * 0.3)
                local payload = "\\c"..c1
                    .. RheaFoundation.transformTag(offset, mid, "\\c"..c2)
                    .. RheaFoundation.transformTag(mid, dur, "\\c"..c1)
                subs[i] = injectFX(l, payload, cfg.strip_existing)
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

FX["Color Pulse"] = function(subs, sel, cfg)
    local c1 = Rhea.colorNorm(cfg.fx_color  or "&HFFFFFF&")
    local c2 = Rhea.colorNorm(cfg.fx_color2 or "&H00CCFF&")
    local step = math.max(80, math.floor(cfg.fx_step_ms or 250))
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                l.text = fxText(l, usesKaraoke)
                local payload = "\\c"..c1
                local t = offset; local toFin = true
                while t < dur do
                    local t2 = math.min(t + step, dur)
                    payload = payload .. RheaFoundation.transformTag(t, t2, "\\c"..(toFin and c2 or c1))
                    t = t2; toFin = not toFin
                end
                subs[i] = injectFX(l, payload, cfg.strip_existing)
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

FX["To Color (frame)"] = function(subs, sel, cfg)
    local fms, ferr = frameMs()
    local color = Rhea.colorNorm(cfg.fx_color or "&HFFCC00&")
    local cnt, errs = 0, {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local startOff, usesKaraoke = fxOffset(l)
                if not usesKaraoke then
                    if fms then startOff = Rhea.clamp(fms - l.start_time, 0, dur)
                    else startOff = nil; table.insert(errs, L("tagops_line") .. " " .. tostring(i) .. ": " .. (ferr or L("msg_frame_unavailable"))) end
                end
                if startOff then
                    l.text = fxText(l, usesKaraoke)
                    local payload = RheaFoundation.transformTag(startOff, dur,
                        "\\c"..color.."\\3c"..color.."\\4c"..color)
                    subs[i] = injectFX(l, payload, cfg.strip_existing)
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt, #errs > 0 and table.concat(errs, "\n") or nil
end

FX["To Style (frame)"] = function(subs, sel, cfg, sm)
    local fms, ferr = frameMs()
    local color = Rhea.colorNorm(cfg.fx_color or "&HFFCC00&")
    local cnt, errs = 0, {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local off, usesKaraoke = fxOffset(l)
            local perr
            if not usesKaraoke then
                if fms then off, perr = withFrameInRange(l, fms)
                else off, perr = nil, ferr or L("msg_frame_unavailable") end
            end
            if not off then
                table.insert(errs, L("tagops_line") .. " " .. tostring(i) .. ": " .. perr)
            else
                local style = sm[l.style]
                if not style then
                    table.insert(errs, L("tagops_line") .. " " .. tostring(i) .. ": " .. L("msg_style_not_found"))
                else
                    l.text = fxText(l, usesKaraoke)
                    local sc1 = Rhea.colorFromStyle(style.color1)
                    local sc3 = Rhea.colorFromStyle(style.color3)
                    local sc4 = Rhea.colorFromStyle(style.color4)
                    local initTags = string.format("\\c%s\\3c%s\\4c%s", color, color, color)
                    local trans = RheaFoundation.transformTag(0, off, string.format("\\c%s\\3c%s\\4c%s", sc1, sc3, sc4))
                    subs[i] = injectFX(l, initTags .. trans, cfg.strip_existing)
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt, #errs > 0 and table.concat(errs, "\n") or nil
end


local function shakeEngine(subs, sel, cfg, axis)
    local step = math.max(20, math.floor(cfg.fx_step_ms or 50))
    local amount = cfg.fx_amount or 0.12
    local orgDistance = 1500
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                l.text = fxText(l, usesKaraoke)
                local px, py = l.text:match("\\pos%(([%-%d%.]+),([%-%d%.]+)%)")
                if not px then px, py = 960, 540 else px, py = tonumber(px), tonumber(py) end

                l.text = RheaFoundation.removeTags(l.text, "org")

                local orgX, orgY = math.floor(px), math.floor(py)
                if axis == "V" or axis == "XY" then orgX = orgX - orgDistance end
                if axis == "H" or axis == "XY" then orgY = orgY - orgDistance end
                local orgTag = string.format("\\org(%d,%d)", orgX, orgY)

                local trans = ""
                local t, dir = offset, 1
                while t < dur do
                    local t2 = math.min(t + step, dur)
                    trans = trans .. RheaFoundation.transformTag(t, t2, string.format("\\frz%.3f", amount * dir))
                    t = t2; dir = -dir
                end
                subs[i] = injectFX(l, orgTag .. trans, cfg.strip_existing)
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

FX["Shake V"]  = function(s,l,c) return shakeEngine(s,l,c,"V")  end
FX["Shake H"]  = function(s,l,c) return shakeEngine(s,l,c,"H")  end
FX["Shake XY"] = function(s,l,c) return shakeEngine(s,l,c,"XY") end

FX["Wobble (frz)"] = function(subs, sel, cfg)
    local step = math.max(40, math.floor(cfg.fx_step_ms or 120))
    local amount = cfg.fx_amount or 4.0
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                l.text = fxText(l, usesKaraoke)
                local trans = ""
                local t, dir = offset, 1
                while t < dur do
                    local t2 = math.min(t + step, dur)
                    trans = trans .. RheaFoundation.transformTag(t, t2, string.format("\\frz%.2f", amount * dir))
                    t = t2; dir = -dir
                end
                subs[i] = injectFX(l, trans, cfg.strip_existing)
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

FX["Glitch"] = function(subs, sel, cfg)
    math.randomseed(os.time())
    local step = math.max(30, math.floor(cfg.fx_step_ms or 60))
    local amount = cfg.fx_amount or 6.0
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                l.text = fxText(l, usesKaraoke)
                local trans = ""
                local t = offset
                while t < dur do
                    local t2 = math.min(t + step, dur)
                    local fax = (math.random() - 0.5) * amount * 0.05
                    local fsp = math.floor((math.random() - 0.5) * amount)
                    trans = trans .. RheaFoundation.transformTag(t, t2, string.format("\\fax%.3f\\fsp%d", fax, fsp))
                    t = t2
                end
                subs[i] = injectFX(l, trans, cfg.strip_existing)
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

FX["Dramatic Pulse"] = function(subs, sel, cfg)
    local cnt = 0
    local pulseColor = Rhea.colorNorm(cfg.fx_color or "&HFFFFFF&")
    local lines = LineCollection(subs, sel, function() return true end)
    local replacements = {}
    lines:runCallback(function(_, l)
        if Rhea.isDialogue(l) then
            local dur = l.end_time - l.start_time
            if dur > 0 then
                local offset, usesKaraoke = fxOffset(l)
                local baseText = fxText(l, usesKaraoke)
                local pulseEnd = math.min(dur, offset + math.max(120, math.floor(cfg.fx_step_ms or 220)))
                local settleEnd = math.min(dur, offset + math.max(180, math.floor((cfg.fx_step_ms or 220) * 1.8)))
                local glow = Rhea.cloneLine(l)
                local top = Rhea.cloneLine(l)
                glow.layer = l.layer or 0
                top.layer = (l.layer or 0) + 1
                glow.text = baseText
                top.text = baseText
                local glowTags = "\\c"..pulseColor.."\\3c"..pulseColor.."\\blur2\\bord3\\alpha&H20&"
                    .. RheaFoundation.transformTag(offset, pulseEnd, "\\fscx170\\fscy170\\blur9\\bord8\\alpha&HFF&")
                local topTags = "\\alpha&H00&"
                    .. RheaFoundation.transformTag(offset, pulseEnd, "\\fscx122\\fscy122")
                    .. RheaFoundation.transformTag(pulseEnd, settleEnd, "\\fscx100\\fscy100")
                replacements[l] = {
                    injectFX(glow, glowTags, cfg.strip_existing),
                    injectFX(top, topTags, cfg.strip_existing),
                }
                cnt = cnt + 1
            end
        end
    end)
    if cnt <= 0 then return 0 end
    local newSel = RheaFoundation.replaceCollectedLines(lines, replacements)
    return cnt, nil, newSel
end


FX["Flashback (fad)"] = function(subs, sel, cfg)
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if Rhea.isDialogue(l) then
            l.text = Rhea.injectFirst(l.text, "\\fad(200,200)")
            subs[i] = l; cnt = cnt + 1
        end
    end
    return cnt
end


local function splitAtFrame(subs, sel, mode)
    local fms, ferr = frameMs()
    local cnt, errs = 0, {}
    local lines = LineCollection(subs, sel, function() return true end)
    local replacements = {}
    lines:runCallback(function(_, l)
        if Rhea.isDialogue(l) then
            local kOff, kBefore, kAfter = karaokeCue(l.text)
            local lineFms = fms
            if kOff then
                lineFms = l.start_time + kOff
            end
            if not kOff and not lineFms then
                table.insert(errs, L("tagops_line") .. " " .. tostring(l.number) .. ": " .. (ferr or L("msg_frame_unavailable")))
            elseif not kOff and not l.text:find("|", 1, true) then
                table.insert(errs, L("tagops_line") .. " " .. tostring(l.number) .. ": " .. L("msg_missing_pipe"))
            elseif lineFms <= l.start_time or lineFms >= l.end_time then
                table.insert(errs, string.format(L("msg_line_frame_out_of_range"), l.number, l.start_time, l.end_time))
            else
                local head = Rhea.firstBlock(l.text)
                local body = l.text:sub(#head + 1)
                local before, after = body:match("^(.-)%|(.*)$")
                if kOff then head, before, after = "", kBefore, kAfter end
                if not before then
                    table.insert(errs, L("tagops_line") .. " " .. tostring(l.number) .. ": " .. L("msg_marker_error"))
                else
                    local l1 = Rhea.cloneLine(l)
                    local l2 = Rhea.cloneLine(l)
                    if mode == "Split Line" then
                        l1.end_time = lineFms
                        l1.text = head .. before .. "{\\alpha&HFF&}" .. after
                        l2.start_time = lineFms
                        l2.text = head .. before .. after
                    elseif mode == "Split Line Fad" then
                        l1.text = head .. before .. "{\\alpha&HFF&}" .. after
                        l2.layer = (l.layer or 0) + 1
                        l2.start_time = lineFms
                        local fadTag = "\\fad(250,0)\\alpha&HFF&"
                        if head ~= "" then
                            l2.text = head:gsub("^{", "{" .. fadTag) .. before .. "{\\alpha&H00&}" .. after
                        else
                            l2.text = "{" .. fadTag .. "}" .. before .. "{\\alpha&H00&}" .. after
                        end
                    end
                    replacements[l] = {l1, l2}
                    cnt = cnt + 1
                end
            end
        end
    end)
    if cnt <= 0 then return 0, #errs > 0 and table.concat(errs, "\n") or nil end
    local newSel = RheaFoundation.replaceCollectedLines(lines, replacements)
    return cnt, #errs > 0 and table.concat(errs, "\n") or nil, newSel
end

FX["Split Line"]     = function(s,l) return splitAtFrame(s,l,"Split Line") end
FX["Split Line Fad"] = function(s,l) return splitAtFrame(s,l,"Split Line Fad") end

FX["Split Title"] = function(subs, sel)
    local cnt = 0
    local lines = LineCollection(subs, sel, function() return true end)
    local replacements = {}
    lines:runCallback(function(_, l)
        if Rhea.isDialogue(l) then
            local head = Rhea.firstBlock(l.text)
            local body = l.text:sub(#head + 1)
            local l1 = Rhea.cloneLine(l)
            local l2 = Rhea.cloneLine(l)
            l1.layer = l.layer or 0
            l2.layer = (l.layer or 0) + 1
            if head ~= "" then
                l1.text = head:gsub("^{", "{\\1a&HFF&") .. body
                l2.text = head:gsub("^{", "{\\bord0") .. body
            else
                l1.text = "{\\1a&HFF&}" .. body
                l2.text = "{\\bord0}" .. body
            end
            replacements[l] = {l1, l2}
            cnt = cnt + 1
        end
    end)
    if cnt <= 0 then return 0 end
    local newSel = RheaFoundation.replaceCollectedLines(lines, replacements)
    return cnt, nil, newSel
end


local function runFX(subs, sel, cfg)
    local name = cfg.fx_preset
    if not name or name == "" then return 0, "Sin FX seleccionado." end
    local fx = FX[name]
    if not fx then return 0, "FX desconocido: "..name end
    local sm = Rhea.styleMap(subs)
    local n, err, newSel = fx(subs, sel, cfg, sm)
    return n or 0, err, newSel
end

local function pt_dispatch(subs, sel, opts)
    if not sel or #sel == 0 then return false end
    local cfg = loadAnimationConfig()
    for k, v in pairs(opts or {}) do
        cfg[k] = v
    end
    cfg = normalizeAnimationConfig(cfg)
    saveAnimationConfig(cfg)
    local action = opts and opts.action or "chain"
    if action == "chain" then
        local n, errs = applyChain(subs, sel, cfg)
        if (tonumber(n) or 0) > 0 then
            aegisub.set_undo_point("Rhea Signs - Animation Chain")
            return true, true
        elseif errs and #errs > 0 then
            showMsg(table.concat(errs, "\n"))
        end
    elseif action == "fx" then
        cfg.strip_existing = cfg.strip_existing ~= false
        local n, err, newSel = runFX(subs, sel, cfg)
        if err and n == 0 then
            showMsg("Animation FX " .. tostring(cfg.fx_preset or "?") .. ": " .. err)
        elseif n > 0 then
            aegisub.set_undo_point("Rhea Signs - Animation FX " .. cfg.fx_preset)
            return newSel or true, true
        end
    end
    return false
end

RheaOps.Animation.run = pt_dispatch
RheaOps.Animation.loadConfig = loadAnimationConfig
RheaOps.Animation.shapes = SHAPE_ITEMS
RheaOps.Animation.delays = DELAY_ITEMS
RheaOps.Animation.fx = FX_ITEMS
end

do

-- RheaOps.Masks
local MASK_FILE = aegisub.decode_path("?user") .. "/dramaturgy_masks.txt"

local BUILTIN_MASKS = [[mask:square:m 0 0 l 100 0 100 100 0 100:
mask:rounded:m -100 -25 b -100 -92 -92 -100 -25 -100 l 25 -100 b 92 -100 100 -92 100 -25 l 100 25 b 100 92 92 100 25 100 l -25 100 b -92 100 -100 92 -100 25 l -100 -25:
mask:circle:m -100 -100 b -45 -155 45 -155 100 -100 b 155 -45 155 45 100 100 b 46 155 -45 155 -100 100 b -155 45 -155 -45 -100 -100:
mask:triangle:m -122 70 l 122 70 l 0 -141:
]]

local function stampSeqMarker(line, seq)
    line.effect = Rhea.trim((line.effect or ""):gsub("%[DR%-%w+%]", ""))
    RheaFoundation.stampMarker(line, "DR", seq)
end

local function clipCommandsToLocalDrawing(cmds, ox, oy)
    local parts = {}
    local firstX, firstY, lastX, lastY
    for _, cmd in ipairs(cmds or {}) do
        parts[#parts + 1] = cmd.type
        for i = 1, #cmd.pts, 2 do
            local x = (tonumber(cmd.pts[i]) or 0) - ox
            local y = (tonumber(cmd.pts[i + 1]) or 0) - oy
            if not firstX then firstX, firstY = x, y end
            lastX, lastY = x, y
            parts[#parts + 1] = RheaFoundation.assNumber(x)
            parts[#parts + 1] = RheaFoundation.assNumber(y)
        end
    end
    if firstX and lastX and (math.abs(firstX - lastX) > 0.001 or math.abs(firstY - lastY) > 0.001) then
        parts[#parts + 1] = "l"
        parts[#parts + 1] = RheaFoundation.assNumber(firstX)
        parts[#parts + 1] = RheaFoundation.assNumber(firstY)
    end
    return Rhea.trim(table.concat(parts, " "))
end

local function extractClipMaskShape(text)
    local clip = RheaFoundation.firstClipTag(text)
    if not clip then return nil end
    local x1, y1, x2, y2 = RheaFoundation.clipBBox(clip)
    if not x1 or not y1 or not x2 or not y2 then return nil end
    local cmds = RheaFoundation.clipCommands(clip)
    if not cmds or #cmds == 0 then return nil end
    return clipCommandsToLocalDrawing(cmds, x1, y1), x1, y1, x2, y2
end

local function replaceDrawing(lineText, shape)
    local text = tostring(lineText or ""):gsub("\\fsc[xy][^}\\]+", "")
    local replaced
    text, replaced = text:gsub("}m%s+[^{}]*", "\\fscx100\\fscy100}" .. shape, 1)
    if replaced == 0 then text = text:gsub("}[^{}]*$", "\\fscx100\\fscy100}" .. shape, 1) end
    return text
end

local DR_DEFAULTS = {
    mask_source = "from clip", alignment = "an7",
    create_layer = true, replace_mask = false, bicubic = false,
    use_alpha = false, alpha_value = "80",
    use_color = true,  color_value = "#000000",
}

local DR_CONFIG = RheaConfig.section("dr", DR_DEFAULTS)

local function loadMaskLibrary()
    local f = io.open(MASK_FILE)
    local content = f and f:read("*all") or ""
    if f then f:close() end
    local masks, names = {}, {"from clip"}
    local source = BUILTIN_MASKS .. content
    if source:sub(-1) ~= "\n" then source = source .. "\n" end
    for name, shape in source:gmatch("mask:(.-):(.-):\n") do
        names[#names + 1] = name
        masks[#masks + 1] = {name = name, shape = shape}
    end
    return masks, names
end

local function saveMask(name, shapeText)
    name = Rhea.trim(name); if name == "" or name:match("[:\r\n]") then return end
    local shape = tostring(shapeText or ""):gsub("{[^}]-}", ""):match("m%s+[^{}:\r\n]+")
    if not shape then return end
    shape = Rhea.trim(shape)
    local f = io.open(MASK_FILE, "a")
    if f then f:write("mask:" .. name .. ":" .. shape .. ":\n\n"); f:close() end
end

local function deleteMask(name)
    name = Rhea.trim(name); if name == "" or name:match("[:\r\n]") then return end
    local f = io.open(MASK_FILE, "r")
    local content = f and f:read("*all") or ""
    if f then f:close() end
    content = content:gsub("mask:" .. Rhea.escapePattern(name) .. ":.-:\n\n?", "")
    f = io.open(MASK_FILE, "w")
    if f then f:write(content); f:close() end
end

local function findMaskShape(masks, name)
    for i = #(masks or {}), 1, -1 do
        local m = masks[i]
        if m.name == name then return m.shape end
    end
    return nil
end

local function insertedMaskSelection(sel, additions)
    local entries = {}
    for line in pairs(additions) do entries[#entries + 1] = line.number end
    table.sort(entries)

    local selected = {}
    for _, i in ipairs(sel) do
        local shift = 0
        for _, n in ipairs(entries) do if n < i then shift = shift + 1 end end
        selected[#selected + 1] = i + shift
    end
    for offset, n in ipairs(entries) do
        selected[#selected + 1] = n + offset
    end
    return selected
end

local function applyMask(subs, sel, opts)
    local masks, _ = loadMaskLibrary()
    local lines = LineCollection(subs, sel, function() return true end)
    local additions = {}
    local changed = false
    lines:runCallback(function(_, line, seq)
        local text = line.text or ""
        local sourceText = text
        local colorTag = opts.use_color and ("\\c" .. Rhea.htmlToAss(opts.color_value or "#000000")) or ""
        local alphaTag = opts.use_alpha and ("\\alpha&H" .. RheaFoundation.sanitizeAlpha(opts.alpha_value) .. "&") or ""
        local target = line
        local sourceIsClip = opts.mask_source == "from clip"
        local clipPath, x1, y1, x2, y2
        if sourceIsClip then
            clipPath, x1, y1, x2, y2 = extractClipMaskShape(sourceText)
        end
        local libraryShape
        if not sourceIsClip then
            libraryShape = findMaskShape(masks, opts.mask_source)
            if not libraryShape then return end
        end
        if opts.create_layer and not opts.replace_mask then
            if sourceIsClip then
                if not clipPath then return end
            end
            local baseLayer = tonumber(line.layer) or 0
            local mask_line = Rhea.cloneLine(line)
            if baseLayer <= 0 then
                line.layer = 1
                mask_line.layer = 0
                changed = true
            else
                mask_line.layer = baseLayer - 1
            end
            if sourceIsClip then
                mask_line.text = RheaFoundation.removeTags(mask_line.text or "", {"clip", "iclip"})
            end
            additions[line] = mask_line
            changed = true
            target = mask_line
            text = sourceText
        end
        if opts.replace_mask then
            if not text:match("\\p1") then return end
            if sourceIsClip then
                if not clipPath then return end
                local an = tonumber(tostring(opts.alignment or "an7"):match("an([1-9])")) or 7
                local cx, cy = RheaFoundation.anchorPointFromAlign(an, x1, y1, x2, y2)
                target.text = RheaFoundation.removeTags(target.text, {"clip", "iclip"})
                target.text = replaceDrawing(target.text, clipPath)
                target.text = RheaFoundation.setAlignTag(target.text, an)
                target.text = RheaFoundation.setPositionTag(target.text, cx, cy)
            else
                target.text = replaceDrawing(target.text, libraryShape)
            end
            stampSeqMarker(target, seq)
            changed = true
        elseif sourceIsClip then
            if not clipPath then return end
            local an = tonumber(tostring(opts.alignment or "an7"):match("an([1-9])")) or 7
            local cx, cy = RheaFoundation.anchorPointFromAlign(an, x1, y1, x2, y2)
            target.text = string.format(
                "{\\an%d\\blur1\\bord0\\shad0\\fscx100\\fscy100%s%s\\pos(%.3f,%.3f)\\p1}%s",
                an, colorTag, alphaTag, cx, cy, clipPath)
            stampSeqMarker(target, seq)
            changed = true
        else
            local rotTags = ""
            for _, pat in ipairs({"\\org%b()", "\\frz[%d%.%-]+", "\\frx[%d%.%-]+", "\\fry[%d%.%-]+"}) do
                local m = text:match(pat); if m then rotTags = rotTags .. m end
            end
            local posTag = text:match("(\\pos%([%d%,%.%-]+%))") or ""
            target.text = string.format(
                "{\\%s\\bord0\\shad0\\blur1%s%s%s%s\\p1}%s",
                opts.alignment, rotTags, posTag, colorTag, alphaTag, libraryShape)
            if not target.text:match("\\pos") then
                target.text = target.text:gsub("\\p1", "\\pos(640,360)\\p1")
            end
            stampSeqMarker(target, seq)
            changed = true
        end
        if opts.bicubic then
            if target.text:match("\\q2") then
                target.text = target.text:gsub("\\q2", ""):gsub("{}", "")
            else
                target.text = "{\\q2}" .. target.text
                target.text = target.text:gsub("\\q2}{\\", "\\q2\\")
            end
            changed = true
        end
    end)
    if not changed then return sel, false end
    if opts.create_layer and not opts.replace_mask then
        RheaFoundation.insertCollectedLinesAfter(lines, additions, true)
        return insertedMaskSelection(sel, additions), true
    end
    lines:replaceLines()
    return sel, true
end

local function cleanAllDLines(subs, sel)
    return RheaFoundation.cleanByMarker(subs, sel, "all", "DR", L("msg_delete_dr_marked"), L("msg_no_dr_marked"))
end

local function cleanSelectedDLines(subs, sel)
    return RheaFoundation.cleanByMarker(subs, sel, "sel", "DR", nil, L("msg_no_dr_marked_selection"))
end

local function dr_dispatch(subs, sel, opts)
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return nil, false end
    local cfg = DR_CONFIG.read()
    cfg = FunctionalTable.union(opts or {}, cfg, DR_DEFAULTS)
    if cfg.op == "clean" then return cleanAllDLines(subs, sel) end
    local newSel, changed = applyMask(subs, sel, cfg)
    DR_CONFIG.write(cfg)
    if changed then aegisub.set_undo_point("Rhea Signs - Masks Apply") end
    return newSel, changed == true
end
RheaOps.Masks.run = dr_dispatch
RheaOps.Masks.maskNames = function() local _, names = loadMaskLibrary(); return names end
RheaOps.Masks.defaults = DR_DEFAULTS
RheaOps.Masks.loadConfig = DR_CONFIG.read
RheaOps.Masks.saveConfig = DR_CONFIG.write
RheaOps.Masks.saveMask = saveMask
RheaOps.Masks.deleteMask = deleteMask
RheaOps.Masks.cleanAll = cleanAllDLines
RheaOps.Masks.cleanSelected = cleanSelectedDLines

end

do
-- RheaOps.Sign
local sioMarkers = RheaFoundation.markerTools("SiO")
local generateMarkerID = sioMarkers.next
local _so_reset = sioMarkers.reset
local stampEffect = sioMarkers.stamp

local SIGN_GEOM_TAGS = {"clip","iclip","pos","move","org","an","frx","fry","frz","fr","fax","fay"}
local function stripGeneratedGeometry(tags)
    return RheaFoundation.removeTags(tostring(tags or ""), SIGN_GEOM_TAGS)
end

local function tagsWithGeometry(tags, geom)
    local tgStr = stripGeneratedGeometry(tags):gsub("}$", "")
    if tgStr ~= "" and not tgStr:match("^{") then tgStr = "{" .. tgStr end
    return (tgStr ~= "" and tgStr or "{") .. geom .. "}"
end


local DEFAULTS = {
    type_mode = "Frame",
    circ_rot = "Normal",
    circ_radio = 0,
    circ_track = 0,
    circ_invert = false,
    circ_delete = false
}

local SIGN_TYPE_ITEMS = {"Frame", "Duration"}
local SIGN_ROT_ITEMS = {"Normal", "Invertido", "Vertical"}
local SIGN_TYPE_ALIASES = { ["Duracion"] = "Duration", ["Duracao"] = "Duration" }
local SIGN_ROT_ALIASES = { ["Inverted"] = "Invertido" }

local function normalizeSignConfig(cfg)
    cfg = FunctionalTable.union(cfg or {}, DEFAULTS)
    cfg.type_mode = RheaFoundation.chooseAlias(cfg.type_mode, SIGN_TYPE_ALIASES, SIGN_TYPE_ITEMS, DEFAULTS.type_mode)
    cfg.circ_rot = RheaFoundation.chooseAlias(cfg.circ_rot, SIGN_ROT_ALIASES, SIGN_ROT_ITEMS, DEFAULTS.circ_rot)
    return cfg
end

local SO_CONFIG = RheaConfig.section("so", DEFAULTS)

local function prepareSignLine(subs, meta, styles, line)
    local ok = pcall(karaskel.preproc_line, subs, meta, styles, line)
    if not ok or not line.styleref then
        local style = styles[line.style] or styles["Default"]
        if not style then return false end
        line.styleref = style
        line.text_stripped = Rhea.visibleText(line.text or "")
        local data = RheaFoundation.tryParseLine(line)
        if not data then return false end
        local tags = data:getEffectiveTags(-1, false, true, true).tags
        local pos = tags.position
        line.x = pos and pos.x or 0
        line.y = pos and pos.y or 0
    end
    return line.styleref ~= nil
end

local function applyTypewriter(subs, sel, cfg)
    local usedMarkers = {}
    local cnt = 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        local markerID = generateMarkerID(usedMarkers)
        local head = Rhea.firstBlock(line.text)
        if head ~= "" then
            head = RheaFoundation.removeTags(head, {"alpha","1a","2a","3a","4a","t"})
        end

        local tokens = Rhea.tokenizeVisible(Rhea.stripTags(line.text))
        local nchars = 0
        for _, tk in ipairs(tokens) do if tk.type == "char" then nchars = nchars + 1 end end
        if nchars > 0 then
            local dur = line.end_time - line.start_time
            local mpc = cfg.type_mode == "Frame" and 42 or (dur / nchars)
            local out, idx = {}, 0
            for _, tk in ipairs(tokens) do
                if tk.type == "break" then
                    out[#out + 1] = tk.content
                else
                    local ts = math.floor(idx * mpc)
                    out[#out + 1] = string.format("{\\alpha&HFF&\\t(%d,%d,\\alpha&H00&)}%s", ts, ts + 1, tk.content)
                    idx = idx + 1
                end
            end

            line.text = head .. table.concat(out)
            stampEffect(line, markerID)
            subs[i] = line
            cnt = cnt + 1
        end
    end
    if cnt > 0 then aegisub.set_undo_point("SignOps: Typewriter") end
    return cnt, cnt > 0 and sel or nil
end


local function applyVertical(subs, sel, cfg)
    local usedMarkers = {}
    local meta, styles = karaskel.collect_head(subs, false)
    local lines = LineCollection(subs, sel)
    local replacements = {}
    local cnt = 0
    lines:runCallback(function(_, line)
        local markerID = generateMarkerID(usedMarkers)
        if not prepareSignLine(subs, meta, styles, line) then return end
        local px, py = line.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
        px = tonumber(px) or line.x
        py = tonumber(py) or line.y
        local chars = FunctionalUnicode.toCharTable(line.text_stripped)
        if #chars == 0 then return end
        local head = RheaFoundation.removeTags(Rhea.firstBlock(line.text), {"pos","an"}):gsub("[{}]", "")
        local cy = 0
        local scaleY = tonumber(line.styleref and line.styleref.scale_y) or 100
        local new_lines = {}
        for _, ch in ipairs(chars) do
            local nline = Rhea.cloneLine(line)
            local _, chH = RheaFoundation.textExtents(line.styleref, ch)
            local chh = (tonumber(chH) or 0) * (scaleY / 100)
            nline.text = string.format("{\\an5\\pos(%.1f,%.1f)%s}%s", px, py + cy, head, ch)
            stampEffect(nline, markerID)
            cy = cy + chh
            new_lines[#new_lines + 1] = nline
        end
        if #new_lines > 0 then
            replacements[line] = new_lines
            cnt = cnt + 1
        end
    end, true)
    if cnt <= 0 then return 0 end
    local newSel = RheaFoundation.replaceCollectedLines(lines, replacements, true)
    if cnt > 0 then aegisub.set_undo_point("SignOps: Vertical") end
    return cnt, cnt > 0 and (newSel or sel) or nil
end

local function applyCircle(subs, sel, cfg)
    local usedMarkers = {}
    local meta, styles = karaskel.collect_head(subs, false)
    local lines = LineCollection(subs, sel)
    local replacements, additions = {}, {}
    local cnt = 0
    
    lines:runCallback(function(_, line)
        local markerID = generateMarkerID(usedMarkers)
        if not prepareSignLine(subs, meta, styles, line) then return end
        
        local px, py = line.text:match("\\pos%(([%d%.%-eE%+]+),([%d%.%-eE%+]+)%)")
        local ox, oy = line.text:match("\\org%(([%d%.%-eE%+]+),([%d%.%-eE%+]+)%)")
        if not (px and py and ox and oy) then
        else
            px, py, ox, oy = tonumber(px), tonumber(py), tonumber(ox), tonumber(oy)

            local rad = math.sqrt((px - ox)^2 + (py - oy)^2) + (cfg.circ_radio or 0)
            local ang = RheaFoundation.atan2(py - oy, px - ox)
            if rad >= 1 then
                local parts = Rhea.tokenize(line.text)
                local cur_style = {}
                for k,v in pairs(line.styleref) do cur_style[k]=v end

                local letters = {}
                local aw = 0
                local ht = ""
                local bord_val = tonumber(line.text:match("\\bord([%d%.]+)")) or line.styleref.outline or 0
                local ro = rad + (cur_style.fontsize / 2.2)

                for _, p in ipairs(parts) do
                    if p.type == "tag" then
                        ht = ht .. p.content
                        RheaFoundation.applyInlineStyleTags(cur_style, p.content)
                    elseif p.type ~= "break" then
                        local ch = p.content
                        local w = RheaFoundation.textExtents(cur_style, ch)
                        local sx = cur_style.scale_x / 100
                        local ar = (w * sx) + ((cur_style.spacing or 0) * sx) + (cfg.circ_track or 0) + (bord_val * 2 * sx)
                        local ac = ar / ro
                        table.insert(letters, {char = ch, angle_rad = ac, tags = ht})
                        aw = aw + ac
                    end
                end

                if #letters > 0 then aw = aw - ((cfg.circ_track or 0) / ro) end
                local pd = (py < oy) and 1 or -1
                if cfg.circ_invert then pd = pd * -1 end
                local acur = ang - (pd * (aw / 2))

                local new_lines = {}
                for _, let in ipairs(letters) do
                    if not let.char:match("^%s*$") then
                        local am = acur + (pd * (let.angle_rad / 2))
                        local fx = ox + rad * math.cos(am)
                        local fy = oy + rad * math.sin(am)
                        local rot = -math.deg(am) - 90
                        if cfg.circ_rot == "Vertical" then rot = 0
                        elseif cfg.circ_rot == "Invertido" then rot = rot + 180 end

                        local nline = Rhea.cloneLine(line)
                        local geom = string.format("\\an5\\pos(%.2f,%.2f)\\frz%.2f", fx, fy, rot)
                        nline.text = tagsWithGeometry(let.tags, geom) .. let.char
                        nline.layer = line.layer + 1
                        stampEffect(nline, markerID)
                        table.insert(new_lines, nline)
                    end
                    acur = acur + (pd * let.angle_rad)
                end

                if #new_lines > 0 then
                    if cfg.circ_delete then
                        replacements[line] = new_lines
                    else
                        line.comment = true
                        line.text = "{Origin} " .. line.text
                        additions[line] = new_lines
                    end
                    cnt = cnt + 1
                end
            end
        end
    end)
    if cnt <= 0 then return 0 end
    if cfg.circ_delete then
        local newSel = RheaFoundation.replaceCollectedLines(lines, replacements, true)
        if cnt > 0 then aegisub.set_undo_point("SignOps: Circle") end
        return cnt, newSel or sel
    else
        local newSel = RheaFoundation.insertCollectedLinesAfter(lines, additions, true)
        if cnt > 0 then aegisub.set_undo_point("SignOps: Circle") end
        return cnt, newSel or sel
    end
end


local function parseVectorClip(text)
    return RheaFoundation.clipCommands(RheaFoundation.firstClipTag(text))
end

local function applyCurve(subs, sel, cfg)
    local usedMarkers = {}
    local meta, styles = karaskel.collect_head(subs, false)
    local lines = LineCollection(subs, sel)
    local replacements = {}
    
    local globalClipCmds = nil
    for _, i in ipairs(sel) do
        globalClipCmds = parseVectorClip(subs[i].text)
        if globalClipCmds then break end
    end
    if not globalClipCmds then
        showMsg(L("msg_no_vector_curve"))
        return 0
    end
    local cnt = 0
    
    lines:runCallback(function(_, line)
        local markerID = generateMarkerID(usedMarkers)
        local clipCmds = parseVectorClip(line.text) or globalClipCmds
        local sampledPath, totalLen = RheaFoundation.samplePath(clipCmds, 40)
        if totalLen > 0 then
            if not prepareSignLine(subs, meta, styles, line) then return end

            local parts = Rhea.tokenize(line.text)
            local cur_style = {}
            for k,v in pairs(line.styleref) do cur_style[k]=v end

            local letters = {}
            local total_w = 0
            local ht = ""
            local bord_val = tonumber(line.text:match("\\bord([%d%.]+)")) or line.styleref.outline or 0

            for _, p in ipairs(parts) do
                if p.type == "tag" then
                    ht = ht .. p.content
                    RheaFoundation.applyInlineStyleTags(cur_style, p.content)
                elseif p.type ~= "break" then
                    local ch = p.content
                    local w = RheaFoundation.textExtents(cur_style, ch)
                    local sx = cur_style.scale_x / 100
                    local ar = (w * sx) + ((cur_style.spacing or 0) * sx) + (bord_val * 2 * sx)
                    table.insert(letters, {char = ch, width = ar, tags = ht})
                    total_w = total_w + ar
                end
            end

            local new_lines = {}
            local curDist = (totalLen - total_w) / 2
            for _, let in ipairs(letters) do
                if not let.char:match("^%s*$") then
                    local charCenterDist = curDist + let.width / 2
                    local pathPt = RheaFoundation.pointOnPath(sampledPath, charCenterDist)
                    if pathPt then
                        local rot = -math.deg(pathPt.angle)
                        local px = pathPt.p.x
                        local py = pathPt.p.y

                        local nline = Rhea.cloneLine(line)
                        local geom = string.format("\\an5\\pos(%.2f,%.2f)\\frz%.2f", px, py, rot)
                        nline.text = tagsWithGeometry(let.tags, geom) .. let.char
                        nline.layer = line.layer + 1
                        stampEffect(nline, markerID)
                        table.insert(new_lines, nline)
                    end
                end
                curDist = curDist + let.width
            end

            if #new_lines > 0 then
                replacements[line] = new_lines
                cnt = cnt + 1
            end
        end
    end)
    if cnt <= 0 then return 0 end
    local newSel = RheaFoundation.replaceCollectedLines(lines, replacements, true)
    if cnt > 0 then aegisub.set_undo_point("SignOps: Curve Text") end
    return cnt, newSel or sel
end


local function applyAlign(subs, sel, cfg)
    local usedMarkers = {}
    local clipCmds = nil
    for _, i in ipairs(sel) do
        clipCmds = parseVectorClip(subs[i].text)
        if clipCmds then break end
    end
    if not clipCmds then
        showMsg(L("msg_no_vector_align"))
        return 0
    end
    
    local segs = RheaFoundation.pathSegments(clipCmds, 40)
    if #segs == 0 then
        showMsg(L("msg_no_usable_path_align"))
        return 0
    end
    local cnt = 0
    
    for _, i in ipairs(sel) do
        local line = subs[i]
        local markerID = generateMarkerID(usedMarkers)
        local px, py = line.text:match("\\pos%(%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*,%s*([%+%-]?[%d%.]+[eE%+%-]*)%s*%)")
        if px and py then
            px, py = tonumber(px), tonumber(py)
            local minDist = math.huge
            local bestX, bestY = px, py
            
            local localCmds = parseVectorClip(line.text)
            local targetSegs = segs
            if localCmds then
                local localSegs = RheaFoundation.pathSegments(localCmds, 40)
                if #localSegs > 0 then targetSegs = localSegs end
            end
            
            for _, seg in ipairs(targetSegs) do
                local d, bx, by = RheaFoundation.distanceToSegment(px, py, seg.x1, seg.y1, seg.x2, seg.y2)
                if d < minDist then
                    minDist = d
                    bestX = bx
                    bestY = by
                end
            end
            
            if minDist < math.huge then
                line.text = line.text:gsub("\\pos%b()", string.format("\\pos(%.2f,%.2f)", bestX, bestY), 1)
                stampEffect(line, markerID)
                subs[i] = line
                cnt = cnt + 1
            end
        end
    end
    if cnt > 0 then aegisub.set_undo_point("SignOps: Align") end
    return cnt, cnt > 0 and sel or nil
end


local function cleanSiO(subs, sel)
    local newSel, changed, count = RheaFoundation.cleanByMarker(subs, sel, "all", "SiO", nil, nil, "SignOps: Clean SiO-lines")
    return count or 0, changed and newSel or nil
end


local function so_dispatch(subs, sel, opts)
    if not sel or #sel == 0 then return false end
    _so_reset()
    local cfg = SO_CONFIG.read()
    cfg = normalizeSignConfig(FunctionalTable.union(opts or {}, cfg, DEFAULTS))
    SO_CONFIG.write(cfg)
    local op = opts and opts.op or ""
    local n, newSel = 0, nil
    if     op == "typewriter"    then n, newSel = applyTypewriter(subs, sel, cfg)
    elseif op == "vertical_drop" then n, newSel = applyVertical(subs, sel, cfg)
    elseif op == "circle_text"   then n, newSel = applyCircle(subs, sel, cfg)
    elseif op == "curve_text"    then n, newSel = applyCurve(subs, sel, cfg)
    elseif op == "align_clip"    then n, newSel = applyAlign(subs, sel, cfg)
    elseif op == "clean_sio"     then n, newSel = cleanSiO(subs, sel) end
    n = n or 0
    return n > 0 and (newSel or true) or false, n > 0
end

RheaOps.Sign.run = so_dispatch
RheaOps.Sign.loadConfig = function()
    local cfg = SO_CONFIG.read()
    return normalizeSignConfig(cfg)
end
RheaOps.Sign.defaults = DEFAULTS

end

do

-- RheaOps.Colors
local calMarkers = RheaFoundation.markerTools("CAL")
local generateMarkerID = calMarkers.next
local _cal_reset = calMarkers.reset
local stampEffect = calMarkers.stamp

local DEF = {
    c1="#FFFFFF",c2="#000000",c3="#FF0000",c4="#00FF00",
    bord1=2, bord2=4, bord3=0, bord4=0,
    ub1=true, ub2=false, ub3=false, ub4=false,
    preset="",
}

local CAL_CONFIG = RheaConfig.section("cal", DEF)

local CAL_CONFIG_KEYS = {
    "c1", "c2", "c3", "c4",
    "bord1", "bord2", "bord3", "bord4",
    "ub1", "ub2", "ub3", "ub4",
    "preset",
}

local function cleanCALConfig(cfg)
    local out = {}
    for _, key in ipairs(CAL_CONFIG_KEYS) do
        if cfg and cfg[key] ~= nil then out[key] = cfg[key] end
    end
    return FunctionalTable.union(out, DEF)
end

local function createBorders(subs, sel, cfg)
    local st = Rhea.styleMap(subs)
    local usedMarkers = {}
    local lines = LineCollection(subs, sel, function() return true end)
    local replacements = {}
    lines:runCallback(function(_, l)
        local s=st[l.style] or st["Default"]
        if s then
            if l.text:sub(1,1)~="{" then l.text="{}"..l.text end
            local mid = generateMarkerID(usedMarkers)
            local bl=RheaFoundation.layerOf(l); local dp=1
            local layers={{use=cfg.ub1,sz=cfg.bord1,col=cfg.c1},{use=cfg.ub2,sz=cfg.bord2,col=cfg.c2},
                          {use=cfg.ub3,sz=cfg.bord3 or 0,col=cfg.c3},{use=cfg.ub4,sz=cfg.bord4 or 0,col=cfg.c4}}
            for _,ly in ipairs(layers) do if ly.use then dp=dp+1 end end
            local cp={}
            local f=Rhea.cloneLine(l)
            f.text=l.text:gsub("\\bord[%d%.]+","\\bord0")
            if not f.text:match("\\bord") then f.text=Rhea.injectFirst(f.text,"\\bord0") end
            f.layer=bl+dp; stampEffect(f, mid); table.insert(cp,f)
            local ac,cd=0,dp
            for _,ly in ipairs(layers) do
                if ly.use then
                    cd=cd-1; ac=ac+(tonumber(ly.sz) or 0)
                    local b=Rhea.cloneLine(l)
                    b.text=l.text:gsub("\\bord[%d%.]+","\\bord"..ac)
                    if not b.text:match("\\bord") then b.text=Rhea.injectFirst(b.text,"\\bord"..ac) end
                    b.text=Rhea.injectFirst(b.text, "\\1a&HFF&")
                    local cl=Rhea.colorNorm(ly.col)
                    b.text=b.text:gsub("\\3c&H%x+&","")
                    b.text=Rhea.injectFirst(b.text, "\\3c"..cl)
                    b.layer=bl+cd; stampEffect(b, mid); table.insert(cp,b)
                end
            end
            replacements[l] = cp
        end
    end)
    if not next(replacements) then return sel, false end
    return RheaFoundation.replaceCollectedLines(lines, replacements) or sel, true
end

local PRESETS = {
    "Decompose (Fill + Border)",
    "Blur + Glow",
    "Shadtrick (Shadow Layer)",
    "Double Border Blur",
    "Clean Layers (Flatten)",
}

local function normalizeCALPreset(preset)
    return RheaFoundation.choose(preset, PRESETS, PRESETS[1])
end

local function applyPreset(subs, sel, preset, cfg)
    local st = Rhea.styleMap(subs)
    local usedMarkers = {}
    local lines = LineCollection(subs, sel, function() return true end)

    preset = normalizeCALPreset(preset)
    if preset == PRESETS[1] then
        local replacements = {}
        lines:runCallback(function(_, l)
            local s=st[l.style] or st["Default"]
            if s then
                if l.text:sub(1,1)~="{" then l.text="{}"..l.text end
                local mid = generateMarkerID(usedMarkers)
                local fill=Rhea.cloneLine(l)
                fill.text=l.text:gsub("\\bord[%d%.]+","\\bord0")
                if not fill.text:match("\\bord") then fill.text=Rhea.injectFirst(fill.text,"\\bord0") end
                fill.layer=RheaFoundation.layerOf(l)+1; stampEffect(fill, mid)
                local border=Rhea.cloneLine(l)
                border.text=Rhea.injectFirst(l.text, "\\1a&HFF&")
                border.layer=RheaFoundation.layerOf(l); stampEffect(border, mid)
                replacements[l] = {border, fill}
            end
        end)
        if not next(replacements) then return sel, false end
        return RheaFoundation.replaceCollectedLines(lines, replacements) or sel, true

    elseif preset == PRESETS[2] then
        local replacements = {}
        lines:runCallback(function(_, l)
            if l.text:sub(1,1)~="{" then l.text="{}"..l.text end
            local mid = generateMarkerID(usedMarkers)
            local glow=Rhea.cloneLine(l)
            glow.text=l.text:gsub("\\blur[%d%.]+","\\blur3")
            if not glow.text:match("\\blur") then glow.text=Rhea.injectFirst(glow.text,"\\blur3") end
            glow.text=Rhea.injectFirst(glow.text, "\\alpha&H80&")
            glow.layer=RheaFoundation.layerOf(l); stampEffect(glow, mid)
            local fill=Rhea.cloneLine(l)
            if not fill.text:match("\\blur") then fill.text=Rhea.injectFirst(fill.text,"\\blur0.6") end
            fill.layer=RheaFoundation.layerOf(l)+1; stampEffect(fill, mid)
            replacements[l] = {glow, fill}
        end)
        if not next(replacements) then return sel, false end
        return RheaFoundation.replaceCollectedLines(lines, replacements) or sel, true

    elseif preset == PRESETS[3] then
        local changed = false
        local function processTagSection(defaultTags, section, previousAlpha)
            local tags = section:getEffectiveTags(false, false, false).tags
            local tagsToInsert = {}
            local alpha
            if not previousAlpha or tags.alpha1 or previousAlpha == -1 then
                alpha = (tags.alpha1 or defaultTags.alpha1):getTagParams()
            else
                alpha = previousAlpha
            end
            for i = #section.tags, 1, -1 do
                local tagStr = section.tags[i]:toString()
                if not tagStr:find("^\\t") then
                    if tagStr:find("alpha") then
                        alpha = tags.alpha:getTagParams()
                        break
                    elseif tagStr:find("1a") then
                        break
                    end
                end
            end
            if not previousAlpha or tags.color1 then
                local colorParams = { (tags.color1 or defaultTags.color1):getTagParams() }
                table.insert(tagsToInsert, ASS:createTag("color4", unpack(colorParams)))
            end
            if not previousAlpha then
                table.insert(tagsToInsert, ASS:createTag("alpha", 0xFF))
                table.insert(tagsToInsert, ASS:createTag("alpha4", alpha))
                table.insert(tagsToInsert, ASS:createTag("shadow_x", 0.001))
                table.insert(tagsToInsert, ASS:createTag("k_bord", 0))
            elseif previousAlpha ~= alpha and (tags.alpha1 or tags.alpha) then
                table.insert(tagsToInsert, ASS:createTag("alpha4", alpha))
            end
            section:removeTags({"alpha", "alpha1", "alpha3", "alpha4", "color1", "color3",
                                "color4", "k_bord", "shadow", "shadow_x", "shadow_y"})
            section:insertTags(tagsToInsert, 1)
            return alpha
        end
        lines:runCallback(function(_, line)
            local data = RheaFoundation.tryParseLine(line)
            if not data then return end
            local previousAlpha
            local defaultTags = data:getDefaultTags().tags
            data:callback(function(section)
                previousAlpha = processTagSection(defaultTags, section, previousAlpha)
                section:callback(function(tag)
                    local hasAlpha = #tag.tags:getTags({"alpha", "alpha1"}) > 0
                    processTagSection(defaultTags, tag.tags, previousAlpha)
                    if hasAlpha then previousAlpha = -1 end
                end, "transform")
            end, ASS.Section.Tag)
            data:cleanTags(nil, nil, nil)
            data:commit(line)
            changed = true
        end)
        if changed then lines:replaceLines() end
        return sel, changed

    elseif preset == PRESETS[4] then
        local replacements = {}
        lines:runCallback(function(_, l)
            local s=st[l.style] or st["Default"]
            if s then
                if l.text:sub(1,1)~="{" then l.text="{}"..l.text end
                local mid = generateMarkerID(usedMarkers)
                local bv=tonumber(l.text:match("\\bord([%d%.]+)")) or s.outline or 2
                local top=Rhea.cloneLine(l)
                top.text=l.text:gsub("\\bord[%d%.]+","\\bord0")
                if not top.text:match("\\bord") then top.text=Rhea.injectFirst(top.text,"\\bord0") end
                top.layer=RheaFoundation.layerOf(l)+2; stampEffect(top, mid)
                local mid_l=Rhea.cloneLine(l)
                mid_l.text=Rhea.injectFirst(l.text, "\\1a&HFF&")
                if not mid_l.text:match("\\blur") then mid_l.text=Rhea.injectFirst(mid_l.text,"\\blur0.4") end
                mid_l.layer=RheaFoundation.layerOf(l)+1; stampEffect(mid_l, mid)
                local bot=Rhea.cloneLine(l)
                bot.text=l.text:gsub("\\bord[%d%.]+","\\bord"..(bv*2))
                if not bot.text:match("\\bord") then bot.text=Rhea.injectFirst(bot.text,"\\bord"..(bv*2)) end
                bot.text=Rhea.injectFirst(bot.text, "\\1a&HFF&\\blur2")
                bot.layer=RheaFoundation.layerOf(l); stampEffect(bot, mid)
                replacements[l] = {bot, mid_l, top}
            end
        end)
        if not next(replacements) then return sel, false end
        return RheaFoundation.replaceCollectedLines(lines, replacements) or sel, true

    elseif preset == PRESETS[5] then
        local changed = false
        lines:runCallback(function(_, l)
            local oldText, oldLayer = l.text, l.layer
            l.text = RheaFoundation.removeTags(l.text, {"1a","4a","alpha"})
            l.layer=0
            if l.text ~= oldText or l.layer ~= oldLayer then changed = true end
        end)
        if changed then lines:replaceLines() end
        return sel, changed
    end
    return sel, false
end

local function cleanCAL(subs, sel)
    return RheaFoundation.cleanByMarker(subs, sel, "all", "CAL", L("msg_delete_cal_marked"), L("msg_no_cal_marked"), function(count)
        return string.format("CAL: clean %d lines", count)
    end)
end

local function cal_dispatch(subs, sel, opts)
    if not sel or #sel == 0 then return nil, false end
    _cal_reset()
    local cfg = CAL_CONFIG.read()
    cfg = cleanCALConfig(FunctionalTable.union(opts or {}, cfg, DEF))
    cfg.preset = normalizeCALPreset(cfg.preset)
    CAL_CONFIG.write(cfg)
    local op = opts and opts.op or ""
    local result = sel
    local changed = false
    if     op == "borders"   then result, changed = createBorders(subs, sel, cfg)
    elseif op == "preset"    then result, changed = applyPreset(subs, sel, cfg.preset or PRESETS[1], cfg)
    elseif op == "clean_cal" then result, changed = cleanCAL(subs, sel) end
    if changed and op ~= "clean_cal" then aegisub.set_undo_point("Rhea Signs - Color Layers: " .. (op ~= "" and op or "?")) end
    return result, changed == true
end

RheaOps.Colors.run = cal_dispatch
RheaOps.Colors.loadConfig = function()
    local cfg = CAL_CONFIG.read()
    cfg = cleanCALConfig(FunctionalTable.union(cfg, DEF))
    cfg.preset = normalizeCALPreset(cfg.preset)
    return cfg
end
RheaOps.Colors.presets = PRESETS

end

do


-- RheaOps.Tools.MassSigns
local function detectLerpTag(text)
    return RheaFoundation.detectGBCTag(text) or "color1"
end

local function processLine(line, newVisible, doLerp)
    local sourceText = line.text or ""
    local cleanText = RheaFoundation.stripAutoMarkers(sourceText)
    if cleanText ~= sourceText then line.text = cleanText end
    local ass = RheaFoundation.tryParseLine(line)
    if not ass then return false end
    if newVisible ~= nil then
        if RheaFoundation.replaceVisibleText(ass, newVisible) then
            ass:commit(line)
            ass = RheaFoundation.tryParseLine(line)
            if not ass then return false end
        end
    end
    local regenerated = false
    local protectedBreaks = false
    if doLerp then
        local protectedText = Rhea.protectVisibleBreaks(line.text)
        if protectedText ~= line.text then
            line.text = protectedText
            protectedBreaks = true
            ass = RheaFoundation.tryParseLine(line)
            if not ass then
                line.text = Rhea.restoreVisibleBreaks(line.text)
                return false
            end
        end
        regenerated = RheaFoundation.lerpLine(ass, detectLerpTag(sourceText))
    end
    ass:commit(line)
    if protectedBreaks then line.text = Rhea.restoreVisibleBreaks(line.text) end
    return regenerated
end

local function groupVisible(lines, opts)
    local records, order, groups = {}, {}, {}
    local stats = { omit_vec = 0, omit_cap = 0 }
    local skipVec = opts.skip_vec
    local useCap, capLimit = opts.use_cap, opts.cap_limit or 150
    lines:runCallback(function(_, line, i)
        if not line.text or line.text == "" then return end
        if skipVec and Rhea.isVectorLine(line.text) then
            stats.omit_vec = stats.omit_vec + 1; return
        end
        local cleanText = RheaFoundation.stripAutoMarkers(line.text)
        local ass = RheaFoundation.tryParseLine(cleanText)
        if not ass then return end
        local visible = RheaFoundation.visibleFromASS(ass)
        if visible == "" then return end
        if useCap and #visible > capLimit then
            stats.omit_cap = stats.omit_cap + 1; return
        end
        local isGBC = line.text:find("{*", 1, true) ~= nil
        records[#records + 1] = { visible = visible, line = line, idx = i, isGBC = isGBC }
    end)
    local grouped = FunctionalList.groupBy(records, "visible")
    for _, record in ipairs(records) do
        if not groups[record.visible] then
            groups[record.visible] = grouped[record.visible]
            order[#order + 1] = record.visible
        end
    end
    return groups, order, stats
end

local function main(sub, sel)
    resolveConfig()
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return false end

    local cfgDlg = {
        {class="label", x=0, y=0, width=4, height=1, label=L("signs_editor_title")},
        {class="checkbox", x=0, y=1, width=3, name="skip_vec", label=L("signs_skip_vec"), value=true},
        {class="checkbox", x=0, y=2, width=3, name="auto_gbc", label=L("signs_auto_gbc"), value=true},
        {class="checkbox", x=0, y=3, width=2, name="use_cap", label=L("signs_use_cap"), value=false},
        {class="intedit", x=2, y=3, width=1, name="cap_limit", value=150, min=1, max=5000},
    }

    local continue, cancel = L("btn_continue"), L("btn_cancel")
    local btn1, res1 = aegisub.dialog.display(cfgDlg, {continue, cancel}, {ok=continue, close=cancel})
    if btn1 ~= continue then return false end

    local lines = LineCollection(sub, sel)
    local groups, order, stats = groupVisible(lines, res1)

    if #order == 0 then
        showMsg(L("signs_no_editable"))
        return false
    end

    local gbcCount, totalGrouped = 0, 0
    for _, vis in ipairs(order) do
        for _, d in ipairs(groups[vis]) do
            totalGrouped = totalGrouped + 1
            if d.isGBC then gbcCount = gbcCount + 1 end
        end
    end

    local originalText = table.concat(order, "\n")
    local info = string.format(L("signs_info"), #order, totalGrouped, gbcCount)
    if stats.omit_vec > 0 then info = info .. string.format(L("signs_skipped_vectors"), stats.omit_vec) end
    if stats.omit_cap > 0 then info = info .. string.format(L("signs_skipped_over_limit"), stats.omit_cap) end

    local editDlg = {
        {class="label", x=0, y=0, width=40, height=1, label=L("signs_original")},
        {class="textbox", x=0, y=1, width=40, height=14, name="original", text=originalText},
        {class="label", x=41, y=0, width=40, height=1, label=L("signs_modified")},
        {class="textbox", x=41, y=1, width=40, height=14, name="modified", text=originalText},
        {class="label", x=0, y=15, width=81, height=1, label=info},
        {class="checkbox", x=0, y=16, width=40, name="do_gbc", label=L("signs_regen_gbc"), value=res1.auto_gbc},
    }

    local apply = L("btn_apply")
    local btn2, res2 = aegisub.dialog.display(editDlg, {apply, cancel}, {ok=apply, close=cancel})
    if btn2 ~= apply then return false end

    local modifiedLines = {}
    for line in (res2.modified .. "\n"):gmatch("([^\r\n]*)\r?\n") do
        table.insert(modifiedLines, line)
    end
    while #modifiedLines > #order and modifiedLines[#modifiedLines] == "" do
        table.remove(modifiedLines)
    end

    if #modifiedLines ~= #order then
        showMsg(string.format(L("signs_line_mismatch"), #order, #modifiedLines))
        return false
    end

    local remap = {}
    for i, orig in ipairs(order) do remap[orig] = modifiedLines[i] end

    local modCount, gbcRegen = 0, 0
    for vis, dataList in pairs(groups) do
        local newVis = remap[vis]
        if newVis and newVis ~= vis then
            for _, d in ipairs(dataList) do
                local regenerated = processLine(d.line, newVis, d.isGBC and res2.do_gbc)
                if regenerated then gbcRegen = gbcRegen + 1 end
                modCount = modCount + 1
            end
        end
    end
    lines:replaceLines()

    aegisub.set_undo_point("Signs Editor")
    return true
end


RheaOps.Tools.massSigns = main
end


-- RheaOps.Tools.FastSigns
local function fastSignsCleanText(text)
    local cleaned = Rhea.stripTags(text):gsub("\\n", "\\N")
    cleaned = cleaned:gsub("%s*\\N%s*", "\\N"):gsub("^\\N+", ""):gsub("\\N+$", "")
    return cleaned
end

local function fastSignsRes(meta)
    local xres = tonumber(meta and meta.res_x) or 1920
    local yres = tonumber(meta and meta.res_y) or 1080
    if xres == 0 then xres = 1920 end
    if yres == 0 then yres = 1080 end
    return xres, yres
end

local function fastSignsMeasure(line, style, text)
    local bw, bh = RheaFoundation.lineBoundsSize(line, text, style)
    return bw or 0, bh or ((style and style.fontsize) or 0)
end

local function fastSignsRect(w, h)
    local wi = math.floor((tonumber(w) or 0) + 0.5)
    local hi = math.floor((tonumber(h) or 0) + 0.5)
    return string.format("m 0 0 l %d 0 l %d %d l 0 %d", wi, wi, hi, hi)
end

local function fastSignsEffect(effect, marker)
    local cleaned = tostring(effect or ""):gsub("%[FS%-%d+%]", "")
    cleaned = Rhea.trim(cleaned):gsub("%s+", " ")
    return cleaned ~= "" and (marker .. " " .. cleaned) or marker
end

local function fastSignsConfig()
    local cfg = {}
    for k, v in pairs(DEFAULT_CONFIG) do
        if tostring(k):match("^fastsign_") then cfg[k] = current_config[k] ~= nil and current_config[k] or v end
    end
    cfg.fastsign_box_alpha = RheaFoundation.sanitizeAlpha(cfg.fastsign_box_alpha, DEFAULT_CONFIG.fastsign_box_alpha)
    cfg.fastsign_glow_alpha = RheaFoundation.sanitizeAlpha(cfg.fastsign_glow_alpha, DEFAULT_CONFIG.fastsign_glow_alpha)
    cfg.fastsign_fade_ms = RheaFoundation.configNumber(cfg.fastsign_fade_ms, DEFAULT_CONFIG.fastsign_fade_ms, 0)
    cfg.fastsign_margin_h = RheaFoundation.configNumber(cfg.fastsign_margin_h, DEFAULT_CONFIG.fastsign_margin_h, 0)
    cfg.fastsign_margin_v = RheaFoundation.configNumber(cfg.fastsign_margin_v, DEFAULT_CONFIG.fastsign_margin_v, 0)
    cfg.fastsign_top_offset = RheaFoundation.configNumber(cfg.fastsign_top_offset, DEFAULT_CONFIG.fastsign_top_offset, 0)
    cfg.fastsign_horz_gap = RheaFoundation.configNumber(cfg.fastsign_horz_gap, DEFAULT_CONFIG.fastsign_horz_gap, 0)
    cfg.fastsign_max_width = RheaFoundation.configNumber(cfg.fastsign_max_width, DEFAULT_CONFIG.fastsign_max_width, 10, 100)
    cfg.fastsign_box_blur = RheaFoundation.configNumber(cfg.fastsign_box_blur, DEFAULT_CONFIG.fastsign_box_blur, 0)
    cfg.fastsign_glow_border = RheaFoundation.configNumber(cfg.fastsign_glow_border, DEFAULT_CONFIG.fastsign_glow_border, 0)
    cfg.fastsign_glow_blur = RheaFoundation.configNumber(cfg.fastsign_glow_blur, DEFAULT_CONFIG.fastsign_glow_blur, 0)
    cfg.fastsign_text_blur = RheaFoundation.configNumber(cfg.fastsign_text_blur, DEFAULT_CONFIG.fastsign_text_blur, 0)
    return cfg
end

local function runFastSigns(subs, sel)
    resolveConfig()
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return end
    local cfg = fastSignsConfig()
    local meta, styles = karaskel.collect_head(subs, false)
    local vid_w = fastSignsRes(meta)
    local clusters = {}
    local rawCandidates = {}
    local lines = LineCollection(subs, sel, function() return true end)
    lines:runCallback(function(_, line)
        if line.text and line.text ~= "" then
            local clean = fastSignsCleanText(line.text)
            rawCandidates[#rawCandidates + 1] = { idx = line.number, line = line, clean = clean }
        end
    end)
    local candidates = FunctionalList.filter(rawCandidates, function(item)
        return item.clean ~= "" and not item.clean:match("^%s*$")
    end)
    table.sort(candidates, function(a, b)
        local as, bs = a.line.start_time or 0, b.line.start_time or 0
        local ae, be = a.line.end_time or 0, b.line.end_time or 0
        if as ~= bs then return as < bs end
        if ae ~= be then return ae < be end
        return a.idx < b.idx
    end)
    for seq, item in ipairs(candidates) do
        local line = item.line
        item.marker = string.format("[FS-%03d]", seq)
        local added = false
        local startTime = line.start_time or 0
        local endTime = line.end_time or startTime
        if #clusters > 0 then
            local last = clusters[#clusters]
            if startTime < last.end_time and endTime > last.start_time then
                last.lines[#last.lines + 1] = item
                last.end_time = math.max(last.end_time, endTime)
                added = true
            end
        end
        if not added then
            clusters[#clusters + 1] = {
                start_time = startTime,
                end_time = endTime,
                lines = { item },
            }
        end
    end
    local outputItems = {}
    for _, cluster in ipairs(clusters) do
        local total_w = 0
        for _, item in ipairs(cluster.lines) do
            local style = styles[item.line.style] or styles.Default
            local text_w, text_h = fastSignsMeasure(item.line, style, item.clean)
            local box_w = math.min(text_w + cfg.fastsign_margin_h * 2, vid_w * (cfg.fastsign_max_width / 100))
            local box_h = text_h + cfg.fastsign_margin_v * 2
            item.box_w, item.box_h = box_w, box_h
            total_w = total_w + box_w
        end
        total_w = total_w + cfg.fastsign_horz_gap * (#cluster.lines - 1)
        local current_x = (vid_w / 2) - (total_w / 2)
        for _, item in ipairs(cluster.lines) do
            item.center_x = current_x + item.box_w / 2
            item.center_y = cfg.fastsign_top_offset + item.box_h / 2
            current_x = current_x + item.box_w + cfg.fastsign_horz_gap
        end
    end
    for _, cluster in ipairs(clusters) do
        for _, item in ipairs(cluster.lines) do outputItems[#outputItems + 1] = item end
    end
    local additions = {}
    for _, item in ipairs(outputItems) do
        local line = item.line
        local marked_effect = fastSignsEffect(line.effect, item.marker)
        local shape_x = item.center_x - item.box_w / 2
        local shape_y = item.center_y - item.box_h / 2
        local box_shape = fastSignsRect(item.box_w, item.box_h)
        local base_layer = line.layer or 0
        local box = Rhea.cloneLine(line)
        local glow = Rhea.cloneLine(line)
        local text = Rhea.cloneLine(line)
        box.layer = base_layer
        box.effect = marked_effect
        box.comment = false
        box.text = string.format("{\\an7\\pos(%.1f,%.1f)\\fad(%d,%d)\\bord0\\shad0\\blur%.2f\\fscx100\\fscy100\\1c%s\\1a&H%s&\\p1}%s",
            shape_x, shape_y, cfg.fastsign_fade_ms, cfg.fastsign_fade_ms, cfg.fastsign_box_blur, Rhea.htmlToAss(cfg.fastsign_box_color), cfg.fastsign_box_alpha, box_shape)
        glow.layer = base_layer + 1
        glow.effect = marked_effect
        glow.comment = false
        glow.text = string.format("{\\an5\\pos(%.1f,%.1f)\\fad(%d,%d)\\bord%.2f\\shad0\\blur%.2f\\1c%s\\3c%s\\1a&HFF&\\3a&H%s&}%s",
            item.center_x, item.center_y, cfg.fastsign_fade_ms, cfg.fastsign_fade_ms, cfg.fastsign_glow_border, cfg.fastsign_glow_blur,
            Rhea.htmlToAss(cfg.fastsign_text_color), Rhea.htmlToAss(cfg.fastsign_glow_color), cfg.fastsign_glow_alpha, item.clean)
        text.layer = base_layer + 2
        text.effect = marked_effect
        text.comment = false
        text.text = string.format("{\\an5\\pos(%.1f,%.1f)\\fad(%d,%d)\\bord0\\shad0\\blur%.2f\\1c%s}%s",
            item.center_x, item.center_y, cfg.fastsign_fade_ms, cfg.fastsign_fade_ms, cfg.fastsign_text_blur, Rhea.htmlToAss(cfg.fastsign_text_color), item.clean)
        line.comment = true
        line.effect = marked_effect
        additions[line] = {box, glow, text}
    end
    RheaFoundation.insertCollectedLinesAfter(lines, additions)
    aegisub.set_undo_point("Rhea Signs - FastSigns")
end

RheaOps.Tools.fastSigns = runFastSigns


-- RheaOps.TagOps
local TagOps = RheaOps.TagOps

local TAGOPS_DEFS = {
    { key="pos",   label="pos",    names={"pos"},        remove={"pos","move"},    animatable=false },
    { key="move",  label="move",   names={"move"},       remove={"move","pos"},    animatable=false },
    { key="org",   label="org",    names={"org"},        remove={"org"},           animatable=false },
    { key="clip",  label="clip",   names={"clip"},       remove={"clip","iclip"},  animatable=true  },
    { key="iclip", label="iclip",  names={"iclip"},      remove={"iclip","clip"},  animatable=true  },
    { key="fad",   label="fad",    names={"fad"},        remove={"fad","fade"},    animatable=false },
    { key="fade",  label="fade",   names={"fade"},       remove={"fade","fad"},    animatable=false },
    { key="t",     label="t",      names={"t"},          remove={"t"},             animatable=false },
    { key="r",     label="r",      names={"r"},          remove={"r"},             animatable=false },
    { key="an",    label="an",     names={"an"},         remove={"an","a"},        animatable=false },
    { key="a",     label="a",      names={"a"},          remove={"a","an"},        animatable=false },
    { key="q",     label="q",      names={"q"},          remove={"q"},             animatable=false },
    { key="fn",    label="fn",     names={"fn"},         remove={"fn"},            animatable=false },
    { key="fs",    label="fs",     names={"fs"},         remove={"fs"},            animatable=true  },
    { key="fsp",   label="fsp",    names={"fsp"},        remove={"fsp"},           animatable=true  },
    { key="fscx",  label="fscx",   names={"fscx"},       remove={"fscx"},          animatable=true  },
    { key="fscy",  label="fscy",   names={"fscy"},       remove={"fscy"},          animatable=true  },
    { key="frz",   label="frz/fr", names={"frz","fr"},   remove={"frz","fr"},      animatable=true  },
    { key="frx",   label="frx",    names={"frx"},        remove={"frx"},           animatable=true  },
    { key="fry",   label="fry",    names={"fry"},        remove={"fry"},           animatable=true  },
    { key="fax",   label="fax",    names={"fax"},        remove={"fax"},           animatable=true  },
    { key="fay",   label="fay",    names={"fay"},        remove={"fay"},           animatable=true  },
    { key="bord",  label="bord",   names={"bord"},       remove={"bord"},          animatable=true  },
    { key="xbord", label="xbord",  names={"xbord"},      remove={"xbord"},         animatable=true  },
    { key="ybord", label="ybord",  names={"ybord"},      remove={"ybord"},         animatable=true  },
    { key="shad",  label="shad",   names={"shad"},       remove={"shad"},          animatable=true  },
    { key="xshad", label="xshad",  names={"xshad"},      remove={"xshad"},         animatable=true  },
    { key="yshad", label="yshad",  names={"yshad"},      remove={"yshad"},         animatable=true  },
    { key="blur",  label="blur",   names={"blur"},       remove={"blur"},          animatable=true  },
    { key="be",    label="be",     names={"be"},         remove={"be"},            animatable=true  },
    { key="b",     label="b",      names={"b"},          remove={"b"},             animatable=false },
    { key="i",     label="i",      names={"i"},          remove={"i"},             animatable=false },
    { key="u",     label="u",      names={"u"},          remove={"u"},             animatable=false },
    { key="s",     label="s",      names={"s"},          remove={"s"},             animatable=false },
    { key="c",     label="c/1c",   names={"c","1c"},     remove={"c","1c"},        animatable=true  },
    { key="2c",    label="2c",     names={"2c"},         remove={"2c"},            animatable=true  },
    { key="3c",    label="3c",     names={"3c"},         remove={"3c"},            animatable=true  },
    { key="4c",    label="4c",     names={"4c"},         remove={"4c"},            animatable=true  },
    { key="alpha", label="alpha",  names={"alpha"},      remove={"alpha"},         animatable=true  },
    { key="1a",    label="1a",     names={"1a"},         remove={"1a"},            animatable=true  },
    { key="2a",    label="2a",     names={"2a"},         remove={"2a"},            animatable=true  },
    { key="3a",    label="3a",     names={"3a"},         remove={"3a"},            animatable=true  },
    { key="4a",    label="4a",     names={"4a"},         remove={"4a"},            animatable=true  },
    { key="k",     label="k",      names={"k"},          remove={"k"},             animatable=false },
    { key="kf",    label="kf/K",   names={"kf","K"},     remove={"kf","K"},        animatable=false },
    { key="ko",    label="ko",     names={"ko"},         remove={"ko"},            animatable=false },
    { key="p",     label="p",      names={"p"},          remove={"p"},             animatable=false },
    { key="pbo",   label="pbo",    names={"pbo"},        remove={"pbo"},           animatable=false },
    { key="fe",    label="fe",     names={"fe"},         remove={"fe"},            animatable=false },
}

local TAGOPS_BY_KEY, TAGOPS_NAME_TO_KEYS = {}, {}
for _, def in ipairs(TAGOPS_DEFS) do
    TAGOPS_BY_KEY[def.key] = def
    for _, n in ipairs(def.names) do
        TAGOPS_NAME_TO_KEYS[n] = TAGOPS_NAME_TO_KEYS[n] or {}
        TAGOPS_NAME_TO_KEYS[n][#TAGOPS_NAME_TO_KEYS[n] + 1] = def.key
    end
end
TagOps.U.alert = showMsg

local TAGOPS_CLIP_AXIS_CHOICES = {"x", "y"}
local TAGOPS_ANGLE_CHOICES = {"Transform angle", "First angle"}
local TAGOPS_CLIP_HOTKEY_CHOICES = {
    "Calibrate clip X", "Calibrate clip Y", "Rectangle from diagonal", "Toggle clip/iclip", "Copy clip/iclip"
}
local TAGOPS_CLIP_SCALE_TAGS = {"fs", "fsp", "bord", "xbord", "ybord", "shad", "xshad", "yshad", "blur", "be", "pbo"}

local function tagopsAppendLeadingTags(text, payload)
    text = tostring(text or "")
    payload = tostring(payload or "")
    if payload == "" then return text end
    local pos, lastClose, leadingClose = 1, nil, nil
    while text:sub(pos, pos) == "{" do
        local close = text:find("}", pos + 1, true)
        if not close then break end
        leadingClose = close
        if text:sub(pos + 1, pos + 1) ~= "*" then lastClose = close end
        pos = close + 1
    end
    if lastClose then
        return text:sub(1, lastClose - 1) .. payload .. "}" .. text:sub(lastClose + 1)
    end
    if leadingClose then
        return text:sub(1, leadingClose) .. "{" .. payload .. "}" .. text:sub(leadingClose + 1)
    end
    return "{" .. payload .. "}" .. text
end

local function tagopsReadNumericTags(text)
    local out = {}
    for _, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        for _, tag in ipairs(RheaFoundation.parseTagBlock(block.content)) do
            if tag.name ~= "t" then
                local key = tag.name == "fr" and "frz" or tag.name
                local nums = RheaFoundation.tagNumbers(tag.value)
                if nums[1] then out[key] = nums[1] end
            end
        end
    end
    return out
end

local function tagopsLineScaleDefault(line, axis)
    local style = line and (line.styleref or line.styleRef)
    if style then
        if axis == "y" and style.scale_y then return tonumber(style.scale_y) or 100 end
        if axis ~= "y" and style.scale_x then return tonumber(style.scale_x) or 100 end
    end
    return 100
end

local function tagopsClipTransformText(line, segs, opts)
    local d1, d2 = RheaFoundation.segmentLength(segs[1]), RheaFoundation.segmentLength(segs[2])
    if d1 == 0 then return nil, nil, "zero" end
    local ratio = d2 / d1
    local axis = opts.clip_axis == "y" and "y" or "x"
    local scaleTag = axis == "y" and "fscy" or "fscx"
    local nums = tagopsReadNumericTags(line.text or "")
    local baseScale = nums[scaleTag] or tagopsLineScaleDefault(line, axis)
    local f = Rhea.formatNum
    local baseParts = { "\\" .. scaleTag .. f(baseScale, 4) }
    local finalParts = { "\\" .. scaleTag .. f(baseScale * ratio, 4) }
    local angleMode = opts.angle_mode or ""
    local a1, a2 = RheaFoundation.segmentAngle(segs[1]), RheaFoundation.segmentAngle(segs[2])

    if angleMode == "Transform angle" or angleMode == "First angle" then
        baseParts[#baseParts + 1] = "\\frz" .. f(a1, 2)
    end
    for _, tag in ipairs(TAGOPS_CLIP_SCALE_TAGS) do
        if nums[tag] ~= nil then
            finalParts[#finalParts + 1] = "\\" .. tag .. f(nums[tag] * ratio, 4)
        end
    end
    if angleMode == "Transform angle" then
        finalParts[#finalParts + 1] = "\\frz" .. f(a2, 2)
    end

    local dur = math.max(0, (tonumber(line.end_time) or 0) - (tonumber(line.start_time) or 0))
    local payload = table.concat(baseParts) .. RheaFoundation.transformTag(0, dur, table.concat(finalParts))
    return tagopsAppendLeadingTags(line.text or "", payload), {
        d1 = d1, d2 = d2, ratio = ratio, a1 = a1, a2 = a2, axis = axis,
    }
end

local function tagopsClipMoveCount(cmds)
    local n = 0
    for _, cmd in ipairs(cmds or {}) do
        if cmd.type == "m" then n = n + 1 end
    end
    return n
end

local function tagopsFirstClipSegments(line, count)
    local clip = RheaFoundation.firstClipTag(line)
    if not clip then return nil, nil, nil, "no_clip" end
    local cmds = RheaFoundation.clipCommands(clip)
    if not cmds then return nil, nil, clip, "bad_clip" end
    local segs = RheaFoundation.firstPathSegments(cmds, count or 2, 8)
    if #segs == 0 then return nil, cmds, clip, "few_segments" end
    return segs, cmds, clip
end

local function tagopsClipScaleReference(subs, sel)
    local clipped, singleLine = {}, nil
    for _, i in ipairs(sel or {}) do
        local line = subs[i]
        if Rhea.isDialogue(line) then
            local segs, cmds, clip = tagopsFirstClipSegments(line, 2)
            if segs and #segs > 0 then
                clipped[#clipped + 1] = { index = i, seg = segs[1], clip = clip }
                if not singleLine and #segs >= 2 and tagopsClipMoveCount(cmds) >= 2 then
                    singleLine = { index = i, seg1 = segs[1], seg2 = segs[2], clip = clip }
                end
            end
        end
    end
    if #clipped >= 2 then
        return clipped[1].seg, clipped[2].seg, { mode = "lines", source = clipped[1].index, target = clipped[2].index, clip = clipped[1].clip }
    end
    if singleLine then
        return singleLine.seg1, singleLine.seg2, { mode = "single", source = singleLine.index, clip = singleLine.clip }
    end
    return nil, nil, nil, #clipped == 0 and "no_clip" or "few_segments"
end

function TagOps.opAdjustByClipScale(subs, sel, opts)
    if not sel or #sel == 0 then TagOps.U.alert(L("tagops_err_adjust_select")); return false end
    local seg1, seg2, _meta, err = tagopsClipScaleReference(subs, sel)
    if err == "no_clip" then TagOps.U.alert(L("tagops_no_clip")); return false end
    if err == "bad_clip" then TagOps.U.alert(L("tagops_bad_clip")); return false end
    if err == "few_segments" then TagOps.U.alert(L("tagops_few_segments")); return false end
    local d1, d2 = RheaFoundation.segmentLength(seg1), RheaFoundation.segmentLength(seg2)
    if d1 == 0 then TagOps.U.alert(L("tagops_zero_segment")); return false end

    local adjustOpts = {}
    for k, v in pairs(opts or {}) do adjustOpts[k] = v end
    adjustOpts.amount = (d2 / d1 - 1) * 100
    adjustOpts.mode = "Percent"
    return TagOps.opAdjust(subs, sel, adjustOpts)
end

function TagOps.opMeasure(subs, sel, opts)
    if not sel or #sel == 0 then TagOps.U.alert(L("tagops_err_measure_select")); return false end
    opts = opts or {}
    local transform = opts.clip_axis == "x" or opts.clip_axis == "y"
    local report, misses = {}, {}
    local changed = 0
    for n, i in ipairs(sel) do
        local label = L("tagops_line") .. " " .. tostring(n)
        local line = subs[i]
        local clip = RheaFoundation.firstClipTag(line.text or "")
        if not clip then
            misses[#misses + 1] = label .. ": " .. L("tagops_no_clip")
        else
            local cmds = RheaFoundation.clipCommands(clip)
            if not cmds then
                misses[#misses + 1] = label .. ": " .. L("tagops_bad_clip")
            else
                local segs = RheaFoundation.firstPathSegments(cmds, 2, 8)
                if #segs < 2 then
                    misses[#misses + 1] = label .. ": " .. L("tagops_few_segments")
                else
                    local d1, d2 = RheaFoundation.segmentLength(segs[1]), RheaFoundation.segmentLength(segs[2])
                    if d1 == 0 then
                        misses[#misses + 1] = label .. ": " .. L("tagops_zero_segment")
                    else
                        local pct = d2 / d1 * 100
                        local f = Rhea.formatNum
                        if transform then
                            local nextText, meta, err = tagopsClipTransformText(line, segs, opts)
                            if err == "zero" then
                                misses[#misses + 1] = label .. ": " .. L("tagops_zero_segment")
                            elseif nextText and nextText ~= line.text then
                                line.text = nextText
                                subs[i] = line
                                changed = changed + 1
                                report[#report + 1] = string.format(
                                    "%s [%s]\n%s: %s px @ %s deg\n%s: %s px @ %s deg\n%s: %s%%",
                                    label, RheaFoundation.clipKind(clip), L("tagops_first"), f(meta.d1), f(meta.a1, 2),
                                    L("tagops_second"), f(meta.d2), f(meta.a2, 2), L("tagops_change"), f((meta.ratio - 1) * 100, 2))
                            end
                        else
                            report[#report + 1] = string.format(
                                "%s [%s]\n%s: %s px = 100%%\n%s: %s px = %s%%\n%s: %s px (%s%%)",
                                label, RheaFoundation.clipKind(clip), L("tagops_first"), f(d1), L("tagops_second"), f(d2), f(pct), L("tagops_change"), f(d2 - d1), f(pct - 100))
                        end
                    end
                end
            end
        end
    end
    if transform then
        if changed == 0 then TagOps.U.alert(#misses > 0 and table.concat(misses, "\n") or L("tagops_no_clip_changed")); return false end
        aegisub.set_undo_point("TagOps - Clip Ruler")
        if opts.info then
            local out = #report > 0 and table.concat(report, "\n\n") or string.format(L("tagops_clip_transform_done"), changed)
            if #misses > 0 then out = out .. "\n\n" .. L("tagops_skipped") .. ":\n" .. table.concat(misses, "\n") end
            aegisub.dialog.display({{class="textbox", name="r", text=out, x=0, y=0, width=60, height=18}}, {L("btn_ok")})
        end
        return true
    end
    if #report == 0 then TagOps.U.alert(table.concat(misses, "\n")); return false end
    local out = table.concat(report, "\n\n")
    if #misses > 0 then out = out .. "\n\n" .. L("tagops_skipped") .. ":\n" .. table.concat(misses, "\n") end
    aegisub.dialog.display({{class="textbox", name="r", text=out, x=0, y=0, width=60, height=18}}, {L("btn_ok")})
    return true
end

local function tagopsRemoveNames(selected)
    return FunctionalList.reduce(TAGOPS_DEFS, {}, function(names, def)
        if selected[def.key] then FunctionalList.makeSet(def.remove or def.names, names) end
        return names
    end)
end

local function tagopsExtractTags(text, selected, allBlocks)
    local out, found = {}, {}
    for blockIndex, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        if allBlocks or blockIndex == 1 then
            for _, tag in ipairs(RheaFoundation.parseTagBlock(block.content)) do
                local keys = TAGOPS_NAME_TO_KEYS[tag.name]
                if keys then
                    for _, key in ipairs(keys) do
                        if selected[key] then
                            out[#out + 1] = tag.raw
                            found[key] = true
                            break
                        end
                    end
                end
            end
        end
        if not allBlocks then break end
    end
    return table.concat(out), found
end

local function tagopsHasAnySelected(selected)
    for _ in pairs(selected or {}) do return true end
    return false
end

local function tagopsMergeFound(dst, src)
    for key, value in pairs(src or {}) do
        if value then dst[key] = true end
    end
end

function TagOps.opCopy(subs, sel, opts)
    if not sel or #sel < 2 then TagOps.U.alert(L("tagops_err_copy_select")); return false end
    opts = opts or {}
    local selected = opts.selected or {}
    if not tagopsHasAnySelected(selected) then TagOps.U.alert(L("tagops_err_select_tag")); return false end
    local groups = RheaFoundation.selectionCopyGroups(subs, sel)
    if #groups == 0 then TagOps.U.alert(L("tagops_err_copy_select")); return false end

    local names = tagopsRemoveNames(selected)
    local changed, found = 0, {}
    local anySourceTags = false
    for _, group in ipairs(groups) do
        if #group.targets > 0 then
            local source = subs[group.source]
            local tags, groupFound = tagopsExtractTags(source.text or "", selected, opts.all_blocks)
            if tags ~= "" then
                anySourceTags = true
                tagopsMergeFound(found, groupFound)
                for _, i in ipairs(group.targets) do
                    local line = subs[i]
                    local text = line.text or ""
                    if opts.replace then text = RheaFoundation.removeTags(text, names) end
                    local nextText = RheaFoundation.insertTags(text, tags, opts.append and "append" or nil)
                    if nextText ~= line.text then
                        line.text = nextText
                        subs[i] = line
                        changed = changed + 1
                    end
                end
            end
        end
    end
    if not anySourceTags then TagOps.U.alert(L("tagops_err_source_tag")); return false end
    if changed == 0 then TagOps.U.alert(L("tagops_copy_no_change")); return false end
    aegisub.set_undo_point("TagOps - Copy")
    if opts.info then
        local copied = FunctionalList.map(FunctionalList.filter(TAGOPS_DEFS, function(def)
            return found[def.key]
        end), function(def) return def.label end)
        TagOps.U.alert(string.format("%s: %s\n%s: %d", L("tagops_copied"), table.concat(copied, ", "), L("tagops_targets"), changed))
    end
    return true
end

local function tagopsTagSelected(name, selected)
    local keys = TAGOPS_NAME_TO_KEYS[name]
    if not keys then return false end
    for _, key in ipairs(keys) do if selected[key] then return true end end
    return false
end

local function tagopsIsOverrideBlock(content)
    return tostring(content or ""):match("^[*>]?\\") ~= nil
end

local function tagopsKeepOnlyContent(content, selected)
    content = tostring(content or "")
    local prefix = ""
    local first = content:sub(1, 1)
    if first == "*" or first == ">" then
        prefix = first
        content = content:sub(2)
    end

    local out, pos = {}, 1
    for _, tag in ipairs(RheaFoundation.parseTagBlock(content)) do
        out[#out + 1] = content:sub(pos, tag.startPos - 1)
        if tagopsTagSelected(tag.name, selected) then
            out[#out + 1] = tag.raw
        end
        pos = tag.endPos + 1
    end
    out[#out + 1] = content:sub(pos)

    local cleaned = table.concat(out)
    if cleaned:match("^%s*$") then return "" end
    return prefix .. cleaned
end

local function tagopsKeepOnlyText(text, selected)
    text = tostring(text or "")
    local out, pos = {}, 1
    for _, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        out[#out + 1] = text:sub(pos, block.openPos - 1)
        if tagopsIsOverrideBlock(block.content) then
            local cleaned = tagopsKeepOnlyContent(block.content, selected)
            if cleaned ~= "" then out[#out + 1] = "{" .. cleaned .. "}" end
        else
            out[#out + 1] = text:sub(block.openPos, block.closePos)
        end
        pos = block.closePos + 1
    end
    out[#out + 1] = text:sub(pos)
    return (table.concat(out):gsub("{}", ""))
end

function TagOps.opKeepOnly(subs, sel, opts)
    if not sel or #sel == 0 then TagOps.U.alert(L("tagops_err_adjust_select")); return false end
    opts = opts or {}
    local selected = opts.selected or {}
    if not tagopsHasAnySelected(selected) then TagOps.U.alert(L("tagops_err_select_tag")); return false end

    local changed = 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        if Rhea.isDialogue(line) then
            local nextText = tagopsKeepOnlyText(line.text or "", selected)
            if nextText ~= line.text then
                line.text = nextText
                subs[i] = line
                changed = changed + 1
            end
        end
    end
    if changed == 0 then
        TagOps.U.alert(L("tagops_keep_only_no_change"))
        return false
    end
    aegisub.set_undo_point("TagOps - Keep Only")
    if opts.info then TagOps.U.alert(string.format(L("tagops_keep_only_changed"), changed)) end
    return true
end

local TAGOPS_AUTO_ADJUST_KEYS = {
    fs=true, fsp=true, fscx=true, fscy=true,
    frz=true, frx=true, fry=true, fax=true, fay=true,
    bord=true, xbord=true, ybord=true,
    shad=true, xshad=true, yshad=true,
    blur=true, be=true, pbo=true,
}

local TAGOPS_MANUAL_ADJUST_KEYS = {
    pos=true, move=true, org=true, clip=true, iclip=true,
    fad=true, fade=true, t=true, an=true, a=true, q=true,
    fs=true, fsp=true, fscx=true, fscy=true,
    frz=true, frx=true, fry=true, fax=true, fay=true,
    bord=true, xbord=true, ybord=true,
    shad=true, xshad=true, yshad=true,
    blur=true, be=true, k=true, kf=true, ko=true, pbo=true,
}

local TAGOPS_STYLE_ADJUST_ORDER = {"fs", "fsp", "fscx", "fscy", "bord", "shad"}
local TAGOPS_STYLE_ADJUST = {
    fs   = { tag="fs",   field="fontsize", default=20 },
    fsp  = { tag="fsp",  field="spacing",  default=0  },
    fscx = { tag="fscx", field="scale_x",  default=100 },
    fscy = { tag="fscy", field="scale_y",  default=100 },
    bord = { tag="bord", field="outline",  default=0  },
    shad = { tag="shad", field="shadow",   default=0  },
}

local TAGOPS_NUM_VALUE_PATTERN = "[%+%-]?%d*%.?%d+"
local TAGOPS_PERSPECTIVE_REPROJECT_KEYS = { fs=true, fsp=true, fscx=true, fscy=true }

local function tagopsAdjustKeyForName(name)
    for _, key in ipairs(TAGOPS_NAME_TO_KEYS[name] or {}) do
        if TAGOPS_AUTO_ADJUST_KEYS[key] then return key end
    end
    return nil
end

local function tagopsTransformInner(token)
    local tagStart = tostring(token or ""):find("\\", 4, true)
    if not tagStart then return nil end
    local tagEnd = token:sub(-1) == ")" and #token - 1 or #token
    return token:sub(tagStart, tagEnd)
end

local function tagopsCollectAdjustKeysFromBlock(block, selected)
    for _, tag in ipairs(RheaFoundation.parseTagBlock(block)) do
        if tag.name == "t" then
            local inner = tagopsTransformInner(tag.raw)
            if inner then tagopsCollectAdjustKeysFromBlock(inner, selected) end
        else
            local key = tagopsAdjustKeyForName(tag.name)
            if key and tostring(tag.value or ""):match(TAGOPS_NUM_VALUE_PATTERN) then
                selected[key] = true
            end
        end
    end
end

local function tagopsCollectAdjustKeysFromText(text, selected)
    for _, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        tagopsCollectAdjustKeysFromBlock(block.content, selected)
    end
end

local function tagopsLineStyle(line, styles)
    if not line then return nil end
    return line.styleref or line.styleRef or (styles and (styles[line.style] or styles.Default)) or nil
end

local function tagopsStyleDefaultValue(style, spec)
    if not style or not spec then return nil end
    local value = tonumber(style[spec.field])
    if value == nil then value = spec.default end
    return value
end

local function tagopsCollectStyleAdjustKeys(line, styles, selected)
    local style = tagopsLineStyle(line, styles)
    if not style then return end
    for _, key in ipairs(TAGOPS_STYLE_ADJUST_ORDER) do
        local value = tagopsStyleDefaultValue(style, TAGOPS_STYLE_ADJUST[key])
        if value and math.abs(value) > 1e-9 then selected[key] = true end
    end
end

local function tagopsAutoAdjustSelected(subs, sel, styles)
    local selected = {}
    for _, i in ipairs(sel or {}) do
        local line = subs[i]
        if Rhea.isDialogue(line) then
            tagopsCollectAdjustKeysFromText(line.text or "", selected)
            tagopsCollectStyleAdjustKeys(line, styles, selected)
        end
    end
    return selected
end

local function tagopsResolveAdjustSelected(autoSelected, manualSelected)
    local selected = {}
    for key in pairs(autoSelected or {}) do selected[key] = true end
    for key, value in pairs(manualSelected or {}) do
        if value and TAGOPS_MANUAL_ADJUST_KEYS[key] then
            if selected[key] then
                selected[key] = nil
            else
                selected[key] = true
            end
        end
    end
    return selected
end

local function tagopsAdjustNeedsPerspectiveReproject(selected)
    for key in pairs(TAGOPS_PERSPECTIVE_REPROJECT_KEYS) do
        if selected and selected[key] then return true end
    end
    return false
end

local function tagopsTextHasLeadingName(text, names)
    local set = {}
    for _, name in ipairs(names or {}) do set[name] = true end
    text = tostring(text or "")
    local pos = 1
    while text:sub(pos, pos) == "{" do
        local close = text:find("}", pos + 1, true)
        if not close then break end
        local content = text:sub(pos + 1, close - 1)
        if content:sub(1, 1) ~= "*" then
            for _, tag in ipairs(RheaFoundation.parseTagBlock(content)) do
                if set[tag.name] then return true end
            end
        end
        pos = close + 1
    end
    return false
end

local function tagopsAdjustNumber(raw, amount, mode)
    local n = tonumber(raw)
    if not n then return raw end
    if mode == "Percent" then n = n * (1 + amount / 100) else n = n + amount end
    return Rhea.formatNum(n, 6)
end

local function tagopsAdjustToken(token, amount, mode)
    return (token:gsub("(" .. TAGOPS_NUM_VALUE_PATTERN .. ")", function(n)
        return tagopsAdjustNumber(n, amount, mode)
    end))
end

local function tagopsAdjustBlock(block, selected, amount, mode)
    local function adjustTransformTags(token)
        local tagStart = token:find("\\", 4, true)
        if not tagStart then return token, 0 end
        local tagEnd = token:sub(-1) == ")" and #token - 1 or #token
        local prefix = token:sub(1, tagStart - 1)
        local inner = token:sub(tagStart, tagEnd)
        local suffix = token:sub(tagEnd + 1)
        local nextInner, changed = tagopsAdjustBlock(inner, selected, amount, mode)
        return prefix .. nextInner .. suffix, changed
    end

    local tags = RheaFoundation.parseTagBlock(block)
    if #tags == 0 then return block, 0 end
    local out, pos, changed = {}, 1, 0
    for _, tag in ipairs(tags) do
        out[#out + 1] = block:sub(pos, tag.startPos - 1)
        if tagopsTagSelected(tag.name, selected) then
            local adjusted = tagopsAdjustToken(tag.raw, amount, mode)
            out[#out + 1] = adjusted
            if adjusted ~= tag.raw then changed = changed + 1 end
        elseif tag.name == "t" then
            local adjusted, nc = adjustTransformTags(tag.raw)
            out[#out + 1] = adjusted
            changed = changed + nc
        else
            out[#out + 1] = tag.raw
        end
        pos = tag.endPos + 1
    end
    out[#out + 1] = block:sub(pos)
    return table.concat(out), changed
end

local function tagopsAdjustText(text, selected, amount, mode)
    local out, pos, changed = {}, 1, 0
    for _, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        out[#out + 1] = text:sub(pos, block.openPos - 1)
        local nb, c = tagopsAdjustBlock(block.content, selected, amount, mode)
        if nb ~= "" then out[#out + 1] = "{" .. nb .. "}" end
        changed = changed + c
        pos = block.closePos + 1
    end
    out[#out + 1] = text:sub(pos)
    return table.concat(out), changed
end

local function tagopsInjectStyleAdjustments(text, selected, amount, mode, style)
    local payload = {}
    for _, key in ipairs(TAGOPS_STYLE_ADJUST_ORDER) do
        if selected[key] then
            local spec = TAGOPS_STYLE_ADJUST[key]
            local base = tagopsStyleDefaultValue(style, spec)
            local names = (TAGOPS_BY_KEY[key] and TAGOPS_BY_KEY[key].names) or { spec.tag }
            if base and not tagopsTextHasLeadingName(text, names) then
                local adjusted = tagopsAdjustNumber(tostring(base), amount, mode)
                local adjustedNumber = tonumber(adjusted)
                if adjustedNumber and math.abs(adjustedNumber - base) > 1e-9 then
                    payload[#payload + 1] = "\\" .. spec.tag .. adjusted
                end
            end
        end
    end
    if #payload == 0 then return text, 0 end
    return tagopsAppendLeadingTags(text, table.concat(payload)), #payload
end

function TagOps.opAdjust(subs, sel, opts)
    if not sel or #sel == 0 then TagOps.U.alert(L("tagops_err_adjust_select")); return false end
    opts = opts or {}
    local amount = tonumber(opts.amount)
    if not amount then TagOps.U.alert(L("tagops_err_numeric")); return false end
    local styles = Rhea.styleMap(subs)
    local selected = tagopsResolveAdjustSelected(tagopsAutoAdjustSelected(subs, sel, styles), opts.selected)
    if not tagopsHasAnySelected(selected) then TagOps.U.alert(L("tagops_err_no_adjust_tags")); return false end
    local perspectiveAware = tagopsAdjustNeedsPerspectiveReproject(selected)
    local perspectiveMeta, perspectiveStyles, perspectiveContextLoaded
    local function getPerspectiveContext()
        if not perspectiveContextLoaded then
            if RheaOps.Perspective.context then
                perspectiveMeta, perspectiveStyles = RheaOps.Perspective.context(subs)
            end
            perspectiveMeta = perspectiveMeta or {}
            perspectiveStyles = perspectiveStyles or styles
            perspectiveContextLoaded = true
        end
        return perspectiveMeta, perspectiveStyles
    end
    local linesChanged, tagsChanged = 0, 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        local style = tagopsLineStyle(line, styles)
        local perspectiveQuad, perspectiveStyle, perspectiveMetaForLine, perspectiveStylesForLine
        if perspectiveAware
            and RheaOps.Perspective.isPerspectiveLine
            and RheaOps.Perspective.isPerspectiveLine(line) then
            perspectiveMetaForLine, perspectiveStylesForLine = getPerspectiveContext()
            perspectiveStyle = tagopsLineStyle(line, perspectiveStylesForLine) or style
            if perspectiveStyle and RheaOps.Perspective.captureQuad then
                perspectiveQuad = RheaOps.Perspective.captureQuad(line, perspectiveStyle, perspectiveMetaForLine, perspectiveStylesForLine)
            end
        end
        local nt, c = tagopsAdjustText(line.text or "", selected, amount, opts.mode)
        local injected, injectedCount = tagopsInjectStyleAdjustments(nt, selected, amount, opts.mode, style)
        nt, c = injected, c + injectedCount
        if c > 0 and nt ~= line.text then
            line.text = nt
            if perspectiveQuad and RheaOps.Perspective.reprojectLineToQuad then
                if RheaOps.Perspective.reprojectLineToQuad(line, perspectiveStyle,
                    perspectiveMetaForLine, perspectiveStylesForLine, perspectiveQuad, selected) then
                    c = c + 1
                end
            end
            subs[i] = line
            linesChanged = linesChanged + 1
            tagsChanged = tagsChanged + c
        end
    end
    if linesChanged == 0 then TagOps.U.alert(L("tagops_adjust_no_change")); return false end
    aegisub.set_undo_point("TagOps - Adjust")
    if opts.info then
        TagOps.U.alert(string.format("%s: %d\n%s: %d", L("tagops_lines_changed"), linesChanged, L("tagops_tags_changed"), tagsChanged))
    end
    return true
end

local TAGOPS_TR_CANON = { fr = "frz", ["1c"] = "c" }

local TAGOPS_TR_STATIC = {
    an=true, a=true, q=true, fn=true, r=true,
    b=true, i=true, u=true, s=true,
    p=true, pbo=true, fe=true,
}

local function tagopsCanonical(name) return TAGOPS_TR_CANON[name] or name end

local function tagopsParseTransitionTags(blocks)
    local tags, order = {}, {}
    local text = tostring(blocks or ""):gsub("[{}]", "")
    for _, t in ipairs(RheaFoundation.parseTagBlock(text)) do
        if t.name ~= "t" then
            local key = tagopsCanonical(t.name)
            if not tags[key] then order[#order + 1] = key end
            tags[key] = { name = t.name, key = key, value = t.value, raw = t.raw }
        end
    end
    return tags, order
end

local function tagopsPosition(tags, final)
    local t = tags.pos
    if t then
        local nums = RheaFoundation.tagNumbers(t.value)
        if nums[1] and nums[2] then return { x = nums[1], y = nums[2] } end
    end
    t = tags.move
    if t then
        local nums = RheaFoundation.tagNumbers(t.value)
        if nums[1] and nums[2] and nums[3] and nums[4] then
            return { x = nums[final and 3 or 1], y = nums[final and 4 or 2] }
        end
    end
    return nil
end

local function tagopsFadValue(tag, slot)
    if not tag or tag.key ~= "fad" then return 0 end
    local nums = RheaFoundation.tagNumbers(tag.value)
    return math.max(0, math.floor((nums[slot] or 0) + 0.5))
end

local function tagopsSplitLeadingTagBlocks(text)
    text = tostring(text or "")
    local tagBuf, body, i = {}, "", 1
    while i <= #text do
        local op = text:sub(i, i)
        if op == "{" then
            local cp = text:find("}", i + 1, true)
            if not cp then break end
            tagBuf[#tagBuf + 1] = text:sub(i, cp)
            i = cp + 1
        else
            body = text:sub(i)
            break
        end
    end
    return table.concat(tagBuf), body
end

local function tagopsTagText(tag) return "\\" .. tag.name .. tag.value end

function TagOps.opTransition(subs, sel)
    if not sel or #sel ~= 2 then TagOps.U.alert(L("tagops_err_transition")); return false end
    local sortedSel = { sel[1], sel[2] }
    table.sort(sortedSel)
    local lines = LineCollection(subs, sortedSel, function() return true end)
    local line1, line2
    lines:runCallback(function(_, line)
        if line.number == sortedSel[1] then line1 = line
        elseif line.number == sortedSel[2] then line2 = line end
    end)
    if not (Rhea.isDialogue(line1) and Rhea.isDialogue(line2)) then
        TagOps.U.alert(L("tagops_err_transition")); return false
    end
    local tagsText1, body1 = tagopsSplitLeadingTagBlocks(line1.text)
    local tagsText2, body2 = tagopsSplitLeadingTagBlocks(line2.text)
    local finalText = body1
    if Rhea.stripTags(body1) ~= Rhea.stripTags(body2) then
        local b1, b2, bc = L("tagops_use_line1"), L("tagops_use_line2"), L("btn_cancel")
        local pressed = showMsg(L("tagops_choose_text"), {b1, b2, bc}, {width=50, height=1}, {cancel=bc})
        if pressed == b2 then finalText = body2
        elseif pressed ~= b1 then return false end
    end
    local tags1, order1 = tagopsParseTransitionTags(tagsText1)
    local tags2, order2 = tagopsParseTransitionTags(tagsText2)
    local parts, used = {}, {}
    local pos1, pos2 = tagopsPosition(tags1, false), tagopsPosition(tags2, true)
    local fnum = function(v) return Rhea.formatNum(v, 3) end
    if pos1 and pos2 and (pos1.x ~= pos2.x or pos1.y ~= pos2.y) then
        parts[#parts + 1] = "\\move(" .. fnum(pos1.x) .. "," .. fnum(pos1.y) .. "," .. fnum(pos2.x) .. "," .. fnum(pos2.y) .. ")"
    elseif pos1 then
        parts[#parts + 1] = "\\pos(" .. fnum(pos1.x) .. "," .. fnum(pos1.y) .. ")"
    end
    for _, key in ipairs(order1) do
        local t1, t2 = tags1[key], tags2[key]
        local def = TAGOPS_BY_KEY[key]
        if def and def.animatable then
            parts[#parts + 1] = tagopsTagText(t1)
            if t2 and t1.raw ~= t2.raw then parts[#parts + 1] = "\\t(" .. tagopsTagText(t2) .. ")" end
            used[key] = true
        elseif TAGOPS_TR_STATIC[key] then
            parts[#parts + 1] = tagopsTagText(t1)
            used[key] = true
        end
    end
    for _, key in ipairs(order2) do
        local def = TAGOPS_BY_KEY[key]
        if def and def.animatable and not used[key] then
            parts[#parts + 1] = "\\t(" .. tagopsTagText(tags2[key]) .. ")"
            used[key] = true
        end
    end
    local fadIn  = tagopsFadValue(tags1.fad, 1)
    local fadOut = tagopsFadValue(tags2.fad, 2)
    if fadIn > 0 or fadOut > 0 then parts[#parts + 1] = "\\fad(" .. fadIn .. "," .. fadOut .. ")" end
    local newLine = Rhea.cloneLine(line1)
    newLine.start_time = line1.start_time
    newLine.end_time = line2.end_time
    newLine.comment = false
    newLine.text = (#parts > 0 and ("{" .. table.concat(parts) .. "}") or "") .. finalText
    line1.comment, line2.comment = true, true
    lines:replaceLines()
    lines:addLine(newLine, function() return true end, true, line2.number + 1)
    lines:insertLines()
    aegisub.set_undo_point("TagOps - Transition")
    TagOps.U.alert(L("tagops_transition_done"))
    return true
end

local TAGOPS_NUM_PATTERN = "([%+%-]?%d*%.?%d+)"

local function tagopsCoord(n)
    return Rhea.formatNum(tonumber(n) or 0, 2)
end

local function tagopsShiftPair(x, y, dx, dy, scale)
    scale = scale or 1
    return tagopsCoord((tonumber(x) or 0) + dx * scale), tagopsCoord((tonumber(y) or 0) + dy * scale)
end

local function tagopsShiftPath(path, dx, dy, scale)
    return tostring(path or ""):gsub(TAGOPS_NUM_PATTERN .. "%s+" .. TAGOPS_NUM_PATTERN, function(x, y)
        local nx, ny = tagopsShiftPair(x, y, dx, dy, scale)
        return nx .. " " .. ny
    end)
end

local function tagopsFirstPos(text)
    local x, y = tostring(text or ""):match("\\pos%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*%)")
    if not x or not y then return nil, nil end
    return tonumber(x), tonumber(y)
end

local function tagopsFirstOrg(text)
    local x, y = tostring(text or ""):match("\\org%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*%)")
    if not x or not y then return nil, nil end
    return tonumber(x), tonumber(y)
end

local function tagopsPosAlignDelta(sourceLine, referenceLine, moveGeometry)
    if not (Rhea.isDialogue(sourceLine) and Rhea.isDialogue(referenceLine)) then
        return nil, nil, L("tagops_err_align_select")
    end
    local sourceX, sourceY = tagopsFirstPos(sourceLine.text)
    if not sourceX then return nil, nil, L("tagops_err_source_pos") end
    local referenceX, referenceY = tagopsFirstPos(referenceLine.text)
    if not referenceX then return nil, nil, L("tagops_err_reference_pos") end

    local dx, dy = referenceX - sourceX, referenceY - sourceY
    if dx == 0 and dy == 0 and moveGeometry then
        local sourceOrgX, sourceOrgY = tagopsFirstOrg(sourceLine.text)
        local referenceOrgX, referenceOrgY = tagopsFirstOrg(referenceLine.text)
        if sourceOrgX and referenceOrgX then
            dx, dy = referenceOrgX - sourceOrgX, referenceOrgY - sourceOrgY
        end
    end
    if dx == 0 and dy == 0 then return nil, nil, L("tagops_align_no_delta") end
    return dx, dy, nil
end

local function tagopsShiftAlignText(text, dx, dy, moveGeometry)
    text = tostring(text or "")
    text = text:gsub("\\pos%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*%)", function(x, y)
        local nx, ny = tagopsShiftPair(x, y, dx, dy)
        return "\\pos(" .. nx .. "," .. ny .. ")"
    end)
    if not moveGeometry then return text end

    text = text:gsub("\\move%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "(.-)%)", function(x1, y1, x2, y2, rest)
        local nx1, ny1 = tagopsShiftPair(x1, y1, dx, dy)
        local nx2, ny2 = tagopsShiftPair(x2, y2, dx, dy)
        return "\\move(" .. nx1 .. "," .. ny1 .. "," .. nx2 .. "," .. ny2 .. rest .. ")"
    end)
    text = text:gsub("\\org%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*%)", function(x, y)
        local nx, ny = tagopsShiftPair(x, y, dx, dy)
        return "\\org(" .. nx .. "," .. ny .. ")"
    end)
    text = text:gsub("(\\i?clip)%(%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*,%s*" .. TAGOPS_NUM_PATTERN .. "%s*%)", function(tag, x1, y1, x2, y2)
        local nx1, ny1 = tagopsShiftPair(x1, y1, dx, dy)
        local nx2, ny2 = tagopsShiftPair(x2, y2, dx, dy)
        return tag .. "(" .. nx1 .. "," .. ny1 .. "," .. nx2 .. "," .. ny2 .. ")"
    end)
    text = text:gsub("(\\i?clip)%(%s*(%d+)%s*,%s*m%s+([^%)]+)%)", function(tag, scaleText, path)
        local factor = 2 ^ ((tonumber(scaleText) or 1) - 1)
        return tag .. "(" .. scaleText .. ",m " .. tagopsShiftPath(path, dx, dy, factor) .. ")"
    end)
    text = text:gsub("(\\i?clip)%(%s*m%s+([^%)]+)%)", function(tag, path)
        return tag .. "(m " .. tagopsShiftPath(path, dx, dy) .. ")"
    end)

    local draw = text:match("}m%s+([^{]+)")
    if draw then
        local nextDraw = tagopsShiftPath(draw, dx, dy)
        if nextDraw ~= draw then
            text = text:gsub("}m%s+" .. Rhea.escapePattern(draw), "}m " .. nextDraw, 1)
        end
    end
    return text
end

function TagOps.opPosAlign(subs, sel, opts)
    local indices = RheaFoundation.selectionDialogueIndices(subs, sel)
    if #indices < 2 then TagOps.U.alert(L("tagops_err_align_select")); return false end
    local moveGeometry = opts and opts.align_org == "Move org"
    local sourceIndex, referenceIndex = indices[1], indices[2]
    local dx, dy, err = tagopsPosAlignDelta(subs[sourceIndex], subs[referenceIndex], moveGeometry)
    if err then TagOps.U.alert(err); return false end

    local changed = 0
    for _, i in ipairs(indices) do
        if i ~= referenceIndex then
            local line = subs[i]
            local nextText = tagopsShiftAlignText(line.text or "", dx, dy, moveGeometry)
            if nextText ~= line.text then
                line.text = nextText
                subs[i] = line
                changed = changed + 1
            end
        end
    end
    if changed == 0 then TagOps.U.alert(L("tagops_align_no_delta")); return false end
    aegisub.set_undo_point("TagOps - Pos Align")
    if opts and opts.info then TagOps.U.alert(string.format(L("tagops_align_done"), changed)) end
    return changed > 0
end

local TAGOPS_CLIP_NUM_PATTERN = "([%+%-]?%d*%.?%d+)"

local function tagopsClipVectorParts(value)
    local inner = tostring(value or ""):match("^%((.*)%)$")
    if not inner then return nil, nil end
    local scale, path = inner:match("^%s*(%d+)%s*,%s*([mM]%s+.+)$")
    if path then return scale, path end
    path = inner:match("^%s*([mM]%s+.+)$")
    return nil, path
end

local function tagopsClipTagText(name, scale, path)
    return "\\" .. name .. "(" .. (scale and (scale .. ",") or "") .. tostring(path or "") .. ")"
end

local function tagopsMapClipTags(text, mapper)
    text = tostring(text or "")
    local out, pos, changed = {}, 1, 0
    for _, block in ipairs(RheaFoundation.iterTagBlocks(text)) do
        out[#out + 1] = text:sub(pos, block.openPos - 1)
        local parts, bpos = {}, 1
        for _, tag in ipairs(RheaFoundation.parseTagBlock(block.content)) do
            parts[#parts + 1] = block.content:sub(bpos, tag.startPos - 1)
            local replacement
            if tag.name == "clip" or tag.name == "iclip" then
                replacement = mapper(tag)
            end
            if replacement and replacement ~= tag.raw then
                parts[#parts + 1] = replacement
                changed = changed + 1
            else
                parts[#parts + 1] = tag.raw
            end
            bpos = tag.endPos + 1
        end
        parts[#parts + 1] = block.content:sub(bpos)
        out[#out + 1] = "{" .. table.concat(parts) .. "}"
        pos = block.closePos + 1
    end
    out[#out + 1] = text:sub(pos)
    return table.concat(out), changed
end

local function tagopsCalibrateClipPath(path, axis)
    local pat = "([mM])%s+" .. TAGOPS_CLIP_NUM_PATTERN .. "%s+" .. TAGOPS_CLIP_NUM_PATTERN ..
        "%s+([lL])%s+" .. TAGOPS_CLIP_NUM_PATTERN .. "%s+" .. TAGOPS_CLIP_NUM_PATTERN
    return (tostring(path or ""):gsub(pat, function(m, x1, y1, l, x2, y2)
        if axis == "y" then x2 = x1 else y2 = y1 end
        return string.format("%s %s %s %s %s %s", m, tagopsCoord(x1), tagopsCoord(y1), l, tagopsCoord(x2), tagopsCoord(y2))
    end))
end

local function tagopsRectangleFromDiagonal(path)
    local pat = "([mM])%s+" .. TAGOPS_CLIP_NUM_PATTERN .. "%s+" .. TAGOPS_CLIP_NUM_PATTERN ..
        "%s+([lL])%s+" .. TAGOPS_CLIP_NUM_PATTERN .. "%s+" .. TAGOPS_CLIP_NUM_PATTERN
    local _m, x1, y1, _l, x2, y2 = tostring(path or ""):match(pat)
    if not x1 then return path end
    x1, y1, x2, y2 = tagopsCoord(x1), tagopsCoord(y1), tagopsCoord(x2), tagopsCoord(y2)
    return string.format("m %s %s l %s %s l %s %s l %s %s", x1, y1, x2, y1, x2, y2, x1, y2)
end

local function tagopsClipHotkeyText(text, op)
    return tagopsMapClipTags(text, function(tag)
        if op == "Toggle clip/iclip" then
            return "\\" .. (tag.name == "clip" and "iclip" or "clip") .. tag.value
        end
        local scale, path = tagopsClipVectorParts(tag.value)
        if not path then return tag.raw end
        if op == "Calibrate clip X" then
            return tagopsClipTagText(tag.name, scale, tagopsCalibrateClipPath(path, "x"))
        elseif op == "Calibrate clip Y" then
            return tagopsClipTagText(tag.name, scale, tagopsCalibrateClipPath(path, "y"))
        elseif op == "Rectangle from diagonal" then
            return tagopsClipTagText(tag.name, scale, tagopsRectangleFromDiagonal(path))
        end
        return tag.raw
    end)
end

function TagOps.opClipHotkey(subs, sel, opts)
    if not sel or #sel == 0 then TagOps.U.alert(L("tagops_err_measure_select")); return false end
    local op = opts and opts.clip_hotkey or ""
    if op == "" then return false end
    if op == "Copy clip/iclip" then
        return TagOps.opCopy(subs, sel, {
            selected = { clip = true, iclip = true },
            replace = true,
            all_blocks = true,
            append = false,
            info = opts and opts.info,
        })
    end
    local changed = 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        if Rhea.isDialogue(line) then
            local nextText, c = tagopsClipHotkeyText(line.text or "", op)
            if c > 0 and nextText ~= line.text then
                line.text = nextText
                subs[i] = line
                changed = changed + 1
            end
        end
    end
    if changed == 0 then TagOps.U.alert(L("tagops_no_clip_changed")); return false end
    aegisub.set_undo_point("TagOps - " .. op)
    if opts and opts.info then TagOps.U.alert(string.format(L("tagops_clip_changed"), changed)) end
    return true
end

TagOps.defs = TAGOPS_DEFS
TagOps.actions = {"Measure & Transform Clip", "Adjust tags", "Adjust by Clip Scale", "In-Out tags", "Pos Align"}

local function tagopsNormalizeAction(action)
    action = tostring(action or "")
    if action == "Copy tags" or action == "Copy Tags" then return "Measure & Transform Clip" end
    if action == "" then return "" end
    return RheaFoundation.choose(action, TagOps.actions, "Measure & Transform Clip")
end


-- UI support
local HELP_TEXTS = {
en = [[
RHEA SIGNS · USER GUIDE
====================

Typesetting operations suite. The interface consists of a main panel and
three auxiliary windows: Tag Ops, Signs Editor, and Config. Each section
of the main panel has an Action field; if that field is left empty, the
section is skipped during execution. This lets you prepare several values
and apply only the sections you need in a single pass.


1. HOW TO USE IT
----------------

   1.1. Select the working lines in the grid.
   1.2. The main panel runs on the current Aegisub selection.
   1.3. Set an Action in each section you want to run.
   1.4. Adjust geometry, colors, layers, and timing.
   1.5. Click RUN.
   1.6. Review layers, clips, markers, and comments before applying any
        cleanup.


2. SELECTION
------------

   2.1. The main panel uses the selected rows directly.
   2.2. To run on a narrower batch, adjust the Aegisub selection before
        opening Rhea Signs.


3. TRANSFORM COLORS (C1-C4)
---------------------------

   3.1. C1 through C4 are edited from the Transforms block or Config.
   3.2. These colors feed the four border layers in Transforms.
   3.3. FX 1 and FX 2 are independent global colors and feed only the
        FX actions.


4. TRANSFORMS
-------------

   4.1. Actions:
        - Apply Chain: builds a \t() chain from the Initial and Final
          states.
        - FX: applies the effect selected in FX.
        - Preset: applies the layer recipe selected in Preset.
        - Borders: generates stacked border layers.
        - Clean CAL: removes the output generated by this section.

   4.2. Initial / Final: starting and ending tag states.
   4.3. KF (Custom keyframes): timed entries in time:tags format,
        separated by semicolons. Example:
        0:\blur8;250:\blur0
   4.4. Shape:
        - Once (out): simple transition.
        - Out and back: goes halfway, then returns.
        - Yoyo (N cycles): N out-and-back cycles.
        - Pulse (ms): alternates within a fixed time window.
        - Steps (N): discrete interpolation across N segments.
        - Custom keyframes: follows the markers declared in KF.
   4.5. Steps: N for Yoyo and Steps; ms for Pulse.
   4.6. Delay:
        - No delay.
        - ms from the start.
        - Current video frame.
        - Percentage (%) of the line duration.
   4.7. Accel: acceleration applied to the \t() chain when the checkbox
        is enabled.
   4.8. Step and Amount: parameters for FX that use repeated pulses,
        such as Shake, Wobble, Glitch, and Color Pulse.
   4.9. Strip: removes existing \t() blocks before injecting the new
        chain.
   4.10. Available FX presets:
        - Blur In / Blur Out
        - Fade In / Fade Out
        - Scale Up / Scale Down
        - Pop In / Pop Out
        - Color Flash, Color Pulse, To Color (frame), To Style (frame)
        - Border Pulse, Glow Pulse
        - Shake V, Shake H, Shake XY
        - Wobble (frz), Glitch
        - Dramatic Pulse, Flashback (fad)
        - Split Line, Split Line Fad, Split Title
   4.11. B1-B4: enable border layers; the adjacent numeric field sets
         the thickness.
   4.12. C1-C4: colors for the B1-B4 layers.


5. PERSPECTIVE
--------------

   5.1. Modes:
        - Copy Exact: source perspective, source \pos and source \org; targets overlap the source.
        - Copy Static Plane: source perspective and source \org, but target \pos. This keeps the perspective plane fixed.
        - Copy Move Plane: source perspective with \pos and \org shifted together to the target \pos.
        - Copy w/ corner swap: remaps corners with Map.
        - Mass FSC: locks the quadrilateral.
        - Scale Quad (3D Box).
        - Clip to Persp: applies the quadrilateral clip to the text.
        - Rescale to Clip: rescales using the clip as reference.
        - Bake Extradata / Restore Extradata.
        - Identity reproject.

   5.2. Map: corner order — ABCD, BADC, DCBA, CDAB, BCDA, DABC, ABDC,
        BACD, plus origin/destination variants. Copy Exact, Copy Static Plane,
        and Copy Move Plane keep the source corner order; use Copy w/ corner
        swap for remapping.
   5.3. Org: strategy for \org.
        - 1: keep the destination origin.
        - 2: center of the quadrilateral.
        - 3: minimize fax, the default option.
   5.4. Rescale: Fit (uniform), Fill (uniform), Stretch (per axis).
   5.5. x / y: when enabled, they lock \fscx and \fscy.
   5.6. Quad%: percentage scale of the destination quadrilateral.
   5.7. Drop P: removes the perspective clip after baking.
   5.8. Drop R: removes the rescale clip.
   5.9. Center: recenters after a clip-based rescale.
   5.10. The Text, Border, Shadow, Blur, and fsp checkboxes define which
         dimensions follow the transformation.


6. SIGN
-------

   6.1. Actions:
        - Typewriter: reveals characters by frame or duration.
        - Vertical Drop: distributes characters vertically.
        - Circle Text: lays out the text in a circle around a radius.
        - Curve Text: samples the vector clip as a path.
        - Align to Clip: positions the line according to the clip
          bounds.
        - Clean SiO: removes the output generated by this section.
   6.2. Type: Frame, for fixed time per character, or Duration, to
        distribute the reveal over the line duration.
   6.3. Rotation: Normal, Inverted, or Vertical.
   6.4. Radius: radius used by Circle Text and Curve Text.
   6.5. Track: additional tracking between characters.
   6.6. Inv: reverses the direction when the operation uses it.
   6.7. Delete: removes the source line after generating the derived
        line.


7. MASKS
--------

   7.1. Actions:
        - Apply Mask: applies a shape from the library.
        - Create Layer: adds the mask as an independent layer.
        - Replace Mask: replaces the existing mask drawing.
        - Save Shape: saves the current shape under the specified name.
        - Delete Shape: removes the specified shape from the file.
        - Clean DR: removes the lines generated by Masks.
   7.2. Source:
        - from clip: derives the shape from the current vector clip.
        - Any shape saved in the library.
   7.3. Align: an1 to an9.
   7.4. Alpha: optional hexadecimal alpha value for the mask.
   7.5. Color: mask color, set with the checkbox and picker.
   7.6. q2: toggles bicubic rendering.
   7.7. Layer: when creating a layer, if the source is on layer 0, the
        mask stays on 0 and the source moves up to 1.
   7.8. Name: key used to save or delete shapes.


8. FASTSIGNS
------------

Direct button on the main panel. It comments the source line, preserves
visible text and \N line breaks, and generates three layers: box, glow,
and front text. Lines with overlapping timings are grouped automatically.
The typographic palette, margins, fade, top offset, horizontal spacing,
maximum width, and blurs are configured from Config.


9. SIGNS EDITOR
----------------

Dedicated window for bulk sign management. It lets you edit multiple
lines in a batch while preserving tags, layers, and comments.


10. TAG OPS
-----------

   10.1. Measure & Transform Clip: compares the first two m–l segments of the first
         vector clip and reports lengths and percentage.
   10.2. Copy Tags button: copies the checked tags by Effect group. If
         no Effect group has a target, the first selected dialogue line
         is used as the source for the remaining selected dialogue lines.
         - Replace matching tags: replaces equivalent tags.
         - Read all blocks: scans all override blocks.
         - Append to first block: adds the tags to the first existing
           block.
   10.3. Keep Only button: removes all override tags except the checked
         tags from the selected lines.
   10.4. Adjust tags: adds (Add) or scales (Percent) auto-detected
         numeric tags. Checking an auto-detected tag excludes it;
         checking a manual-only tag adds it to the adjustment.
   10.5. Adjust by Clip Scale: computes the Percent amount from clip
         distance growth. It uses either the first two selected clipped
         lines or two m-l subpaths in one vector clip.
   10.6. In-Out tags: with two lines selected, generates a single line
         with the timed transition and comments the originals.
   10.7. Pos Align: uses the first two selected lines as fixed roles:
         first line = source / pivot, second line = reference.
         It applies the delta from the source \pos to the reference \pos
         to the selected lines, leaving the reference line unchanged.
         - Keep org: moves only \pos and preserves the original \org.
         - Move org: moves \pos, \move, \org, clips, and inline drawings.
           If the two \pos values are identical, it uses the \org delta.
   10.8. Show result: prints a summary of modified lines and tags.


11. CONFIG
----------

   11.1. Language: en, es, pt.
   11.2. C1-C4 transform colors.
   11.3. Global colors: FX 1, FX 2, and Mask.
   11.4. FastSigns:
         - Box, Text, and Glow colors.
         - Box and glow alpha.
         - Fade (ms).
         - Horizontal and vertical padding.
         - Top offset.
         - Horizontal spacing.
         - Maximum width (% of video width).
         - Box blur, border and glow blur, text blur.


12. MARKERS AND CLEANUP
-----------------------

Generated families write a marker to the Effect field:

   - DR  → Masks.
   - SiO → Sign.
   - CAL → Colors.
   - FS  → FastSigns.

Clean DR, Clean SiO, and Clean CAL read these markers and remove only
the corresponding output. It is recommended to keep source lines
commented until the result has been validated, and to save a version of
the file before any cleanup or large batch operation.


13. SUPPORT
-----------

Questions and reports: https://discord.gg/Egq8us4xZC
]],
es = [[
RHEA SIGNS · GUÍA DE USO
=====================
Suite de operaciones de typesetting. La interfaz se compone de
un panel principal y tres ventanas auxiliares: Tag Ops, Editor de
carteles y Config. Cada sección del panel principal expone una Acción; 
si el campo Acción queda vacío, esa sección se omite al
ejecutar. Esto permite preparar varios valores y aplicar únicamente las
secciones deseadas en una sola pasada.

1. ¿CÓMO USARLO?

   1.1. Seleccionar las líneas de trabajo en la grilla.
   1.2. El panel principal trabaja sobre la selección actual de Aegisub.
   1.3. Definir Acción en cada sección que se desee ejecutar.
   1.4. Ajustar geometría, colores, capas y tiempos.
   1.5. Pulsar EJECUTAR.
   1.6. Revisar capas, clips, marcadores y comentarios antes de aplicar
        cualquier limpieza.

2. SELECCIÓN

   2.1. El panel principal usa directamente las filas seleccionadas.
   2.2. Para trabajar con un lote menor, ajusta la selección de Aegisub
        antes de abrir Rhea Signs.

3. COLORES DE TRANSFORMACIÓN (C1-C4)

   3.1. C1 a C4 se editan desde Transforms o Config.
   3.2. Estos colores alimentan las cuatro capas de borde de Transforms.
   3.3. FX 1 y FX 2 son colores globales independientes y alimentan
        solo las acciones FX.

4. TRANSFORMACIONES

   4.1. Acciones:
         Apply Chain: construye una cadena \t() a partir de los
          estados Inicial y Final.
         FX: aplica el efecto indicado en FX.
         Preset: aplica la receta de capas indicada en Preset.
         Borders: genera capas de borde apiladas.
         Clean CAL: elimina la salida generada por la sección.
   4.2. Inicial / Final: estados de tags de partida y de llegada.
   4.3. KF (Custom keyframes): entradas con tiempo, en formato
        tiempo:tags, separadas por punto y coma. Ejemplo:
        0:\blur8;250:\blur0
   4.4. Forma:
         Una vez (ida): transición simple.
         Ida y vuelta: ida hasta la mitad y retorno.
         Yoyo (N ciclos): N idas y vueltas.
         Pulso (ms): alternancia con ventana fija.
         Pasos (N): interpolación discreta en N tramos.
         Custom keyframes: respeta las marcas declaradas en KF.
   4.5. Pasos: N para Yoyo y Pasos; ms para Pulso.
   4.6. Retardo (Delay):
         Sin retardo.
         ms desde inicio.
         Frame actual del video.
         Porcentaje (%) sobre la duración de la línea.
   4.7. Accel: aceleración aplicada a la cadena \t() cuando la casilla
        está marcada.
   4.8. Paso (Step) y Cantidad (Amount): parámetros de los FX que usan
        pulsos repetidos (Shake, Wobble, Glitch, Color Pulse).
   4.9. Quitar (Strip): elimina los \t() previos antes de inyectar la
        nueva cadena.
   4.10. Presets de FX disponibles:
         Blur In / Blur Out
         Fade In / Fade Out
         Scale Up / Scale Down
         Pop In / Pop Out
         Color Flash, Color Pulse, To Color (frame), To Style (frame)
         Border Pulse, Glow Pulse
         Shake V, Shake H, Shake XY
         Wobble (frz), Glitch
         Dramatic Pulse, Flashback (fad)
         Split Line, Split Line Fad, Split Title
   4.11. B1-B4: activan capas de borde; el campo numérico contiguo
        define el grosor.
   4.12. C1-C4: colores de las capas B1-B4.

5. PERSPECTIVA

   5.1. Modos (Mode):
         Copy Exact: perspectiva, \pos y \org de la fuente; encima los destinos.
         Copy Static Plane: perspectiva y \org de la fuente, pero \pos destino. Mantiene fijo el plano de perspectiva.
         Copy Move Plane: perspectiva de la fuente con \pos y \org desplazados juntos hasta \pos destino.
         Copy w/ corner swap: remapea esquinas con Map.
         Mass FSC (fija el cuadrilátero).
         Scale Quad (3D Box).
         Clip to Persp: aplica el clip cuadrilátero al texto.
         Rescale to Clip: reescala usando el clip como referencia.
         Bake Extradata / Restore Extradata.
         Identity reproject.
   5.2. Mapa (Map): orden de las esquinas (ABCD, BADC, DCBA, CDAB,
        BCDA, DABC, ABDC, BACD y variantes con origen/destino). Copy Exact,
        Copy Static Plane y Copy Move Plane conservan el orden de la fuente; usa
        Copy w/ corner swap para remapear.
   5.3. Org: estrategia para \org.
         1: conservar el origen de destino.
         2: centro del cuadrilátero.
         3: minimizar fax (opción por defecto).
   5.4. Rescale: Fit (uniforme), Fill (uniforme), Stretch (por eje).
   5.5. x / y: si están activadas, fijan \fscx y \fscy.
   5.6. Quad%: escala porcentual del cuadrilátero de destino.
   5.7. Drop P: elimina el clip de perspectiva tras hornear.
   5.8. Drop R: elimina el clip de reescalado.
   5.9. Center: recentra después de un reescalado por clip.
   5.10. Casillas Texto, Borde, Sombra, Blur y fsp: definen qué
         dimensiones acompañan a la transformación.

6. CARTEL · SIGN

   6.1. Acciones:
         Typewriter: revela los caracteres por frame o duración.
         Vertical Drop: distribución vertical de caracteres.
         Circle Text: distribución circular alrededor de un radio.
         Curve Text: muestreo del clip vectorial como ruta.
         Align to Clip: posiciona la línea según los límites del clip.
         Clean SiO: elimina la salida generada por la sección.
   6.2. Tipo: Frame (tiempo fijo por carácter) o Duration (reparto
        sobre la duración de la línea).
   6.3. Rotación: Normal, Invertido o Vertical.
   6.4. Radio: radio en Circle Text y Curve Text.
   6.5. Track: tracking adicional entre caracteres.
   6.6. Inv: invierte la dirección cuando la operación la utiliza.
   6.7. Borrar: elimina la línea fuente tras generar la derivada.

7. MÁSCARAS

   7.1. Acciones:
         Apply Mask: aplica una forma de la biblioteca.
         Create Layer: añade la máscara como capa independiente.
         Replace Mask: sustituye el dibujo de máscara existente.
         Save Shape: guarda la forma actual con el nombre indicado.
         Delete Shape: elimina del archivo la forma indicada.
         Clean DR: elimina las líneas generadas por Máscaras.
   7.2. Fuente:
         from clip: deriva la forma del clip vectorial actual.
         Cualquier forma guardada en biblioteca.
   7.3. Alinear: an1 a an9.
   7.4. Alpha: valor hexadecimal opcional del alfa de la máscara.
   7.5. Color: color de la máscara (casilla y picker).
   7.6. q2: alterna renderizado bicúbico.
   7.7. Capa: cuando se crea una capa, si la fuente está en layer 0 la
        máscara queda en 0 y la fuente sube a 1.
   7.8. Nombre: clave usada para guardar o borrar formas.

8. FASTSIGNS

Botón directo del panel principal. Comenta la línea fuente, conserva el
texto visible y los saltos \N, y genera tres capas: caja, glow y texto
frontal. Las líneas con tiempos solapados se agrupan automáticamente.
La paleta tipográfica, márgenes, fade, offset superior, separación
horizontal, ancho máximo y desenfoques se configuran desde Config.

9. EDITOR DE CARTELES (SIGNS EDITOR)

Ventana dedicada a la gestión masiva de carteles. Permite editar varias
líneas en lote con preservación de tags, capas y comentarios.

10. TAG OPS

   10.1. Medir y transformar clip (Measure & Transform Clip): compara los dos primeros segmentos
         m–l del primer clip vectorial y reporta longitudes y
         porcentaje.
   10.2. Boton Copiar tags: copia los tags marcados por grupo de Effect.
         Si ningun grupo de Effect tiene destino, la primera linea de
         dialogo seleccionada se usa como fuente para las demas lineas.
          Reemplazar tags iguales: sustituye tags equivalentes.
          Leer todos los bloques: recorre todos los bloques de
           override.
          Anexar en primer bloque: añade los tags al primer bloque
           existente.
   10.3. Botón Keep Only: elimina todos los tags de override excepto
         los tags marcados en las líneas seleccionadas.
   10.4. Ajustar tags (Adjust tags): suma (Add) o escala (Percent) los
         tags numéricos detectados. Marcar un tag ya detectado lo excluye;
         marcar un tag manual lo añade al ajuste.
   10.5. Ajustar por escala de clip: calcula Percent desde el crecimiento
         de distancia del clip. Usa las dos primeras lineas con clip
         seleccionadas o dos subrutas m-l dentro de un clip vectorial.
   10.6. InOut tags: con dos líneas seleccionadas genera una sola
         línea con la transición temporizada y comenta las originales.
   10.7. Pos Align: usa las dos primeras lineas seleccionadas como
         roles fijos: primera linea = fuente / pivote, segunda linea =
         referencia. Aplica el delta de \pos de la fuente a
         \pos de la referencia sobre la seleccion, dejando sin cambios la
         linea de referencia.
          Conservar org: mueve solo \pos y conserva el \org original.
          Mover org: mueve \pos, \move, \org, clips y dibujos inline.
          Si los dos \pos son identicos, usa el delta de \org.
   10.8. Mostrar resultado: imprime un resumen de líneas y tags
         modificados.

11. CONFIG

   11.1. Idioma: en, es, pt.
   11.2. Colores de transformación C1-C4.
   11.3. Colores globales: FX 1, FX 2 y Máscara.
   11.4. FastSigns:
          Colores de Caja, Texto y Glow.
          Alfa de caja y de glow.
          Fade (ms).
          Padding horizontal y vertical.
          Offset superior.
          Separación horizontal.
          Ancho máximo (% del ancho de video).
          Blur de caja, borde y blur de glow, blur de texto.

12. MARCADORES Y LIMPIEZA

Las familias generadas inscriben un marcador en el campo Effect:
    DR  → Máscaras.
    SiO → Cartel (Sign).
    CAL → Colores.
    FS  → FastSigns.
Las acciones Clean DR, Clean SiO y Clean CAL leen estos marcadores y
eliminan únicamente la salida correspondiente. Se recomienda mantener
las líneas fuente comentadas hasta validar el resultado y guardar una
versión del archivo antes de cualquier limpieza o lote extenso.

13. SOPORTE

Dudas y reportes: https://discord.gg/Egq8us4xZC
]],
pt = [[
RHEA SIGNS · GUIA DE USO
=====================

Suíte de operações de typesetting. A interface é composta por um painel
principal e três janelas auxiliares: Tag Ops, Editor de Placas e Config.
Cada seção do painel principal tem uma Ação; se o campo Ação ficar
vazio, essa seção será ignorada durante a execução. Isso permite
preparar vários valores e aplicar apenas as seções desejadas em uma
única passada.


1. COMO USAR?
-------------

   1.1. Selecione as linhas de trabalho na grade.
   1.2. O painel principal trabalha sobre a seleção atual do Aegisub.
   1.3. Defina a Ação em cada seção que deseja executar.
   1.4. Ajuste geometria, cores, camadas e tempos.
   1.5. Clique em EXECUTAR.
   1.6. Revise camadas, clips, marcadores e comentários antes de aplicar
        qualquer limpeza.


2. SELEÇÃO
----------

   2.1. O painel principal usa diretamente as linhas selecionadas.
   2.2. Para trabalhar com um lote menor, ajuste a seleção do Aegisub
        antes de abrir Rhea Signs.


3. CORES DE TRANSFORMAÇÃO (C1-C4)
---------------------------------

   3.1. C1 a C4 são editadas em Transforms ou Config.
   3.2. Essas cores alimentam as quatro camadas de borda em Transforms.
   3.3. FX 1 e FX 2 são cores globais independentes e alimentam apenas
        as ações FX.


4. TRANSFORMACOES
-----------------

   4.1. Ações:
        - Apply Chain: cria uma cadeia \t() a partir dos estados
          Inicial e Final.
        - FX: aplica o efeito indicado em FX.
        - Preset: aplica a receita de camadas indicada em Preset.
        - Borders: gera camadas de borda empilhadas.
        - Clean CAL: remove a saída gerada pela seção.

   4.2. Inicial / Final: estados de tags de partida e chegada.
   4.3. KF (Custom keyframes): entradas com tempo, no formato
        tempo:tags, separadas por ponto e vírgula. Exemplo:
        0:\blur8;250:\blur0
   4.4. Forma:
        - Uma vez (ida): transição simples.
        - Ida e volta: vai até a metade e retorna.
        - Yoyo (N ciclos): executa N idas e voltas.
        - Pulso (ms): alternância com janela fixa.
        - Passos (N): interpolação discreta em N trechos.
        - Custom keyframes: respeita as marcações declaradas em KF.
   4.5. Passos: N para Yoyo e Passos; ms para Pulso.
   4.6. Retardo (Delay):
        - Sem retardo.
        - ms a partir do início.
        - Frame atual do vídeo.
        - Porcentagem (%) da duração da linha.
   4.7. Accel: aceleração aplicada à cadeia \t() quando a caixa está
        marcada.
   4.8. Passo (Step) e Quantidade (Amount): parâmetros dos FX que usam
        pulsos repetidos, como Shake, Wobble, Glitch e Color Pulse.
   4.9. Remover (Strip): remove os \t() anteriores antes de inserir a
        nova cadeia.
   4.10. Presets de FX disponíveis:
        - Blur In / Blur Out
        - Fade In / Fade Out
        - Scale Up / Scale Down
        - Pop In / Pop Out
        - Color Flash, Color Pulse, To Color (frame), To Style (frame)
        - Border Pulse, Glow Pulse
        - Shake V, Shake H, Shake XY
        - Wobble (frz), Glitch
        - Dramatic Pulse, Flashback (fad)
        - Split Line, Split Line Fad, Split Title
   4.11. B1-B4: ativam camadas de borda; o campo numérico ao lado define
         a espessura.
   4.12. C1-C4: cores das camadas B1-B4.


5. PERSPECTIVA
--------------

   5.1. Modos (Mode):
        - Copy Exact: perspectiva, \pos e \org da fonte; destinos sobre a fonte.
        - Copy Static Plane: perspectiva e \org da fonte, mas \pos destino. Mantém fixo o plano de perspectiva.
        - Copy Move Plane: perspectiva da fonte com \pos e \org deslocados juntos até \pos destino.
        - Copy w/ corner swap: remapeia cantos com Map.
        - Mass FSC: fixa o quadrilátero.
        - Scale Quad (3D Box).
        - Clip to Persp: aplica o clip quadrilátero ao texto.
        - Rescale to Clip: redimensiona usando o clip como referência.
        - Bake Extradata / Restore Extradata.
        - Identity reproject.

   5.2. Mapa (Map): ordem dos cantos — ABCD, BADC, DCBA, CDAB, BCDA,
        DABC, ABDC, BACD e variantes com origem/destino. Copy Exact,
        Copy Static Plane e Copy Move Plane mantêm a ordem da fonte; use
        Copy w/ corner swap para remapear.
   5.3. Org: estratégia para \org.
        - 1: manter a origem de destino.
        - 2: centro do quadrilátero.
        - 3: minimizar fax, opção padrão.
   5.4. Rescale: Fit (uniforme), Fill (uniforme), Stretch (por eixo).
   5.5. x / y: quando ativados, fixam \fscx e \fscy.
   5.6. Quad%: escala percentual do quadrilátero de destino.
   5.7. Drop P: remove o clip de perspectiva após o bake.
   5.8. Drop R: remove o clip de redimensionamento.
   5.9. Center: recentraliza após um redimensionamento por clip.
   5.10. As caixas Texto, Borda, Sombra, Blur e fsp definem quais
         dimensões acompanham a transformação.


6. PLACA · SIGN
---------------

   6.1. Ações:
        - Typewriter: revela os caracteres por frame ou por duração.
        - Vertical Drop: distribui os caracteres na vertical.
        - Circle Text: distribui o texto em círculo ao redor de um raio.
        - Curve Text: usa o clip vetorial como rota.
        - Align to Clip: posiciona a linha de acordo com os limites do
          clip.
        - Clean SiO: remove a saída gerada pela seção.
   6.2. Tipo: Frame, com tempo fixo por caractere, ou Duration, com
        distribuição ao longo da duração da linha.
   6.3. Rotação: Normal, Invertido ou Vertical.
   6.4. Raio: raio usado em Circle Text e Curve Text.
   6.5. Track: tracking adicional entre caracteres.
   6.6. Inv: inverte a direção quando a operação usa esse parâmetro.
   6.7. Apagar: remove a linha fonte depois de gerar a derivada.


7. MÁSCARAS
-----------

   7.1. Ações:
        - Apply Mask: aplica uma forma da biblioteca.
        - Create Layer: adiciona a máscara como camada independente.
        - Replace Mask: substitui o desenho de máscara existente.
        - Save Shape: salva a forma atual com o nome indicado.
        - Delete Shape: remove do arquivo a forma indicada.
        - Clean DR: remove as linhas geradas por Máscaras.
   7.2. Fonte:
        - from clip: deriva a forma do clip vetorial atual.
        - Qualquer forma salva na biblioteca.
   7.3. Alinhar: an1 a an9.
   7.4. Alpha: valor hexadecimal opcional do alfa da máscara.
   7.5. Cor: cor da máscara, definida pela caixa e pelo seletor.
   7.6. q2: alterna o render bicúbico.
   7.7. Camada: ao criar uma camada, se a fonte estiver na layer 0, a
        máscara fica em 0 e a fonte sobe para 1.
   7.8. Nome: chave usada para salvar ou apagar formas.


8. FASTSIGNS
------------

Botão direto do painel principal. Comenta a linha fonte, preserva o
texto visível e as quebras \N, e gera três camadas: caixa, glow e texto
frontal. Linhas com tempos sobrepostos são agrupadas automaticamente.
Paleta tipográfica, margens, fade, offset superior, separação horizontal,
largura máxima e desfoques são configurados em Config.


9. EDITOR DE PLACAS (SIGNS EDITOR)
-----------------------------------

Janela dedicada ao gerenciamento em massa de placas. Permite editar
várias linhas em lote, preservando tags, camadas e comentários.


10. TAG OPS
-----------

   10.1. Medir e transformar clip (Measure & Transform Clip): compara os dois primeiros segmentos
         m–l do primeiro clip vetorial e informa os comprimentos e a
         porcentagem.
   10.2. Botao Copiar tags: copia as tags marcadas por grupo de Effect.
         Se nenhum grupo de Effect tiver destino, a primeira linha de
         dialogo selecionada e usada como fonte para as demais linhas.
         - Substituir tags iguais: substitui tags equivalentes.
         - Ler todos os blocos: percorre todos os blocos de override.
         - Anexar no primeiro bloco: adiciona as tags ao primeiro bloco
           existente.
   10.3. Botao Keep Only: remove todas as tags de override exceto as
         tags marcadas nas linhas selecionadas.
   10.4. Ajustar tags (Adjust tags): soma (Add) ou escala (Percent) as
         tags numéricas detectadas. Marcar uma tag detectada a exclui;
         marcar uma tag manual a adiciona ao ajuste.
   10.5. Ajustar por escala de clip: calcula Percent pelo crescimento
         de distancia do clip. Usa as duas primeiras linhas com clip
         selecionadas ou duas subrotas m-l dentro de um clip vetorial.
   10.6. In-Out tags: com duas linhas selecionadas, gera uma única linha
         com a transição temporizada e comenta as originais.
   10.7. Pos Align: usa as duas primeiras linhas selecionadas como
         papeis fixos: primeira linha = fonte / pivo, segunda linha =
         referencia. Aplica o delta de \pos da fonte para
         \pos da referencia sobre a selecao, deixando a linha de referencia
         sem alteracao.
         - Manter org: move somente \pos e preserva o \org original.
         - Mover org: move \pos, \move, \org, clips e desenhos inline.
           Se os dois \pos forem identicos, usa o delta de \org.
   10.8. Mostrar resultado: imprime um resumo das linhas e tags
         modificadas.


11. CONFIG
----------

   11.1. Idioma: en, es, pt.
   11.2. Cores de transformação C1-C4.
   11.3. Cores globais: FX 1, FX 2 e Máscara.
   11.4. FastSigns:
         - Cores de Caixa, Texto e Glow.
         - Alfa da caixa e do glow.
         - Fade (ms).
         - Padding horizontal e vertical.
         - Offset superior.
         - Separação horizontal.
         - Largura máxima (% da largura do vídeo).
         - Blur da caixa, borda e blur do glow, blur do texto.


12. MARCADORES E LIMPEZA
------------------------

As famílias geradas gravam um marcador no campo Effect:

   - DR  → Máscaras.
   - SiO → Placa (Sign).
   - CAL → Cores.
   - FS  → FastSigns.

As ações Clean DR, Clean SiO e Clean CAL leem esses marcadores e removem
apenas a saída correspondente. Recomenda-se manter as linhas fonte
comentadas até validar o resultado e salvar uma versão do arquivo antes
de qualquer limpeza ou lote extenso.


13. SUPORTE
-----------

Dúvidas e reportes: https://discord.gg/Egq8us4xZC
]],
}
local function helpText()
    return HELP_TEXTS[current_lang] or HELP_TEXTS.en
end

local CHOICE_KEYS = {
    ["en"] = "lang_en", ["es"] = "lang_es", ["pt"] = "lang_pt",
    ["Apply Chain"] = "op_apply_chain", ["Apply Mask"] = "op_apply_mask", ["Create Layer"] = "op_create_layer",
    ["Replace Mask"] = "op_replace_mask", ["Save Shape"] = "op_save_shape", ["Delete Shape"] = "op_delete_shape", ["Clean DR"] = "op_clean_dr",
    ["Typewriter"] = "op_typewriter", ["Vertical Drop"] = "op_vertical_drop", ["Circle Text"] = "op_circle_text", ["Curve Text"] = "op_curve_text",
    ["Align to Clip"] = "op_align_clip", ["Clean SiO"] = "op_clean_sio", ["Borders"] = "op_borders", ["Preset"] = "op_preset",
    ["Clean CAL"] = "op_clean_cal", ["Frame"] = "choice_frame", ["Duration"] = "choice_duration", ["Normal"] = "choice_normal",
    ["Invertido"] = "choice_inverted", ["Vertical"] = "choice_vertical", ["from clip"] = "choice_from_clip",
    ["Copy Exact (same plane)"] = "pk_copy_exact", ["Copy Static Plane (keep \\pos)"] = "pk_copy_static", ["Copy Move Plane (whole plane)"] = "pk_copy_move_plane",
    ["Copy w/ corner swap"] = "pk_copy_swap", ["Copy Translate (keep \\pos)"] = "pk_copy_translate", ["Copy Transport (\\org -> \\pos)"] = "pk_copy_transport",
    ["Mass FSC (lock quad)"] = "pk_mass_fsc", ["Scale Quad (3D Box)"] = "pk_scale_quad", ["Clip to Persp"] = "pk_clip_persp",
    ["Rescale to Clip"] = "pk_rescale_clip", ["Bake Extradata"] = "pk_bake_extra", ["Restore Extradata"] = "pk_restore_extra",
    ["Identity reproject"] = "pk_identity", ["ABCD (exact copy)"] = "map_abcd", ["BADC (h-mirror)"] = "map_badc",
    ["DCBA (v-mirror)"] = "map_dcba", ["CDAB (rot 180)"] = "map_cdab", ["BCDA (rot 90 CW)"] = "map_bcda",
    ["DABC (rot 90 CCW)"] = "map_dabc", ["ABDC (swap CD)"] = "map_abdc", ["BACD (swap AB)"] = "map_bacd",
    ["AB src + CD dst"] = "map_ab_cd", ["CD src + AB dst"] = "map_cd_ab", ["AC src + BD dst"] = "map_ac_bd",
    ["BD src + AC dst"] = "map_bd_ac", ["1 keep dst org"] = "org_keep", ["2 quad center"] = "org_center", ["3 minimize fax"] = "org_min_fax",
    ["Fit (uniform)"] = "res_fit", ["Fill (uniform)"] = "res_fill", ["Stretch (per-axis)"] = "res_stretch",
    ["Una vez (ida)"] = "shape_once", ["Ida y vuelta"] = "shape_round", ["Yoyo (N ciclos)"] = "shape_yoyo",
    ["Pulso (ms)"] = "shape_pulse", ["Pasos (N)"] = "shape_steps", ["Custom keyframes"] = "shape_custom",
    ["Sin retardo"] = "delay_none", ["ms desde inicio"] = "delay_ms", ["Frame actual"] = "delay_frame", ["Porcentaje (%)"] = "delay_percent",
    ["Blur In"] = "fx_blur_in", ["Blur Out"] = "fx_blur_out", ["Fade In"] = "fx_fade_in", ["Fade Out"] = "fx_fade_out",
    ["Scale Up"] = "fx_scale_up", ["Scale Down"] = "fx_scale_down", ["Pop In"] = "fx_pop_in", ["Pop Out"] = "fx_pop_out",
    ["Color Flash"] = "fx_color_flash", ["Color Pulse"] = "fx_color_pulse", ["To Color (frame)"] = "fx_to_color",
    ["To Style (frame)"] = "fx_to_style", ["Border Pulse"] = "fx_border_pulse", ["Glow Pulse"] = "fx_glow_pulse",
    ["Shake V"] = "fx_shake_v", ["Shake H"] = "fx_shake_h", ["Shake XY"] = "fx_shake_xy", ["Wobble (frz)"] = "fx_wobble",
    ["Glitch"] = "fx_glitch", ["Dramatic Pulse"] = "fx_dramatic_pulse", ["Flashback (fad)"] = "fx_flashback", ["Split Line"] = "fx_split_line",
    ["Split Line Fad"] = "fx_split_line_fad", ["Split Title"] = "fx_split_title",
    ["Decompose (Fill + Border)"] = "cal_decompose", ["Blur + Glow"] = "cal_blur_glow", ["Shadtrick (Shadow Layer)"] = "cal_shadtrick",
    ["Double Border Blur"] = "cal_double_border", ["Clean Layers (Flatten)"] = "cal_clean_layers",
    ["Measure & Transform Clip"] = "tagops_measure", ["Adjust tags"] = "tagops_adjust",
    ["Adjust by Clip Scale"] = "tagops_clip_scale_adjust",
    ["In-Out tags"] = "tagops_transition", ["Pos Align"] = "tagops_pos_align",
    ["Add"] = "tagops_add", ["Percent"] = "tagops_percent", ["Keep org"] = "tagops_keep_org", ["Move org"] = "tagops_move_org",
    ["Transform angle"] = "tagops_angle_transform", ["First angle"] = "tagops_angle_first",
    ["Calibrate clip X"] = "tagops_clip_cal_x", ["Calibrate clip Y"] = "tagops_clip_cal_y",
    ["Rectangle from diagonal"] = "tagops_clip_rect", ["Toggle clip/iclip"] = "tagops_clip_toggle",
    ["Copy clip/iclip"] = "tagops_clip_copy",
}

local function choiceLabel(raw)
    local key = CHOICE_KEYS[raw]
    if key then
        local translated = L(key)
        if translated ~= key then return translated end
    end
    return tostring(raw or "")
end

local function dropdownData(items)
    local out, toRaw, toShown = {""}, {[""] = ""}, {[""] = ""}
    local n = 1
    for _, raw in ipairs(items or {}) do
        if raw ~= nil and raw ~= "" then
            local shown = string.format("%d. %s", n, choiceLabel(raw))
            out[#out + 1] = shown
            toRaw[shown] = raw
            toRaw[raw] = raw
            toShown[raw] = shown
            n = n + 1
        end
    end
    return out, toRaw, toShown
end

local function shownChoice(toShown, raw)
    return (toShown and toShown[raw]) or raw or ""
end

local function rawChoice(toRaw, shown)
    return (toRaw and toRaw[shown]) or shown or ""
end

-- Single macro UI
local tagops_gui, config_gui
local function row_master_gui(subs, sel)
    resolveConfig()
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return end

    local pkc = RheaOps.Perspective.loadConfig()
    local ptc = RheaOps.Animation.loadConfig()
    local drc = FunctionalTable.union(RheaOps.Masks.loadConfig() or {}, RheaOps.Masks.defaults or {})
    local soc = RheaOps.Sign.loadConfig()
    local calc = RheaOps.Colors.loadConfig()

    local state = {
        pk_action = "", pk_map = pkc.map or "ABCD (exact copy)", pk_orgm = pkc.orgm or "3 minimize fax",
        pk_set_sx = pkc.set_sx or false, pk_sx = pkc.sx or 100,
        pk_set_sy = pkc.set_sy or false, pk_sy = pkc.sy or 100,
        pk_qscale = pkc.qscale or 100,
        pk_remove_persp_clip = pkc.remove_persp_clip ~= false,
        pk_rescale_mode = pkc.rescale_mode or "Fit (uniform)",
        pk_remove_clip = pkc.remove_clip ~= false, pk_recenter = pkc.recenter ~= false,
        pk_scale_fs = pkc.scale_fs ~= false, pk_scale_bord = pkc.scale_bord ~= false,
        pk_scale_shad = pkc.scale_shad ~= false, pk_scale_blur = pkc.scale_blur ~= false,
        pk_scale_fsp = pkc.scale_fsp ~= false,

        pt_action = "", pt_tags_ini = "", pt_tags_fin = "",
        pt_shape = ptc.shape or "Una vez (ida)", pt_shape_val = ptc.shape_val or 3,
        pt_use_accel = ptc.use_accel or false, pt_accel = ptc.accel or 1.0,
        pt_delay_mode = ptc.delay_mode or "Sin retardo", pt_delay_val = ptc.delay_val or 0,
        pt_strip_existing = ptc.strip_existing ~= false, pt_custom_kf = "",
        pt_fx_preset = "",
        pt_cal_preset = calc.preset or (RheaOps.Colors.presets[1] or ""),
        pt_fx_color = Rhea.assToHtml(ptc.fx_color) or "#FFCC00",
        pt_fx_color2 = Rhea.assToHtml(ptc.fx_color2) or "#00CCFF",
        pt_fx_step_ms = ptc.fx_step_ms or 50, pt_fx_amount = ptc.fx_amount or 0.12,

        dr_action = "", dr_mask_source = drc.mask_source or "from clip",
        dr_alignment = drc.alignment or "an7", dr_create_layer = drc.create_layer ~= false,
        dr_replace_mask = drc.replace_mask or false, dr_bicubic = drc.bicubic or false,
        dr_use_alpha = drc.use_alpha or false, dr_alpha_value = drc.alpha_value or "80",
        dr_use_color = drc.use_color ~= false, dr_mask_color = drc.color_value or "#000000", dr_save_name = "",

        so_action = "", so_type_mode = soc.type_mode or "Frame",
        so_circ_rot = soc.circ_rot or "Normal", so_circ_radio = soc.circ_radio or 0,
        so_circ_track = soc.circ_track or 0, so_circ_invert = soc.circ_invert or false,
        so_circ_delete = soc.circ_delete or false,

        cal_ub1 = calc.ub1 ~= false, cal_bord1 = calc.bord1 or 2,
        cal_ub2 = calc.ub2 or false, cal_bord2 = calc.bord2 or 4,
        cal_ub3 = calc.ub3 or false, cal_bord3 = calc.bord3 or 0,
        cal_ub4 = calc.ub4 or false, cal_bord4 = calc.bord4 or 0,
    }
    local function syncMainGlobalColors()
        if current_config.fx_color1 ~= nil then state.pt_fx_color = current_config.fx_color1 end
        if current_config.fx_color2 ~= nil then state.pt_fx_color2 = current_config.fx_color2 end
        if current_config.mask_color ~= nil then state.dr_mask_color = current_config.mask_color end
        for i = 1, 4 do
            local key = "color" .. i
            state[key] = current_config[key] ~= nil and current_config[key] or DEFAULT_CONFIG[key]
        end
    end
    syncMainGlobalColors()

    while true do
        local ptActionItems, ptActionMap, ptActionShown = dropdownData({ "Apply Chain", "FX", "Preset", "Borders", "Clean CAL" })
        local ptFxItems, ptFxMap, ptFxShown = dropdownData(RheaOps.Animation.fx)
        local ptShapeItems, ptShapeMap, ptShapeShown = dropdownData(RheaOps.Animation.shapes)
        local ptDelayItems, ptDelayMap, ptDelayShown = dropdownData(RheaOps.Animation.delays)
        local pkItems, pkMap, pkShown = dropdownData(RheaOps.Perspective.modes)
        local pkMapItems, pkMapMap, pkMapShown = dropdownData(RheaOps.Perspective.mapNames())
        local pkOrgItems, pkOrgMap, pkOrgShown = dropdownData(RheaOps.Perspective.orgModes)
        local pkRescaleItems, pkRescaleMap, pkRescaleShown = dropdownData(RheaOps.Perspective.rescaleModes)
        local soActionItems, soActionMap, soActionShown = dropdownData({ "Typewriter", "Vertical Drop", "Circle Text", "Curve Text", "Align to Clip", "Clean SiO" })
        local soTypeItems, soTypeMap, soTypeShown = dropdownData({ "Frame", "Duration" })
        local soRotItems, soRotMap, soRotShown = dropdownData({ "Normal", "Invertido", "Vertical" })
        local drActionItems, drActionMap, drActionShown = dropdownData({ "Apply Mask", "Create Layer", "Replace Mask", "Save Shape", "Delete Shape", "Clean DR" })
        local drMaskItems, drMaskMap, drMaskShown = dropdownData(RheaOps.Masks.maskNames())
        local drAlignItems, drAlignMap, drAlignShown = dropdownData({"an1", "an2", "an3", "an4", "an5", "an6", "an7", "an8", "an9"})
        local drAlphaItems, drAlphaMap, drAlphaShown = dropdownData({"00", "20", "40", "60", "80", "A0", "C0", "E0", "FF"})
        local calPresetItems, calPresetMap, calPresetShown = dropdownData(RheaOps.Colors.presets)
        local dropdownMaps = {
            pt_action = ptActionMap, pt_fx_preset = ptFxMap, pt_cal_preset = calPresetMap, pt_shape = ptShapeMap, pt_delay_mode = ptDelayMap,
            pk_action = pkMap, pk_map = pkMapMap, pk_orgm = pkOrgMap, pk_rescale_mode = pkRescaleMap,
            so_action = soActionMap, so_type_mode = soTypeMap, so_circ_rot = soRotMap,
            dr_action = drActionMap, dr_mask_source = drMaskMap, dr_alignment = drAlignMap, dr_alpha_value = drAlphaMap,
        }
        local d = {
            { class="label", label=sectionTitle("title_transforms"), x=0, y=0, width=4, height=1 },
            { class="label", label=L("lbl_action"), x=0, y=1, width=1, height=1 },
            { class="dropdown", name="pt_action", items=ptActionItems, value=shownChoice(ptActionShown, state.pt_action), x=1, y=1, width=3, height=1 },
            { class="label", label=L("lbl_fx"), x=0, y=2, width=1, height=1 },
            { class="dropdown", name="pt_fx_preset", items=ptFxItems, value=shownChoice(ptFxShown, state.pt_fx_preset), x=1, y=2, width=3, height=1 },
            { class="label", label=L("lbl_preset"), x=0, y=3, width=1, height=1 },
            { class="dropdown", name="pt_cal_preset", items=calPresetItems, value=shownChoice(calPresetShown, state.pt_cal_preset), x=1, y=3, width=3, height=1 },

            { class="label", label=L("lbl_initial"), x=0, y=4, width=1, height=1 },
            { class="textbox", name="pt_tags_ini", text=state.pt_tags_ini, x=1, y=4, width=3, height=2 },
            { class="label", label=L("lbl_final"), x=0, y=6, width=1, height=1 },
            { class="textbox", name="pt_tags_fin", text=state.pt_tags_fin, x=1, y=6, width=3, height=2 },
            { class="label", label=L("lbl_kf"), x=0, y=8, width=1, height=1 },
            { class="textbox", name="pt_custom_kf", text=state.pt_custom_kf, x=1, y=8, width=3, height=2 },

            { class="label", label=L("lbl_shape"), x=0, y=10, width=1, height=1 },
            { class="dropdown", name="pt_shape", items=ptShapeItems, value=shownChoice(ptShapeShown, state.pt_shape), x=1, y=10, width=3, height=1 },
            { class="label", label=L("lbl_steps"), x=0, y=11, width=1, height=1 },
            { class="floatedit", name="pt_shape_val", value=state.pt_shape_val, min=1, x=1, y=11, width=1, height=1 },
            { class="label", label=L("lbl_time"), x=2, y=11, width=1, height=1 },
            { class="floatedit", name="pt_delay_val", value=state.pt_delay_val, min=0, x=3, y=11, width=1, height=1 },
            { class="label", label=L("lbl_delay"), x=0, y=12, width=1, height=1 },
            { class="dropdown", name="pt_delay_mode", items=ptDelayItems, value=shownChoice(ptDelayShown, state.pt_delay_mode), x=1, y=12, width=3, height=1 },
            { class="checkbox", name="pt_use_accel", label=L("lbl_accel"), value=state.pt_use_accel, x=0, y=13, width=1, height=1 },
            { class="floatedit", name="pt_accel", value=state.pt_accel, min=0.1, max=10, x=1, y=13, width=1, height=1 },
            { class="label", label=L("lbl_step"), x=2, y=13, width=1, height=1 },
            { class="intedit", name="pt_fx_step_ms", value=state.pt_fx_step_ms, min=1, x=3, y=13, width=1, height=1 },
            { class="label", label=L("lbl_amount"), x=0, y=14, width=1, height=1 },
            { class="floatedit", name="pt_fx_amount", value=state.pt_fx_amount, min=0, x=1, y=14, width=1, height=1 },
            { class="checkbox", name="pt_strip_existing", label=L("lbl_strip"), value=state.pt_strip_existing, x=2, y=14, width=2, height=1 },
            { class="label", label=L("lbl_fx_c1"), x=0, y=15, width=1, height=1 },
            { class="coloralpha", name="pt_fx_color", value=state.pt_fx_color, x=1, y=15, width=1, height=1 },
            { class="label", label=L("lbl_fx_c2"), x=2, y=15, width=1, height=1 },
            { class="coloralpha", name="pt_fx_color2", value=state.pt_fx_color2, x=3, y=15, width=1, height=1 },

            { class="checkbox", name="cal_ub1", label="B1", value=state.cal_ub1, x=0, y=17, width=1, height=1 },
            { class="floatedit", name="cal_bord1", value=state.cal_bord1, min=0, x=1, y=17, width=1, height=1 },
            { class="coloralpha", name="color1", value=state.color1, x=2, y=17, width=1, height=1 },
            { class="checkbox", name="cal_ub2", label="B2", value=state.cal_ub2, x=0, y=18, width=1, height=1 },
            { class="floatedit", name="cal_bord2", value=state.cal_bord2, min=0, x=1, y=18, width=1, height=1 },
            { class="coloralpha", name="color2", value=state.color2, x=2, y=18, width=1, height=1 },
            { class="checkbox", name="cal_ub3", label="B3", value=state.cal_ub3, x=0, y=19, width=1, height=1 },
            { class="floatedit", name="cal_bord3", value=state.cal_bord3, min=0, x=1, y=19, width=1, height=1 },
            { class="coloralpha", name="color3", value=state.color3, x=2, y=19, width=1, height=1 },
            { class="checkbox", name="cal_ub4", label="B4", value=state.cal_ub4, x=0, y=20, width=1, height=1 },
            { class="floatedit", name="cal_bord4", value=state.cal_bord4, min=0, x=1, y=20, width=1, height=1 },
            { class="coloralpha", name="color4", value=state.color4, x=2, y=20, width=1, height=1 },

            { class="label", label=sectionTitle("title_masks"), x=4, y=0, width=5, height=1 },
            { class="label", label=L("lbl_mask"), x=4, y=1, width=1, height=1 },
            { class="dropdown", name="dr_action", items=drActionItems, value=shownChoice(drActionShown, state.dr_action), x=5, y=1, width=4, height=1 },
            { class="label", label=L("lbl_source"), x=4, y=2, width=1, height=1 },
            { class="dropdown", name="dr_mask_source", items=drMaskItems, value=shownChoice(drMaskShown, state.dr_mask_source), x=5, y=2, width=4, height=1 },
            { class="label", label=L("lbl_align"), x=4, y=3, width=1, height=1 },
            { class="dropdown", name="dr_alignment", items=drAlignItems, value=shownChoice(drAlignShown, state.dr_alignment), x=5, y=3, width=4, height=1 },
            { class="label", label=L("lbl_alpha"), x=4, y=4, width=1, height=1 },
            { class="dropdown", name="dr_alpha_value", items=drAlphaItems, value=shownChoice(drAlphaShown, state.dr_alpha_value), x=5, y=4, width=4, height=1 },
            { class="checkbox", name="dr_create_layer", label=L("lbl_layer"), value=state.dr_create_layer, x=4, y=5, width=2, height=1 },
            { class="checkbox", name="dr_replace_mask", label=L("lbl_replace"), value=state.dr_replace_mask, x=6, y=5, width=3, height=1 },
            { class="checkbox", name="dr_bicubic", label="q2", value=state.dr_bicubic, x=4, y=6, width=1, height=1 },
            { class="checkbox", name="dr_use_color", label=L("lbl_color"), value=state.dr_use_color, x=5, y=6, width=1, height=1 },
            { class="coloralpha", name="dr_mask_color", value=state.dr_mask_color, x=6, y=6, width=1, height=1 },
            { class="checkbox", name="dr_use_alpha", label="A", value=state.dr_use_alpha, x=7, y=6, width=1, height=1 },
            { class="label", label=L("lbl_name"), x=4, y=7, width=1, height=1 },
            { class="edit", name="dr_save_name", value=state.dr_save_name, x=5, y=7, width=4, height=1 },

            { class="label", label=sectionTitle("title_perspectiva"), x=4, y=8, width=5, height=1 },
            { class="label", label=L("lbl_mode"), x=4, y=9, width=1, height=1 },
            { class="dropdown", name="pk_action", items=pkItems, value=shownChoice(pkShown, state.pk_action), x=5, y=9, width=4, height=1 },
            { class="label", label=L("lbl_map"), x=4, y=10, width=1, height=1 },
            { class="dropdown", name="pk_map", items=pkMapItems, value=shownChoice(pkMapShown, state.pk_map), x=5, y=10, width=4, height=1 },
            { class="label", label=L("lbl_org"), x=4, y=11, width=1, height=1 },
            { class="dropdown", name="pk_orgm", items=pkOrgItems, value=shownChoice(pkOrgShown, state.pk_orgm), x=5, y=11, width=4, height=1 },
            { class="label", label=L("lbl_rescale"), x=4, y=12, width=1, height=1 },
            { class="dropdown", name="pk_rescale_mode", items=pkRescaleItems, value=shownChoice(pkRescaleShown, state.pk_rescale_mode), x=5, y=12, width=4, height=1 },
            { class="checkbox", name="pk_set_sx", label=L("lbl_x"), value=state.pk_set_sx, x=4, y=13, width=1, height=1 },
            { class="floatedit", name="pk_sx", value=state.pk_sx, min=1, x=5, y=13, width=1, height=1 },
            { class="checkbox", name="pk_set_sy", label=L("lbl_y"), value=state.pk_set_sy, x=6, y=13, width=1, height=1 },
            { class="floatedit", name="pk_sy", value=state.pk_sy, min=1, x=7, y=13, width=1, height=1 },
            { class="checkbox", name="pk_recenter", label=L("lbl_center"), value=state.pk_recenter, x=8, y=13, width=1, height=1 },
            { class="label", label=L("lbl_quad"), x=4, y=14, width=1, height=1 },
            { class="floatedit", name="pk_qscale", value=state.pk_qscale, min=1, x=5, y=14, width=1, height=1 },
            { class="checkbox", name="pk_scale_fsp", label="fsp", value=state.pk_scale_fsp, x=6, y=14, width=1, height=1 },
            { class="checkbox", name="pk_remove_persp_clip", label=L("lbl_drop_p"), value=state.pk_remove_persp_clip, x=7, y=14, width=1, height=1 },
            { class="checkbox", name="pk_remove_clip", label=L("lbl_drop_r"), value=state.pk_remove_clip, x=8, y=14, width=1, height=1 },
            { class="checkbox", name="pk_scale_fs", label=L("lbl_text"), value=state.pk_scale_fs, x=4, y=15, width=1, height=1 },
            { class="checkbox", name="pk_scale_bord", label=L("lbl_border"), value=state.pk_scale_bord, x=5, y=15, width=1, height=1 },
            { class="checkbox", name="pk_scale_shad", label=L("lbl_shadow"), value=state.pk_scale_shad, x=6, y=15, width=1, height=1 },
            { class="checkbox", name="pk_scale_blur", label=L("lbl_blur"), value=state.pk_scale_blur, x=7, y=15, width=1, height=1 },

            { class="label", label=sectionTitle("title_signlayout"), x=4, y=16, width=5, height=1 },
            { class="label", label=L("lbl_sign"), x=4, y=17, width=1, height=1 },
            { class="dropdown", name="so_action", items=soActionItems, value=shownChoice(soActionShown, state.so_action), x=5, y=17, width=4, height=1 },
            { class="label", label=L("lbl_type"), x=4, y=18, width=1, height=1 },
            { class="dropdown", name="so_type_mode", items=soTypeItems, value=shownChoice(soTypeShown, state.so_type_mode), x=5, y=18, width=4, height=1 },
            { class="label", label=L("lbl_rot"), x=4, y=19, width=1, height=1 },
            { class="dropdown", name="so_circ_rot", items=soRotItems, value=shownChoice(soRotShown, state.so_circ_rot), x=5, y=19, width=4, height=1 },
            { class="label", label=L("lbl_radius"), x=4, y=20, width=1, height=1 },
            { class="floatedit", name="so_circ_radio", value=state.so_circ_radio, x=5, y=20, width=1, height=1 },
            { class="label", label=L("lbl_track"), x=6, y=20, width=1, height=1 },
            { class="floatedit", name="so_circ_track", value=state.so_circ_track, x=7, y=20, width=1, height=1 },
            { class="checkbox", name="so_circ_invert", label=L("lbl_inv"), value=state.so_circ_invert, x=4, y=21, width=2, height=1 },
            { class="checkbox", name="so_circ_delete", label=L("lbl_del"), value=state.so_circ_delete, x=6, y=21, width=3, height=1 },
            { class="label", label=L("hint_picker"), x=0, y=22, width=9, height=1 },
        }
        local buttons = { L("btn_execute"), L("btn_mass_signs"), L("btn_fastsigns"), L("btn_tagops"), L("btn_config"), L("btn_help"), L("btn_cancel") }
        local b, r = aegisub.dialog.display(d, buttons)
        if not b or b == L("btn_cancel") then return end

        for k, v in pairs(r) do
            local m = dropdownMaps[k]
            state[k] = m and rawChoice(m, v) or v
        end
        r = state
        local paletteChanged = false
        for i = 1, 4 do
            local key = "color" .. i
            if r[key] ~= nil and current_config[key] ~= r[key] then
                current_config[key] = r[key]
                paletteChanged = true
            end
        end
        if paletteChanged then saveGlobalConfig() end

        if b == L("btn_help") then
            aegisub.dialog.display({
                { class="textbox", text=helpText(), x=0, y=0, width=70, height=22 }
            }, { L("btn_ok") })

        elseif b == L("btn_mass_signs") then
            if RheaOps.Tools.massSigns(subs, sel) then return end

        elseif b == L("btn_fastsigns") then
            RheaOps.Tools.fastSigns(subs, sel)
            return

        elseif b == L("btn_tagops") then
            if tagops_gui(subs, sel) then return end

        elseif b == L("btn_config") then
            if config_gui() then syncMainGlobalColors() end

        elseif b == L("btn_execute") then
            local tsel = sel
            local transform_cal_action = (r.pt_action == "Borders" or r.pt_action == "Clean CAL") and r.pt_action or ""
            local pt_action = transform_cal_action == "" and r.pt_action or ""
            local any_run = (r.pk_action ~= "" or r.pt_action ~= "" or r.dr_action ~= ""
                          or r.so_action ~= "")
            if not any_run then return end
            local function updateChainSelection(result, changed)
                if changed ~= false and type(result) == "table" then tsel = result end
            end

            if r.pk_action ~= "" then
                local perspectiveResult = RheaOps.Perspective.run(subs, tsel, {
                    mode = r.pk_action, map = r.pk_map, orgm = r.pk_orgm,
                    set_sx = r.pk_set_sx, sx = tonumber(r.pk_sx) or 100,
                    set_sy = r.pk_set_sy, sy = tonumber(r.pk_sy) or 100,
                    qscale = tonumber(r.pk_qscale) or 100,
                    remove_persp_clip = r.pk_remove_persp_clip,
                    rescale_mode = r.pk_rescale_mode,
                    remove_clip = r.pk_remove_clip, recenter = r.pk_recenter,
                    scale_fs = r.pk_scale_fs, scale_bord = r.pk_scale_bord,
                    scale_shad = r.pk_scale_shad, scale_blur = r.pk_scale_blur,
                    scale_fsp = r.pk_scale_fsp,
                })
                if perspectiveResult ~= true then return end
            end

            if pt_action ~= "" then
                if pt_action == "Preset" then
                    local result, changed = RheaOps.Colors.run(subs, tsel, {
                        op = "preset",
                        preset = r.pt_cal_preset,
                    })
                    updateChainSelection(result, changed)
                else
                    local result, changed = RheaOps.Animation.run(subs, tsel, {
                        action = pt_action == "FX" and "fx" or "chain",
                        tags_ini = r.pt_tags_ini, tags_fin = r.pt_tags_fin,
                        shape = r.pt_shape, shape_val = tonumber(r.pt_shape_val) or 3,
                        use_accel = r.pt_use_accel, accel = tonumber(r.pt_accel) or 1,
                        delay_mode = r.pt_delay_mode, delay_val = tonumber(r.pt_delay_val) or 0,
                        strip_existing = r.pt_strip_existing, custom_kf = r.pt_custom_kf,
                        fx_preset = r.pt_fx_preset, fx_step_ms = tonumber(r.pt_fx_step_ms) or 50,
                        fx_amount = tonumber(r.pt_fx_amount) or 0.12,
                        fx_color = Rhea.htmlToAss(r.pt_fx_color), fx_color2 = Rhea.htmlToAss(r.pt_fx_color2),
                    })
                    updateChainSelection(result, changed)
                    if r.pt_fx_color ~= nil then current_config.fx_color1 = r.pt_fx_color end
                    if r.pt_fx_color2 ~= nil then current_config.fx_color2 = r.pt_fx_color2 end
                    saveGlobalConfig()
                end
            end

            if r.dr_action ~= "" then
                local drcfg = {
                    mask_source = r.dr_mask_source, alignment = r.dr_alignment,
                    create_layer = r.dr_create_layer, replace_mask = r.dr_replace_mask,
                    bicubic = r.dr_bicubic, use_alpha = r.dr_use_alpha,
                    alpha_value = r.dr_alpha_value, use_color = r.dr_use_color,
                    color_value = r.dr_mask_color,
                }
                if r.dr_mask_color and r.dr_mask_color ~= current_config.mask_color then
                    current_config.mask_color = r.dr_mask_color
                    saveGlobalConfig()
                end
                if r.dr_action == "Save Shape" then
                    local name = Rhea.trim(r.dr_save_name or "")
                    if name ~= "" and tsel[1] then RheaOps.Masks.saveMask(name, subs[tsel[1]].text) end
                    RheaOps.Masks.saveConfig(drcfg)
                elseif r.dr_action == "Delete Shape" then
                    local name = Rhea.trim(r.dr_save_name or "")
                    if name ~= "" then RheaOps.Masks.deleteMask(name) end
                    RheaOps.Masks.saveConfig(drcfg)
                else
                    if r.dr_action == "Clean DR" then drcfg.op = "clean"
                    elseif r.dr_action == "Create Layer" then drcfg.create_layer = true; drcfg.replace_mask = false
                    elseif r.dr_action == "Replace Mask" then drcfg.replace_mask = true end
                    local result, changed = RheaOps.Masks.run(subs, tsel, drcfg)
                    updateChainSelection(result, changed)
                end
            end

            if r.so_action ~= "" then
                local sop = ({
                    ["Typewriter"] = "typewriter", ["Vertical Drop"] = "vertical_drop",
                    ["Circle Text"] = "circle_text", ["Curve Text"] = "curve_text",
                    ["Align to Clip"] = "align_clip", ["Clean SiO"] = "clean_sio",
                })[r.so_action]
                local result, changed = RheaOps.Sign.run(subs, tsel, {
                    op = sop, type_mode = r.so_type_mode,
                    circ_rot = r.so_circ_rot,
                    circ_radio = tonumber(r.so_circ_radio) or 0,
                    circ_track = tonumber(r.so_circ_track) or 0,
                    circ_invert = r.so_circ_invert,
                    circ_delete = r.so_circ_delete,
                })
                updateChainSelection(result, changed)
            end

            if transform_cal_action ~= "" then
                local calop = ({
                    ["Borders"] = "borders", ["Clean CAL"] = "clean_cal",
                })[transform_cal_action]
                local calopts = {
                    op = calop,
                    ub1 = r.cal_ub1, bord1 = tonumber(r.cal_bord1) or 0,
                    ub2 = r.cal_ub2, bord2 = tonumber(r.cal_bord2) or 0,
                    ub3 = r.cal_ub3, bord3 = tonumber(r.cal_bord3) or 0,
                    ub4 = r.cal_ub4, bord4 = tonumber(r.cal_bord4) or 0,
                }
                for i = 1, 4 do calopts["c" .. i] = current_config["color" .. i] end
                local result, changed = RheaOps.Colors.run(subs, tsel, calopts)
                updateChainSelection(result, changed)
            end

            return
        end
    end
end

tagops_gui = function(subs, sel)
    resolveConfig()
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return false end

    local actionItems, actionMap, actionShown = dropdownData(TagOps.actions)
    local modeItems, modeMap, modeShown = dropdownData({"Add", "Percent"})
    local alignOrgItems, alignOrgMap, alignOrgShown = dropdownData({"Keep org", "Move org"})
    local axisItems, axisMap, axisShown = dropdownData(TAGOPS_CLIP_AXIS_CHOICES)
    local angleItems, angleMap, angleShown = dropdownData(TAGOPS_ANGLE_CHOICES)
    local clipHotkeyItems, clipHotkeyMap, clipHotkeyShown = dropdownData(TAGOPS_CLIP_HOTKEY_CHOICES)
    local savedAction = tagopsNormalizeAction(current_config.tagops_action or "Measure & Transform Clip")
    local state = {
        tagops_action = savedAction,
        tagops_amount = current_config.tagops_amount or 0,
        tagops_mode = current_config.tagops_mode or "Add",
        tagops_align_org = current_config.tagops_align_org or "Keep org",
        tagops_clip_axis = current_config.tagops_clip_axis or "",
        tagops_angle_mode = current_config.tagops_angle_mode or "",
        tagops_clip_hotkey = current_config.tagops_clip_hotkey or "",
        tagops_replace = current_config.tagops_replace ~= false,
        tagops_all_blocks = current_config.tagops_all_blocks or false,
        tagops_append = current_config.tagops_append or false,
        tagops_info = current_config.tagops_info or false,
    }
    for _, def in ipairs(TagOps.defs) do
        state["tagops_" .. def.key] = current_config["tagops_" .. def.key] or false
    end

    local d = {
        {class="label", label=L("tagops_title"), x=0, y=0, width=8, height=1},
        {class="label", label=L("lbl_action"), x=0, y=1, width=2, height=1},
        {class="dropdown", name="tagops_action", items=actionItems, value=shownChoice(actionShown, state.tagops_action), x=2, y=1, width=4, height=1},
        {class="label", label=L("lbl_org"), x=0, y=2, width=2, height=1},
        {class="dropdown", name="tagops_align_org", items=alignOrgItems, value=shownChoice(alignOrgShown, state.tagops_align_org), x=2, y=2, width=4, height=1},
        {class="label", label=L("lbl_amount"), x=0, y=3, width=2, height=1},
        {class="floatedit", name="tagops_amount", value=state.tagops_amount, x=2, y=3, width=1, height=1},
        {class="dropdown", name="tagops_mode", items=modeItems, value=shownChoice(modeShown, state.tagops_mode), x=3, y=3, width=3, height=1},
        {class="label", label=L("tagops_axis"), x=0, y=4, width=1, height=1},
        {class="dropdown", name="tagops_clip_axis", items=axisItems, value=shownChoice(axisShown, state.tagops_clip_axis), x=1, y=4, width=1, height=1},
        {class="label", label=L("tagops_angle"), x=2, y=4, width=2, height=1},
        {class="dropdown", name="tagops_angle_mode", items=angleItems, value=shownChoice(angleShown, state.tagops_angle_mode), x=4, y=4, width=2, height=1},
        {class="label", label=L("tagops_clip_hotkey"), x=0, y=5, width=2, height=1},
        {class="dropdown", name="tagops_clip_hotkey", items=clipHotkeyItems, value=shownChoice(clipHotkeyShown, state.tagops_clip_hotkey), x=2, y=5, width=4, height=1},
        {class="checkbox", name="tagops_replace", label=L("tagops_replace"), value=state.tagops_replace, x=0, y=6, width=6, height=1},
        {class="checkbox", name="tagops_all_blocks", label=L("tagops_read_all"), value=state.tagops_all_blocks, x=0, y=7, width=6, height=1},
        {class="checkbox", name="tagops_append", label=L("tagops_append"), value=state.tagops_append, x=0, y=8, width=6, height=1},
        {class="checkbox", name="tagops_info", label=L("tagops_show_result"), value=state.tagops_info, x=0, y=9, width=6, height=1},
    }
    for index, def in ipairs(TagOps.defs) do
        local col = (index - 1) % 6
        local row = math.floor((index - 1) / 6)
        d[#d + 1] = {class="checkbox", name="tagops_" .. def.key, label=def.label, value=state["tagops_" .. def.key], x=col, y=11 + row, width=1, height=1}
    end

    local b, r = aegisub.dialog.display(d, {L("btn_execute"), L("btn_copy_tags"), L("btn_keep_only"), L("btn_cancel")})
    if b == L("btn_cancel") or not b then return false end

    r.tagops_action = tagopsNormalizeAction(rawChoice(actionMap, r.tagops_action))
    r.tagops_mode = rawChoice(modeMap, r.tagops_mode)
    r.tagops_align_org = rawChoice(alignOrgMap, r.tagops_align_org)
    r.tagops_clip_axis = rawChoice(axisMap, r.tagops_clip_axis)
    r.tagops_angle_mode = rawChoice(angleMap, r.tagops_angle_mode)
    r.tagops_clip_hotkey = rawChoice(clipHotkeyMap, r.tagops_clip_hotkey)
    current_config.tagops_action = r.tagops_action
    current_config.tagops_amount = r.tagops_amount
    current_config.tagops_mode = r.tagops_mode
    current_config.tagops_align_org = r.tagops_align_org
    current_config.tagops_clip_axis = r.tagops_clip_axis
    current_config.tagops_angle_mode = r.tagops_angle_mode
    current_config.tagops_clip_hotkey = ""
    current_config.tagops_replace = r.tagops_replace
    current_config.tagops_all_blocks = r.tagops_all_blocks
    current_config.tagops_append = r.tagops_append
    current_config.tagops_info = r.tagops_info

    local selected = {}
    for _, def in ipairs(TagOps.defs) do
        local enabled = r["tagops_" .. def.key] or false
        current_config["tagops_" .. def.key] = enabled
        if enabled then selected[def.key] = true end
    end
    saveGlobalConfig()

    local opts = {
        selected = selected,
        amount = r.tagops_amount,
        mode = r.tagops_mode,
        align_org = r.tagops_align_org,
        replace = r.tagops_replace,
        all_blocks = r.tagops_all_blocks,
        append = r.tagops_append,
        info = r.tagops_info,
        clip_axis = r.tagops_clip_axis,
        angle_mode = r.tagops_angle_mode,
        clip_hotkey = r.tagops_clip_hotkey,
    }
    local applied = false
    if b == L("btn_copy_tags") then
        applied = TagOps.opCopy(subs, sel, opts)
    elseif b == L("btn_keep_only") then
        applied = TagOps.opKeepOnly(subs, sel, opts)
    elseif r.tagops_clip_hotkey ~= "" then
        applied = TagOps.opClipHotkey(subs, sel, opts)
    elseif r.tagops_action == "Measure & Transform Clip" then
        applied = TagOps.opMeasure(subs, sel, opts)
    elseif r.tagops_action == "Adjust tags" then
        applied = TagOps.opAdjust(subs, sel, opts)
    elseif r.tagops_action == "Adjust by Clip Scale" then
        applied = TagOps.opAdjustByClipScale(subs, sel, opts)
    elseif r.tagops_action == "In-Out tags" then
        applied = TagOps.opTransition(subs, sel)
    elseif r.tagops_action == "Pos Align" then
        applied = TagOps.opPosAlign(subs, sel, opts)
    end
    return applied == true
end

config_gui = function()
    resolveConfig()
    local langItems, langMap, langShown = dropdownData({"en", "es", "pt"})
    local state = FunctionalTable.union(current_config, DEFAULT_CONFIG)
    local d = {
        {class="label", label=L("btn_config"), x=0, y=0, width=8, height=1},
        {class="label", label=L("lbl_language"), x=0, y=1, width=2, height=1},
        {class="dropdown", name="language", items=langItems, value=shownChoice(langShown, state.language), x=2, y=1, width=2, height=1},

        {class="label", label=sectionTitle("title_colorbar"), x=0, y=2, width=4, height=1},
        {class="coloralpha", name="color1", value=state.color1, x=0, y=3, width=1, height=1},
        {class="coloralpha", name="color2", value=state.color2, x=1, y=3, width=1, height=1},
        {class="coloralpha", name="color3", value=state.color3, x=2, y=3, width=1, height=1},
        {class="coloralpha", name="color4", value=state.color4, x=3, y=3, width=1, height=1},

        {class="label", label=L("lbl_fx_c1"), x=0, y=4, width=1, height=1},
        {class="coloralpha", name="fx_color1", value=state.fx_color1, x=1, y=4, width=1, height=1},
        {class="label", label=L("lbl_fx_c2"), x=2, y=4, width=1, height=1},
        {class="coloralpha", name="fx_color2", value=state.fx_color2, x=3, y=4, width=1, height=1},
        {class="label", label=L("lbl_mask"), x=4, y=4, width=1, height=1},
        {class="coloralpha", name="mask_color", value=state.mask_color, x=5, y=4, width=1, height=1},

        {class="label", label=L("btn_fastsigns"), x=0, y=5, width=8, height=1},
        {class="label", label=L("lbl_box"), x=0, y=6, width=1, height=1},
        {class="coloralpha", name="fastsign_box_color", value=state.fastsign_box_color, x=1, y=6, width=1, height=1},
        {class="label", label=L("lbl_text"), x=2, y=6, width=1, height=1},
        {class="coloralpha", name="fastsign_text_color", value=state.fastsign_text_color, x=3, y=6, width=1, height=1},
        {class="label", label=L("lbl_glow"), x=4, y=6, width=1, height=1},
        {class="coloralpha", name="fastsign_glow_color", value=state.fastsign_glow_color, x=5, y=6, width=1, height=1},

        {class="label", label=L("lbl_alpha"), x=0, y=7, width=1, height=1},
        {class="edit", name="fastsign_box_alpha", value=state.fastsign_box_alpha, x=1, y=7, width=1, height=1},
        {class="label", label=L("lbl_glow") .. " A", x=2, y=7, width=1, height=1},
        {class="edit", name="fastsign_glow_alpha", value=state.fastsign_glow_alpha, x=3, y=7, width=1, height=1},
        {class="label", label=L("lbl_fade"), x=4, y=7, width=1, height=1},
        {class="intedit", name="fastsign_fade_ms", value=state.fastsign_fade_ms, min=0, x=5, y=7, width=1, height=1},
        {class="label", label=L("lbl_pad_x"), x=6, y=7, width=1, height=1},
        {class="intedit", name="fastsign_margin_h", value=state.fastsign_margin_h, min=0, x=7, y=7, width=1, height=1},
        {class="label", label=L("lbl_pad_y"), x=8, y=7, width=1, height=1},
        {class="intedit", name="fastsign_margin_v", value=state.fastsign_margin_v, min=0, x=9, y=7, width=1, height=1},

        {class="label", label=L("lbl_top"), x=0, y=8, width=1, height=1},
        {class="intedit", name="fastsign_top_offset", value=state.fastsign_top_offset, min=0, x=1, y=8, width=1, height=1},
        {class="label", label=L("lbl_gap"), x=2, y=8, width=1, height=1},
        {class="intedit", name="fastsign_horz_gap", value=state.fastsign_horz_gap, min=0, x=3, y=8, width=1, height=1},
        {class="label", label=L("lbl_max_width"), x=4, y=8, width=1, height=1},
        {class="intedit", name="fastsign_max_width", value=state.fastsign_max_width, min=10, max=100, x=5, y=8, width=1, height=1},
        {class="label", label=L("lbl_box_blur"), x=6, y=8, width=1, height=1},
        {class="floatedit", name="fastsign_box_blur", value=state.fastsign_box_blur, min=0, x=7, y=8, width=1, height=1},

        {class="label", label=L("lbl_glow_border"), x=0, y=9, width=1, height=1},
        {class="floatedit", name="fastsign_glow_border", value=state.fastsign_glow_border, min=0, x=1, y=9, width=1, height=1},
        {class="label", label=L("lbl_glow_blur"), x=2, y=9, width=1, height=1},
        {class="floatedit", name="fastsign_glow_blur", value=state.fastsign_glow_blur, min=0, x=3, y=9, width=1, height=1},
        {class="label", label=L("lbl_text_blur"), x=4, y=9, width=1, height=1},
        {class="floatedit", name="fastsign_text_blur", value=state.fastsign_text_blur, min=0, x=5, y=9, width=1, height=1},
    }

    local b, r = aegisub.dialog.display(d, {L("btn_save"), L("btn_cancel")})
    if b ~= L("btn_save") then return false end
    r.language = rawChoice(langMap, r.language)
    for key in pairs(DEFAULT_CONFIG) do
        if r[key] ~= nil then current_config[key] = r[key] end
    end
    current_lang = current_config.language or current_lang
    saveGlobalConfig()
    return true
end

-- Macro registration
local function macroPath(name)
    if name == "" then return script_name end
    return script_name .. "/" .. name
end

local function fastsigns_macro(subs, sel)
    return RheaOps.Tools.fastSigns(subs, sel)
end

local function signs_editor_macro(subs, sel)
    return RheaOps.Tools.massSigns(subs, sel)
end

local function tagops_clip_hotkey_macro(op)
    return function(subs, sel)
        resolveConfig()
        return TagOps.opClipHotkey(subs, sel, { clip_hotkey = op })
    end
end

depRec:registerMacros({
    { macroPath(""), script_description, row_master_gui },
    { macroPath("TagOps"), "Tag operations", tagops_gui },
    { macroPath("TagOps/Clip Hotkeys/Calibrate X"), "Calibrate vector clips parallel to X", tagops_clip_hotkey_macro("Calibrate clip X") },
    { macroPath("TagOps/Clip Hotkeys/Calibrate Y"), "Calibrate vector clips parallel to Y", tagops_clip_hotkey_macro("Calibrate clip Y") },
    { macroPath("TagOps/Clip Hotkeys/Rectangle from diagonal"), "Create rectangle clips from a diagonal", tagops_clip_hotkey_macro("Rectangle from diagonal") },
    { macroPath("TagOps/Clip Hotkeys/Toggle clip-iclip"), "Toggle clip and iclip tags", tagops_clip_hotkey_macro("Toggle clip/iclip") },
    { macroPath("TagOps/Clip Hotkeys/Copy clip-iclip"), "Copy clip or iclip tags by Effect group", tagops_clip_hotkey_macro("Copy clip/iclip") },
    { macroPath("Fast Signs"), "Generate fast signs", fastsigns_macro },
    { macroPath("Signs Editor"), "Edit repeated sign text", signs_editor_macro },
}, false)
