export script_name        = "AddTexture"
export script_description = "Apply pasted ASS drawing textures clipped to selected text outlines"
export script_author      = "Kiterow"
export script_version     = "2.0.1"
export script_namespace   = "kite.AddTexture"

CONFIG_FILE = "kite-addtexture.json"

TEST_EXPORT = rawget _G, "ADD_TEXTURE_TEST_EXPORT"

local ZF, ASS, ConfigHandler, depctrl
if TEST_EXPORT and rawget(_G, "ADD_TEXTURE_TEST_ZF")
  ZF = rawget _G, "ADD_TEXTURE_TEST_ZF"
  ASS = rawget _G, "ADD_TEXTURE_TEST_ASS"
  ConfigHandler = rawget _G, "ADD_TEXTURE_TEST_CONFIG_HANDLER"
else
  DependencyControl = require "l0.DependencyControl"
  depctrl = DependencyControl{
    feed: "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
    {
      {"ZF.main", version: "2.3.0", url: "https://github.com/TypesettingTools/zeref-Aegisub-Scripts",
        feed: "https://raw.githubusercontent.com/TypesettingTools/zeref-Aegisub-Scripts/main/DependencyControl.json"}
      {"l0.ASSFoundation", version: "0.5.0", url: "https://github.com/TypesettingTools/ASSFoundation",
        feed: "https://raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json"}
      {"a-mo.ConfigHandler", version: "1.1.4", url: "https://github.com/TypesettingTools/Aegisub-Motion",
        feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
    }
  }
  ZF, ASS, ConfigHandler = depctrl\requireModules!

safe_require = (name) ->
  ok, mod = pcall require, name
  if ok then mod else nil

clipboard = safe_require "aegisub.clipboard"

DEFAULTS = {
  clip_tolerance: 1.0
  shape_tolerance: 1.0
  layer_offset: 1
  preserve_colors: false
  cut_to_text_shape: false
  user_tags: "\\bord0\\shad0"
}

trim = (value) ->
  text = tostring value or ""
  text = text\gsub "^%s+", ""
  text = text\gsub "%s+$", ""
  text

normalize_color = (color) ->
  return nil unless type(color) == "string"
  hex = color\match "&[Hh](%x+)&?"
  return nil unless hex
  hex = hex\sub(-6) if #hex > 6
  hex = string.rep("0", 6 - #hex) .. hex if #hex < 6
  "&H" .. hex\upper! .. "&"

normalize_tolerance = (tolerance) ->
  value = tonumber(tolerance) or 1
  if value < 1 then 1 else value

format_number = (n) ->
  n = tonumber(n) or 0
  n = 0 if math.abs(n) < 0.000001
  if math.abs(n - math.floor(n + 0.5)) < 0.000001
    return tostring math.floor(n + 0.5)
  s = string.format "%.3f", n
  s = s\gsub "0+$", ""
  s\gsub "%.$", ""

normalize_draw_scale = (drawing, p_scale) ->
  scale = tonumber(p_scale) or 1
  return drawing if scale <= 1
  factor = math.pow 2, scale - 1
  drawing\gsub "%-?%d+%.?%d*", (n) ->
    format_number((tonumber(n) or 0) / factor)

read_clipboard = ->
  return "" unless clipboard and clipboard.get
  ok, data = pcall clipboard.get
  if ok and type(data) == "string" then data else ""

clean_shape = (raw) ->
  s = tostring raw or ""
  s = s\gsub "\r", " "
  s = s\gsub "\n", " "
  s = s\gsub "\\N", " "
  s = s\gsub "%b{}", " "
  s = s\gsub "\\p%d+", " "
  s = s\gsub ",", " "
  s = s\gsub "([mMlLbB])", (c) -> " " .. c\lower! .. " "
  s = s\gsub "%s+", " "
  s = trim s
  trim(s\match("(m%s+%-?[%d%.]+%s+%-?[%d%.]+.*)") or s)

parse_dialogue_line = (line) ->
  s = trim line
  prefix = s\match("^(Dialogue:)") or s\match "^(Comment:)"
  return nil unless prefix
  rest = trim s\sub #prefix + 1
  fields = {}
  pos = 1
  for _ = 1, 9
    comma = rest\find ",", pos, true
    return nil unless comma
    fields[#fields + 1] = rest\sub pos, comma - 1
    pos = comma + 1
  fields[#fields + 1] = rest\sub pos
  { text: fields[10] or "" }

split_payloads = (input) ->
  payloads = {}
  normalized = tostring(input or "")\gsub "\r\n", "\n"
  normalized = normalized\gsub "\r", "\n"
  for line in (normalized .. "\n")\gmatch "([^\n]*)\n"
    if trim(line) != ""
      parsed = parse_dialogue_line line
      payloads[#payloads + 1] = {
        text: parsed and parsed.text or line
        line: parsed
      }
  if #payloads == 0 and trim(normalized) != ""
    payloads[1] = { text: normalized }
  payloads

copy_state = (state = {}) ->
  {
    p: state.p
    color: state.color
    align: state.align
    pos: state.pos and { state.pos[1], state.pos[2] } or nil
    scale_x: state.scale_x
    scale_y: state.scale_y
  }

update_tag_state = (tags, state) ->
  tags = tostring tags or ""
  for color in tags\gmatch "\\1?c%s*(&[Hh]%x+&?)"
    state.color = normalize_color(color) or state.color
  for p in tags\gmatch "\\p(%d+)"
    state.p = tonumber(p) or state.p
  for an in tags\gmatch "\\an([1-9])"
    state.align = tonumber(an) or state.align

  x, y = tags\match "\\pos%(%s*([%-%.%d]+)%s*,%s*([%-%.%d]+)%s*%)"
  if x and y
    state.pos = { tonumber(x), tonumber(y) }
  else
    x, y = tags\match "\\move%(%s*([%-%.%d]+)%s*,%s*([%-%.%d]+)%s*,%s*[%-%.%d]+%s*,%s*[%-%.%d]+"
    state.pos = { tonumber(x), tonumber(y) } if x and y

  fscx = tags\match "\\fscx([%-%.%d]+)"
  fscy = tags\match "\\fscy([%-%.%d]+)"
  state.scale_x = tonumber(fscx) or state.scale_x if fscx
  state.scale_y = tonumber(fscy) or state.scale_y if fscy

collect_tag_state = (input) ->
  state = { p: 0, color: nil, align: 7, pos: nil, scale_x: 100, scale_y: 100 }
  for tags in tostring(input or "")\gmatch "{([^}]*)}"
    update_tag_state tags, state
  state

append_record = (records, raw, state = {}, source_index = 1, kind = "drawing", apply_position = false) ->
  drawing = clean_shape raw
  return false if drawing == "" or not drawing\match "^m%s+"
  drawing = normalize_draw_scale drawing, state.p or 1
  records[#records + 1] = {
    drawing: drawing
    color: normalize_color state.color
    source_index: source_index
    kind: kind
    apply_position: apply_position and state.pos != nil
    align: state.align or 7
    pos: state.pos and { state.pos[1], state.pos[2] } or nil
    scale_x: tonumber(state.scale_x) or 100
    scale_y: tonumber(state.scale_y) or 100
  }
  true

append_clip_args = (records, args, state = {}, source_index = 1) ->
  local_state = copy_state state
  p_scale, drawing = tostring(args or "")\match "^%s*(%d+)%s*,%s*([mM]%s+.+)$"
  if drawing
    local_state.p = tonumber(p_scale) or 1
  else
    drawing = tostring(args or "")\match "^%s*([mM]%s+.+)$"
    local_state.p = 1
  if drawing
    return append_record records, drawing, local_state, source_index, "clip", false
  false

extract_clip_shapes = (text, records, source_index) ->
  state = { p: 0, color: nil, align: 7, pos: nil, scale_x: 100, scale_y: 100 }
  before = #records
  for tags in tostring(text or "")\gmatch "{([^}]*)}"
    update_tag_state tags, state
    for args in tags\gmatch "\\i?clip%(([^%)]*)%)"
      append_clip_args records, args, state, source_index
  return true if #records > before
  for args in tostring(text or "")\gmatch "\\i?clip%(([^%)]*)%)"
    append_clip_args records, args, state, source_index
  #records > before

extract_p_drawings = (text, records, source_index) ->
  text = tostring text or ""
  seed = collect_tag_state text
  state = { p: 0, color: nil, align: seed.align, pos: seed.pos, scale_x: 100, scale_y: 100 }
  pos = 1
  before = #records
  while true
    open, close, tags = text\find "{([^}]*)}", pos
    chunk = if open then text\sub(pos, open - 1) else text\sub(pos)
    append_record records, chunk, state, source_index, "drawing", true if state.p and state.p > 0
    break unless open
    update_tag_state tags, state
    pos = close + 1
  #records > before

extract_raw_shape = (text, records, source_index) ->
  state = collect_tag_state text
  stripped = tostring(text or "")\gsub "%b{}", " "
  stripped = stripped\gsub "\r", " "
  stripped = stripped\gsub "\n", " "
  drawing = stripped\match "%f[%a]([mM]%s*%-?[%d%.]+%s+%-?[%d%.]+.*)"
  if drawing
    return append_record records, drawing, state, source_index, "drawing", state.pos != nil
  false

section_string = (section) ->
  ok, value = pcall ->
    if section.toString
      section\toString!
    elseif section.getString
      section\getString!
    elseif section.getTagParams
      section\getTagParams!
  if ok and value then tostring(value) else ""

assf_tag_name = (tag) ->
  if tag and tag.__tag then tag.__tag.name else nil

assf_tag_values = (tag) ->
  ok, a, b, c, d, e, f = pcall -> tag\getTagParams!
  return nil unless ok
  { a, b, c, d, e, f }

format_assf_color = (values) ->
  return nil unless values and values[1] and values[2] and values[3]
  string.format "&H%02X%02X%02X&", values[1], values[2], values[3]

update_assf_tag_state = (tag, state) ->
  name = assf_tag_name tag
  return false unless name
  values = assf_tag_values tag
  return false unless values

  switch name
    when "color1"
      state.color = format_assf_color(values) or state.color
    when "align"
      state.align = tonumber(values[1]) or state.align
    when "position"
      state.pos = { tonumber(values[1]), tonumber(values[2]) } if values[1] and values[2]
    when "move"
      state.pos = { tonumber(values[1]), tonumber(values[2]) } if values[1] and values[2]
    when "scale_x"
      state.scale_x = tonumber(values[1]) or state.scale_x
    when "scale_y"
      state.scale_y = tonumber(values[1]) or state.scale_y
    else
      return false
  true

append_assf_clip = (records, tag, state, source_index) ->
  name = assf_tag_name tag
  return false unless name == "clip_vect" or name == "iclip_vect" or name == "clip_rect" or name == "iclip_rect"

  local_state = copy_state state
  local_state.p = 1

  values = assf_tag_values tag
  drawing = nil
  if values
    if type(values[2]) == "string"
      drawing = values[2]
      local_state.p = tonumber(values[1]) or 1
    else
      drawing = values[1]
  if drawing and type(drawing) == "string" and drawing\match "^%s*[mM]%s+"
    return append_record records, drawing, local_state, source_index, "clip", false

  if tag.getDrawing
    ok, drawing_section, pos = pcall -> tag\getDrawing true
    if ok and drawing_section
      if pos and pos.getTagParams
        px, py = pos\getTagParams!
        local_state.pos = { px, py }
        return append_record records, section_string(drawing_section), local_state, source_index, "clip", true
      return append_record records, section_string(drawing_section), local_state, source_index, "clip", false
  false

extract_assf_sections = (payload, records, source_index) ->
  return false unless ASS and ASS.Parser and ASS.Parser.LineText
  line = payload.line or { text: payload.text or "" }
  ok, sections = pcall -> ASS.Parser.LineText\getSections line
  return false unless ok and type(sections) == "table"

  before = #records
  seed = collect_tag_state payload.text
  state = { p: 0, color: nil, align: seed.align, pos: seed.pos, scale_x: 100, scale_y: 100 }
  for section in *sections
    if ASS\instanceOf(section, ASS.Section.Tag)
      if section.tags
        for tag in *section.tags
          append_assf_clip records, tag, state, source_index
          update_assf_tag_state tag, state
      else
        update_tag_state section_string(section), state
    elseif ASS\instanceOf(section, ASS.Section.Drawing)
      draw_state = copy_state state
      ok_scale, p_scale = pcall -> section.scale\get!
      draw_state.p = ok_scale and tonumber(p_scale) or 1
      append_record records, section_string(section), draw_state, source_index, "drawing", true
  #records > before

extract_from_text = (text, records, source_index) ->
  before = #records
  return #records - before if extract_p_drawings text, records, source_index
  return #records - before if extract_clip_shapes text, records, source_index
  extract_raw_shape text, records, source_index
  #records - before

extract_ass_drawings = (input) ->
  records = {}
  payloads = split_payloads input
  for i, payload in ipairs payloads
    extracted = false
    extracted = extract_assf_sections payload, records, i
    extract_from_text payload.text, records, i unless extracted
  extract_from_text input, records, 1 if #records == 0
  records

shape_info = (drawing) ->
  ok, shape = pcall -> ZF.shape drawing
  return nil, "Invalid ASS shape." unless ok and shape
  return nil, "ASS shape has empty bounds." unless shape.w and shape.h and shape.w > 0 and shape.h > 0
  shape

build_shape = (shape) ->
  trim shape\build!

transform_record = (record) ->
  shape, err = shape_info record.drawing
  return nil, err unless shape
  if (record.scale_x and record.scale_x != 100) or (record.scale_y and record.scale_y != 100)
    shape\scale record.scale_x or 100, record.scale_y or 100
    shape\setBoudingBox!
  if record.apply_position and record.pos
    shape\setPosition record.align or 7, "tcp", record.pos[1] or 0, record.pos[2] or 0
  drawing = build_shape shape
  shape, err = shape_info drawing
  return nil, err unless shape
  {
    drawing: drawing
    color: record.color
    source_index: record.source_index
  }

join_drawings = (items) ->
  out = {}
  for item in *items
    drawing = if type(item) == "table" then item.drawing else item
    out[#out + 1] = trim drawing if drawing and trim(drawing) != ""
  trim table.concat out, " "

move_drawing = (drawing, dx = 0, dy = 0) ->
  shape, err = shape_info drawing
  return nil, err unless shape
  build_shape shape\move dx, dy

scale_drawing = (drawing, scale = 1) ->
  shape, err = shape_info drawing
  return nil, err unless shape
  build_shape shape\scale scale * 100, scale * 100

simplify_drawing = (drawing, tolerance) ->
  tol = normalize_tolerance tolerance
  ok, simplified = pcall ->
    ZF.clipper(drawing)\simplify!\build "line", tol
  return nil, "Could not simplify ASS shape: #{simplified}" unless ok
  simplified = trim simplified
  simplified = drawing if simplified == ""
  shape, err = shape_info simplified
  return nil, err unless shape
  simplified

prepare_texture_groups = (input, tolerance, preserve_colors) ->
  extracted = extract_ass_drawings input
  if #extracted == 0
    return nil, "Paste raw ASS drawing data, a {\\p1} drawing, a vector \\clip(), or Dialogue/Comment lines containing drawings."

  transformed = {}
  for i, record in ipairs extracted
    item, err = transform_record record
    unless item
      return nil, ("Texture shape %d failed: %s")\format i, err or "invalid shape"
    transformed[#transformed + 1] = item

  combined = join_drawings transformed
  global_shape, err = shape_info combined
  return nil, err unless global_shape

  global = {
    l: global_shape.l
    t: global_shape.t
    w: global_shape.w
    h: global_shape.h
  }
  return nil, "ASS texture composition has empty bounds." if global.w <= 0 or global.h <= 0

  normalize_to_global = (drawing) ->
    move_drawing drawing, -global.l, -global.t

  unless preserve_colors
    moved, move_err = normalize_to_global combined
    return nil, move_err unless moved
    simplified, simplify_err = simplify_drawing moved, tolerance
    return nil, simplify_err unless simplified
    return {
      {
        drawing: simplified
        color: nil
        w: global.w
        h: global.h
      }
    }, global

  buckets, order = {}, {}
  for item in *transformed
    key = item.color or "__fallback__"
    unless buckets[key]
      buckets[key] = { color: item.color, drawings: {} }
      order[#order + 1] = key
    buckets[key].drawings[#buckets[key].drawings + 1] = item

  groups = {}
  for key in *order
    bucket = buckets[key]
    drawing = join_drawings bucket.drawings
    moved, move_err = normalize_to_global drawing
    return nil, move_err unless moved
    simplified, simplify_err = simplify_drawing moved, tolerance
    return nil, simplify_err unless simplified
    groups[#groups + 1] = {
      drawing: simplified
      color: bucket.color
      w: global.w
      h: global.h
    }

  groups, global

fit_texture_to_box = (group, target_l, target_t, target_w, target_h) ->
  target_l = tonumber(target_l) or 0
  target_t = tonumber(target_t) or 0
  target_w = tonumber(target_w) or 0
  target_h = tonumber(target_h) or 0
  return nil, "Text outline has empty bounds." if target_w <= 0 or target_h <= 0
  return nil, "Texture shape has empty bounds." unless group and group.w and group.h and group.w > 0 and group.h > 0

  scale = math.max target_w / group.w, target_h / group.h
  drawing, err = scale_drawing group.drawing, scale
  return nil, err unless drawing
  scaled_w = group.w * scale
  scaled_h = group.h * scale
  {
    drawing: drawing
    scale: scale
    x: target_l + (target_w - scaled_w) / 2
    y: target_t + (target_h - scaled_h) / 2
  }

cut_fitted_texture_to_clip = (fitted, clip_drawing, tolerance) ->
  absolute, move_err = move_drawing fitted.drawing, fitted.x, fitted.y
  return nil, move_err unless absolute
  tol = normalize_tolerance tolerance
  ok, clipped = pcall ->
    ZF.clipper(absolute, clip_drawing, true)\clip(false)\build "line", tol
  return nil, "Could not cut texture shape to text outline: #{clipped}" unless ok
  clipped = trim clipped
  return nil, "Cut texture shape is empty." if clipped == ""
  local_drawing, local_err = move_drawing clipped, -fitted.x, -fitted.y
  return nil, local_err unless local_drawing
  local_drawing

build_text_clip = (dlg, line, tolerance) ->
  call = ZF.line(line)\prepoc dlg
  pers = dlg\getPerspectiveTags line
  pers.p = "text" if pers.p == 0
  px, py = pers.pos[1], pers.pos[2]
  shape = ZF.util\isShape line.text
  unless shape
    shape = call\toShape dlg, nil, px, py
    line.styleref.scale_x = 100
    line.styleref.scale_y = 100
  clip_abs = ZF.shape(shape, true)\setPosition(line.styleref.align)\expand(line, pers)\move(px, py)\build!
  tol = normalize_tolerance tolerance
  simplified = trim ZF.clipper(clip_abs)\simplify!\build "line", tol
  sh = ZF.shape simplified
  {
    clip: simplified
    l: sh.l
    t: sh.t
    w: sh.w
    h: sh.h
    cx: sh.l + sh.w / 2
    cy: sh.t + sh.h / 2
  }

text_primary_color = (l, line) ->
  c1 = l.text\match "\\1?c%s*(&[Hh]%x+&?)"
  return normalize_color c1 if c1
  if line.styleref and line.styleref.color1
    return normalize_color(line.styleref.color1) or line.styleref.color1
  "&HFFFFFF&"

show_message = (title, msg) ->
  aegisub.dialog.display {
    { class: "label", label: title, x: 0, y: 0, width: 7 }
    { class: "textbox", value: msg, x: 0, y: 1, width: 7, height: 6 }
  }, { "OK" }

build_interface = ->
  {
    main: {
      title: { class: "label", label: "AddTexture", x: 0, y: 0, width: 7 }
      hint: {
        class: "label"
        label: "Paste ASS drawings, vector clips, or Dialogue/Comment lines."
        x: 0
        y: 1
        width: 7
      }
      shape_label: { class: "label", label: "ASS drawings / Dialogue lines:", x: 0, y: 2, width: 7 }
      shape_input: { class: "textbox", value: "", config: false, x: 0, y: 3, width: 7, height: 9 }
      preserve_colors: {
        class: "checkbox"
        label: "Preserve colors"
        value: DEFAULTS.preserve_colors
        config: true
        x: 0
        y: 12
        width: 3
      }
      cut_to_text_shape: {
        class: "checkbox"
        label: "Clip to text"
        value: DEFAULTS.cut_to_text_shape
        config: true
        x: 3
        y: 12
        width: 4
      }
      user_tags_label: { class: "label", label: "Extra tags:", x: 0, y: 13, width: 2 }
      user_tags: {
        class: "edit"
        value: DEFAULTS.user_tags
        config: true
        x: 2
        y: 13
        width: 5
      }
      clip_tolerance_label: { class: "label", label: "Text simplify:", x: 0, y: 14, width: 4 }
      clip_tolerance: {
        class: "floatedit"
        value: DEFAULTS.clip_tolerance
        config: true
        min: 1
        max: 50
        x: 4
        y: 14
        width: 3
      }
      shape_tolerance_label: { class: "label", label: "Shape simplify:", x: 0, y: 15, width: 4 }
      shape_tolerance: {
        class: "floatedit"
        value: DEFAULTS.shape_tolerance
        config: true
        min: 1
        max: 50
        x: 4
        y: 15
        width: 3
      }
      layer_offset_label: { class: "label", label: "Layer offset:", x: 0, y: 16, width: 4 }
      layer_offset: {
        class: "intedit"
        value: DEFAULTS.layer_offset
        config: true
        min: 0
        max: 100
        x: 4
        y: 16
        width: 3
      }
    }
  }

show_dialog = ->
  interface = build_interface!
  options = nil
  if ConfigHandler
    options = ConfigHandler interface, CONFIG_FILE, true, script_version
    options\read!
    options\updateInterface "main"

  interface.main.shape_input.value = read_clipboard!
  btn, res = aegisub.dialog.display interface.main, { "Run", "Cancel" }, { ok: "Run", close: "Cancel" }
  aegisub.cancel! if btn != "Run"
  if options
    options\updateConfiguration res, "main"
    options\write!
  res

main = (subs, sel, active) ->
  unless sel and #sel >= 1
    aegisub.dialog.display { { class: "label", label: "Select at least one line." } }, { "OK" }
    aegisub.cancel!

  opts = show_dialog!
  texture_groups, err = prepare_texture_groups opts.shape_input or "", opts.shape_tolerance, opts.preserve_colors and true or false
  unless texture_groups
    show_message "AddTexture - invalid drawing input", err
    aegisub.cancel!

  aegisub.progress.title "AddTexture"
  dlg = ZF.dialog subs, sel, active, false
  processed = 0

  for l, line, sel_idx, _, n in dlg\iterSelected!
    processed += 1
    aegisub.progress.set processed * 100 / n
    aegisub.progress.task ("Texturing line %d / %d")\format processed, n

    unless l.comment
      text_box = build_text_clip dlg, line, opts.clip_tolerance
      clip_inner = trim text_box.clip
      fallback_color = text_primary_color l, line

      for group in *texture_groups
        fitted, fit_err = fit_texture_to_box group, text_box.l, text_box.t, text_box.w, text_box.h
        unless fitted
          show_message "AddTexture - fit failed", fit_err
          aegisub.cancel!

        drawing = fitted.drawing
        clip_tag = "\\clip(#{clip_inner})"
        if opts.cut_to_text_shape
          cut, cut_err = cut_fitted_texture_to_clip fitted, clip_inner, opts.shape_tolerance
          unless cut
            show_message "AddTexture - shape cut failed", cut_err
            aegisub.cancel!
          drawing = cut
          clip_tag = ""

        new_line = ZF.table(l)\copy!
        new_line.comment = false
        new_line.layer = (l.layer or 0) + (tonumber(opts.layer_offset) or 1)
        new_line.text = string.format "{\\an7\\pos(%s,%s)%s\\1c%s%s\\p1}%s",
          format_number(fitted.x),
          format_number(fitted.y),
          opts.user_tags or "",
          group.color or fallback_color,
          clip_tag,
          drawing
        dlg\insertLine new_line, sel_idx

  aegisub.progress.set 100
  dlg\getSelection!

if TEST_EXPORT
  export ADD_TEXTURE_INTERNALS = {
    clean_shape: clean_shape
    parse_dialogue_line: parse_dialogue_line
    split_payloads: split_payloads
    extract_ass_drawings: extract_ass_drawings
    prepare_texture_groups: prepare_texture_groups
    fit_texture_to_box: fit_texture_to_box
    cut_fitted_texture_to_clip: cut_fitted_texture_to_clip
    build_text_clip: build_text_clip
    build_interface: build_interface
    normalize_color: normalize_color
    text_primary_color: text_primary_color
    format_number: format_number
    main: main
  }
else
  validate = (subs, sel) -> sel and #sel >= 1
  if depctrl and depctrl.registerMacro
    depctrl\registerMacro script_name, script_description, main, validate, nil, false
  else
    aegisub.register_macro script_name, script_description, main, validate
