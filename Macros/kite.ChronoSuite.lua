script_name        = "Chrono Suite"
script_description = "Suite for subtitle timing, QC, cleanup, and workflow toolkit"
script_author      = "Kiterow"
script_version     = "1.0.4"
script_namespace   = "kite.ChronoSuite"

include("karaskel.lua")

local UTF8_CHAR_PATTERN          = "[%z\1-\127\194-\244][\128-\191]*"
local NBSP                       = string.char(0xC2, 0xA0)
local INV_QUESTION               = string.char(0xC2, 0xBF)
local INV_EXCLAMATION            = string.char(0xC2, 0xA1)
local CJK_PERIOD                 = string.char(0xE3, 0x80, 0x82)
local CJK_COMMA                  = string.char(0xE3, 0x80, 0x81)
local FULLWIDTH_QUESTION         = string.char(0xEF, 0xBC, 0x9F)
local FULLWIDTH_EXCLAMATION      = string.char(0xEF, 0xBC, 0x81)
local FULLWIDTH_COMMA            = string.char(0xEF, 0xBC, 0x8C)
local FULLWIDTH_SEMICOLON        = string.char(0xEF, 0xBC, 0x9B)
local FULLWIDTH_PERIOD           = string.char(0xEF, 0xBC, 0x8E)
local FULLWIDTH_COLON            = string.char(0xEF, 0xBC, 0x9A)
local HORIZONTAL_ELLIPSIS        = string.char(0xE2, 0x80, 0xA6)
local TWO_DOT_LEADER             = string.char(0xE2, 0x80, 0xA5)
local LEFT_DOUBLE_QUOTE          = string.char(0xE2, 0x80, 0x9C)
local RIGHT_DOUBLE_QUOTE         = string.char(0xE2, 0x80, 0x9D)
local DOUBLE_LOW_QUOTE           = string.char(0xE2, 0x80, 0x9E)
local DOUBLE_HIGH_REVERSED_QUOTE = string.char(0xE2, 0x80, 0x9F)
local LEFT_SINGLE_QUOTE          = string.char(0xE2, 0x80, 0x98)
local RIGHT_SINGLE_QUOTE         = string.char(0xE2, 0x80, 0x99)
local SINGLE_LOW_QUOTE           = string.char(0xE2, 0x80, 0x9A)
local SINGLE_HIGH_REVERSED_QUOTE = string.char(0xE2, 0x80, 0x9B)
local LEFT_GUILLEMET             = string.char(0xC2, 0xAB)
local RIGHT_GUILLEMET            = string.char(0xC2, 0xBB)
local LEFT_SINGLE_GUILLEMET      = string.char(0xE2, 0x80, 0xB9)
local RIGHT_SINGLE_GUILLEMET     = string.char(0xE2, 0x80, 0xBA)
local EN_DASH                    = string.char(0xE2, 0x80, 0x93)
local EM_DASH                    = string.char(0xE2, 0x80, 0x94)
local HORIZONTAL_BAR             = string.char(0xE2, 0x80, 0x95)
local MINUS_SIGN                 = string.char(0xE2, 0x88, 0x92)

local SENTENCE_SPLIT_CHARS = {
    ["."] = true, ["?"] = true, ["!"] = true,
    [CJK_PERIOD] = true, [FULLWIDTH_QUESTION] = true, [FULLWIDTH_EXCLAMATION] = true,
    [FULLWIDTH_PERIOD] = true, [HORIZONTAL_ELLIPSIS] = true, [TWO_DOT_LEADER] = true,
}
local COMMA_SPLIT_CHARS = {
    [","] = true, [":"] = true, [";"] = true,
    [CJK_COMMA] = true, [FULLWIDTH_COMMA] = true, [FULLWIDTH_COLON] = true, [FULLWIDTH_SEMICOLON] = true,
}
local UTF8_PUNCTUATION_CHARS = {
    [INV_QUESTION] = true, [INV_EXCLAMATION] = true,
    [CJK_PERIOD] = true, [CJK_COMMA] = true,
    [FULLWIDTH_QUESTION] = true, [FULLWIDTH_EXCLAMATION] = true,
    [FULLWIDTH_COMMA] = true, [FULLWIDTH_SEMICOLON] = true,
    [FULLWIDTH_PERIOD] = true, [FULLWIDTH_COLON] = true,
    [HORIZONTAL_ELLIPSIS] = true, [TWO_DOT_LEADER] = true,
    [LEFT_DOUBLE_QUOTE] = true, [RIGHT_DOUBLE_QUOTE] = true,
    [LEFT_SINGLE_QUOTE] = true, [RIGHT_SINGLE_QUOTE] = true,
    [LEFT_GUILLEMET] = true, [RIGHT_GUILLEMET] = true,
    [string.char(0xE3,0x80,0x8C)] = true, [string.char(0xE3,0x80,0x8D)] = true,
    [string.char(0xE3,0x80,0x8E)] = true, [string.char(0xE3,0x80,0x8F)] = true,
    [string.char(0xE3,0x80,0x90)] = true, [string.char(0xE3,0x80,0x91)] = true,
    [string.char(0xEF,0xBC,0x88)] = true, [string.char(0xEF,0xBC,0x89)] = true,
    [string.char(0xEF,0xBC,0xBB)] = true, [string.char(0xEF,0xBC,0xBD)] = true,
}
local TERMINAL_PUNCTUATION = {
    ["."] = true, ["?"] = true, ["!"] = true, [","] = true,
    [CJK_PERIOD] = true, [CJK_COMMA] = true,
    [FULLWIDTH_PERIOD] = true, [FULLWIDTH_QUESTION] = true, [FULLWIDTH_EXCLAMATION] = true, [FULLWIDTH_COMMA] = true,
    [HORIZONTAL_ELLIPSIS] = true,
}
local CLOSING_PUNCTUATION  = {
    [")"] = true, ["]"] = true, ["}"] = true, ["\""] = true, ["'"] = true,
    [RIGHT_DOUBLE_QUOTE] = true, [RIGHT_SINGLE_QUOTE] = true, [RIGHT_GUILLEMET] = true,
}

local LATIN_UPPER_TO_LOWER = {
    [string.char(0xC3,0x81)] = string.char(0xC3,0xA1), [string.char(0xC3,0x89)] = string.char(0xC3,0xA9),
    [string.char(0xC3,0x8D)] = string.char(0xC3,0xAD), [string.char(0xC3,0x93)] = string.char(0xC3,0xB3),
    [string.char(0xC3,0x9A)] = string.char(0xC3,0xBA), [string.char(0xC3,0x9C)] = string.char(0xC3,0xBC),
    [string.char(0xC3,0x91)] = string.char(0xC3,0xB1),
}
local LATIN_LOWER_TO_UPPER = {}
for u, l in pairs(LATIN_UPPER_TO_LOWER) do LATIN_LOWER_TO_UPPER[l] = u end

local function safeRequire(mod) local ok,m = pcall(require, mod); if ok then return m end end

local DependencyControl = safeRequire("l0.DependencyControl")
local depRec, ASS, Functional, re

if DependencyControl then
    local ok, rec = pcall(DependencyControl, {
        feed        = "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
        {
            { "l0.ASSFoundation", version = "0.5.0",
              url  = "https://github.com/TypesettingTools/ASSFoundation",
              feed = "https://raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json" },
            { "l0.Functional", version = "0.6.0",
              url  = "https://github.com/TypesettingTools/Functional",
              feed = "https://raw.githubusercontent.com/TypesettingTools/Functional/master/DependencyControl.json" },
            { "aegisub.re" },
        },
    })
    if ok and rec then
        depRec = rec
        local okMods, mASS, mFunctional, mRe = pcall(function() return depRec:requireModules() end)
        if okMods then ASS, Functional, re = mASS, mFunctional, mRe end
    end
end
ASS        = ASS        or safeRequire("l0.ASSFoundation")
Functional = Functional or safeRequire("l0.Functional")
re         = re         or safeRequire("aegisub.re")

local FunctionalString  = type(Functional) == "table" and Functional.string  or nil
local FunctionalMath    = type(Functional) == "table" and Functional.math    or nil
local FunctionalUnicode = type(Functional) == "table" and Functional.unicode or nil

local unicode = safeRequire("aegisub.unicode") or {}
if type(unicode.to_upper) ~= "function" then unicode.to_upper = string.upper end
if type(unicode.to_lower) ~= "function" then unicode.to_lower = string.lower end
if type(unicode.len)      ~= "function" then
    unicode.len = function(t)
        local n = 0; for _ in tostring(t or ""):gmatch(UTF8_CHAR_PATTERN) do n = n + 1 end; return n
    end
end

local DEFAULT_CONFIG = {
    language          = "en",

    lazy_method       = "Cluster (±ms)",
    lazy_limit        = 800,
    lazy_apply_start  = true,
    lazy_apply_end    = true,
    lazy_enable_tagging = true,
    lazy_tag_mode     = "Both",
    lazy_tag_scope    = "Both",
    lazy_table_csv    = false,

    scxvid_path       = "",
    ffmpeg_path       = "",
    scxvid_suffix     = "_keyframes.log",

    cue_mode          = "Full Timing",
    cue_multichapter  = false,
    cue_lead_in_ms    = 120,
    cue_lead_out_ms   = 420,
    cue_max_lead_out_ms = 800,
    cue_max_lead_in_ms  = 400,
    cue_kf_end_range_ms = 800,
    cue_kf_start_range_ms = 400,
    cue_kf_back_ms    = 100,
    cue_duration_floor_ms = 500,
    cue_cps_flag      = 28,
    cue_skip_signs    = true,
    cue_show_stats    = true,
    cue_auto_discover = true,
    cue_style_filter  = "All",
    cue_extra_style   = "",
    cue_fps           = 23.976,
    lead_step_ms      = 100,
    chain_max_ms      = 2000,

    kt_lead_in_base   = 150,
    kt_lead_in_max    = 300,
    kt_lead_out_base  = 350,
    kt_lead_out_max   = 600,
    kt_lead_out_chain = 500,
    kt_chain_gap_max  = 800,
    bidir_snap_f      = 2,
    edge_snap_protect_ms = 250,

    preset_start_twin_ms = 300,
    preset_start_miss_ms = 300,
    preset_end_twin_ms = 1000,
    preset_end_miss_ms = 1000,
    preset_full_twin_ms = 1000,
    preset_full_miss_ms = 1000,
    preset_full_short_ms = 500,
    preset_full_long_ms = 7000,
    preset_full_max_cps = 20,
    preset_full_short_gap_ms = 300,
    preset_full_large_gap_ms = 800,
    preset_full_max_width = 1200,
    preset_duration_short_ms = 500,
    preset_duration_long_ms = 7000,
    preset_cps_max = 20,
    preset_gap_short_ms = 300,
    preset_gap_large_ms = 800,
    preset_overtime_ms = 5500,

    scream_avg_db        = -13,
    scream_sample_db     = -17,
    scream_loud_ratio    = 35,
    scream_min_samples   = 3,
    scream_robust_z      = 0.50,
    scream_clean_previous = true,
    scream_reuse_log     = true,
    scream_scope         = "All dialogue",
}

local configPath = aegisub.decode_path("?user/chrono_suite_config.lua")
local currentConfig = {}
local currentLang = "en"

local function loadConfig()
    local f = io.open(configPath, "r")
    if f then
        local content = f:read("*a"); f:close()
        local chunk = loadstring("return " .. content)
        if chunk then
            local ok, loaded = pcall(chunk)
            if ok and type(loaded) == "table" then
                currentConfig = {}
                for k, v in pairs(DEFAULT_CONFIG) do
                    currentConfig[k] = loaded[k] == nil and v or loaded[k]
                end
                currentLang = currentConfig.language or "en"
                return true
            end
        end
    end
    currentConfig = {}
    for k, v in pairs(DEFAULT_CONFIG) do currentConfig[k] = v end
    currentLang = currentConfig.language or "en"
    return false
end

local function saveConfig()
    local f = io.open(configPath, "w"); if not f then return false end
    f:write("{\n")
    for k in pairs(DEFAULT_CONFIG) do
        local v = currentConfig[k]
        if type(v) == "string" then
            f:write(string.format("    %s = %q,\n", k, v))
        else
            f:write(string.format("    %s = %s,\n", k, tostring(v)))
        end
    end
    f:write("}\n"); f:close()
    return true
end

loadConfig()

local LANG = {
    en = {
        title_suite      = "═══ CHRONO SUITE ═══════════════════",
        title_markers    = "═══ AUDIT MARKERS ════════════════════",
        title_utilities  = "═══ UTILITY TOOLS ════════════════",
        title_data_import  = "─── DATA IMPORT ─────────",
        title_tools      = "─── Extra Tools ─",
        lbl_apply_to     = "Apply to:",            lbl_filter      = "Filter:",
        lbl_preset       = "Preset:",              lbl_kf_mode     = "KF Mode:", lbl_kf_dir = "KF Dir:",
        lbl_short_ms     = "Short (ms):",          lbl_long_ms     = "Long (ms):",
        lbl_twin_ms      = "Twin KF (ms):",        lbl_miss_ms     = "Miss KF (ms):",
        lbl_overtime     = "Overtime (ms):",       lbl_min_cps     = "Min CPS:",
        lbl_max_cps      = "Max CPS:",             lbl_gap_ms      = "Short gap (ms):",
        lbl_max_width    = "Max Width (px):",      lbl_marker_dd   = "Single Marker:",
        lbl_section_case  = "CASE:",
        lbl_section_punct = "PUNCT/TEXT:",
        lbl_section_tags  = "TAGS/COMM:",
        lbl_section_smart = "SMART:",
        lbl_section_split = "SPLIT/JOIN:",
        lbl_section_time  = "TIME/SORT:",
        lbl_section_kara  = "KARAOKE:",
        lbl_data_import_mode = "Import Mode:",
        lbl_suite_tool    = "Extra Tool:",
        lbl_selection     = "Selection: %d lines",
        chk_clear_old     = "Clear previous markers",
        chk_gap_continuous= "Mark continuous (0ms)",
        chk_gap_ignore_kf = "Ignore gap on KF",
        chk_kf_seal       = "Keyframe Seal [START-ON-KF/END-ON-KF]",
        chk_data_import_cmt = "Wrap imported text as comments {…}",
        chk_data_import_same_layers = "Same Layers",
        chk_data_import_skip= "(empty box → skip Data Import)",
        btn_execute       = "EXECUTE",
        btn_cue           = "Cue Timer",
        btn_browse        = "Browse...",
        btn_extract_kf    = "Extract KF",
        btn_cancel        = "Cancel",
        btn_ok            = "OK",
        btn_save          = "Save",
        btn_process       = "Process",
        err_no_selection  = "No selection.",
        err_filter_zero   = "Filter resulted in 0 lines.",
        err_no_video      = "No video loaded.",
        err_invalid_twin  = "Twin KF must be a number ≥ 0",
        err_invalid_miss  = "Miss KF must be a number ≥ 0",
        err_invalid_ov    = "Overtime must be a number ≥ 0",
        msg_audit_done    = "Audit completed.\n\nLines audited: %d\nLines flagged: %d\n\nIssues:\n%s",
        msg_avg_cps       = "Average CPS (%d lines): %.2f",
        lbl_section_cps_gap          = "── CPS / Gap ──",
        lbl_section_filters_header   = "──── AUDIT TAG & STRUCTURE FILTERS ──────────────────────────",
        lbl_section_text_markers_hdr = "──── AUDIT TEXT MARKERS ─────────────────────────────────────",
        lbl_dropdown_skip_hint       = "(empty dropdown = skip section)",
        chk_has_n        = "\\N break [LINE-BREAK]",
        chk_has_pos      = "\\pos/\\move [POSITION-TAG]",
        chk_has_clip     = "\\clip [CLIP-TAG]",
        chk_has_fad      = "\\fad [FADE-TAG]",
        chk_has_t        = "\\t transform [TRANSFORM-TAG]",
        chk_has_k        = "\\k karaoke [KARAOKE-TAG]",
        chk_has_comment  = "Comment {} [COMMENT-BLOCK]",
        chk_has_num      = "Digits [HAS-DIGITS]",
        chk_full_italic  = "Italic line [FULL-ITALIC]",
        chk_has_cjk      = "CJK / kana [HAS-CJK]",
        chk_dbl_space    = "Double space [DOUBLE-SPACE]",
        chk_edge_space   = "Edge space [EDGE-SPACE]",
        chk_uppercase      = "Uppercase [UPPERCASE]",
        chk_3liner         = "3-Liner [THREE-LINES]",
        chk_missing_punct  = "No end punctuation [NO-END-PUNCT]",
        chk_punct_balance  = "Unpaired punctuation [UNPAIRED-PUNCT]",
        chk_orphan_word    = "Short last line [SHORT-LAST-LINE]",
        chk_orphan_tag     = "Broken tag [BROKEN-TAG]",
        chk_overlap        = "Overlap [OVERLAP]",
        chk_unstyled       = "Unstyled [DEFAULT-STYLE]",
        chk_double_italics = "Dbl Italics [ITALIC-ERROR]",
        chk_parentheses    = "Parentheses [PARENTHESES]",
        chk_name_prefix    = "Name Prefix [NAME-PREFIX]",
        chk_sentences      = "Sentences [MULTI-SENTENCE]",

        cue_title          = "Cue Timer — %s",
        cue_lbl_mode       = "Mode:",
        cue_chk_multi      = "Multi-chapter by layer",
        cue_chk_auto_discover = "Auto-search on open",
        cue_lbl_files      = "Data files (editable):",
        cue_lbl_sil30      = "-30 dB silences",
        cue_lbl_sil40      = "-40 dB silences",
        cue_lbl_sil50      = "-50 dB silences",
        cue_lbl_vad        = "VAD intervals",
        cue_lbl_flux       = "Flux events",
        cue_lbl_env        = "RMS/dB envelope",
        cue_lbl_kf         = "Keyframes file",
        cue_lbl_leads      = "Lead-in / out (ms):",
        cue_lbl_kfrange    = "KF snap end / start (ms):",
        cue_lbl_chain      = "Chain max out / in (ms):",
        cue_lbl_cut        = "Voice-cut limit (ms):",
        cue_lbl_cps        = "CPS flag above:",
        cue_lbl_floor      = "Duration floor (ms):",
        cue_chk_signs      = "Skip sign/karaoke/fx styles",
        cue_chk_stats      = "Show statistics",
        cue_lbl_style      = "Style filter:",
        cue_lbl_chapters   = "Chapters detected: %s",
        cue_none           = "(none)",
        cue_err_no_data    = "No audio data files found.\nUse Browse... or generate them with ProcesarLote.bat.",
        cue_err_no_sil     = "The LZT modes need at least one silence file.",
        cue_err_no_chapters= "Multi-chapter: no numbered data files found in the subtitle folder.",
        cue_msg_skipped    = "Layers without chapter files: %s",
        cue_msg_done       = "Cue Timer (%s)\n%s",
        cue_sum_lzt        = "Modified: %d",
        cue_sum_vt         = "Timed: %d/%d spoken | KF snaps: %d | Joins: %d | Flagged: %d",
        cue_sum_layer      = "Layer %d:",
        cue_no_voice       = "No voice found.",
        cue_hint           = "Auto-search fills empty paths when the dialog opens. Multi-chapter ignores path boxes. LZT modes ignore ms tuning (Config).",
        cue_hint_layer0    = "Layer 0 has no chapter files: set each line's layer to its chapter number.",
        cue_files_unknown  = "Files not recognized by name:\n%s",
        msg_config_saved   = "Config saved.",

        data_import_paste_hint = "Paste 'Dialogue:' lines (or use one of the modes).",
    },
    es = {
        title_suite      = "═══ CHRONO SUITE ═══════════════════",
        title_markers    = "═══ MARCADORES AUDITORIA ═════════════════",
        title_utilities  = "═══ UTILIDADES ═══════════════",
        title_data_import  = "─── IMPORTAR DATOS ──────",
        title_tools      = "─── Herramientas Extra ",
        lbl_apply_to     = "Aplicar a:",           lbl_filter      = "Filtro:",
        lbl_preset       = "Preset:",              lbl_kf_mode     = "Modo KF:", lbl_kf_dir = "Dir KF:",
        lbl_short_ms     = "Corto (ms):",          lbl_long_ms     = "Largo (ms):",
        lbl_twin_ms      = "Twin KF (ms):",        lbl_miss_ms     = "Miss KF (ms):",
        lbl_overtime     = "Sobretiempo (ms):",    lbl_min_cps     = "Min CPS:",
        lbl_max_cps      = "Max CPS:",             lbl_gap_ms      = "Gap corto (ms):",
        lbl_max_width    = "Ancho máx (px):",      lbl_marker_dd   = "Marcador único:",
        lbl_section_case  = "CAJA:",
        lbl_section_punct = "PUNT/TEXTO:",
        lbl_section_tags  = "TAGS/COMENT:",
        lbl_section_smart = "INTELIG:",
        lbl_section_split = "DIVIDIR/UNIR:",
        lbl_section_time  = "TIEMPO/ORDEN:",
        lbl_section_kara  = "KARAOKE:",
        lbl_data_import_mode = "Modo Importación:",
        lbl_suite_tool    = "Herramienta:",
        lbl_selection     = "Selección: %d líneas",
        chk_clear_old     = "Limpiar marcadores previos",
        chk_gap_continuous= "Marcar continuas (0ms)",
        chk_gap_ignore_kf = "Ignorar gap en KF",
        chk_kf_seal       = "Sello Keyframe [START-ON-KF/END-ON-KF]",
        chk_data_import_cmt = "Importar como comentario {…}",
        chk_data_import_same_layers = "Same Layers",
        chk_data_import_skip= "(caja vacía → omitir Importar Datos)",
        btn_execute       = "EJECUTAR",
        btn_cue           = "Cue Timer",
        btn_browse        = "Buscar...",
        btn_extract_kf    = "Extraer KF",
        btn_cancel        = "Cancelar",
        btn_ok            = "OK",
        btn_save          = "Guardar",
        btn_process       = "Procesar",
        err_no_selection  = "Sin selección.",
        err_filter_zero   = "El filtro resultó en 0 líneas.",
        err_no_video      = "No hay vídeo cargado.",
        err_invalid_twin  = "Twin KF debe ser un número ≥ 0",
        err_invalid_miss  = "Miss KF debe ser un número ≥ 0",
        err_invalid_ov    = "Sobretiempo debe ser un número ≥ 0",
        msg_audit_done    = "Auditoría completada.\n\nLíneas auditadas: %d\nLíneas marcadas: %d\n\nProblemas:\n%s",
        msg_avg_cps       = "CPS promedio (%d líneas): %.2f",
        lbl_section_cps_gap          = "── CPS / Gap ──",
        lbl_section_filters_header   = "──── FILTROS DE TAGS Y ESTRUCTURA (AUDIT) ────────────────────",
        lbl_section_text_markers_hdr = "──── MARCADORES DE TEXTO (AUDIT) ────────────────────────────",
        lbl_dropdown_skip_hint       = "(dropdown vacío = saltar sección)",
        chk_has_n        = "Salto \\N [LINE-BREAK]",
        chk_has_pos      = "\\pos/\\move [POSITION-TAG]",
        chk_has_clip     = "\\clip [CLIP-TAG]",
        chk_has_fad      = "\\fad [FADE-TAG]",
        chk_has_t        = "\\t transform [TRANSFORM-TAG]",
        chk_has_k        = "\\k karaoke [KARAOKE-TAG]",
        chk_has_comment  = "Comentario {} [COMMENT-BLOCK]",
        chk_has_num      = "Dígitos [HAS-DIGITS]",
        chk_full_italic  = "Línea cursiva [FULL-ITALIC]",
        chk_has_cjk      = "CJK / kana [HAS-CJK]",
        chk_dbl_space    = "Espacio doble [DOUBLE-SPACE]",
        chk_edge_space   = "Espacio bordes [EDGE-SPACE]",
        chk_uppercase      = "Mayúsculas [UPPERCASE]",
        chk_3liner         = "3 Líneas [THREE-LINES]",
        chk_missing_punct  = "Sin puntuación final [NO-END-PUNCT]",
        chk_punct_balance  = "Puntuación sin pareja [UNPAIRED-PUNCT]",
        chk_orphan_word    = "Última línea corta [SHORT-LAST-LINE]",
        chk_orphan_tag     = "Tag roto [BROKEN-TAG]",
        chk_overlap        = "Solapamiento [OVERLAP]",
        chk_unstyled       = "Sin estilo [DEFAULT-STYLE]",
        chk_double_italics = "Dbl Cursiva [ITALIC-ERROR]",
        chk_parentheses    = "Paréntesis [PARENTHESES]",
        chk_name_prefix    = "Nombre [NAME-PREFIX]",
        chk_sentences      = "Oraciones [MULTI-SENTENCE]",
        cue_title          = "Cue Timer — %s",
        cue_lbl_mode       = "Modo:",
        cue_chk_multi      = "Multi-capítulo por layer",
        cue_chk_auto_discover = "Autobuscar al abrir",
        cue_lbl_files      = "Archivos de datos (editables):",
        cue_lbl_sil30      = "Silencios -30 dB",
        cue_lbl_sil40      = "Silencios -40 dB",
        cue_lbl_sil50      = "Silencios -50 dB",
        cue_lbl_vad        = "Intervalos VAD",
        cue_lbl_flux       = "Eventos flux",
        cue_lbl_env        = "Envelope RMS/dB",
        cue_lbl_kf         = "Archivo de keyframes",
        cue_lbl_leads      = "Lead-in / out (ms):",
        cue_lbl_kfrange    = "Snap KF fin / inicio (ms):",
        cue_lbl_chain      = "Cadena máx out / in (ms):",
        cue_lbl_cut        = "Corte de voz máx (ms):",
        cue_lbl_cps        = "Marcar CPS sobre:",
        cue_lbl_floor      = "Duración mínima (ms):",
        cue_chk_signs      = "Omitir estilos sign/karaoke/fx",
        cue_chk_stats      = "Mostrar estadísticas",
        cue_lbl_style      = "Filtro de estilo:",
        cue_lbl_chapters   = "Capítulos detectados: %s",
        cue_none           = "(ninguno)",
        cue_err_no_data    = "No se encontraron archivos de datos de audio.\nUsa Buscar... o genéralos con ProcesarLote.bat.",
        cue_err_no_sil     = "Los modos LZT necesitan al menos un archivo de silencios.",
        cue_err_no_chapters= "Multi-capítulo: no hay archivos numerados en la carpeta del subtítulo.",
        cue_msg_skipped    = "Layers sin archivos de capítulo: %s",
        cue_msg_done       = "Cue Timer (%s)\n%s",
        cue_sum_lzt        = "Modificadas: %d",
        cue_sum_vt         = "Cronometradas: %d/%d habladas | Snaps KF: %d | Uniones: %d | Marcadas: %d",
        cue_sum_layer      = "Layer %d:",
        cue_no_voice       = "No se encontró voz.",
        cue_hint           = "Autobuscar llena rutas vacías al abrir. Multi-capítulo ignora las rutas. Los modos LZT ignoran los ms (Config).",
        cue_hint_layer0    = "Layer 0 no tiene archivos de capítulo: asigna a cada línea el layer de su capítulo.",
        cue_files_unknown  = "Archivos no reconocidos por nombre:\n%s",
        msg_config_saved   = "Configuración guardada.",
        data_import_paste_hint = "Pega líneas 'Dialogue:' (o usa uno de los modos).",
    },
    pt = {
        title_suite      = "═══ CHRONO SUITE ═══════════════════",
        title_markers    = "═══ MARCADORES AUDITORIA ═════════════════",
        title_utilities  = "═══ UTILIDADES ═══════════════",
        title_data_import  = "─── IMPORTAR DADOS ──────",
        title_tools      = "─── Ferramentas Extra",
        lbl_apply_to     = "Aplicar em:",          lbl_filter      = "Filtro:",
        lbl_preset       = "Preset:",              lbl_kf_mode     = "Modo KF:", lbl_kf_dir = "Dir KF:",
        lbl_short_ms     = "Curto (ms):",          lbl_long_ms     = "Longo (ms):",
        lbl_twin_ms      = "Twin KF (ms):",        lbl_miss_ms     = "Miss KF (ms):",
        lbl_overtime     = "Sobretempo (ms):",     lbl_min_cps     = "Min CPS:",
        lbl_max_cps      = "Max CPS:",             lbl_gap_ms      = "Gap curto (ms):",
        lbl_max_width    = "Largura máx (px):",    lbl_marker_dd   = "Marcador único:",
        lbl_section_case  = "CAIXA:",
        lbl_section_punct = "PONT/TEXTO:",
        lbl_section_tags  = "TAGS/COMENT:",
        lbl_section_smart = "INTELIG:",
        lbl_section_split = "DIVIDIR/UNIR:",
        lbl_section_time  = "TEMPO/ORDEM:",
        lbl_section_kara  = "KARAOKE:",
        lbl_data_import_mode = "Modo Importação:",
        lbl_suite_tool    = "Ferramenta:",
        lbl_selection     = "Seleção: %d linhas",
        chk_clear_old     = "Limpar marcadores prévios",
        chk_gap_continuous= "Marcar contínuas (0ms)",
        chk_gap_ignore_kf = "Ignorar gap em KF",
        chk_kf_seal       = "Selo Keyframe [START-ON-KF/END-ON-KF]",
        chk_data_import_cmt = "Importar como comentário {…}",
        chk_data_import_same_layers = "Same Layers",
        chk_data_import_skip= "(caixa vazia → ignorar Importar Dados)",
        btn_execute       = "EXECUTAR",
        btn_cue           = "Cue Timer",
        btn_browse        = "Procurar...",
        btn_extract_kf    = "Extrair KF",
        btn_cancel        = "Cancelar",
        btn_ok            = "OK",
        btn_save          = "Salvar",
        btn_process       = "Processar",
        err_no_selection  = "Sem seleção.",
        err_filter_zero   = "O filtro resultou em 0 linhas.",
        err_no_video      = "Nenhum vídeo carregado.",
        err_invalid_twin  = "Twin KF deve ser um número ≥ 0",
        err_invalid_miss  = "Miss KF deve ser um número ≥ 0",
        err_invalid_ov    = "Sobretempo deve ser um número ≥ 0",
        msg_audit_done    = "Auditoria concluída.\n\nLinhas auditadas: %d\nLinhas marcadas: %d\n\nProblemas:\n%s",
        msg_avg_cps       = "CPS médio (%d linhas): %.2f",
        lbl_section_cps_gap          = "── CPS / Gap ──",
        lbl_section_filters_header   = "──── FILTROS DE TAGS E ESTRUTURA (AUDIT) ─────────────────────",
        lbl_section_text_markers_hdr = "──── MARCADORES DE TEXTO (AUDIT) ─────────────────────────────",
        lbl_dropdown_skip_hint       = "(dropdown vazio = saltar seção)",
        chk_has_n        = "Quebra \\N [LINE-BREAK]",
        chk_has_pos      = "\\pos/\\move [POSITION-TAG]",
        chk_has_clip     = "\\clip [CLIP-TAG]",
        chk_has_fad      = "\\fad [FADE-TAG]",
        chk_has_t        = "\\t transform [TRANSFORM-TAG]",
        chk_has_k        = "\\k karaoke [KARAOKE-TAG]",
        chk_has_comment  = "Comentário {} [COMMENT-BLOCK]",
        chk_has_num      = "Dígitos [HAS-DIGITS]",
        chk_full_italic  = "Linha itálica [FULL-ITALIC]",
        chk_has_cjk      = "CJK / kana [HAS-CJK]",
        chk_dbl_space    = "Espaço duplo [DOUBLE-SPACE]",
        chk_edge_space   = "Espaço bordas [EDGE-SPACE]",
        chk_uppercase      = "Maiúsculas [UPPERCASE]",
        chk_3liner         = "3 Linhas [THREE-LINES]",
        chk_missing_punct  = "Sem pontuação final [NO-END-PUNCT]",
        chk_punct_balance  = "Pontuação sem par [UNPAIRED-PUNCT]",
        chk_orphan_word    = "Última linha curta [SHORT-LAST-LINE]",
        chk_orphan_tag     = "Tag quebrada [BROKEN-TAG]",
        chk_overlap        = "Sobreposição [OVERLAP]",
        chk_unstyled       = "Sem estilo [DEFAULT-STYLE]",
        chk_double_italics = "Dbl Itálico [ITALIC-ERROR]",
        chk_parentheses    = "Parênteses [PARENTHESES]",
        chk_name_prefix    = "Nome [NAME-PREFIX]",
        chk_sentences      = "Frases [MULTI-SENTENCE]",
        cue_title          = "Cue Timer — %s",
        cue_lbl_mode       = "Modo:",
        cue_chk_multi      = "Multi-capítulo por camada",
        cue_chk_auto_discover = "Buscar ao abrir",
        cue_lbl_files      = "Arquivos de dados (editáveis):",
        cue_lbl_sil30      = "Silêncios -30 dB",
        cue_lbl_sil40      = "Silêncios -40 dB",
        cue_lbl_sil50      = "Silêncios -50 dB",
        cue_lbl_vad        = "Intervalos VAD",
        cue_lbl_flux       = "Eventos flux",
        cue_lbl_env        = "Envelope RMS/dB",
        cue_lbl_kf         = "Arquivo de keyframes",
        cue_lbl_leads      = "Lead-in / out (ms):",
        cue_lbl_kfrange    = "Snap KF fim / início (ms):",
        cue_lbl_chain      = "Cadeia máx out / in (ms):",
        cue_lbl_cut        = "Corte de voz máx (ms):",
        cue_lbl_cps        = "Marcar CPS acima de:",
        cue_lbl_floor      = "Duração mínima (ms):",
        cue_chk_signs      = "Pular estilos sign/karaokê/fx",
        cue_chk_stats      = "Mostrar estatísticas",
        cue_lbl_style      = "Filtro de estilo:",
        cue_lbl_chapters   = "Capítulos detectados: %s",
        cue_none           = "(nenhum)",
        cue_err_no_data    = "Nenhum arquivo de dados de áudio encontrado.\nUse Procurar... ou gere-os com ProcesarLote.bat.",
        cue_err_no_sil     = "Os modos LZT precisam de pelo menos um arquivo de silêncios.",
        cue_err_no_chapters= "Multi-capítulo: nenhum arquivo numerado na pasta da legenda.",
        cue_msg_skipped    = "Camadas sem arquivos de capítulo: %s",
        cue_msg_done       = "Cue Timer (%s)\n%s",
        cue_sum_lzt        = "Modificadas: %d",
        cue_sum_vt         = "Cronometradas: %d/%d faladas | Snaps KF: %d | Uniões: %d | Marcadas: %d",
        cue_sum_layer      = "Camada %d:",
        cue_no_voice       = "Nenhuma voz encontrada.",
        cue_hint           = "Buscar ao abrir preenche caminhos vazios. Multi-capítulo ignora caminhos. Modos LZT ignoram ajustes em ms (Config).",
        cue_hint_layer0    = "A camada 0 não tem arquivos de capítulo: defina em cada linha a camada do seu capítulo.",
        cue_files_unknown  = "Arquivos não reconhecidos pelo nome:\n%s",
        msg_config_saved   = "Configuração salva.",
        data_import_paste_hint = "Cole linhas 'Dialogue:' (ou use um dos modos).",
    },
}

local EXTRA_LANG = {
    en = {
        btn_config="Config", btn_help="Help", help_btn_close="Close",
        cfg_title="Chrono Suite Config", cfg_lbl_language="Language:", cfg_lbl_lazy="Cue Timer (LZT Legacy)", cfg_lbl_method="Method:", cfg_lbl_limit="Limit (ms):",
        cfg_chk_apply_start="Apply start", cfg_chk_apply_end="Apply end", cfg_chk_tagging="Write timing tags", cfg_lbl_tag_mode="Tag mode:", cfg_lbl_tag_scope="Tag scope:",
        cfg_lbl_scxvid="SCXvid", cfg_lbl_scxvid_path="SCXvid path:", cfg_lbl_ffmpeg_path="FFmpeg path:", cfg_lbl_log_suffix="Log suffix:",
        cfg_lbl_leadutil="Lead-In / Lead-Out / Chain", cfg_lbl_lead_step="Step (ms):", cfg_lbl_chain_cap="Chain max (ms):", cfg_chk_table_csv="Write noise_table CSV (Table)",
        cfg_lbl_kite="Kite Timing", cfg_lbl_lead_in_base="Lead-in base:", cfg_lbl_lead_in_max="Lead-in max:", cfg_lbl_lead_out_base="Lead-out base:", cfg_lbl_lead_out_max="Lead-out max:", cfg_lbl_lead_out_chain="Chain out:", cfg_lbl_chain_gap_max="Chain gap:",
        cfg_lbl_bidir="Bidirectional Snapping", cfg_lbl_bidir_snap="Snap range (frames):", cfg_lbl_snap_protect="Directional range (ms):",
        cfg_lbl_presets="Audit Presets", cfg_lbl_preset_start="Start T/M:", cfg_lbl_preset_end="End T/M:", cfg_lbl_preset_full_kf="Full T/M:", cfg_lbl_preset_full_time="Full S/L:", cfg_lbl_preset_full_read="Full CPS/W:", cfg_lbl_preset_full_gap="Full Gap S/L:", cfg_lbl_preset_duration="Duration S/L:", cfg_lbl_preset_cps="CPS Max:", cfg_lbl_preset_gaps="Gaps S/L:", cfg_lbl_preset_overtime="Overtime:",
        cfg_msg_saved="Config saved.", cfg_msg_lang_changed="Language changed. Reopen the dialog.",
        msg_bidir_done="Bidirectional snapping done.\n\nLines modified: %d\nStarts snapped: %d\nEnds snapped: %d\nRange: ±%d frames",
        err_no_keyframes="No keyframes loaded.",
        title_markers="=== AUDIT MARKERS ===", title_utilities="=== UTILITY TOOLS ===", title_data_import="--- DATA IMPORT ---", title_tools="--- EXTRA TOOLS ---",
        lbl_section_case="CASE:", lbl_section_punct="PUNCT/TEXT:", lbl_section_tags="TAGS/COMMENTS:", lbl_section_smart="SMART:", lbl_section_split="SPLIT/JOIN:", lbl_section_time="TIME/SORT:", lbl_suite_tool="Extra Tool:", lbl_large_gap="Large gap (ms):",
        chk_kf_seal="Keyframe seal [START-ON-KF/END-ON-KF]", chk_data_import_cmt="Import text as comments {...}", chk_data_import_skip="(empty box = skip Data Import)",
        chk_has_n="Line break [LINE-BREAK]", chk_has_pos="Position tag [POSITION-TAG]", chk_has_clip="Clip tag [CLIP-TAG]", chk_has_fad="Fade tag [FADE-TAG]", chk_has_t="Transform tag [TRANSFORM-TAG]", chk_has_k="Karaoke tag [KARAOKE-TAG]", chk_has_comment="Comment block [COMMENT-BLOCK]", chk_has_num="Digits [HAS-DIGITS]", chk_full_italic="Full italic [FULL-ITALIC]", chk_dbl_space="Double space [DOUBLE-SPACE]", chk_edge_space="Edge space [EDGE-SPACE]",
        chk_3liner="Three lines [THREE-LINES]", chk_missing_punct="No end punctuation [NO-END-PUNCT]", chk_punct_balance="Unpaired punctuation [UNPAIRED-PUNCT]", chk_orphan_word="Short last line [SHORT-LAST-LINE]", chk_orphan_tag="Broken tag [BROKEN-TAG]", chk_unstyled="Default style [DEFAULT-STYLE]", chk_double_italics="Italic error [ITALIC-ERROR]", chk_parentheses="Parentheses [PARENTHESES]", chk_name_prefix="Name prefix [NAME-PREFIX]", chk_sentences="Multiple sentences [MULTI-SENTENCE]",
    },
    es = {
        btn_config="Config", btn_help="Ayuda", help_btn_close="Cerrar",
        cfg_title="Config de Chrono Suite", cfg_lbl_language="Idioma:", cfg_lbl_lazy="Cue Timer (LZT Legacy)", cfg_lbl_method="Método:", cfg_lbl_limit="Límite (ms):",
        cfg_chk_apply_start="Aplicar inicio", cfg_chk_apply_end="Aplicar final", cfg_chk_tagging="Escribir marcas de tiempo", cfg_lbl_tag_mode="Modo de marca:", cfg_lbl_tag_scope="Alcance:",
        cfg_lbl_scxvid="SCXvid", cfg_lbl_scxvid_path="Ruta de SCXvid:", cfg_lbl_ffmpeg_path="Ruta de FFmpeg:", cfg_lbl_log_suffix="Sufijo del log:",
        cfg_lbl_leadutil="Lead-In / Lead-Out / Cadena", cfg_lbl_lead_step="Paso (ms):", cfg_lbl_chain_cap="Cadena máx (ms):", cfg_chk_table_csv="Escribir CSV noise_table (Table)",
        cfg_lbl_kite="Kite Timing", cfg_lbl_lead_in_base="Lead-in base:", cfg_lbl_lead_in_max="Lead-in máximo:", cfg_lbl_lead_out_base="Lead-out base:", cfg_lbl_lead_out_max="Lead-out máximo:", cfg_lbl_lead_out_chain="Salida en cadena:", cfg_lbl_chain_gap_max="Gap de cadena:",
        cfg_lbl_bidir="Bidirectional Snapping", cfg_lbl_bidir_snap="Rango de snap (frames):", cfg_lbl_snap_protect="Rango direccional (ms):",
        cfg_lbl_presets="Presets de auditoría", cfg_lbl_preset_start="Inicio T/M:", cfg_lbl_preset_end="Final T/M:", cfg_lbl_preset_full_kf="Completa T/M:", cfg_lbl_preset_full_time="Completa C/L:", cfg_lbl_preset_full_read="Completa CPS/An:", cfg_lbl_preset_full_gap="Completa Gap C/L:", cfg_lbl_preset_duration="Duración C/L:", cfg_lbl_preset_cps="CPS máx:", cfg_lbl_preset_gaps="Gaps C/L:", cfg_lbl_preset_overtime="Sobretiempo:",
        cfg_msg_saved="Configuración guardada.", cfg_msg_lang_changed="Idioma cambiado. Reabre el diálogo.",
        msg_bidir_done="Bidirectional Snapping finalizado.\n\nLíneas modificadas: %d\nInicios ajustados: %d\nFinales ajustados: %d\nRango: ±%d frames",
        err_no_keyframes="No hay keyframes cargados.",
        title_markers="=== MARCADORES DE AUDITORÍA ===", title_utilities="=== UTILIDADES ===", title_data_import="--- IMPORTAR DATOS ---", title_tools="--- HERRAMIENTAS EXTRA ---",
        lbl_apply_to="Aplicar a:", lbl_filter="Filtro:", lbl_marker_dd="Marcador único:", lbl_large_gap="Gap largo (ms):", lbl_section_case="CAJA:", lbl_section_punct="PUNT/TEXTO:", lbl_section_tags="TAGS/COMENTARIOS:", lbl_section_smart="SMART:", lbl_section_split="DIVIDIR/UNIR:", lbl_section_time="TIEMPO/ORDEN:", lbl_suite_tool="Herramienta:", lbl_selection="Selección: %d líneas",
        chk_clear_old="Limpiar marcadores previos", chk_gap_continuous="Marcar continuas (0 ms)", chk_gap_ignore_kf="Ignorar gap si cae en KF", chk_kf_seal="Sello de keyframe [START-ON-KF/END-ON-KF]", chk_data_import_cmt="Importar texto como comentarios {...}", chk_data_import_skip="(caja vacía = saltar Importar Datos)",
        chk_has_n="Salto de línea [LINE-BREAK]", chk_has_pos="Tag de posición [POSITION-TAG]", chk_has_clip="Tag de clip [CLIP-TAG]", chk_has_fad="Tag de fade [FADE-TAG]", chk_has_t="Tag de transformación [TRANSFORM-TAG]", chk_has_k="Tag de karaoke [KARAOKE-TAG]", chk_has_comment="Bloque de comentario [COMMENT-BLOCK]", chk_has_num="Dígitos [HAS-DIGITS]", chk_full_italic="Toda en cursiva [FULL-ITALIC]", chk_dbl_space="Doble espacio [DOUBLE-SPACE]", chk_edge_space="Espacio al borde [EDGE-SPACE]",
        chk_uppercase="Mayúsculas [UPPERCASE]", chk_3liner="Tres líneas [THREE-LINES]", chk_missing_punct="Sin puntuación final [NO-END-PUNCT]", chk_punct_balance="Puntuación sin pareja [UNPAIRED-PUNCT]", chk_orphan_word="Última línea corta [SHORT-LAST-LINE]", chk_orphan_tag="Tag roto [BROKEN-TAG]", chk_overlap="Solapamiento [OVERLAP]", chk_unstyled="Estilo Default [DEFAULT-STYLE]", chk_double_italics="Error de cursiva [ITALIC-ERROR]", chk_parentheses="Paréntesis [PARENTHESES]", chk_name_prefix="Prefijo de nombre [NAME-PREFIX]", chk_sentences="Varias oraciones [MULTI-SENTENCE]",
        msg_config_saved="Configuración guardada.", data_import_paste_hint="Pega líneas 'Dialogue:' o elige un modo de importación.",
    },
    pt = {
        btn_config="Config", btn_help="Ajuda", help_btn_close="Fechar",
        cfg_title="Config do Chrono Suite", cfg_lbl_language="Idioma:", cfg_lbl_lazy="Cue Timer (LZT Legacy)", cfg_lbl_method="Método:", cfg_lbl_limit="Limite (ms):",
        cfg_chk_apply_start="Aplicar início", cfg_chk_apply_end="Aplicar fim", cfg_chk_tagging="Escrever marcas de tempo", cfg_lbl_tag_mode="Modo da marca:", cfg_lbl_tag_scope="Escopo:",
        cfg_lbl_scxvid="SCXvid", cfg_lbl_scxvid_path="Caminho do SCXvid:", cfg_lbl_ffmpeg_path="Caminho do FFmpeg:", cfg_lbl_log_suffix="Sufixo do log:",
        cfg_lbl_leadutil="Lead-In / Lead-Out / Cadeia", cfg_lbl_lead_step="Passo (ms):", cfg_lbl_chain_cap="Cadeia máx (ms):", cfg_chk_table_csv="Gravar CSV noise_table (Table)",
        cfg_lbl_kite="Kite Timing", cfg_lbl_lead_in_base="Lead-in base:", cfg_lbl_lead_in_max="Lead-in máximo:", cfg_lbl_lead_out_base="Lead-out base:", cfg_lbl_lead_out_max="Lead-out máximo:", cfg_lbl_lead_out_chain="Saída em cadeia:", cfg_lbl_chain_gap_max="Gap da cadeia:",
        cfg_lbl_bidir="Bidirectional Snapping", cfg_lbl_bidir_snap="Alcance de snap (frames):", cfg_lbl_snap_protect="Alcance direcional (ms):",
        cfg_lbl_presets="Presets de auditoria", cfg_lbl_preset_start="Início T/M:", cfg_lbl_preset_end="Fim T/M:", cfg_lbl_preset_full_kf="Completa T/M:", cfg_lbl_preset_full_time="Completa C/L:", cfg_lbl_preset_full_read="Completa CPS/Lg:", cfg_lbl_preset_full_gap="Completa Gap C/L:", cfg_lbl_preset_duration="Duração C/L:", cfg_lbl_preset_cps="CPS máx:", cfg_lbl_preset_gaps="Gaps C/L:", cfg_lbl_preset_overtime="Sobretempo:",
        cfg_msg_saved="Configuração salva.", cfg_msg_lang_changed="Idioma alterado. Reabra o diálogo.",
        msg_bidir_done="Bidirectional Snapping concluído.\n\nLinhas modificadas: %d\nInícios ajustados: %d\nFinais ajustados: %d\nAlcance: ±%d frames",
        err_no_keyframes="Nenhum keyframe carregado.",
        title_markers="=== MARCADORES DE AUDITORIA ===", title_utilities="=== UTILIDADES ===", title_data_import="--- IMPORTAR DADOS ---", title_tools="--- FERRAMENTAS EXTRA ---",
        lbl_apply_to="Aplicar em:", lbl_filter="Filtro:", lbl_marker_dd="Marcador único:", lbl_large_gap="Gap longo (ms):", lbl_section_case="CAIXA:", lbl_section_punct="PONT/TEXTO:", lbl_section_tags="TAGS/COMENTÁRIOS:", lbl_section_smart="SMART:", lbl_section_split="DIVIDIR/UNIR:", lbl_section_time="TEMPO/ORDEM:", lbl_suite_tool="Ferramenta:", lbl_selection="Seleção: %d linhas",
        chk_clear_old="Limpar marcadores anteriores", chk_gap_continuous="Marcar contínuas (0 ms)", chk_gap_ignore_kf="Ignorar gap se cair em KF", chk_kf_seal="Selo de keyframe [START-ON-KF/END-ON-KF]", chk_data_import_cmt="Importar texto como comentários {...}", chk_data_import_skip="(caixa vazia = pular Importar Dados)",
        chk_has_n="Quebra de linha [LINE-BREAK]", chk_has_pos="Tag de posição [POSITION-TAG]", chk_has_clip="Tag de clip [CLIP-TAG]", chk_has_fad="Tag de fade [FADE-TAG]", chk_has_t="Tag de transformação [TRANSFORM-TAG]", chk_has_k="Tag de karaokê [KARAOKE-TAG]", chk_has_comment="Bloco de comentário [COMMENT-BLOCK]", chk_has_num="Dígitos [HAS-DIGITS]", chk_full_italic="Toda em itálico [FULL-ITALIC]", chk_dbl_space="Espaço duplo [DOUBLE-SPACE]", chk_edge_space="Espaço nas bordas [EDGE-SPACE]",
        chk_uppercase="Maiúsculas [UPPERCASE]", chk_3liner="Três linhas [THREE-LINES]", chk_missing_punct="Sem pontuação final [NO-END-PUNCT]", chk_punct_balance="Pontuação sem par [UNPAIRED-PUNCT]", chk_orphan_word="Última linha curta [SHORT-LAST-LINE]", chk_orphan_tag="Tag quebrada [BROKEN-TAG]", chk_overlap="Sobreposição [OVERLAP]", chk_unstyled="Estilo Default [DEFAULT-STYLE]", chk_double_italics="Erro de itálico [ITALIC-ERROR]", chk_parentheses="Parênteses [PARENTHESES]", chk_name_prefix="Prefixo de nome [NAME-PREFIX]", chk_sentences="Várias frases [MULTI-SENTENCE]",
        msg_config_saved="Configuração salva.", data_import_paste_hint="Cole linhas 'Dialogue:' ou escolha um modo de importação.",
    },
}

local LOCALE_PATCH = {
    en = {
        err_no_active_dialogue   = "No valid active dialogue lines found.",
        err_no_sync_point        = "Data Import — Songs: no sync point found.\nNeed Comment line with layer 50.",
        err_scxvid_not_found     = "SCXvid not found:\n%s",
        err_ffmpeg_not_found     = "FFmpeg not found:\n%s",
        err_cannot_create_batch  = "Error: cannot create temp batch file",
        err_cannot_create_shell  = "Error: cannot create temp shell script",
        err_no_lines_selected    = "No lines selected.",
        err_not_inside_fold      = "Active line is not inside a fold.\nMove to a line within a fold group.",
        err_no_fold_group        = "Could not find complete fold group.",
        err_cannot_write_file    = "Could not write to:\n%s",
        err_shift_min_two        = "Shift First requires at least 2 lines.",
        err_shift_first_two      = "Shift First requires the first two selected lines to be dialogue lines.",
        err_no_styles            = "No styles found in selected lines.",
        err_no_styles_delete     = "No lines to delete. All selected lines have a kept style.",
        err_tolerance_positive   = "Tolerance must be a positive number.",
        err_paste_mpvqc          = "Paste mpvQC text first.",
        err_no_mpvqc_comments    = "No mpvQC comments found.",
        msg_process_started      = "Process started.\nLog: %s",
        msg_ae_saved             = "AE keyframe data saved to:\n%s",
        msg_kite_done            = "Kite Timing: %d changes from %d selected lines.",
        msg_replacer_done        = "Text Replacer: %d lines modified.",
        msg_filter_done          = "Deleted %d lines, kept %d.",
        msg_mpvqc_done           = "mpv QC done.\nLines modified: %d",
        msg_remover_done         = "Remover Assistant done.\nLines modified: %d\nLines deleted: %d",
        err_remover_none         = "Select at least one remover option.",
        lbl_include_partial      = "Include partially overlapping lines",
        lbl_paste_dialogue       = "Paste text or Dialogue/Comment lines:",
        lbl_import_as_comments   = "Import plain text as {…} comments",
        lbl_original_text        = "ORIGINAL TEXT",
        lbl_replacement_text     = "REPLACEMENT TEXT",
        lbl_replacer_help        = "Each line in Original matches the corresponding line in Replacement. Tags preserved.",
        lbl_styles_filter_help   = "Styles in selection.\nRemove the ones to DELETE; keep the rest.",
        lbl_styles_filter_warn   = "Lines whose style is NOT in the list will be deleted.",
        lbl_styles_filter_empty  = "WARNING: list is empty.\nThis will delete ALL selected lines. Continue?",
        lbl_styles_filter_sum    = "Summary:\n  Keep:   %d lines\n  Delete: %d lines\n\nProceed?",
        lbl_mpvqc_title          = "mpv QC",
        lbl_mpvqc_tolerance      = "Tolerance (ms):",
        lbl_mpvqc_paste          = "Paste mpvQC text:",
        lbl_remover_title        = "Remover Assistant",
        lbl_remover_text         = "Visible text",
        lbl_remover_tags         = "Override tags",
        lbl_remover_comments     = "Comments",
        chk_rem_n                = "Remove \\N",
        chk_rem_h                = "Remove \\h",
        chk_rem_double_space     = "Double spaces",
        chk_rem_edge_space       = "Edge spaces",
        chk_rem_excl             = "Exclamation signs",
        chk_rem_quest            = "Question signs",
        chk_rem_combo            = "Mixed ¡¿?! signs",
        chk_rem_final_commas     = "Final commas",
        chk_rem_all_commas       = "All commas",
        chk_rem_quotes           = "Quotes",
        chk_rem_apostrophes      = "Apostrophes",
        chk_rem_stutter          = "Stutter X-X",
        chk_rem_dup_letters      = "Duplicate letters",
        chk_rem_leading_ellipsis = "Leading ellipsis",
        chk_rem_ellipsis         = "All ellipsis",
        chk_rem_italic_tags      = "\\i tags",
        chk_rem_q_tags           = "\\q tags",
        chk_rem_an8              = "\\an8",
        chk_rem_comment_lines    = "Comment lines",
        chk_rem_inline_comments  = "Inline comments {...}",
        btn_import               = "Import",
        btn_replace_all          = "Replace All",
        btn_apply                = "Apply",
        btn_filter               = "Filter",
        btn_yes_delete_all       = "Yes, delete all",
        btn_yes_proceed          = "Yes, proceed",
    },
    es = {
        err_no_active_dialogue   = "No se encontraron líneas de diálogo activas válidas.",
        err_no_sync_point        = "Importar datos — Songs: no se encontró punto de sincronización.\nSe requiere línea Comment con layer 50.",
        err_scxvid_not_found     = "SCXvid no encontrado:\n%s",
        err_ffmpeg_not_found     = "FFmpeg no encontrado:\n%s",
        err_cannot_create_batch  = "Error: no se pudo crear el archivo batch temporal",
        err_cannot_create_shell  = "Error: no se pudo crear el script shell temporal",
        err_no_lines_selected    = "Sin líneas seleccionadas.",
        err_not_inside_fold      = "La línea activa no está dentro de un fold.\nMuévete a una línea dentro de un grupo fold.",
        err_no_fold_group        = "No se encontró un grupo fold completo.",
        err_cannot_write_file    = "No se pudo escribir en:\n%s",
        err_shift_min_two        = "Shift First requiere al menos 2 líneas.",
        err_shift_first_two      = "Shift First requiere que las dos primeras líneas seleccionadas sean diálogo.",
        err_no_styles            = "No se encontraron estilos en las líneas seleccionadas.",
        err_no_styles_delete     = "No hay líneas que eliminar. Todas las líneas tienen un estilo conservado.",
        err_tolerance_positive   = "La tolerancia debe ser un número positivo.",
        err_paste_mpvqc          = "Pega primero el texto de mpvQC.",
        err_no_mpvqc_comments    = "No se encontraron comentarios de mpvQC.",
        msg_process_started      = "Proceso iniciado.\nLog: %s",
        msg_ae_saved             = "Datos AE guardados en:\n%s",
        msg_kite_done            = "Kite Timing: %d cambios en %d líneas seleccionadas.",
        msg_replacer_done        = "Text Replacer: %d líneas modificadas.",
        msg_filter_done          = "Se eliminaron %d líneas, se conservaron %d.",
        msg_mpvqc_done           = "mpv QC finalizado.\nLíneas modificadas: %d",
        msg_remover_done         = "Remover Assistant finalizado.\nLíneas modificadas: %d\nLíneas eliminadas: %d",
        err_remover_none         = "Selecciona al menos una opcion de limpieza.",
        lbl_include_partial      = "Incluir líneas con superposición parcial",
        lbl_paste_dialogue       = "Pega texto o líneas Dialogue/Comment:",
        lbl_import_as_comments   = "Importar texto plano como comentarios {…}",
        lbl_original_text        = "TEXTO ORIGINAL",
        lbl_replacement_text     = "TEXTO DE REEMPLAZO",
        lbl_replacer_help        = "Cada línea de Original corresponde a la misma línea en Reemplazo. Los tags se conservan.",
        lbl_styles_filter_help   = "Estilos en la selección.\nElimina los que quieras BORRAR; conserva el resto.",
        lbl_styles_filter_warn   = "Las líneas cuyo estilo NO esté en la lista serán eliminadas.",
        lbl_styles_filter_empty  = "AVISO: la lista está vacía.\nEsto eliminará TODAS las líneas seleccionadas. ¿Continuar?",
        lbl_styles_filter_sum    = "Resumen:\n  Conservar: %d líneas\n  Eliminar:  %d líneas\n\n¿Proceder?",
        lbl_mpvqc_title          = "mpv QC",
        lbl_mpvqc_tolerance      = "Tolerancia (ms):",
        lbl_mpvqc_paste          = "Pega el texto de mpvQC:",
        lbl_remover_title        = "Remover Assistant",
        lbl_remover_text         = "Texto visible",
        lbl_remover_tags         = "Override tags",
        lbl_remover_comments     = "Comentarios",
        chk_rem_n                = "Quitar \\N",
        chk_rem_h                = "Quitar \\h",
        chk_rem_double_space     = "Espacios dobles",
        chk_rem_edge_space       = "Espacios al borde",
        chk_rem_excl             = "Signos de exclamacion",
        chk_rem_quest            = "Signos de interrogacion",
        chk_rem_combo            = "Signos mixtos ¡¿?!",
        chk_rem_final_commas     = "Comas finales",
        chk_rem_all_commas       = "Todas las comas",
        chk_rem_quotes           = "Comillas",
        chk_rem_apostrophes      = "Apostrofos",
        chk_rem_stutter          = "Tartamudeo X-X",
        chk_rem_dup_letters      = "Letras duplicadas",
        chk_rem_leading_ellipsis = "Puntos suspensivos iniciales",
        chk_rem_ellipsis         = "Todos los puntos suspensivos",
        chk_rem_italic_tags      = "Tags \\i",
        chk_rem_q_tags           = "Tags \\q",
        chk_rem_an8              = "\\an8",
        chk_rem_comment_lines    = "Lineas comentadas",
        chk_rem_inline_comments  = "Comentarios inline {...}",
        btn_import               = "Importar",
        btn_replace_all          = "Reemplazar todo",
        btn_apply                = "Aplicar",
        btn_filter               = "Filtrar",
        btn_yes_delete_all       = "Sí, eliminar todo",
        btn_yes_proceed          = "Sí, proceder",
    },
    pt = {
        err_no_active_dialogue   = "Nenhuma linha de diálogo ativa válida encontrada.",
        err_no_sync_point        = "Importar dados — Songs: ponto de sincronia não encontrado.\nNecessário linha Comment com layer 50.",
        err_scxvid_not_found     = "SCXvid não encontrado:\n%s",
        err_ffmpeg_not_found     = "FFmpeg não encontrado:\n%s",
        err_cannot_create_batch  = "Erro: não foi possível criar o arquivo batch temporário",
        err_cannot_create_shell  = "Erro: não foi possível criar o script shell temporário",
        err_no_lines_selected    = "Nenhuma linha selecionada.",
        err_not_inside_fold      = "A linha ativa não está dentro de um fold.\nVá para uma linha dentro de um grupo fold.",
        err_no_fold_group        = "Grupo fold completo não encontrado.",
        err_cannot_write_file    = "Não foi possível gravar em:\n%s",
        err_shift_min_two        = "Shift First requer pelo menos 2 linhas.",
        err_shift_first_two      = "Shift First requer que as duas primeiras linhas selecionadas sejam diálogo.",
        err_no_styles            = "Nenhum estilo encontrado nas linhas selecionadas.",
        err_no_styles_delete     = "Nenhuma linha para apagar. Todas as linhas têm um estilo preservado.",
        err_tolerance_positive   = "A tolerância deve ser um número positivo.",
        err_paste_mpvqc          = "Cole primeiro o texto do mpvQC.",
        err_no_mpvqc_comments    = "Nenhum comentário do mpvQC encontrado.",
        msg_process_started      = "Processo iniciado.\nLog: %s",
        msg_ae_saved             = "Dados AE salvos em:\n%s",
        msg_kite_done            = "Kite Timing: %d alterações em %d linhas selecionadas.",
        msg_replacer_done        = "Text Replacer: %d linhas modificadas.",
        msg_filter_done          = "Apagadas %d linhas, mantidas %d.",
        msg_mpvqc_done           = "mpv QC concluído.\nLinhas modificadas: %d",
        msg_remover_done         = "Remover Assistant concluido.\nLinhas modificadas: %d\nLinhas apagadas: %d",
        err_remover_none         = "Selecione pelo menos uma opcao de limpeza.",
        lbl_include_partial      = "Incluir linhas com sobreposição parcial",
        lbl_paste_dialogue       = "Cole texto ou linhas Dialogue/Comment:",
        lbl_import_as_comments   = "Importar texto puro como comentários {…}",
        lbl_original_text        = "TEXTO ORIGINAL",
        lbl_replacement_text     = "TEXTO DE SUBSTITUIÇÃO",
        lbl_replacer_help        = "Cada linha em Original corresponde à mesma linha em Substituição. Tags são preservados.",
        lbl_styles_filter_help   = "Estilos na seleção.\nRemova os que deseja APAGAR; mantenha o resto.",
        lbl_styles_filter_warn   = "Linhas cujo estilo NÃO estiver na lista serão apagadas.",
        lbl_styles_filter_empty  = "AVISO: a lista está vazia.\nIsto apagará TODAS as linhas selecionadas. Continuar?",
        lbl_styles_filter_sum    = "Resumo:\n  Manter:  %d linhas\n  Apagar:  %d linhas\n\nProsseguir?",
        lbl_mpvqc_title          = "mpv QC",
        lbl_mpvqc_tolerance      = "Tolerância (ms):",
        lbl_mpvqc_paste          = "Cole o texto do mpvQC:",
        lbl_remover_title        = "Remover Assistant",
        lbl_remover_text         = "Texto visivel",
        lbl_remover_tags         = "Override tags",
        lbl_remover_comments     = "Comentarios",
        chk_rem_n                = "Remover \\N",
        chk_rem_h                = "Remover \\h",
        chk_rem_double_space     = "Espacos duplos",
        chk_rem_edge_space       = "Espacos nas bordas",
        chk_rem_excl             = "Sinais de exclamacao",
        chk_rem_quest            = "Sinais de interrogacao",
        chk_rem_combo            = "Sinais mistos ¡¿?!",
        chk_rem_final_commas     = "Virgulas finais",
        chk_rem_all_commas       = "Todas as virgulas",
        chk_rem_quotes           = "Aspas",
        chk_rem_apostrophes      = "Apostrofos",
        chk_rem_stutter          = "Gagueira X-X",
        chk_rem_dup_letters      = "Letras duplicadas",
        chk_rem_leading_ellipsis = "Reticencias iniciais",
        chk_rem_ellipsis         = "Todas as reticencias",
        chk_rem_italic_tags      = "Tags \\i",
        chk_rem_q_tags           = "Tags \\q",
        chk_rem_an8              = "\\an8",
        chk_rem_comment_lines    = "Linhas comentadas",
        chk_rem_inline_comments  = "Comentarios inline {...}",
        btn_import               = "Importar",
        btn_replace_all          = "Substituir tudo",
        btn_apply                = "Aplicar",
        btn_filter               = "Filtrar",
        btn_yes_delete_all       = "Sim, apagar tudo",
        btn_yes_proceed          = "Sim, prosseguir",
    },
}

for code, tbl in pairs(EXTRA_LANG) do
    LANG[code] = LANG[code] or {}
    for k, v in pairs(tbl) do LANG[code][k] = v end
end

for code, tbl in pairs(LOCALE_PATCH) do
    LANG[code] = LANG[code] or {}
    for k, v in pairs(tbl) do LANG[code][k] = v end
end

local EMPHASIS_LANG = {
    en = {
        chk_strong_excl     = "Strong exclamation [STRONG-EXCL]",
        chk_strong_quest    = "Strong question [STRONG-QUEST]",
        chk_mixed_emphasis  = "Mixed emphasis [MIXED-EMPHASIS]",
        chk_semicolon       = "Semicolon [SEMICOLON]",
        chk_stutter         = "Stutter [STUTTER]",
        btn_scream          = "Scream",
        scream_title        = "Scream Detector",
        scream_lbl_avg      = "Average line dB:",
        scream_lbl_sample   = "Strong sample dB:",
        scream_lbl_ratio    = "Strong sample ratio (%):",
        scream_lbl_min      = "Minimum samples:",
        scream_lbl_z        = "Robust z-score:",
        scream_chk_clean    = "Clear previous SCREAM marks",
        scream_chk_reuse    = "Reuse existing analysis log",
        scream_btn_analyze  = "Analyze",
        scream_msg_no_media = "Scream Detector: no audio or video file is loaded.",
        scream_msg_no_folder= "Scream Detector: could not find a folder for the analysis files.",
        scream_msg_no_batch = "Scream Detector: could not create the analysis batch.",
        scream_msg_running  = "Scream Detector: running FFmpeg analysis.\nThis can take a while.",
        scream_msg_no_log   = "Scream Detector: no audio samples found in the log.\nBatch: %s",
        scream_msg_done     = "Scream Detector: marked %d of %d lines.\nSamples: %d\nMedian avg: %.2f dB | MAD: %.2f dB",
        scream_help         = "Scream Detector marks lines whose interval is statistically loud.\n\n"
                              .. "Average line dB: mean power inside each subtitle interval (closer to 0 is stricter).\n"
                              .. "Strong sample dB: samples above this value count as strong evidence.\n"
                              .. "Strong sample ratio: minimum percent of strong samples per interval.\n"
                              .. "Minimum samples: ignore lines with too little audio evidence.\n"
                              .. "Robust z-score: compares each line against median/MAD of the current set.\n"
                              .. "Reuse log skips FFmpeg if the analysis log already exists.",
    },
    es = {
        chk_strong_excl     = "Exclamación fuerte [STRONG-EXCL]",
        chk_strong_quest    = "Interrogación fuerte [STRONG-QUEST]",
        chk_mixed_emphasis  = "Énfasis mixto [MIXED-EMPHASIS]",
        chk_semicolon       = "Punto y coma [SEMICOLON]",
        chk_stutter         = "Tartamudeo [STUTTER]",
        btn_scream          = "Grito",
        scream_title        = "Detector de Gritos",
        scream_lbl_avg      = "Promedio dB:",
        scream_lbl_sample   = "Muestra fuerte dB:",
        scream_lbl_ratio    = "Ratio muestra fuerte (%):",
        scream_lbl_min      = "Muestras mínimas:",
        scream_lbl_z        = "z-score robusto:",
        scream_chk_clean    = "Limpiar marcas SCREAM previas",
        scream_chk_reuse    = "Reutilizar log de análisis existente",
        scream_btn_analyze  = "Analizar",
        scream_msg_no_media = "Scream Detector: no hay audio o vídeo cargado.",
        scream_msg_no_folder= "Scream Detector: no se encontró carpeta para los archivos de análisis.",
        scream_msg_no_batch = "Scream Detector: no se pudo crear el batch de análisis.",
        scream_msg_running  = "Scream Detector: ejecutando análisis de FFmpeg.\nPuede tardar un rato.",
        scream_msg_no_log   = "Scream Detector: no se encontraron muestras en el log.\nBatch: %s",
        scream_msg_done     = "Scream Detector: marcadas %d de %d líneas.\nMuestras: %d\nMediana promedio: %.2f dB | MAD: %.2f dB",
        scream_help         = "Scream Detector marca líneas cuyo intervalo es estadísticamente fuerte.\n\n"
                              .. "Promedio dB: potencia media en el intervalo de cada subtítulo (más cerca de 0 es más estricto).\n"
                              .. "Muestra fuerte dB: muestras por encima de este valor cuentan como evidencia fuerte.\n"
                              .. "Ratio muestra fuerte: porcentaje mínimo de muestras fuertes por intervalo.\n"
                              .. "Muestras mínimas: ignora líneas con muy poca evidencia.\n"
                              .. "z-score robusto: compara cada línea contra mediana/MAD del conjunto actual.\n"
                              .. "Reutilizar log evita correr FFmpeg si ya existe el log de análisis.",
    },
    pt = {
        chk_strong_excl     = "Exclamação forte [STRONG-EXCL]",
        chk_strong_quest    = "Interrogação forte [STRONG-QUEST]",
        chk_mixed_emphasis  = "Ênfase mista [MIXED-EMPHASIS]",
        chk_semicolon       = "Ponto e vírgula [SEMICOLON]",
        chk_stutter         = "Gagueira [STUTTER]",
        btn_scream          = "Grito",
        scream_title        = "Detector de Gritos",
        scream_lbl_avg      = "Média dB:",
        scream_lbl_sample   = "Amostra forte dB:",
        scream_lbl_ratio    = "Razão amostra forte (%):",
        scream_lbl_min      = "Amostras mínimas:",
        scream_lbl_z        = "z-score robusto:",
        scream_chk_clean    = "Limpar marcas SCREAM anteriores",
        scream_chk_reuse    = "Reutilizar log de análise existente",
        scream_btn_analyze  = "Analisar",
        scream_msg_no_media = "Scream Detector: nenhum áudio ou vídeo carregado.",
        scream_msg_no_folder= "Scream Detector: não foi encontrada pasta para os arquivos de análise.",
        scream_msg_no_batch = "Scream Detector: não foi possível criar o batch de análise.",
        scream_msg_running  = "Scream Detector: executando análise do FFmpeg.\nPode demorar.",
        scream_msg_no_log   = "Scream Detector: nenhuma amostra encontrada no log.\nBatch: %s",
        scream_msg_done     = "Scream Detector: marcadas %d de %d linhas.\nAmostras: %d\nMediana média: %.2f dB | MAD: %.2f dB",
        scream_help         = "Scream Detector marca linhas cujo intervalo é estatisticamente forte.\n\n"
                              .. "Média dB: potência média no intervalo de cada legenda (mais perto de 0 é mais estrito).\n"
                              .. "Amostra forte dB: amostras acima deste valor contam como evidência forte.\n"
                              .. "Razão amostra forte: porcentagem mínima de amostras fortes por intervalo.\n"
                              .. "Amostras mínimas: ignora linhas com pouca evidência.\n"
                              .. "z-score robusto: compara cada linha contra mediana/MAD do conjunto atual.\n"
                              .. "Reutilizar log evita rodar FFmpeg se o log de análise já existir.",
    },
}

for code, tbl in pairs(EMPHASIS_LANG) do
    LANG[code] = LANG[code] or {}
    for k, v in pairs(tbl) do LANG[code][k] = v end
end

local function L(key)
    return (LANG[currentLang] and LANG[currentLang][key]) or LANG.en[key] or key
end

local function resolveConfig()
    currentLang = currentConfig.language or currentLang or "en"
end

local function showMsg(msg)
    msg = tostring(msg)
    local lines, maxLen = 0, 0
    for line in (msg .. "\n"):gmatch("(.-)\n") do
        lines = lines + 1
        if #line > maxLen then maxLen = #line end
    end
    if lines > 4 or maxLen > 70 or #msg > 180 then
        local width = math.max(45, math.min(90, math.floor(maxLen / 2) + 8))
        local height = math.max(8, math.min(26, lines + 4))
        aegisub.dialog.display({{class="textbox", text=msg, x=0, y=0, width=width, height=height}}, {L("btn_ok")})
    else
        local width = math.max(30, math.min(70, maxLen + 4))
        local height = math.max(3, math.min(8, lines + 2))
        aegisub.dialog.display({{class="label", label=msg, x=0, y=0, width=width, height=height}}, {L("btn_ok")})
    end
end
local UI = {
    labels = {
        en = {
            ["en"]="English", ["es"]="Spanish", ["pt"]="Portuguese",
            ["All Selected"]="All selected", ["By Style"]="By style", ["By Actor"]="By actor", ["By Effect"]="By effect", ["By Layer"]="By layer",
            ["Ends Only"]="Ends only", ["Start Only"]="Start only", ["Full Audit"]="Full audit", ["Duration"]="Duration", ["CPS"]="CPS", ["Short Gaps"]="Short gaps", ["Large Gaps"]="Large gaps", ["Both Gaps"]="Both gaps", ["Overtime"]="Overtime",
            ["End Only"]="End only", ["Both"]="Both", ["End only"]="End only", ["Start only"]="Start only",
            ["KF Back"]="Back", ["KF Forward"]="Forward", ["KF Both"]="Both",
            ["Import Effects"]="Import effects", ["Import Text"]="Import text", ["Import Actor"]="Import actor", ["Import Tags"]="Import tags", ["Song Sync"]="Song sync",
            ["LazyFusion"]="LazyFusion", ["Cluster (±ms)"]="Cluster (±ms)", ["Table (±ms)"]="Table (±ms)",
            ["Full Timing"]="Full timing", ["Post-Timing"]="Post-timing", ["Raw Timing"]="Raw timing",
            ["LZT Raw (Legacy)"]="LZT raw (legacy)", ["LZT Raw Silences"]="LZT raw silences",
            ["Only changes"]="Only changes", ["Only 0ms"]="Only 0 ms", ["None"]="None",
            ["All"]="All", ["All Default"]="All Default", ["Default+Alt"]="Default + Alt",
            ["Number Effects"]="Number effects", ["Add Identifier"]="Add identifier",
            ["UPPERCASE"]="Uppercase", ["THREE-LINES"]="Three lines", ["NO-END-PUNCT"]="No end punctuation", ["UNPAIRED-PUNCT"]="Unpaired punctuation",
            ["SHORT-LAST-LINE"]="Short last line", ["BROKEN-TAG"]="Broken tag", ["OVERLAP"]="Overlap", ["DEFAULT-STYLE"]="Default style",
            ["ITALIC-ERROR"]="Italic error", ["PARENTHESES"]="Parentheses", ["NAME-PREFIX"]="Name prefix", ["MULTI-SENTENCE"]="Multiple sentences",
            ["TOO-WIDE"]="Too wide", ["TOO-SHORT"]="Too short", ["TOO-LONG"]="Too long", ["TOO-LONG-TIME"]="Too long duration",
            ["FAST-CPS"]="Fast CPS", ["SLOW-CPS"]="Slow CPS", ["SHORT-GAP"]="Short gap", ["LARGE-GAP"]="Large gap", ["END-ON-KF/START-ON-KF"]="On keyframe",
            ["NEAR-END-KF/NEAR-START-KF"]="Near keyframe", ["MISSED-END-KF/MISSED-START-KF"]="Missed keyframe",
            ["LINE-BREAK"]="Line break", ["POSITION-TAG"]="Position tag", ["CLIP-TAG"]="Clip tag", ["FADE-TAG"]="Fade tag",
            ["TRANSFORM-TAG"]="Transform tag", ["KARAOKE-TAG"]="Karaoke tag", ["COMMENT-BLOCK"]="Comment block", ["HAS-DIGITS"]="Digits",
            ["HAS-CJK"]="CJK / kana", ["FULL-ITALIC"]="Full italic", ["DOUBLE-SPACE"]="Double space", ["EDGE-SPACE"]="Edge space",
            ["Toggle \\an8"]="Toggle \\an8", ["Toggle Italics"]="Toggle italics", ["Uppercase"]="Uppercase", ["Lowercase"]="Lowercase",
            ["Title Case"]="Title case", ["Sentence Case"]="Sentence case", ["Capitalize First"]="Capitalize first", ["Lowercase First"]="Lowercase first",
            ["Normalize Ellipsis"]="Normalize ellipsis", ["Add Ellipsis"]="Add ellipsis", ["Erase Leading Ellipsis"]="Erase leading ellipsis",
            ["Unify Quotes"]="Unify quotes", ["Normalize Dashes"]="Normalize dashes", ["Trim Trailing Spaces"]="Trim trailing spaces",
            ["Remove Duplicate Letters"]="Remove duplicate letters", ["Stutter Manager"]="Stutter manager", ["Extract Tags"]="Extract tags",
            ["Reinsert Tags"]="Reinsert tags", ["Remove Tags"]="Remove tags", ["Remove Comments"]="Remove comments", ["Actor Parser"]="Actor parser",
            ["Swap Comment"]="Swap comment", ["Delete Comment Lines"]="Delete comment lines", ["Comments to Top"]="Comments to top",
            ["Comments to Bottom"]="Comments to bottom", ["Effects to Top"]="Effects to top", ["Fold by Identifier"]="Fold by identifier", ["Add Stutter"]="Add stutter",
            ["Add Ah Prefix"]="Add Ah prefix", ["Bidirectional Snapping"]="Bidirectional snapping", ["Start Snap Back"]="Start snap back", ["Start Snap Forward"]="Start snap forward", ["End Snap Back"]="End snap back", ["End Snap Forward"]="End snap forward", ["Remove Honorifics"]="Remove honorifics",
            ["Caption Clarifier"]="Caption clarifier", ["Complete Sentences"]="Complete sentences", ["Erase Blank Lines"]="Erase blank lines", ["Remove \\N"]="Remove \\N",
            ["Frame Effect"]="Frame effect", ["Copy Fold"]="Copy fold", ["Smart Break"]="Smart break", ["Split by Sentence"]="Split by sentence",
            ["Split by Comma"]="Split by comma", ["Join Lines"]="Join lines", ["Join Same Text"]="Join same text", ["Join Overlaps"]="Join overlaps", ["Divide by \\N"]="Divide by \\N",
            ["Copy Times"]="Copy times", ["Time Picker"]="Time picker", ["Sort by Length"]="Sort by length", ["Sort by CPS"]="Sort by CPS",
            ["Sort Odd Even"]="Sort odd/even", ["Count CPS"]="Count CPS", ["Import Text"]="Import text", ["Kite Timing"]="Kite timing",
            ["Add Lead-In Left"]="Add lead-in left", ["Add Lead-In Right"]="Add lead-in right", ["Add Lead-Out Left"]="Add lead-out left", ["Add Lead-Out Right"]="Add lead-out right", ["Chain Left"]="Chain left", ["Chain Right"]="Chain right",
            ["Shift First"]="Shift first", ["Romaji Karaoker (Word → \\k)"]="Romaji karaoker (word → \\k)",
            ["AE Export"]="AE export", ["Text Replacer"]="Text replacer", ["mpv QC"]="mpv QC", ["Style Filter"]="Style filter",
        },
        es = {
            ["en"]="Inglés", ["es"]="Español", ["pt"]="Portugués",
            ["All Selected"]="Toda la selección", ["By Style"]="Por estilo", ["By Actor"]="Por actor", ["By Effect"]="Por Effect", ["By Layer"]="Por capa",
            ["Ends Only"]="Solo finales", ["Start Only"]="Solo inicios", ["Full Audit"]="Auditoría completa", ["Duration"]="Duración", ["CPS"]="CPS", ["Short Gaps"]="Gaps cortos", ["Large Gaps"]="Gaps largos", ["Both Gaps"]="Ambos gaps", ["Overtime"]="Sobretiempo",
            ["End Only"]="Solo final", ["Both"]="Ambos", ["End only"]="Solo final", ["Start only"]="Solo inicio",
            ["KF Back"]="Atrás", ["KF Forward"]="Adelante", ["KF Both"]="Ambos",
            ["Import Effects"]="Importar Effects", ["Import Text"]="Importar texto", ["Import Actor"]="Importar actor", ["Import Tags"]="Importar tags", ["Song Sync"]="Sincronía de canción",
            ["LazyFusion"]="LazyFusion", ["Cluster (±ms)"]="Clúster (±ms)", ["Table (±ms)"]="Tabla (±ms)",
            ["Full Timing"]="Timing Completo", ["Post-Timing"]="Post-Timing", ["Raw Timing"]="Timing Bruto",
            ["LZT Raw (Legacy)"]="LZT Bruto (Legacy)", ["LZT Raw Silences"]="LZT Bruto Silencios",
            ["Only changes"]="Solo cambios", ["Only 0ms"]="Solo 0 ms", ["None"]="Ninguno",
            ["All"]="Todo", ["All Default"]="Todo Default", ["Default+Alt"]="Default + Alt",
            ["Number Effects"]="Numerar Effects", ["Add Identifier"]="Añadir identificador",
            ["UPPERCASE"]="Mayúsculas", ["THREE-LINES"]="Tres líneas", ["NO-END-PUNCT"]="Sin puntuación final", ["UNPAIRED-PUNCT"]="Puntuación sin pareja",
            ["SHORT-LAST-LINE"]="Última línea corta", ["BROKEN-TAG"]="Tag roto", ["OVERLAP"]="Solapamiento", ["DEFAULT-STYLE"]="Estilo Default",
            ["ITALIC-ERROR"]="Error de cursiva", ["PARENTHESES"]="Paréntesis", ["NAME-PREFIX"]="Prefijo de nombre", ["MULTI-SENTENCE"]="Varias oraciones",
            ["TOO-WIDE"]="Demasiado ancho", ["TOO-SHORT"]="Muy corta", ["TOO-LONG"]="Muy larga", ["TOO-LONG-TIME"]="Duración excesiva",
            ["FAST-CPS"]="CPS alto", ["SLOW-CPS"]="CPS bajo", ["SHORT-GAP"]="Gap corto", ["LARGE-GAP"]="Gap largo", ["END-ON-KF/START-ON-KF"]="En keyframe",
            ["NEAR-END-KF/NEAR-START-KF"]="Cerca de keyframe", ["MISSED-END-KF/MISSED-START-KF"]="Keyframe omitido",
            ["LINE-BREAK"]="Salto de línea", ["POSITION-TAG"]="Tag de posición", ["CLIP-TAG"]="Tag de clip", ["FADE-TAG"]="Tag de fade",
            ["TRANSFORM-TAG"]="Tag de transformación", ["KARAOKE-TAG"]="Tag de karaoke", ["COMMENT-BLOCK"]="Bloque de comentario", ["HAS-DIGITS"]="Dígitos",
            ["HAS-CJK"]="CJK / kana", ["FULL-ITALIC"]="Toda en cursiva", ["DOUBLE-SPACE"]="Doble espacio", ["EDGE-SPACE"]="Espacio al borde",
            ["Toggle \\an8"]="Alternar \\an8", ["Toggle Italics"]="Alternar cursiva", ["Uppercase"]="Mayúsculas", ["Lowercase"]="Minúsculas",
            ["Title Case"]="Tipo título", ["Sentence Case"]="Tipo oración", ["Capitalize First"]="Primera mayúscula", ["Lowercase First"]="Primera minúscula",
            ["Normalize Ellipsis"]="Normalizar elipsis", ["Add Ellipsis"]="Añadir elipsis", ["Erase Leading Ellipsis"]="Borrar elipsis inicial",
            ["Unify Quotes"]="Unificar comillas", ["Normalize Dashes"]="Normalizar guiones", ["Trim Trailing Spaces"]="Quitar espacios finales",
            ["Remove Duplicate Letters"]="Quitar letras repetidas", ["Stutter Manager"]="Gestor de tartamudeo", ["Extract Tags"]="Extraer tags",
            ["Reinsert Tags"]="Reinsertar tags", ["Remove Tags"]="Quitar tags", ["Remove Comments"]="Quitar comentarios", ["Actor Parser"]="Parsear actor",
            ["Swap Comment"]="Intercambiar comentario", ["Delete Comment Lines"]="Borrar líneas comentadas", ["Comments to Top"]="Comentarios arriba",
            ["Comments to Bottom"]="Comentarios abajo", ["Effects to Top"]="Con Effect arriba", ["Fold by Identifier"]="Fold por identificador", ["Add Stutter"]="Añadir tartamudeo",
            ["Add Ah Prefix"]="Añadir Ah inicial", ["Bidirectional Snapping"]="Snap bidireccional", ["Start Snap Back"]="Inicio a KF previo", ["Start Snap Forward"]="Inicio a KF siguiente", ["End Snap Back"]="Final a KF previo", ["End Snap Forward"]="Final a KF siguiente", ["Remove Honorifics"]="Comentar honoríficos",
            ["Caption Clarifier"]="Limpiar acotaciones", ["Complete Sentences"]="Completar oraciones", ["Erase Blank Lines"]="Borrar líneas vacías", ["Remove \\N"]="Quitar \\N",
            ["Frame Effect"]="Frame en Effect", ["Copy Fold"]="Copiar fold", ["Smart Break"]="Salto inteligente", ["Split by Sentence"]="Dividir por oración",
            ["Split by Comma"]="Dividir por coma", ["Join Lines"]="Unir líneas", ["Join Same Text"]="Unir texto igual", ["Join Overlaps"]="Unir solapes", ["Divide by \\N"]="Dividir por \\N",
            ["Copy Times"]="Copiar tiempos", ["Time Picker"]="Selector de tiempo", ["Sort by Length"]="Ordenar por longitud", ["Sort by CPS"]="Ordenar por CPS",
            ["Sort Odd Even"]="Ordenar impar/par", ["Count CPS"]="Contar CPS", ["Import Text"]="Importar texto", ["Kite Timing"]="Kite timing",
            ["Add Lead-In Left"]="Lead-in izquierda", ["Add Lead-In Right"]="Lead-in derecha", ["Add Lead-Out Left"]="Lead-out izquierda", ["Add Lead-Out Right"]="Lead-out derecha", ["Chain Left"]="Encadenar izquierda", ["Chain Right"]="Encadenar derecha",
            ["Shift First"]="Desplazar desde primera", ["Romaji Karaoker (Word → \\k)"]="Karaoke romaji (palabra → \\k)",
            ["AE Export"]="Exportar AE", ["Text Replacer"]="Reemplazar texto", ["mpv QC"]="mpv QC", ["Style Filter"]="Filtro de estilo",
        },
        pt = {
            ["en"]="Inglês", ["es"]="Espanhol", ["pt"]="Português",
            ["All Selected"]="Toda a seleção", ["By Style"]="Por estilo", ["By Actor"]="Por ator", ["By Effect"]="Por Effect", ["By Layer"]="Por camada",
            ["Ends Only"]="Só finais", ["Start Only"]="Só inícios", ["Full Audit"]="Auditoria completa", ["Duration"]="Duração", ["CPS"]="CPS", ["Short Gaps"]="Gaps curtos", ["Large Gaps"]="Gaps longos", ["Both Gaps"]="Ambos gaps", ["Overtime"]="Sobretempo",
            ["End Only"]="Só final", ["Both"]="Ambos", ["End only"]="Só final", ["Start only"]="Só início",
            ["KF Back"]="Para trás", ["KF Forward"]="Para frente", ["KF Both"]="Ambos",
            ["Import Effects"]="Importar Effects", ["Import Text"]="Importar texto", ["Import Actor"]="Importar ator", ["Import Tags"]="Importar tags", ["Song Sync"]="Sincronia da música",
            ["LazyFusion"]="LazyFusion", ["Cluster (±ms)"]="Cluster (±ms)", ["Table (±ms)"]="Tabela (±ms)",
            ["Full Timing"]="Timing Completo", ["Post-Timing"]="Pós-Timing", ["Raw Timing"]="Timing Bruto",
            ["LZT Raw (Legacy)"]="LZT Bruto (Legacy)", ["LZT Raw Silences"]="LZT Bruto Silêncios",
            ["Only changes"]="Só mudanças", ["Only 0ms"]="Só 0 ms", ["None"]="Nenhum",
            ["All"]="Tudo", ["All Default"]="Tudo Default", ["Default+Alt"]="Default + Alt",
            ["Number Effects"]="Numerar Effects", ["Add Identifier"]="Adicionar identificador",
            ["UPPERCASE"]="Maiúsculas", ["THREE-LINES"]="Três linhas", ["NO-END-PUNCT"]="Sem pontuação final", ["UNPAIRED-PUNCT"]="Pontuação sem par",
            ["SHORT-LAST-LINE"]="Última linha curta", ["BROKEN-TAG"]="Tag quebrada", ["OVERLAP"]="Sobreposição", ["DEFAULT-STYLE"]="Estilo Default",
            ["ITALIC-ERROR"]="Erro de itálico", ["PARENTHESES"]="Parênteses", ["NAME-PREFIX"]="Prefixo de nome", ["MULTI-SENTENCE"]="Várias frases",
            ["TOO-WIDE"]="Larga demais", ["TOO-SHORT"]="Curta demais", ["TOO-LONG"]="Longa demais", ["TOO-LONG-TIME"]="Duração excessiva",
            ["FAST-CPS"]="CPS alto", ["SLOW-CPS"]="CPS baixo", ["SHORT-GAP"]="Gap curto", ["LARGE-GAP"]="Gap longo", ["END-ON-KF/START-ON-KF"]="Em keyframe",
            ["NEAR-END-KF/NEAR-START-KF"]="Perto de keyframe", ["MISSED-END-KF/MISSED-START-KF"]="Keyframe perdido",
            ["LINE-BREAK"]="Quebra de linha", ["POSITION-TAG"]="Tag de posição", ["CLIP-TAG"]="Tag de clip", ["FADE-TAG"]="Tag de fade",
            ["TRANSFORM-TAG"]="Tag de transformação", ["KARAOKE-TAG"]="Tag de karaokê", ["COMMENT-BLOCK"]="Bloco de comentário", ["HAS-DIGITS"]="Dígitos",
            ["HAS-CJK"]="CJK / kana", ["FULL-ITALIC"]="Toda em itálico", ["DOUBLE-SPACE"]="Espaço duplo", ["EDGE-SPACE"]="Espaço nas bordas",
            ["Toggle \\an8"]="Alternar \\an8", ["Toggle Italics"]="Alternar itálico", ["Uppercase"]="Maiúsculas", ["Lowercase"]="Minúsculas",
            ["Title Case"]="Tipo título", ["Sentence Case"]="Tipo frase", ["Capitalize First"]="Primeira maiúscula", ["Lowercase First"]="Primeira minúscula",
            ["Normalize Ellipsis"]="Normalizar reticências", ["Add Ellipsis"]="Adicionar reticências", ["Erase Leading Ellipsis"]="Apagar reticências iniciais",
            ["Unify Quotes"]="Unificar aspas", ["Normalize Dashes"]="Normalizar travessões", ["Trim Trailing Spaces"]="Remover espaços finais",
            ["Remove Duplicate Letters"]="Remover letras repetidas", ["Stutter Manager"]="Gestor de gaguejo", ["Extract Tags"]="Extrair tags",
            ["Reinsert Tags"]="Reinserir tags", ["Remove Tags"]="Remover tags", ["Remove Comments"]="Remover comentários", ["Actor Parser"]="Processar ator",
            ["Swap Comment"]="Trocar comentário", ["Delete Comment Lines"]="Apagar linhas comentadas", ["Comments to Top"]="Comentários acima",
            ["Comments to Bottom"]="Comentários abaixo", ["Effects to Top"]="Com Effect acima", ["Fold by Identifier"]="Fold por identificador", ["Add Stutter"]="Adicionar gaguejo",
            ["Add Ah Prefix"]="Adicionar Ah inicial", ["Bidirectional Snapping"]="Snap bidirecional", ["Start Snap Back"]="Inicio ao KF anterior", ["Start Snap Forward"]="Inicio ao KF seguinte", ["End Snap Back"]="Fim ao KF anterior", ["End Snap Forward"]="Fim ao KF seguinte", ["Remove Honorifics"]="Comentar honoríficos",
            ["Caption Clarifier"]="Limpar indicações", ["Complete Sentences"]="Completar frases", ["Erase Blank Lines"]="Apagar linhas vazias", ["Remove \\N"]="Remover \\N",
            ["Frame Effect"]="Frame em Effect", ["Copy Fold"]="Copiar fold", ["Smart Break"]="Quebra inteligente", ["Split by Sentence"]="Dividir por frase",
            ["Split by Comma"]="Dividir por vírgula", ["Join Lines"]="Unir linhas", ["Join Same Text"]="Unir texto igual", ["Join Overlaps"]="Unir sobreposições", ["Divide by \\N"]="Dividir por \\N",
            ["Copy Times"]="Copiar tempos", ["Time Picker"]="Seletor de tempo", ["Sort by Length"]="Ordenar por tamanho", ["Sort by CPS"]="Ordenar por CPS",
            ["Sort Odd Even"]="Ordenar ímpar/par", ["Count CPS"]="Contar CPS", ["Import Text"]="Importar texto", ["Kite Timing"]="Kite timing",
            ["Add Lead-In Left"]="Lead-in esquerda", ["Add Lead-In Right"]="Lead-in direita", ["Add Lead-Out Left"]="Lead-out esquerda", ["Add Lead-Out Right"]="Lead-out direita", ["Chain Left"]="Encadear esquerda", ["Chain Right"]="Encadear direita",
            ["Shift First"]="Deslocar desde primeira", ["Romaji Karaoker (Word → \\k)"]="Karaokê romaji (palavra → \\k)",
            ["AE Export"]="Exportar AE", ["Text Replacer"]="Substituir texto", ["mpv QC"]="mpv QC", ["Style Filter"]="Filtro de estilo",
        },
    },
}
UI.labels.en["FINAL-COMMA"] = "Final comma"
UI.labels.es["FINAL-COMMA"] = "Final con coma"
UI.labels.pt["FINAL-COMMA"] = "Final com virgula"
UI.labels.en["Pivot \\N"] = "Pivot \\N"
UI.labels.es["Pivot \\N"] = "Pivotear \\N"
UI.labels.pt["Pivot \\N"] = "Pivotar \\N"
UI.labels.en["STRONG-EXCL"]     = "Strong exclamation"
UI.labels.es["STRONG-EXCL"]     = "Exclamación fuerte"
UI.labels.pt["STRONG-EXCL"]     = "Exclamação forte"
UI.labels.en["STRONG-QUEST"]    = "Strong question"
UI.labels.es["STRONG-QUEST"]    = "Interrogación fuerte"
UI.labels.pt["STRONG-QUEST"]    = "Interrogação forte"
UI.labels.en["MIXED-EMPHASIS"]  = "Mixed emphasis"
UI.labels.es["MIXED-EMPHASIS"]  = "Énfasis mixto"
UI.labels.pt["MIXED-EMPHASIS"]  = "Ênfase mista"
UI.labels.en["SEMICOLON"]       = "Semicolon"
UI.labels.es["SEMICOLON"]       = "Punto y coma"
UI.labels.pt["SEMICOLON"]       = "Ponto e vírgula"
UI.labels.en["STUTTER"]         = "Stutter"
UI.labels.es["STUTTER"]         = "Tartamudeo"
UI.labels.pt["STUTTER"]         = "Gagueira"
UI.labels.en["SCREAM"]          = "Scream"
UI.labels.es["SCREAM"]          = "Grito"
UI.labels.pt["SCREAM"]          = "Grito"
UI.labels.en["All dialogue"]    = "All dialogue"
UI.labels.es["All dialogue"]    = "Todo el diálogo"
UI.labels.pt["All dialogue"]    = "Todo o diálogo"
UI.labels.en["Selected lines"]  = "Selected lines"
UI.labels.es["Selected lines"]  = "Líneas seleccionadas"
UI.labels.pt["Selected lines"]  = "Linhas selecionadas"
function UI.text(key)
    return (UI.labels[currentLang] and UI.labels[currentLang][key]) or (UI.labels.en and UI.labels.en[key]) or key
end
function UI.options(values, current)
    local data = { items = {}, map = {}, value = "" }
    local n = 0
    for _, key in ipairs(values) do
        local shown = ""
        if key ~= "" then n = n + 1; shown = tostring(n) .. ". " .. UI.text(key) end
        data.items[#data.items+1] = shown
        data.map[shown] = key
        if key == current then data.value = shown end
    end
    return data
end
function UI.utilityOptions(section, current)
    local values = {}
    for _, it in ipairs(section.items) do values[#values+1] = it.name or "" end
    return UI.options(values, current)
end
function UI.from(data, shown)
    if not data then return shown end
    return data.map[shown] ~= nil and data.map[shown] or shown
end
local SUITE_HELP = {
    en = [[
CHRONO SUITE · USER GUIDE
__________________________

A suite of timing, audit, cleanup, import, and editing utilities for
Aegisub. The interface consists of a main panel and auxiliary dialogs
(Cue Timer, Extract KF, Data Import, Config, and Help). The main
panel operates on the current selection and is split into two columns:
Audit Markers (left) and Utility Tools (right), with Data Import and
Extra Tools at the bottom. Most audit results are written to the Effect
field.


1. MAIN PANEL
_____________

The panel is organized around the current selection. Actions are
triggered by pressing EXECUTE. The Cue Timer, Extract KF, Config,
and Help buttons open their dialogs directly. Cue Timer respects the
Apply to / Filter pair.

   1.1. Apply to: defines the subset on which the panel sections act.
   1.2. Filter: text or numeric value paired with Apply to.
   1.3. Audit Markers: presets, thresholds, keyframe mode, and Single
        Marker.
   1.4. Utility Tools: seven independent sections (Case, Punct/Text,
        Tags/Comments, Smart, Split/Join, Time/Sort, and Karaoke).
   1.5. Data Import: import data from text pasted into the box.
   1.6. Extra Tools: five independent tools.

An empty dropdown skips its section during execution.


2. APPLY TO / FILTER
____________________

   2.1. All Selected: uses the selection as it is.
   2.2. By Style: keeps lines whose style matches Filter.
   2.3. By Actor: keeps lines whose actor matches Filter.
   2.4. By Effect: keeps lines whose Effect contains the filter text
        (partial match).
   2.5. By Layer: keeps lines whose Layer equals the number written in
        Filter.


3. AUDIT PRESETS
________________

Each preset applies the thresholds defined in Config → Audit Presets
and writes its markers to the Effect field.

   3.1. Ends Only: checks line end times against nearby keyframes.
        Writes only Miss KF and Twin KF markers.
   3.2. Start Only: equivalent check applied to line start times.
   3.3. Full Audit: general check covering text, layout, timing, CPS,
        gaps, and structure.
   3.4. Duration: checks each line against the Short and Long
        thresholds.
   3.5. CPS: checks reading speed against the configured maximum.
   3.6. Short Gaps: checks line-to-line gaps against the Short gap
        threshold.
   3.7. Large Gaps: checks line-to-line gaps against the Large gap
        threshold.
   3.8. Both Gaps: runs both gap checks. Markers are written on both
        adjacent lines and include the detected millisecond value.
   3.9. Overtime: marks lines that exceed the configured maximum
        duration.


4. AUDIT NUMERIC FIELDS
_______________________

   4.1. Short (ms) / Long (ms): minimum and maximum duration
        thresholds.
   4.2. Twin KF (ms): distance for identifying two lines touching the
        same keyframe.
   4.3. Miss KF (ms): distance for identifying a missed keyframe.
   4.4. Overtime (ms): threshold exclusive to the Overtime preset.
   4.5. Min CPS / Max CPS: reading speed range.
   4.6. Short gap (ms) / Large gap (ms): line-to-line gap thresholds.
   4.7. Max Width (px): visual line width used as a review criterion.


5. KEYFRAME MODE AND DIRECTION
______________________________

   5.1. KF Mode: selects which edge is checked against keyframes:
        Start Only, End Only, or Both.
   5.2. KF Dir: search direction for Near/Missed keyframes: Back,
        Forward, or Both. An empty value defaults to Back.
   5.3. Keyframe Seal: independent option that writes START-ON-KF or
        END-ON-KF when an edge lands on a keyframe.
   5.4. Mark continuous (0 ms): includes zero-millisecond gaps in the
        check.
   5.5. Ignore gap on KF: skips gaps whose edge lands on a keyframe.
   5.6. Clear previous markers: removes existing markers before
        writing new ones.


6. SINGLE MARKER
________________

Overrides the chosen preset and runs a single check. The matching tag
is written to the Effect field.

   6.1. Numbering and identification
        - Number Effects: sequential numbering (1, 2, 3...).
        - Add Identifier: 14-digit unique identifier per line.

   6.2. Text and punctuation
        - UPPERCASE: entire line in uppercase.
        - THREE-LINES: line displayed across three rows.
        - NO-END-PUNCT: line without ending punctuation.
        - FINAL-COMMA: line ending with a comma.
        - UNPAIRED-PUNCT: punctuation marks without a counterpart.
        - STRONG-EXCL: visible exclamation sign ("¡", "!" or fullwidth
          variant).
        - STRONG-QUEST: word containing both opening "¿" and closing
          "?".
        - MIXED-EMPHASIS: word combining two openings (¡¿) or two
          closings (?!).
        - SEMICOLON: line containing ";".
        - STUTTER: word containing the X-X pattern (same letter
          repeated with a hyphen).

   6.3. Layout and structure
        - SHORT-LAST-LINE: visually short last line.
        - BROKEN-TAG: empty or malformed override block.
        - OVERLAP: overlap with another line.
        - DEFAULT-STYLE: line using the Default style.
        - ITALIC-ERROR: inconsistency in italics usage.
        - PARENTHESES: parentheses without a counterpart.
        - NAME-PREFIX: detected speaker-name prefix.
        - MULTI-SENTENCE: more than one sentence in a single line.

   6.4. Override tag presence
        - LINE-BREAK, POSITION-TAG, CLIP-TAG, FADE-TAG, TRANSFORM-TAG,
          KARAOKE-TAG.

   6.5. Cleanup and content
        - COMMENT-BLOCK: comment block embedded in the text.
        - HAS-DIGITS: digits present.
        - HAS-CJK: CJK characters or kana.
        - FULL-ITALIC: entire line in italics.
        - DOUBLE-SPACE: double spaces in the text.
        - EDGE-SPACE: spaces at the start or end of the line.


7. UTILITY TOOLS
________________

Each section offers an independent dropdown. An empty value skips that
section during execution.

7.1. CASE
    - Toggle \an8: toggles the top alignment \an8.
    - Toggle Italics: toggles italics.
    - Uppercase: converts the entire text to uppercase.
    - Lowercase: converts the entire text to lowercase.
    - Title Case: capitalizes each word.
    - Sentence Case: capitalizes the first word of each sentence.
    - Capitalize First: capitalizes the first visible character.
    - Lowercase First: converts the first visible character to
      lowercase.

7.2. PUNCT / TEXT
    - Toggle ¡!: toggles the opening exclamation mark.
    - Toggle ¿?: toggles the opening question mark.
    - Toggle ¡¿?!: toggles both opening signs.
    - Normalize Ellipsis: standardizes ellipsis characters.
    - Add Ellipsis: appends an ellipsis at the end of the line.
    - Erase Leading Ellipsis: removes an ellipsis at the start of the
      line.
    - Unify Quotes: standardizes quotation marks.
    - Latin Quotes («»): converts quotes to Latin guillemets.
    - Normalize Dashes: standardizes hyphens, en-dashes, and em-dashes.
    - Trim Trailing Spaces: removes trailing spaces.
    - Remove Duplicate Letters: removes consecutive duplicate letters.
    - Add Stutter: inserts stutter formatting in the text.
    - Add Ah Prefix: inserts an "ah" prefix at the start of the
      dialogue.
    - Stutter Manager: interactive dialog for stutter management.

7.3. TAGS / COMMENTS
    - Fold by Identifier: groups lines sharing the same identifier into
      folds. A fold is created only when the group contains two or more
      lines.
    - Extract Tags: moves override tags from the text into the Effect
      field.
    - Reinsert Tags: returns override tags from Effect to the text and
      converts semicolons to commas inside override blocks.
    - Remove Tags: deletes override blocks from the visible dialogue.
    - Remove Comments: deletes comment blocks within the text.
    - Actor Parser: extracts actor information from the text.
    - Swap Comment: toggles the comment state of the line.
    - Delete Comment Lines: deletes lines flagged as comments.
    - Comments to Top: reorders comments to the top of the selection.
    - Comments to Bottom: reorders comments to the bottom of the
      selection.
    - Effects to Top: moves lines with a non-empty Effect to the top of
      the selection while preserving their relative order.

7.4. SMART
    - Bidirectional Snapping: snaps both start and end to the nearest
      keyframe within the configured frame range.
    - Remove Honorifics: wraps Japanese honorifics in {…} comment
      blocks so they stay in the source but disappear from the visual
      render.
    - Caption Clarifier: standardizes caption brackets and indications.
    - Complete Sentences: joins an incomplete line with the next line
      when the next text starts lowercase. Overlaps or non-lowercase
      continuations are marked as [POSSIBLE-JOIN] instead.
    - Erase Blank Lines: deletes blank lines.
    - Frame Effect: writes the start-frame number into Effect.
    - Copy Fold: duplicates the contents of the fold containing the
      active line.

7.5. SPLIT / JOIN
    - Smart Break: inserts a \N line break at the optimal position
      only when the rendered text exceeds the available width.
    - Split by Sentence: splits the line by sentence.
    - Split by Comma: splits the line by comma.
    - Pivot \N: shifts the \N break within the line.
    - Remove \N: removes every \N from the line, collapsing whitespace.
    - Join Lines: joins consecutive selected lines.
    - Join Same Text: joins adjacent lines with identical text.
    - Join Overlaps: joins selected groups whose times overlap,
      expands the kept line to the group bounds, and preserves each
      source text separated by \N.
    - Divide by \N: splits the line on every existing \N break.

7.6. TIME / SORT
    - Copy Times: copies timing from one line to others.
    - Time Picker: selects lines within a time range.
    - Sort by Length: sorts the lines by visible length.
    - Sort by CPS: sorts the lines by reading speed.
    - Sort Odd Even: sorts by the numeric value of the Effect field
      (odd and even).
    - Count CPS: shows the average CPS across the selection.
    - Import Text: imports text from an external source for controlled
      replacement.
    - Kite Timing: applies the Kite Timing algorithm (adaptive lead-in
      and lead-out, chaining, and edge protection) using the values
      from Config.
    - Shift First: shifts the selection so the first line aligns with
      the start of the second.
    - Start Snap Back: snaps the start to the previous keyframe.
    - Start Snap Forward: snaps the start to the next keyframe.
    - End Snap Back: snaps the end to the previous keyframe.
    - End Snap Forward: snaps the end to the next keyframe.
    - Add Lead-In Left: moves the start back by the configured step
      (Config → Lead-In / Lead-Out). A neighbour chained at gap 0
      moves its end along to keep the chain; with a positive gap the
      start only advances until it touches the neighbour, never
      overlapping it.
    - Add Lead-In Right: moves the start forward by the configured
      step. A neighbour chained at gap 0 moves its end along to keep
      the chain.
    - Add Lead-Out Left: moves the end back by the configured step.
      A chained next line moves its start along to keep the chain.
    - Add Lead-Out Right: moves the end forward by the configured
      step, pushing the start of a chained next line.
    - Chain Left: extends the start back to the previous line's end
      (creates gap 0), within the configured max distance.
    - Chain Right: extends the end to the next line's start (creates
      gap 0), within the configured max distance.

7.7. KARAOKE
    - Romaji Karaoker (Word → \k): generates word-level romaji karaoke
      with {\k} tags.


8. DATA IMPORT
______________

The import source is the text pasted into the Data Import box. An
empty box skips this section.

   8.1. Import Effects: copies the source Effect by time overlap.
   8.2. Import Text: copies visible text by time overlap.
   8.3. Import Actor: copies actor by best time overlap.
   8.4. Import Tags: copies initial override tags from overlapping
        source lines. Imported tags override matching initial tags in
        the target line; inline tags after visible text are ignored.
   8.5. Song Sync: duplicates or synchronizes groups using a Comment
        line on layer 50 as the sync anchor.
   8.6. Same Layers: when checked, Import Effects, Import Text,
        Import Actor, and Import Tags only match source lines whose
        layer equals the target line layer.
   8.7. Import as comments: wraps the imported text inside {…} comment
        blocks.


9. EXTRA TOOLS
______________

   9.1. AE Export: exports motion data compatible with After Effects.
   9.2. Text Replacer: replaces visible text while preserving override
        tags.
   9.3. mpv QC: reads notes exported from mpvQC in the format
        [hh:mm:ss.ms] [Type] Observation {suggested text}. The
        observation is written as [QC: …] in Effect and the suggestion
        is inserted as a comment block in the dialogue. Tolerance is
        defined in milliseconds.
   9.4. Remover Assistant: removes selected visible signs, spacing
        tokens, comments, and known override tags without toggling them
        back on when absent.
   9.5. Style Filter: filters or deletes lines by style with a
        confirmation dialog.


10. CUE TIMER
_____________

Auto-timing dialog that detects spoken intervals from silence, VAD,
flux, envelope, and keyframe data. Numeric parameters are stored in
the main Chrono Suite configuration.

   10.1. Modes:
         - Full Timing: voice match, then padding, chaining, and
           keyframe snapping.
         - Post-Timing: padding, chaining, and keyframe snapping for
           lines already sitting on the voice.
         - Raw Timing: moves lines to the detected voice start/end
           only, with no padding.
         - LZT Raw (Legacy): applies the method selected in Config.
         - LZT Raw Silences: uses only the silence files, without flux
           or VAD.
   10.2. When Auto-search on open is enabled, data files are detected
         in the subtitle folder using the ProcesarLote.bat naming
         (NN_Retimes_30/40/50.txt,
         NN_Retimes_vad.tsv, NN_Retimes_flux.tsv, NN_envelope.tsv,
         NN_keyframes.log) plus generic names (sil30, vad, flux, rms,
         keyframes). Paths can be edited or picked with Browse...
         (multi-select; each file is assigned to its slot by name).
         Turn Auto-search off to keep the path boxes untouched when
         the dialog opens.
   10.3. Multi-chapter by layer: data files are grouped by their
         leading chapter number and every line is processed with the
         files of the chapter equal to its layer (layer 1 → files of
         chapter 1). Keyframes come from each chapter's keyframe log;
         layers without files are reported and skipped.
   10.4. Style filter: All, All Default, Default+Alt, or an exact
         style, plus a second exact style in the extra box.
   10.5. Problem lines are marked in Effect with [TM-...] markers
         (Full, Post, and Raw Timing) or [LZ ...] tags (LZT modes).
         Both are cleaned automatically on the next run.


11. CUE TIMER: LZT MODES
________________________

These modes snap lines to silence intervals and refine them with flux
or VAD evidence according to the method chosen in Config.

   11.1. Method (Config): LazyFusion (silences + flux refinement),
         Cluster (±ms) (silence-edge candidates scored with optional
         flux/VAD evidence), and Table (±ms) (silences only; one
         file, preferring -40 dB; the noise_table CSV is optional).
         The LZT modes also respect the style filter and the
         sign/karaoke skip.
   11.2. Limit (ms): maximum adjustment distance (Cluster/Table).
   11.3. Application: start, end, or both.
   11.4. Timing tag writing:
         - Mode: Both, Only changes, Only 0ms, None.
         - Scope: Both, Start only, End only.
   11.5. LZT Raw Silences ignores the method and runs the silence
         interval engine alone.


12. EXTRACT KF
______________

Generates a keyframe log through SCXvid, with FFmpeg used for
decoding. The SCXvid path, FFmpeg path, and log suffix are configured
in Config → SCXvid.


13. SCREAM DETECTOR
___________________

Audio-driven QA tool. Runs FFmpeg astats on the loaded audio/video and
writes the [SCREAM] marker to lines whose interval is statistically
loud relative to the rest of the analysed set.

   13.1. Average line dB: mean power inside each subtitle interval.
         Closer to 0 is stricter.
   13.2. Strong sample dB: samples above this value count as strong
         evidence.
   13.3. Strong sample ratio (%): minimum percent of strong samples
         per interval.
   13.4. Minimum samples: ignores lines with too little audio
         evidence.
   13.5. Robust z-score: compares each line against the median/MAD of
         the analysed set.
   13.6. Apply to: All dialogue or Selected lines only.
   13.7. Clear previous SCREAM marks: removes earlier [SCREAM] in
         scope before writing new ones.
   13.8. Reuse existing analysis log: skips FFmpeg if a previous log
         exists. Useful for recalibration.


14. CONFIG
__________

Global configuration persisted between sessions.

   14.1. Language: en, es, pt.
   14.2. Cue Timer (LZT modes): method, limit, application at start
         and end, timing-tag writing, mode and scope, and the
         optional noise_table CSV.
   14.3. SCXvid: SCXvid path, FFmpeg path, and log suffix.
   14.4. Lead-In / Lead-Out / Chain: step in milliseconds for the
         lead utilities and max distance for Chain Left/Right.
   14.5. Kite Timing: base and maximum lead-in, base and maximum
         lead-out, chain out, and maximum chain gap.
   14.6. Bidirectional Snapping: frame range for the bidirectional
         snap, and directional range in milliseconds for the
         Start/End Snap tools.
   14.7. Audit Presets: Twin/Miss pairs for Start, End, and Full;
         Short/Long thresholds; maximum CPS; Short, Large, and Both
         gap presets; overtime; maximum width.


15. SUPPORT
___________

Discord: https://discord.gg/Egq8us4xZC
]],
    es = [[
CHRONO SUITE · GUÍA DE USO
___________________________

Suite de timing, auditoría, limpieza, importación y utilidades de
edición para Aegisub. La interfaz se compone de un panel principal y
diálogos auxiliares (Cue Timer, Extraer KF, Importar Datos, Config
y Ayuda). El panel principal opera sobre la selección actual y se
divide en dos columnas: Marcadores de Auditoría (izquierda) y
Utilidades (derecha), con Importar Datos y Herramientas Extra en la
parte inferior. La mayoría de los resultados de auditoría se inscribe
en el campo Effect.


1. PANEL PRINCIPAL
__________________

El panel se organiza en torno a la selección actual. Las acciones se
ejecutan al pulsar EJECUTAR. Los botones Cue Timer, Extraer KF,
Config y Ayuda abren directamente sus respectivos diálogos.

   1.1. Aplicar a: define el subconjunto sobre el que actúan las
        secciones del panel.
   1.2. Filtro: campo de texto o número asociado al criterio de
        Aplicar a.
   1.3. Marcadores de Auditoría: presets, tolerancias, modo de
        keyframe y Marcador único.
   1.4. Utilidades: siete secciones independientes (Caja, Puntuación,
        Tags/Comentarios, Smart, Dividir/Unir, Tiempo/Orden y Karaoke).
   1.5. Importar Datos: importación desde texto pegado en la caja
        correspondiente.
   1.6. Herramientas Extra: cinco herramientas independientes.

Un desplegable vacío omite la sección durante la ejecución.


2. APLICAR A / FILTRO
_____________________

   2.1. Toda la selección: utiliza la selección sin filtrar.
   2.2. Por estilo: conserva las líneas cuyo estilo coincide con
        Filtro.
   2.3. Por actor: conserva las líneas cuyo actor coincide con Filtro.
   2.4. Por Effect: conserva las líneas cuyo Effect contiene el texto
        del filtro (coincidencia parcial).
   2.5. Por capa: conserva las líneas cuyo Layer es igual al número
        escrito en Filtro.


3. PRESETS DE AUDITORÍA
_______________________

Cada preset configura las tolerancias indicadas en Config → Presets de
auditoría e inscribe sus marcadores en el campo Effect.

   3.1. Solo finales: contrasta el final de las líneas con keyframes
        cercanos. Inscribe únicamente Miss KF y Twin KF.
   3.2. Solo inicios: equivalente al anterior aplicado al inicio de las
        líneas.
   3.3. Auditoría completa: revisión general de texto, composición,
        timing, CPS, gaps y estructura.
   3.4. Duración: contrasta cada línea con los umbrales Corto y Largo.
   3.5. CPS: revisa velocidad de lectura contra el umbral configurado.
   3.6. Gaps cortos: revisa los espacios entre líneas contra el umbral
        de Gap corto.
   3.7. Gaps largos: revisa los espacios entre líneas contra el umbral
        de Gap largo.
   3.8. Ambos gaps: ejecuta ambas revisiones de gaps. Los marcadores
        se inscriben en ambas líneas adyacentes con los milisegundos
        detectados.
   3.9. Sobretiempo: marca las líneas que superan la duración máxima
        configurada.


4. CAMPOS NUMÉRICOS DE AUDITORÍA
________________________________

   4.1. Corto (ms) / Largo (ms): umbrales mínimo y máximo de duración.
   4.2. Twin KF (ms): distancia para identificar dos líneas que tocan
        el mismo keyframe.
   4.3. Miss KF (ms): distancia para identificar omisión de keyframe.
   4.4. Sobretiempo (ms): umbral exclusivo del preset Sobretiempo.
   4.5. CPS mín / CPS máx: rangos de velocidad de lectura.
   4.6. Gap corto (ms) / Gap largo (ms): umbrales de separación entre
        líneas.
   4.7. Ancho máximo (px): ancho visual de la línea utilizado como
        criterio de revisión.


5. MODO Y DIRECCIÓN DE KEYFRAME
_______________________________

   5.1. Modo KF: define el borde contrastado contra los keyframes:
        Solo inicio, Solo final o Ambos.
   5.2. Dir KF: dirección de búsqueda para Near/Missed KF: Atrás,
        Adelante o Ambos. El valor vacío equivale a Atrás.
   5.3. Sello Keyframe: opción independiente que inscribe START-ON-KF
        o END-ON-KF cuando el borde coincide con un keyframe.
   5.4. Marcar continuas (0 ms): incluye los gaps de cero milisegundos
        en la revisión.
   5.5. Ignorar gap en KF: omite los gaps cuyo borde coincide con un
        keyframe.
   5.6. Limpiar marcadores previos: elimina los marcadores existentes
        antes de inscribir los nuevos.


6. MARCADOR ÚNICO
_________________

Anula el preset elegido y ejecuta una sola comprobación. Su etiqueta se
inscribe en Effect.

   6.1. Numeración e identificación
        - Number Effects: numeración correlativa (1, 2, 3...).
        - Add Identifier: identificador único de 14 dígitos por línea.

   6.2. Texto y puntuación
        - UPPERCASE: línea íntegramente en mayúsculas.
        - THREE-LINES: línea con tres renglones visibles.
        - NO-END-PUNCT: línea sin puntuación final.
        - FINAL-COMMA: línea terminada en coma.
        - UNPAIRED-PUNCT: signos de puntuación sin contraparte.
        - STRONG-EXCL: signo de exclamacion visible ("¡", "!" o
          variante fullwidth).
        - STRONG-QUEST: palabra con "¿" de apertura y "?" de cierre.
        - MIXED-EMPHASIS: palabra con dos aperturas (¡¿) o dos
          cierres (?!).
        - SEMICOLON: línea con ";".
        - STUTTER: palabra con el patrón X-X (misma letra repetida
          con guion).

   6.3. Composición y estructura
        - SHORT-LAST-LINE: última línea visualmente corta.
        - BROKEN-TAG: bloque de override vacío o malformado.
        - OVERLAP: solapamiento con otra línea.
        - DEFAULT-STYLE: línea con estilo Default.
        - ITALIC-ERROR: incoherencia en el uso de cursivas.
        - PARENTHESES: paréntesis sin contraparte.
        - NAME-PREFIX: prefijo de nombre detectado.
        - MULTI-SENTENCE: varias oraciones en una misma línea.

   6.4. Presencia de override tags
        - LINE-BREAK, POSITION-TAG, CLIP-TAG, FADE-TAG, TRANSFORM-TAG,
          KARAOKE-TAG.

   6.5. Limpieza y contenido
        - COMMENT-BLOCK: bloque de comentario en el texto.
        - HAS-DIGITS: presencia de dígitos.
        - HAS-CJK: caracteres CJK o kana.
        - FULL-ITALIC: línea íntegramente en cursiva.
        - DOUBLE-SPACE: espacios dobles en el texto.
        - EDGE-SPACE: espacios al inicio o al final.


7. UTILIDADES
_____________

Cada sección ofrece un desplegable independiente. El valor vacío omite
la sección durante la ejecución.

7.1. CAJA
    - Toggle \an8: alterna la posición superior \an8.
    - Toggle Italics: alterna cursiva.
    - Uppercase: conversión total a mayúsculas.
    - Lowercase: conversión total a minúsculas.
    - Title Case: capitalización por palabra.
    - Sentence Case: capitalización por oración.
    - Capitalize First: capitaliza el primer carácter visible.
    - Lowercase First: convierte el primer carácter visible a
      minúscula.

7.2. PUNTUACIÓN / TEXTO
    - Toggle ¡!: alterna el signo de exclamación de apertura.
    - Toggle ¿?: alterna el signo de interrogación de apertura.
    - Toggle ¡¿?!: alterna ambos signos de apertura.
    - Normalize Ellipsis: unifica los puntos suspensivos.
    - Add Ellipsis: añade puntos suspensivos al final de la línea.
    - Erase Leading Ellipsis: elimina puntos suspensivos iniciales.
    - Unify Quotes: unifica comillas.
    - Latin Quotes («»): convierte las comillas a guillemets latinos.
    - Normalize Dashes: normaliza guiones y rayas.
    - Trim Trailing Spaces: elimina espacios finales.
    - Remove Duplicate Letters: elimina letras consecutivas repetidas.
    - Add Stutter: inserta tartamudeo.
    - Add Ah Prefix: añade el prefijo "ah" al inicio del diálogo.
    - Stutter Manager: diálogo interactivo para la gestión de
      tartamudeos.

7.3. TAGS / COMENTARIOS
    - Fold by Identifier: agrupa en folds las líneas que comparten un
      identificador. El fold se crea cuando el grupo tiene dos o más
      líneas.
    - Extract Tags: traslada los override tags desde el texto al campo
      Effect.
    - Reinsert Tags: devuelve los tags desde Effect al texto y
      normaliza los signos de punto y coma como coma dentro de los
      bloques de override.
    - Remove Tags: elimina los bloques de override del diálogo
      visible.
    - Remove Comments: elimina los bloques de comentario dentro del
      texto.
    - Actor Parser: procesa información de actor a partir del texto.
    - Swap Comment: alterna el estado comentado de la línea.
    - Delete Comment Lines: elimina las líneas marcadas como
      comentario.
    - Comments to Top: reordena los comentarios al inicio de la
      selección.
    - Comments to Bottom: reordena los comentarios al final de la
      selección.
    - Effects to Top: sube las líneas con Effect no vacío al inicio de
      la selección conservando el orden relativo.

7.4. SMART
    - Bidirectional Snapping: ajusta inicio y final al keyframe más
      próximo dentro del rango configurado en frames.
    - Remove Honorifics: envuelve los honoríficos japoneses en
      bloques de comentario {…} para que permanezcan en la fuente
      pero desaparezcan visualmente.
    - Caption Clarifier: normaliza acotaciones de subtitulado.
    - Complete Sentences: une una línea incompleta con la siguiente
      cuando el texto posterior empieza en minúscula. Los solapes o
      continuaciones sin minúscula se marcan como [POSSIBLE-JOIN].
    - Erase Blank Lines: elimina las líneas vacías.
    - Frame Effect: inscribe en Effect el número de frame
      correspondiente al inicio de la línea.
    - Copy Fold: duplica el contenido del fold que contiene a la línea
      activa.

7.5. DIVIDIR / UNIR
    - Smart Break: inserta un salto \N en la posición óptima
      solo cuando el texto renderizado excede el ancho disponible.
    - Split by Sentence: divide la línea por oraciones.
    - Split by Comma: divide la línea por comas.
    - Pivot \N: desplaza el salto \N dentro de la línea.
    - Remove \N: elimina todos los \N de la línea y compacta espacios.
    - Join Lines: une las líneas consecutivas seleccionadas.
    - Join Same Text: une las líneas adyacentes con texto idéntico.
    - Join Overlaps: une grupos seleccionados cuyos tiempos se solapan,
      expande la línea conservada a los límites del grupo y mantiene
      cada texto separado por \N.
    - Divide by \N: divide la línea por cada \N existente.

7.6. TIEMPO / ORDEN
    - Copy Times: copia los tiempos de una línea a otras.
    - Time Picker: selecciona líneas comprendidas en un rango.
    - Sort by Length: ordena las líneas por longitud.
    - Sort by CPS: ordena las líneas por velocidad de lectura.
    - Sort Odd Even: ordena por valor numérico del Effect (impares y
      pares).
    - Count CPS: muestra el promedio de CPS sobre la selección.
    - Import Text: importa texto desde una fuente externa para
      reemplazo controlado.
    - Kite Timing: aplica el algoritmo Kite Timing (lead-in y lead-out
      adaptativos, encadenado y protección de bordes) según los
      valores definidos en Config.
    - Shift First: desplaza la selección de modo que la primera línea
      coincida con el inicio de la segunda.
    - Start Snap Back: ajusta el inicio al keyframe anterior.
    - Start Snap Forward: ajusta el inicio al keyframe siguiente.
    - End Snap Back: ajusta el final al keyframe anterior.
    - End Snap Forward: ajusta el final al keyframe siguiente.
    - Add Lead-In Left: adelanta el inicio hacia la izquierda por el
      paso configurado (Config → Lead-In / Lead-Out). Si hay una
      vecina encadenada con gap 0, su final se mueve junto con el
      inicio para mantener la cadena; si el gap es positivo, el inicio
      solo avanza hasta tocar a la vecina (gap 0), nunca la solapa.
    - Add Lead-In Right: mueve el inicio hacia la derecha por el paso
      configurado. Si hay una vecina encadenada con gap 0, su final se
      mueve junto para mantener la cadena.
    - Add Lead-Out Left: mueve el final hacia la izquierda por el paso
      configurado. La siguiente línea encadenada mueve su inicio para
      mantener la cadena.
    - Add Lead-Out Right: mueve el final hacia la derecha por el paso
      configurado, empujando el inicio de la siguiente línea si está
      encadenada.
    - Chain Left: extiende el inicio hasta el final de la línea
      anterior (crea gap 0), dentro de la distancia máxima
      configurada.
    - Chain Right: extiende el final hasta el inicio de la línea
      siguiente (crea gap 0), dentro de la distancia máxima
      configurada.

7.7. KARAOKE
    - Romaji Karaoker (Word → \k): genera karaoke simple por palabra
      en romaji con etiquetas {\k}.


8. IMPORTAR DATOS
_________________

La importación toma como fuente el texto pegado en la caja. La caja
vacía omite esta sección.

   8.1. Import Effects: copia el Effect de origen por superposición
        temporal.
   8.2. Import Text: copia el texto visible por superposición temporal.
   8.3. Import Actor: copia el actor por la mejor superposición
        temporal.
   8.4. Import Tags: copia override tags iniciales de las líneas de
        origen solapadas. Los tags importados reemplazan tags iniciales
        iguales en destino; los tags inline tras texto visible se
        ignoran.
   8.5. Song Sync: duplica o sincroniza grupos a partir de una línea
        Comment con layer 50 como punto de sincronización.
   8.6. Same Layers: al marcarlo, Import Effects, Import Text, Import
        Actor e Import Tags solo emparejan líneas de origen cuyo layer
        coincide con el layer de la línea destino.
   8.7. Importar como comentario: encapsula el texto importado dentro
        de bloques {…} de comentario.


9. HERRAMIENTAS EXTRA
_____________________

   9.1. AE Export: exporta datos de movimiento compatibles con After
        Effects.
   9.2. Text Replacer: reemplaza texto visible conservando los
        override tags.
   9.3. mpv QC: lee notas exportadas desde mpvQC con formato
        [hh:mm:ss.ms] [Tipo] Observación {sugerencia}. La observación
        se inscribe como [QC: …] en Effect y la sugerencia se inserta
        como bloque de comentario en el texto. La tolerancia se define
        en milisegundos.
   9.4. Remover Assistant: elimina signos visibles, espacios,
        comentarios y override tags conocidos sin alternarlos si no
        existen.
   9.5. Style Filter: filtra o elimina líneas por estilo con diálogo
        de confirmación.


10. CUE TIMER
_____________

Diálogo de timing automático que detecta intervalos de voz mediante
datos de silencio, VAD, flux, envolvente y keyframes. Los parámetros
numéricos se guardan en la configuración principal de Chrono Suite.

   10.1. Modos:
         - Timing Completo: pegado a la voz y luego padding,
           encadenado y ajuste a keyframes.
         - Post-Timing: padding, encadenado y ajuste a keyframes para
           líneas que ya están sobre la voz.
         - Timing Bruto: mueve las líneas al inicio/final de la voz
           detectada, sin padding.
         - LZT Bruto (Legacy): aplica el método elegido en Config.
         - LZT Bruto Silencios: usa solo los archivos de silencios,
           sin flux ni VAD.
   10.2. Cuando Autobuscar al abrir está marcado, los archivos de
         datos se detectan en la carpeta del subtítulo con la
         nomenclatura de ProcesarLote.bat (NN_Retimes_30/40/50.txt,
         NN_Retimes_vad.tsv,
         NN_Retimes_flux.tsv, NN_envelope.tsv, NN_keyframes.log) y
         también nombres genéricos (sil30, vad, flux, rms,
         keyframes). Las rutas pueden editarse o elegirse con
         Buscar... (multi-selección; cada archivo se asigna a su
         casilla por nombre). Desmárcalo para dejar intactas las
         casillas de ruta al abrir el diálogo.
   10.3. Multi-capítulo por layer: los archivos se agrupan por el
         número inicial de su nombre y cada línea se procesa con los
         archivos del capítulo igual a su layer (layer 1 → archivos
         del capítulo 1). Los keyframes salen del log de cada
         capítulo; los layers sin archivos se informan y se omiten.
   10.4. Filtro de estilo: All, All Default, Default+Alt o un estilo
         exacto, más un segundo estilo exacto en la caja extra.
   10.5. Las líneas con problemas se marcan en Effect con marcadores
         [TM-...] (Timing Completo, Post-Timing y Timing Bruto) o
         etiquetas [LZ ...] (modos LZT). Ambos se limpian
         automáticamente en la siguiente ejecución.


11. CUE TIMER: MODOS LZT
________________________

Estos modos ajustan las líneas a intervalos de silencio y las refinan
con evidencia de flux o VAD según el método elegido en Config.

   11.1. Método (Config): LazyFusion (silencios + refinado con flux),
         Cluster (±ms) (candidatos de borde de silencio puntuados con
         evidencia opcional de flux/VAD) y Table (±ms) (solo
         silencios; un archivo, prefiriendo -40 dB; el CSV
         noise_table es opcional). Los modos LZT también respetan el
         filtro de estilo y la omisión de signs/karaoke.
   11.2. Límite (ms): distancia máxima de ajuste (Cluster/Table).
   11.3. Aplicación: inicio, final o ambos.
   11.4. Escritura de marcas de tiempo:
         - Modo: Both, Only changes, Only 0ms, None.
         - Alcance: Both, Start only, End only.
   11.5. LZT Bruto Silencios ignora el método y ejecuta solo el motor
         de intervalos de silencio.


12. EXTRAER KF
______________

Genera un log de keyframes mediante SCXvid, con apoyo de FFmpeg para la
decodificación. Las rutas de SCXvid y FFmpeg y el sufijo del log se
configuran en Config → SCXvid.


13. SCREAM DETECTOR
___________________

Herramienta de QA basada en audio. Ejecuta FFmpeg astats sobre el
audio/vídeo cargado e inscribe el marcador [SCREAM] en las líneas
cuyo intervalo es estadísticamente fuerte respecto al resto.

   13.1. Promedio dB: potencia media en el intervalo de cada
         subtítulo. Más cerca de 0 es más estricto.
   13.2. Muestra fuerte dB: muestras por encima de este valor cuentan
         como evidencia fuerte.
   13.3. Ratio muestra fuerte (%): porcentaje mínimo de muestras
         fuertes por intervalo.
   13.4. Muestras mínimas: ignora líneas con poca evidencia.
   13.5. z-score robusto: compara cada línea contra mediana/MAD del
         conjunto analizado.
   13.6. Aplicar a: Todo el diálogo o solo Líneas seleccionadas.
   13.7. Limpiar marcas SCREAM previas: borra [SCREAM] anteriores en
         el ámbito antes de escribir nuevos.
   13.8. Reutilizar log existente: evita ejecutar FFmpeg si ya existe
         el log. Útil para recalibrar.


14. CONFIG
__________

Configuración global persistente entre sesiones.

   14.1. Idioma: en, es, pt.
   14.2. Cue Timer (modos LZT): método, límite, aplicación en inicio
         y final, escritura de marcas de tiempo, modo y alcance, y el
         CSV noise_table opcional.
   14.3. SCXvid: ruta de SCXvid, ruta de FFmpeg y sufijo del log.
   14.4. Lead-In / Lead-Out / Cadena: paso en milisegundos de
         las utilidades de lead y distancia máxima de Chain
         Left/Right.
   14.5. Kite Timing: lead-in base y máximo, lead-out base y máximo,
         salida en cadena y gap máximo de cadena.
   14.6. Bidirectional Snapping: rango en frames para el snap
         bidireccional y rango direccional en milisegundos para los
         Start/End Snap.
   14.7. Presets de auditoría: pares Twin/Miss para Inicio, Final y
         Completa; umbrales Corto/Largo; CPS máxima; presets de gaps
         cortos, largos y ambos; sobretiempo; ancho máximo.


15. SOPORTE
___________

Discord: https://discord.gg/Egq8us4xZC
]],
    pt = [[
CHRONO SUITE · GUIA DE USO
___________________________

Conjunto de timing, auditoria, limpeza, importação e utilidades de
edição para o Aegisub. A interface é composta por um painel principal
e diálogos auxiliares (Cue Timer, Extrair KF, Importar Dados,
Config e Ajuda). O painel principal opera sobre a seleção atual e se
divide em duas colunas: Marcadores de Auditoria (esquerda) e
Utilidades (direita), com Importar Dados e Ferramentas Extras na
parte inferior. A maior parte dos resultados de auditoria é escrita
no campo Effect.


1. PAINEL PRINCIPAL
___________________

O painel se organiza em torno da seleção atual. As ações são
executadas ao pressionar EXECUTAR. Os botões Cue Timer, Extrair
KF, Config e Ajuda abrem diretamente seus respectivos diálogos.

   1.1. Aplicar em: define o subconjunto sobre o qual as seções do
        painel atuam.
   1.2. Filtro: campo de texto ou número associado ao critério de
        Aplicar em.
   1.3. Marcadores de Auditoria: presets, tolerâncias, modo de
        keyframe e Marcador único.
   1.4. Utilidades: sete seções independentes (Caixa, Pont/Texto,
        Tags/Comentários, Smart, Dividir/Unir, Tempo/Ordem e Karaokê).
   1.5. Importar Dados: importação a partir de texto colado na caixa
        correspondente.
   1.6. Ferramentas Extras: cinco ferramentas independentes.

Um dropdown vazio salta sua seção durante a execução.


2. APLICAR EM / FILTRO
______________________

   2.1. Toda a seleção: usa a seleção sem filtrar.
   2.2. Por estilo: mantém as linhas cujo estilo coincide com Filtro.
   2.3. Por ator: mantém as linhas cujo ator coincide com Filtro.
   2.4. Por Effect: mantém as linhas cujo Effect contém o texto do
        filtro (coincidência parcial).
   2.5. Por camada: mantém as linhas cujo Layer é igual ao número
        escrito em Filtro.


3. PRESETS DE AUDITORIA
_______________________

Cada preset aplica as tolerâncias definidas em Config → Presets de
auditoria e inscreve seus marcadores no campo Effect.

   3.1. Só finais: verifica o fim das linhas contra keyframes
        próximos. Inscreve apenas Miss KF e Twin KF.
   3.2. Só inícios: verificação equivalente aplicada ao início das
        linhas.
   3.3. Auditoria completa: revisão geral de texto, composição,
        timing, CPS, gaps e estrutura.
   3.4. Duração: verifica cada linha contra os limites Curto e Longo.
   3.5. CPS: verifica a velocidade de leitura contra o máximo
        configurado.
   3.6. Gaps curtos: verifica os espaços entre linhas contra o limite
        de Gap curto.
   3.7. Gaps longos: verifica os espaços entre linhas contra o limite
        de Gap longo.
   3.8. Ambos gaps: executa ambas as revisões de gaps. Os marcadores
        são inscritos em ambas as linhas adjacentes com os milissegundos
        detectados.
   3.9. Sobretempo: marca as linhas que ultrapassam a duração máxima
        configurada.


4. CAMPOS NUMÉRICOS DE AUDITORIA
________________________________

   4.1. Curto (ms) / Longo (ms): limites mínimo e máximo de duração.
   4.2. Twin KF (ms): distância para identificar duas linhas que
        tocam o mesmo keyframe.
   4.3. Miss KF (ms): distância para identificar omissão de keyframe.
   4.4. Sobretempo (ms): limite exclusivo do preset Sobretempo.
   4.5. Min CPS / Max CPS: faixa de velocidade de leitura.
   4.6. Gap curto (ms) / Gap longo (ms): limites de separação entre
        linhas.
   4.7. Largura máx (px): largura visual da linha usada como critério
        de revisão.


5. MODO E DIREÇÃO DE KEYFRAME
_____________________________

   5.1. Modo KF: define a borda verificada contra os keyframes: Só
        início, Só final ou Ambos.
   5.2. Dir KF: direção de busca para Near/Missed KF: Para trás,
        Para frente ou Ambos. O valor vazio equivale a Para trás.
   5.3. Selo de Keyframe: opção independente que inscreve START-ON-KF
        ou END-ON-KF quando a borda coincide com um keyframe.
   5.4. Marcar contínuas (0 ms): inclui os gaps de zero milissegundos
        na revisão.
   5.5. Ignorar gap em KF: descarta os gaps cuja borda coincide com
        um keyframe.
   5.6. Limpar marcadores prévios: remove os marcadores existentes
        antes de inscrever os novos.


6. MARCADOR ÚNICO
_________________

Anula o preset escolhido e executa uma única verificação. Sua
etiqueta é inscrita no campo Effect.

   6.1. Numeração e identificação
        - Number Effects: numeração sequencial (1, 2, 3...).
        - Add Identifier: identificador único de 14 dígitos por linha.

   6.2. Texto e pontuação
        - UPPERCASE: linha inteira em maiúsculas.
        - THREE-LINES: linha exibida em três fileiras.
        - NO-END-PUNCT: linha sem pontuação final.
        - FINAL-COMMA: linha terminada em vírgula.
        - UNPAIRED-PUNCT: sinais de pontuação sem contraparte.
        - STRONG-EXCL: sinal de exclamação visível ("¡", "!" ou
          variante fullwidth).
        - STRONG-QUEST: palavra com "¿" de abertura e "?" de
          fechamento.
        - MIXED-EMPHASIS: palavra com duas aberturas (¡¿) ou dois
          fechamentos (?!).
        - SEMICOLON: linha contém ";".
        - STUTTER: palavra com o padrão X-X (mesma letra repetida com
          hífen).

   6.3. Composição e estrutura
        - SHORT-LAST-LINE: última linha visualmente curta.
        - BROKEN-TAG: bloco de override vazio ou malformado.
        - OVERLAP: sobreposição com outra linha.
        - DEFAULT-STYLE: linha com estilo Default.
        - ITALIC-ERROR: inconsistência no uso de itálico.
        - PARENTHESES: parênteses sem contraparte.
        - NAME-PREFIX: prefixo de nome detectado.
        - MULTI-SENTENCE: mais de uma frase em uma mesma linha.

   6.4. Presença de override tags
        - LINE-BREAK, POSITION-TAG, CLIP-TAG, FADE-TAG, TRANSFORM-TAG,
          KARAOKE-TAG.

   6.5. Limpeza e conteúdo
        - COMMENT-BLOCK: bloco de comentário embutido no texto.
        - HAS-DIGITS: presença de dígitos.
        - HAS-CJK: caracteres CJK ou kana.
        - FULL-ITALIC: linha inteira em itálico.
        - DOUBLE-SPACE: espaços duplos no texto.
        - EDGE-SPACE: espaços no início ou no final.


7. UTILIDADES
_____________

Cada seção oferece um dropdown independente. O valor vazio salta a
seção durante a execução.

7.1. CAIXA
    - Toggle \an8: alterna o alinhamento superior \an8.
    - Toggle Italics: alterna itálico.
    - Uppercase: converte todo o texto para maiúsculas.
    - Lowercase: converte todo o texto para minúsculas.
    - Title Case: capitaliza cada palavra.
    - Sentence Case: capitaliza a primeira palavra de cada frase.
    - Capitalize First: capitaliza o primeiro caractere visível.
    - Lowercase First: converte o primeiro caractere visível para
      minúscula.

7.2. PONTUAÇÃO / TEXTO
    - Toggle ¡!: alterna o sinal de exclamação de abertura.
    - Toggle ¿?: alterna o sinal de interrogação de abertura.
    - Toggle ¡¿?!: alterna ambos os sinais de abertura.
    - Normalize Ellipsis: unifica as reticências.
    - Add Ellipsis: adiciona reticências no final da linha.
    - Erase Leading Ellipsis: remove reticências iniciais.
    - Unify Quotes: unifica as aspas.
    - Latin Quotes («»): converte as aspas para guillemets latinos.
    - Normalize Dashes: padroniza hifens, travessões e meias-riscas.
    - Trim Trailing Spaces: remove espaços finais.
    - Remove Duplicate Letters: remove letras consecutivas repetidas.
    - Add Stutter: insere gagueira no texto.
    - Add Ah Prefix: insere o prefixo "ah" no início do diálogo.
    - Stutter Manager: diálogo interativo para gerenciar gagueira.

7.3. TAGS / COMENTÁRIOS
    - Fold by Identifier: agrupa em folds as linhas que compartilham
      um identificador. O fold é criado quando o grupo contém duas
      ou mais linhas.
    - Extract Tags: move os override tags do texto para o campo
      Effect.
    - Reinsert Tags: devolve os tags do Effect ao texto e normaliza
      os pontos e vírgulas como vírgulas dentro dos blocos de
      override.
    - Remove Tags: apaga os blocos de override do diálogo visível.
    - Remove Comments: apaga os blocos de comentário dentro do texto.
    - Actor Parser: extrai informação de ator a partir do texto.
    - Swap Comment: alterna o estado comentado da linha.
    - Delete Comment Lines: apaga as linhas marcadas como comentário.
    - Comments to Top: reordena os comentários ao início da seleção.
    - Comments to Bottom: reordena os comentários ao final da
      seleção.
    - Effects to Top: sobe as linhas com Effect não vazio ao início
      da seleção, preservando a ordem relativa.

7.4. SMART
    - Bidirectional Snapping: ajusta início e fim ao keyframe mais
      próximo dentro do alcance configurado em frames.
    - Remove Honorifics: envolve os honoríficos japoneses em blocos
      de comentário {…} para que permaneçam na fonte mas desapareçam
      visualmente.
    - Caption Clarifier: padroniza indicações de legendagem.
    - Complete Sentences: une uma linha incompleta com a seguinte
      quando o texto posterior começa em minúscula. Sobreposições ou
      continuações sem minúscula são marcadas como [POSSIBLE-JOIN].
    - Erase Blank Lines: apaga linhas em branco.
    - Frame Effect: inscreve em Effect o número de frame
      correspondente ao início da linha.
    - Copy Fold: duplica o conteúdo do fold que contém a linha
      ativa.

7.5. DIVIDIR / UNIR
    - Smart Break: insere uma quebra \N na posição ótima
      apenas quando o texto renderizado excede a largura disponível.
    - Split by Sentence: divide a linha por frase.
    - Split by Comma: divide a linha por vírgula.
    - Pivot \N: desloca a quebra \N dentro da linha.
    - Remove \N: remove todos os \N da linha e compacta espaços.
    - Join Lines: une as linhas consecutivas selecionadas.
    - Join Same Text: une as linhas adjacentes com texto idêntico.
    - Join Overlaps: une grupos selecionados cujos tempos se sobrepõem,
      expande a linha preservada aos limites do grupo e mantém cada
      texto separado por \N.
    - Divide by \N: divide a linha em cada \N existente.

7.6. TEMPO / ORDEM
    - Copy Times: copia os tempos de uma linha para outras.
    - Time Picker: seleciona linhas dentro de um intervalo.
    - Sort by Length: ordena as linhas por comprimento.
    - Sort by CPS: ordena as linhas por velocidade de leitura.
    - Sort Odd Even: ordena pelo valor numérico do Effect (ímpares e
      pares).
    - Count CPS: mostra o CPS médio da seleção.
    - Import Text: importa texto a partir de uma fonte externa para
      substituição controlada.
    - Kite Timing: aplica o algoritmo Kite Timing (lead-in e
      lead-out adaptativos, encadeamento e proteção de bordas) com
      os valores de Config.
    - Shift First: desloca a seleção de modo que a primeira linha
      coincida com o início da segunda.
    - Start Snap Back: ajusta o início ao keyframe anterior.
    - Start Snap Forward: ajusta o início ao keyframe seguinte.
    - End Snap Back: ajusta o fim ao keyframe anterior.
    - End Snap Forward: ajusta o fim ao keyframe seguinte.
    - Add Lead-In Left: antecipa o início para a esquerda pelo passo
      configurado (Config → Lead-In / Lead-Out). Se houver uma
      vizinha encadeada com gap 0, o fim dela se move junto para
      manter a cadeia; com gap positivo, o início só avança até tocar
      a vizinha (gap 0), nunca a sobrepõe.
    - Add Lead-In Right: move o início para a direita pelo passo
      configurado. Se houver uma vizinha encadeada com gap 0, o fim
      dela se move junto para manter a cadeia.
    - Add Lead-Out Left: move o fim para a esquerda pelo passo
      configurado. A próxima linha encadeada move o início para
      manter a cadeia.
    - Add Lead-Out Right: move o fim para a direita pelo passo
      configurado, empurrando o início da linha seguinte se estiver
      encadeada.
    - Chain Left: estende o início até o fim da linha anterior (cria
      gap 0), dentro da distância máxima configurada.
    - Chain Right: estende o fim até o início da linha seguinte (cria
      gap 0), dentro da distância máxima configurada.

7.7. KARAOKÊ
    - Romaji Karaoker (Word → \k): gera karaokê simples por palavra
      em romaji com tags {\k}.


8. IMPORTAR DADOS
_________________

A importação toma como fonte o texto colado na caixa de Importar
Dados. A caixa vazia salta esta seção.

   8.1. Import Effects: copia o Effect de origem por sobreposição
        temporal.
   8.2. Import Text: copia o texto visível por sobreposição temporal.
   8.3. Import Actor: copia o ator pela melhor sobreposição temporal.
   8.4. Import Tags: copia override tags iniciais das linhas de origem
        sobrepostas. Os tags importados substituem tags iniciais iguais
        no destino; tags inline após texto visível são ignorados.
   8.5. Song Sync: duplica ou sincroniza grupos a partir de uma linha
        Comment com layer 50 como ponto de sincronia.
   8.6. Same Layers: quando marcado, Import Effects, Import Text,
        Import Actor e Import Tags só combinam linhas de origem cujo
        layer coincide com o layer da linha destino.
   8.7. Importar como comentário: encapsula o texto importado dentro
        de blocos {…} de comentário.


9. FERRAMENTAS EXTRAS
_____________________

   9.1. AE Export: exporta dados de movimento compatíveis com o After
        Effects.
   9.2. Text Replacer: substitui texto visível preservando os
        override tags.
   9.3. mpv QC: lê notas exportadas do mpvQC no formato
        [hh:mm:ss.ms] [Tipo] Observação {sugestão}. A observação é
        inscrita como [QC: …] em Effect e a sugestão é inserida como
        bloco de comentário no texto. A tolerância é definida em
        milissegundos.
   9.4. Remover Assistant: remove sinais visíveis, espaços,
        comentários e override tags conhecidos sem alterná-los quando
        ausentes.
   9.5. Style Filter: filtra ou apaga linhas por estilo com diálogo
        de confirmação.


10. CUE TIMER
_____________

Diálogo de timing automático que detecta intervalos de voz por meio de
dados de silêncio, VAD, flux, envelope e keyframes. Os parâmetros
numéricos são salvos na configuração principal do Chrono Suite.

   10.1. Modos:
         - Timing Completo: encaixe na voz e depois padding,
           encadeamento e ajuste a keyframes.
         - Pós-Timing: padding, encadeamento e ajuste a keyframes
           para linhas que já estão sobre a voz.
         - Timing Bruto: move as linhas para o início/fim da voz
           detectada, sem padding.
         - LZT Bruto (Legacy): aplica o método escolhido em Config.
         - LZT Bruto Silêncios: usa apenas os arquivos de silêncios,
           sem flux nem VAD.
   10.2. Quando Buscar ao abrir está marcado, os arquivos de dados são
         detectados na pasta da legenda com a nomenclatura do
         ProcesarLote.bat (NN_Retimes_30/40/50.txt, NN_Retimes_vad.tsv,
         NN_Retimes_flux.tsv, NN_envelope.tsv, NN_keyframes.log) e
         também nomes genéricos (sil30, vad, flux, rms, keyframes).
         Os caminhos podem ser editados ou escolhidos com Procurar...
         (multi-seleção; cada arquivo é atribuído pelo nome).
         Desmarque para deixar as caixas de caminho intactas ao abrir
         o diálogo.
   10.3. Multi-capítulo por camada: os arquivos são agrupados pelo
         número inicial do nome e cada linha é processada com os
         arquivos do capítulo igual à sua camada (camada 1 → arquivos
         do capítulo 1). Os keyframes vêm do log de cada capítulo;
         camadas sem arquivos são informadas e puladas.
   10.4. Filtro de estilo: All, All Default, Default+Alt ou um estilo
         exato, mais um segundo estilo exato na caixa extra.
   10.5. Linhas com problemas são marcadas em Effect com marcadores
         [TM-...] (Timing Completo, Pós-Timing e Timing Bruto) ou tags
         [LZ ...] (modos LZT). Ambos são limpos automaticamente na
         próxima execução.


11. CUE TIMER: MODOS LZT
________________________

Estes modos ajustam as linhas aos intervalos de silêncio e as refinam
com evidência de flux ou VAD conforme o método escolhido em Config.

   11.1. Método (Config): LazyFusion (silêncios + refinamento com
         flux), Cluster (±ms) (candidatos de borda de silêncio
         pontuados com evidência opcional de flux/VAD) e Table (±ms)
         (apenas silêncios; um arquivo, preferindo -40 dB; o CSV
         noise_table é opcional). Os modos LZT também respeitam o
         filtro de estilo e o pulo de signs/karaokê.
   11.2. Limite (ms): distância máxima de ajuste (Cluster/Table).
   11.3. Aplicação: início, fim ou ambos.
   11.4. Escrita de marcas de tempo:
         - Modo: Both, Only changes, Only 0ms, None.
         - Escopo: Both, Start only, End only.
   11.5. LZT Bruto Silêncios ignora o método e executa apenas o motor
         de intervalos de silêncio.


12. EXTRAIR KF
______________

Gera um log de keyframes por meio do SCXvid, com apoio do FFmpeg para
a decodificação. O caminho do SCXvid, o caminho do FFmpeg e o sufixo
do log são configurados em Config → SCXvid.


13. SCREAM DETECTOR
___________________

Ferramenta de QA baseada em áudio. Executa FFmpeg astats no
áudio/vídeo carregado e escreve o marcador [SCREAM] nas linhas cujo
intervalo é estatisticamente forte em relação ao restante.

   13.1. Média dB: potência média no intervalo de cada legenda. Mais
         perto de 0 é mais estrito.
   13.2. Amostra forte dB: amostras acima deste valor contam como
         evidência forte.
   13.3. Razão amostra forte (%): porcentagem mínima de amostras
         fortes por intervalo.
   13.4. Amostras mínimas: ignora linhas com pouca evidência.
   13.5. z-score robusto: compara cada linha contra mediana/MAD do
         conjunto analisado.
   13.6. Aplicar em: Todo o diálogo ou somente Linhas selecionadas.
   13.7. Limpar marcas SCREAM anteriores: apaga [SCREAM] anteriores
         no escopo antes de escrever novos.
   13.8. Reutilizar log existente: evita executar FFmpeg se já existe
         o log. Útil para recalibrar.


14. CONFIG
__________

Configuração global persistente entre sessões.

   14.1. Idioma: en, es, pt.
   14.2. Cue Timer (modos LZT): método, limite, aplicação no início
         e no fim, escrita de marcas de tempo, modo e escopo, e o
         CSV noise_table opcional.
   14.3. SCXvid: caminho do SCXvid, caminho do FFmpeg e sufixo do
         log.
   14.4. Lead-In / Lead-Out / Cadeia: passo em
         milissegundos das utilidades de lead e distância máxima de
         Chain Left/Right.
   14.5. Kite Timing: lead-in base e máximo, lead-out base e máximo,
         saída em cadeia e gap máximo da cadeia.
   14.6. Bidirectional Snapping: alcance em frames para o snap
         bidirecional e alcance direcional em milissegundos para as
         ferramentas Start/End Snap.
   14.7. Presets de auditoria: pares Twin/Miss para Início, Fim e
         Completa; limites Curto/Longo; CPS máximo; presets de gaps
         curtos, longos e ambos; sobretempo; largura máxima.


15. SUPORTE
___________

Discord: https://discord.gg/Egq8us4xZC
]],
}
local function showHelp()
    aegisub.dialog.display({{class="textbox", text=SUITE_HELP[currentLang] or SUITE_HELP.en, x=0, y=0, width=45, height=25}}, {L("help_btn_close")})
end

local function showConfigDialog()
    resolveConfig()
    local cfgUi = {
        language = UI.options({"en","es","pt"}, currentConfig.language),
        lazy_method = UI.options({"LazyFusion", "Cluster (±ms)", "Table (±ms)"}, currentConfig.lazy_method),
        lazy_tag_mode = UI.options({"Both","Only changes","Only 0ms","None"}, currentConfig.lazy_tag_mode),
        lazy_tag_scope = UI.options({"Both","Start only","End only"}, currentConfig.lazy_tag_scope),
        scream_scope = UI.options({ "All dialogue", "Selected lines" }, currentConfig.scream_scope),
    }
    local dlg = {
        { class="label", label=L("cfg_lbl_language"), x=0, y=0, width=2, height=1 },
        { class="dropdown", name="language", items=cfgUi.language.items, value=cfgUi.language.value, x=2, y=0, width=2, height=1 },
        { class="label", label=L("cfg_lbl_lazy"), x=0, y=1, width=4, height=1 },
        { class="label", label=L("cfg_lbl_method"), x=0, y=2, width=1, height=1 },
        { class="dropdown", name="lazy_method", items=cfgUi.lazy_method.items, value=cfgUi.lazy_method.value, x=1, y=2, width=3, height=1 },
        { class="label", label=L("cfg_lbl_limit"), x=0, y=3, width=1, height=1 },
        { class="intedit", name="lazy_limit", value=tonumber(currentConfig.lazy_limit) or 800, x=1, y=3, width=1, min=0, max=10000 },
        { class="checkbox", name="lazy_apply_start", label=L("cfg_chk_apply_start"), value=currentConfig.lazy_apply_start, x=0, y=4, width=2, height=1 },
        { class="checkbox", name="lazy_apply_end", label=L("cfg_chk_apply_end"), value=currentConfig.lazy_apply_end, x=2, y=4, width=2, height=1 },
        { class="checkbox", name="lazy_enable_tagging", label=L("cfg_chk_tagging"), value=currentConfig.lazy_enable_tagging, x=0, y=5, width=2, height=1 },
        { class="dropdown", name="lazy_tag_mode", items=cfgUi.lazy_tag_mode.items, value=cfgUi.lazy_tag_mode.value, x=2, y=5, width=2, height=1 },
        { class="dropdown", name="lazy_tag_scope", items=cfgUi.lazy_tag_scope.items, value=cfgUi.lazy_tag_scope.value, x=0, y=6, width=2, height=1 },
        { class="checkbox", name="lazy_table_csv", label=L("cfg_chk_table_csv"), value=currentConfig.lazy_table_csv, x=2, y=6, width=2, height=1 },
        { class="label", label=L("cfg_lbl_scxvid"), x=0, y=7, width=4, height=1 },
        { class="label", label=L("cfg_lbl_scxvid_path"), x=0, y=8, width=1, height=1 },
        { class="edit", name="scxvid_path", value=currentConfig.scxvid_path, x=1, y=8, width=3 },
        { class="label", label=L("cfg_lbl_ffmpeg_path"), x=0, y=9, width=1, height=1 },
        { class="edit", name="ffmpeg_path", value=currentConfig.ffmpeg_path, x=1, y=9, width=3 },
        { class="label", label=L("cfg_lbl_log_suffix"), x=0, y=10, width=1, height=1 },
        { class="edit", name="scxvid_suffix", value=currentConfig.scxvid_suffix, x=1, y=10, width=1 },
        { class="label", label=L("cfg_lbl_leadutil"), x=0, y=11, width=4, height=1 },
        { class="label", label=L("cfg_lbl_lead_step"), x=0, y=12, width=1, height=1 },
        { class="intedit", name="lead_step_ms", value=currentConfig.lead_step_ms, x=1, y=12, width=1, min=1, max=2000 },
        { class="label", label=L("cfg_lbl_chain_cap"), x=2, y=12, width=1, height=1 },
        { class="intedit", name="chain_max_ms", value=currentConfig.chain_max_ms, x=3, y=12, width=1, min=0, max=20000 },
        { class="label", label=L("cfg_lbl_kite"), x=0, y=13, width=4, height=1 },
        { class="intedit", name="kt_lead_in_base", value=currentConfig.kt_lead_in_base, x=0, y=14, width=1, min=0, max=2000 },
        { class="intedit", name="kt_lead_in_max", value=currentConfig.kt_lead_in_max, x=1, y=14, width=1, min=0, max=2000 },
        { class="intedit", name="kt_lead_out_base", value=currentConfig.kt_lead_out_base, x=2, y=14, width=1, min=0, max=2000 },
        { class="intedit", name="kt_lead_out_max", value=currentConfig.kt_lead_out_max, x=3, y=14, width=1, min=0, max=2000 },
        { class="intedit", name="kt_lead_out_chain", value=currentConfig.kt_lead_out_chain, x=0, y=15, width=1, min=0, max=2000 },
        { class="intedit", name="kt_chain_gap_max", value=currentConfig.kt_chain_gap_max, x=1, y=15, width=1, min=0, max=2000 },
        { class="label", label=L("cfg_lbl_bidir"), x=0, y=16, width=4, height=1 },
        { class="label", label=L("cfg_lbl_bidir_snap"), x=0, y=17, width=2, height=1 },
        { class="intedit", name="bidir_snap_f", value=currentConfig.bidir_snap_f, x=2, y=17, width=1, min=0, max=20 },
        { class="label", label=L("cfg_lbl_snap_protect"), x=0, y=18, width=2, height=1 },
        { class="intedit", name="edge_snap_protect_ms", value=currentConfig.edge_snap_protect_ms, x=2, y=18, width=1, min=0, max=5000 },
        { class="label", label=L("cfg_lbl_presets"), x=4, y=1, width=4, height=1 },
        { class="label", label=L("cfg_lbl_preset_start"), x=4, y=2, width=2, height=1 },
        { class="intedit", name="preset_start_twin_ms", value=currentConfig.preset_start_twin_ms, x=6, y=2, width=1, min=0, max=5000 },
        { class="intedit", name="preset_start_miss_ms", value=currentConfig.preset_start_miss_ms, x=7, y=2, width=1, min=0, max=5000 },
        { class="label", label=L("cfg_lbl_preset_end"), x=4, y=3, width=2, height=1 },
        { class="intedit", name="preset_end_twin_ms", value=currentConfig.preset_end_twin_ms, x=6, y=3, width=1, min=0, max=5000 },
        { class="intedit", name="preset_end_miss_ms", value=currentConfig.preset_end_miss_ms, x=7, y=3, width=1, min=0, max=5000 },
        { class="label", label=L("cfg_lbl_preset_full_kf"), x=4, y=4, width=2, height=1 },
        { class="intedit", name="preset_full_twin_ms", value=currentConfig.preset_full_twin_ms, x=6, y=4, width=1, min=0, max=5000 },
        { class="intedit", name="preset_full_miss_ms", value=currentConfig.preset_full_miss_ms, x=7, y=4, width=1, min=0, max=5000 },
        { class="label", label=L("cfg_lbl_preset_full_time"), x=4, y=5, width=2, height=1 },
        { class="intedit", name="preset_full_short_ms", value=currentConfig.preset_full_short_ms, x=6, y=5, width=1, min=0, max=20000 },
        { class="intedit", name="preset_full_long_ms", value=currentConfig.preset_full_long_ms, x=7, y=5, width=1, min=0, max=60000 },
        { class="label", label=L("cfg_lbl_preset_full_read"), x=4, y=6, width=2, height=1 },
        { class="intedit", name="preset_full_max_cps", value=currentConfig.preset_full_max_cps, x=6, y=6, width=1, min=0, max=120 },
        { class="intedit", name="preset_full_max_width", value=currentConfig.preset_full_max_width, x=7, y=6, width=1, min=0, max=5000 },
        { class="label", label=L("cfg_lbl_preset_full_gap"), x=4, y=7, width=2, height=1 },
        { class="intedit", name="preset_full_short_gap_ms", value=currentConfig.preset_full_short_gap_ms, x=6, y=7, width=1, min=0, max=5000 },
        { class="intedit", name="preset_full_large_gap_ms", value=currentConfig.preset_full_large_gap_ms, x=7, y=7, width=1, min=0, max=30000 },
        { class="label", label=L("cfg_lbl_preset_duration"), x=4, y=8, width=2, height=1 },
        { class="intedit", name="preset_duration_short_ms", value=currentConfig.preset_duration_short_ms, x=6, y=8, width=1, min=0, max=20000 },
        { class="intedit", name="preset_duration_long_ms", value=currentConfig.preset_duration_long_ms, x=7, y=8, width=1, min=0, max=60000 },
        { class="label", label=L("cfg_lbl_preset_cps"), x=4, y=9, width=2, height=1 },
        { class="intedit", name="preset_cps_max", value=currentConfig.preset_cps_max, x=6, y=9, width=1, min=0, max=120 },
        { class="label", label=L("cfg_lbl_preset_overtime"), x=4, y=10, width=2, height=1 },
        { class="intedit", name="preset_overtime_ms", value=currentConfig.preset_overtime_ms, x=6, y=10, width=1, min=0, max=60000 },
        { class="label", label=L("cfg_lbl_preset_gaps"), x=4, y=11, width=2, height=1 },
        { class="intedit", name="preset_gap_short_ms", value=currentConfig.preset_gap_short_ms, x=6, y=11, width=1, min=0, max=5000 },
        { class="intedit", name="preset_gap_large_ms", value=currentConfig.preset_gap_large_ms, x=7, y=11, width=1, min=0, max=30000 },
        { class="label", label=L("scream_title"), x=4, y=13, width=4, height=1 },
        { class="label", label=L("scream_lbl_avg"), x=4, y=14, width=3, height=1 },
        { class="edit", name="scream_avg_db", value=tostring(currentConfig.scream_avg_db), x=7, y=14, width=2, height=1 },
        { class="label", label=L("scream_lbl_sample"), x=4, y=15, width=3, height=1 },
        { class="edit", name="scream_sample_db", value=tostring(currentConfig.scream_sample_db), x=7, y=15, width=2, height=1 },
        { class="label", label=L("scream_lbl_ratio"), x=4, y=16, width=3, height=1 },
        { class="intedit", name="scream_loud_ratio", value=currentConfig.scream_loud_ratio, x=7, y=16, width=2, min=0, max=100 },
        { class="label", label=L("scream_lbl_min"), x=4, y=17, width=3, height=1 },
        { class="intedit", name="scream_min_samples", value=currentConfig.scream_min_samples, x=7, y=17, width=2, min=1 },
        { class="label", label=L("scream_lbl_z"), x=4, y=18, width=3, height=1 },
        { class="edit", name="scream_robust_z", value=tostring(currentConfig.scream_robust_z), x=7, y=18, width=2, height=1 },
        { class="label", label=L("lbl_apply_to"), x=4, y=19, width=3, height=1 },
        { class="dropdown", name="scream_scope", items=cfgUi.scream_scope.items, value=cfgUi.scream_scope.value, x=7, y=19, width=2, height=1 },
        { class="checkbox", name="scream_clean_previous", label=L("scream_chk_clean"), value=currentConfig.scream_clean_previous, x=4, y=20, width=5, height=1 },
        { class="checkbox", name="scream_reuse_log", label=L("scream_chk_reuse"), value=currentConfig.scream_reuse_log, x=4, y=21, width=5, height=1 },
    }
    local pressed, result = aegisub.dialog.display(dlg, {L("btn_save"), L("btn_cancel")})
    if pressed == L("btn_save") then
        local old_lang = currentConfig.language
        result.language = UI.from(cfgUi.language, result.language)
        result.lazy_method = UI.from(cfgUi.lazy_method, result.lazy_method)
        result.lazy_tag_mode = UI.from(cfgUi.lazy_tag_mode, result.lazy_tag_mode)
        result.lazy_tag_scope = UI.from(cfgUi.lazy_tag_scope, result.lazy_tag_scope)
        result.scream_scope = UI.from(cfgUi.scream_scope, result.scream_scope)
        if result.scream_scope ~= "Selected lines" then result.scream_scope = "All dialogue" end
        result.scream_avg_db = tonumber(result.scream_avg_db) or currentConfig.scream_avg_db
        result.scream_sample_db = tonumber(result.scream_sample_db) or currentConfig.scream_sample_db
        result.scream_loud_ratio = math.max(0, math.min(100, tonumber(result.scream_loud_ratio) or currentConfig.scream_loud_ratio))
        result.scream_min_samples = math.max(1, tonumber(result.scream_min_samples) or currentConfig.scream_min_samples)
        result.scream_robust_z = math.max(0, tonumber(result.scream_robust_z) or currentConfig.scream_robust_z)
        for k, v in pairs(result) do currentConfig[k] = v end
        saveConfig(); resolveConfig(); showMsg(L("cfg_msg_saved"))
        if old_lang ~= currentConfig.language then showMsg(L("cfg_msg_lang_changed")) end
    end
end

local function normalizeString(v) if type(v)=="string" then return v end if v==nil then return "" end return tostring(v) end
local function normalizeNumber(v, fb) local n = tonumber(v); if n == nil then return fb end; return n end
local function escapeLuaPattern(t) return normalizeString(t):gsub("(%W)", "%%%1") end

local function splitUtf8Chars(text)
    local out = {}
    for c in normalizeString(text):gmatch(UTF8_CHAR_PATTERN) do out[#out+1] = c end
    return out
end
local function joinRange(chars, a, b) if a > b then return "" end; return table.concat(chars, "", a, b) end
local function unicodeLenSafe(t)
    local ok, n = pcall(unicode.len, normalizeString(t))
    if ok and type(n) == "number" then return n end
    return #splitUtf8Chars(t)
end
local function mapLatinFallback(text, mapping)
    local chars = splitUtf8Chars(text)
    for i, c in ipairs(chars) do chars[i] = mapping[c] or c end
    return table.concat(chars)
end
local function unicodeUpper(t)
    t = normalizeString(t)
    local ok, v = pcall(unicode.to_upper, t)
    if ok and type(v) == "string" then return mapLatinFallback(v, LATIN_LOWER_TO_UPPER) end
    return mapLatinFallback(string.upper(t), LATIN_LOWER_TO_UPPER)
end
local function unicodeLower(t)
    t = normalizeString(t)
    local ok, v = pcall(unicode.to_lower, t)
    if ok and type(v) == "string" then return mapLatinFallback(v, LATIN_UPPER_TO_LOWER) end
    return mapLatinFallback(string.lower(t), LATIN_UPPER_TO_LOWER)
end
local function unicodeSub(text, fromIdx, toIdx)
    text = normalizeString(text)
    if FunctionalUnicode and type(FunctionalUnicode.sub) == "function" then
        local ok, v = pcall(FunctionalUnicode.sub, text, fromIdx, toIdx)
        if ok and type(v) == "string" then return v end
    end
    local chars = splitUtf8Chars(text)
    local a = fromIdx or 1; local b = toIdx or #chars
    if a < 0 then a = #chars + a + 1 end
    if b < 0 then b = #chars + b + 1 end
    return joinRange(chars, a, b)
end
local function trimText(t)
    t = normalizeString(t)
    if FunctionalString and type(FunctionalString.trim) == "function" then
        local ok, v = pcall(FunctionalString.trim, t)
        if ok and type(v) == "string" then return v end
    end
    return (t:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function roundNumber(v, digits)
    if FunctionalMath and type(FunctionalMath.round) == "function" then
        local ok, r = pcall(FunctionalMath.round, v, digits or 0)
        if ok and type(r) == "number" then return r end
    end
    local m = 10 ^ (digits or 0)
    if v >= 0 then return math.floor(v*m + 0.5)/m end
    return math.ceil(v*m - 0.5)/m
end
local function isWhitespaceChar(c) return c == NBSP or (#c == 1 and c:match("^%s$") ~= nil) end
local function isPunctuationChar(c) return UTF8_PUNCTUATION_CHARS[c] == true or (#c == 1 and c:match("^%p$") ~= nil) end
local function isLetter(c)
    c = normalizeString(c); if c == "" then return false end
    return unicodeLower(c) ~= unicodeUpper(c)
end
local function startsWith(t, p) t = normalizeString(t); p = normalizeString(p); return p == "" or t:sub(1, #p) == p end
local function endsWith(t, s)   t = normalizeString(t); s = normalizeString(s); return s == "" or t:sub(-#s) == s end
local function countChar(text, target)
    local n = 0; for _, c in ipairs(splitUtf8Chars(text)) do if c == target then n = n + 1 end end; return n
end
local function countLiteral(text, lit)
    local _, n = normalizeString(text):gsub(escapeLuaPattern(lit), ""); return n
end

local function cloneLine(l)
    if type(l.copy) == "function" then return l:copy() end
    local d = { class = l.class or "dialogue" }
    for k, v in pairs(l) do
        if type(v) == "table" then
            d[k] = {}; for ki, vi in pairs(v) do d[k][ki] = vi end
        else
            d[k] = v
        end
    end
    setmetatable(d, getmetatable(l))
    return d
end

local function clockToMs(h, m, s, frac)
    local base = (tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)) * 1000
    if frac and frac ~= "" then return base + tonumber((frac .. "000"):sub(1, 3)) end
    return base
end

local function splitEventLine(line)
    local prefix = line:match("^(Dialogue):") or line:match("^(Comment):")
    if not prefix then return nil end
    local fields, startPos = {}, #prefix + 2
    for _ = 1, 9 do
        local comma = line:find(",", startPos, true); if not comma then return nil end
        fields[#fields+1] = line:sub(startPos, comma - 1); startPos = comma + 1
    end
    fields[10] = line:sub(startPos)
    return prefix, fields
end

local function msToAssTime(ms)
    local h = math.floor(ms / 3600000)
    local m = math.floor((ms % 3600000) / 60000)
    local s = math.floor((ms % 60000) / 1000)
    local cs = math.floor((ms % 1000) / 10)
    return string.format("%d:%02d:%02d.%02d", h, m, s, cs)
end
local function assTimeToMs(t)
    local h, m, s, cs = normalizeString(t):match("^%s*(%d+):(%d+):(%d+)%.(%d+)%s*$")
    if not h then return nil end
    return clockToMs(h, m, s, cs)
end

local function parseLine(lineOrText)
    if not ASS or type(ASS.parse) ~= "function" then return nil end
    local payload = lineOrText
    if type(lineOrText) == "string" then payload = { text = lineOrText, class = "dialogue" } end
    local ok, parsed = pcall(function() return ASS:parse(payload) end)
    if ok then return parsed end
    return nil
end

local function stripTags(text)
    text = normalizeString(text)
    if ASS and type(ASS.parse) == "function" then
        local parsed = parseLine(text)
        if parsed and parsed.stripTags and parsed.getString then
            local ok = pcall(function() parsed:stripTags() end)
            if ok then return parsed:getString() end
        end
    end
    return (text:gsub("(%b{})", function(b)
        return b:match("^%{%s*\\") and "" or b
    end))
end

local function stripComments(text)
    text = normalizeString(text)
    local parsed = parseLine(text)
    if parsed and parsed.stripComments and parsed.getString then
        local ok = pcall(function() parsed:stripComments() end)
        if ok then return parsed:getString() end
    end
    return text:gsub("{([^}]*)}", function(inner)
        if inner:match("^%s*\\") then return "{" .. inner .. "}" end
        return ""
    end)
end

local function visibleText(text) return stripComments(stripTags(text)):gsub("\\[Nnh]", " ") end

local function countCharacters(text)
    local n = 0
    for _, c in ipairs(splitUtf8Chars(visibleText(text))) do
        if not isWhitespaceChar(c) and not isPunctuationChar(c) then n = n + 1 end
    end
    return n
end

local function countWords(text)
    local n, inWord = 0, false
    for _, c in ipairs(splitUtf8Chars(visibleText(text))) do
        if not isWhitespaceChar(c) and not isPunctuationChar(c) then
            if not inWord then n = n + 1; inWord = true end
        else
            inWord = false
        end
    end
    return n
end

local function validateDuration(l) return l.end_time and l.start_time and l.end_time > l.start_time end

local function addTag(l, tag, force)
    if not l.effect then l.effect = "" end
    local clean = tag:gsub("[%[%]]", "")
    local pat = "%[" .. clean:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. "[^%]]*%]"
    if force or not l.effect:match(pat) then
        l.effect = (l.effect == "" and tag or l.effect .. " " .. tag)
    end
end

local function addEffectMarker(line, marker)
    marker = normalizeString(marker); if marker == "" then return end
    local effect = normalizeString(line.effect)
    if not effect:find(escapeLuaPattern(marker), 1) then
        line.effect = (effect == "" and marker or effect .. " " .. marker)
    end
end

local function isOverrideBlock(block) return normalizeString(block):match("^%{%s*\\") ~= nil end

local function mutateOverrideBlocks(text, blockMutator)
    text = normalizeString(text)
    local out, cursor = {}, 1
    for startIdx, block, endIdx in text:gmatch("()(%b{})()") do
        if startIdx > cursor then out[#out+1] = text:sub(cursor, startIdx - 1) end
        if isOverrideBlock(block) then out[#out+1] = blockMutator(block) else out[#out+1] = block end
        cursor = endIdx
    end
    out[#out+1] = text:sub(cursor)
    return table.concat(out)
end

local function hasOverridePattern(text, pattern)
    text = normalizeString(text)
    for block in text:gmatch("(%b{})") do
        if isOverrideBlock(block) and block:match(pattern) then return true end
    end
    return false
end

local function removeOverridePattern(text, pattern)
    return mutateOverrideBlocks(text, function(block)
        local inner = block:sub(2, -2):gsub(pattern, "")
        if inner:match("^%s*$") then return "" end
        return "{" .. inner .. "}"
    end)
end

local function insertOverrideAfterLeadingComments(text, tagBlock)
    text = normalizeString(text); local cursor = 1
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor)
        if not s or s ~= cursor then break end
        if isOverrideBlock(text:sub(s, e)) then break end
        cursor = e + 1
    end
    return text:sub(1, cursor - 1) .. tagBlock .. text:sub(cursor)
end

local function splitLeadingTagBlocks(text)
    text = normalizeString(text)
    local cursor, chunks = 1, {}
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor); if not s or s ~= cursor then break end
        local block = text:sub(s, e)
        if block:match("^%{%s*\\") then chunks[#chunks+1] = block else break end
        cursor = e + 1
    end
    return table.concat(chunks, ""), text:sub(cursor)
end

local function splitLeadingBraceBlocks(text)
    text = normalizeString(text)
    local cursor = 1
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor)
        if not s or s ~= cursor then break end
        cursor = e + 1
    end
    return text:sub(1, cursor - 1), text:sub(cursor)
end

local function extractLeadingTagBlocks(text)
    text = normalizeString(text)
    local cursor, chunks = 1, {}
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor); if not s or s ~= cursor then break end
        local block = text:sub(s, e)
        if block:match("^%{%s*\\") then chunks[#chunks+1] = block end
        cursor = e + 1
    end
    return table.concat(chunks, "")
end

local function extractEffectTagBlocks(effect)
    local tags = {}
    local rest = normalizeString(effect):gsub("%b{}", function(b)
        if b:match("^%{%s*\\") then tags[#tags+1] = b; return " " end
        return b
    end)
    return table.concat(tags, ""), trimText(rest:gsub("%s+", " "))
end

local function splitTrailingTagBlocks(text)
    text = trimText(text); local tags = {}
    while true do
        local s, e = text:find("%{%s*\\[^}]*%}%s*$"); if not s then break end
        table.insert(tags, 1, trimText(text:sub(s, e)))
        text = trimText(text:sub(1, s - 1))
    end
    return text, table.concat(tags, "")
end

local function mutateTextOutsideBlocks(text, sectionMutator)
    text = normalizeString(text)
    local out, cursor = {}, 1
    while cursor <= #text do
        local s, e = text:find("%b{}", cursor)
        if not s then out[#out+1] = sectionMutator(text:sub(cursor)); break end
        if s > cursor then out[#out+1] = sectionMutator(text:sub(cursor, s - 1)) end
        out[#out+1] = text:sub(s, e)
        cursor = e + 1
    end
    if #out == 0 then return sectionMutator("") end
    return table.concat(out)
end

local function mutateTextSections(line, sectionMutator)
    local parsed = parseLine(line)
    if parsed and parsed.callback and parsed.commit and ASS and ASS.Section then
        parsed:callback(function(section)
            if section.class == ASS.Section.Text then section.value = sectionMutator(section.value) end
        end)
        parsed:commit(); return true
    end
    line.text = mutateTextOutsideBlocks(line.text, sectionMutator)
    return false
end

local function isDialogue(l) return type(l) == "table" and (l.class == nil or l.class == "dialogue") end
local function isEditableDialogue(l) return isDialogue(l) and not l.comment end
local function isVectorDrawing(line)
    local text = normalizeString(line and line.text or "")
    if hasOverridePattern(text, "\\p[1-9]") then return true end
    return false
end

local function collectEditableSelection(subs, sel)
    local out = {}
    for _, i in ipairs(sel) do if isEditableDialogue(subs[i]) then out[#out+1] = i end end
    return out
end
local function collectEditableTextSelection(subs, sel)
    local out = {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isEditableDialogue(l) and not isVectorDrawing(l) then out[#out+1] = i end
    end
    return out
end
local function collectDialogueSelection(subs, sel)
    local out = {}; for _, i in ipairs(sel) do if isDialogue(subs[i]) then out[#out+1] = i end end; return out
end

local function getTargetedSelection(subs, sel, c)
    if not c or c.mode == "All Selected" then return sel end
    local f = {}
    for _, i in ipairs(sel) do
        local l = subs[i]; local m = false
        if isDialogue(l) then
            if     c.mode == "By Style"  and normalizeString(l.style) == normalizeString(c.value) then m = true
            elseif c.mode == "By Actor"  and normalizeString(l.actor) == normalizeString(c.value) then m = true
            elseif c.mode == "By Layer"  and (tonumber(l.layer) or 0) == tonumber(c.value) then m = true
            elseif c.mode == "By Effect" and normalizeString(l.effect):find(normalizeString(c.value), 1, true) then m = true
            end
        end
        if m then table.insert(f, i) end
    end
    return f
end

local auditLines, applyPreset, SINGLE_MARKER_ITEMS
local TextOperations, TagOperations, SmartOperations, TimingOperations, MarkerOperations
local cueTimer

local function getKeyframes()
    if aegisub and type(aegisub.keyframes) == "function" then
        local ok, k = pcall(aegisub.keyframes)
        if ok and type(k) == "table" then table.sort(k); return k end
    end
    return nil
end

local function msToFrame(ms)
    if aegisub and type(aegisub.frame_from_ms) == "function" then
        local ok, f = pcall(aegisub.frame_from_ms, ms); if ok and f then return f end
    end
    return nil
end

local function frameToMs(frame)
    if aegisub and type(aegisub.ms_from_frame) == "function" then
        local ok, ms = pcall(aegisub.ms_from_frame, frame); if ok and ms then return ms end
    end
    return nil
end

local function isOnKeyframe(ms, kfs)
    if not kfs then return false end
    local f = msToFrame(ms); if not f then return false end
    for _, k in ipairs(kfs) do if k == f then return true end; if k > f then break end end
    return false
end

local function hasKeyframeNearEdge(ms, kfs, rangeMs, direction, excludeEdgeFrame)
    if not kfs or rangeMs <= 0 then return false end
    local edgeFrame = msToFrame(ms)
    if not edgeFrame then return false end
    for _, k in ipairs(kfs) do
        if not (excludeEdgeFrame and k == edgeFrame) then
            local kMs = frameToMs(k)
            if kMs then
                local dist = math.abs(kMs - ms)
                if dist <= rangeMs then
                    if direction == "KF Both" or (direction == "KF Back" and k < edgeFrame) or (direction == "KF Forward" and k > edgeFrame) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

do
local AUDIT_MARKERS = {
    ["TOO-SHORT"]=true,["TOO-LONG"]=true,["ZERO-LENGTH"]=true,
    ["FAST-CPS"]=true,["SLOW-CPS"]=true,["DEFAULT-STYLE"]=true,
    ["THREE-LINES"]=true,["SHORT-LAST-LINE"]=true,["TOO-WIDE"]=true,
    ["BROKEN-TAG"]=true,["PUNCT-ERROR"]=true,["UNPAIRED-PUNCT"]=true,
    ["NO-END-PUNCT"]=true,["FINAL-COMMA"]=true,["OVERLAP"]=true,["SHORT-GAP"]=true,["LARGE-GAP"]=true,
    ["UPPERCASE"]=true,["EMPTY"]=true,["DRAWING"]=true,
    ["COMMENT"]=true,["TOO-LONG-TIME"]=true,
    ["END-ON-KF"]=true,["START-ON-KF"]=true,["NEAR-END-KF"]=true,["NEAR-START-KF"]=true,
    ["MISSED-END-KF"]=true,["MISSED-START-KF"]=true,
    ["ITALIC-ERROR"]=true,["PARENTHESES"]=true,["NAME-PREFIX"]=true,
    ["LINE-BREAK"]=true,["POSITION-TAG"]=true,["CLIP-TAG"]=true,["FADE-TAG"]=true,
    ["TRANSFORM-TAG"]=true,["KARAOKE-TAG"]=true,["COMMENT-BLOCK"]=true,["HAS-DIGITS"]=true,["HAS-CJK"]=true,
    ["FULL-ITALIC"]=true,["DOUBLE-SPACE"]=true,["EDGE-SPACE"]=true,
    ["REPLACED"]=true,["COMPLETE-SENTENCE"]=true,["POSSIBLE-JOIN"]=true,
    ["STRONG-EXCL"]=true,["STRONG-QUEST"]=true,["MIXED-EMPHASIS"]=true,["SEMICOLON"]=true,
    ["STUTTER"]=true,["SCREAM"]=true,
}

local function hasTerminalPunctuation(text)
    local chars = splitUtf8Chars(trimText(visibleText(text)))
    for i = #chars, 1, -1 do
        local c = chars[i]
        if isWhitespaceChar(c) or CLOSING_PUNCTUATION[c] then
        else
            return TERMINAL_PUNCTUATION[c] == true
        end
    end
    return true
end

local function hasFinalComma(text)
    local chars = splitUtf8Chars(trimText(visibleText(text)))
    for i = #chars, 1, -1 do
        local c = chars[i]
        if isWhitespaceChar(c) or CLOSING_PUNCTUATION[c] then
        else
            return c == ","
        end
    end
    return false
end

SmartOperations = SmartOperations or {}
SmartOperations.completeSentences = function(subs, sel)
    local function incomplete(text)
        local clean = trimText(visibleText(text))
        return clean ~= "" and (hasFinalComma(clean) or not hasTerminalPunctuation(clean))
    end
    local function startsLower(text)
        local chars = splitUtf8Chars(trimText(visibleText(text)))
        for _, c in ipairs(chars) do
            if isLetter(c) then return c == unicodeLower(c) end
        end
        return false
    end
    local function itemSort(a, b)
        if a.line.start_time == b.line.start_time then return a.index < b.index end
        return (a.line.start_time or 0) < (b.line.start_time or 0)
    end
    local function collectItems()
        local selected = {}
        for _, i in ipairs(sel or {}) do selected[i] = true end
        local all, picked = {}, {}
        for i = 1, #subs do
            local l = subs[i]
            if isEditableDialogue(l) and not isVectorDrawing(l) and l.start_time and l.end_time then
                local item = { index = i, line = l, selected = selected[i] == true }
                all[#all+1] = item
                if item.selected then picked[#picked+1] = item end
            end
        end
        table.sort(all, itemSort); table.sort(picked, itemSort)
        return all, picked
    end
    local function blockers(all, first, second)
        local out, spanStart, spanEnd = {}, first.line.start_time, second.line.end_time
        if second.line.start_time < spanStart then spanStart = second.line.start_time end
        if first.line.end_time > spanEnd then spanEnd = first.line.end_time end
        for _, item in ipairs(all) do
            if item.index ~= first.index and item.index ~= second.index then
                local s, e = item.line.start_time or 0, item.line.end_time or 0
                if s < spanEnd and e > spanStart then out[#out+1] = item.index end
            end
        end
        return out
    end
    local function joinParts(parts)
        local clean = {}
        for _, p in ipairs(parts) do
            local v = trimText(normalizeString(p):gsub("%s+", " "))
            if v ~= "" then clean[#clean+1] = v end
        end
        local t = table.concat(clean, " ")
        t = t:gsub("%s+", " "):gsub("%s+([,;:%)%.%!%?])", "%1"):gsub("([%(])%s+", "%1")
        t = t:gsub("(" .. INV_EXCLAMATION .. ")%s+", "%1"):gsub("(" .. INV_QUESTION .. ")%s+", "%1")
        return trimText(t)
    end
    local function markSuspect(first, second, extra)
        addEffectMarker(subs[first.index], "[POSSIBLE-JOIN]")
        addEffectMarker(subs[second.index], "[POSSIBLE-JOIN]")
        for _, idx in ipairs(extra or {}) do addEffectMarker(subs[idx], "[POSSIBLE-JOIN]") end
    end
    local function applyJoin(action)
        local first, second = subs[action.first], subs[action.second]
        local merged = cloneLine(first)
        local p1 = stripComments(stripTags(first.text))
        local p2 = stripComments(stripTags(second.text))
        merged.end_time = math.max(first.end_time or 0, second.end_time or 0)
        merged.text = extractLeadingTagBlocks(first.text) .. joinParts({ p1, p2 })
        addEffectMarker(merged, "[COMPLETE-SENTENCE]")
        subs[action.first] = merged
        subs.delete(action.second)
    end
    local function remap(deleteSet)
        local out = {}
        for _, i in ipairs(sel or {}) do
            if not deleteSet[i] then
                local shift = 0
                for d in pairs(deleteSet) do if d < i then shift = shift + 1 end end
                out[#out+1] = i - shift
            end
        end
        return #out > 0 and out or sel
    end

    sel = collectEditableTextSelection(subs, sel)
    if #sel < 2 then return sel end
    local all, picked = collectItems()
    local actions, deleteSet, used = {}, {}, {}
    for pos = 1, #picked - 1 do
        local first, second = picked[pos], picked[pos + 1]
        if not used[first.index] and not used[second.index] and incomplete(first.line.text) then
            local extra = blockers(all, first, second)
            local overlaps = (second.line.start_time or 0) < (first.line.end_time or 0)
            local canJoin = #extra == 0 and not overlaps and first.index < second.index and startsLower(second.line.text)
            if canJoin then
                actions[#actions+1] = { first = first.index, second = second.index }
                used[first.index], used[second.index] = true, true
            else
                markSuspect(first, second, extra)
            end
        end
    end
    table.sort(actions, function(a, b) return a.second > b.second end)
    for _, action in ipairs(actions) do applyJoin(action); deleteSet[action.second] = true end
    return #actions > 0 and remap(deleteSet) or sel
end

local function hasPunctuationBalanceIssue(text)
    local v = visibleText(text)
    if countChar(v, INV_QUESTION)        ~= countChar(v, "?")             then return true end
    if countChar(v, INV_EXCLAMATION)     ~= countChar(v, "!")             then return true end
    if countChar(v, "(")                 ~= countChar(v, ")")             then return true end
    if countChar(v, "[")                 ~= countChar(v, "]")             then return true end
    if countChar(v, "\"") % 2 ~= 0 then return true end
    if countChar(v, LEFT_DOUBLE_QUOTE)   ~= countChar(v, RIGHT_DOUBLE_QUOTE) then return true end
    if countChar(v, LEFT_SINGLE_QUOTE)   ~= countChar(v, RIGHT_SINGLE_QUOTE) then return true end
    return countChar(v, LEFT_GUILLEMET)  ~= countChar(v, RIGHT_GUILLEMET)
end

local function hasOrphanTag(text)
    text = normalizeString(text)
    if text:find("{}", 1, true) ~= nil or text:find("{\\}", 1, true) ~= nil or text:match("{%s*}") ~= nil then return true end
    local depth = 0
    for c in text:gmatch("[{}]") do
        if c == "{" then
            if depth > 0 then return true end
            depth = 1
        else
            if depth == 0 then return true end
            depth = 0
        end
    end
    return depth ~= 0
end

local function splitByLinebreak(text)
    local parts, last = {}, 1
    text = normalizeString(text)
    while true do
        local p, pe = text:find("\\[Nn]", last)
        if not p then parts[#parts+1] = text:sub(last); break end
        parts[#parts+1] = text:sub(last, p - 1); last = pe + 1
    end
    return parts
end

local function getLineWidth(text, style)
    local clean = visibleText(text)
    if aegisub and type(aegisub.text_extents) == "function" and type(style) == "table" then
        local ok, w = pcall(function() return aegisub.text_extents(style, clean) end)
        if ok and type(w) == "number" then return w end
    end
    return unicodeLenSafe(clean) * 15
end

local function hasDoubleItalics(text)
    text = normalizeString(text)
    local hasI1, hasI0 = false, false
    for block in text:gmatch("{([^}]*)}") do
        if block:sub(1, 1) == "\\" or block:find("^%s*\\") then
            if block:find("\\i1%f[%D]") then hasI1 = true end
            if block:find("\\i0%f[%D]") then hasI0 = true end
        end
    end
    return hasI1 and hasI0
end

local function hasParenthesesPair(text)
    local clean = visibleText(text)
    return clean:find("%(") ~= nil and clean:find("%)") ~= nil
end

local function hasNamePrefix(text)
    return visibleText(text):match("^%[.-%]:") ~= nil
end

local function tagBlockContains(text, pattern)
    text = normalizeString(text)
    for block in text:gmatch("{([^}]*)}") do
        if block:sub(1,1) == "\\" and block:find(pattern) then return true end
    end
    return false
end

local function hasLineBreakTag(text)  return normalizeString(text):find("\\[Nn]") ~= nil end
local function hasPosTag(text)        return tagBlockContains(text, "\\pos%(") or tagBlockContains(text, "\\move%(") end
local function hasClipTag(text)       return tagBlockContains(text, "\\i?clip%(") end
local function hasFadeTag(text)       return tagBlockContains(text, "\\fade?%(") end
local function hasTransformTag(text)  return tagBlockContains(text, "\\t%(") end
local function hasKaraokeTag(text)    return tagBlockContains(text, "\\[kK][fo]?%d") end
local function hasCommentBlock(text)
    text = normalizeString(text)
    for block in text:gmatch("{([^}]*)}") do
        local trimmed = block:gsub("^%s+", "")
        if trimmed ~= "" and trimmed:sub(1,1) ~= "\\" then return true end
    end
    return false
end
local function hasNumeric(text)         return visibleText(text):find("%d") ~= nil end
local function hasDoubleSpaceText(text) return stripTags(text):find("[ \t][ \t]") ~= nil end
local function hasEdgeSpace(text)
    local s = stripTags(text); if s == "" then return false end
    return s:match("^[ \t]") ~= nil or s:match("[ \t]$") ~= nil
end
local function hasCJKChars(text) return visibleText(text):find("[\227-\237]") ~= nil end

local function wordHasAny(word, needles)
    for _, n in ipairs(needles) do if word:find(n, 1, true) then return true end end
    return false
end

local function hasStrongExclamation(text)
    local clean = visibleText(text)
    for word in clean:gmatch("%S+") do
        if wordHasAny(word, { INV_EXCLAMATION }) and wordHasAny(word, { "!", FULLWIDTH_EXCLAMATION }) then
            return true
        end
    end
    return false
end

local function hasStrongQuestion(text)
    local clean = visibleText(text)
    for word in clean:gmatch("%S+") do
        if wordHasAny(word, { INV_QUESTION }) and wordHasAny(word, { "?", FULLWIDTH_QUESTION }) then
            return true
        end
    end
    return false
end

local function hasMixedEmphasis(text)
    local clean = visibleText(text)
    for word in clean:gmatch("%S+") do
        local hasOpenE = wordHasAny(word, { INV_EXCLAMATION })
        local hasOpenQ = wordHasAny(word, { INV_QUESTION })
        local hasCloseE = wordHasAny(word, { "!", FULLWIDTH_EXCLAMATION })
        local hasCloseQ = wordHasAny(word, { "?", FULLWIDTH_QUESTION })
        if (hasOpenE and hasOpenQ) or (hasCloseE and hasCloseQ) then return true end
    end
    return false
end

local function hasSemicolon(text)
    local clean = visibleText(text)
    return clean:find(";", 1, true) ~= nil or clean:find(FULLWIDTH_SEMICOLON, 1, true) ~= nil
end

local function hasStutter(text)
    local clean = visibleText(text)
    for word in clean:gmatch("%S+") do
        local chars = splitUtf8Chars(word)
        for i = 1, #chars - 2 do
            if chars[i+1] == "-" and isLetter(chars[i]) and isLetter(chars[i+2])
               and unicodeLower(chars[i]) == unicodeLower(chars[i+2]) then
                return true
            end
        end
    end
    return false
end

local function isFullItalic(text)
    text = normalizeString(text)
    local first = text:match("^{([^}]*)}")
    if not first or not first:find("\\i1") then return false end
    for block in text:gmatch("{([^}]*)}") do
        if block:find("\\i0") then return false end
    end
    return true
end

local function countSentences(text)
    local clean = visibleText(text)
    local chars = splitUtf8Chars(clean)
    local count, i = 0, 1
    while i <= #chars do
        local c = chars[i]
        local isEnd = (c == "." or c == "?" or c == "!" or c == HORIZONTAL_ELLIPSIS)
        if isEnd then
            count = count + 1
            while i + 1 <= #chars do
                local nx = chars[i + 1]
                if nx == "." or nx == "?" or nx == "!" or nx == HORIZONTAL_ELLIPSIS or CLOSING_PUNCTUATION[nx] then
                    i = i + 1
                else break end
            end
        end
        i = i + 1
    end
    if count == 0 and #chars > 0 then count = 1 end
    return count
end

local function isUppercaseText(text)
    local letters = 0
    for _, c in ipairs(splitUtf8Chars(visibleText(text))) do
        if isLetter(c) then
            letters = letters + 1
            if c ~= unicodeUpper(c) then return false end
        end
    end
    return letters >= 2
end

local function cleanAuditMarkers(effect)
    effect = normalizeString(effect)
    effect = effect:gsub("%[([^%]]+)%]", function(key)
        local base = key:match("^(%S+)") or key
        if AUDIT_MARKERS[base] or key:match("^%d+%-SENTENCES$") then return " " end
        return "[" .. key .. "]"
    end)
    return trimText(effect:gsub("%s+", " "))
end

local function auditMarkerKey(marker)
    marker = normalizeString(marker)
    local key = marker:match("^%[([^%]]+)%]$") or marker
    return key:match("^(%S+)") or key
end

local function gapMarker(kind, gap)
    return string.format("[%s %dms]", kind, math.floor((tonumber(gap) or 0) + 0.5))
end

local function applyIssues(line, issues, clearOld, allowDuplicate)
    local effect = clearOld and cleanAuditMarkers(line.effect) or normalizeString(line.effect)
    local seen, existingCounts = {}, {}
    effect:gsub("%[([^%]]+)%]", function(k)
        local key = auditMarkerKey(k)
        seen[key] = true
        existingCounts[key] = (existingCounts[key] or 0) + 1
    end)
    local issueCounts = {}
    for _, marker in ipairs(issues) do
        local key = auditMarkerKey(marker)
        if key ~= "" then issueCounts[key] = (issueCounts[key] or 0) + 1 end
    end
    local markers = {}
    for _, marker in ipairs(issues) do
        local key = auditMarkerKey(marker)
        if key ~= "" then
            if allowDuplicate and allowDuplicate[key] then
                local existing = existingCounts[key] or 0
                if issueCounts[key] > existing then
                    markers[#markers+1] = marker
                    existingCounts[key] = existing + 1
                end
            elseif not seen[key] then
                markers[#markers+1] = marker
                seen[key] = true
            end
        end
    end
    local prefix = table.concat(markers, " ")
    if prefix ~= "" and effect ~= "" then line.effect = prefix .. " " .. effect
    elseif prefix ~= "" then               line.effect = prefix
    else                                   line.effect = effect end
end

local function addIssue(issues, marker) issues[#issues+1] = marker end

local function collectHead(subs)
    if karaskel and type(karaskel.collect_head) == "function" then
        local ok, meta, styles = pcall(karaskel.collect_head, subs, false)
        if ok then return meta, styles or {} end
    end
    return nil, {}
end
local function preprocLine(subs, meta, styles, line)
    if karaskel and type(karaskel.preproc_line) == "function" then
        pcall(karaskel.preproc_line, subs, meta, styles, line)
    end
end

local function buildAdjacentSelection(subs, sel)
    local selected = {}
    for _, i in ipairs(sel) do selected[i] = true end
    local items = {}
    for i = 1, #subs do
        local l = subs[i]
        if isEditableDialogue(l) and l.start_time and l.end_time then
            items[#items+1] = { index = i, line = l, selected = selected[i] == true }
        end
    end
    table.sort(items, function(a, b)
        if a.line.start_time == b.line.start_time then return a.index < b.index end
        return (a.line.start_time or 0) < (b.line.start_time or 0)
    end)
    return items
end

SINGLE_MARKER_ITEMS = {
    "", "Number Effects","Add Identifier",
    "UPPERCASE","THREE-LINES","NO-END-PUNCT","FINAL-COMMA","UNPAIRED-PUNCT",
    "SHORT-LAST-LINE","TOO-WIDE","BROKEN-TAG","OVERLAP","DEFAULT-STYLE",
    "ITALIC-ERROR","PARENTHESES","NAME-PREFIX","MULTI-SENTENCE",
    "STRONG-EXCL","STRONG-QUEST","MIXED-EMPHASIS","SEMICOLON","STUTTER",
    "LINE-BREAK","POSITION-TAG","CLIP-TAG","FADE-TAG","TRANSFORM-TAG","KARAOKE-TAG",
    "COMMENT-BLOCK","HAS-DIGITS","HAS-CJK","FULL-ITALIC","DOUBLE-SPACE","EDGE-SPACE",
}
local SINGLE_TO_CHECKS = {
    ["UPPERCASE"]={"check_uppercase"},     ["THREE-LINES"]={"check_3liner"},
    ["NO-END-PUNCT"]={"check_missing_punct"}, ["FINAL-COMMA"]={"check_final_comma"},
    ["UNPAIRED-PUNCT"]={"check_punct_balance"},
    ["SHORT-LAST-LINE"]={"check_orphan_word"}, ["BROKEN-TAG"]={"check_orphan_tag"},
    ["OVERLAP"]={"check_overlap"},         ["DEFAULT-STYLE"]={"check_unstyled"},
    ["ITALIC-ERROR"]={"check_double_italics"},     ["PARENTHESES"]={"check_parentheses"},
    ["NAME-PREFIX"]={"check_name_prefix"},        ["MULTI-SENTENCE"]={"check_sentences"},
    ["TOO-WIDE"]={"check_needs_split"},
    ["STRONG-EXCL"]={"check_strong_excl"}, ["STRONG-QUEST"]={"check_strong_quest"},
    ["MIXED-EMPHASIS"]={"check_mixed_emphasis"}, ["SEMICOLON"]={"check_semicolon"},
    ["STUTTER"]={"check_stutter"},
    ["LINE-BREAK"]={"check_has_n"},   ["POSITION-TAG"]={"check_has_pos"},
    ["CLIP-TAG"]={"check_has_clip"}, ["FADE-TAG"]={"check_has_fad"},
    ["TRANSFORM-TAG"]={"check_has_t"},   ["KARAOKE-TAG"]={"check_has_k"},
    ["COMMENT-BLOCK"]={"check_has_comment"}, ["HAS-DIGITS"]={"check_has_num"},
    ["HAS-CJK"]={"check_has_cjk"}, ["FULL-ITALIC"]={"check_full_italic"},
    ["DOUBLE-SPACE"]={"check_dbl_space"}, ["EDGE-SPACE"]={"check_edge_space"},
}
local function applySingleMarkerOverride(config)
    local sm = config.single_marker; if not sm or sm == "" then return end
    local allChecks = {
        "check_uppercase","check_3liner","check_missing_punct","check_final_comma","check_punct_balance",
        "check_orphan_word","check_orphan_tag","check_overlap","check_unstyled",
        "check_double_italics","check_parentheses","check_name_prefix","check_sentences",
        "check_needs_split","check_empty",
        "check_strong_excl","check_strong_quest","check_mixed_emphasis","check_semicolon","check_stutter",
        "check_has_n","check_has_pos","check_has_clip","check_has_fad",
        "check_has_t","check_has_k","check_has_comment","check_has_num",
        "check_has_cjk","check_full_italic","check_dbl_space","check_edge_space",
    }
    for _, k in ipairs(allChecks) do config[k] = false end
    config.short_ms = 0
    config.long_ms = 0
    config.overtime_ms = 0
    config.max_cps = 0
    config.min_cps = 0
    config.gap_ms = 0
    config.large_gap_ms = 0
    config.kf_seal = false
    config.twin_kf_ms = 0
    config.miss_kf_ms = 0
    config.kf_dir = ""
    local checks = SINGLE_TO_CHECKS[sm]
    if checks then for _, k in ipairs(checks) do config[k] = true end end
end

local function presetNumber(key)
    return tonumber(currentConfig and currentConfig[key]) or tonumber(DEFAULT_CONFIG[key]) or 0
end

function applyPreset(result, preset)
    result.short_ms = 0; result.long_ms = 0; result.overtime_ms = 0
    result.min_cps = 0; result.max_cps = 0; result.gap_ms = 0; result.large_gap_ms = 0
    result.max_width = 0
    result.kf_seal = false; result.twin_kf_ms = 0; result.miss_kf_ms = 0; result.kf_mode = ""; result.kf_dir = ""
    result.check_uppercase=false; result.check_3liner=false; result.check_missing_punct=false; result.check_final_comma=false
    result.check_punct_balance=false; result.check_orphan_word=false; result.check_orphan_tag=false
    result.check_overlap=false; result.check_unstyled=false; result.check_double_italics=false
    result.check_parentheses=false; result.check_name_prefix=false; result.check_sentences=false
    result.check_needs_split=false; result.check_empty=false; result.check_dbl_space=false; result.check_edge_space=false
    result.check_strong_excl=false; result.check_strong_quest=false; result.check_mixed_emphasis=false; result.check_semicolon=false
    result.check_stutter=false
    if preset == "Ends Only" then
        result.twin_kf_ms = presetNumber("preset_end_twin_ms"); result.miss_kf_ms = presetNumber("preset_end_miss_ms"); result.kf_mode = "End Only"; result.kf_dir = "KF Back"
    elseif preset == "Start Only" then
        result.twin_kf_ms = presetNumber("preset_start_twin_ms"); result.miss_kf_ms = presetNumber("preset_start_miss_ms"); result.kf_mode = "Start Only"; result.kf_dir = "KF Back"
    elseif preset == "Full Audit" then
        result.twin_kf_ms = presetNumber("preset_full_twin_ms"); result.miss_kf_ms = presetNumber("preset_full_miss_ms"); result.kf_mode = "Both"; result.kf_dir = "KF Back"
        result.short_ms = presetNumber("preset_full_short_ms"); result.long_ms = presetNumber("preset_full_long_ms"); result.max_cps = presetNumber("preset_full_max_cps"); result.gap_ms = presetNumber("preset_full_short_gap_ms"); result.large_gap_ms = presetNumber("preset_full_large_gap_ms"); result.max_width = presetNumber("preset_full_max_width")
        result.check_uppercase = true;     result.check_3liner = true
        result.check_missing_punct = true; result.check_punct_balance = true
        result.check_orphan_word = true;   result.check_orphan_tag = true
        result.check_overlap = true;       result.check_unstyled = true
        result.check_double_italics = true;result.check_parentheses = true
        result.check_name_prefix = true;   result.check_sentences = true
        result.check_needs_split = true;   result.check_empty = true
        result.check_dbl_space = true;     result.check_edge_space = true
    elseif preset == "Overtime" then
        result.overtime_ms = presetNumber("preset_overtime_ms")
    elseif preset == "Duration" then
        result.short_ms = presetNumber("preset_duration_short_ms"); result.long_ms = presetNumber("preset_duration_long_ms")
    elseif preset == "CPS" then
        result.max_cps = presetNumber("preset_cps_max")
    elseif preset == "Short Gaps" then
        result.gap_ms = presetNumber("preset_gap_short_ms")
    elseif preset == "Large Gaps" then
        result.large_gap_ms = presetNumber("preset_gap_large_ms")
    elseif preset == "Both Gaps" or preset == "Gaps" then
        result.gap_ms = presetNumber("preset_gap_short_ms"); result.large_gap_ms = presetNumber("preset_gap_large_ms")
    end
    return result
end

function auditLines(subs, sel, config)
    config = config or {}
    if config.single_marker == "Number Effects" then
        MarkerOperations.numberEffects(subs, sel)
        return
    elseif config.single_marker == "Add Identifier" then
        MarkerOperations.randomEffects(subs, sel)
        return
    end
    config.gap_ms      = math.min(math.max(tonumber(config.gap_ms) or 0, 0), 5000)
    config.large_gap_ms= math.min(math.max(tonumber(config.large_gap_ms) or 0, 0), 30000)
    config.short_ms    = tonumber(config.short_ms)    or 0
    config.long_ms     = tonumber(config.long_ms)     or 0
    config.max_cps     = tonumber(config.max_cps)     or 0
    config.min_cps     = tonumber(config.min_cps)     or 0
    config.max_width   = tonumber(config.max_width)   or 0
    config.clear_old   = config.clear_old ~= false
    config.overtime_ms = tonumber(config.overtime_ms) or 0
    config.twin_kf_ms  = tonumber(config.twin_kf_ms)  or 0
    config.miss_kf_ms  = tonumber(config.miss_kf_ms)  or 0
    config.kf_seal     = config.kf_seal or false
    config.kf_mode     = config.kf_mode or ""
    config.kf_dir      = config.kf_dir or ""
    config.gap_mark_continuous = config.gap_mark_continuous or false
    config.gap_ignore_kf       = config.gap_ignore_kf       or false

    applySingleMarkerOverride(config)

    local meta, styles = collectHead(subs)
    local kfs = getKeyframes()
    local activeKfMode = config.kf_mode ~= "" and config.kf_mode or ((config.kf_seal or config.twin_kf_ms > 0 or config.miss_kf_ms > 0) and "Both" or "")
    local activeKfDir = config.kf_dir ~= "" and config.kf_dir or "KF Back"
    local checkEnd   = (activeKfMode == "End Only"   or activeKfMode == "Both")
    local checkStart = (activeKfMode == "Start Only" or activeKfMode == "Both")
    local stats, linesWithIssues = {}, 0
    local selectedSet, issueMap = {}, {}
    for _, index in ipairs(sel) do selectedSet[index] = true; issueMap[index] = {} end
    local relationalMarkers = { ["OVERLAP"]=true, ["SHORT-GAP"]=true, ["LARGE-GAP"]=true }
    local function queueIssue(index, marker)
        if selectedSet[index] then
            issueMap[index] = issueMap[index] or {}
            issueMap[index][#issueMap[index]+1] = marker
        end
    end
    local function queueIssues(index, issues)
        for _, marker in ipairs(issues) do queueIssue(index, marker) end
    end

    for _, index in ipairs(sel) do
        local line = subs[index]
        if isDialogue(line) then
            preprocLine(subs, meta, styles, line)
            local issues = {}
            local duration = (tonumber(line.end_time) or 0) - (tonumber(line.start_time) or 0)

            if line.comment then
                addIssue(issues, "[COMMENT]")
                queueIssues(index, issues)
            else
                local drawing = isVectorDrawing(line)
                local clean = visibleText(line.text)

                if duration <= 0 then
                    addIssue(issues, "[ZERO-LENGTH]")
                elseif not drawing then
                    if config.short_ms > 0 and duration < config.short_ms then addIssue(issues, "[TOO-SHORT]") end
                    if config.long_ms > 0 and duration > config.long_ms  then addIssue(issues, "[TOO-LONG]")  end
                    if config.overtime_ms > 0 and duration > config.overtime_ms then
                        addIssue(issues, "[TOO-LONG-TIME]")
                    end
                    local cps = countCharacters(line.text) / (duration / 1000)
                    if config.max_cps > 0 and cps > config.max_cps then addIssue(issues, "[FAST-CPS]") end
                    if config.min_cps > 0 and cps < config.min_cps then addIssue(issues, "[SLOW-CPS]") end
                end

                if kfs then
                    if config.kf_seal then
                        if checkEnd   and isOnKeyframe(line.end_time,   kfs) then addIssue(issues, "[END-ON-KF]") end
                        if checkStart and isOnKeyframe(line.start_time, kfs) then addIssue(issues, "[START-ON-KF]") end
                    end
                    if config.twin_kf_ms > 0 then
                        if checkEnd and isOnKeyframe(line.end_time, kfs) then
                            if hasKeyframeNearEdge(line.end_time, kfs, config.twin_kf_ms, activeKfDir, true) then addIssue(issues, "[NEAR-END-KF]") end
                        end
                        if checkStart and isOnKeyframe(line.start_time, kfs) then
                            if hasKeyframeNearEdge(line.start_time, kfs, config.twin_kf_ms, activeKfDir, true) then addIssue(issues, "[NEAR-START-KF]") end
                        end
                    end
                    if config.miss_kf_ms > 0 then
                        if checkEnd and not isOnKeyframe(line.end_time, kfs) then
                            if hasKeyframeNearEdge(line.end_time, kfs, config.miss_kf_ms, activeKfDir, false) then addIssue(issues, "[MISSED-END-KF]") end
                        end
                        if checkStart and not isOnKeyframe(line.start_time, kfs) then
                            if hasKeyframeNearEdge(line.start_time, kfs, config.miss_kf_ms, activeKfDir, false) then addIssue(issues, "[MISSED-START-KF]") end
                        end
                    end
                end

                if not drawing and normalizeString(line.style) == "Default" then
                    if config.check_unstyled ~= false then addIssue(issues, "[DEFAULT-STYLE]") end
                end

                if drawing then
                    addIssue(issues, "[DRAWING]")
                else
                    if trimText(clean) == "" then
                        if config.check_empty ~= false then addIssue(issues, "[EMPTY]") end
                    else
                        if config.check_uppercase ~= false and isUppercaseText(clean) then addIssue(issues, "[UPPERCASE]") end
                        if config.check_missing_punct ~= false and not hasTerminalPunctuation(clean) then addIssue(issues, "[NO-END-PUNCT]") end
                        if config.check_final_comma == true and hasFinalComma(clean) then addIssue(issues, "[FINAL-COMMA]") end
                    end

                    local parts = splitByLinebreak(line.text)
                    if #parts >= 3 then
                        if config.check_3liner ~= false then addIssue(issues, "[THREE-LINES]") end
                    elseif #parts == 2 then
                        local lastPart = parts[#parts]
                        if config.check_orphan_word ~= false and (countWords(lastPart) <= 1 or countCharacters(lastPart) < 4) then
                            addIssue(issues, "[SHORT-LAST-LINE]")
                        end
                    else
                        local style = line.styleref or styles[normalizeString(line.style)] or line.style
                        if config.max_width > 0 and getLineWidth(line.text, style) > config.max_width then
                            if config.check_needs_split ~= false then addIssue(issues, "[TOO-WIDE]") end
                        end
                    end

                    if config.check_orphan_tag    ~= false and hasOrphanTag(line.text)         then addIssue(issues, "[BROKEN-TAG]") end
                    if config.check_punct_balance ~= false and hasPunctuationBalanceIssue(line.text) then addIssue(issues, "[UNPAIRED-PUNCT]") end
                    if config.check_double_italics ~= false and hasDoubleItalics(line.text)    then addIssue(issues, "[ITALIC-ERROR]") end
                    if config.check_parentheses    ~= false and hasParenthesesPair(line.text)  then addIssue(issues, "[PARENTHESES]") end
                    if config.check_name_prefix    ~= false and hasNamePrefix(line.text)       then addIssue(issues, "[NAME-PREFIX]") end
                    if config.check_sentences      ~= false then
                        local sc = countSentences(clean)
                        if sc >= 2 then addIssue(issues, "[" .. sc .. "-SENTENCES]") end
                    end

                    if config.check_has_n     and hasLineBreakTag(line.text) then addIssue(issues, "[LINE-BREAK]") end
                    if config.check_has_pos   and hasPosTag(line.text)       then addIssue(issues, "[POSITION-TAG]") end
                    if config.check_has_clip  and hasClipTag(line.text)      then addIssue(issues, "[CLIP-TAG]") end
                    if config.check_has_fad   and hasFadeTag(line.text)      then addIssue(issues, "[FADE-TAG]") end
                    if config.check_has_t     and hasTransformTag(line.text) then addIssue(issues, "[TRANSFORM-TAG]") end
                    if config.check_has_k     and hasKaraokeTag(line.text)   then addIssue(issues, "[KARAOKE-TAG]") end
                    if config.check_has_comment and hasCommentBlock(line.text) then addIssue(issues, "[COMMENT-BLOCK]") end
                    if config.check_has_num   and hasNumeric(line.text)      then addIssue(issues, "[HAS-DIGITS]") end
                    if config.check_has_cjk   and hasCJKChars(line.text)     then addIssue(issues, "[HAS-CJK]") end
                    if config.check_full_italic and isFullItalic(line.text)  then addIssue(issues, "[FULL-ITALIC]") end

                    if config.check_dbl_space  ~= false and hasDoubleSpaceText(line.text) then addIssue(issues, "[DOUBLE-SPACE]") end
                    if config.check_edge_space ~= false and hasEdgeSpace(line.text)       then addIssue(issues, "[EDGE-SPACE]") end

                    if config.check_strong_excl     and hasStrongExclamation(clean) then addIssue(issues, "[STRONG-EXCL]") end
                    if config.check_strong_quest    and hasStrongQuestion(clean)    then addIssue(issues, "[STRONG-QUEST]") end
                    if config.check_mixed_emphasis  and hasMixedEmphasis(clean)     then addIssue(issues, "[MIXED-EMPHASIS]") end
                    if config.check_semicolon       and hasSemicolon(line.text)     then addIssue(issues, "[SEMICOLON]") end
                    if config.check_stutter         and hasStutter(clean)           then addIssue(issues, "[STUTTER]") end
                end

                queueIssues(index, issues)
            end
        end
    end

    local adjacent = buildAdjacentSelection(subs, sel)
    for i = 1, #adjacent - 1 do
        local prev, line = adjacent[i], adjacent[i + 1]
        if prev.selected or line.selected then
            local gap = (tonumber(line.line.start_time) or 0) - (tonumber(prev.line.end_time) or 0)
            if gap < 0 then
                if config.check_overlap ~= false then
                    queueIssue(prev.index, "[OVERLAP]")
                    queueIssue(line.index, "[OVERLAP]")
                end
            elseif gap == 0 and config.gap_mark_continuous then
                local marker = gapMarker("SHORT-GAP", gap)
                queueIssue(prev.index, marker)
                queueIssue(line.index, marker)
            elseif config.gap_ms > 0 and gap > 0 and gap <= config.gap_ms then
                if not (config.gap_ignore_kf and kfs and isOnKeyframe(prev.line.end_time, kfs)) then
                    local marker = gapMarker("SHORT-GAP", gap)
                    queueIssue(prev.index, marker)
                    queueIssue(line.index, marker)
                end
            elseif config.large_gap_ms > 0 and gap > config.large_gap_ms then
                local marker = gapMarker("LARGE-GAP", gap)
                queueIssue(prev.index, marker)
                queueIssue(line.index, marker)
            end
        end
    end

    for _, index in ipairs(sel) do
        local issues = issueMap[index] or {}
        if #issues > 0 and isDialogue(subs[index]) then
            linesWithIssues = linesWithIssues + 1
            for _, iss in ipairs(issues) do stats[iss] = (stats[iss] or 0) + 1 end
            local line = subs[index]
            applyIssues(line, issues, config.clear_old, relationalMarkers)
            subs[index] = line
        end
    end

    local statList = {}
    for marker, count in pairs(stats) do table.insert(statList, marker .. ": " .. count) end
    table.sort(statList)
    local msg = string.format(L("msg_audit_done"), #sel, linesWithIssues,
                              #statList > 0 and table.concat(statList, "\n") or "—")
    showMsg(msg)
end

end

do
TextOperations   = {}
SmartOperations  = SmartOperations or {}
TagOperations    = {}
TimingOperations = {}
MarkerOperations = {}

local function remapSelectionAfterDeletion(originalSel, deleteSet)
    local delSorted = {}
    for k in pairs(deleteSet or {}) do delSorted[#delSorted+1] = k end
    table.sort(delSorted)
    local sortedSel = {}
    for _, v in ipairs(originalSel or {}) do sortedSel[#sortedSel+1] = v end
    table.sort(sortedSel)
    local newSel = {}
    for _, i in ipairs(sortedSel) do
        if not (deleteSet and deleteSet[i]) then
            local shift = 0
            for _, d in ipairs(delSorted) do
                if d < i then shift = shift + 1 else break end
            end
            newSel[#newSel+1] = i - shift
        end
    end
    if #newSel == 0 and #sortedSel > 0 then
        local first = sortedSel[1]
        for _, d in ipairs(delSorted) do
            if d < first then first = first - 1 end
        end
        newSel[1] = math.max(1, first)
    end
    return newSel
end

local function remapSelectionAfterInsertion(originalSel, insertedByIndex)
    local asc = {}
    for _, v in ipairs(originalSel or {}) do asc[#asc+1] = v end
    table.sort(asc)
    local newSel, shift = {}, 0
    for _, i in ipairs(asc) do
        local n = insertedByIndex[i] or 0
        for k = 0, n do newSel[#newSel+1] = i + shift + k end
        shift = shift + n
    end
    return newSel
end

function MarkerOperations.appendEffectText(line, value)
    value = trimText(value)
    if value == "" then return end
    local effect = trimText(line.effect)
    line.effect = effect == "" and value or effect .. " " .. value
end

function MarkerOperations.effectNumber(line)
    local effect = normalizeString(line and line.effect or "")
    for sign, num in effect:gmatch("(%-?)(%d+)") do
        if #num ~= 14 then return tonumber(sign .. num) end
    end
    return nil
end

function MarkerOperations.effectRandomNumber(line)
    return normalizeString(line and line.effect or ""):match("%f[%d](%d%d%d%d%d%d%d%d%d%d%d%d%d%d)%f[%D]")
end

function MarkerOperations.normalizeEffectTagSeparators(tags)
    return normalizeString(tags):gsub("%b{}", function(block)
        if block:match("^%{%s*\\") then return block:gsub(";", ",") end
        return block
    end)
end

local function hasVisibleSegmentText(text)
    local clean = stripComments(stripTags(text)):gsub("\\N", " ")
    for _, c in ipairs(splitUtf8Chars(clean)) do
        if not isWhitespaceChar(c) then return true end
    end
    return false
end

local function ensureInheritedTags(segment, tags)
    segment = trimText(segment); tags = normalizeString(tags)
    if segment == "" then return "" end
    if tags ~= "" and not startsWith(segment, tags) then return tags .. segment end
    return segment
end

local function joinTextParts(parts)
    local clean = {}
    for _, p in ipairs(parts) do
        local v = trimText(normalizeString(p):gsub("%s+", " "))
        if v ~= "" then clean[#clean+1] = v end
    end
    local t = table.concat(clean, " ")
    t = t:gsub("%s+", " ")
    t = t:gsub("%s+([,;:%)%.%!%?])", "%1")
    t = t:gsub("([%(])%s+", "%1")
    t = t:gsub("(" .. INV_EXCLAMATION .. ")%s+", "%1")
    t = t:gsub("(" .. INV_QUESTION .. ")%s+", "%1")
    return trimText(t)
end

local function textToTitleCase(value)
    local chars = splitUtf8Chars(unicodeLower(value))
    local inWord = false
    local i = 1
    while i <= #chars do
        local c = chars[i]
        if c == "\\" and (chars[i+1] == "N" or chars[i+1] == "n") then
            inWord = false
            i = i + 2
        elseif isLetter(c) then
            if not inWord then chars[i] = unicodeUpper(c) end
            inWord = true
            i = i + 1
        elseif isWhitespaceChar(c) or isPunctuationChar(c) or c == "-" then
            inWord = false
            i = i + 1
        else
            i = i + 1
        end
    end
    return table.concat(chars)
end

local function textToSentenceCase(value)
    local chars = splitUtf8Chars(unicodeLower(value))
    local pending = true
    for i, c in ipairs(chars) do
        if isLetter(c) then
            if pending then chars[i] = unicodeUpper(c); pending = false end
        elseif SENTENCE_SPLIT_CHARS[c] or c == "?" or c == "!" then
            pending = true
        elseif c == INV_QUESTION or c == INV_EXCLAMATION or isWhitespaceChar(c) or c == "\"" or c == "'" or c == "(" or c == "[" then
        else
            if not isPunctuationChar(c) then pending = false end
        end
    end
    return table.concat(chars)
end

local function changeFirstLetter(value, upper)
    local chars = splitUtf8Chars(value)
    for i, c in ipairs(chars) do
        if isLetter(c) then
            chars[i] = upper and unicodeUpper(c) or unicodeLower(c)
            return table.concat(chars), true
        end
    end
    return table.concat(chars), false
end

local function stripLeadingEllipsisText(value)
    value = normalizeString(value)
    local prefix, rest = "", trimText(value)
    while startsWith(rest, INV_QUESTION) or startsWith(rest, INV_EXCLAMATION) do
        local c = unicodeSub(rest, 1, 1)
        prefix = prefix .. c
        rest = trimText(unicodeSub(rest, 2))
    end
    local stripping = true
    while stripping do
        stripping = false
        local r = rest:gsub("^%.%.%.+%s*", "")
        if r ~= rest then rest = r; stripping = true end
        if startsWith(rest, HORIZONTAL_ELLIPSIS) or startsWith(rest, TWO_DOT_LEADER) then
            rest = trimText(unicodeSub(rest, 2)); stripping = true
        end
    end
    return prefix .. rest
end

local function addEndingEllipsisText(value)
    local tags, body = splitLeadingTagBlocks(value)
    body = trimText(body)
    local trailingTags
    body, trailingTags = splitTrailingTagBlocks(body)
    if body == "" then return value end
    local suffix, changed = "", true
    while changed do
        changed = false
        if endsWith(body, "?") or endsWith(body, "!") then
            suffix = body:sub(-1) .. suffix
            body = trimText(body:sub(1, -2))
            changed = true
        end
    end
    local stripping = true
    while stripping do
        stripping = false
        local b = body:gsub("%s*%.+%s*$", "")
        if b ~= body then body = b; stripping = true end
        if endsWith(body, HORIZONTAL_ELLIPSIS) or endsWith(body, TWO_DOT_LEADER) then
            body = trimText(unicodeSub(body, 1, -2)); stripping = true
        end
    end
    return tags .. trimText(body) .. "..." .. suffix .. trailingTags
end

local function normalizeQuotesText(v)
    return normalizeString(v)
        :gsub(LEFT_DOUBLE_QUOTE,"\""):gsub(RIGHT_DOUBLE_QUOTE,"\"")
        :gsub(DOUBLE_LOW_QUOTE,"\""):gsub(DOUBLE_HIGH_REVERSED_QUOTE,"\"")
        :gsub(LEFT_GUILLEMET,"\""):gsub(RIGHT_GUILLEMET,"\"")
        :gsub(LEFT_SINGLE_GUILLEMET,"\""):gsub(RIGHT_SINGLE_GUILLEMET,"\"")
        :gsub(LEFT_SINGLE_QUOTE,"'"):gsub(RIGHT_SINGLE_QUOTE,"'")
        :gsub(SINGLE_LOW_QUOTE,"'"):gsub(SINGLE_HIGH_REVERSED_QUOTE,"'")
end

local function toLatinQuotesText(value)
    local chars = splitUtf8Chars(normalizeString(value))
    local out = {}
    local doubleOpen, singleOpen = false, false
    for i, ch in ipairs(chars) do
        local prev, nxt = chars[i-1], chars[i+1]
        local letterContext = prev and nxt and isLetter(prev) and isLetter(nxt)
        if ch == LEFT_DOUBLE_QUOTE or ch == DOUBLE_LOW_QUOTE then
            out[#out+1] = LEFT_GUILLEMET
        elseif ch == RIGHT_DOUBLE_QUOTE or ch == DOUBLE_HIGH_REVERSED_QUOTE then
            out[#out+1] = RIGHT_GUILLEMET
        elseif ch == LEFT_SINGLE_GUILLEMET then
            out[#out+1] = LEFT_GUILLEMET
        elseif ch == RIGHT_SINGLE_GUILLEMET then
            out[#out+1] = RIGHT_GUILLEMET
        elseif ch == LEFT_SINGLE_QUOTE or ch == SINGLE_LOW_QUOTE then
            out[#out+1] = LEFT_GUILLEMET
        elseif ch == RIGHT_SINGLE_QUOTE or ch == SINGLE_HIGH_REVERSED_QUOTE then
            if letterContext then out[#out+1] = "'" else out[#out+1] = RIGHT_GUILLEMET end
        elseif ch == "\"" then
            if doubleOpen then out[#out+1] = RIGHT_GUILLEMET; doubleOpen = false
            else out[#out+1] = LEFT_GUILLEMET; doubleOpen = true end
        elseif ch == "'" then
            if letterContext then out[#out+1] = "'"
            elseif singleOpen then out[#out+1] = RIGHT_GUILLEMET; singleOpen = false
            else out[#out+1] = LEFT_GUILLEMET; singleOpen = true end
        else
            out[#out+1] = ch
        end
    end
    return table.concat(out)
end

local function normalizeDashesText(v)
    v = normalizeString(v):gsub(EN_DASH,"-"):gsub(EM_DASH,"-"):gsub(HORIZONTAL_BAR,"-"):gsub(MINUS_SIGN,"-")
    v = v:gsub("%s+%-%s+", " - "):gsub("%s+%-%-", "--")
    return v
end

local function toggleWrappedPunctuation(text, opening, closing)
    local tags, body = splitLeadingTagBlocks(text)
    body = trimText(body)
    if body == "" then return text end
    local trailingTags
    body, trailingTags = splitTrailingTagBlocks(body)
    if startsWith(body, opening) and endsWith(body, closing) then
        body = body:sub(#opening + 1, #body - #closing); body = trimText(body)
        if body ~= "" and not (body:match("[%.%!%?]$") or endsWith(body, HORIZONTAL_ELLIPSIS)) then
            body = body .. "."
        end
        return tags .. body .. trailingTags
    end
    if startsWith(body, opening) and not endsWith(body, closing) then
        local clean = stripTags(body):sub(#opening + 1)
        if not clean:find(closing, 1, true) then return tags .. body .. closing .. trailingTags end
        return text
    end
    if not startsWith(body, opening) and endsWith(body, closing) then
        local clean = stripTags(body); clean = clean:sub(1, #clean - #closing)
        local paired = false
        if #opening > 1 then
            for c in opening:gmatch(UTF8_CHAR_PATTERN) do
                if clean:find(c, 1, true) then paired = true; break end
            end
        else
            if clean:find(opening, 1, true) then paired = true end
        end
        if not paired then return tags .. opening .. trimText(body) .. trailingTags end
        return text
    end
    if not body:match("%.%.%s*$") and not endsWith(trimText(body), HORIZONTAL_ELLIPSIS) then
        body = body:gsub("%.%s*$", "")
    end
    return tags .. opening .. trimText(body) .. closing .. trailingTags
end

function TextOperations.toggleAlignment(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]; local text = normalizeString(line.text)
        if hasOverridePattern(text, "\\an8") then
            text = removeOverridePattern(text, "\\an8")
        else
            text = removeOverridePattern(text, "\\an%d")
            local applied = false
            text = mutateOverrideBlocks(text, function(block)
                if applied then return block end
                local inner = block:sub(2, -2); inner = "\\an8" .. inner
                applied = true; return "{" .. inner .. "}"
            end)
            if not applied then text = insertOverrideAfterLeadingComments(text, "{\\an8}") end
        end
        line.text = text; subs[i] = line
    end
end

function TextOperations.toggleItalics(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]; local text = normalizeString(line.text)
        if hasOverridePattern(text, "\\i1") then
            text = removeOverridePattern(text, "\\i[01]")
        else
            local applied = false
            text = mutateOverrideBlocks(text, function(block)
                if applied then return block end
                local inner = block:sub(2, -2)
                if inner:match("\\i%d") then inner = inner:gsub("\\i%d", "\\i1", 1)
                else inner = inner .. "\\i1" end
                applied = true; return "{" .. inner .. "}"
            end)
            if not applied then text = insertOverrideAfterLeadingComments(text, "{\\i1}") end
            if not text:match("{\\i0}%s*$") then text = text .. "{\\i0}" end
        end
        line.text = text; subs[i] = line
    end
end

function TextOperations.toUppercase(subs, sel)   for _, i in ipairs(sel) do local l=subs[i]; mutateTextSections(l, unicodeUpper);     subs[i]=l end end
function TextOperations.toLowercase(subs, sel)   for _, i in ipairs(sel) do local l=subs[i]; mutateTextSections(l, unicodeLower);     subs[i]=l end end
function TextOperations.toTitleCase(subs, sel)   for _, i in ipairs(sel) do local l=subs[i]; mutateTextSections(l, textToTitleCase);  subs[i]=l end end
function TextOperations.toSentenceCase(subs, sel)for _, i in ipairs(sel) do local l=subs[i]; mutateTextSections(l, textToSentenceCase);subs[i]=l end end

function TextOperations.capitalizeFirst(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local done = false
        mutateTextSections(l, function(t) if done then return t end
            local c, found = changeFirstLetter(t, true); if found then done = true end; return c end)
        subs[i] = l
    end
end
function TextOperations.lowercaseFirst(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local done = false
        mutateTextSections(l, function(t) if done then return t end
            local c, found = changeFirstLetter(t, false); if found then done = true end; return c end)
        subs[i] = l
    end
end

function TextOperations.formatEllipsis(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        mutateTextSections(l, function(t)
            t = t:gsub(HORIZONTAL_ELLIPSIS, "...")
            t = t:gsub(TWO_DOT_LEADER, "...")
            t = t:gsub("%.%.+", "...")
            t = t:gsub("%s+%.%.%.", "...")
            return t
        end)
        subs[i] = l
    end
end
function TextOperations.eraseLeadingEllipsis(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local tags, body = splitLeadingTagBlocks(l.text)
        l.text = tags .. stripLeadingEllipsisText(body)
        subs[i] = l
    end
end
function TextOperations.addEndingEllipsis(subs, sel)
    for _, i in ipairs(sel) do local l = subs[i]; l.text = addEndingEllipsisText(l.text); subs[i] = l end
end
function TextOperations.normalizeQuotes(subs, sel)
    for _, i in ipairs(sel) do local l = subs[i]; mutateTextSections(l, normalizeQuotesText); subs[i] = l end
end
function TextOperations.toLatinQuotes(subs, sel)
    for _, i in ipairs(sel) do local l = subs[i]; mutateTextSections(l, toLatinQuotesText); subs[i] = l end
end
function TextOperations.normalizeDashes(subs, sel)
    for _, i in ipairs(sel) do local l = subs[i]; mutateTextSections(l, normalizeDashesText); subs[i] = l end
end
function TextOperations.trimTrailingSpaces(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        l.text = normalizeString(l.text):gsub("[ \t]+\\N", "\\N"):gsub("\\N[ \t]+", "\\N"):gsub("[ \t]+$", "")
        subs[i] = l
    end
end

local function togglePunctuationForSelection(subs, sel, opening, closing)
    for _, i in ipairs(sel) do local l = subs[i]; l.text = toggleWrappedPunctuation(l.text, opening, closing); subs[i] = l end
end
function TextOperations.toggleExclamation(subs, sel) togglePunctuationForSelection(subs, sel, INV_EXCLAMATION, "!") end
function TextOperations.toggleQuestion(subs, sel)    togglePunctuationForSelection(subs, sel, INV_QUESTION, "?") end
function TextOperations.toggleBothSigns(subs, sel)   togglePunctuationForSelection(subs, sel, INV_EXCLAMATION .. INV_QUESTION, "?!") end

local function normalizeRepeatedLetters(value)
    local chars = splitUtf8Chars(value); if #chars < 3 then return value end
    local out, i = {}, 1
    while i <= #chars do
        local cur = chars[i]
        if isLetter(cur) then
            local j = i + 1
            while j <= #chars and chars[j] == cur do j = j + 1 end
            local run = j - i
            if run >= 3 then out[#out+1] = cur
            else for k = i, j - 1 do out[#out+1] = chars[k] end end
            i = j
        else
            out[#out+1] = cur; i = i + 1
        end
    end
    return table.concat(out)
end
function TextOperations.removeDuplicateLetters(subs, sel)
    for _, i in ipairs(sel) do local l = subs[i]; mutateTextSections(l, normalizeRepeatedLetters); subs[i] = l end
end

function TagOperations.extractTags(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local initialTags, rest = splitLeadingTagBlocks(l.text)
        if initialTags ~= "" then
            local cur = normalizeString(l.effect)
            l.effect = (cur ~= "" and (initialTags .. " " .. cur) or initialTags)
            l.text = trimText(rest)
            subs[i] = l
        end
    end
end

function TagOperations.reinsertTags(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local saved, rest = extractEffectTagBlocks(l.effect)
        if saved ~= "" then
            l.text = MarkerOperations.normalizeEffectTagSeparators(saved) .. normalizeString(l.text)
            l.effect = rest
            subs[i] = l
        end
    end
end

function MarkerOperations.numberEffects(subs, sel)
    local sorted = {}
    for _, i in ipairs(sel) do sorted[#sorted+1] = i end
    table.sort(sorted)
    local n = 1
    for _, i in ipairs(sorted) do
        local l = subs[i]
        if isDialogue(l) then
            MarkerOperations.appendEffectText(l, tostring(n))
            subs[i] = l
            n = n + 1
        end
    end
end

function MarkerOperations.collectRandomNumbers(subs)
    local used = {}
    for i = 1, #subs do
        local effect = normalizeString(subs[i] and subs[i].effect or "")
        for n in effect:gmatch("%f[%d](%d%d%d%d%d%d%d%d%d%d%d%d%d%d)%f[%D]") do used[n] = true end
    end
    return used
end

function MarkerOperations.makeRandomNumber(used)
    local n
    repeat
        local out = {}
        for i = 1, 14 do out[i] = tostring(math.random(0, 9)) end
        n = table.concat(out)
    until not used[n]
    used[n] = true
    return n
end

function MarkerOperations.randomEffects(subs, sel)
    math.randomseed(os.time() + math.floor(os.clock() * 1000000) + (#sel * 7919))
    math.random(); math.random(); math.random()
    local used = MarkerOperations.collectRandomNumbers(subs)
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isDialogue(l) then
            MarkerOperations.appendEffectText(l, MarkerOperations.makeRandomNumber(used))
            subs[i] = l
        end
    end
end

function MarkerOperations.collectFoldIds(subs)
    local used = {}
    for i = 1, #subs do
        local extra = subs[i] and subs[i].extra
        local data = type(extra) == "table" and extra["_aegi_folddata"] or nil
        local id = data and data:match("^%d+;%d+;(%d+)$")
        if id then used[tonumber(id)] = true end
    end
    return used
end

function MarkerOperations.nextFoldId(used)
    local id = math.floor(os.time() % 1000000000)
    if id < 1 then id = 1 end
    while used[id] do id = id + 1 end
    used[id] = true
    return id
end

function MarkerOperations.clearFoldData(line)
    if type(line.extra) == "table" then line.extra["_aegi_folddata"] = nil end
end

function MarkerOperations.setFoldData(line, side, id)
    if type(line.extra) ~= "table" then line.extra = {} end
    line.extra["_aegi_folddata"] = tostring(side) .. ";0;" .. tostring(id)
end

function MarkerOperations.randomFolds(subs, sel)
    local sorted = {}
    for _, i in ipairs(sel) do sorted[#sorted+1] = i end
    table.sort(sorted)
    local entries, groups, order = {}, {}, {}
    for _, i in ipairs(sorted) do
        local line = cloneLine(subs[i])
        MarkerOperations.clearFoldData(line)
        local id = MarkerOperations.effectRandomNumber(line)
        local entry = { line = line, random = id }
        entries[#entries+1] = entry
        if id then
            if not groups[id] then groups[id] = {}; order[#order+1] = id end
            groups[id][#groups[id]+1] = entry
        end
    end
    local groupedIds = {}
    for _, id in ipairs(order) do if #groups[id] > 1 then groupedIds[id] = true end end
    local out, emitted = {}, {}
    for _, entry in ipairs(entries) do
        local id = entry.random
        if id and groupedIds[id] then
            if not emitted[id] then
                for _, grouped in ipairs(groups[id]) do out[#out+1] = grouped end
                emitted[id] = true
            end
        else
            out[#out+1] = entry
        end
    end
    local usedFoldIds = MarkerOperations.collectFoldIds(subs)
    local firstById, lastById = {}, {}
    for pos, entry in ipairs(out) do
        local id = entry.random
        if id and groupedIds[id] then
            firstById[id] = firstById[id] or pos
            lastById[id] = pos
        end
    end
    for id, first in pairs(firstById) do
        local last = lastById[id]
        if first and last and first ~= last then
            local foldId = MarkerOperations.nextFoldId(usedFoldIds)
            MarkerOperations.setFoldData(out[first].line, 0, foldId)
            MarkerOperations.setFoldData(out[last].line, 1, foldId)
        end
    end
    for pos, i in ipairs(sorted) do subs[i] = out[pos].line end
    return sel
end

function TagOperations.removeAllTags(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local p = parseLine(l)
        if p and p.stripTags and p.commit then p:stripTags(); p:commit()
        else
            l.text = normalizeString(l.text):gsub("(%b{})", function(b)
                return b:match("^%{%s*\\") and "" or b
            end)
        end
        subs[i] = l
    end
end

function TagOperations.removeComments(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local p = parseLine(l)
        if p and p.stripComments and p.commit then p:stripComments(); p:commit()
        else l.text = stripComments(l.text) end
        subs[i] = l
    end
end

function TagOperations.parseActor(subs, sel)
    local function allocDur(seg, T)
        local c = 0
        for _, s in ipairs(seg) do
            local txt = s.text:gsub("{[^}]*}", ""):gsub("%s+", "")
            c = c + unicodeLenSafe(txt)
        end
        local d, r = {}, T
        if c == 0 then
            local s = math.floor(T / #seg)
            for i = 1, #seg do d[i] = s end
            d[#seg] = T - s * (#seg - 1)
        else
            for i, s in ipairs(seg) do
                local txt = s.text:gsub("{[^}]*}", ""):gsub("%s+", "")
                local len = unicodeLenSafe(txt)
                if i == #seg then d[i] = r
                else local v = math.floor(T * len / c); d[i] = v; r = r - v end
            end
        end
        return d
    end
    local function parseActorsAndSplit(text)
        local segments = {}
        local current_text, current_actor = "", nil
        local i, len = 1, text:len()
        while i <= len do
            local sub = text:sub(i)
            local actor_match, match_len = nil, 0
            local patterns = {
                "^%s*（(.-)）", "^%s*%((.-)%)", "^%s*%[(.-)%]",
                "^%s*【(.-)】", "^%s*［(.-)］", "^%s*｛(.-)｝",
                "^%s*〈(.-)〉", "^%s*《(.-)》", "^%s*「(.-)」",
                "^%s*『(.-)』", "^%s*〔(.-)〕",
            }
            for _, pat in ipairs(patterns) do
                local s, e, cap = sub:find(pat)
                if s then actor_match = cap; match_len = e - s + 1; break end
            end
            if actor_match then
                if current_text ~= "" and current_text:match("%S") then
                    table.insert(segments, { actor = current_actor, text = current_text })
                    current_text = ""
                end
                i = i + match_len; current_actor = actor_match
            else
                local b = text:byte(i)
                local cl = (b >= 240) and 4 or (b >= 224) and 3 or (b >= 192) and 2 or 1
                current_text = current_text .. text:sub(i, i + cl - 1)
                i = i + cl
            end
        end
        if current_text ~= "" then table.insert(segments, { actor = current_actor, text = current_text }) end
        return segments
    end
    local last_actor = nil
    table.sort(sel)
    local shifts = 0
    local inserted = {}
    for _, ix in ipairs(sel) do
        local i = ix + shifts
        local l = subs[i]
        local text = normalizeString(l.text)
        text = text:gsub("<([^>]+)>", "{\\i1}%1{\\i0}")
        text = text:gsub("＜(.-)＞", "{\\i1}%1{\\i0}")
        local simple_actor, simple_rest = text:match("^%s*%[([^%]]+)%]%s*:%s*(.+)$")
        if not simple_actor then
            simple_actor, simple_rest = text:match("^%s*([^:%[%(]+):%s*(.+)$")
            if simple_actor and (simple_actor:find("\\") or #trimText(simple_actor) > 24) then
                simple_actor, simple_rest = nil, nil
            end
        end
        if simple_actor and simple_rest and not simple_rest:match("[%[%(（]") then
            l.actor = trimText(simple_actor)
            l.text = simple_rest
            last_actor = l.actor
            subs[i] = l
        else
            local parts = parseActorsAndSplit(text)
            if #parts == 0 then
                if last_actor then l.actor = last_actor; subs[i] = l end
            elseif #parts == 1 then
                local p = parts[1]
                if p.actor then l.actor = p.actor; last_actor = p.actor
                elseif last_actor then l.actor = last_actor end
                l.text = p.text:gsub("^%s+", ""):gsub("%s+$", "")
                subs[i] = l
            else
                local dur = allocDur(parts, l.end_time - l.start_time)
                local t = l.start_time
                for j, p in ipairs(parts) do
                    local nl = cloneLine(l)
                    nl.start_time = t; nl.end_time = t + dur[j]; t = nl.end_time
                    if p.actor then nl.actor = p.actor; last_actor = p.actor
                    elseif last_actor then nl.actor = last_actor end
                    nl.text = p.text:gsub("^%s+", ""):gsub("%s+$", "")
                    if j == 1 then subs[i] = nl else subs.insert(i + j - 1, nl); shifts = shifts + 1 end
                end
                inserted[ix] = #parts - 1
            end
        end
    end
    return remapSelectionAfterInsertion(sel, inserted)
end

function TagOperations.swapComment(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local text = normalizeString(l.text); local out = {}; local lastIdx = 1
        for s, block, e in text:gmatch("()(%b{})()") do
            local before = text:sub(lastIdx, s - 1)
            if before ~= "" then
                if before:match("^%s+$") then out[#out+1] = before
                else out[#out+1] = "{" .. before .. "}" end
            end
            if block:match("^%{%s*\\") then out[#out+1] = block else out[#out+1] = block:sub(2, -2) end
            lastIdx = e
        end
        local tail = text:sub(lastIdx)
        if tail ~= "" then
            if tail:match("^%s+$") then out[#out+1] = tail else out[#out+1] = "{" .. tail .. "}" end
        end
        l.text = table.concat(out); subs[i] = l
    end
end

local function addStutterToText(value)
    local chars = splitUtf8Chars(value)
    if #chars == 0 then return value, false end
    local target, depth = nil, 0
    for idx, ch in ipairs(chars) do
        if ch == "{" then depth = depth + 1
        elseif ch == "}" then depth = math.max(0, depth - 1)
        elseif depth == 0 and isLetter(ch) then target = idx; break end
    end
    if not target then return value, false end
    if chars[target+1] == "-" and chars[target+2] and unicodeLower(chars[target+2]) == unicodeLower(chars[target]) then
        table.remove(chars, target + 2)
        table.remove(chars, target + 1)
        return table.concat(chars), true
    end
    local out = {}
    for idx, ch in ipairs(chars) do
        if idx == target then out[#out+1] = ch; out[#out+1] = "-"; out[#out+1] = ch
        else out[#out+1] = ch end
    end
    return table.concat(out), true
end

local function addAhPrefixToText(value)
    local chars = splitUtf8Chars(value)
    if #chars == 0 then return value, false end
    local prefix, idx = {}, 1
    while idx <= #chars do
        local ch = chars[idx]
        if ch == INV_QUESTION or ch == INV_EXCLAMATION then prefix[#prefix+1] = ch; idx = idx + 1
        elseif ch == "." then
            local dots, j = 0, idx
            while j <= #chars and chars[j] == "." do dots = dots + 1; j = j + 1 end
            if dots >= 2 then
                for _ = 1, dots do prefix[#prefix+1] = "." end
                idx = j
                while idx <= #chars and (chars[idx] == " " or chars[idx] == "\t") do idx = idx + 1 end
            else break end
        elseif ch == HORIZONTAL_ELLIPSIS or ch == TWO_DOT_LEADER then
            prefix[#prefix+1] = ch; idx = idx + 1
            while idx <= #chars and (chars[idx] == " " or chars[idx] == "\t") do idx = idx + 1 end
        elseif ch == " " or ch == "\t" then idx = idx + 1
        else break end
    end
    if idx > #chars then return value, false end
    local firstLetter, depth = nil, 0
    for k = idx, #chars do
        if chars[k] == "{" then depth = depth + 1
        elseif chars[k] == "}" then depth = math.max(0, depth - 1)
        elseif depth == 0 and isLetter(chars[k]) then firstLetter = k; break end
    end
    if not firstLetter then return value, false end
    local matchA, matchB = true, true
    local lower = {"a","h",","}; local upper = {"A","h",","}
    for m = 1, 3 do
        local ci = firstLetter + m - 1
        if ci > #chars then matchA = false; matchB = false; break end
        if chars[ci] ~= lower[m] then matchA = false end
        if chars[ci] ~= upper[m] then matchB = false end
    end
    if matchA or matchB then
        for _ = 1, 3 do table.remove(chars, firstLetter) end
        while chars[firstLetter] == " " or chars[firstLetter] == "\t" do table.remove(chars, firstLetter) end
        if chars[firstLetter] then chars[firstLetter] = unicodeUpper(chars[firstLetter]) end
        return table.concat(chars), true
    end
    chars[firstLetter] = unicodeLower(chars[firstLetter])
    local out = {}
    for k = 1, #prefix do out[#out+1] = prefix[k] end
    out[#out+1] = "Ah, "
    for k = idx, #chars do out[#out+1] = chars[k] end
    return table.concat(out), true
end

function SmartOperations.injectStutter(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local p = parseLine(l); local done = false
        if p and ASS and ASS.Section and p.callback and p.commit then
            p:callback(function(section)
                if not done and section.class == ASS.Section.Text then
                    local replaced, changed = addStutterToText(section.value)
                    section.value = replaced; done = changed
                end
            end)
            p:commit()
        else
            local leadTags, body = splitLeadingTagBlocks(normalizeString(l.text))
            local replaced, changed = addStutterToText(body)
            if changed then l.text = leadTags .. replaced end
        end
        subs[i] = l
    end
end

function SmartOperations.injectAhPrefix(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; local p = parseLine(l); local done = false
        if p and ASS and ASS.Section and p.callback and p.commit then
            p:callback(function(section)
                if not done and section.class == ASS.Section.Text then
                    local replaced, changed = addAhPrefixToText(section.value)
                    section.value = replaced; done = changed
                end
            end)
            p:commit()
        else
            local leadTags, body = splitLeadingTagBlocks(normalizeString(l.text))
            local replaced, changed = addAhPrefixToText(body)
            if changed then l.text = leadTags .. replaced end
        end
        subs[i] = l
    end
end

function SmartOperations.removeHonorifics(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        l.text = normalizeString(l.text)
            :gsub("%-san%f[%A]",      "{-san}")
            :gsub("%-tan%f[%A]",      "{-tan}")
            :gsub("%-chan%f[%A]",     "{-chan}")
            :gsub("%-kun%f[%A]",      "{-kun}")
            :gsub("%-sama%f[%A]",     "{-sama}")
            :gsub("%-niisan%f[%A]",   "{-niisan}")
            :gsub("%-oniisan%f[%A]",  "{-oniisan}")
            :gsub("%-oniichan%f[%A]", "{-oniichan}")
            :gsub("%-oneesan%f[%A]",  "{-oneesan}")
            :gsub("%-oneechan%f[%A]", "{-oneechan}")
            :gsub("%-neesama%f[%A]",  "{-neesama}")
            :gsub("%-sensei%f[%A]",   "{-sensei}")
            :gsub("%-se[mn]pai%f[%A]","{-senpai}")
            :gsub("%-dono%f[%A]",     "{-dono}")
            :gsub("{{", "{")
            :gsub("}}", "}")
            :gsub("({[^{}]-){(%-%a-)}([^{}]-})", "%1%2%3")
        subs[i] = l
    end
end

function TimingOperations.removeLinebreaks(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local text = normalizeString(l.text):gsub("\\[Nn]", " "):gsub("[ \t]+", " ")
        l.text = trimText(text)
        subs[i] = l
    end
end

function SmartOperations.clarifyCaption(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]; l.text = trimText(normalizeString(l.text):gsub("%b[]", ""):gsub("%s+", " "))
        subs[i] = l
    end
end

function SmartOperations.eraseBlankLines(subs, sel)
    local toDelete, deleteSet = {}, {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        local clean = stripComments(stripTags(l.text)):gsub("%s+", "")
        if clean == "" then toDelete[#toDelete+1] = i; deleteSet[i] = true end
    end
    table.sort(toDelete, function(a, b) return a > b end)
    for _, i in ipairs(toDelete) do subs.delete(i) end
    return remapSelectionAfterDeletion(sel, deleteSet)
end

function SmartOperations.deleteCommentLines(subs, sel)
    local deleteSet = {}
    table.sort(sel, function(a, b) return a > b end)
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isDialogue(l) and l.comment then
            subs.delete(i); deleteSet[i] = true
        end
    end
    return remapSelectionAfterDeletion(sel, deleteSet)
end

local function moveCommentLines(subs, sel, toStart)
    local selected, commented, active = {}, {}, {}
    for _, i in ipairs(sel) do selected[#selected+1] = { index = i, line = cloneLine(subs[i]) } end
    table.sort(selected, function(a, b) return a.index < b.index end)
    for _, it in ipairs(selected) do
        if isDialogue(it.line) and it.line.comment then commented[#commented+1] = it.line
        else active[#active+1] = it.line end
    end
    local ordered = {}
    local first = toStart and commented or active
    local second = toStart and active    or commented
    for _, l in ipairs(first)  do ordered[#ordered+1] = l end
    for _, l in ipairs(second) do ordered[#ordered+1] = l end
    for idx, it in ipairs(selected) do subs[it.index] = ordered[idx] end
end
function SmartOperations.commentsToTop(subs, sel)    moveCommentLines(subs, sel, true) end
function SmartOperations.commentsToBottom(subs, sel) moveCommentLines(subs, sel, false) end

local function moveEffectLinesToTop(subs, sel)
    local selected, marked, plain = {}, {}, {}
    for _, i in ipairs(sel) do selected[#selected+1] = { index = i, line = cloneLine(subs[i]) } end
    table.sort(selected, function(a, b) return a.index < b.index end)
    for _, it in ipairs(selected) do
        if isDialogue(it.line) and trimText(it.line.effect or "") ~= "" then marked[#marked+1] = it.line
        else plain[#plain+1] = it.line end
    end
    local ordered = {}
    for _, l in ipairs(marked) do ordered[#ordered+1] = l end
    for _, l in ipairs(plain) do ordered[#ordered+1] = l end
    for idx, it in ipairs(selected) do subs[it.index] = ordered[idx] end
end

function TagOperations.effectsToTop(subs, sel) moveEffectLinesToTop(subs, sel) end

local function nearestKeyframe(frame, kfs, range)
    local best, bestDist = nil, nil
    for _, kf in ipairs(kfs or {}) do
        local dist = math.abs(kf - frame)
        if dist <= range and (not bestDist or dist < bestDist) then
            best, bestDist = kf, dist
        end
        if kf > frame + range then break end
    end
    return best, bestDist
end

local function directionalKeyframeMs(targetMs, kfs, limitMs, direction)
    local frame = msToFrame(targetMs)
    if not frame then return nil end
    local bestMs, bestDist = nil, nil
    for _, kf in ipairs(kfs or {}) do
        local kfMs = frameToMs(kf)
        local ok = kfMs and ((direction == "back" and kf < frame) or (direction == "forward" and kf > frame))
        if ok then
            local dist = math.abs(kfMs - targetMs)
            if dist <= limitMs and (not bestDist or dist < bestDist) then
                bestMs, bestDist = kfMs, dist
            end
        end
    end
    return bestMs, bestDist
end

function SmartOperations.bidirectionalSnapping(subs, sel)
    local kfs = getKeyframes()
    if not kfs or #kfs == 0 then showMsg(L("err_no_keyframes")); return end
    local range = tonumber(currentConfig.bidir_snap_f) or 2
    if range < 0 then range = 0 end
    local modified, starts, ends = 0, 0, 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isDialogue(line) and validateDuration(line) then
            local sf, ef = msToFrame(line.start_time), msToFrame(line.end_time)
            local skf, sdist, ekf, edist
            if sf then skf, sdist = nearestKeyframe(sf, kfs, range) end
            if ef then ekf, edist = nearestKeyframe(ef, kfs, range) end
            local oldStart, oldEnd = line.start_time, line.end_time
            local snapStart = skf and frameToMs(skf) or nil
            local snapEnd = ekf and frameToMs(ekf) or nil
            local newStart = snapStart or oldStart
            local newEnd = snapEnd or oldEnd
            if snapStart or snapEnd then
                if newEnd <= newStart then
                    if snapStart and (not snapEnd or sdist <= edist) and oldEnd > snapStart then
                        newStart, newEnd = snapStart, oldEnd
                    elseif snapEnd and snapEnd > oldStart then
                        newStart, newEnd = oldStart, snapEnd
                    else
                        newStart, newEnd = oldStart, oldEnd
                    end
                end
                if newStart ~= oldStart or newEnd ~= oldEnd then
                    if newStart ~= oldStart then starts = starts + 1 end
                    if newEnd ~= oldEnd then ends = ends + 1 end
                    line.start_time, line.end_time = newStart, newEnd
                    subs[i] = line
                    modified = modified + 1
                end
            end
        end
    end
    showMsg(string.format(L("msg_bidir_done"), modified, starts, ends, range))
end

local function directionalSnap(subs, sel, edge, direction)
    local kfs = getKeyframes()
    if not kfs or #kfs == 0 then showMsg(L("err_no_keyframes")); return end
    local limit = tonumber(currentConfig.edge_snap_protect_ms) or DEFAULT_CONFIG.edge_snap_protect_ms
    if limit <= 0 then limit = DEFAULT_CONFIG.edge_snap_protect_ms end
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isDialogue(line) and validateDuration(line) then
            local oldStart, oldEnd = line.start_time, line.end_time
            local target = edge == "start" and oldStart or oldEnd
            local snapped = directionalKeyframeMs(target, kfs, limit, direction)
            if snapped then
                if edge == "start" then
                    if snapped < oldEnd and snapped ~= oldStart then
                        line.start_time = snapped
                        subs[i] = line
                    end
                elseif snapped > oldStart and snapped ~= oldEnd then
                    line.end_time = snapped
                    subs[i] = line
                end
            end
        end
    end
end

function SmartOperations.startSnapBack(subs, sel) directionalSnap(subs, sel, "start", "back") end
function SmartOperations.startSnapForward(subs, sel) directionalSnap(subs, sel, "start", "forward") end
function SmartOperations.endSnapBack(subs, sel) directionalSnap(subs, sel, "end", "back") end
function SmartOperations.endSnapForward(subs, sel) directionalSnap(subs, sel, "end", "forward") end

local function timelineSnapshot(subs)
    local arr = {}
    for i = 1, #subs do
        local l = subs[i]
        if isEditableDialogue(l) and validateDuration(l) then
            arr[#arr+1] = { i = i, s = l.start_time, e = l.end_time }
        end
    end
    return arr
end

local function applySnapshotTime(subs, rec, s, e)
    local line = subs[rec.i]
    line.start_time, line.end_time = s, e
    subs[rec.i] = line
    rec.s, rec.e = s, e
end

local function selectionByStart(all, sel)
    local byIdx = {}
    for _, r in ipairs(all) do byIdx[r.i] = r end
    local order = {}
    for _, i in ipairs(sel) do if byIdx[i] then order[#order+1] = byIdx[i] end end
    table.sort(order, function(a, b) return a.s < b.s end)
    return order
end

local MIN_NEIGHBOR_DURATION = 10

local function nudgeLead(subs, sel, edge)
    local step = normalizeNumber(currentConfig.lead_step_ms, DEFAULT_CONFIG.lead_step_ms)
    if step <= 0 then step = DEFAULT_CONFIG.lead_step_ms end
    local all = timelineSnapshot(subs)
    for _, rec in ipairs(selectionByStart(all, sel)) do
        local bound, chained = nil, {}
        if edge == "in" then
            for _, r in ipairs(all) do
                if r ~= rec then
                    if r.e == rec.s and r.s < rec.s then chained[#chained+1] = r
                    elseif r.e < rec.s and (not bound or r.e > bound) then bound = r.e end
                end
            end
            local move
            if #chained > 0 then
                move = step
                for _, r in ipairs(chained) do move = math.min(move, r.e - r.s - MIN_NEIGHBOR_DURATION) end
                move = math.min(move, rec.s)
                if move > 0 then
                    for _, r in ipairs(chained) do applySnapshotTime(subs, r, r.s, r.e - move) end
                end
            else
                move = math.min(step, rec.s - (bound or 0))
            end
            if move > 0 then applySnapshotTime(subs, rec, rec.s - move, rec.e) end
        else
            for _, r in ipairs(all) do
                if r ~= rec then
                    if r.s == rec.e and r.e > rec.e then chained[#chained+1] = r
                    elseif r.s > rec.e and (not bound or r.s < bound) then bound = r.s end
                end
            end
            local move
            if #chained > 0 then
                move = step
                for _, r in ipairs(chained) do move = math.min(move, r.e - r.s - MIN_NEIGHBOR_DURATION) end
                if move > 0 then
                    for _, r in ipairs(chained) do applySnapshotTime(subs, r, r.s + move, r.e) end
                end
            else
                move = bound and math.min(step, bound - rec.e) or step
            end
            if move > 0 then applySnapshotTime(subs, rec, rec.s, rec.e + move) end
        end
    end
end

local function nudgeLeadInward(subs, sel, edge)
    local step = normalizeNumber(currentConfig.lead_step_ms, DEFAULT_CONFIG.lead_step_ms)
    if step <= 0 then step = DEFAULT_CONFIG.lead_step_ms end
    local all = timelineSnapshot(subs)
    for _, rec in ipairs(selectionByStart(all, sel)) do
        local move = math.min(step, rec.e - rec.s - MIN_NEIGHBOR_DURATION)
        if move > 0 then
            if edge == "in" then
                local oldStart = rec.s
                for _, r in ipairs(all) do
                    if r ~= rec and r.e == oldStart and r.s < oldStart then
                        applySnapshotTime(subs, r, r.s, r.e + move)
                    end
                end
                applySnapshotTime(subs, rec, rec.s + move, rec.e)
            else
                local oldEnd = rec.e
                for _, r in ipairs(all) do
                    if r ~= rec and r.s == oldEnd and r.e > oldEnd then
                        applySnapshotTime(subs, r, r.s - move, r.e)
                    end
                end
                applySnapshotTime(subs, rec, rec.s, rec.e - move)
            end
        end
    end
end

local function chainToNeighbor(subs, sel, side)
    local cap = normalizeNumber(currentConfig.chain_max_ms, DEFAULT_CONFIG.chain_max_ms)
    if cap <= 0 then cap = DEFAULT_CONFIG.chain_max_ms end
    local all = timelineSnapshot(subs)
    for _, rec in ipairs(selectionByStart(all, sel)) do
        if side == "left" then
            local bound
            for _, r in ipairs(all) do
                if r ~= rec and r.e <= rec.s and (not bound or r.e > bound) then bound = r.e end
            end
            if bound and bound < rec.s and rec.s - bound <= cap then applySnapshotTime(subs, rec, bound, rec.e) end
        else
            local bound
            for _, r in ipairs(all) do
                if r ~= rec and r.s >= rec.e and (not bound or r.s < bound) then bound = r.s end
            end
            if bound and bound > rec.e and bound - rec.e <= cap then applySnapshotTime(subs, rec, rec.s, bound) end
        end
    end
end

function TimingOperations.addLeadIn(subs, sel)  nudgeLead(subs, sel, "in") end
function TimingOperations.addLeadInRight(subs, sel) nudgeLeadInward(subs, sel, "in") end
function TimingOperations.addLeadOutLeft(subs, sel) nudgeLeadInward(subs, sel, "out") end
function TimingOperations.addLeadOut(subs, sel) nudgeLead(subs, sel, "out") end
function TimingOperations.chainLeft(subs, sel)  chainToNeighbor(subs, sel, "left") end
function TimingOperations.chainRight(subs, sel) chainToNeighbor(subs, sel, "right") end

local function allocateDurationsByWeights(weights, totalDuration)
    local duration = math.floor(normalizeNumber(totalDuration, 0))
    local count = #weights
    if count == 0 or duration <= 0 or duration < count then return nil end
    local nw, sum = {}, 0
    for i = 1, count do
        local w = math.max(0, normalizeNumber(weights[i], 0)); nw[i] = w; sum = sum + w
    end
    local alloc = {}
    if sum == 0 then
        local base = math.floor(duration / count)
        local rem  = duration - (base * count)
        for i = 1, count do alloc[i] = base + (i <= rem and 1 or 0) end
        return alloc
    end
    local used = 0
    for i = 1, count - 1 do
        local raw = roundNumber(duration * nw[i] / sum, 0)
        local minRem = count - i
        local maxCur = duration - used - minRem
        if maxCur < 1 then return nil end
        if raw < 1 then raw = 1 elseif raw > maxCur then raw = maxCur end
        alloc[i] = raw; used = used + raw
    end
    alloc[count] = duration - used
    if alloc[count] < 1 then
        local needed = 1 - alloc[count]
        for i = count - 1, 1, -1 do
            if alloc[i] > 1 then
                local borrow = math.min(alloc[i] - 1, needed)
                alloc[i] = alloc[i] - borrow
                alloc[count] = alloc[count] + borrow
                needed = needed - borrow
                if needed <= 0 then break end
            end
        end
        if alloc[count] < 1 then return nil end
    end
    return alloc
end

local function _allocateTimeDuration(segments, totalDuration)
    local w = {}; for i, s in ipairs(segments) do w[i] = countCharacters(s) end
    return allocateDurationsByWeights(w, totalDuration)
end

local function lineTextKey(line)
    return trimText(normalizeString(line.text):gsub("[ \t]+$", ""))
end

function TimingOperations.copyTimes(subs, sel)
    table.sort(sel); if #sel < 2 then return end
    local src = subs[sel[1]]
    for n = 2, #sel do
        local l = subs[sel[n]]
        l.start_time, l.end_time = src.start_time, src.end_time
        subs[sel[n]] = l
    end
end

function TimingOperations.joinSameText(subs, sel)
    local selected, deleteSet = {}, {}
    for _, i in ipairs(sel) do selected[i] = true end
    table.sort(sel, function(a, b) return a > b end)
    for _, i in ipairs(sel) do
        if i > 1 and selected[i-1] and isEditableDialogue(subs[i]) and isEditableDialogue(subs[i-1]) then
            local l = subs[i]; local prev = subs[i-1]
            if lineTextKey(l) ~= "" and lineTextKey(l) == lineTextKey(prev)
               and normalizeString(l.style) == normalizeString(prev.style) then
                prev.start_time = math.min(prev.start_time, l.start_time)
                prev.end_time   = math.max(prev.end_time,   l.end_time)
                subs[i-1] = prev; subs.delete(i); deleteSet[i] = true
            end
        end
    end
    return remapSelectionAfterDeletion(sel, deleteSet)
end

function TimingOperations.joinOverlaps(subs, sel)
    if not sel or #sel < 2 then return sel end
    local entries = {}
    for _, index in ipairs(sel) do
        local line = subs[index]
        if isEditableDialogue(line) and validateDuration(line) then
            entries[#entries+1] = {
                index = index,
                line = line,
                start_time = line.start_time,
                end_time = line.end_time,
            }
        end
    end
    if #entries < 2 then return sel end
    table.sort(entries, function(a, b)
        if a.start_time ~= b.start_time then return a.start_time < b.start_time end
        if a.end_time ~= b.end_time then return a.end_time < b.end_time end
        return a.index < b.index
    end)

    local groups, current = {}, nil
    for _, entry in ipairs(entries) do
        if not current then
            current = { start_time = entry.start_time, end_time = entry.end_time, lines = { entry } }
        elseif entry.start_time < current.end_time then
            current.lines[#current.lines+1] = entry
            if entry.end_time > current.end_time then current.end_time = entry.end_time end
        else
            groups[#groups+1] = current
            current = { start_time = entry.start_time, end_time = entry.end_time, lines = { entry } }
        end
    end
    if current then groups[#groups+1] = current end

    local replacements, deleteSet, deleted = {}, {}, {}
    for _, group in ipairs(groups) do
        if #group.lines > 1 then
            local base = group.lines[1]
            local joined = cloneLine(base.line)
            local texts = {}
            joined.start_time = group.start_time
            joined.end_time = group.end_time
            for _, entry in ipairs(group.lines) do
                texts[#texts+1] = entry.line.text or ""
                if entry.index ~= base.index then
                    deleteSet[entry.index] = true
                    deleted[#deleted+1] = entry.index
                end
            end
            joined.text = table.concat(texts, "\\N")
            replacements[#replacements+1] = { index = base.index, line = joined }
        end
    end
    if #deleted == 0 then return sel end

    for _, replacement in ipairs(replacements) do subs[replacement.index] = replacement.line end
    table.sort(deleted, function(a, b) return a > b end)
    for _, index in ipairs(deleted) do subs.delete(index) end
    return remapSelectionAfterDeletion(sel, deleteSet)
end

function TimingOperations.sortByLength(subs, sel)
    table.sort(sel)
    local items = {}
    for _, i in ipairs(sel) do
        items[#items+1] = { line = cloneLine(subs[i]), count = countCharacters(subs[i].text) }
    end
    table.sort(items, function(a, b)
        if a.count == b.count then return normalizeString(a.line.text) < normalizeString(b.line.text) end
        return a.count > b.count
    end)
    for idx, i in ipairs(sel) do subs[i] = items[idx].line end
end

local function calcCPS(line)
    local d = (line.end_time - line.start_time) / 1000
    if d <= 0 then return 0 end
    return countCharacters(line.text) / d
end

function TimingOperations.sortByCPS(subs, sel)
    table.sort(sel)
    local items = {}
    for _, i in ipairs(sel) do
        items[#items+1] = { line = cloneLine(subs[i]), cps = calcCPS(subs[i]) }
    end
    table.sort(items, function(a, b)
        if a.cps == b.cps then return normalizeString(a.line.text) < normalizeString(b.line.text) end
        return a.cps > b.cps
    end)
    for idx, i in ipairs(sel) do subs[i] = items[idx].line end
end

function TimingOperations.sortByEvenOdd(subs, sel)
    local sorted = {}
    for _, i in ipairs(sel) do sorted[#sorted+1] = i end
    table.sort(sorted)
    local odds, evens, others = {}, {}, {}
    for _, i in ipairs(sorted) do
        local line = cloneLine(subs[i])
        local n = MarkerOperations.effectNumber(line)
        if n == nil then
            others[#others+1] = line
        elseif math.abs(n) % 2 == 1 then
            odds[#odds+1] = line
        else
            evens[#evens+1] = line
        end
    end
    local out = {}
    for _, line in ipairs(odds) do out[#out+1] = line end
    for _, line in ipairs(evens) do out[#out+1] = line end
    for _, line in ipairs(others) do out[#out+1] = line end
    for pos, i in ipairs(sorted) do subs[i] = out[pos] end
    return sel
end

function TimingOperations.showCPS(subs, sel)
    local totalChars, totalMs, maxCps, maxIdx = 0, 0, 0, nil
    for _, i in ipairs(sel) do
        local l = subs[i]
        if validateDuration(l) then
            local c = countCharacters(l.text)
            local cps = calcCPS(l)
            totalChars = totalChars + c
            totalMs    = totalMs    + (l.end_time - l.start_time)
            if cps > maxCps then maxCps = cps; maxIdx = i end
        end
    end
    local avg = totalMs > 0 and totalChars / (totalMs / 1000) or 0
    showMsg(string.format(L("msg_avg_cps"), #sel, avg) .. string.format("\nMax CPS: %.2f%s", maxCps,
        maxIdx and (" on line " .. tostring(maxIdx)) or ""))
end

function TimingOperations.timePicker(subs, sel)
    if #sel == 0 then showMsg(L("err_no_selection")); return sel end
    table.sort(sel)

    local btn, res = aegisub.dialog.display({
        { class="checkbox", name="include_partial", label=L("lbl_include_partial"), value=true, x=0, y=0, width=6, height=1 },
    }, { L("btn_ok"), L("btn_cancel") }, { cancel = L("btn_cancel") })
    if btn ~= L("btn_ok") then return sel end

    local minStart, maxEnd
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isEditableDialogue(l) and validateDuration(l) then
            if not minStart or l.start_time < minStart then minStart = l.start_time end
            if not maxEnd or l.end_time > maxEnd then maxEnd = l.end_time end
        end
    end
    if not minStart or not maxEnd then showMsg(L("err_no_active_dialogue")); return sel end

    local includePartial = res.include_partial
    local newSel = {}
    for i = 1, #subs do
        local l = subs[i]
        if isEditableDialogue(l) and validateDuration(l) then
            local inRange
            if includePartial then
                inRange = l.start_time < maxEnd and l.end_time > minStart
            else
                inRange = l.start_time >= minStart and l.end_time <= maxEnd
            end
            if inRange then newSel[#newSel+1] = i end
        end
    end
    showMsg(string.format(
        "Time range: %s - %s\nMode: %s\nActive dialogue lines selected: %d",
        msToAssTime(minStart),
        msToAssTime(maxEnd),
        includePartial and "partial overlap" or "fully contained",
        #newSel
    ))
    return newSel
end

local function parseDialogueRaw(line)
    line = trimText(line)
    local prefix, fields = splitEventLine(line)
    if not prefix then return nil end
    return {
        comment    = prefix == "Comment",
        layer      = tonumber(fields[1]) or 0,
        start_time = assTimeToMs(fields[2]),
        end_time   = assTimeToMs(fields[3]),
        style      = trimText(fields[4]),
        actor      = trimText(fields[5]),
        margin_l   = tonumber(fields[6]) or 0,
        margin_r   = tonumber(fields[7]) or 0,
        margin_t   = tonumber(fields[8]) or 0,
        effect     = trimText(fields[9]),
        text       = fields[10],
    }
end

local function splitImportLines(content)
    local lines = {}
    content = normalizeString(content):gsub("\r\n", "\n"):gsub("\r", "\n")
    for line in (content .. "\n"):gmatch("([^\n]*)\n") do
        if trimText(line) ~= "" then
            local parsed = parseDialogueRaw(line)
            if parsed then lines[#lines+1] = parsed
            else lines[#lines+1] = { text = trimText(line) } end
        end
    end
    return lines
end

function TimingOperations.importText(subs, sel)
    table.sort(sel); if #sel == 0 then return end
    local btn, res = aegisub.dialog.display({
        { class="label",    label=L("lbl_paste_dialogue"), x=0, y=0, width=8, height=1 },
        { class="textbox",  name="content", text="", x=0, y=1, width=80, height=16 },
        { class="checkbox", name="as_comment", label=L("lbl_import_as_comments"), value=false, x=0, y=17, width=8, height=1 }
    }, { L("btn_import"), L("btn_cancel") })
    if btn ~= L("btn_import") then return end
    local entries = splitImportLines(res.content)
    if #entries == 0 then return end
    local insertAfter = sel[#sel]
    local function applyEntry(base, entry)
        local nl = cloneLine(base)
        if entry.style then
            nl.layer    = entry.layer
            nl.style    = entry.style
            nl.actor    = entry.actor
            nl.margin_l = entry.margin_l
            nl.margin_r = entry.margin_r
            nl.margin_t = entry.margin_t
            nl.effect   = entry.effect
            nl.comment  = entry.comment
        end
        nl.text = res.as_comment and not entry.style and ("{" .. entry.text .. "}") or entry.text
        return nl
    end
    if #sel == #entries then
        for idx, i in ipairs(sel) do
            local entry = entries[idx]
            local l = applyEntry(subs[i], entry)
            if entry.start_time and entry.end_time then
                l.start_time, l.end_time = entry.start_time, entry.end_time
            else
                l.start_time, l.end_time = subs[i].start_time, subs[i].end_time
            end
            subs[i] = l
        end
        return
    end
    local source = subs[sel[1]]
    for idx, entry in ipairs(entries) do
        local base = (idx <= #sel and subs[sel[idx]]) or source
        local l = applyEntry(base, entry)
        if entry.start_time and entry.end_time then
            l.start_time, l.end_time = entry.start_time, entry.end_time
        else
            l.start_time, l.end_time = base.start_time, base.end_time
        end
        if idx <= #sel then subs[sel[idx]] = l
        else subs.insert(insertAfter + idx - #sel, l) end
    end
    local newSel = {}
    for _, i in ipairs(sel) do newSel[#newSel+1] = i end
    for k = 1, #entries - #sel do newSel[#newSel+1] = insertAfter + k end
    return newSel
end

function TimingOperations.joinLines(subs, sel)
    sel = collectEditableSelection(subs, sel)
    if #sel < 2 then return sel end
    table.sort(sel)
    local first, last = subs[sel[1]], subs[sel[#sel]]
    local parts = {}
    for _, i in ipairs(sel) do parts[#parts+1] = stripComments(stripTags(subs[i].text)) end
    local merged = cloneLine(first); merged.end_time = last.end_time
    local leadTags = extractLeadingTagBlocks(first.text)
    local mergedText = joinTextParts(parts)
    merged.text = (leadTags ~= "" and leadTags or "") .. mergedText
    subs[sel[1]] = merged
    for k = #sel, 2, -1 do subs.delete(sel[k]) end
    return { sel[1] }
end

local function isSplitBoundary(c, comma) if SENTENCE_SPLIT_CHARS[c] then return true end; if comma == true and COMMA_SPLIT_CHARS[c] then return true end; return false end
local function isSplitIndex(chars, i, comma)
    local c = chars[i]
    if isSplitBoundary(c, comma) then return true end
    return c == "-" and chars[i-1] == " " and chars[i+1] == " "
end

local function splitTextByPunctuation(text, comma)
    local chars = splitUtf8Chars(text)
    local segments, current, i = {}, {}, 1
    while i <= #chars do
        if chars[i] == "{" then
            while i <= #chars do
                current[#current+1] = chars[i]
                if chars[i] == "}" then i = i + 1; break end
                i = i + 1
            end
        else
            current[#current+1] = chars[i]
            if isSplitIndex(chars, i, comma) then
                local j = i
                while j + 1 <= #chars and isSplitBoundary(chars[j+1], comma) do
                    j = j + 1; current[#current+1] = chars[j]
                end
                local seg = trimText(table.concat(current))
                if hasVisibleSegmentText(seg) then segments[#segments+1] = seg end
                current = {}; i = j + 1
                while i <= #chars and isWhitespaceChar(chars[i]) do i = i + 1 end
            else
                i = i + 1
            end
        end
    end
    local tail = trimText(table.concat(current))
    if hasVisibleSegmentText(tail) then segments[#segments+1] = tail end
    if #segments < 2 then return nil end
    local inherited = extractLeadingTagBlocks(text)
    local final = {}
    for _, seg in ipairs(segments) do
        local n = ensureInheritedTags(seg, inherited)
        if hasVisibleSegmentText(n) then final[#final+1] = n end
    end
    if #final < 2 then return nil end
    return final
end

local function splitLineByPunctuationFallback(subs, i, comma)
    local l = subs[i]
    if not isEditableDialogue(l) or not validateDuration(l) then return 0 end
    local segments = splitTextByPunctuation(l.text, comma); if not segments then return 0 end
    local weights = {}; for k, s in ipairs(segments) do weights[k] = countCharacters(s) end
    local durations = allocateDurationsByWeights(weights, l.end_time - l.start_time); if not durations then return 0 end
    local cur = l.start_time
    for k, seg in ipairs(segments) do
        local nl = cloneLine(l); nl.text = seg
        nl.start_time = cur; nl.end_time = cur + durations[k]
        if k == 1 then subs[i] = nl else subs.insert(i + k - 1, nl) end
        cur = nl.end_time
    end
    return #segments - 1
end

local function _splitLineByPunctuation(subs, sel, comma)
    table.sort(sel, function(a, b) return a > b end)
    local inserted = {}
    for _, i in ipairs(sel) do inserted[i] = splitLineByPunctuationFallback(subs, i, comma) end
    return remapSelectionAfterInsertion(sel, inserted)
end

function TimingOperations.splitBySentence(subs, sel) return _splitLineByPunctuation(subs, sel, false) end
function TimingOperations.splitByComma(subs, sel)    return _splitLineByPunctuation(subs, sel, true) end

local function countWordsBeforeLinebreak(text)
    local before = normalizeString(text)
    local nPos = before:find("\\[Nn]")
    if not nPos then return nil end
    before = before:sub(1, nPos - 1)
    local count, inWord, depth = 0, false, 0
    for _, ch in ipairs(splitUtf8Chars(before)) do
        if ch == "{" then depth = depth + 1; inWord = false
        elseif ch == "}" then depth = math.max(0, depth - 1); inWord = false
        elseif depth > 0 then
        elseif isWhitespaceChar(ch) then inWord = false
        elseif not inWord then count = count + 1; inWord = true end
    end
    return count
end

local function pivotLinebreakText(text)
    local beforeCount = countWordsBeforeLinebreak(text)
    if not beforeCount then return text, false end
    local clean = normalizeString(text):gsub("\\[Nn]", " ")
    clean = clean:gsub("[ \t]+", " ")
    clean = trimText(clean)
    local chars = splitUtf8Chars(clean)
    local words, inWord, depth, startAt = {}, false, 0, nil
    for idx, ch in ipairs(chars) do
        if ch == "{" then
            if inWord then words[#words].finish = idx - 1; inWord = false end
            depth = depth + 1
        elseif ch == "}" then
            depth = math.max(0, depth - 1)
        elseif depth == 0 and isWhitespaceChar(ch) then
            if inWord then words[#words].finish = idx - 1; inWord = false end
        elseif depth == 0 and not inWord then
            startAt = idx
            words[#words+1] = { start = startAt, finish = idx }
            inWord = true
        elseif depth == 0 and inWord then
            words[#words].finish = idx
        end
    end
    if #words < 2 then return text, false end
    local candidateCount = #words - 1
    local target = beforeCount + 1
    if target > candidateCount then target = 1 end
    if target < 1 then target = 1 end
    local splitAt = words[target].finish
    local left, right = {}, {}
    for idx = 1, splitAt do left[#left+1] = chars[idx] end
    for idx = splitAt + 1, #chars do right[#right+1] = chars[idx] end
    return trimText(table.concat(left)) .. " \\N" .. trimText(table.concat(right)), true
end

function TimingOperations.pivotLinebreak(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isEditableDialogue(l) and normalizeString(l.text):find("\\[Nn]") then
            local changed
            l.text, changed = pivotLinebreakText(l.text)
            if changed then subs[i] = l end
        end
    end
end

function TimingOperations.splitByLinebreak(subs, sel)
    table.sort(sel, function(a, b) return a > b end)
    local inserted = {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if isEditableDialogue(l) and normalizeString(l.text):find("\\[Nn]") and validateDuration(l) then
            local parts = splitByLinebreak(l.text)
            if #parts >= 2 then
                local inherited = extractLeadingTagBlocks(l.text)
                local final = {}
                for _, p in ipairs(parts) do
                    local seg = ensureInheritedTags(p, inherited)
                    if hasVisibleSegmentText(seg) then final[#final+1] = seg end
                end
                if #final >= 2 then
                    local alloc = _allocateTimeDuration(final, l.end_time - l.start_time)
                    if alloc then
                        local first = cloneLine(l); first.text = final[1]; first.end_time = first.start_time + alloc[1]
                        subs[i] = first; local cur = first.end_time
                        for p = 2, #final do
                            local nl = cloneLine(l); nl.text = final[p]
                            nl.start_time = cur; nl.end_time = cur + alloc[p]
                            subs.insert(i + p - 1, nl); cur = nl.end_time
                        end
                        inserted[i] = #final - 1
                    end
                end
            end
        end
    end
    return remapSelectionAfterInsertion(sel, inserted)
end

function TimingOperations.smartLineBreak(subs, sel)
    local STRONG_CONJ = {
        ["pero"]=true,["mas"]=true,["sino"]=true,["aunque"]=true,["porque"]=true,["pues"]=true,
        ["si"]=true,["aun"]=true,["cuando"]=true,["mientras"]=true,["donde"]=true,["como"]=true,
        ["y"]=true,["e"]=true,["o"]=true,["u"]=true,["ni"]=true,
        ["but"]=true,["and"]=true,["or"]=true,["so"]=true,["yet"]=true,["if"]=true,["when"]=true,
        ["while"]=true,["because"]=true,["although"]=true,["though"]=true,["unless"]=true,["whereas"]=true,
    }
    local TIGHT_FOLLOWER = {
        ["que"]=true,["cual"]=true,["cuales"]=true,["quien"]=true,["quienes"]=true,
        ["cuyo"]=true,["cuya"]=true,["cuyos"]=true,["cuyas"]=true,
        ["that"]=true,["which"]=true,["who"]=true,["whom"]=true,["whose"]=true,
    }
    local FUNCTION_TRAIL = {
        ["el"]=true,["la"]=true,["los"]=true,["las"]=true,
        ["un"]=true,["una"]=true,["unos"]=true,["unas"]=true,["lo"]=true,
        ["a"]=true,["ante"]=true,["bajo"]=true,["con"]=true,["contra"]=true,
        ["de"]=true,["desde"]=true,["en"]=true,["entre"]=true,["hacia"]=true,
        ["hasta"]=true,["para"]=true,["por"]=true,["sin"]=true,["sobre"]=true,["tras"]=true,
        ["durante"]=true,["mediante"]=true,
        ["mi"]=true,["mis"]=true,["tu"]=true,["tus"]=true,["su"]=true,["sus"]=true,
        ["nuestro"]=true,["nuestra"]=true,["nuestros"]=true,["nuestras"]=true,
        ["vuestro"]=true,["vuestra"]=true,["vuestros"]=true,["vuestras"]=true,
        ["the"]=true,["an"]=true,["of"]=true,["to"]=true,["in"]=true,["on"]=true,["at"]=true,
        ["by"]=true,["for"]=true,["with"]=true,["from"]=true,["into"]=true,["onto"]=true,["upon"]=true,
        ["my"]=true,["your"]=true,["his"]=true,["her"]=true,["our"]=true,["their"]=true,["its"]=true,
    }
    local cfg = {
        minLength = 15, imbalanceWeight = 1000,
        shortCharsPenalty = 80, minChars = 5,
        shortWordsPenalty = 150, minWords = 2,
        overflowPenalty = 40, sentenceEndBonus = 14, softPauseBonus = 6,
        conjunctionBonus = 40, tightFollowerPenalty = 25,
        functionTrailPenalty = 18, orphanConjPenalty = 8,
    }
    local function firstWordLower(text)
        local t = trimText(text); if t == "" then return nil end
        if startsWith(t, INV_QUESTION)    then t = t:sub(#INV_QUESTION + 1) end
        if startsWith(t, INV_EXCLAMATION) then t = t:sub(#INV_EXCLAMATION + 1) end
        t = t:gsub("^[%-%(%[\"'%s]+", "")
        local w = t:match("^([^%s%c%p]+)")
        if not w or w == "" then return nil end
        return unicodeLower(w)
    end
    local function lastWordLower(text)
        local t = trimText(text); t = t:gsub("[%s%p]+$", "")
        local w = t:match("([^%s%c%p]+)$")
        if not w or w == "" then return nil end
        return unicodeLower(w)
    end
    local meta, styles = nil, nil
    if karaskel and type(karaskel.collect_head) == "function" then
        local ok, m, s = pcall(karaskel.collect_head, subs, false)
        if ok then meta = m; styles = s end
    end
    local videoWidth = 1920
    if aegisub and type(aegisub.video_size) == "function" then
        local ok, w = pcall(aegisub.video_size)
        if ok then
            if type(w) == "table" and tonumber(w.width) then videoWidth = tonumber(w.width)
            elseif tonumber(w) then videoWidth = tonumber(w) end
        end
    end
    local function getExtents(text, style)
        local clean = stripComments(stripTags(text))
        if aegisub and type(aegisub.text_extents) == "function" then
            local ok, w = pcall(function() return aegisub.text_extents(style, clean) end)
            if ok and type(w) == "number" then return w end
        end
        local fs = 24
        if type(style) == "table" and tonumber(style.fontsize) then fs = tonumber(style.fontsize) end
        return countCharacters(clean) * math.max(1, fs * 0.5)
    end
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isEditableDialogue(line) then
            if meta and styles and karaskel and karaskel.preproc_line then
                pcall(function() karaskel.preproc_line(subs, meta, styles, line) end)
            end
            if not normalizeString(line.text):find("\\N", 1, true) then
                local rawText = normalizeString(line.text)
                if unicodeLenSafe(stripComments(stripTags(rawText))) >= cfg.minLength then
                    local style = line.styleref or (styles and styles[line.style]) or {}
                    local mL = normalizeNumber(line.margin_l, 0); local mR = normalizeNumber(line.margin_r, 0)
                    if mL <= 0 then mL = normalizeNumber(style.margin_l, 0) end
                    if mR <= 0 then mR = normalizeNumber(style.margin_r, 0) end
                    local available = videoWidth - mL - mR
                    local needs = available > 0 and getExtents(rawText, style) > available
                    if needs then
                        local bestSplit, bestCost = nil, math.huge
                        local searchPos = 1
                        while true do
                            local sp = rawText:find(" ", searchPos, true); if not sp then break end
                            local prefix = rawText:sub(1, sp)
                            if countLiteral(prefix, "{") == countLiteral(prefix, "}") then
                                local p1 = rawText:sub(1, sp - 1)
                                local p2 = trimText(rawText:sub(sp + 1))
                                if hasVisibleSegmentText(p1) and hasVisibleSegmentText(p2) then
                                    local w1, w2 = getExtents(p1, style), getExtents(p2, style)
                                    local total = w1 + w2
                                    local imb = total > 0 and math.abs(w1 - w2) / total or 1
                                    local cost = imb * imb * cfg.imbalanceWeight
                                    if countCharacters(p2) < cfg.minChars then cost = cost + cfg.shortCharsPenalty end
                                    if countWords(p2)      < cfg.minWords then cost = cost + cfg.shortWordsPenalty end
                                    if w1 > available or w2 > available then cost = cost + cfg.overflowPenalty end
                                    local cp1 = trimText(stripComments(stripTags(p1)))
                                    local cp2 = trimText(stripComments(stripTags(p2)))
                                    local lc = cp1:sub(-1)
                                    if lc == "." or lc == "!" or lc == "?" then cost = cost - cfg.sentenceEndBonus
                                    elseif lc == "," or lc == ";" or lc == ":" then cost = cost - cfg.softPauseBonus end
                                    local fw = firstWordLower(cp2)
                                    if fw then
                                        if STRONG_CONJ[fw]    then cost = cost - cfg.conjunctionBonus
                                        elseif TIGHT_FOLLOWER[fw] then cost = cost + cfg.tightFollowerPenalty end
                                    end
                                    local lw = lastWordLower(cp1)
                                    if lw then
                                        if FUNCTION_TRAIL[lw] then cost = cost + cfg.functionTrailPenalty
                                        elseif STRONG_CONJ[lw] then cost = cost + cfg.orphanConjPenalty end
                                    end
                                    if cost < bestCost then bestCost = cost; bestSplit = sp end
                                end
                            end
                            searchPos = sp + 1
                        end
                        if bestSplit then
                            local before = (rawText:sub(1, bestSplit - 1):gsub("%s+$", ""))
                            local after = trimText(rawText:sub(bestSplit + 1))
                            line.text = before .. " \\N" .. after
                            subs[i] = line
                        end
                    end
                end
            end
        end
    end
end

end

local trimWS = trimText

local function parseTime(t)
    t = trimWS(t)
    local h, m, s, frac = t:match("(%d+):(%d+):(%d+)%.(%d+)")
    if h then return clockToMs(h, m, s, frac) end
    local h2, m2, s2 = t:match("(%d+):(%d+):(%d+)")
    if h2 then return clockToMs(h2, m2, s2, nil) end
    return nil
end

local function timeInt(s1, e1, s2, e2)
    local s, e = math.max(s1, s2), math.min(e1, e2)
    return s < e and (e - s) or 0
end

local function parseDialogue(l)
    l = trimWS(l); if not l:match("^Dialogue:") then return nil end
    local _, fields = splitEventLine(l)
    if not fields then return nil end
    local f = {}
    for i = 1, 10 do f[i] = trimWS(fields[i]) end
    return f
end

local function sameLayerMatch(line, src, same_layers)
    if not same_layers then return true end
    return (tonumber(line.layer) or 0) == (tonumber(src.layer) or 0)
end

local function antEffects(subs, sel, raw, same_layers)
    local src = {}
    for l in raw:gmatch("[^\r\n]+") do
        local f = parseDialogue(l)
        if f then
            local s, e, ef, ly = parseTime(f[2]), parseTime(f[3]), f[9], tonumber(f[1]) or 0
            if s and e and ef ~= "" then table.insert(src, { start = s, end_time = e, effect = ef, layer = ly }) end
        end
    end
    if #src == 0 then return 0 end
    local mod = 0
    for _, i in ipairs(sel) do
        local l = subs[i]; local add = {}
        for _, s in ipairs(src) do
            if sameLayerMatch(l, s, same_layers) and timeInt(l.start_time, l.end_time, s.start, s.end_time) > 0 then table.insert(add, s.effect) end
        end
        if #add > 0 then
            if l.effect ~= "" then table.insert(add, 1, l.effect) end
            l.effect = table.concat(add, "; "); mod = mod + 1
        end
        subs[i] = l
    end
    return mod
end

local function antLines(subs, sel, raw, comm, same_layers)
    local src = {}
    for l in raw:gmatch("[^\r\n]+") do
        local f = parseDialogue(l)
        if f then
            local s, e, tx, ly = parseTime(f[2]), parseTime(f[3]), f[10], tonumber(f[1]) or 0
            if s and e and tx ~= "" and not tx:match("^{=%d+}$") then
                table.insert(src, { start = s, end_time = e, text = tx, layer = ly })
            end
        end
    end
    if #src == 0 then return 0 end
    local mod = 0
    for _, i in ipairs(sel) do
        local l = subs[i]; local add = ""
        for _, s in ipairs(src) do
            if sameLayerMatch(l, s, same_layers) and timeInt(l.start_time, l.end_time, s.start, s.end_time) > 0 then
                local t = comm and ("{" .. s.text .. "}") or s.text
                add = (add == "" and t or add .. " " .. t)
            end
        end
        if add ~= "" then l.text = l.text .. " " .. add; mod = mod + 1 end
        subs[i] = l
    end
    return mod
end

local function antActor(subs, sel, raw, same_layers)
    local src = {}
    for l in raw:gmatch("[^\r\n]+") do
        local f = parseDialogue(l)
        if f then
            local s, e, ac, ly = parseTime(f[2]), parseTime(f[3]), f[5], tonumber(f[1]) or 0
            if s and e and ac ~= "" then table.insert(src, { start = s, end_time = e, actor = ac, layer = ly }) end
        end
    end
    if #src == 0 then return 0 end
    local mod = 0
    for _, i in ipairs(sel) do
        local l = subs[i]; local ba, bd = nil, 0
        for _, s in ipairs(src) do
            if sameLayerMatch(l, s, same_layers) then
                local d = timeInt(l.start_time, l.end_time, s.start, s.end_time)
                if d > bd then bd, ba = d, s.actor end
            end
        end
        if ba then l.actor = ba; mod = mod + 1 end
        subs[i] = l
    end
    return mod
end

local DataImportOps = {}
DataImportOps.tagNameOrder = {
    "iclip","clip","move","pos","org","fade","fad","alpha","blur","bord","xbord","ybord",
    "shad","xshad","yshad","fscx","fscy","fsp","frx","fry","fax","fay","fs","fn",
    "be","b","i","u","s","q","pbo","p","r","t","kf","ko","k","K","fe",
}

function DataImportOps.tagName(token)
    token = normalizeString(token)
    if token:match("^\\[1234]c") then return token:match("^\\([1234]c)") end
    if token:match("^\\c%f[^%a]") then return "1c" end
    if token:match("^\\[1234]a") then return token:match("^\\([1234]a)") end
    if token:match("^\\frz") or token:match("^\\fr[^%a]") then return "frz" end
    if token:match("^\\an") or token:match("^\\a[^%a]") then return "an" end
    if token:match("^\\pos") or token:match("^\\move") then return "position" end
    if token:match("^\\i?clip") then return "clip" end
    if token:match("^\\fad") or token:match("^\\fade") then return "fade" end
    if token:match("^\\fn") then return "fn" end
    if token:match("^\\r") then return "r" end
    for _, name in ipairs(DataImportOps.tagNameOrder) do
        if token:match("^\\+" .. name .. "%f[^%a]") then return name end
    end
    return token:match("^\\([%a%d]+)")
end

function DataImportOps.tagTokens(inner)
    local out, pos, len = {}, 1, #normalizeString(inner)
    inner = normalizeString(inner)
    while pos <= len do
        local s = inner:find("\\", pos, true)
        if not s then break end
        local nextSlash = inner:find("\\", s + 1, true) or (len + 1)
        local rawName = inner:match("^\\([%a%d]+)", s) or ""
        local p = s + 1 + #rawName
        if inner:sub(p, p) == "(" then
            local depth, j = 0, p
            while j <= len do
                local ch = inner:sub(j, j)
                if ch == "(" then depth = depth + 1
                elseif ch == ")" then
                    depth = depth - 1
                    if depth == 0 then j = j + 1; break end
                end
                j = j + 1
            end
            out[#out+1] = inner:sub(s, math.min(j - 1, len))
            pos = math.max(j, s + 1)
        else
            out[#out+1] = inner:sub(s, nextSlash - 1)
            pos = nextSlash
        end
    end
    return out
end

function DataImportOps.splitInitial(text)
    text = normalizeString(text)
    local comments, tags, cursor = {}, {}, 1
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor)
        if not s or s ~= cursor then break end
        local block = text:sub(s, e)
        if isOverrideBlock(block) then break end
        comments[#comments+1] = block
        cursor = e + 1
    end
    while text:sub(cursor, cursor) == "{" do
        local s, e = text:find("%b{}", cursor)
        if not s or s ~= cursor then break end
        local block = text:sub(s, e)
        if not isOverrideBlock(block) then break end
        tags[#tags+1] = block:sub(2, -2)
        cursor = e + 1
    end
    return table.concat(comments, ""), table.concat(tags, ""), text:sub(cursor)
end

function DataImportOps.mergeInitialTags(text, importedInner)
    local names, sourceTokens = {}, DataImportOps.tagTokens(importedInner)
    for _, token in ipairs(sourceTokens) do
        local name = DataImportOps.tagName(token)
        if name and name ~= "" then names[name] = true end
    end
    if next(names) == nil then return text, false end
    local comments, targetInner, rest = DataImportOps.splitInitial(text)
    local kept = {}
    for _, token in ipairs(DataImportOps.tagTokens(targetInner)) do
        local name = DataImportOps.tagName(token)
        if not (name and names[name]) then kept[#kept+1] = token end
    end
    local merged = comments .. "{" .. importedInner .. table.concat(kept) .. "}" .. rest
    return merged, merged ~= normalizeString(text)
end

function DataImportOps.importTags(subs, sel, raw, same_layers)
    local src = {}
    for l in normalizeString(raw):gmatch("[^\r\n]+") do
        local f = parseDialogue(l)
        if f then
            local s, e, ly = parseTime(f[2]), parseTime(f[3]), tonumber(f[1]) or 0
            local _, tags = DataImportOps.splitInitial(f[10])
            if s and e and tags ~= "" then src[#src+1] = { start = s, end_time = e, layer = ly, tags = tags } end
        end
    end
    if #src == 0 then return 0 end
    local mod = 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isDialogue(line) then
            local imported = {}
            for _, s in ipairs(src) do
                if sameLayerMatch(line, s, same_layers) and timeInt(line.start_time, line.end_time, s.start, s.end_time) > 0 then
                    imported[#imported+1] = s.tags
                end
            end
            if #imported > 0 then
                local changed
                line.text, changed = DataImportOps.mergeInitialTags(line.text, table.concat(imported))
                if changed then mod = mod + 1 end
            end
            subs[i] = line
        end
    end
    return mod
end

local function spParseDialogueLine(line)
    line = trimWS(line)
    local prefix, f = splitEventLine(line)
    if not prefix then return nil end
    return {
        line_type = prefix == "Comment" and "comment" or "dialogue", layer = tonumber(f[1]) or 0,
        start_time = f[2], end_time = f[3],
        style = f[4], actor = f[5],
        margin_l = tonumber(f[6]) or 0, margin_r = tonumber(f[7]) or 0, margin_t = tonumber(f[8]) or 0,
        effect = f[9], text = f[10],
    }
end

local function antSongs(subs, sel, raw)
    if not sel or #sel == 0 then return 0 end
    if not raw or raw:gsub("%s", "") == "" then return 0 end
    local group, sync_point = {}, nil
    for line in raw:gmatch("[^\r\n]+") do
        line = trimWS(line)
        if line ~= "" then
            local p = spParseDialogueLine(line)
            if p then
                if p.line_type == "comment" and p.layer == 50 then
                    local s = parseTime(p.start_time); if s then sync_point = s end
                end
                table.insert(group, p)
            end
        end
    end
    if not sync_point then
        showMsg(L("err_no_sync_point")); return 0
    end
    if #group == 0 then return 0 end
    local lines_added = 0
    local insert_pos = sel[#sel]
    for idx = #sel, 1, -1 do
        local target = subs[sel[idx]]
        if target and target.start_time then
            local shift = target.start_time - sync_point
            local marker = target.effect or ""
            for i = #group, 1, -1 do
                local p = group[i]
                local s = parseTime(p.start_time); local e = parseTime(p.end_time)
                if s and e then
                    local ns, ne = s + shift, e + shift
                    if ns >= 0 and ne >= 0 then
                        local nl = {
                            class = "dialogue", comment = (p.line_type == "comment"),
                            layer = p.layer, start_time = ns, end_time = ne,
                            style = p.style, actor = marker ~= "" and marker or p.actor,
                            margin_l = p.margin_l, margin_r = p.margin_r, margin_t = p.margin_t, margin_b = 0,
                            effect = p.effect, text = p.text,
                        }
                        subs.insert(insert_pos + 1, nl)
                        lines_added = lines_added + 1
                    end
                end
            end
        end
    end
    return lines_added
end

local fr_to, ms_from = aegisub.frame_from_ms, aegisub.ms_from_frame
local function getFps()
    local m1, m0
    if ms_from then
        local ok1, v1 = pcall(ms_from, 1)
        local ok0, v0 = pcall(ms_from, 0)
        if ok1 then m1 = v1 end
        if ok0 then m0 = v0 end
    end
    return (m1 and m0 and m1 ~= m0) and 1000/(m1-m0) or 23.976
end
local function toFrame(t)
    local f = msToFrame(t)
    if f then return f end
    return math.floor(t * getFps() / 1000 + 0.5)
end
local function toMs(f)
    local m = frameToMs(f)
    if m then return m end
    return math.floor(f * 1000 / getFps() + 0.5)
end
local function getKfSet()
    local kfs = getKeyframes()
    if not kfs or #kfs == 0 then return {}, {} end
    local set = {}; for _, k in ipairs(kfs) do set[k] = true end
    return kfs, set
end
local function ktSnap(t) return toMs(toFrame(t)) end
local function ktIsOnKf(t_ms, kfs)
    local f = toFrame(t_ms)
    for _, k in ipairs(kfs) do if k == f then return true end; if k > f then break end end
    return false
end
local function ktFindKfForward(orig, max_ms, kfs)
    local f0, fl = toFrame(orig), toFrame(orig + max_ms)
    for _, k in ipairs(kfs) do if k > f0 and k <= fl then return toMs(k) end; if k > fl then break end end
end
local function ktFindKfBackward(orig, max_ms, kfs)
    local f0, fl = toFrame(orig), toFrame(orig - max_ms)
    local best
    for _, k in ipairs(kfs) do if k >= fl and k < f0 then best = k end; if k >= f0 then break end end
    if best then return toMs(best) end
end

local function collectStyles(subs, sel)
    local st, seen = { "All", "All Default", "Default+Alt" }, {}
    for _, i in ipairs(sel) do
        if subs[i].class == "dialogue" and not seen[subs[i].style] then
            seen[subs[i].style] = true; st[#st+1] = subs[i].style
        end
    end
    return st
end

do

local LZ = {}

LZ.lazyConfig = {
    weights = { proximity = 0.30, silence_q = 0.22, source_c = 0.13, clarity = 0.08, vad = 0.30, flux = 0.30 },
    cluster_max_dist = 120, min_cluster_mass = 0.6, min_score_threshold = 0.25,
    min_duration = 200, max_duration = 8000, epsilon = 50,
    thresholds = {
        [30] = { min_silence_dur = 350, reliability = 1.0 },
        [40] = { min_silence_dur = 120, reliability = 0.9 },
        [50] = { min_silence_dur = 120, reliability = 0.6 },
    },
}
LZ.tableConfig = {
    merge_gap_ms = 120, min_noise_ms = 80, edge_drop_ms = 60,
    w_cov = 0.65, w_prox = 0.25, w_frag = 0.10, sigma_ms = 200, eps = 1,
}
LZ.auxVad  = nil
LZ.auxFlux = nil

function LZ.normalizeProximity(d, w) if w <= 0 then return 0 end; return math.exp(-(d*d)/(w*w)) end
function LZ.normalizeSilenceQuality(d)
    if d < 100 then return 0.1
    elseif d < 500 then return 0.3 + 0.4 * (d - 100) / 400
    elseif d < 1500 then return 0.7 + 0.2 * (d - 500) / 1000
    else return 0.9 + 0.1 * (1 - math.exp(-(d - 1500) / 1000)) end
end
function LZ.getSourceConfidence(t) return (LZ.lazyConfig.thresholds[t] and LZ.lazyConfig.thresholds[t].reliability) or 0.5 end
function LZ.normalizeContextClarity(d) return 1 / (1 + d * d) end
function LZ.calculateScore(c, rt, sw, sd)
    local d = math.abs(c.time - rt)
    local fp = LZ.normalizeProximity(d, sw)
    local fq = LZ.normalizeSilenceQuality(c.duration or 0)
    local fc = LZ.getSourceConfidence(c.threshold)
    local fl = LZ.normalizeContextClarity(sd)
    local fflux, fvad = (c.flux_boost or 0), (c.vad_align or 0)
    local W = LZ.lazyConfig.weights
    return (fp*W.proximity)+(fq*W.silence_q)+(fc*W.source_c)+(fl*W.clarity)+(fflux*W.flux)+(fvad*W.vad)
end
function LZ.findClusters(cs, md)
    if not cs or #cs == 0 then return {} end
    if #cs < 2 then return { cs } end
    table.sort(cs, function(a, b) return a.time < b.time end)
    local cls, ccl = {}, { cs[1] }
    for i = 2, #cs do
        if cs[i].time - ccl[#ccl].time <= md then table.insert(ccl, cs[i])
        else table.insert(cls, ccl); ccl = { cs[i] } end
    end
    table.insert(cls, ccl); return cls
end
function LZ.weightedMedianTime(cl)
    table.sort(cl, function(a, b) return a.time < b.time end)
    local sum = 0; for _, p in ipairs(cl) do sum = sum + (p.score or 0) end
    if sum <= 0 then local mid = math.floor((#cl + 1) / 2); return cl[mid].time end
    local acc = 0
    for _, p in ipairs(cl) do acc = acc + (p.score or 0); if acc >= sum * 0.5 then return p.time end end
    return cl[#cl].time
end
function LZ.addLazyTag(l, t) addTag(l, "[LZ " .. t .. "]", true) end
function LZ.lowerBound(arr, t)
    local lo, hi = 1, #arr + 1
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if arr[mid].time < t then lo = mid + 1 else hi = mid end
    end
    return lo
end
function LZ.validateIntra(ns, ne, os, oe)
    if ns < os or ne > oe then return false, "out_of_range" end
    if ne - ns < LZ.lazyConfig.min_duration then return false, "min_dur" end
    return true
end
function LZ.clampIntra(ns, ne, os, oe)
    local ns2, ne2 = math.max(ns, os), math.min(ne, oe)
    if ne2 - ns2 < LZ.lazyConfig.min_duration then return false, "min_dur", ns, ne end
    return true, nil, ns2, ne2
end
function LZ.getDensity(t, s, ws)
    ws = ws or 5000
    local c, sw, ew = 0, t - ws/2, t + ws/2
    for _, seg in ipairs(s) do
        if not (seg["end"] <= sw or seg.start >= ew) then c = c + 1 end
    end
    return c / (ws / 1000)
end

function LZ.parseLazyFile(fp, t)
    local segs = {}; local fh = io.open(fp, "r"); if not fh then return segs end
    local cs = nil
    for l in fh:lines() do
        local ss = l:match("silence_start:%s*([%d%.]+)")
        if ss then cs = tonumber(ss) * 1000 end
        local se, sd = l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)")
        if se and cs then
            local dms = tonumber(sd) * 1000
            if dms >= ((LZ.lazyConfig.thresholds[t] and LZ.lazyConfig.thresholds[t].min_silence_dur) or 100) then
                table.insert(segs, { start = cs, ["end"] = tonumber(se) * 1000, duration = dms, threshold = t })
            end
            cs = nil
        end
    end
    fh:close(); return segs
end

function LZ.parseVADtsv(path)
    local segs, f = {}, io.open(path, "r"); if not f then return segs end
    local first = true
    for line in f:lines() do
        if first then first = false
        else
            local a, b = line:match("([%d%.]+)%s+([%d%.]+)")
            if a and b then table.insert(segs, { start = tonumber(a), ["end"] = tonumber(b) }) end
        end
    end
    f:close(); return segs
end

function LZ.parseFLUXtsv(path)
    local cands, f = {}, io.open(path, "r"); if not f then return cands end
    local first = true
    for line in f:lines() do
        if first then first = false
        else
            local t, ty, sc = line:match("([%d%.]+)%s+(%a+)%s+([%d%.]+)")
            if t and ty and sc then table.insert(cands, { time = tonumber(t), type = ty, score = tonumber(sc) }) end
        end
    end
    f:close(); return cands
end

function LZ.enrichWithAux(cands, flux, vad, want_type)
    local function nearest_flux(t)
        local best_d, best_s = math.huge, 0
        for _, c in ipairs(flux or {}) do
            if c.type == want_type then
                local d = math.abs(c.time - t)
                if d < best_d then best_d, best_s = d, c.score end
            end
        end
        if best_d <= 40 then return (1 - best_d / 40) * best_s else return 0 end
    end
    local function vad_margin(t)
        local best = math.huge
        for _, s in ipairs(vad or {}) do
            local d1 = math.abs((s.start or 0) - t); local d2 = math.abs((s["end"] or 0) - t)
            local d = (d1 < d2) and d1 or d2
            if d < best then best = d end
        end
        if best == math.huge then return 0 end
        return math.exp(-(best * best) / 1600)
    end
    for _, c in ipairs(cands) do c.flux_boost = nearest_flux(c.time); c.vad_align = vad_margin(c.time) end
end

function LZ.loadLazyData(fps)
    local rs = {}
    for t, p in pairs(fps) do for _, s in ipairs(LZ.parseLazyFile(p, t)) do table.insert(rs, s) end end
    table.sort(rs, function(a, b) return a.start < b.start end)
    local ss, se = {}, {}
    for _, s in ipairs(rs) do
        table.insert(ss, { time = s["end"],   duration = s.duration, threshold = s.threshold })
        table.insert(se, { time = s.start,    duration = s.duration, threshold = s.threshold })
    end
    local byTime = function(a, b) return a.time < b.time end
    table.sort(ss, byTime); table.sort(se, byTime)
    return ss, se, rs
end

function LZ.copyCandidate(ev) return { time = ev.time, duration = ev.duration, threshold = ev.threshold } end
function LZ.roundMs(x) return math.floor(x + 0.5) end
function LZ.orderedByStart(subs, sel)
    local arr = {}
    for _, i in ipairs(sel) do table.insert(arr, { i = i, st = subs[i].start_time }) end
    table.sort(arr, function(a, b) return a.st < b.st end)
    local out = {}; for _, e in ipairs(arr) do table.insert(out, e.i) end; return out
end
function LZ.stripLZ(effect) effect = effect or ""; return (effect:gsub("%s*%[LZ[^%]]*%]", "")) end

function LZ.tagDecider(l, os, oe, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
    if not enable_tagging or tag_mode == "None" then return end
    local chs = (apply_start and ns ~= os)
    local che = (apply_end and ne ~= oe)
    local scope_s = (tag_scope == "Both" or tag_scope == "Start only")
    local scope_e = (tag_scope == "Both" or tag_scope == "End only")
    if tag_mode == "Only 0ms" then
        if scope_s and apply_start and not chs then LZ.addLazyTag(l, "~0ms-s") end
        if scope_e and apply_end   and not che then LZ.addLazyTag(l, "~0ms-e") end
    elseif tag_mode == "Only changes" then
        if scope_s and chs then LZ.addLazyTag(l, string.format("Δs=%+dms", ns - os)) end
        if scope_e and che then LZ.addLazyTag(l, string.format("Δe=%+dms", ne - oe)) end
    elseif tag_mode == "Both" then
        if scope_s and apply_start then LZ.addLazyTag(l, chs and string.format("Δs=%+dms", ns - os) or "~0ms-s") end
        if scope_e and apply_end   then LZ.addLazyTag(l, che and string.format("Δe=%+dms", ne - oe) or "~0ms-e") end
    end
end

function LZ.rankFusionPick(cands, rt, is_start)
    local M = #cands; if M == 0 then return nil end; if M == 1 then return cands[1] end
    local function rank_by(fn, desc)
        local t = {}; for i, c in ipairs(cands) do t[i] = { i = i, v = fn(c) } end
        table.sort(t, function(a, b) if desc then return a.v > b.v else return a.v < b.v end end)
        local r = {}; for k, rec in ipairs(t) do r[rec.i] = k end; return r
    end
    local r_flux = rank_by(function(c) return c.flux_boost or 0 end, true)
    local r_vad  = rank_by(function(c) return c.vad_align  or 0 end, true)
    local r_prox = rank_by(function(c) return math.abs(c.time - rt) end, false)
    local r_dur  = rank_by(function(c) return c.duration or 0 end, true)
    local r_src  = rank_by(function(c) return LZ.getSourceConfidence(c.threshold) end, true)
    local best_i, best_sum = 1, 1e9
    for i = 1, M do
        local s = (r_flux[i]/M) + (r_vad[i]/M) + (r_prox[i]/M) + (r_dur[i]/M) + (r_src[i]/M)
        if s < best_sum then best_sum = s; best_i = i end
    end
    return cands[best_i]
end

function LZ.pickTime(cands, ref, is_start)
    local cls = LZ.findClusters(cands, LZ.lazyConfig.cluster_max_dist)
    local bc, bcm = nil, 0
    for _, cl in ipairs(cls) do
        local cm = 0; for _, p in ipairs(cl) do cm = cm + (p.score or 0) end
        if cm > bcm then bcm = cm; bc = cl end
    end
    if bc then
        local k = math.min(3, #bc); local nm = bcm / k
        if nm > LZ.lazyConfig.min_cluster_mass then return LZ.weightedMedianTime(bc), true end
    end
    table.sort(cands, function(a, b) return (a.score or 0) > (b.score or 0) end)
    if cands[1] and (cands[1].score or 0) > LZ.lazyConfig.min_score_threshold then return cands[1].time, true end
    local alt = LZ.rankFusionPick(cands, ref, is_start); if alt then return alt.time, true end
    return ref, false
end

function LZ.runClusterAnalysis(subs, sel, lim, files, opts)
    local ss, se, asg = LZ.loadLazyData(files); if #ss == 0 then return 0 end
    local modified = 0
    local apply_start, apply_end = opts.apply_start, opts.apply_end
    local enable_tagging, tag_mode, tag_scope = opts.enable_tagging, opts.tag_mode, opts.tag_scope
    aegisub.progress.task("Analyzing (Cluster, intra ±" .. tostring(lim) .. " ms)...")
    local seq = LZ.orderedByStart(subs, sel)
    for idx, ii in ipairs(seq) do
        aegisub.progress.set(idx / #seq * 100)
        local l = subs[ii]
        if l.class == "dialogue" then
            local os, oe = l.start_time, l.end_time
            local ns, ne = os, oe
            local den = LZ.getDensity((os + oe) / 2, asg)
            if apply_start then
                local sc = {}
                local hi = math.min(os + lim, oe - LZ.lazyConfig.min_duration)
                local k = LZ.lowerBound(ss, os)
                while ss[k] and ss[k].time <= hi do
                    table.insert(sc, LZ.copyCandidate(ss[k])); k = k + 1
                end
                if LZ.auxFlux or LZ.auxVad then LZ.enrichWithAux(sc, LZ.auxFlux, LZ.auxVad, "onset") end
                for _, cv in ipairs(sc) do cv.score = LZ.calculateScore(cv, os, lim, den) end
                if #sc > 0 then
                    local pt, ok = LZ.pickTime(sc, os, true)
                    if ok then ns = LZ.roundMs(pt) end
                end
            end
            if apply_end then
                local ec = {}
                local lo = math.max(oe - lim, os + LZ.lazyConfig.min_duration)
                local k = LZ.lowerBound(se, lo)
                while se[k] and se[k].time <= oe do
                    table.insert(ec, LZ.copyCandidate(se[k])); k = k + 1
                end
                if LZ.auxFlux or LZ.auxVad then LZ.enrichWithAux(ec, LZ.auxFlux, LZ.auxVad, "offset") end
                for _, cv in ipairs(ec) do cv.score = LZ.calculateScore(cv, oe, lim, den) end
                if #ec > 0 then
                    local pt, ok = LZ.pickTime(ec, oe, false)
                    if ok then ne = LZ.roundMs(pt) end
                end
            end
            if apply_start or apply_end then
                local changed = (ns ~= os) or (ne ~= oe)
                if changed then
                    local ok, why = LZ.validateIntra(ns, ne, os, oe)
                    if not ok then
                        local ok2, why2, ns2, ne2 = LZ.clampIntra(ns, ne, os, oe)
                        if ok2 then
                            l.start_time = ns2; l.end_time = ne2; modified = modified + 1
                            LZ.tagDecider(l, os, oe, ns2, ne2, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                        else
                            if enable_tagging then LZ.addLazyTag(l, "Reject:" .. (why2 or why)) end
                        end
                    else
                        l.start_time = ns; l.end_time = ne; modified = modified + 1
                        LZ.tagDecider(l, os, oe, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                    end
                else
                    LZ.tagDecider(l, os, oe, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                end
                subs[ii] = l
            end
        end
    end
    return modified
end

function LZ.normalizeVadToMs(vad_data)
    if not vad_data or #vad_data == 0 then return {} end
    local vmax = 0
    for _, s in ipairs(vad_data) do if s["end"] and s["end"] > vmax then vmax = s["end"] end end
    local in_ms = (vmax > 10000)
    local out = {}
    for _, s in ipairs(vad_data) do
        local a = in_ms and s.start    or (s.start    * 1000)
        local b = in_ms and s["end"]   or (s["end"]   * 1000)
        table.insert(out, { start = a, ["end"] = b })
    end
    table.sort(out, function(a, b) return a.start < b.start end)
    return out
end

function LZ.normalizeFluxToMs(flux_data)
    if not flux_data or #flux_data == 0 then return flux_data end
    local fmax = 0
    for _, c in ipairs(flux_data) do if c.time and c.time > fmax then fmax = c.time end end
    if fmax > 10000 then return flux_data end
    local out = {}
    for _, c in ipairs(flux_data) do out[#out+1] = { time = (c.time or 0) * 1000, type = c.type, score = c.score } end
    return out
end

function LZ.containingSilence(t, silences)
    local lo, hi, cand = 1, #silences, nil
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        if silences[mid].start <= t then cand = silences[mid]; lo = mid + 1
        else hi = mid - 1 end
    end
    if cand and t <= cand["end"] then return cand end
end

function LZ.mergeSilenceToIntervals(files)
    local all = {}
    for threshold, path in pairs(files or {}) do
        local fh = io.open(path, "r")
        if fh then
            local cur
            for line in fh:lines() do
                local ss = line:match("silence_start:%s*([%d%.]+)")
                if ss then cur = tonumber(ss) * 1000 end
                local se = line:match("silence_end:%s*([%d%.]+)")
                if se and cur then
                    table.insert(all, { start = cur, ["end"] = tonumber(se) * 1000, threshold = threshold })
                    cur = nil
                end
            end
            fh:close()
        end
    end
    table.sort(all, function(a, b) return a.start < b.start end)
    local merged = {}
    for _, sil in ipairs(all) do
        if #merged == 0 then
            table.insert(merged, { start = sil.start, ["end"] = sil["end"], count = 1 })
        else
            local last = merged[#merged]
            if sil.start <= last["end"] + 50 then
                last["end"] = math.max(last["end"], sil["end"])
                last.count = (last.count or 1) + 1
            else
                table.insert(merged, { start = sil.start, ["end"] = sil["end"], count = 1 })
            end
        end
    end
    return merged
end

function LZ.findFluxExact(t, flux_data, want_type, tol)
    tol = tol or 20
    for _, f in ipairs(flux_data or {}) do
        if f.type == want_type and math.abs((f.time or 0) - t) <= tol then return f.time end
    end
end
function LZ.findActivityBounds(os_ms, oe_ms, silences, flux_data)
    local t_start, t_end, has_fs, has_fe = nil, nil, false, false
    local s0 = LZ.containingSilence(os_ms, silences)
    local cand = s0 and (s0["end"] + 1) or os_ms
    if cand <= oe_ms then
        t_start = cand
        local fx = LZ.findFluxExact(t_start, flux_data, "onset", 30)
        if fx and fx >= os_ms then t_start = fx; has_fs = true end
    end
    local s1 = LZ.containingSilence(oe_ms, silences)
    cand = s1 and (s1.start - 1) or oe_ms
    if cand >= os_ms then
        t_end = cand
        local fx = LZ.findFluxExact(t_end, flux_data, "offset", 30)
        if fx and fx <= oe_ms then t_end = fx; has_fe = true end
    end
    return t_start, t_end, has_fs, has_fe
end

function LZ.runLazyFusionAnalysis(subs, sel, files, opts, flux_data)
    local silences = LZ.mergeSilenceToIntervals(files)
    local apply_start, apply_end = opts.apply_start, opts.apply_end
    local enable_tagging, tag_mode, tag_scope = opts.enable_tagging, opts.tag_mode, opts.tag_scope
    local modified = 0
    local seq = LZ.orderedByStart(subs, sel)
    aegisub.progress.task("Analyzing (LazyFusion v2 EFS)...")
    for idx, ii in ipairs(seq) do
        aegisub.progress.set(idx / #seq * 100)
        local l = subs[ii]
        if l.class == "dialogue" then
            local os_ms, oe_ms = l.start_time, l.end_time
            local ns, ne = os_ms, oe_ms
            local t_s, t_e, has_fs, has_fe = LZ.findActivityBounds(os_ms, oe_ms, silences, flux_data)
            if t_s and t_e then
                local ps = has_fs and 0 or 15
                local pe = has_fe and 0 or 15
                if apply_start then ns = t_s - ps; if ns < 0 then ns = 0 end end
                if apply_end   then ne = t_e + pe end
                if ne - ns < LZ.lazyConfig.min_duration then
                    local center = (t_s + t_e) / 2; local hm = LZ.lazyConfig.min_duration / 2
                    ns = center - hm; ne = center + hm
                    if ns < 0 then ns = 0 end
                end
            else
                if enable_tagging then LZ.addLazyTag(l, "NoActivity") end
            end
            local changed = (math.abs(ns - os_ms) > 1) or (math.abs(ne - oe_ms) > 1)
            if changed then
                local ok, why = LZ.validateIntra(ns, ne, os_ms, oe_ms)
                if not ok then
                    local ok2, why2, ns2, ne2 = LZ.clampIntra(ns, ne, os_ms, oe_ms)
                    if ok2 then
                        l.start_time = LZ.roundMs(ns2); l.end_time = LZ.roundMs(ne2)
                        modified = modified + 1
                        LZ.tagDecider(l, os_ms, oe_ms, ns2, ne2, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                    else
                        if enable_tagging then LZ.addLazyTag(l, "Reject:" .. (why2 or why)) end
                    end
                else
                    l.start_time = LZ.roundMs(ns); l.end_time = LZ.roundMs(ne)
                    modified = modified + 1
                    LZ.tagDecider(l, os_ms, oe_ms, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
                end
            else
                LZ.tagDecider(l, os_ms, oe_ms, ns, ne, apply_start, apply_end, enable_tagging, tag_mode, tag_scope)
            end
            subs[ii] = l
        end
    end
    return modified
end

function LZ.clamp(x, a, b) if x < a then return a elseif x > b then return b else return x end end
function LZ.mergeIntervals(ints, eps)
    table.sort(ints, function(a, b) return a.start < b.start end)
    local out = {}
    for _, it in ipairs(ints) do
        if #out == 0 then out[1] = { start = it.start, ["end"] = it["end"] }
        else
            local L = out[#out]
            if it.start <= L["end"] + (eps or 0) then
                if it["end"] > L["end"] then L["end"] = it["end"] end
            else
                out[#out+1] = { start = it.start, ["end"] = it["end"] }
            end
        end
    end
    return out
end
function LZ.intersect(a1, a2, b1, b2) local s = math.max(a1, b1); local e = math.min(a2, b2); if s < e then return s, e end end
function LZ.noiseInWindow(merged_silence, W1, W2, eps)
    local cut = {}
    for _, si in ipairs(merged_silence) do
        local s, e = LZ.intersect(W1, W2, si.start, si["end"])
        if s and e then cut[#cut+1] = { start = s, ["end"] = e } end
    end
    cut = LZ.mergeIntervals(cut, eps)
    local noise = {}; local cur = W1
    for _, si in ipairs(cut) do
        if si.start > cur + (eps or 0) then noise[#noise+1] = { start = cur, ["end"] = si.start } end
        cur = math.max(cur, si["end"])
    end
    if cur < W2 - (eps or 0) then noise[#noise+1] = { start = cur, ["end"] = W2 } end
    return noise
end
function LZ.totalMs(ints) local s = 0; for _, x in ipairs(ints) do s = s + (x["end"] - x.start) end; return s end
function LZ.mergeNoiseSmallGaps(noise, gap_ms)
    if #noise <= 1 then return noise end
    local out = { { start = noise[1].start, ["end"] = noise[1]["end"] } }
    for i = 2, #noise do
        local L = out[#out]
        local g = noise[i].start - L["end"]
        if g <= gap_ms then if noise[i]["end"] > L["end"] then L["end"] = noise[i]["end"] end
        else out[#out+1] = { start = noise[i].start, ["end"] = noise[i]["end"] } end
    end
    return out
end
function LZ.dropEdgeInconclusives(noise, W1, W2, edge_ms)
    if #noise == 0 then return noise end
    local has_inner = false
    for _, n in ipairs(noise) do if n.start > W1 and n["end"] < W2 then has_inner = true; break end end
    if not has_inner then return noise end
    local out = {}
    for _, n in ipairs(noise) do
        local len = n["end"] - n.start
        local el = (n.start <= W1 + LZ.tableConfig.eps); local er = (n["end"] >= W2 - LZ.tableConfig.eps)
        if (el or er) and len <= edge_ms then else out[#out+1] = n end
    end
    return (#out > 0) and out or noise
end
function LZ.center(t1, t2) return (t1 + t2) / 2 end
function LZ.groupNoise(noise, merge_gap_ms)
    if #noise == 0 then return {} end
    local groups, cur = {}, { noise[1] }
    for i = 2, #noise do
        local g = noise[i].start - noise[i-1]["end"]
        if g <= merge_gap_ms then cur[#cur+1] = noise[i]
        else groups[#groups+1] = cur; cur = { noise[i] } end
    end
    groups[#groups+1] = cur; return groups
end
function LZ.clusterSpan(G) return G[1].start, G[#G]["end"] end
function LZ.clusterScore(G, W1, W2)
    local gs = LZ.totalMs(G); local s, e = LZ.clusterSpan(G); local width = math.max(1, e - s)
    local cov = gs / width
    local prox = math.exp(-((LZ.center(s, e) - LZ.center(W1, W2))^2) / (LZ.tableConfig.sigma_ms^2))
    local frag = (#G - 1) / #G
    return LZ.tableConfig.w_cov * cov + LZ.tableConfig.w_prox * prox - LZ.tableConfig.w_frag * frag
end
function LZ.parseLazyFileTable(fp, t)
    local segs, dur = {}, nil
    local fh = io.open(fp, "r"); if not fh then return segs, dur end
    local cur
    for l in fh:lines() do
        local H, M, S = l:match("Duration:%s*(%d+):(%d+):([%d%.]+)")
        if H then dur = (tonumber(H)*3600 + tonumber(M)*60 + tonumber(S)) * 1000 end
        local ss = l:match("silence_start:%s*([%d%.]+)"); if ss then cur = tonumber(ss) * 1000 end
        local se, sd = l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)")
        if se and cur then
            local dms = tonumber(sd) * 1000
            if dms >= ((LZ.lazyConfig.thresholds[t] and LZ.lazyConfig.thresholds[t].min_silence_dur) or 100) then
                table.insert(segs, { start = cur, ["end"] = tonumber(se) * 1000, duration = dms, threshold = t })
            end
            cur = nil
        end
    end
    fh:close(); return segs, dur
end
function LZ.loadLazyDataTable(fps)
    local rs, maxdur = {}, 0
    for t, p in pairs(fps) do
        local lst, dur = LZ.parseLazyFileTable(p, t)
        if dur and dur > maxdur then maxdur = dur end
        for _, s in ipairs(lst) do table.insert(rs, s) end
    end
    table.sort(rs, function(a, b) return a.start < b.start end)
    local ss, se = {}, {}
    for _, s in ipairs(rs) do
        table.insert(ss, { time = s["end"],  duration = s.duration, threshold = s.threshold })
        table.insert(se, { time = s.start,   duration = s.duration, threshold = s.threshold })
    end
    return ss, se, rs, maxdur
end
function LZ.buildNoiseTable(merged_silences, W1, W2, save_path)
    local noise = LZ.noiseInWindow(merged_silences, W1, W2, LZ.tableConfig.eps)
    noise = LZ.mergeNoiseSmallGaps(noise, LZ.tableConfig.merge_gap_ms)
    if save_path then
        local f = io.open(save_path, "w")
        if f then
            f:write("start_ms,end_ms,duration_ms\n")
            for _, n in ipairs(noise) do f:write(string.format("%d,%d,%d\n", n.start, n["end"], n["end"] - n.start)) end
            f:close()
        end
    end
    return noise
end

function LZ.runTableAnalysis(subs, sel, lim, files, opts)
    local _, _, rs, maxdur = LZ.loadLazyDataTable(files)
    if not rs or #rs == 0 then return 0 end
    local raw = {}
    for _, s in ipairs(rs) do raw[#raw+1] = { start = s.start, ["end"] = s["end"] } end
    local merged = LZ.mergeIntervals(raw, LZ.tableConfig.eps)
    local base = files[40] or files[30] or files[50]
    if opts.table_csv and base and maxdur and maxdur > 0 then
        local folder = base:gsub("[^\\/]+$", "")
        LZ.buildNoiseTable(merged, 0, maxdur, folder .. "noise_table_global.csv")
    end
    local apply_start, apply_end = opts.apply_start, opts.apply_end
    local enable_tag, tag_mode, tag_scope = opts.enable_tagging, opts.tag_mode, opts.tag_scope
    local modified = 0
    local seq = LZ.orderedByStart(subs, sel)
    aegisub.progress.task("Analyzing (Table, intra ±" .. tostring(lim) .. " ms)...")
    for idx, ii in ipairs(seq) do
        aegisub.progress.set(idx / #seq * 100)
        local l = subs[ii]
        if l.class == "dialogue" then
            local os, oe = l.start_time, l.end_time
            local min_d = LZ.lazyConfig.min_duration
            local Slo, Shi = os, math.min(oe - min_d, os + lim)
            local Elo, Ehi = math.max(os + min_d, oe - lim), oe
            if Shi < Slo then Shi = Slo end
            if Ehi < Elo then Elo = Ehi end
            local noise = LZ.noiseInWindow(merged, os, oe, LZ.tableConfig.eps)
            noise = LZ.mergeNoiseSmallGaps(noise, LZ.tableConfig.merge_gap_ms)
            noise = LZ.dropEdgeInconclusives(noise, os, oe, LZ.tableConfig.edge_drop_ms)
            if #noise > 1 then
                local pruned = {}
                for _, n in ipairs(noise) do if (n["end"] - n.start) >= LZ.tableConfig.min_noise_ms then pruned[#pruned+1] = n end end
                if #pruned > 0 then noise = pruned end
            end
            local ns, ne = os, oe; local changed = false
            if #noise == 0 then
            elseif #noise == 1 then
                local n = noise[1]
                if apply_start then ns = LZ.clamp(n.start, Slo, Shi) end
                if apply_end   then ne = LZ.clamp(n["end"], Elo, Ehi) end
                if ne - ns < min_d then
                    local c = LZ.center(n.start, n["end"])
                    ns = LZ.clamp(math.floor(c - min_d/2 + 0.5), Slo, Shi)
                    ne = LZ.clamp(ns + min_d, Elo, Ehi)
                end
                changed = (ns ~= os) or (ne ~= oe)
            else
                local groups = LZ.groupNoise(noise, LZ.tableConfig.merge_gap_ms)
                local bestG, bestScore = groups[1], -1e9
                for _, G in ipairs(groups) do
                    local sc = LZ.clusterScore(G, os, oe)
                    if sc > bestScore then bestScore = sc; bestG = G end
                end
                local cs, ce = LZ.clusterSpan(bestG)
                if bestG[1].start <= os + LZ.tableConfig.eps and (bestG[1]["end"] - bestG[1].start) <= LZ.tableConfig.edge_drop_ms and #bestG > 1 then
                    cs = bestG[2].start
                end
                if bestG[#bestG]["end"] >= oe - LZ.tableConfig.eps and (bestG[#bestG]["end"] - bestG[#bestG].start) <= LZ.tableConfig.edge_drop_ms and #bestG > 1 then
                    ce = bestG[#bestG-1]["end"]
                end
                if apply_start then ns = LZ.clamp(cs, Slo, Shi) end
                if apply_end   then ne = LZ.clamp(ce, Elo, Ehi) end
                if ne - ns < min_d then
                    local big = bestG[1]; local blen = big["end"] - big.start
                    for _, n in ipairs(bestG) do
                        local len = n["end"] - n.start
                        if len > blen then big = n; blen = len end
                    end
                    ns = LZ.clamp(big.start, Slo, Shi); ne = LZ.clamp(big["end"], Elo, Ehi)
                    if ne - ns < min_d then
                        local c = LZ.center(ns, ne)
                        ns = LZ.clamp(math.floor(c - min_d/2 + 0.5), Slo, Shi)
                        ne = LZ.clamp(ns + min_d, Elo, Ehi)
                    end
                end
                changed = (ns ~= os) or (ne ~= oe)
            end
            if apply_start or apply_end then
                if changed then
                    local ok, why = LZ.validateIntra(ns, ne, os, oe)
                    if not ok then
                        local ok2, why2, ns2, ne2 = LZ.clampIntra(ns, ne, os, oe)
                        if ok2 then
                            l.start_time, l.end_time = ns2, ne2
                            modified = modified + 1
                            LZ.tagDecider(l, os, oe, ns2, ne2, apply_start, apply_end, enable_tag, tag_mode, tag_scope)
                        else
                            if enable_tag then LZ.addLazyTag(l, "Reject:" .. (why2 or why)) end
                        end
                    else
                        l.start_time, l.end_time = ns, ne
                        modified = modified + 1
                        LZ.tagDecider(l, os, oe, ns, ne, apply_start, apply_end, enable_tag, tag_mode, tag_scope)
                    end
                    subs[ii] = l
                else
                    LZ.tagDecider(l, os, oe, ns, ne, apply_start, apply_end, enable_tag, tag_mode, tag_scope)
                    subs[ii] = l
                end
            end
        end
    end
    return modified
end

function LZ.run(subs, sel, paths, silences_only)
    local files = {}
    if paths.sil30 and paths.sil30 ~= "" then files[30] = paths.sil30 end
    if paths.sil40 and paths.sil40 ~= "" then files[40] = paths.sil40 end
    if paths.sil50 and paths.sil50 ~= "" then files[50] = paths.sil50 end
    if not (files[30] or files[40] or files[50]) then return nil end
    for _, i in ipairs(sel) do
        local line = subs[i]
        if line and line.class == "dialogue" then
            line.effect = LZ.stripLZ(line.effect)
            subs[i] = line
        end
    end
    local opts = {
        apply_start    = currentConfig.lazy_apply_start,
        apply_end      = currentConfig.lazy_apply_end,
        enable_tagging = currentConfig.lazy_enable_tagging,
        tag_mode       = currentConfig.lazy_tag_mode,
        tag_scope      = currentConfig.lazy_tag_scope,
        table_csv      = currentConfig.lazy_table_csv and true or false,
    }
    if silences_only then
        return LZ.runLazyFusionAnalysis(subs, sel, files, opts, nil)
    end
    local method = currentConfig.lazy_method
    local flux = (paths.flux and paths.flux ~= "") and LZ.normalizeFluxToMs(LZ.parseFLUXtsv(paths.flux)) or nil
    if method == "LazyFusion" then
        return LZ.runLazyFusionAnalysis(subs, sel, files, opts, flux)
    elseif method == "Table (±ms)" then
        local single = {}
        if files[40] then single[40] = files[40]
        elseif files[30] then single[30] = files[30]
        else single[50] = files[50] end
        local lim = tonumber(currentConfig.lazy_limit) or 500
        return LZ.runTableAnalysis(subs, sel, lim, single, opts)
    else
        LZ.auxVad  = (paths.vad and paths.vad ~= "") and LZ.normalizeVadToMs(LZ.parseVADtsv(paths.vad)) or nil
        LZ.auxFlux = flux
        local lim = tonumber(currentConfig.lazy_limit) or 500
        local modified = LZ.runClusterAnalysis(subs, sel, lim, files, opts)
        LZ.auxVad, LZ.auxFlux = nil, nil
        return modified
    end
end

local VTMOD











local function getVT()
if VTMOD then return VTMOD end





local DEFAULTS = {
    
    sil30 = "", sil40 = "", sil50 = "",
    vad = "", flux = "", env = "", keyframes = "",
    
    lead_in_ms = DEFAULT_CONFIG.cue_lead_in_ms,
    lead_out_ms = DEFAULT_CONFIG.cue_lead_out_ms,
    max_lead_out_ms = DEFAULT_CONFIG.cue_max_lead_out_ms,
    max_lead_in_ms = DEFAULT_CONFIG.cue_max_lead_in_ms,
    
    kf_end_range_ms = DEFAULT_CONFIG.cue_kf_end_range_ms,
    kf_start_range_ms = DEFAULT_CONFIG.cue_kf_start_range_ms,
    kf_back_ms = DEFAULT_CONFIG.cue_kf_back_ms,
    
    duration_floor_ms = DEFAULT_CONFIG.cue_duration_floor_ms,
    cps_flag = DEFAULT_CONFIG.cue_cps_flag,
    skip_signs = DEFAULT_CONFIG.cue_skip_signs,
    style_filter = DEFAULT_CONFIG.cue_style_filter,
    extra_style = DEFAULT_CONFIG.cue_extra_style,
    show_stats = DEFAULT_CONFIG.cue_show_stats,
    fps = DEFAULT_CONFIG.cue_fps,
}

local CONFIG_KEYS = {
    lead_in_ms = "cue_lead_in_ms",
    lead_out_ms = "cue_lead_out_ms",
    max_lead_out_ms = "cue_max_lead_out_ms",
    max_lead_in_ms = "cue_max_lead_in_ms",
    kf_end_range_ms = "cue_kf_end_range_ms",
    kf_start_range_ms = "cue_kf_start_range_ms",
    kf_back_ms = "cue_kf_back_ms",
    duration_floor_ms = "cue_duration_floor_ms",
    cps_flag = "cue_cps_flag",
    skip_signs = "cue_skip_signs",
    style_filter = "cue_style_filter",
    extra_style = "cue_extra_style",
    show_stats = "cue_show_stats",
    fps = "cue_fps",
}



local TUNE = {
    vote_fraction = 0.5,     
    w_vad = 1.0,             
    w_sil30 = 0.9,           
    w_sil40 = 0.85,
    w_sil50 = 0.6,           
    w_flux = 0.7,            
    min_voice_run_ms = 50,   
    bridge_gap_ms = 320,     
    max_pause_ms = 900,      
    tiny_span_ms = 120,      
    flux_start_ms = 160,     
    flux_end_ms = 200,       
    spread_search_ms = 450,  
    spread_flag_ms = 350,    
    min_voice_ms = 80,       
    stack_eps_ms = 40,       
    keep_min_out_ms = 200,   
    flash_gap_ms = 250,      
    cap_grace_ms = 120,      
    frame_grace_ms = 45,     
    orig_end_cut_ms = 150,   
                             
    
    max_sane_cps = 40,       
    relax_vote = 0.38,       
    relax_bridge_ms = 480,   
    relax_tiny_ms = 60,      
    relax_pause_ms = 1200,   
    relax_run_ms = 30,       
    
    onset_soft_ms = 140,     
    loud_tail_ms = 300,      
    tail_keep_ms = 80,       
    
    w_env = 1.0,
    env_refine_ms = 220,     
    env_min_range_db = 6,    
    env_thr_frac = 0.35,     
}

local GUI_BOUNDS = {
    lead_in_ms = { min = 0, max = 600 },
    lead_out_ms = { min = 0, max = 1200 },
    max_lead_out_ms = { min = 200, max = 1500 },
    max_lead_in_ms = { min = 100, max = 1000 },
    kf_end_range_ms = { min = 0, max = 1500 },
    kf_start_range_ms = { min = 0, max = 1000 },
    kf_back_ms = { min = 0, max = 300 },
    cps_flag = { min = 10, max = 60 },
    duration_floor_ms = { min = 0, max = 2000 },
}





local function trim(s)
    return (tostring(s or ""):match("^%s*(.-)%s*$")) or ""
end

local function round(x)
    x = tonumber(x) or 0
    if x >= 0 then return math.floor(x + 0.5) end
    return math.ceil(x - 0.5)
end

local function clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end


local function lower_bound(list, value)
    local lo, hi = 1, #list + 1
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if list[mid] < value then lo = mid + 1 else hi = mid end
    end
    return lo
end

local function overlap_len(a0, a1, b0, b1)
    return math.min(a1, b1) - math.max(a0, b0)
end


local function progress(task, pct)
    if aegisub and aegisub.progress then
        if task and aegisub.progress.task then pcall(aegisub.progress.task, task) end
        if pct and aegisub.progress.set then pcall(aegisub.progress.set, pct) end
    end
end





local PATH_KEYS = { "sil30", "sil40", "sil50", "vad", "flux", "env", "keyframes" }

local function save_cfg(c)
    for key, configKey in pairs(CONFIG_KEYS) do currentConfig[configKey] = c[key] end
    return saveConfig()
end





local IS_WINDOWS = package.config:sub(1, 1) == "\\"

local function script_dir_and_base()
    local dir, name
    if aegisub and aegisub.decode_path then
        local ok, d = pcall(aegisub.decode_path, "?script")
        if ok and d and d ~= "" and not d:find("?script", 1, true) then dir = d end
    end
    if aegisub and aegisub.file_name then
        local ok, n = pcall(aegisub.file_name)
        if ok and n and n ~= "" then name = n end
    end
    local base = name and name:gsub("%.[^%.]+$", "") or nil
    return dir, base, name
end

local function list_dir(dir)
    if not dir then return {} end
    local cmd
    if IS_WINDOWS then cmd = 'dir /b "' .. dir .. '"'
    else cmd = 'ls -1 "' .. dir .. '"' end
    local ok, p = pcall(io.popen, cmd)
    if not ok or not p then return {} end
    local out = {}
    for line in p:lines() do
        line = trim(line)
        if line ~= "" then out[#out + 1] = line end
    end
    p:close()
    return out
end





local function classify_data_file(name)
    local n = tostring(name or ""):lower()
    if not (n:match("%.txt$") or n:match("%.log$") or n:match("%.tsv$") or n:match("%.csv$")) then return nil end
    if n:find("key", 1, true) or n:find("kf", 1, true) or n:find("scene", 1, true) then return "keyframes" end
    if n:find("vad", 1, true) then return "vad" end
    if n:find("flux", 1, true) or n:find("onset", 1, true) then return "flux" end
    if n:find("env", 1, true) or n:find("rms", 1, true) or n:find("loud", 1, true) then return "env" end
    if n:find("sil", 1, true) or n:find("silence", 1, true) or n:find("retime", 1, true) then
        if n:find("30", 1, true) then return "sil30" end
        if n:find("40", 1, true) then return "sil40" end
        if n:find("50", 1, true) then return "sil50" end
        return "sil30"
    end
    local th = n:match("[_%-]([345]0)%.%w+$")
    if th then return "sil" .. th end
    return nil
end



local function chapter_of(name)
    local digits = tostring(name or ""):match("^(%d+)")
    if digits then return tonumber(digits) end
    return nil
end




local function discover_paths(paths)
    local dir, base = script_dir_and_base()
    if not dir then return paths end
    local sep = IS_WINDOWS and "\\" or "/"
    local subs_ch = base and tonumber(base:match("(%d+)")) or nil
    local best = {}
    for _, fname in ipairs(list_dir(dir)) do
        local slot = classify_data_file(fname)
        if slot and (paths[slot] == nil or paths[slot] == "") then
            local score = 1
            if base and fname:lower():find(base:lower(), 1, true) then score = score + 2 end
            if subs_ch and chapter_of(fname) == subs_ch then score = score + 3 end
            if not best[slot] or score > best[slot].score then
                best[slot] = { name = fname, score = score }
            end
        end
    end
    for slot, rec in pairs(best) do
        paths[slot] = dir .. sep .. rec.name
    end
    return paths
end



local SESSION = { key = nil, paths = nil }

local function session_key()
    local dir, _, name = script_dir_and_base()
    return (dir or "?") .. "|" .. (name or "?")
end

local function session_paths(autoDiscover)
    local key = session_key()
    if SESSION.key ~= key then
        SESSION.key = key
        SESSION.paths = nil
    end
    if not SESSION.paths then
        local p = {}
        for _, k in ipairs(PATH_KEYS) do p[k] = "" end
        if autoDiscover ~= false then discover_paths(p) end
        SESSION.paths = p
    elseif autoDiscover ~= false then
        discover_paths(SESSION.paths)
    end
    return SESSION.paths
end

local function normalize_cfg(c)
    for k, v in pairs(DEFAULTS) do
        if c[k] == nil or type(c[k]) ~= type(v) then c[k] = v end
    end
    for k, b in pairs(GUI_BOUNDS) do
        c[k] = clamp(round(tonumber(c[k]) or DEFAULTS[k]), b.min, b.max)
    end
    c.fps = tonumber(c.fps) or DEFAULTS.fps
    if c.fps <= 0 then c.fps = DEFAULTS.fps end
    if c.max_lead_out_ms < c.lead_out_ms then c.max_lead_out_ms = c.lead_out_ms end
    if c.max_lead_in_ms < c.lead_in_ms then c.max_lead_in_ms = c.lead_in_ms end
    return c
end

local function get_cfg(autoDiscover)
    local c = {}
    for k, v in pairs(DEFAULTS) do c[k] = v end
    for key, configKey in pairs(CONFIG_KEYS) do
        if currentConfig[configKey] ~= nil then c[key] = currentConfig[configKey] end
    end
    local sp = session_paths(autoDiscover)
    for _, k in ipairs(PATH_KEYS) do c[k] = sp[k] or "" end
    return normalize_cfg(c)
end





local function visible_text(text)
    local s = tostring(text or "")
    s = s:gsub("{[^}]*}", "")
    s = s:gsub("\\[Nn]", " ")
    s = s:gsub("\\h", " ")
    return trim(s)
end

local function utf8_len(s)
    s = tostring(s or "")
    local _, continuation = s:gsub("[\128-\191]", "")
    return #s - continuation
end

local function readable_chars(text)
    local clean = visible_text(text)
    clean = clean:gsub("[%s%p]", "")
    clean = clean:gsub("\194\191", ""):gsub("\194\161", ""):gsub("\226\128\166", "")
    return utf8_len(clean)
end



local function style_ok(style, flt, extra)
    flt = tostring(flt or "All")
    if flt == "" or flt == "All" then return true end
    style = tostring(style or "")
    local extra_hit = extra ~= nil and extra ~= "" and style == extra
    if flt == "All Default" then return style:find("Defa", 1, true) ~= nil or extra_hit end
    if flt == "Default+Alt" then
        return style:find("Defa", 1, true) ~= nil or style:find("Alt", 1, true) ~= nil or extra_hit
    end
    return style == flt or extra_hit
end

local function is_spoken(line, cfg)
    if not line or line.comment then return false end
    local raw = tostring(line.text or "")
    if raw:find("\\p%d") then return false end 
    if visible_text(raw) == "" then return false end
    local effect = tostring(line.effect or ""):lower()
    if effect:find("template", 1, true) or effect:find("karaoke", 1, true) or effect:find("code", 1, true) then return false end
    if cfg.skip_signs then
        local style = tostring(line.style or ""):lower()
        if style:find("sign", 1, true) or style:find("kara", 1, true) or style:find("fx", 1, true) then return false end
    end
    if not style_ok(line.style, cfg.style_filter, cfg.extra_style) then return false end
    return true
end





local function split_fields(line)
    local fields = {}
    line = tostring(line or "")
    if line:find("\t", 1, true) then
        for f in line:gmatch("[^\t]+") do fields[#fields + 1] = trim(f) end
    elseif line:find(",", 1, true) then
        for f in line:gmatch("[^,]+") do fields[#fields + 1] = trim(f) end
    else
        for f in line:gmatch("%S+") do fields[#fields + 1] = trim(f) end
    end
    return fields
end



local function detect_time_scale(header, values)
    header = tostring(header or ""):lower()
    if header:find("ms", 1, true) or header:find("millisecond", 1, true) then return 1 end
    if header:find("sec", 1, true) or header:find("time_s", 1, true) then return 1000 end
    local max_abs, n, fractional = 0, 0, false
    for _, v in ipairs(values) do
        local x = tonumber(v)
        if x then
            n = n + 1
            max_abs = math.max(max_abs, math.abs(x))
            if x ~= math.floor(x) then fractional = true end
        end
    end
    if fractional then return 1000 end
    if n >= 4 then return 1 end
    if max_abs > 100000 then return 1 end
    return 1000
end


local function merge_intervals(list)
    table.sort(list, function(a, b) return a.b < b.b end)
    local out = {}
    for _, iv in ipairs(list) do
        if iv.e > iv.b then
            local last = out[#out]
            if last and iv.b <= last.e then
                if iv.e > last.e then last.e = iv.e end
            else
                out[#out + 1] = { b = iv.b, e = iv.e }
            end
        end
    end
    return out
end

local function parse_interval_rows(path)
    local rows, nums, header = {}, {}, nil
    local f = io.open(path, "r")
    if not f then return rows end
    local first = true
    for line in f:lines() do
        local fields = split_fields(line)
        local s, e = tonumber(fields[1]), tonumber(fields[2])
        if first then
            first = false
            header = line
            if s and e then rows[#rows + 1] = { b = s, e = e }; nums[#nums + 1] = s; nums[#nums + 1] = e end
        elseif s and e and e > s then
            rows[#rows + 1] = { b = s, e = e }; nums[#nums + 1] = s; nums[#nums + 1] = e
        end
    end
    f:close()
    local scale = detect_time_scale(header, nums)
    for _, r in ipairs(rows) do r.b = r.b * scale; r.e = r.e * scale end
    return merge_intervals(rows)
end

local function parse_silence_file(path)
    if not path or path == "" then return {} end
    local out = {}
    local f = io.open(path, "r")
    if not f then return out end
    local cur = nil
    for line in f:lines() do
        local ss = line:match("silence_start:%s*(-?[%d%.]+)")
        if ss then cur = tonumber(ss) and tonumber(ss) * 1000 or nil end
        local se = line:match("silence_end:%s*(-?[%d%.]+)")
        if se and cur then
            local e = tonumber(se) * 1000
            if e > cur then out[#out + 1] = { b = cur, e = e } end
            cur = nil
        end
    end
    f:close()
    if #out == 0 then
        
        return parse_interval_rows(path)
    end
    return merge_intervals(out)
end

local function parse_vad_file(path)
    if not path or path == "" then return {} end
    return parse_interval_rows(path)
end

local function parse_flux_file(path)
    local on, off = {}, {}
    if not path or path == "" then return on, off end
    local rows, nums, header = {}, {}, nil
    local f = io.open(path, "r")
    if not f then return on, off end
    local first = true
    for line in f:lines() do
        local fields = split_fields(line)
        local t = tonumber(fields[1])
        if first then
            first = false
            header = line
        end
        if t then
            rows[#rows + 1] = { t = t, kind = tostring(fields[2] or "onset"):lower() }
            nums[#nums + 1] = t
        end
    end
    f:close()
    local scale = detect_time_scale(header, nums)
    for _, r in ipairs(rows) do
        local t = r.t * scale
        if r.kind == "offset" or r.kind == "end" then off[#off + 1] = t else on[#on + 1] = t end
    end
    table.sort(on); table.sort(off)
    return on, off
end




local function parse_env_file(path)
    if not path or path == "" then return nil end
    local f = io.open(path, "r")
    if not f then return nil end
    local rows, nums, header, first = {}, {}, nil, true
    for line in f:lines() do
        local fields = split_fields(line)
        local t, v = tonumber(fields[1]), tonumber(fields[2])
        if first then first = false; header = line end
        if t and v then
            rows[#rows + 1] = { t = t, v = v }
            nums[#nums + 1] = t
        end
    end
    f:close()
    if #rows < 8 then return nil end
    local scale = detect_time_scale(header, nums)
    table.sort(rows, function(x, y) return x.t < y.t end)
    local ts, vs = {}, {}
    for i, r in ipairs(rows) do ts[i] = r.t * scale; vs[i] = r.v end
    return { t = ts, v = vs }
end

local function env_window(env, w0, w1)
    local i0 = lower_bound(env.t, w0)
    local i1 = lower_bound(env.t, w1) - 1
    return i0, i1
end


local function env_threshold(env, i0, i1)
    if i1 - i0 < 7 then return nil end
    local vals = {}
    for i = i0, i1 do vals[#vals + 1] = env.v[i] end
    table.sort(vals)
    local floor_db = vals[math.max(1, math.floor(#vals * 0.10))]
    local peak_db = vals[math.max(1, math.floor(#vals * 0.90))]
    if peak_db - floor_db < TUNE.env_min_range_db then return nil end
    return floor_db + (peak_db - floor_db) * TUNE.env_thr_frac
end

local function env_acts(env, w0, w1)
    local i0, i1 = env_window(env, w0, w1)
    local thr = env_threshold(env, i0, i1)
    if not thr then return nil end
    local out, since = {}, nil
    for i = i0, i1 do
        local active = env.v[i] >= thr
        if active and not since then
            since = env.t[i]
        elseif not active and since then
            out[#out + 1] = { b = since, e = env.t[i] }
            since = nil
        end
    end
    if since then out[#out + 1] = { b = since, e = w1 } end
    return out
end


local function env_refine_edge(env, t, which, w0, w1)
    local i0, i1 = env_window(env, w0, w1)
    local thr = env_threshold(env, i0, i1)
    if not thr then return nil end
    local best, bestd
    for i = math.max(i0 + 1, 2), i1 do
        local up = env.v[i - 1] < thr and env.v[i] >= thr
        local down = env.v[i - 1] >= thr and env.v[i] < thr
        if (which == "start" and up) or (which == "end" and down) then
            local d = math.abs(env.t[i] - t)
            if d <= TUNE.env_refine_ms and (not bestd or d < bestd) then
                best, bestd = env.t[i], d
            end
        end
    end
    return best
end

local function frame_to_ms(frame, cfg)
    frame = tonumber(frame)
    if not frame then return nil end
    if aegisub and type(aegisub.ms_from_frame) == "function" then
        local ok, ms = pcall(aegisub.ms_from_frame, frame)
        if ok and ms then return ms end
    end
    return round(frame * 1000 / ((cfg and cfg.fps) or DEFAULTS.fps))
end

local function parse_keyframe_file(path, cfg)
    local raw_lines = {}
    if not path or path == "" then return {} end
    local f = io.open(path, "r")
    if not f then return {} end
    local has_frame_tokens = false
    for line in f:lines() do
        local raw = trim(line)
        if raw ~= "" and not raw:match("^#") then
            raw_lines[#raw_lines + 1] = raw
            local kind = tostring(raw:match("^(%S+)") or ""):lower()
            if kind == "i" or kind == "p" or kind == "b" then has_frame_tokens = true end
        end
    end
    f:close()
    local frames = {}
    if has_frame_tokens then
        
        local frame = 0
        for _, raw in ipairs(raw_lines) do
            local kind = tostring(raw:match("^(%S+)") or ""):lower()
            if kind == "i" or kind == "p" or kind == "b" then
                if kind == "i" then frames[#frames + 1] = frame end
                frame = frame + 1
            end
        end
    else
        for _, raw in ipairs(raw_lines) do
            local n = tonumber(raw:match("^(-?%d+%.?%d*)"))
            if n then frames[#frames + 1] = round(n) end
        end
    end
    local ms, seen = {}, {}
    for _, fr in ipairs(frames) do
        local t = frame_to_ms(fr, cfg)
        if t and not seen[t] then seen[t] = true; ms[#ms + 1] = t end
    end
    table.sort(ms)
    return ms
end

local function get_keyframes(cfg)
    local ms
    if aegisub and type(aegisub.keyframes) == "function" then
        local ok, kf = pcall(aegisub.keyframes)
        if ok and type(kf) == "table" and #kf > 0 then
            local seen = {}
            ms = {}
            for _, fr in ipairs(kf) do
                local t = frame_to_ms(fr, cfg)
                if t and not seen[t] then seen[t] = true; ms[#ms + 1] = t end
            end
            table.sort(ms)
        end
    end
    if not ms then ms = parse_keyframe_file(cfg.keyframes, cfg) end
    local set = {}
    for _, t in ipairs(ms) do set[t] = true end
    return ms, set
end


local function kf_in(kfs, lo, hi, target)
    if not kfs or #kfs == 0 or hi < lo then return nil end
    local pos = lower_bound(kfs, lo)
    local best, bestd
    while pos <= #kfs do
        local t = kfs[pos]
        if t > hi then break end
        local d = math.abs(t - target)
        if not bestd or d < bestd then best, bestd = t, d end
        pos = pos + 1
    end
    return best
end

local function nearest_in(arr, target, max_d)
    if not arr or #arr == 0 then return nil end
    local pos = lower_bound(arr, target)
    local best, bestd
    for off = -1, 0 do
        local t = arr[pos + off]
        if t then
            local d = math.abs(t - target)
            if d <= max_d and (not bestd or d < bestd) then best, bestd = t, d end
        end
    end
    return best
end







local function make_interval_source(kind, label, weight, list)
    local starts, ends = {}, {}
    for _, iv in ipairs(list) do
        if kind == "sil" then
            starts[#starts + 1] = iv.e
            ends[#ends + 1] = iv.b
        else
            starts[#starts + 1] = iv.b
            ends[#ends + 1] = iv.e
        end
    end
    table.sort(starts); table.sort(ends)
    return { kind = kind, label = label, weight = weight, list = list, starts = starts, ends = ends, cur = 1 }
end



local function flux_intervals(on, off)
    local out, oi = {}, 1
    for _, t in ipairs(on) do
        while off[oi] and off[oi] <= t do oi = oi + 1 end
        if off[oi] then out[#out + 1] = { b = t, e = off[oi] } end
    end
    return merge_intervals(out)
end

local function build_signals(cfg)
    local sig = { sources = {}, flux_on = {}, flux_off = {} }
    local silspecs = {
        { cfg.sil30, TUNE.w_sil30, "sil30" },
        { cfg.sil40, TUNE.w_sil40, "sil40" },
        { cfg.sil50, TUNE.w_sil50, "sil50" },
    }
    for _, sp in ipairs(silspecs) do
        if sp[1] ~= "" then
            local list = parse_silence_file(sp[1])
            if #list > 0 then
                sig.sources[#sig.sources + 1] = make_interval_source("sil", sp[3], sp[2], list)
            end
        end
    end
    if cfg.vad ~= "" then
        local list = parse_vad_file(cfg.vad)
        if #list > 0 then
            sig.sources[#sig.sources + 1] = make_interval_source("vad", "vad", TUNE.w_vad, list)
        end
    end
    if cfg.flux ~= "" then
        sig.flux_on, sig.flux_off = parse_flux_file(cfg.flux)
    end
    if cfg.env ~= "" then
        sig.env = parse_env_file(cfg.env)
    end
    if #sig.sources == 0 and #sig.flux_on > 0 and #sig.flux_off > 0 then
        local list = flux_intervals(sig.flux_on, sig.flux_off)
        if #list > 0 then
            sig.sources[#sig.sources + 1] = make_interval_source("vad", "flux-span", TUNE.w_flux, list)
        end
    end
    return sig
end




local function window_overlaps(src, w0, w1)
    local list = src.list
    local cur = src.cur or 1
    if src.last_w0 and w0 < src.last_w0 then cur = 1 end
    src.last_w0 = w0
    while cur <= #list and list[cur].e <= w0 do cur = cur + 1 end
    src.cur = cur
    local out, i = {}, cur
    while i <= #list and list[i].b < w1 do
        if list[i].e > w0 then out[#out + 1] = list[i] end
        i = i + 1
    end
    return out
end

local function clip_intervals(list, w0, w1)
    local out = {}
    for _, iv in ipairs(list) do
        local b, e = math.max(iv.b, w0), math.min(iv.e, w1)
        if e > b then out[#out + 1] = { b = b, e = e } end
    end
    return out
end

local function complement_intervals(list, w0, w1)
    local out, cur = {}, w0
    for _, iv in ipairs(list) do
        local b, e = math.max(iv.b, w0), math.min(iv.e, w1)
        if e > b then
            if b > cur then out[#out + 1] = { b = cur, e = b } end
            if e > cur then cur = e end
        end
    end
    if cur < w1 then out[#out + 1] = { b = cur, e = w1 } end
    return out
end







local function vote_activity(sources, need, w0, w1)
    local events = {}
    for _, src in ipairs(sources) do
        for _, iv in ipairs(src.acts) do
            local b, e = math.max(iv.b, w0), math.min(iv.e, w1)
            if e > b then
                events[#events + 1] = { t = b, d = src.weight }
                events[#events + 1] = { t = e, d = -src.weight }
            end
        end
    end
    if #events == 0 or need <= 0 then return {} end
    table.sort(events, function(x, y) return x.t < y.t end)
    need = need - 1e-9
    local out, level, since = {}, 0, nil
    local i, n = 1, #events
    while i <= n do
        local t = events[i].t
        while i <= n and events[i].t == t do
            level = level + events[i].d
            i = i + 1
        end
        local active = level >= need
        if active and not since then
            since = t
        elseif not active and since then
            if t > since then out[#out + 1] = { b = since, e = t } end
            since = nil
        end
    end
    if since and w1 > since then out[#out + 1] = { b = since, e = w1 } end
    return out
end


local function edge_spread(sig, t, which)
    local vals = {}
    for _, src in ipairs(sig.sources) do
        local arr = (which == "start") and src.starts or src.ends
        local v = nearest_in(arr, t, TUNE.spread_search_ms)
        if v then vals[#vals + 1] = v end
    end
    local f = nearest_in(which == "start" and sig.flux_on or sig.flux_off, t, TUNE.spread_search_ms)
    if f then vals[#vals + 1] = f end
    if #vals < 2 then return false end
    local mn, mx = vals[1], vals[1]
    for _, v in ipairs(vals) do
        if v < mn then mn = v end
        if v > mx then mx = v end
    end
    return (mx - mn) > TUNE.spread_flag_ms
end





local function detect_voice(it, sig, cfg, kfs, relax)
    local fraction = relax and TUNE.relax_vote or TUNE.vote_fraction
    local bridge = relax and TUNE.relax_bridge_ms or TUNE.bridge_gap_ms
    local tiny = relax and TUNE.relax_tiny_ms or TUNE.tiny_span_ms
    local pause = relax and TUNE.relax_pause_ms or TUNE.max_pause_ms
    local min_run = relax and TUNE.relax_run_ms or TUNE.min_voice_run_ms

    
    
    local w0 = math.max(it.os, 0)
    local w1 = it.oe
    if w1 <= w0 then return nil end

    local sources, total = {}, 0
    for _, src in ipairs(sig.sources) do
        local within = window_overlaps(src, w0, w1)
        local acts
        if src.kind == "sil" then
            acts = complement_intervals(within, w0, w1)
        else
            acts = clip_intervals(within, w0, w1)
        end
        sources[#sources + 1] = { weight = src.weight, acts = acts }
        total = total + src.weight
    end
    if sig.env then
        local acts = env_acts(sig.env, w0, w1)
        if acts then
            sources[#sources + 1] = { weight = TUNE.w_env, acts = acts }
            total = total + TUNE.w_env
        end
    end
    if total <= 0 then return nil end

    local voted = vote_activity(sources, total * fraction, w0, w1)
    local runs = {}
    for _, r in ipairs(voted) do
        if r.e - r.b >= min_run then runs[#runs + 1] = r end
    end
    if #runs == 0 then runs = voted end
    if #runs == 0 then return nil end

    
    local spans = {}
    for _, r in ipairs(runs) do
        local last = spans[#spans]
        if last and r.b - last.e <= bridge then
            if r.e > last.e then last.e = r.e end
        else
            spans[#spans + 1] = { b = r.b, e = r.e }
        end
    end

    
    local cands = {}
    for _, sp in ipairs(spans) do
        if sp.e > it.os and sp.b < it.oe then cands[#cands + 1] = sp end
    end
    if #cands == 0 then return nil end

    
    
    local anchor, best = 1, nil
    for i, sp in ipairs(cands) do
        local score = overlap_len(sp.b, sp.e, it.os, it.oe) + 0.2 * (sp.e - sp.b)
        if not best or score > best then best, anchor = score, i end
    end
    local lo, hi = anchor, anchor
    while lo > 1 do
        local prev = cands[lo - 1]
        if cands[lo].b - prev.e <= pause and prev.e - prev.b >= tiny then
            lo = lo - 1
        else break end
    end
    while hi < #cands do
        local nxt = cands[hi + 1]
        if nxt.b - cands[hi].e <= pause and nxt.e - nxt.b >= tiny then
            hi = hi + 1
        else break end
    end
    local vs, ve = cands[lo].b, cands[hi].e

    
    
    for _, src in ipairs(sig.sources) do
        if src.label == "sil40" or src.label == "sil50" then
            local v = nearest_in(src.starts, vs, TUNE.onset_soft_ms)
            if v and v < vs then vs = v end
        end
    end
    
    
    for _, src in ipairs(sig.sources) do
        if src.label == "sil30" then
            local loud_end = nearest_in(src.ends, ve, TUNE.loud_tail_ms)
            if loud_end and loud_end < ve - TUNE.tail_keep_ms and loud_end > vs then
                ve = loud_end + TUNE.tail_keep_ms
            end
        end
    end
    
    if sig.env then
        local r = env_refine_edge(sig.env, vs, "start", w0, w1)
        if r and r < ve then vs = r end
        r = env_refine_edge(sig.env, ve, "end", w0, w1)
        if r and r > vs then ve = r end
    end
    local on = nearest_in(sig.flux_on, vs, TUNE.flux_start_ms)
    if on and on < ve then vs = on end
    local off = nearest_in(sig.flux_off, ve, TUNE.flux_end_ms)
    if off and off > vs then ve = off end

    
    
    
    
    
    local hit_lo = vs <= w0 + 1
    local hit_hi = ve >= w1 - 1
    vs = clamp(vs, it.os, it.oe)
    ve = clamp(ve, it.os, it.oe)
    
    
    if hit_hi and kfs then
        local k = kf_in(kfs, it.oe - TUNE.orig_end_cut_ms, it.oe, it.oe)
        if k and k > vs then ve = k end
    end
    if ve - vs < TUNE.min_voice_ms then return nil end

    local weak = hit_lo or hit_hi
        or edge_spread(sig, vs, "start") or edge_spread(sig, ve, "end")
    return { vs = round(vs), ve = round(ve), weak = weak }
end





local function add_flag(it, flag)
    it.flags = it.flags or {}
    for _, f in ipairs(it.flags) do if f == flag then return end end
    it.flags[#it.flags + 1] = flag
end

local function stacked(a, b)
    return overlap_len(a.os, a.oe, b.os, b.oe) > TUNE.stack_eps_ms
end





local function plan_padding(items, kfs, kfset, cfg, stats)
    stats = stats or {}
    local vis, processed = {}, {}
    for _, it in ipairs(items) do
        if it.spoken then
            vis[#vis + 1] = it
            it.vpos = #vis
            if it.use then processed[#processed + 1] = it end
        end
    end

    local grace = TUNE.frame_grace_ms

    
    
    
    
    
    
    for _, it in ipairs(processed) do
        it.ideal_s = it.vs - cfg.lead_in_ms
        it.ideal_e = it.ve + cfg.lead_out_ms
        it.s, it.e = it.ideal_s, it.ideal_e
        it.s_kf, it.e_kf = false, false
        it.joined_l, it.joined_r = false, false
        local orig_start_kf = kf_in(kfs, it.os - grace, it.os + grace, it.os)
        local orig_end_kf = kf_in(kfs, it.oe - grace, it.oe + grace, it.oe)
        
        
        local ks = kf_in(kfs, it.vs - cfg.kf_start_range_ms, it.vs, it.vs)
            or kf_in(kfs, it.vs + 1, math.min(it.vs + cfg.kf_back_ms, it.ve - 1), it.vs + 1)
        if not ks and orig_start_kf
            and orig_start_kf >= it.vs - cfg.kf_start_range_ms - 2 * grace
            and orig_start_kf <= it.vs + cfg.kf_back_ms then
            ks = orig_start_kf 
        end
        if ks then it.s, it.s_kf = ks, true end
        local elo = math.max(it.ve - cfg.kf_back_ms, it.vs + 1)
        local ke = kf_in(kfs, it.ve, it.ve + cfg.kf_end_range_ms, it.ve)
        if not ke and elo <= it.ve - 1 then
            ke = kf_in(kfs, elo, it.ve - 1, it.ve)
        end
        if not ke and orig_end_kf
            and orig_end_kf > it.vs
            and orig_end_kf <= it.ve + cfg.max_lead_out_ms + 2 * grace then
            ke = orig_end_kf
        end
        if ke then it.e, it.e_kf = ke, true end
        if it.s < 0 then it.s = 0 end
    end

    local function set_boundary(a, b, t)
        t = round(t)
        a.e, b.s = t, t
        local on = kfset and kfset[t] or false
        a.e_kf, b.s_kf = on, on
        a.joined_r, b.joined_l = true, true
        stats.joins = (stats.joins or 0) + 1
    end

    local function resolve_pair(a, b, blocked, orig_chained)
        if stacked(a, b) then return end
        if b.vs < a.ve then
            
            
            if a.e > b.s then add_flag(a, "OVERLAP"); add_flag(b, "OVERLAP") end
            return
        end
        if blocked then
            
            if a.e > b.s then
                a.e = clamp(b.s, a.ve, a.e)
                a.e_kf = kfset and kfset[a.e] or false
            end
            if a.e > b.s then add_flag(a, "OVERLAP"); add_flag(b, "OVERLAP") end
            return
        end
        local va_e, vb_s = a.ve, b.vs
        local gap = b.s - a.e
        if gap == 0 then
            a.joined_r, b.joined_l = true, true
            return
        end

        if gap < 0 then
            
            
            local boundary
            if a.e_kf and a.e <= vb_s + cfg.kf_back_ms then boundary = a.e
            elseif b.s_kf and b.s >= va_e - cfg.kf_back_ms then boundary = b.s
            else
                local r0 = math.max(va_e - cfg.kf_back_ms, math.min(a.e, b.s))
                local r1 = math.min(vb_s + cfg.kf_back_ms, math.max(a.e, b.s))
                boundary = kf_in(kfs, r0, r1, clamp(vb_s - cfg.lead_in_ms, r0, r1))
                if not boundary then
                    local cand = vb_s - cfg.lead_in_ms
                    if cand - va_e >= TUNE.keep_min_out_ms then
                        boundary = cand 
                    else
                        
                        boundary = va_e + (vb_s - va_e) * cfg.lead_out_ms / (cfg.lead_out_ms + cfg.lead_in_ms)
                    end
                    boundary = clamp(boundary, va_e, vb_s)
                end
            end
            set_boundary(a, b, boundary)
            return
        end

        
        
        
        local out_room = math.max(0, cfg.max_lead_out_ms - (a.e - va_e))
        local in_room = math.max(0, cfg.max_lead_in_ms - (vb_s - b.s))
        local joinable = gap <= out_room + in_room
        local flashy = gap <= TUNE.flash_gap_ms
        local wanted = joinable or flashy or orig_chained
        local grace_ms = (flashy or orig_chained) and TUNE.cap_grace_ms or 0
        
        local zone_kf
        if b.s - a.e > 2 then
            zone_kf = kf_in(kfs, a.e + 1, b.s - 1, clamp(vb_s - cfg.lead_in_ms, a.e + 1, b.s - 1))
        end

        if a.e_kf and b.s_kf then
            
            
            if flashy then
                if b.s - va_e <= cfg.max_lead_out_ms + TUNE.cap_grace_ms then
                    set_boundary(a, b, b.s)
                elseif vb_s - a.e <= cfg.max_lead_in_ms + TUNE.cap_grace_ms then
                    set_boundary(a, b, a.e)
                end
            end
            return
        end
        if a.e_kf then
            
            if wanted and not zone_kf and vb_s - a.e <= cfg.max_lead_in_ms + grace_ms then
                set_boundary(a, b, a.e)
            end
            return
        end
        if b.s_kf then
            if zone_kf and zone_kf - va_e <= cfg.max_lead_out_ms then
                a.e = zone_kf 
                a.e_kf = true
            elseif wanted and b.s - va_e <= cfg.max_lead_out_ms + grace_ms then
                set_boundary(a, b, b.s)
            end
            return
        end
        if zone_kf then
            
            if wanted and zone_kf - va_e <= cfg.max_lead_out_ms + grace_ms
                and vb_s - zone_kf <= cfg.max_lead_in_ms + grace_ms then
                set_boundary(a, b, zone_kf)
            end
            return
        end
        if not wanted then return end
        if b.s - va_e <= cfg.max_lead_out_ms + grace_ms then
            set_boundary(a, b, b.s) 
        elseif joinable then
            set_boundary(a, b, va_e + cfg.max_lead_out_ms)
        elseif flashy then
            set_boundary(a, b, clamp(b.s, va_e, vb_s)) 
        end
    end

    
    for i = 1, #processed - 1 do
        local a, b = processed[i], processed[i + 1]
        local blocked = false
        for k = a.vpos + 1, b.vpos - 1 do
            local m = vis[k]
            if not m.use and m.oe > a.ve and m.os < b.vs then blocked = true; break end
        end
        local orig_gap = b.os - a.oe
        local orig_chained = orig_gap <= grace and orig_gap >= -TUNE.stack_eps_ms
        resolve_pair(a, b, blocked, orig_chained)
    end

    
    for _, it in ipairs(processed) do
        local p = vis[it.vpos - 1]
        if p and not p.use and not stacked(p, it) and it.s < p.oe then
            it.s = math.min(math.max(it.s, p.oe), it.vs)
            it.s_kf = kfset and kfset[it.s] or false
        end
        local nx = vis[it.vpos + 1]
        if nx and not nx.use and not stacked(it, nx) and it.e > nx.os then
            it.e = math.max(math.min(it.e, nx.os), it.ve)
            it.e_kf = kfset and kfset[it.e] or false
        end
    end

    
    for i = 1, #processed do
        local a = processed[i]
        for j = i + 1, math.min(i + 3, #processed) do
            local b = processed[j]
            if not stacked(a, b) and a.e > b.s then
                a.e = math.max(b.s, a.ve)
                a.e_kf = kfset and kfset[a.e] or false
                if a.e > b.s then add_flag(a, "OVERLAP"); add_flag(b, "OVERLAP") end
            end
        end
    end

    
    
    for _, it in ipairs(processed) do
        if not it.e_kf and not it.joined_r then
            local z = kf_in(kfs, it.ve, it.ve + cfg.kf_end_range_ms, it.ve)
            if z and z ~= it.e then
                local nx = vis[it.vpos + 1]
                local lim
                if nx and not stacked(it, nx) then lim = (nx.use and nx.s) or nx.os end
                local ok = true
                if lim then
                    if z > lim then ok = false
                    elseif z < lim and lim - z < TUNE.flash_gap_ms then ok = false end
                end
                if ok then it.e = z; it.e_kf = true end
            end
        end
    end

    
    
    for _, it in ipairs(processed) do
        if it.chars and it.chars > 0 then
            local short = cfg.duration_floor_ms - (it.e - it.s)
            if short > 0 then
                local pall = vis[it.vpos - 1]
                local left_lim = 0
                if pall and not stacked(pall, it) then left_lim = (pall.use and pall.e) or pall.oe end
                local nall = vis[it.vpos + 1]
                local right_lim = math.huge
                if nall and not stacked(it, nall) then right_lim = (nall.use and nall.s) or nall.os end
                if not it.e_kf then
                    local give = math.min(short, math.max(0, right_lim - it.e))
                    it.e = it.e + give; short = short - give
                end
                if short > 0 and not it.s_kf then
                    local give = math.min(short, math.max(0, it.s - left_lim))
                    it.s = it.s - give; short = short - give
                end
                if short > 0 then add_flag(it, "SHORT") end
            end
        end
    end

    
    
    for i = 1, #vis - 1 do
        local a, b = vis[i], vis[i + 1]
        if (a.use or b.use) and b.os >= a.oe - TUNE.stack_eps_ms then
            local ae = a.use and a.e or a.oe
            local bs = b.use and b.s or b.os
            if ae > bs then
                if a.use then
                    a.e = math.max(bs, a.ve)
                    a.e_kf = kfset and kfset[a.e] or false
                    ae = a.e
                end
                if ae > bs and b.use then
                    b.s = math.min(ae, b.vs)
                    b.s_kf = kfset and kfset[b.s] or false
                    bs = b.s
                end
                if ae > bs then add_flag(a, "OVERLAP"); add_flag(b, "OVERLAP") end
            end
        end
    end

    for _, it in ipairs(processed) do
        if it.s_kf then stats.snaps = (stats.snaps or 0) + 1 end
        if it.e_kf then stats.snaps = (stats.snaps or 0) + 1 end
    end
    return processed
end


local function add_cps_flags(items, cfg)
    for _, it in ipairs(items) do
        if it.use and it.chars > 0 and it.e and it.s and it.e > it.s then
            local cps = it.chars * 1000 / (it.e - it.s)
            if cps > cfg.cps_flag then
                add_flag(it, string.format("CPS %d", round(cps)))
            end
        end
    end
end





local function clean_marks(effect)
    local s = trim(effect)
    s = s:gsub("%s*%[TM%-[^%]]*%]", "")
    return trim(s)
end

local function collect_items(subs, sel, cfg)
    local items = {}
    for _, idx in ipairs(sel or {}) do
        local line = subs[idx]
        if line and line.class == "dialogue" and not line.comment then
            local os_ms = tonumber(line.start_time) or 0
            local oe_ms = tonumber(line.end_time) or 0
            local old_marks = {}
            for m in tostring(line.effect or ""):gmatch("%[TM%-([^%]%s]+)") do
                old_marks[m] = true
            end
            items[#items + 1] = {
                idx = idx, line = line, os = os_ms, oe = oe_ms,
                spoken = oe_ms > os_ms and is_spoken(line, cfg),
                chars = readable_chars(line.text),
                old_marks = old_marks,
                flags = {},
            }
        end
    end
    table.sort(items, function(a, b)
        if a.os == b.os then return a.idx < b.idx end
        return a.os < b.os
    end)
    return items
end

local function dialogue_ordinals(subs)
    local ord, n = {}, 0
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            n = n + 1
            ord[i] = n
        end
    end
    return ord
end

local function apply_items(subs, items)
    local flagged = {}
    for _, it in ipairs(items) do
        local line = it.line
        if it.use and it.s and it.e then
            local ns = round(it.s)
            local ne = math.max(round(it.e), ns + 10)
            line.start_time = ns
            line.end_time = ne
        end
        local eff = clean_marks(line.effect)
        if #it.flags > 0 then
            local tags = {}
            for _, fl in ipairs(it.flags) do tags[#tags + 1] = "[TM-" .. fl .. "]" end
            eff = (eff == "" and "" or eff .. " ") .. table.concat(tags, " ")
            flagged[#flagged + 1] = it
        end
        line.effect = eff
        subs[it.idx] = line
    end
    return flagged
end

local MODE_NAMES = { "voice match", "padding + cleanup", "full process" }





local function run_pipeline(subs, sel, cfg, mode, sig, kfs, kfset)
    local items = collect_items(subs, sel, cfg)
    if #items == 0 then return nil, "no_lines" end

    local stats = { matched = 0, spoken = 0, used = 0 }
    progress("Detecting voice...", 5)
    for k, it in ipairs(items) do
        if it.spoken then
            stats.spoken = stats.spoken + 1
            if mode == 2 then
                
                
                
                if it.old_marks["NOVOICE"] then
                    add_flag(it, "NOVOICE")
                else
                    it.vs, it.ve = it.os, it.oe
                    it.use = true
                    if it.old_marks["WEAK"] then add_flag(it, "WEAK") end
                end
            else
                
                
                local v = detect_voice(it, sig, cfg, kfs)
                local plaus_min = it.chars > 0 and (it.chars * 1000 / TUNE.max_sane_cps) or 0
                if not v or (v.ve - v.vs) < plaus_min then
                    local v2 = detect_voice(it, sig, cfg, kfs, true)
                    if v2 and (not v or (v2.ve - v2.vs) > (v.ve - v.vs)) then
                        v2.weak = true 
                        v = v2
                    end
                end
                if v then
                    if (v.ve - v.vs) < plaus_min then v.weak = true end
                    it.vs, it.ve = v.vs, v.ve
                    it.use = true
                    if v.weak then add_flag(it, "WEAK") end
                    stats.matched = stats.matched + 1
                else
                    add_flag(it, "NOVOICE")
                end
            end
            if it.use then stats.used = stats.used + 1 end
        end
        progress(nil, 5 + math.floor(45 * k / #items))
    end

    if mode ~= 2 and stats.matched == 0 then return nil, "no_voice" end

    progress("Planning timing...", 55)
    if mode == 1 then
        local prev
        for _, it in ipairs(items) do
            if it.use then
                it.s, it.e = it.vs, it.ve
                if prev and not stacked(prev, it) and it.s < prev.e then
                    add_flag(prev, "OVERLAP"); add_flag(it, "OVERLAP")
                end
                prev = it
            end
        end
    else
        plan_padding(items, kfs, kfset, cfg, stats)
    end
    add_cps_flags(items, cfg)

    progress("Applying...", 85)
    local ordinals = dialogue_ordinals(subs)
    local flagged = apply_items(subs, items)
    progress(nil, 100)
    return { items = items, flagged = flagged, stats = stats, ordinals = ordinals }
end

local VT = {
    DEFAULTS = DEFAULTS, TUNE = TUNE, GUI_BOUNDS = GUI_BOUNDS,
    PATH_KEYS = PATH_KEYS, MODE_NAMES = MODE_NAMES,
    parse_silence_file = parse_silence_file,
    parse_vad_file = parse_vad_file,
    parse_flux_file = parse_flux_file,
    parse_env_file = parse_env_file,
    parse_keyframe_file = parse_keyframe_file,
    classify_data_file = classify_data_file,
    chapter_of = chapter_of,
    make_interval_source = make_interval_source,
    detect_voice = detect_voice,
    plan_padding = plan_padding,
    add_cps_flags = add_cps_flags,
    normalize_cfg = normalize_cfg,
    style_ok = style_ok,
    get_cfg = get_cfg,
    save_cfg = save_cfg,
    session_paths = session_paths,
    discover_paths = discover_paths,
    list_dir = list_dir,
    script_dir_and_base = script_dir_and_base,
    build_signals = build_signals,
    get_keyframes = get_keyframes,
    run_pipeline = run_pipeline,
}

VTMOD = VT
return VTMOD
end

local CUE_MODES = { "Full Timing", "Post-Timing", "Raw Timing", "LZT Raw (Legacy)", "LZT Raw Silences" }
local CUE_MODE_SET = {}
for _, m in ipairs(CUE_MODES) do CUE_MODE_SET[m] = true end
local CUE_NUMERIC = {
    "lead_in_ms", "lead_out_ms", "max_lead_out_ms", "max_lead_in_ms",
    "kf_end_range_ms", "kf_start_range_ms", "kf_back_ms", "duration_floor_ms", "cps_flag",
}
local CUE_FLAGS = { "skip_signs", "show_stats", "style_filter", "extra_style" }
local CUE_TUNE
local CUE_SLOT_TAGS = { sil30 = "30", sil40 = "40", sil50 = "50", vad = "vad", flux = "flux", env = "env", keyframes = "kf" }

local function cueDetectChapters(VT)
    local dir = VT.script_dir_and_base()
    local chapters = {}
    if not dir then return chapters end
    local sep = package.config:sub(1, 1)
    for _, fname in ipairs(VT.list_dir(dir)) do
        local slot = VT.classify_data_file(fname)
        local ch = slot and VT.chapter_of(fname)
        if slot and ch then
            chapters[ch] = chapters[ch] or {}
            if not chapters[ch][slot] then chapters[ch][slot] = dir .. sep .. fname end
        end
    end
    return chapters
end

local function cueChapterSummary(VT, chapters)
    local nums = {}
    for n in pairs(chapters) do nums[#nums+1] = n end
    table.sort(nums)
    if #nums == 0 then return L("cue_none") end
    local parts = {}
    for _, n in ipairs(nums) do
        local slots = {}
        for _, key in ipairs(VT.PATH_KEYS) do
            if chapters[n][key] then slots[#slots+1] = CUE_SLOT_TAGS[key] or key end
        end
        parts[#parts+1] = string.format("%02d[%s]", n, table.concat(slots, ","))
    end
    local txt = table.concat(parts, "  ")
    if #txt > 70 then
        return string.format("%02d-%02d (%d)", nums[1], nums[#nums], #nums)
    end
    return txt
end

local function cueLztSelection(VT, subs, sel, cfg)
    local out = {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l and l.class == "dialogue" and VT.style_ok(l.style, cfg.style_filter, cfg.extra_style) then
            local skip = false
            if cfg.skip_signs then
                local st = tostring(l.style or ""):lower()
                skip = st:find("sign", 1, true) ~= nil or st:find("kara", 1, true) ~= nil or st:find("fx", 1, true) ~= nil
            end
            if not skip then out[#out+1] = i end
        end
    end
    return out
end

local function cueKfset(kfs)
    local set = {}
    for _, t in ipairs(kfs or {}) do set[t] = true end
    return set
end

local function cueRunPipeline(VT, subs, tsel, cfg, modeNum, sig, kfs, kfset)
    local res, why = VT.run_pipeline(subs, tsel, cfg, modeNum, sig, kfs, kfset)
    if not res then return nil, why end
    local s = res.stats
    local txt = string.format(L("cue_sum_vt"), s.used or 0, s.spoken or 0, s.snaps or 0, s.joins or 0, #res.flagged)
    local rows = {}
    for i, it in ipairs(res.flagged) do
        if i > 15 then rows[#rows+1] = string.format("(+%d)", #res.flagged - 15); break end
        rows[#rows+1] = string.format("#%d %s", res.ordinals[it.idx] or it.idx, table.concat(it.flags, ","))
    end
    if #rows > 0 then txt = txt .. "\n" .. table.concat(rows, "\n") end
    return txt, nil, #res.flagged
end

local function cueProcess(VT, subs, sel, cfg, chapters)
    local modeKey = currentConfig.cue_mode
    if not CUE_MODE_SET[modeKey] then modeKey = "Full Timing"; currentConfig.cue_mode = modeKey end
    local modeNum = (modeKey == "Full Timing") and 3 or (modeKey == "Post-Timing") and 2
        or (modeKey == "Raw Timing") and 1 or nil
    local silencesOnly = (modeKey == "LZT Raw Silences")

    if currentConfig.cue_multichapter then
        if next(chapters) == nil then showMsg(L("cue_err_no_chapters")); return nil end
        local groups, layers = {}, {}
        for _, i in ipairs(sel) do
            local l = subs[i]
            if l and l.class == "dialogue" then
                local layer = tonumber(l.layer) or 0
                if not groups[layer] then groups[layer] = {}; layers[#layers+1] = layer end
                table.insert(groups[layer], i)
            end
        end
        table.sort(layers)
        local parts, skipped, any, notable = {}, {}, false, false
        local layer0 = false
        for _, layer in ipairs(layers) do
            local files = chapters[layer]
            local txt
            if not files then
                skipped[#skipped+1] = tostring(layer)
                if layer == 0 then layer0 = true end
            elseif not modeNum then
                local modified = LZ.run(subs, cueLztSelection(VT, subs, groups[layer], cfg), {
                    sil30 = files.sil30 or "", sil40 = files.sil40 or "", sil50 = files.sil50 or "",
                    vad = files.vad or "", flux = files.flux or "",
                }, silencesOnly)
                if modified == nil then skipped[#skipped+1] = tostring(layer)
                else any = true; txt = string.format(L("cue_sum_lzt"), modified) end
            else
                local c2 = {}
                for k, v in pairs(cfg) do c2[k] = v end
                for _, key in ipairs(VT.PATH_KEYS) do c2[key] = files[key] or "" end
                local sig = VT.build_signals(c2)
                if modeNum ~= 2 and #sig.sources == 0 and not sig.env then
                    skipped[#skipped+1] = tostring(layer)
                else
                    local kfs = VT.parse_keyframe_file(c2.keyframes, c2)
                    local r, why, nflag = cueRunPipeline(VT, subs, groups[layer], c2, modeNum, sig, kfs, cueKfset(kfs))
                    if r then
                        any = true; txt = r
                        if (nflag or 0) > 0 then notable = true end
                    elseif why == "no_voice" then
                        txt = L("cue_no_voice"); notable = true
                    end
                end
            end
            if txt then parts[#parts+1] = string.format(L("cue_sum_layer"), layer) .. " " .. txt end
        end
        if #skipped > 0 then
            notable = true
            parts[#parts+1] = string.format(L("cue_msg_skipped"), table.concat(skipped, ", "))
            if layer0 then parts[#parts+1] = L("cue_hint_layer0") end
        end
        if not any then
            showMsg(#parts > 0 and table.concat(parts, "\n") or L("cue_err_no_chapters"))
            return nil
        end
        return table.concat(parts, "\n"), notable
    end

    if not modeNum then
        local modified = LZ.run(subs, cueLztSelection(VT, subs, sel, cfg), cfg, silencesOnly)
        if modified == nil then showMsg(L("cue_err_no_sil")); return nil end
        return string.format(L("cue_sum_lzt"), modified), false
    end
    local sig
    if modeNum ~= 2 then
        sig = VT.build_signals(cfg)
        if #sig.sources == 0 and not sig.env then showMsg(L("cue_err_no_data")); return nil end
    end
    local kfs, kfset = VT.get_keyframes(cfg)
    local txt, why, nflag = cueRunPipeline(VT, subs, sel, cfg, modeNum, sig, kfs, kfset)
    if not txt then
        showMsg(why == "no_lines" and L("err_no_selection") or L("cue_no_voice"))
        return nil
    end
    return txt, (nflag or 0) > 0
end

cueTimer = function(subs, sel)
    resolveConfig()
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return end
    local VT = getVT()

    if not CUE_MODE_SET[currentConfig.cue_mode] then currentConfig.cue_mode = "Full Timing" end
    local cfg = VT.get_cfg(currentConfig.cue_auto_discover ~= false)
    if CUE_TUNE then
        for k, v in pairs(CUE_TUNE) do cfg[k] = v end
        VT.normalize_cfg(cfg)
    end
    local _, _, subsName = VT.script_dir_and_base()
    local styles = collectStyles(subs, sel)
    do
        local present = {}
        for _, s in ipairs(styles) do present[s] = true end
        if cfg.style_filter ~= "" and not present[cfg.style_filter] then styles[#styles+1] = cfg.style_filter end
    end
    local B = VT.GUI_BOUNDS

    while true do
        local wasAutoDiscover = currentConfig.cue_auto_discover ~= false
        local chapters = wasAutoDiscover and cueDetectChapters(VT) or {}
        local modeUi = UI.options(CUE_MODES, currentConfig.cue_mode)
        local styleUi = UI.options(styles, cfg.style_filter)
        local d = {
            { class="label", label=string.format(L("cue_title"), subsName or "?"), x=0, y=0, width=6, height=1 },
            { class="label", label=L("cue_lbl_mode"), x=6, y=0, width=2, height=1 },
            { class="dropdown", name="cue_mode", items=modeUi.items, value=modeUi.value, x=8, y=0, width=4, height=1 },
            { class="checkbox", name="cue_multichapter", label=L("cue_chk_multi"), value=currentConfig.cue_multichapter and true or false, x=0, y=1, width=6, height=1 },
            { class="label", label=string.format(L("cue_lbl_chapters"), cueChapterSummary(VT, chapters)), x=6, y=1, width=6, height=1 },
            { class="checkbox", name="cue_auto_discover", label=L("cue_chk_auto_discover"), value=wasAutoDiscover, x=0, y=2, width=5, height=1 },
            { class="label", label=L("cue_lbl_files"), x=5, y=2, width=7, height=1 },
            { class="label", label=L("cue_lbl_sil30"), x=0, y=3, width=3, height=1 },
            { class="edit", name="sil30", text=cfg.sil30, x=3, y=3, width=9, height=1 },
            { class="label", label=L("cue_lbl_sil40"), x=0, y=4, width=3, height=1 },
            { class="edit", name="sil40", text=cfg.sil40, x=3, y=4, width=9, height=1 },
            { class="label", label=L("cue_lbl_sil50"), x=0, y=5, width=3, height=1 },
            { class="edit", name="sil50", text=cfg.sil50, x=3, y=5, width=9, height=1 },
            { class="label", label=L("cue_lbl_vad"), x=0, y=6, width=3, height=1 },
            { class="edit", name="vad", text=cfg.vad, x=3, y=6, width=9, height=1 },
            { class="label", label=L("cue_lbl_flux"), x=0, y=7, width=3, height=1 },
            { class="edit", name="flux", text=cfg.flux, x=3, y=7, width=9, height=1 },
            { class="label", label=L("cue_lbl_env"), x=0, y=8, width=3, height=1 },
            { class="edit", name="env", text=cfg.env, x=3, y=8, width=9, height=1 },
            { class="label", label=L("cue_lbl_kf"), x=0, y=9, width=3, height=1 },
            { class="edit", name="keyframes", text=cfg.keyframes, x=3, y=9, width=9, height=1 },
            { class="label", label=L("cue_lbl_leads"), x=0, y=10, width=3, height=1 },
            { class="intedit", name="lead_in_ms", value=cfg.lead_in_ms, min=B.lead_in_ms.min, max=B.lead_in_ms.max, x=3, y=10, width=2, height=1 },
            { class="intedit", name="lead_out_ms", value=cfg.lead_out_ms, min=B.lead_out_ms.min, max=B.lead_out_ms.max, x=5, y=10, width=2, height=1 },
            { class="label", label=L("cue_lbl_cut"), x=7, y=10, width=3, height=1 },
            { class="intedit", name="kf_back_ms", value=cfg.kf_back_ms, min=B.kf_back_ms.min, max=B.kf_back_ms.max, x=10, y=10, width=2, height=1 },
            { class="label", label=L("cue_lbl_kfrange"), x=0, y=11, width=3, height=1 },
            { class="intedit", name="kf_end_range_ms", value=cfg.kf_end_range_ms, min=B.kf_end_range_ms.min, max=B.kf_end_range_ms.max, x=3, y=11, width=2, height=1 },
            { class="intedit", name="kf_start_range_ms", value=cfg.kf_start_range_ms, min=B.kf_start_range_ms.min, max=B.kf_start_range_ms.max, x=5, y=11, width=2, height=1 },
            { class="label", label=L("cue_lbl_cps"), x=7, y=11, width=3, height=1 },
            { class="intedit", name="cps_flag", value=cfg.cps_flag, min=B.cps_flag.min, max=B.cps_flag.max, x=10, y=11, width=2, height=1 },
            { class="label", label=L("cue_lbl_chain"), x=0, y=12, width=3, height=1 },
            { class="intedit", name="max_lead_out_ms", value=cfg.max_lead_out_ms, min=B.max_lead_out_ms.min, max=B.max_lead_out_ms.max, x=3, y=12, width=2, height=1 },
            { class="intedit", name="max_lead_in_ms", value=cfg.max_lead_in_ms, min=B.max_lead_in_ms.min, max=B.max_lead_in_ms.max, x=5, y=12, width=2, height=1 },
            { class="label", label=L("cue_lbl_floor"), x=7, y=12, width=3, height=1 },
            { class="intedit", name="duration_floor_ms", value=cfg.duration_floor_ms, min=B.duration_floor_ms.min, max=B.duration_floor_ms.max, x=10, y=12, width=2, height=1 },
            { class="checkbox", name="skip_signs", label=L("cue_chk_signs"), value=cfg.skip_signs, x=0, y=13, width=5, height=1 },
            { class="checkbox", name="show_stats", label=L("cue_chk_stats"), value=cfg.show_stats, x=5, y=13, width=4, height=1 },
            { class="label", label=L("cue_lbl_style"), x=0, y=14, width=3, height=1 },
            { class="dropdown", name="style_filter", items=styleUi.items, value=styleUi.value, x=3, y=14, width=4, height=1 },
            { class="edit", name="extra_style", text=cfg.extra_style, x=7, y=14, width=5, height=1 },
            { class="label", label=L("cue_hint"), x=0, y=15, width=12, height=1 },
        }
        local pressed, r = aegisub.dialog.display(d, { L("btn_process"), L("btn_browse"), L("btn_save"), L("btn_cancel") }, { cancel = L("btn_cancel") })
        if not pressed or pressed == L("btn_cancel") then return end

        currentConfig.cue_mode = UI.from(modeUi, r.cue_mode)
        currentConfig.cue_multichapter = r.cue_multichapter and true or false
        currentConfig.cue_auto_discover = r.cue_auto_discover and true or false
        cfg.style_filter = UI.from(styleUi, r.style_filter)
        cfg.extra_style = normalizeString(r.extra_style)
        for _, k in ipairs(VT.PATH_KEYS) do cfg[k] = normalizeString(r[k]) end
        for _, k in ipairs(CUE_NUMERIC) do cfg[k] = r[k] end
        cfg.skip_signs = r.skip_signs and true or false
        cfg.show_stats = r.show_stats and true or false
        VT.normalize_cfg(cfg)
        CUE_TUNE = CUE_TUNE or {}
        for _, k in ipairs(CUE_NUMERIC) do CUE_TUNE[k] = cfg[k] end
        for _, k in ipairs(CUE_FLAGS) do CUE_TUNE[k] = cfg[k] end
        local sp = VT.session_paths(currentConfig.cue_auto_discover ~= false)
        if currentConfig.cue_auto_discover and not wasAutoDiscover then
            VT.discover_paths(sp)
            for _, k in ipairs(VT.PATH_KEYS) do
                if cfg[k] == "" then cfg[k] = sp[k] or "" end
            end
        end
        for _, k in ipairs(VT.PATH_KEYS) do sp[k] = cfg[k] end
        chapters = currentConfig.cue_auto_discover and cueDetectChapters(VT) or {}

        if pressed == L("btn_save") then
            VT.save_cfg(cfg)
            showMsg(L("msg_config_saved"))
        elseif pressed == L("btn_browse") then
            local dir = VT.script_dir_and_base() or ""
            local ok, got = pcall(aegisub.dialog.open, "Cue Timer", "", dir, "*.txt;*.log;*.tsv;*.csv", true, true)
            if ok and got then
                local picks = type(got) == "table" and got or { got }
                local unknown = {}
                for _, p in ipairs(picks) do
                    if type(p) == "string" and p ~= "" then
                        local slot = VT.classify_data_file(p:match("[^/\\]+$") or p)
                        if slot then cfg[slot] = p else unknown[#unknown+1] = p end
                    end
                end
                for _, k in ipairs(VT.PATH_KEYS) do sp[k] = cfg[k] end
                if #unknown > 0 then showMsg(string.format(L("cue_files_unknown"), table.concat(unknown, "\n"))) end
            end
        else
            saveConfig()
            local summary, notable = cueProcess(VT, subs, sel, cfg, chapters)
            if summary then
                aegisub.set_undo_point("Chrono Suite - Cue Timer")
                if cfg.show_stats or notable then
                    showMsg(string.format(L("cue_msg_done"), UI.text(currentConfig.cue_mode), summary))
                end
                return sel
            end
        end
    end
end
end

local runScxvid, screamDetector
do
local function quoteWin(p)  return '"' .. normalizeString(p):gsub('"', '""') .. '"' end
local function quoteUnix(p) return "'" .. normalizeString(p):gsub("'", "'\\''") .. "'" end

function runScxvid()
    resolveConfig()
    local scx = currentConfig.scxvid_path
    local ffm = currentConfig.ffmpeg_path
    local sfx = currentConfig.scxvid_suffix
    local props = aegisub.project_properties()
    local video = props and props.video_file
    if not video or video == "" then showMsg(L("err_no_video")); return end
    local isWindows = package.config:sub(1, 1) == "\\"
    local function fExists(p) if p == "" then return false end; local f = io.open(p); if f then f:close(); return true end end
    local function dirName(p) return p:match("^(.*)[\\/]") or "" end
    local function baseName(p) return (p:gsub("^.*[\\/]", ""):gsub("%.[^.]+$", "")) end
    local SCX = (scx ~= "" and scx or (isWindows and "scxvid.exe" or "scxvid"))
    local FFM = (ffm ~= "" and ffm or "ffmpeg")
    if scx ~= "" and not fExists(scx) then showMsg(string.format(L("err_scxvid_not_found"), scx)); return end
    if ffm ~= "" and not fExists(ffm) then showMsg(string.format(L("err_ffmpeg_not_found"), ffm)); return end
    local dir = dirName(video)
    local sep = isWindows and "\\" or "/"
    local outLog = dir .. (dir ~= "" and sep or "") .. baseName(video) .. (sfx ~= "" and sfx or "_keyframes.log")
    if isWindows then
        local bat = aegisub.decode_path("?temp/scxvid_run.bat")
        local f = io.open(bat, "w")
        if not f then showMsg(L("err_cannot_create_batch")); return end
        local cmd = table.concat({
            "@echo off",
            "setlocal",
            "title Chrono Suite - Extract KF (SCXvid)",
            quoteWin(FFM) .. " -hide_banner -i " .. quoteWin(video) ..
                " -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | " ..
                quoteWin(SCX) .. " " .. quoteWin(outLog),
            "echo.",
            "echo Done. Output: " .. quoteWin(outLog),
            "pause",
            "endlocal",
            "",
        }, "\r\n")
        f:write(cmd); f:close()
        os.execute('start "" ' .. quoteWin(bat))
    else
        local sh = aegisub.decode_path("?temp/scxvid_run.sh")
        local f = io.open(sh, "w")
        if not f then showMsg(L("err_cannot_create_shell")); return end
        local cmd = table.concat({
            "#!/bin/sh",
            quoteUnix(FFM) .. " -hide_banner -i " .. quoteUnix(video) ..
                " -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | " ..
                quoteUnix(SCX) .. " " .. quoteUnix(outLog),
            "",
        }, "\n")
        f:write(cmd); f:close()
        os.execute("chmod +x " .. quoteUnix(sh))
        os.execute(quoteUnix(sh) .. " &")
    end
    showMsg(string.format(L("msg_process_started"), outLog))
end

local Scream = { MARKER = "[SCREAM]" }
function Scream.decodedPath(spec)
    if not aegisub.decode_path then return "" end
    local ok, path = pcall(aegisub.decode_path, spec)
    if ok and type(path) == "string" and path ~= spec then return path end
    return ""
end

function Scream.fileExists(path)
    if not path or path == "" then return false end
    local f = io.open(path, "r"); if f then f:close(); return true end
    return false
end

function Scream.mediaPath()
    local props = aegisub.project_properties and aegisub.project_properties() or {}
    if type(props) == "table" then
        for _, path in ipairs({ props.audio_file or "", props.video_file or "" }) do
            if path ~= "" and Scream.fileExists(path) then return path end
        end
    end
    for _, spec in ipairs({ "?audio", "?video" }) do
        local p = Scream.decodedPath(spec)
        if p ~= "" and Scream.fileExists(p) then return p end
    end
    return nil
end

function Scream.dirName(path)
    return normalizeString(path):match("^(.*)[\\/]") or ""
end

function Scream.workFolder(media)
    for _, spec in ipairs({ "?script", "?temp" }) do
        local p = Scream.decodedPath(spec)
        if p ~= "" then
            if Scream.fileExists(p) then return Scream.dirName(p) end
            return p
        end
    end
    return Scream.dirName(media or "")
end

function Scream.join(folder, name)
    if folder == "" then return name end
    local last = folder:sub(-1)
    if last == "\\" or last == "/" then return folder .. name end
    local sep = package.config:sub(1, 1) == "\\" and "\\" or "/"
    return folder .. sep .. name
end

function Scream.median(values)
    if #values == 0 then return 0 end
    table.sort(values)
    local mid = math.floor((#values + 1) / 2)
    if #values % 2 == 1 then return values[mid] end
    return (values[mid] + values[mid + 1]) / 2
end

function Scream.dbToPower(db) return 10 ^ (db / 10) end
function Scream.powerToDb(power)
    if not power or power <= 0 then return -120 end
    return 10 * math.log(power) / math.log(10)
end

function Scream.annotateSpans(samples)
    local gaps = {}
    for i = 2, #samples do
        local gap = samples[i].time - samples[i - 1].time
        if gap > 0 then gaps[#gaps+1] = gap end
    end
    local medianGap = Scream.median(gaps)
    if medianGap <= 0 then medianGap = 40 end
    for i, sample in ipairs(samples) do
        local left  = i > 1 and (sample.time - samples[i - 1].time) or medianGap
        local right = i < #samples and (samples[i + 1].time - sample.time) or medianGap
        if left  <= 0 then left  = medianGap end
        if right <= 0 then right = medianGap end
        if left  > medianGap * 3 then left  = medianGap end
        if right > medianGap * 3 then right = medianGap end
        sample.start  = sample.time - left  / 2
        sample["end"] = sample.time + right / 2
    end
end

function Scream.parseLog(path)
    local f = io.open(path, "r"); if not f then return {} end
    local samples, timeMs = {}, nil
    for line in f:lines() do
        local t = line:match("pts_time:([%-%d%.]+)")
        if t then timeMs = tonumber(t) and tonumber(t) * 1000 or nil end
        local peak = line:match("lavfi%.astats%.Overall%.Peak_level=([%-%d%.]+)")
        if peak and timeMs then
            local db = tonumber(peak)
            if db then samples[#samples+1] = { time = timeMs, db = db, power = Scream.dbToPower(db) } end
        end
    end
    f:close()
    table.sort(samples, function(a, b) return a.time < b.time end)
    Scream.annotateSpans(samples)
    return samples
end

function Scream.firstSampleIndex(samples, t)
    local lo, hi = 1, #samples + 1
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if samples[mid].time < t then lo = mid + 1 else hi = mid end
    end
    return lo
end

function Scream.scoreLine(line, samples, cfg)
    local startT, endT = line.start_time or 0, line.end_time or 0
    local count, loud, powerSum, peakDb = 0, 0, 0, -120
    for k = Scream.firstSampleIndex(samples, startT), #samples do
        local sample = samples[k]
        if sample.start > endT then break end
        if sample.start >= startT and sample["end"] <= endT then
            count = count + 1
            powerSum = powerSum + sample.power
            if sample.db >= cfg.scream_sample_db then loud = loud + 1 end
            if sample.db > peakDb then peakDb = sample.db end
        end
    end
    if count == 0 then
        return { samples = 0, avg_db = -120, peak_db = -120, loud_ratio = 0, robust_z = 0 }
    end
    return {
        samples    = count,
        avg_db     = Scream.powerToDb(powerSum / count),
        peak_db    = peakDb,
        loud_ratio = loud / count,
        robust_z   = 0,
    }
end

function Scream.robustStats(scores)
    local values = {}
    for _, s in ipairs(scores) do if s.samples > 0 then values[#values+1] = s.avg_db end end
    local med = Scream.median(values)
    if #values < 5 then return med, 0, 0 end
    local deviations = {}
    for _, v in ipairs(values) do deviations[#deviations+1] = math.abs(v - med) end
    local mad = Scream.median(deviations)
    local sigma = mad * 1.4826
    if sigma < 0.25 then sigma = 0 end
    return med, mad, sigma
end

function Scream.passes(score, cfg, sigma)
    if score.samples < cfg.scream_min_samples then return false end
    if score.avg_db < cfg.scream_avg_db then return false end
    if score.loud_ratio < (cfg.scream_loud_ratio / 100) then return false end
    if cfg.scream_robust_z > 0 and sigma > 0 and score.robust_z < cfg.scream_robust_z then return false end
    return true
end

function Scream.stripMarker(effect)
    return trimText(normalizeString(effect):gsub("%s*%[SCREAM%]", ""))
end

function Scream.writeBat(media, folder)
    local isWindows = package.config:sub(1, 1) == "\\"
    local logName = "chrono_suite_scream.log"
    local logPath = Scream.join(folder, logName)
    local filter = "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=" .. logName
    if isWindows then
        local batPath = Scream.join(folder, "chrono_suite_scream.bat")
        local cmd = table.concat({
            "@echo off",
            "setlocal",
            "cd /d " .. quoteWin(folder),
            "del /q " .. quoteWin(logName) .. " 2>nul",
            "ffmpeg -hide_banner -y -i " .. quoteWin(media) .. " -map 0:a:0 -vn -af " .. quoteWin(filter) .. " -f null NUL",
            "endlocal",
            "",
        }, "\r\n")
        local f = io.open(batPath, "w"); if not f then return nil, nil end
        f:write(cmd); f:close()
        return batPath, logPath
    end
    local shPath = Scream.join(folder, "chrono_suite_scream.sh")
    local cmd = table.concat({
        "#!/bin/sh",
        "cd " .. quoteUnix(folder),
        "rm -f " .. quoteUnix(logName),
        "ffmpeg -hide_banner -y -i " .. quoteUnix(media) .. " -map 0:a:0 -vn -af " .. quoteUnix(filter) .. " -f null /dev/null",
        "",
    }, "\n")
    local f = io.open(shPath, "w"); if not f then return nil, nil end
    f:write(cmd); f:close()
    os.execute("chmod +x " .. quoteUnix(shPath))
    return shPath, logPath
end

function Scream.runBat(batPath)
    if package.config:sub(1, 1) == "\\" then return os.execute('cmd /c ""' .. batPath .. '""') end
    return os.execute(quoteUnix(batPath))
end

function Scream.configDialog()
    resolveConfig()
    local scopeUi = UI.options({ "All dialogue", "Selected lines" }, currentConfig.scream_scope)
    local dlg = {
        { class = "label", label = L("scream_title"),     x = 0, y = 0, width = 10, height = 1 },
        { class = "label", label = L("scream_lbl_avg"),    x = 0, y = 1, width = 6, height = 1 },
        { class = "edit",  name  = "scream_avg_db",        value = tostring(currentConfig.scream_avg_db),    x = 6, y = 1, width = 4, height = 1 },
        { class = "label", label = L("scream_lbl_sample"), x = 0, y = 2, width = 6, height = 1 },
        { class = "edit",  name  = "scream_sample_db",     value = tostring(currentConfig.scream_sample_db), x = 6, y = 2, width = 4, height = 1 },
        { class = "label", label = L("scream_lbl_ratio"),  x = 0, y = 3, width = 6, height = 1 },
        { class = "intedit", name = "scream_loud_ratio",   value = currentConfig.scream_loud_ratio, min = 0, max = 100, x = 6, y = 3, width = 4, height = 1 },
        { class = "label", label = L("scream_lbl_min"),    x = 0, y = 4, width = 6, height = 1 },
        { class = "intedit", name = "scream_min_samples", value = currentConfig.scream_min_samples, min = 1, x = 6, y = 4, width = 4, height = 1 },
        { class = "label", label = L("scream_lbl_z"),      x = 0, y = 5, width = 6, height = 1 },
        { class = "edit",  name  = "scream_robust_z",      value = tostring(currentConfig.scream_robust_z),  x = 6, y = 5, width = 4, height = 1 },
        { class = "label", label = L("lbl_apply_to"),      x = 0, y = 6, width = 6, height = 1 },
        { class = "dropdown", name = "scream_scope", items = scopeUi.items, value = scopeUi.value, x = 6, y = 6, width = 4, height = 1 },
        { class = "checkbox", name = "scream_clean_previous", label = L("scream_chk_clean"), value = currentConfig.scream_clean_previous, x = 0, y = 7, width = 10, height = 1 },
        { class = "checkbox", name = "scream_reuse_log",      label = L("scream_chk_reuse"), value = currentConfig.scream_reuse_log,      x = 0, y = 8, width = 10, height = 1 },
    }
    local btn, res = aegisub.dialog.display(dlg, { L("scream_btn_analyze"), L("btn_cancel") }, { cancel = L("btn_cancel") })
    if not btn or btn == L("btn_cancel") then return nil end
    local scope = UI.from(scopeUi, res.scream_scope)
    if scope ~= "Selected lines" then scope = "All dialogue" end
    local cfg = {
        scream_avg_db        = tonumber(res.scream_avg_db)        or currentConfig.scream_avg_db,
        scream_sample_db     = tonumber(res.scream_sample_db)     or currentConfig.scream_sample_db,
        scream_loud_ratio    = math.max(0, math.min(100, tonumber(res.scream_loud_ratio) or currentConfig.scream_loud_ratio)),
        scream_min_samples   = math.max(1, tonumber(res.scream_min_samples) or currentConfig.scream_min_samples),
        scream_robust_z      = math.max(0, tonumber(res.scream_robust_z) or currentConfig.scream_robust_z),
        scream_clean_previous = res.scream_clean_previous == true,
        scream_reuse_log     = res.scream_reuse_log == true,
        scream_scope         = scope,
    }
    for k, v in pairs(cfg) do currentConfig[k] = v end
    saveConfig()
    return cfg
end

function screamDetector(subs, sel)
    resolveConfig()
    local media = Scream.mediaPath()
    if not media then showMsg(L("scream_msg_no_media")); return end
    local cfg = Scream.configDialog()
    if not cfg then return end
    local folder = Scream.workFolder(media)
    if folder == "" then showMsg(L("scream_msg_no_folder")); return end
    local batPath, logPath = Scream.writeBat(media, folder)
    if not batPath then showMsg(L("scream_msg_no_batch")); return end
    if not cfg.scream_reuse_log or not Scream.fileExists(logPath) then
        showMsg(L("scream_msg_running"))
        Scream.runBat(batPath)
    end
    local samples = Scream.parseLog(logPath)
    if #samples == 0 then showMsg(string.format(L("scream_msg_no_log"), batPath)); return end
    local lookup, restrictToSel = {}, cfg.scream_scope == "Selected lines"
    if restrictToSel and sel then for _, idx in ipairs(sel) do lookup[idx] = true end end
    local candidates, scores, scanned = {}, {}, 0
    for i = 1, #subs do
        local line = subs[i]
        if isDialogue(line) and not line.comment and (not restrictToSel or lookup[i]) then
            scanned = scanned + 1
            local s = Scream.scoreLine(line, samples, cfg)
            candidates[#candidates+1] = { index = i, score = s }
            scores[#scores+1] = s
        end
    end
    local medianDb, madDb, sigmaDb = Scream.robustStats(scores)
    for _, c in ipairs(candidates) do
        if sigmaDb > 0 then c.score.robust_z = (c.score.avg_db - medianDb) / sigmaDb end
    end
    local marked = 0
    for _, c in ipairs(candidates) do
        local i = c.index
        local line = subs[i]
        if isDialogue(line) and not line.comment then
            if cfg.scream_clean_previous then line.effect = Scream.stripMarker(line.effect) end
            if Scream.passes(c.score, cfg, sigmaDb) then
                line.effect = Scream.stripMarker(line.effect)
                line.effect = trimText(line.effect == "" and Scream.MARKER or (line.effect .. " " .. Scream.MARKER))
                marked = marked + 1
            end
            subs[i] = line
        end
    end
    aegisub.set_undo_point("Chrono Suite - Scream Detector")
    showMsg(string.format(L("scream_msg_done"), marked, scanned, #samples, medianDb, madDb))
    return true
end
end

local function ktCalcLeadIn(orig_start, boundary, kfs, cfg)
    local hard = boundary or 0
    local kf = ktFindKfBackward(orig_start, cfg.kt_lead_in_max, kfs)
    if kf and kf >= hard then return kf end
    return ktSnap(math.max(orig_start - cfg.kt_lead_in_base, hard))
end
local function ktCalcLeadOut(orig_end, boundary, kfs, cfg)
    local kf = ktFindKfForward(orig_end, cfg.kt_lead_out_max, kfs)
    if kf and (not boundary or kf <= boundary) then return kf end
    local base = orig_end + cfg.kt_lead_out_base
    if boundary then base = math.min(base, boundary) end
    return ktSnap(base)
end

local function kiteTimingOne(subs, si, kfs, cfg)
    local cur = subs[si]
    if not isEditableDialogue(cur) or not cur.start_time or not cur.end_time then return 0 end
    local before = {
        [si] = { start_time = cur.start_time, end_time = cur.end_time },
    }
    local prev_idx, next_idx
    for j = si - 1, 1, -1 do if isEditableDialogue(subs[j]) then prev_idx = j; break end end
    for j = si + 1, #subs do if isEditableDialogue(subs[j]) then next_idx = j; break end end
    local new_s, new_e = cur.start_time, cur.end_time
    local pending_next_start
    if not prev_idx and not ktIsOnKf(cur.start_time, kfs) then
        new_s = ktCalcLeadIn(cur.start_time, nil, kfs, cfg)
    end
    if next_idx then
        local nxt = subs[next_idx]
        if not nxt.start_time then return 0 end
        before[next_idx] = { start_time = nxt.start_time, end_time = nxt.end_time }
        local orig_e1, orig_s2 = cur.end_time, nxt.start_time
        local e1_locked = ktIsOnKf(orig_e1, kfs)
        local s2_locked = ktIsOnKf(orig_s2, kfs)
        local gap = orig_s2 - orig_e1
        local new_e1, new_s2 = orig_e1, orig_s2
        if e1_locked and s2_locked then
        elseif e1_locked then
            if gap > 0 then
                if gap <= cfg.kt_lead_in_max and gap <= cfg.kt_chain_gap_max then new_s2 = orig_e1
                else new_s2 = ktCalcLeadIn(orig_s2, orig_e1, kfs, cfg) end
            elseif gap < 0 then
                new_s2 = ktCalcLeadIn(orig_s2, nil, kfs, cfg)
                if new_s2 < 0 then new_s2 = 0 end
            end
        elseif s2_locked then
            if gap > 0 then
                local reach = orig_s2 - orig_e1
                if reach >= 0 and reach <= cfg.kt_lead_out_chain and gap <= cfg.kt_chain_gap_max then new_e1 = orig_s2
                else new_e1 = ktCalcLeadOut(orig_e1, orig_s2, kfs, cfg) end
            elseif gap < 0 then
                new_e1 = ktCalcLeadOut(orig_e1, nil, kfs, cfg)
            end
        elseif gap > 0 then
            local kf1 = ktFindKfForward(orig_e1, cfg.kt_lead_out_max, kfs)
            if kf1 and kf1 > orig_s2 then kf1 = nil end
            local kf2 = ktFindKfBackward(orig_s2, cfg.kt_lead_in_max, kfs)
            if kf2 and kf2 < orig_e1 then kf2 = nil end
            local base_e1 = ktSnap(math.min(orig_e1 + cfg.kt_lead_out_base, orig_s2))
            local base_s2 = ktSnap(math.max(orig_s2 - cfg.kt_lead_in_base, orig_e1))
            if kf1 and kf2 then
                new_e1 = kf1; new_s2 = kf2
                if new_e1 > new_s2 then local mid = ktSnap((new_e1 + new_s2) / 2); new_e1 = mid; new_s2 = mid end
            elseif kf1 and not kf2 then
                new_e1 = kf1
                local reach = orig_s2 - kf1
                if reach >= 0 and reach <= cfg.kt_lead_in_max and gap <= cfg.kt_chain_gap_max then new_s2 = kf1 else new_s2 = base_s2 end
            elseif not kf1 and kf2 then
                new_s2 = kf2
                local reach = kf2 - orig_e1
                if reach >= 0 and reach <= cfg.kt_lead_out_chain and gap <= cfg.kt_chain_gap_max then new_e1 = kf2 else new_e1 = base_e1 end
            else
                if gap <= cfg.kt_chain_gap_max and gap <= (cfg.kt_lead_out_chain + cfg.kt_lead_in_max) then
                    new_s2 = base_s2; new_e1 = new_s2
                else
                    new_e1 = base_e1; new_s2 = base_s2
                    if new_e1 > new_s2 then local mid = ktSnap((new_e1 + new_s2) / 2); new_e1 = mid; new_s2 = mid end
                end
            end
        elseif gap < 0 then
            new_e1 = ktCalcLeadOut(orig_e1, nil, kfs, cfg)
            new_s2 = ktCalcLeadIn(orig_s2, nil, kfs, cfg)
            if new_s2 < 0 then new_s2 = 0 end
        end
        new_e = new_e1
        pending_next_start = new_s2
    else
        if not ktIsOnKf(cur.end_time, kfs) then
            new_e = ktCalcLeadOut(cur.end_time, nil, kfs, cfg)
        end
    end
    if new_e <= new_s then return 0 end
    if next_idx and pending_next_start then
        local nxt = subs[next_idx]
        if not nxt or not nxt.end_time or pending_next_start >= nxt.end_time then return 0 end
    end
    cur.start_time = new_s; cur.end_time = new_e; subs[si] = cur
    if next_idx and pending_next_start then
        local nxt = subs[next_idx]
        nxt.start_time = pending_next_start
        subs[next_idx] = nxt
    end

    local changed = 0
    for idx, old in pairs(before) do
        local line = subs[idx]
        if line and (line.start_time ~= old.start_time or line.end_time ~= old.end_time) then changed = changed + 1 end
    end
    return changed
end

local function kiteTiming(subs, sel)
    resolveConfig()
    local okFrame = false
    if fr_to and ms_from then
        local ok, f0, m0 = pcall(function() return fr_to(0), ms_from(0) end)
        okFrame = ok and f0 ~= nil and m0 ~= nil
    end
    if not okFrame then showMsg(L("err_no_video")); return end
    sel = collectEditableSelection(subs, sel or {})
    if #sel == 0 then showMsg(L("err_no_selection")); return end
    table.sort(sel)
    local kfs = getKfSet()
    local cfg = currentConfig
    local changed = 0
    for _, si in ipairs(sel) do
        changed = changed + kiteTimingOne(subs, si, kfs, cfg)
    end
    showMsg(string.format(L("msg_kite_done"), changed, #sel))
end

local function frameToEffect(subs, sel)
    local props = aegisub.project_properties()
    if not props or not props.video_position then showMsg(L("err_no_video")); return end
    local frame = tostring(props.video_position)
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class == "dialogue" then
            local effect = normalizeString(l.effect)
            l.effect = (effect == "" and frame or (effect .. " " .. frame))
            subs[i] = l
        end
    end
end

local function splitRomaji(w)
    local t, pos, len = {}, 1, #w
    local function peek(n) return pos + n - 1 <= len and w:sub(pos, pos + n - 1) or nil end
    local function consume(n) local s = w:sub(pos, pos + n - 1); pos = pos + n; return s end
    local function isVowel(c) return c and c:match("[aiueo]") end
    while pos <= len do
        local found = false
        local c1, c2, c3, c4 = peek(1), peek(2), peek(3), peek(4)
        if c4 then
            local p4 = { "kky[auo]","ssy[auo]","tty[auo]","ppy[auo]","ggy[auo]","zzy[auo]",
                         "ddy[auo]","bby[auo]","mmy[auo]","nny[auo]","rry[auo]","hhy[auo]" }
            for _, p in ipairs(p4) do if c4:match("^" .. p .. "$") then t[#t+1] = consume(4); found = true; break end end
        end
        if not found and c3 then
            local p3 = { "nn[aiueo]","mm[aiueo]","kk[aiueo]","ss[aiueo]","tt[aiueo]","pp[aiueo]",
                         "gg[aiueo]","zz[aiueo]","dd[aiueo]","bb[aiueo]","rr[aiueo]","hh[aiueo]","yy[aiueo]",
                         "kya","kyu","kyo","gya","gyu","gyo","sha","shu","sho","cha","chu","cho",
                         "nya","nyu","nyo","hya","hyu","hyo","bya","byu","byo","pya","pyu","pyo",
                         "mya","myu","myo","rya","ryu","ryo","tsu","shi","chi",
                         "tta","kka","ssa","ppa","gga","zza","dda","bba","mma","nna","rra","hha","yya" }
            for _, p in ipairs(p3) do if c3:match("^" .. p .. "$") then t[#t+1] = consume(3); found = true; break end end
        end
        if not found and c2 then
            local p2 = { "ka","ki","ku","ke","ko","ga","gi","gu","ge","go","sa","si","su","se","so",
                         "za","zi","zu","ze","zo","ta","ti","tu","te","to","da","di","du","de","do",
                         "na","ni","nu","ne","no","ha","hi","hu","he","ho","ba","bi","bu","be","bo",
                         "pa","pi","pu","pe","po","ma","mi","mu","me","mo","ya","yu","yo",
                         "ra","ri","ru","re","ro","wa","wi","wu","we","wo","nn","n'",
                         "aa","ii","uu","ee","oo","ou","oa","oe","oi","ue","ua","ui","ai","au","ei",
                         "ia","ie","iu","uo" }
            for _, p in ipairs(p2) do
                if c2:match("^" .. p .. "$") then
                    if p == "nn" and isVowel(peek(3)) then t[#t+1] = consume(1); found = true; break
                    else t[#t+1] = consume(2); found = true; break end
                end
            end
        end
        if not found and c1 then
            if c1:match("[aiueon]") then t[#t+1] = consume(1); found = true end
        end
        if not found then t[#t+1] = consume(1) end
    end
    if #t == 0 then t[1] = w end
    return t
end

local function romajiKara(subs, sel)
    aegisub.progress.task("Romaji Karaoker (Kana-Beat \\\\k)...")
    for idx, i in ipairs(sel) do
        aegisub.progress.set(idx / #sel * 100)
        local ln = subs[i]
        local groups = {}
        for w in ln.text:gmatch("%S+") do groups[#groups+1] = splitRomaji(w) end
        local tot = 0; for _, g in ipairs(groups) do tot = tot + #g end
        if tot == 0 then tot = 1 end
        local cs = math.floor((ln.end_time - ln.start_time) / 10 + 0.5)
        local base, rem = math.floor(cs / tot), cs % tot
        local out, kix = "", 1
        for wi, g in ipairs(groups) do
            for _, sy in ipairs(g) do
                local d = base + (kix <= rem and 1 or 0)
                out = out .. ("{\\k" .. d .. "}" .. sy)
                kix = kix + 1
            end
            if wi < #groups then out = out .. " " end
        end
        ln.text = out; subs[i] = ln
    end
end

local function foldCopy(subs, sel)
    if #sel == 0 then showMsg(L("err_no_lines_selected")); return end
    local act = sel[1]
    local function parseLineFold(line)
        if not line.extra then return nil end
        local info = line.extra["_aegi_folddata"]; if not info then return nil end
        local side, collapsed, id = info:match("^(%d+);(%d+);(%d+)$")
        if not side then return nil end
        return { side = tonumber(side), collapsed = tonumber(collapsed), id = tonumber(id) }
    end
    local foldStack, newSelection, foldAroundLine = {}, {}
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local line = subs[i]
            local fd = parseLineFold(line)
            if fd and fd.side == 0 then table.insert(foldStack, { index = i, id = fd.id }) end
            if i == act then
                if #foldStack == 0 then
                    showMsg(L("err_not_inside_fold"))
                    return
                end
                foldAroundLine = foldStack[#foldStack]
                newSelection = {}
                for j = foldAroundLine.index, i do table.insert(newSelection, j) end
            elseif i > act and foldAroundLine then
                table.insert(newSelection, i)
            end
            if fd and fd.side == 1 then
                if #foldStack > 0 and foldStack[#foldStack].id == fd.id then
                    table.remove(foldStack)
                    if foldAroundLine and foldAroundLine.id == fd.id then break end
                end
            end
        end
    end
    if not foldAroundLine or #newSelection == 0 then
        showMsg(L("err_no_fold_group")); return
    end
    local clipboard = {}
    for _, idx in ipairs(newSelection) do
        local l = subs[idx]
        if l.class == "dialogue" then
            local s = string.format("%s: %d,%s,%s,%s,%s,%d,%d,%d,%s,%s",
                l.comment and "Comment" or "Dialogue",
                l.layer, msToAssTime(l.start_time), msToAssTime(l.end_time),
                l.style, l.actor, l.margin_l or 0, l.margin_r or 0, l.margin_t or l.margin_v or 0,
                l.effect, l.text)
            table.insert(clipboard, s)
        end
    end
    local txt = table.concat(clipboard, "\n")
    aegisub.dialog.display({
        { class = "label", label = string.format("Fold group found (%d lines).\nCopy text below:", #newSelection), x = 0, y = 0, width = 40, height = 1 },
        { class = "textbox", name = "clipboard", text = txt, x = 0, y = 1, width = 40, height = 20 },
    }, { L("btn_ok") })
    return newSelection
end

local function aeKeyframeExport(subs, sel)
    local FPS = getFps()
    local vw, vh = aegisub.video_size()
    if not vw then vw, vh = 1920, 1080 end
    local frame_ms = 1000 / FPS
    local out_pos = { "Adobe After Effects 6.0 Keyframe Data\n", "\tUnits Per Second\t" .. FPS .. "\n",
                      "\tSource Width\t" .. vw .. "\n", "\tSource Height\t" .. vh .. "\n",
                      "\tSource Pixel Aspect Ratio\t1\n", "\tComp Pixel Aspect Ratio\t1\n\n",
                      "Position\n\tFrame\tX pixels\tY pixels\tZ pixels\n" }
    local out_scale = { "\nScale\n\tFrame\tX percent\tY percent\tZ percent\n" }
    local out_rot   = { "\nRotation\n\tFrame\tDegrees\n" }
    local gframe = 0
    for _, idx in ipairs(sel) do
        local line = subs[idx]
        if isDialogue(line) and validateDuration(line) then
            local text = normalizeString(line.text)
            local nf = math.max(1, math.floor((line.end_time - line.start_time) / frame_ms + 0.5))
            local x = text:match("\\pos%(([%d%.-]+),") or "960"
            local y = text:match("\\pos%([%d%.-]+,([%d%.-]+)%)") or "540"
            local fscx = text:match("\\fscx([%d%.-]+)") or "100"
            local fscy = text:match("\\fscy([%d%.-]+)") or "100"
            local frz  = text:match("\\frz([%d%.-]+)")  or "0"
            for _ = 1, nf do
                table.insert(out_pos,   string.format("\t%d\t%s\t%s\t0\n", gframe, x, y))
                table.insert(out_scale, string.format("\t%d\t%s\t%s\t%s\n", gframe, fscx, fscy, fscx))
                table.insert(out_rot,   string.format("\t%d\t%s\n", gframe, frz))
                gframe = gframe + 1
            end
        end
    end
    table.insert(out_rot, "\nEnd of Keyframe Data")
    local payload = table.concat(out_pos) .. table.concat(out_scale) .. table.concat(out_rot)
    local save_path = aegisub.dialog.save and aegisub.dialog.save("Save AE keyframe data", "", "ae_keyframes.txt", "*.txt", false) or nil
    if save_path and save_path ~= "" then
        local f = io.open(save_path, "w")
        if f then f:write(payload); f:close(); showMsg(string.format(L("msg_ae_saved"), save_path)); return end
        showMsg(string.format(L("err_cannot_write_file"), save_path))
    end
    aegisub.log(payload)
end

local function stutterManager(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local has_TT = normalizeString(l.effect):find("%[TT%]") ~= nil
        local pre, text = splitLeadingBraceBlocks(l.text)
        local punct, rest = "", text
        local scanning = true
        while scanning do
            if startsWith(rest, INV_EXCLAMATION) then punct = punct .. INV_EXCLAMATION; rest = rest:sub(#INV_EXCLAMATION + 1)
            elseif startsWith(rest, INV_QUESTION) then punct = punct .. INV_QUESTION; rest = rest:sub(#INV_QUESTION + 1)
            elseif rest:match("^%s") then punct = punct .. rest:sub(1, 1); rest = rest:sub(2)
            else scanning = false end
        end
        local chars = {}
        for c in rest:gmatch(UTF8_CHAR_PATTERN) do table.insert(chars, c) end
        if #chars > 0 and chars[1]:match("[%a\128-\255]") then
            local first = chars[1]
            local base = unicodeUpper(first)
            local firstLower = unicodeLower(first)
            local is_stutter = (#chars >= 3 and chars[2] == "-" and unicodeLower(chars[3]) == firstLower)
            if is_stutter then
                local res, mode = {}, true
                for _, c in ipairs(chars) do
                    if mode then
                        if c == "-" then table.insert(res, "-")
                        elseif unicodeLower(c) == firstLower then table.insert(res, base)
                        else mode = false; table.insert(res, c) end
                    else
                        table.insert(res, c)
                    end
                end
                l.text = pre .. punct .. table.concat(res)
            elseif has_TT then
                local tail = table.concat(chars, "", 2)
                l.text = pre .. punct .. base .. "-" .. base .. tail
            end
        end
        subs[i] = l
    end
end

local function remplacer(subs, sel)
    if #sel < 1 then showMsg(L("err_no_selection")); return end
    local dlg = {
        { class="label",   x=0,  y=0,  width=40, height=1, label = L("lbl_original_text") },
        { class="textbox", x=0,  y=1,  width=40, height=10, name="original", text="" },
        { class="label",   x=41, y=0,  width=40, height=1, label = L("lbl_replacement_text") },
        { class="textbox", x=41, y=1,  width=40, height=10, name="replacement", text="" },
        { class="label",   x=0,  y=11, width=81, height=1, label = L("lbl_replacer_help") },
    }
    local ret, res = aegisub.dialog.display(dlg, { L("btn_replace_all"), L("btn_cancel") }, { ok = L("btn_replace_all"), close = L("btn_cancel") })
    if ret ~= L("btn_replace_all") or not ret then return end
    local origs = {}; for line in res.original:gmatch("[^\r\n]+") do table.insert(origs, line) end
    local reps  = {}; for line in res.replacement:gmatch("[^\r\n]+") do table.insert(reps, line) end
    if #origs ~= #reps or #origs == 0 then return end
    local map = {}; for i, o in ipairs(origs) do map[o] = reps[i] end
    local mod = 0
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isDialogue(line) then
            local text = normalizeString(line.text)
            local vis = text:gsub("{[^}]-}", "")
            local repl = map[vis]
            if repl then
                local tags = text:match("^({[^}]-})") or ""
                line.text = tags .. repl
                addEffectMarker(line, "[REPLACED]")
                subs[i] = line; mod = mod + 1
            end
        end
    end
    showMsg(string.format(L("msg_replacer_done"), mod))
end

local function shiftToFirst(subs, sel)
    if #sel < 2 then showMsg(L("err_shift_min_two")); return end
    local line1 = subs[sel[1]]
    local line2 = subs[sel[2]]
    if not isDialogue(line1) or not isDialogue(line2) then
        showMsg(L("err_shift_first_two"))
        return
    end
    local delta = line1.start_time - line2.start_time
    if delta == 0 then return end
    for k = 2, #sel do
        local idx = sel[k]
        local cur = subs[idx]
        if isDialogue(cur) then
            local new_start = cur.start_time + delta
            local new_end = cur.end_time + delta
            if new_start < 0 then
                local dur = cur.end_time - cur.start_time
                new_start = 0
                new_end = dur
                if new_end < 0 then new_end = 0 end
            end
            if new_end < new_start then new_end = new_start end
            cur.start_time = new_start
            cur.end_time = new_end
            subs[idx] = cur
        end
    end
end

local function styleSentinel(subs, sel)
    local seen, list = {}, ""
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class == "dialogue" and not seen[l.style] then
            seen[l.style] = true
            list = (list == "") and l.style or (list .. "\n" .. l.style)
        end
    end
    if list == "" then showMsg(L("err_no_styles")); return end
    local pressed, res = aegisub.dialog.display({
        { class = "label",   label = L("lbl_styles_filter_help"),
          x = 0, y = 0, width = 3, height = 2 },
        { class = "textbox", name = "keep", text = list, x = 0, y = 2, width = 3, height = 8 },
        { class = "label",   label = L("lbl_styles_filter_warn"),
          x = 0, y = 10, width = 3, height = 1 },
    }, { L("btn_filter"), L("btn_cancel") })
    if pressed ~= L("btn_filter") then return end
    local keep = {}
    for s in (res.keep or ""):gmatch("[^\r\n]+") do
        local clean = trimText(s); if clean ~= "" then keep[clean] = true end
    end
    if next(keep) == nil then
        local p2 = aegisub.dialog.display({
            { class = "label", label = L("lbl_styles_filter_empty"), x = 0, y = 0, width = 2, height = 2 },
        }, { L("btn_yes_delete_all"), L("btn_cancel") })
        if p2 ~= L("btn_yes_delete_all") then return end
    end
    local toDelete, kept = {}, 0
    local sorted = {}; for _, i in ipairs(sel) do table.insert(sorted, i) end
    table.sort(sorted, function(a, b) return a > b end)
    for _, i in ipairs(sorted) do
        local l = subs[i]
        if l.class == "dialogue" then
            if not keep[l.style] then table.insert(toDelete, i) else kept = kept + 1 end
        end
    end
    if #toDelete == 0 then
        showMsg(L("err_no_styles_delete"))
        return
    end
    local p3 = aegisub.dialog.display({
        { class = "label", label = string.format(L("lbl_styles_filter_sum"), kept, #toDelete),
          x = 0, y = 0, width = 2, height = 4 },
    }, { L("btn_yes_proceed"), L("btn_cancel") })
    if p3 ~= L("btn_yes_proceed") then return end
    for _, i in ipairs(toDelete) do subs.delete(i) end
    showMsg(string.format(L("msg_filter_done"), #toDelete, kept))
end

local UTILITY_SECTIONS = {
    {
        id    = "case",
        label_key = "lbl_section_case",
        items = {
            { name="",                                  func = nil },
            { name="Toggle \\an8",                      func = TextOperations.toggleAlignment,      includeVector = true },
            { name="Toggle Italics",                    func = TextOperations.toggleItalics },
            { name="Uppercase",                         func = TextOperations.toUppercase },
            { name="Lowercase",                         func = TextOperations.toLowercase },
            { name="Title Case",                        func = TextOperations.toTitleCase },
            { name="Sentence Case",                     func = TextOperations.toSentenceCase },
            { name="Capitalize First",                  func = TextOperations.capitalizeFirst },
            { name="Lowercase First",                   func = TextOperations.lowercaseFirst },
        },
    },
    {
        id    = "punct",
        label_key = "lbl_section_punct",
        items = {
            { name="" },
            { name="Toggle " .. INV_EXCLAMATION .. "!",                       func = TextOperations.toggleExclamation },
            { name="Toggle " .. INV_QUESTION .. "?",                          func = TextOperations.toggleQuestion },
            { name="Toggle " .. INV_EXCLAMATION .. INV_QUESTION .. "?!",      func = TextOperations.toggleBothSigns },
            { name="Normalize Ellipsis",                func = TextOperations.formatEllipsis },
            { name="Add Ellipsis",                      func = TextOperations.addEndingEllipsis },
            { name="Erase Leading Ellipsis",            func = TextOperations.eraseLeadingEllipsis },
            { name="Unify Quotes",                      func = TextOperations.normalizeQuotes },
            { name="Latin Quotes (" .. LEFT_GUILLEMET .. RIGHT_GUILLEMET .. ")", func = TextOperations.toLatinQuotes },
            { name="Normalize Dashes",                  func = TextOperations.normalizeDashes },
            { name="Trim Trailing Spaces",              func = TextOperations.trimTrailingSpaces },
            { name="Remove Duplicate Letters",          func = TextOperations.removeDuplicateLetters },
            { name="Add Stutter",                       func = SmartOperations.injectStutter },
            { name="Add Ah Prefix",                     func = SmartOperations.injectAhPrefix },
            { name="Stutter Manager",                   func = stutterManager },
        },
    },
    {
        id    = "tags",
        label_key = "lbl_section_tags",
        items = {
            { name="" },
            { name="Fold by Identifier",               func = MarkerOperations.randomFolds,         includeComments = true, includeVector = true, returnsSelection = true },
            { name="Extract Tags",                      func = TagOperations.extractTags,           includeVector = true },
            { name="Reinsert Tags",                     func = TagOperations.reinsertTags,          includeVector = true },
            { name="Remove Tags",                       func = TagOperations.removeAllTags },
            { name="Remove Comments",                   func = TagOperations.removeComments },
            { name="Actor Parser",                      func = TagOperations.parseActor,            returnsSelection = true },
            { name="Swap Comment",                      func = TagOperations.swapComment },
            { name="Delete Comment Lines",              func = SmartOperations.deleteCommentLines,  includeComments = true, includeVector = true, returnsSelection = true },
            { name="Comments to Top",                   func = SmartOperations.commentsToTop,       includeComments = true, includeVector = true },
            { name="Comments to Bottom",                func = SmartOperations.commentsToBottom,    includeComments = true, includeVector = true },
            { name="Effects to Top",                    func = TagOperations.effectsToTop,          includeComments = true, includeVector = true },
        },
    },
    {
        id    = "smart",
        label_key = "lbl_section_smart",
        items = {
            { name="" },
            { name="Bidirectional Snapping",            func = SmartOperations.bidirectionalSnapping, includeComments = true, includeVector = true },
            { name="Remove Honorifics",                 func = SmartOperations.removeHonorifics },
            { name="Caption Clarifier",                 func = SmartOperations.clarifyCaption },
            { name="Complete Sentences",                func = SmartOperations.completeSentences, returnsSelection = true },
            { name="Erase Blank Lines",                 func = SmartOperations.eraseBlankLines,     returnsSelection = true },
            { name="Frame Effect",     func = frameToEffect,                     includeVector = true },
            { name="Copy Fold",    func = foldCopy,                           includeComments = true, includeVector = true, returnsSelection = true },
        },
    },
    {
        id    = "split",
        label_key = "lbl_section_split",
        items = {
            { name="" },
            { name="Smart Break", func = TimingOperations.smartLineBreak },
            { name="Split by Sentence",                 func = TimingOperations.splitBySentence,    returnsSelection = true },
            { name="Split by Comma",                    func = TimingOperations.splitByComma,       returnsSelection = true },
            { name="Pivot \\N",                         func = TimingOperations.pivotLinebreak },
            { name="Remove \\N",                        func = TimingOperations.removeLinebreaks },
            { name="Join Lines",               func = TimingOperations.joinLines,          returnsSelection = true },
            { name="Join Same Text",                    func = TimingOperations.joinSameText,       returnsSelection = true },
            { name="Join Overlaps",                     func = TimingOperations.joinOverlaps,       returnsSelection = true },
            { name="Divide by \\N",                     func = TimingOperations.splitByLinebreak,   returnsSelection = true },
        },
    },
    {
        id    = "time",
        label_key = "lbl_section_time",
        items = {
            { name="" },
            { name="Copy Times",                        func = TimingOperations.copyTimes,          includeVector = true },
            { name="Time Picker",                       func = TimingOperations.timePicker,         returnsSelection = true, includeVector = true },
            { name="Sort by Length",                    func = TimingOperations.sortByLength },
            { name="Sort by CPS",                       func = TimingOperations.sortByCPS },
            { name="Sort Odd Even",                     func = TimingOperations.sortByEvenOdd,      includeComments = true, includeVector = true },
            { name="Count CPS",                         func = TimingOperations.showCPS },
            { name="Import Text",               func = TimingOperations.importText,         returnsSelection = true },
            { name="Kite Timing", func = kiteTiming,                       includeVector = true },
            { name="Shift First",  func = shiftToFirst,                      includeComments = true },
            { name="Start Snap Back",                   func = SmartOperations.startSnapBack, includeComments = true, includeVector = true },
            { name="Start Snap Forward",                func = SmartOperations.startSnapForward, includeComments = true, includeVector = true },
            { name="End Snap Back",                     func = SmartOperations.endSnapBack, includeComments = true, includeVector = true },
            { name="End Snap Forward",                  func = SmartOperations.endSnapForward, includeComments = true, includeVector = true },
            { name="Add Lead-In Left",                  func = TimingOperations.addLeadIn, includeVector = true },
            { name="Add Lead-In Right",                 func = TimingOperations.addLeadInRight, includeVector = true },
            { name="Add Lead-Out Left",                 func = TimingOperations.addLeadOutLeft, includeVector = true },
            { name="Add Lead-Out Right",                func = TimingOperations.addLeadOut, includeVector = true },
            { name="Chain Left",                        func = TimingOperations.chainLeft, includeVector = true },
            { name="Chain Right",                       func = TimingOperations.chainRight, includeVector = true },
        },
    },
    {
        id    = "kara",
        label_key = "lbl_section_kara",
        items = {
            { name="" },
            { name="Romaji Karaoker (Word → \\k)",      func = romajiKara },
        },
    },
}

local function findUtilityEntry(section_id, name)
    for _, sec in ipairs(UTILITY_SECTIONS) do
        if sec.id == section_id then
            for _, it in ipairs(sec.items) do
                if it.name == name then return it end
            end
        end
    end
    return nil
end

local function runUtilityEntry(entry, subs, sel)
    if not entry or not entry.func then return sel end
    local target
    if entry.allLines then        target = sel
    elseif entry.includeComments then target = collectDialogueSelection(subs, sel)
    elseif entry.includeVector   then target = collectEditableSelection(subs, sel)
    else                          target = collectEditableTextSelection(subs, sel) end
    local result = entry.func(subs, target)
    if entry.returnsSelection and type(result) == "table" then return result end
    return sel
end

function MarkerOperations.parseMpvQcTime(value)
    local h, m, s, ms = normalizeString(value):match("%[(%d+):(%d+):(%d+)%.(%d+)%]")
    if not h then h, m, s = normalizeString(value):match("%[(%d+):(%d+):(%d+)%]") end
    if not h then return nil end
    return clockToMs(h, m, s, ms)
end

function MarkerOperations.parseMpvQc(raw, tolerance)
    local out = {}
    tolerance = tolerance or 1000
    for line in normalizeString(raw):gmatch("[^\r\n]+") do
        line = trimText(line)
        local timeStr, kind, comment = line:match("(%[%d+:%d+:%d+%.?%d*%])%s*%[([^%]]+)%]%s*(.*)")
        if timeStr and comment and comment ~= "" then
            local time = MarkerOperations.parseMpvQcTime(timeStr)
            if time then
                out[#out+1] = {
                    time = time,
                    kind = trimText(kind),
                    comment = trimText(comment),
                    start_time = time - tolerance,
                    end_time = time + tolerance,
                }
            end
        end
    end
    return out
end

function MarkerOperations.splitQcComment(comment)
    local suggestions = {}
    local observation = normalizeString(comment):gsub("%b{}", function(block)
        local inner = trimText(block:sub(2, -2))
        if inner ~= "" then suggestions[#suggestions+1] = "{" .. inner .. "}" end
        return " "
    end)
    observation = trimText(observation:gsub("%s+", " "))
    return observation, suggestions
end

function MarkerOperations.addQcSuggestion(line, suggestion)
    local text = normalizeString(line.text)
    if suggestion ~= "" and not text:find(escapeLuaPattern(suggestion), 1) then
        line.text = trimText(text .. " " .. suggestion)
    end
end

local function mpvQcTool(subs, sel)
    local state = { tolerance = "1000", raw = "" }
    while true do
        local dlg = {
            { class="label", label=L("lbl_mpvqc_title"), x=0, y=0, width=4, height=1 },
            { class="label", label=L("lbl_mpvqc_tolerance"), x=0, y=1, width=1, height=1 },
            { class="edit", name="tolerance", value=state.tolerance, x=1, y=1, width=1 },
            { class="label", label=L("lbl_mpvqc_paste"), x=0, y=2, width=4, height=1 },
            { class="textbox", name="raw", text=state.raw, x=0, y=3, width=65, height=14 },
        }
        local button, result = aegisub.dialog.display(dlg, { L("btn_apply"), L("btn_cancel") })
        if button ~= L("btn_apply") then return end
        state = result
        local tolerance = tonumber(result.tolerance)
        if not tolerance or tolerance < 0 then
            showMsg(L("err_tolerance_positive"))
        elseif trimText(result.raw) == "" then
            showMsg(L("err_paste_mpvqc"))
        else
            local comments = MarkerOperations.parseMpvQc(result.raw, tolerance)
            if #comments == 0 then
                showMsg(L("err_no_mpvqc_comments"))
            else
                local modified = 0
                for _, i in ipairs(sel) do
                    local line = subs[i]
                    if isDialogue(line) and validateDuration(line) then
                        local changed = false
                        for _, qc in ipairs(comments) do
                            if timeInt(line.start_time, line.end_time, qc.start_time, qc.end_time) > 0 then
                                local observation, suggestions = MarkerOperations.splitQcComment(qc.comment)
                                if observation == "" then observation = qc.kind ~= "" and qc.kind or "Observation" end
                                addEffectMarker(line, "[QC: " .. observation .. "]")
                                for _, suggestion in ipairs(suggestions) do MarkerOperations.addQcSuggestion(line, suggestion) end
                                changed = true
                            end
                        end
                        if changed then subs[i] = line; modified = modified + 1 end
                    end
                end
                showMsg(string.format(L("msg_mpvqc_done"), modified))
                return
            end
        end
    end
end

local RemoverOps = {}

function RemoverOps.anySelected(opts)
    for k, v in pairs(opts or {}) do
        if type(k) == "string" and k:match("^rem_") and v == true then return true end
    end
    return false
end

function RemoverOps.removeVisibleSet(value, set)
    local out, changed = {}, false
    for _, c in ipairs(splitUtf8Chars(normalizeString(value))) do
        if set[c] then changed = true else out[#out+1] = c end
    end
    return table.concat(out), changed
end

function RemoverOps.removeStutterText(value)
    local chars, out, i = splitUtf8Chars(normalizeString(value)), {}, 1
    while i <= #chars do
        if i + 2 <= #chars and isLetter(chars[i]) and chars[i + 1] == "-"
           and isLetter(chars[i + 2]) and unicodeLower(chars[i]) == unicodeLower(chars[i + 2]) then
            i = i + 2
        else
            out[#out+1] = chars[i]
            i = i + 1
        end
    end
    return table.concat(out)
end

function RemoverOps.removeDuplicateLettersText(value)
    local chars = splitUtf8Chars(normalizeString(value))
    local out, i = {}, 1
    while i <= #chars do
        local cur = chars[i]
        if isLetter(cur) then
            local j = i + 1
            while j <= #chars and chars[j] == cur do j = j + 1 end
            if j - i >= 3 then out[#out+1] = cur
            else for k = i, j - 1 do out[#out+1] = chars[k] end end
            i = j
        else
            out[#out+1] = cur
            i = i + 1
        end
    end
    return table.concat(out)
end

function RemoverOps.removeLeadingEllipsisText(value)
    local prefix, rest = "", trimText(normalizeString(value))
    while startsWith(rest, INV_QUESTION) or startsWith(rest, INV_EXCLAMATION) do
        prefix = prefix .. unicodeSub(rest, 1, 1)
        rest = trimText(unicodeSub(rest, 2))
    end
    local stripping = true
    while stripping do
        stripping = false
        local r = rest:gsub("^%.%.%.+%s*", "")
        if r ~= rest then rest = r; stripping = true end
        if startsWith(rest, HORIZONTAL_ELLIPSIS) or startsWith(rest, TWO_DOT_LEADER) then
            rest = trimText(unicodeSub(rest, 2)); stripping = true
        end
    end
    return prefix .. rest
end

function RemoverOps.cleanTextSection(value, opts)
    local t = normalizeString(value)
    if opts.rem_n then t = t:gsub("\\[Nn]", " ") end
    if opts.rem_h then t = t:gsub("\\h", " "):gsub(NBSP, " ") end
    if opts.rem_combo then
        t = RemoverOps.removeVisibleSet(t, {
            [INV_EXCLAMATION]=true, ["!"]=true, [FULLWIDTH_EXCLAMATION]=true,
            [INV_QUESTION]=true, ["?"]=true, [FULLWIDTH_QUESTION]=true,
        })
    else
        if opts.rem_excl then
            t = RemoverOps.removeVisibleSet(t, {
                [INV_EXCLAMATION]=true, ["!"]=true, [FULLWIDTH_EXCLAMATION]=true,
            })
        end
        if opts.rem_quest then
            t = RemoverOps.removeVisibleSet(t, {
                [INV_QUESTION]=true, ["?"]=true, [FULLWIDTH_QUESTION]=true,
            })
        end
    end
    if opts.rem_all_commas then t = RemoverOps.removeVisibleSet(t, { [","]=true, [CJK_COMMA]=true, [FULLWIDTH_COMMA]=true }) end
    if opts.rem_quotes then
        t = RemoverOps.removeVisibleSet(t, {
            ["\""]=true, [LEFT_DOUBLE_QUOTE]=true, [RIGHT_DOUBLE_QUOTE]=true,
            [DOUBLE_LOW_QUOTE]=true, [DOUBLE_HIGH_REVERSED_QUOTE]=true,
            [string.char(0xEF,0xBC,0x82)]=true,
            [LEFT_GUILLEMET]=true, [RIGHT_GUILLEMET]=true,
            [string.char(0xE3,0x80,0x8C)]=true, [string.char(0xE3,0x80,0x8D)]=true,
            [string.char(0xE3,0x80,0x8E)]=true, [string.char(0xE3,0x80,0x8F)]=true,
        })
    end
    if opts.rem_apostrophes then
        t = RemoverOps.removeVisibleSet(t, {
            ["'"]=true, [LEFT_SINGLE_QUOTE]=true, [RIGHT_SINGLE_QUOTE]=true,
            [SINGLE_LOW_QUOTE]=true, [SINGLE_HIGH_REVERSED_QUOTE]=true,
            [string.char(0xEF,0xBC,0x87)]=true,
            [LEFT_SINGLE_GUILLEMET]=true, [RIGHT_SINGLE_GUILLEMET]=true,
        })
    end
    if opts.rem_stutter then t = RemoverOps.removeStutterText(t) end
    if opts.rem_dup_letters then t = RemoverOps.removeDuplicateLettersText(t) end
    if opts.rem_leading_ellipsis then t = RemoverOps.removeLeadingEllipsisText(t) end
    if opts.rem_ellipsis then
        t = t:gsub(HORIZONTAL_ELLIPSIS, ""):gsub(TWO_DOT_LEADER, ""):gsub("%.%.%.+", "")
    end
    if opts.rem_n or opts.rem_h or opts.rem_double_space then t = t:gsub("[ \t][ \t]+", " ") end
    return t
end

function RemoverOps.trimVisibleEdges(text)
    local leading, body = splitLeadingTagBlocks(text)
    local core, trailing = splitTrailingTagBlocks(body)
    core = core:gsub("^[ \t]+", ""):gsub("[ \t]+$", "")
    return leading .. core .. trailing
end

function RemoverOps.removeOneFinalComma(text)
    local tokens, cursor = {}, 1
    text = normalizeString(text)
    while cursor <= #text do
        local s, e = text:find("%b{}", cursor)
        if not s then
            for _, c in ipairs(splitUtf8Chars(text:sub(cursor))) do tokens[#tokens+1] = { c, true } end
            break
        end
        if s > cursor then
            for _, c in ipairs(splitUtf8Chars(text:sub(cursor, s - 1))) do tokens[#tokens+1] = { c, true } end
        end
        tokens[#tokens+1] = { text:sub(s, e), false }
        cursor = e + 1
    end
    for i = #tokens, 1, -1 do
        if tokens[i][2] then
            local c = tokens[i][1]
            if isWhitespaceChar(c) or CLOSING_PUNCTUATION[c] then
            elseif c == "," or c == CJK_COMMA or c == FULLWIDTH_COMMA then
                table.remove(tokens, i)
                local out = {}
                for _, token in ipairs(tokens) do out[#out+1] = token[1] end
                return table.concat(out), true
            else
                return text, false
            end
        end
    end
    return text, false
end

function RemoverOps.removeFinalComma(text)
    local current = normalizeString(text)
    while true do
        local nextText, removed = RemoverOps.removeOneFinalComma(current)
        if not removed then return current end
        current = nextText
    end
end

function RemoverOps.cleanLine(line, opts)
    local before = normalizeString(line.text)
    if opts.rem_inline_comments then line.text = stripComments(line.text) end
    if opts.rem_n then line.text = normalizeString(line.text):gsub("\\[Nn]", " ") end
    if opts.rem_h then line.text = normalizeString(line.text):gsub("\\h", " ") end
    if opts.rem_italic_tags then line.text = removeOverridePattern(line.text, "\\i[01]") end
    if opts.rem_q_tags then line.text = removeOverridePattern(line.text, "\\q%d") end
    if opts.rem_an8 then line.text = removeOverridePattern(line.text, "\\an8") end
    mutateTextSections(line, function(value) return RemoverOps.cleanTextSection(value, opts) end)
    if opts.rem_final_commas then line.text = RemoverOps.removeFinalComma(line.text) end
    if opts.rem_edge_space then line.text = RemoverOps.trimVisibleEdges(line.text) end
    return before ~= normalizeString(line.text)
end

function RemoverOps.gui(subs, sel)
    local state = {}
    local dlg = {
        { class="label", label=L("lbl_remover_title"), x=0, y=0, width=6, height=1 },
        { class="label", label=L("lbl_remover_text"), x=0, y=1, width=3, height=1 },
        { class="checkbox", name="rem_n", label=L("chk_rem_n"), value=false, x=0, y=2, width=2, height=1 },
        { class="checkbox", name="rem_h", label=L("chk_rem_h"), value=false, x=2, y=2, width=2, height=1 },
        { class="checkbox", name="rem_double_space", label=L("chk_rem_double_space"), value=false, x=4, y=2, width=2, height=1 },
        { class="checkbox", name="rem_edge_space", label=L("chk_rem_edge_space"), value=false, x=0, y=3, width=2, height=1 },
        { class="checkbox", name="rem_excl", label=L("chk_rem_excl"), value=false, x=2, y=3, width=2, height=1 },
        { class="checkbox", name="rem_quest", label=L("chk_rem_quest"), value=false, x=4, y=3, width=2, height=1 },
        { class="checkbox", name="rem_combo", label=L("chk_rem_combo"), value=false, x=0, y=4, width=2, height=1 },
        { class="checkbox", name="rem_final_commas", label=L("chk_rem_final_commas"), value=false, x=2, y=4, width=2, height=1 },
        { class="checkbox", name="rem_all_commas", label=L("chk_rem_all_commas"), value=false, x=4, y=4, width=2, height=1 },
        { class="checkbox", name="rem_quotes", label=L("chk_rem_quotes"), value=false, x=0, y=5, width=2, height=1 },
        { class="checkbox", name="rem_apostrophes", label=L("chk_rem_apostrophes"), value=false, x=2, y=5, width=2, height=1 },
        { class="checkbox", name="rem_stutter", label=L("chk_rem_stutter"), value=false, x=4, y=5, width=2, height=1 },
        { class="checkbox", name="rem_dup_letters", label=L("chk_rem_dup_letters"), value=false, x=0, y=6, width=2, height=1 },
        { class="checkbox", name="rem_leading_ellipsis", label=L("chk_rem_leading_ellipsis"), value=false, x=2, y=6, width=2, height=1 },
        { class="checkbox", name="rem_ellipsis", label=L("chk_rem_ellipsis"), value=false, x=4, y=6, width=2, height=1 },
        { class="label", label=L("lbl_remover_tags"), x=0, y=7, width=3, height=1 },
        { class="checkbox", name="rem_italic_tags", label=L("chk_rem_italic_tags"), value=false, x=0, y=8, width=2, height=1 },
        { class="checkbox", name="rem_q_tags", label=L("chk_rem_q_tags"), value=false, x=2, y=8, width=2, height=1 },
        { class="checkbox", name="rem_an8", label=L("chk_rem_an8"), value=false, x=4, y=8, width=2, height=1 },
        { class="label", label=L("lbl_remover_comments"), x=0, y=9, width=3, height=1 },
        { class="checkbox", name="rem_comment_lines", label=L("chk_rem_comment_lines"), value=false, x=0, y=10, width=3, height=1 },
        { class="checkbox", name="rem_inline_comments", label=L("chk_rem_inline_comments"), value=false, x=3, y=10, width=3, height=1 },
    }
    local button, result = aegisub.dialog.display(dlg, { L("btn_apply"), L("btn_cancel") })
    if button ~= L("btn_apply") then return false end
    state = result
    if not RemoverOps.anySelected(state) then showMsg(L("err_remover_none")); return false end
    local modified, deleted, deleteSet = 0, 0, {}
    for _, i in ipairs(sel) do
        local line = subs[i]
        if isDialogue(line) and not line.comment then
            if RemoverOps.cleanLine(line, state) then
                subs[i] = line
                modified = modified + 1
            end
        end
    end
    if state.rem_comment_lines then
        for _, i in ipairs(sel) do
            local line = subs[i]
            if isDialogue(line) and line.comment then deleteSet[i] = true end
        end
        local sorted = {}
        for i in pairs(deleteSet) do sorted[#sorted+1] = i end
        table.sort(sorted, function(a, b) return a > b end)
        for _, i in ipairs(sorted) do subs.delete(i); deleted = deleted + 1 end
    end
    showMsg(string.format(L("msg_remover_done"), modified, deleted))
    return true
end

local SUITE_TOOLS = {
    { name = "" },
    { name = "AE Export", func = aeKeyframeExport },
    { name = "Text Replacer",       func = remplacer },
    { name = "mpv QC", func = mpvQcTool },
    { name = "Remover Assistant", func = RemoverOps.gui },
    { name = "Style Filter", func = styleSentinel },
}
local SUITE_TOOL_NAMES = {}
for _, t in ipairs(SUITE_TOOLS) do SUITE_TOOL_NAMES[#SUITE_TOOL_NAMES+1] = t.name end

local function findSuiteTool(name)
    for _, t in ipairs(SUITE_TOOLS) do if t.name == name then return t end end
end

local function rowMasterGui(subs, sel)
    if not sel or #sel == 0 then showMsg(L("err_no_selection")); return end

    resolveConfig()

    local state = {
        tm = "All Selected", tv = "",

        preset = "", kf_mode = "", kf_dir = "", single_marker = "",
        short_ms = 0, long_ms = 0, twin_kf_ms = 0, miss_kf_ms = 0,
        overtime_ms = 0, min_cps = 0, max_cps = 0,
        gap_ms = 0, large_gap_ms = 0, max_width = 0,
        kf_seal = false, gap_mark_continuous = false, gap_ignore_kf = false, clear_old = true,
        sec_case = "", sec_punct = "", sec_tags = "", sec_smart = "", sec_split = "", sec_time = "", sec_kara = "",

        mr = "", mm = "Import Effects", mc = false, same_layers = false,
        ct = "",
    }

    while true do
        local ui = {
            tm = UI.options({ "All Selected","By Style","By Actor","By Effect","By Layer" }, state.tm),
            preset = UI.options({ "","Ends Only","Start Only","Full Audit","Duration","CPS","Short Gaps","Large Gaps","Both Gaps","Overtime" }, state.preset),
            kf_mode = UI.options({ "","End Only","Start Only","Both" }, state.kf_mode),
            kf_dir = UI.options({ "","KF Back","KF Forward","KF Both" }, state.kf_dir),
            sec_case = UI.utilityOptions(UTILITY_SECTIONS[1], state.sec_case),
            sec_punct = UI.utilityOptions(UTILITY_SECTIONS[2], state.sec_punct),
            sec_tags = UI.utilityOptions(UTILITY_SECTIONS[3], state.sec_tags),
            sec_smart = UI.utilityOptions(UTILITY_SECTIONS[4], state.sec_smart),
            sec_split = UI.utilityOptions(UTILITY_SECTIONS[5], state.sec_split),
            sec_time = UI.utilityOptions(UTILITY_SECTIONS[6], state.sec_time),
            sec_kara = UI.utilityOptions(UTILITY_SECTIONS[7], state.sec_kara),
            single_marker = UI.options(SINGLE_MARKER_ITEMS, state.single_marker),
            mm = UI.options({ "Import Effects","Import Text","Import Actor","Import Tags","Song Sync" }, state.mm),
            ct = UI.options(SUITE_TOOL_NAMES, state.ct),
        }
        local d = {
            { class="label",    label=L("lbl_apply_to"),                                              x=0,  y=0, width=4, height=1 },
            { class="dropdown", name="tm", items=ui.tm.items, value=ui.tm.value, x=4, y=0, width=8, height=1 },
            { class="label",    label=L("lbl_filter"),                                                x=12, y=0, width=4, height=1 },
            { class="edit",     name="tv", value=state.tv,                                            x=16, y=0, width=8, height=1 },

            { class="label", label=L("title_markers"),   x=0,  y=1, width=11, height=1 },
            { class="label", label="│",                   x=11, y=1, width=1,  height=1 },
            { class="label", label=L("title_utilities"), x=12, y=1, width=12, height=1 },

            { class="label",    label=L("lbl_preset"),                                                x=0, y=2, width=3, height=1 },
            { class="dropdown", name="preset", items=ui.preset.items, value=ui.preset.value, x=3, y=2, width=8, height=1 },
            { class="label",    label="│",                                                            x=11, y=2, width=1, height=1 },

            { class="label",    label=L("lbl_short_ms"),                                              x=0, y=3, width=3, height=1 },
            { class="intedit",  name="short_ms", value=state.short_ms, min=0,                         x=3, y=3, width=3, height=1 },
            { class="label",    label=L("lbl_long_ms"),                                               x=6, y=3, width=3, height=1 },
            { class="intedit",  name="long_ms",  value=state.long_ms,  min=0,                         x=9, y=3, width=2, height=1 },
            { class="label",    label="│",                                                            x=11, y=3, width=1, height=1 },

            { class="label",    label=L("lbl_kf_mode"),                                               x=0, y=4, width=2, height=1 },
            { class="dropdown", name="kf_mode", items=ui.kf_mode.items, value=ui.kf_mode.value, x=2, y=4, width=4, height=1 },
            { class="label",    label=L("lbl_kf_dir"),                                                x=6, y=4, width=2, height=1 },
            { class="dropdown", name="kf_dir", items=ui.kf_dir.items, value=ui.kf_dir.value, x=8, y=4, width=3, height=1 },
            { class="label",    label="│",                                                            x=11, y=4, width=1, height=1 },

            { class="label",    label=L("lbl_twin_ms"),                                               x=0, y=5, width=3, height=1 },
            { class="intedit",  name="twin_kf_ms", value=state.twin_kf_ms, min=0,                     x=3, y=5, width=3, height=1 },
            { class="label",    label=L("lbl_miss_ms"),                                               x=6, y=5, width=3, height=1 },
            { class="intedit",  name="miss_kf_ms", value=state.miss_kf_ms, min=0,                     x=9, y=5, width=2, height=1 },
            { class="label",    label="│",                                                            x=11, y=5, width=1, height=1 },

            { class="checkbox", name="kf_seal", label=L("chk_kf_seal"), value=state.kf_seal,          x=0, y=6, width=5, height=1 },
            { class="label",    label=L("lbl_overtime"),                                              x=5, y=6, width=3, height=1 },
            { class="intedit",  name="overtime_ms", value=state.overtime_ms, min=0,                   x=8, y=6, width=3, height=1 },
            { class="label",    label="│",                                                            x=11, y=6, width=1, height=1 },

            { class="label",    label=L("lbl_section_cps_gap"),                                       x=0, y=7, width=11, height=1 },
            { class="label",    label="│",                                                            x=11, y=7, width=1, height=1 },

            { class="label",    label=L("lbl_min_cps"),                                               x=0, y=8, width=3, height=1 },
            { class="intedit",  name="min_cps", value=state.min_cps, min=0,                           x=3, y=8, width=3, height=1 },
            { class="label",    label=L("lbl_max_cps"),                                               x=6, y=8, width=3, height=1 },
            { class="intedit",  name="max_cps", value=state.max_cps, min=0,                           x=9, y=8, width=2, height=1 },
            { class="label",    label="│",                                                            x=11, y=8, width=1, height=1 },

            { class="label",    label=L("lbl_gap_ms"),                                                x=0, y=9, width=3, height=1 },
            { class="intedit",  name="gap_ms", value=state.gap_ms, min=0,                             x=3, y=9, width=3, height=1 },
            { class="label",    label=L("lbl_max_width"),                                             x=6, y=9, width=3, height=1 },
            { class="intedit",  name="max_width", value=state.max_width, min=0,                       x=9, y=9, width=2, height=1 },
            { class="label",    label="│",                                                            x=11, y=9, width=1, height=1 },

            { class="label",    label=L("lbl_large_gap"),                                             x=0, y=10, width=3, height=1 },
            { class="intedit",  name="large_gap_ms", value=state.large_gap_ms, min=0,                 x=3, y=10, width=3, height=1 },
            { class="checkbox", name="gap_mark_continuous", label=L("chk_gap_continuous"),            value=state.gap_mark_continuous, x=6, y=10, width=5, height=1 },
            { class="label",    label="│",                                                            x=11, y=10, width=1, height=1 },

            { class="checkbox", name="gap_ignore_kf",       label=L("chk_gap_ignore_kf"),             value=state.gap_ignore_kf,       x=0, y=11, width=5, height=1 },
            { class="checkbox", name="clear_old", label=L("chk_clear_old"), value=state.clear_old,    x=5, y=11, width=6, height=1 },
            { class="label",    label="│",                                                            x=11, y=11, width=1, height=1 },

            { class="label",    label=L("lbl_section_case"),    x=12, y=2, width=4, height=1 },
            { class="dropdown", name="sec_case",  items=ui.sec_case.items, value=ui.sec_case.value,  x=16, y=2, width=8, height=1 },

            { class="label",    label=L("lbl_section_punct"),   x=12, y=3, width=4, height=1 },
            { class="dropdown", name="sec_punct", items=ui.sec_punct.items, value=ui.sec_punct.value, x=16, y=3, width=8, height=1 },

            { class="label",    label=L("lbl_section_tags"),    x=12, y=4, width=4, height=1 },
            { class="dropdown", name="sec_tags",  items=ui.sec_tags.items, value=ui.sec_tags.value,  x=16, y=4, width=8, height=1 },

            { class="label",    label=L("lbl_section_smart"),   x=12, y=5, width=4, height=1 },
            { class="dropdown", name="sec_smart", items=ui.sec_smart.items, value=ui.sec_smart.value, x=16, y=5, width=8, height=1 },

            { class="label",    label=L("lbl_section_split"),   x=12, y=6, width=4, height=1 },
            { class="dropdown", name="sec_split", items=ui.sec_split.items, value=ui.sec_split.value, x=16, y=6, width=8, height=1 },

            { class="label",    label=L("lbl_section_time"),    x=12, y=7, width=4, height=1 },
            { class="dropdown", name="sec_time",  items=ui.sec_time.items, value=ui.sec_time.value,  x=16, y=7, width=8, height=1 },

            { class="label",    label=L("lbl_section_kara"),    x=12, y=8, width=4, height=1 },
            { class="dropdown", name="sec_kara",  items=ui.sec_kara.items, value=ui.sec_kara.value,  x=16, y=8, width=8, height=1 },

            { class="label",    label=L("lbl_marker_dd"),       x=12, y=9, width=4, height=1 },
            { class="dropdown", name="single_marker", items=ui.single_marker.items, value=ui.single_marker.value, x=16, y=9, width=8, height=1 },

            { class="label",    label=string.format(L("lbl_selection"), #sel),        x=12, y=10, width=12, height=1 },
            { class="label",    label=L("lbl_dropdown_skip_hint"),                    x=12, y=11, width=12, height=1 },

            { class="label",    label=L("title_data_import"),                                       x=0, y=12, width=24, height=1 },
            { class="label",    label=L("lbl_data_import_mode"),                                    x=0, y=13, width=4, height=1 },
            { class="dropdown", name="mm", items=ui.mm.items, value=ui.mm.value, x=4, y=13, width=8, height=1 },
            { class="checkbox", name="mc", label=L("chk_data_import_cmt"), value=state.mc,           x=12, y=13, width=7, height=1 },
            { class="checkbox", name="same_layers", label=L("chk_data_import_same_layers"), value=state.same_layers,
                                                                                                  x=19, y=13, width=5, height=1 },
            { class="textbox",  name="mr", text=state.mr,                                         x=0, y=14, width=24, height=4 },
            { class="label",    label=L("chk_data_import_skip") .. "  ·  " .. L("data_import_paste_hint"),
                                                                                                  x=0, y=18, width=24, height=1 },

            { class="label",    label=L("title_tools"),                                           x=0, y=19, width=24, height=1 },
            { class="label",    label=L("lbl_suite_tool"),                                        x=0, y=20, width=4, height=1 },
            { class="dropdown", name="ct", items=ui.ct.items, value=ui.ct.value,              x=4, y=20, width=20, height=1 },
        }

        local buttons = { L("btn_execute"), L("btn_cue"), L("btn_extract_kf"), L("btn_scream"), L("btn_config"), L("btn_help"), L("btn_cancel") }
        local b, r = aegisub.dialog.display(d, buttons)
        if b == L("btn_cancel") or not b then return end

        r.tm = UI.from(ui.tm, r.tm)
        r.preset = UI.from(ui.preset, r.preset)
        r.kf_mode = UI.from(ui.kf_mode, r.kf_mode)
        r.kf_dir = UI.from(ui.kf_dir, r.kf_dir)
        r.sec_case = UI.from(ui.sec_case, r.sec_case)
        r.sec_punct = UI.from(ui.sec_punct, r.sec_punct)
        r.sec_tags = UI.from(ui.sec_tags, r.sec_tags)
        r.sec_smart = UI.from(ui.sec_smart, r.sec_smart)
        r.sec_split = UI.from(ui.sec_split, r.sec_split)
        r.sec_time = UI.from(ui.sec_time, r.sec_time)
        r.sec_kara = UI.from(ui.sec_kara, r.sec_kara)
        r.single_marker = UI.from(ui.single_marker, r.single_marker)
        r.mm = UI.from(ui.mm, r.mm)
        r.ct = UI.from(ui.ct, r.ct)

        for k, v in pairs(r) do state[k] = v end

        if b == L("btn_cue") then
            local tsel = getTargetedSelection(subs, sel, { mode = r.tm, value = r.tv })
            if #tsel == 0 then
                showMsg(L("err_filter_zero"))
            else
                cueTimer(subs, tsel)
                return sel
            end
        elseif b == L("btn_extract_kf") then
            runScxvid()
            return sel
        elseif b == L("btn_scream") then
            if screamDetector(subs, sel) then return sel end
        elseif b == L("btn_config") then
            showConfigDialog()
        elseif b == L("btn_help") then
            showHelp()
        elseif b == L("btn_execute") then
            local twin_val = tonumber(r.twin_kf_ms)
            if not twin_val or twin_val < 0 then showMsg(L("err_invalid_twin")) else
                local miss_val = tonumber(r.miss_kf_ms)
                if not miss_val or miss_val < 0 then showMsg(L("err_invalid_miss")) else
                    local ov_val = tonumber(r.overtime_ms)
                    if not ov_val or ov_val < 0 then showMsg(L("err_invalid_ov")) else
                        local tool_active = (r.ct and r.ct ~= "")
                        local section_active = (r.sec_case ~= "" or r.sec_punct ~= "" or r.sec_tags ~= ""
                            or r.sec_smart ~= "" or r.sec_split ~= "" or r.sec_time ~= "" or r.sec_kara ~= "")
                        local import_active = (r.mr and r.mr:gsub("%s", "") ~= "")
                        local audit_active = (r.preset ~= "" or r.single_marker ~= "" or r.kf_seal
                            or twin_val > 0 or miss_val > 0 or ov_val > 0
                            or (tonumber(r.short_ms) or 0) > 0 or (tonumber(r.long_ms) or 0) > 0
                            or (tonumber(r.min_cps) or 0) > 0 or (tonumber(r.max_cps) or 0) > 0
                            or (tonumber(r.gap_ms) or 0) > 0 or (tonumber(r.large_gap_ms) or 0) > 0
                            or (tonumber(r.max_width) or 0) > 0)

                        if not (tool_active or section_active or import_active or audit_active) then return end

                        local tsel = getTargetedSelection(subs, sel, { mode = r.tm, value = r.tv })
                        if #tsel == 0 then
                            showMsg(L("err_filter_zero"))
                        else
                            aegisub.progress.task("Chrono Suite - Executing...")

                            if tool_active then
                                local tool = findSuiteTool(r.ct)
                                if tool and tool.func then
                                    local result = tool.func(subs, tsel)
                                    if tool.returnsSelection and type(result) == "table" then
                                        aegisub.set_undo_point("Chrono Suite - " .. r.ct)
                                        return result
                                    end
                                end
                                aegisub.set_undo_point("Chrono Suite - " .. r.ct)
                                return
                            end

                            local current_sel = tsel
                            local returns_selection = false
                            if section_active then
                                local section_dd = {
                                    { id = "case",  pick = r.sec_case  },
                                    { id = "punct", pick = r.sec_punct },
                                    { id = "tags",  pick = r.sec_tags  },
                                    { id = "smart", pick = r.sec_smart },
                                    { id = "split", pick = r.sec_split },
                                    { id = "time",  pick = r.sec_time  },
                                    { id = "kara",  pick = r.sec_kara  },
                                }
                                for _, s in ipairs(section_dd) do
                                    if s.pick and s.pick ~= "" then
                                        local entry = findUtilityEntry(s.id, s.pick)
                                        if entry and entry.returnsSelection then returns_selection = true end
                                        current_sel = runUtilityEntry(entry, subs, current_sel)
                                    end
                                end
                            end

                            if import_active then
                                if     r.mm == "Import Effects" then antEffects(subs, current_sel, r.mr, r.same_layers)
                                elseif r.mm == "Import Text"   then antLines(subs,   current_sel, r.mr, r.mc, r.same_layers)
                                elseif r.mm == "Import Actor"   then antActor(subs,   current_sel, r.mr, r.same_layers)
                                elseif r.mm == "Import Tags"    then DataImportOps.importTags(subs, current_sel, r.mr, r.same_layers)
                                elseif r.mm == "Song Sync"   then antSongs(subs,   current_sel, r.mr) end
                            end

                            if audit_active then
                                local audit_cfg = {
                                    short_ms = tonumber(r.short_ms) or 0,
                                    long_ms = tonumber(r.long_ms) or 0,
                                    twin_kf_ms = twin_val, miss_kf_ms = miss_val, overtime_ms = ov_val,
                                    min_cps = tonumber(r.min_cps) or 0,
                                    max_cps = tonumber(r.max_cps) or 0,
                                    gap_ms = tonumber(r.gap_ms) or 0,
                                    large_gap_ms = tonumber(r.large_gap_ms) or 0,
                                    max_width = tonumber(r.max_width) or 0,
                                    kf_seal = r.kf_seal, kf_mode = r.kf_mode, kf_dir = r.kf_dir,
                                    gap_mark_continuous = r.gap_mark_continuous,
                                    gap_ignore_kf = r.gap_ignore_kf,
                                    clear_old = r.clear_old,
                                    single_marker = r.single_marker,
                                    check_uppercase=false, check_3liner=false, check_missing_punct=false,
                                    check_punct_balance=false, check_orphan_word=false, check_orphan_tag=false,
                                    check_overlap=false, check_unstyled=false, check_double_italics=false,
                                    check_parentheses=false, check_name_prefix=false, check_sentences=false,
                                    check_needs_split=(tonumber(r.max_width) or 0) > 0, check_empty=false,
                                    check_has_n=false, check_has_pos=false, check_has_clip=false, check_has_fad=false,
                                    check_has_t=false, check_has_k=false, check_has_comment=false, check_has_num=false,
                                    check_has_cjk=false, check_full_italic=false,
                                    check_dbl_space=false, check_edge_space=false,
                                }
                                if r.preset and r.preset ~= "" then
                                    audit_cfg = applyPreset(audit_cfg, r.preset)
                                    if r.kf_dir and r.kf_dir ~= "" then audit_cfg.kf_dir = r.kf_dir end
                                end
                                auditLines(subs, current_sel, audit_cfg)
                            end

                            aegisub.set_undo_point("Chrono Suite - Executed")
                            if returns_selection then return current_sel end
                            return
                        end
                    end
                end
            end
        end
    end
end

local function macroPath(name)
    if name == "" then return script_name end
    return script_name .. "/" .. name
end

local HotkeyMenu = { root = ": Kite Hotkeys :", script = script_name, migrations = {} }

function HotkeyMenu.path(name)
    return HotkeyMenu.root .. "/" .. HotkeyMenu.script .. "/" .. name
end

function HotkeyMenu.addMigration(oldMacroName, newMacroName)
    local function commandPath(macroName)
        return "automation/lua/" .. script_namespace .. "/" .. macroName
    end
    local function escape(value)
        return normalizeString(value):gsub("\\", "\\\\"):gsub('"', '\\"')
    end
    HotkeyMenu.migrations[escape(commandPath(oldMacroName))] = escape(commandPath(newMacroName))
end

function HotkeyMenu.migrate()
    if next(HotkeyMenu.migrations) == nil or not (aegisub and aegisub.decode_path) then return end
    local okPath, path = pcall(aegisub.decode_path, "?user/hotkey.json")
    if not okPath or not path or path == "" then return end
    local f = io.open(path, "r")
    if not f then return end
    local content = f:read("*a"); f:close()
    if not content or content == "" then return end

    local lines = {}
    for line in (content:gsub("\r\n", "\n"):gsub("\r", "\n") .. "\n"):gmatch("(.-)\n") do
        lines[#lines+1] = line
    end

    local contexts, i = {}, 1
    while i <= #lines do
        local ctxName = lines[i]:match('^%s*"(.-)"%s*:%s*{%s*,?%s*$')
        if ctxName then
            local ctx = { name = ctxName, entries = {} }
            i = i + 1
            while i <= #lines and not lines[i]:match("^%s*}%s*,?%s*$") do
                local key = lines[i]:match('^%s*"(.-)"%s*:%s*%[%s*$')
                if key then
                    local entry = { key = key, values = {} }
                    i = i + 1
                    while i <= #lines and not lines[i]:match("^%s*%]%s*,?%s*$") do
                        local value = lines[i]:match('^%s*"(.-)"%s*,?%s*$')
                        if value then entry.values[#entry.values+1] = value end
                        i = i + 1
                    end
                    ctx.entries[#ctx.entries+1] = entry
                end
                i = i + 1
            end
            contexts[#contexts+1] = ctx
        end
        i = i + 1
    end
    if #contexts == 0 then return end

    local changed = false
    for _, ctx in ipairs(contexts) do
        local merged, out = {}, {}
        for _, entry in ipairs(ctx.entries) do
            local target = HotkeyMenu.migrations[entry.key] or entry.key
            if target ~= entry.key then changed = true end
            local existing = merged[target]
            if existing then
                local seen = {}
                for _, value in ipairs(existing.values) do seen[value] = true end
                for _, value in ipairs(entry.values) do
                    if not seen[value] then
                        existing.values[#existing.values+1] = value
                        seen[value] = true
                    end
                end
                changed = true
            else
                entry.key = target
                merged[target] = entry
                out[#out+1] = entry
            end
        end
        ctx.entries = out
    end
    if not changed then return end

    local out = { "{" }
    for c, ctx in ipairs(contexts) do
        out[#out+1] = string.format('\t"%s" : {', ctx.name)
        for e, entry in ipairs(ctx.entries) do
            out[#out+1] = string.format('\t\t"%s" : [', entry.key)
            for v, value in ipairs(entry.values) do
                out[#out+1] = string.format('\t\t\t"%s"%s', value, v < #entry.values and "," or "")
            end
            out[#out+1] = string.format("\t\t]%s", e < #ctx.entries and "," or "")
        end
        out[#out+1] = string.format("\t}%s", c < #contexts and "," or "")
    end
    out[#out+1] = "}"

    f = io.open(path, "w")
    if not f then return end
    f:write(table.concat(out, "\n"))
    f:write("\n")
    f:close()
end

local macros = {
    { macroPath(""),                   script_description,                  rowMasterGui },
    { macroPath("Config"),             "Chrono Suite settings",             showConfigDialog },
    { macroPath("Help"),               "Chrono Suite help",                 showHelp },
    { macroPath("Cue Timer"),          "Auto-time from detected voice and timing data", cueTimer, hotkeyName = "Cue Timer" },
    { macroPath("Extract KF (SCXvid)"),"Generate keyframes via SCXvid",     runScxvid, hotkeyName = "Extract KF (SCXvid)" },
    { macroPath("Scream Detector"),     "Mark loud dialogue intervals",      screamDetector, hotkeyName = "Scream Detector" },

    { macroPath("Audit/Markers"),       "Run audit markers with current config", function(subs, sel)
            resolveConfig()
            auditLines(subs, sel, applyPreset({}, "Full Audit"))
            aegisub.set_undo_point("Chrono Suite - Audit/Markers")
        end, hotkeyName = "Audit Markers" },
}

local function registerMacro(name, description, process)
    if depRec then
        depRec:registerMacro(name, description, process, nil, nil, false)
    else
        aegisub.register_macro(name, description, process)
    end
end

for _, m in ipairs(macros) do
    if m.hotkeyName then
        local newPath = HotkeyMenu.path(m.hotkeyName)
        registerMacro(newPath, "Hotkey action. " .. m[2], m[3])
        HotkeyMenu.addMigration(m[1], newPath)
    else
        registerMacro(m[1], m[2], m[3])
    end
end

local UTILITY_MACRO_GROUPS = {
    case  = "Case",
    punct = "Punctuation",
    tags  = "Tags",
    smart = "Smart",
    split = "Split Join",
    time  = "Timing",
    kara  = "Karaoke",
}

local function makeUtilityMacro(entry)
    return function(subs, sel)
        local result = runUtilityEntry(entry, subs, sel)
        aegisub.set_undo_point("Chrono Suite - " .. entry.name)
        return result
    end
end

for _, sec in ipairs(UTILITY_SECTIONS) do
    local group = UTILITY_MACRO_GROUPS[sec.id] or sec.id
    for _, entry in ipairs(sec.items) do
        if entry.name and entry.name ~= "" and entry.func then
            local root = sec.id == "kara" and "Karaoke" or ("Utility/" .. group)
            local process = makeUtilityMacro(entry)
            local newPath = HotkeyMenu.path(root .. "/" .. entry.name)
            registerMacro(newPath, "Hotkey action. " .. entry.name, process)
            HotkeyMenu.addMigration(macroPath(root .. "/" .. entry.name), newPath)
        end
    end
end

local function makeSuiteToolMacro(tool)
    return function(subs, sel)
        tool.func(subs, sel)
        aegisub.set_undo_point("Chrono Suite - " .. tool.name)
    end
end

for _, tool in ipairs(SUITE_TOOLS) do
    if tool.name and tool.name ~= "" and tool.func then
        local process = makeSuiteToolMacro(tool)
        local newPath = HotkeyMenu.path(tool.name)
        registerMacro(newPath, "Hotkey action. " .. tool.name, process)
        HotkeyMenu.addMigration(macroPath("Tools/" .. tool.name), newPath)
    end
end

HotkeyMenu.migrate()
