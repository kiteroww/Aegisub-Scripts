export script_name        = "Moka Shape"
export script_description = "Convert Adobe After Effects mask data to ASS clips or drawings"
export script_author      = "Kiterow"
export script_version     = "0.1.1"
export script_namespace   = "kite.Mokashape"

CONFIG_FILE = "kite-mokashape.json"

local ZF, ASS, ConfigHandler, clipboard, depctrl, DependencyControl

safe_require = (name) ->
  ok, mod = pcall require, name
  if ok then mod else nil

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

clipboard = safe_require "aegisub.clipboard"

DEFAULTS = {
  output_mode: "clip"
  placement: "Replace selected lines"
  frame_mode: "First keyframe"
  use_source_meta: true
  scale_to_script: true
  source_width: 1920
  source_height: 1080
  target_width: 1920
  target_height: 1080
  fps: 24
  offset_x: 0
  offset_y: 0
  decimals: 2
  tangent_epsilon: 0.25
  layer_offset: 1
  shape_tags: "\\bord0\\shad0"
}

OUTPUT_MODES = {"clip", "iclip", "shape"}
PLACEMENTS = {"Replace selected lines", "Insert new lines"}
FRAME_MODES = {"First keyframe", "Map keyframes to selected lines", "Create keyframe ranges"}
NUM_PATTERN = "[%+%-]?%d*%.?%d+[eE]?[%+%-]?%d*"

trim = (value) ->
  text = if value == nil then "" else tostring value
  text = text\gsub "^%s+", ""
  text = text\gsub "%s+$", ""
  text

clamp = (value, low, high) ->
  value = tonumber(value) or low
  math.max low, math.min high, value

round_to = (value, decimals = 2) ->
  decimals = clamp decimals, 0, 4
  factor = 10 ^ decimals
  if value >= 0
    math.floor(value * factor + 0.5) / factor
  else
    math.ceil(value * factor - 0.5) / factor

format_number = (value, decimals = 2) ->
  value = tonumber(value) or 0
  value = 0 if math.abs(value) < 0.000001
  value = round_to value, decimals
  if math.abs(value - math.floor(value + 0.5)) < 0.000001
    return tostring math.floor(value + 0.5)
  fmt = "%." .. tostring(decimals) .. "f"
  out = string.format fmt, value
  out = out\gsub "0+$", ""
  out = out\gsub "%.$", ""
  out

copy_line = (line) ->
  out = {}
  out[k] = v for k, v in pairs line
  out

read_clipboard = ->
  return "" unless clipboard and clipboard.get
  ok, data = pcall clipboard.get
  if ok and type(data) == "string" then data else ""

find_balanced = (text, start_pos, open_char, close_char) ->
  depth = 0
  for i = start_pos, #text
    ch = text\sub i, i
    if ch == open_char
      depth += 1
    elseif ch == close_char
      depth -= 1
      if depth == 0
        return text\sub(start_pos, i), i
  nil, nil

extract_labeled_array = (block, label) ->
  label_pos = block\find label, 1, true
  return nil unless label_pos
  start_pos = block\find "[", label_pos, true
  return nil unless start_pos
  array, _ = find_balanced block, start_pos, "[", "]"
  array

parse_pair_array = (array_text) ->
  points = {}
  return points unless array_text
  pattern = "%[%s*(#{NUM_PATTERN})%s*,%s*(#{NUM_PATTERN})%s*%]"
  for x, y in array_text\gmatch pattern
    points[#points + 1] = {x: tonumber(x), y: tonumber(y)}
  points

frame_from_prefix = (prefix) ->
  frame = nil
  for line in tostring(prefix or "")\gmatch "[^\r\n]+"
    value = line\match "^%s*([%-]?%d+)%s"
    frame = tonumber value if value
  frame

parse_shape_block = (block, frame, source_index) ->
  vertices_raw = extract_labeled_array block, "vertices"
  in_raw = extract_labeled_array block, "inTangents"
  out_raw = extract_labeled_array block, "outTangents"
  vertices = parse_pair_array vertices_raw
  in_tangents = parse_pair_array in_raw
  out_tangents = parse_pair_array out_raw
  return nil, "Shape #{source_index} has no vertices." if #vertices < 2
  return nil, "Shape #{source_index} has incomplete inTangents." if in_raw and #in_tangents != #vertices
  return nil, "Shape #{source_index} has incomplete outTangents." if out_raw and #out_tangents != #vertices

  closed_raw = block\match "[\"']?closed[\"']?%s*[:=]%s*(%a+)"
  closed = true
  closed = false if closed_raw and closed_raw\lower! == "false"

  points = {}
  for i, vertex in ipairs vertices
    in_t = in_tangents[i] or {x: 0, y: 0}
    out_t = out_tangents[i] or {x: 0, y: 0}
    points[#points + 1] = {
      x: vertex.x or 0
      y: vertex.y or 0
      inx: in_t.x or 0
      iny: in_t.y or 0
      outx: out_t.x or 0
      outy: out_t.y or 0
    }

  {
    frame: frame
    closed: closed
    points: points
    source_index: source_index
  }

parse_meta = (input) ->
  text = tostring input or ""
  {
    fps: tonumber(text\match "Units Per Second%s+([%d%.]+)") or nil
    source_width: tonumber(text\match "Source Width%s+([%d%.]+)") or nil
    source_height: tonumber(text\match "Source Height%s+([%d%.]+)") or nil
  }

parse_number_list = (text) ->
  out = {}
  for value in tostring(text or "")\gmatch NUM_PATTERN
    out[#out + 1] = tonumber value
  out

parse_bezier_point_block = (body, frame, source_index, closed) ->
  points = {}
  for raw in tostring(body or "")\gmatch "Point%(([^%)]*)%)"
    values = parse_number_list raw
    if #values >= 2
      points[#points + 1] = {
        x: values[1]
        y: values[2]
        inx: 0
        iny: 0
        outx: 0
        outy: 0
        normalized: true
        y_up: true
      }
  return nil, "Bezier shape #{source_index} has no points." if #points < 2
  {
    frame: frame
    closed: closed
    points: points
    source_index: source_index
    legacy_bezier: true
  }

parse_legacy_bezier_data = (input) ->
  text = tostring input or ""
  frames = {}
  source_index = 0
  pos = 1
  while true
    bezier_pos = text\find "Bezier", pos, true
    break unless bezier_pos
    open_pos = text\find "(", bezier_pos, true
    break unless open_pos
    block, block_end = find_balanced text, open_pos, "(", ")"
    break unless block and block_end
    source_index += 1
    prefix = text\sub math.max(1, bezier_pos - 2048), bezier_pos - 1
    suffix = text\sub block_end + 1, math.min(#text, block_end + 4096)
    frame = frame_from_prefix(prefix) or source_index - 1
    body = block\sub 2, -2
    open_text = suffix\match "<Open>%s*(%d+)%s*</Open>"
    closed = tostring(open_text or "0") != "1"
    shape, err = parse_bezier_point_block body, frame, source_index, closed
    return nil, err unless shape
    frames[#frames + 1] = shape
    pos = block_end + 1
  return nil if #frames == 0
  table.sort frames, (a, b) ->
    if a.frame == b.frame
      return a.source_index < b.source_index
    a.frame < b.frame
  frames

parse_ae_mask_data = (input) ->
  text = tostring input or ""
  frames = {}
  pos = 1
  source_index = 0

  while true
    shape_pos = text\find "Shape", pos, true
    break unless shape_pos
    brace_pos = text\find "{", shape_pos, true
    break unless brace_pos
    block, block_end = find_balanced text, brace_pos, "{", "}"
    break unless block and block_end
    if block\find "vertices", 1, true
      source_index += 1
      prefix = text\sub math.max(1, brace_pos - 2048), brace_pos - 1
      frame = frame_from_prefix(prefix) or 0
      shape, err = parse_shape_block block, frame, source_index
      return nil, err unless shape
      frames[#frames + 1] = shape
    pos = block_end + 1

  if #frames == 0 and text\find("vertices", 1, true)
    shape, err = parse_shape_block text, 0, 1
    return nil, err unless shape
    frames[1] = shape

  if #frames == 0
    legacy_frames, legacy_err = parse_legacy_bezier_data text
    return nil, legacy_err if legacy_err
    frames = legacy_frames if legacy_frames

  return nil, "No AE Shape{vertices/inTangents/outTangents/closed} or Bezier(Point(...)) data found." if #frames == 0

  table.sort frames, (a, b) ->
    if a.frame == b.frame
      return a.source_index < b.source_index
    a.frame < b.frame

  {meta: parse_meta(text), frames: frames}

point_at = (point, x, y, ctx) ->
  if point and point.normalized
    x *= ctx.source_w
    y = 1 - y if point.y_up
    y *= ctx.source_h
  {
    x: x * ctx.sx + ctx.dx
    y: y * ctx.sy + ctx.dy
  }

segment_is_line = (point_a, point_b, ctx) ->
  eps = ctx.epsilon
  math.abs((point_a.outx or 0) * ctx.sx) <= eps and
    math.abs((point_a.outy or 0) * ctx.sy) <= eps and
    math.abs((point_b.inx or 0) * ctx.sx) <= eps and
    math.abs((point_b.iny or 0) * ctx.sy) <= eps

append_segment = (parts, point_a, point_b, ctx) ->
  end_point = point_at point_b, point_b.x, point_b.y, ctx
  if segment_is_line point_a, point_b, ctx
    parts[#parts + 1] = "l"
    parts[#parts + 1] = format_number end_point.x, ctx.decimals
    parts[#parts + 1] = format_number end_point.y, ctx.decimals
  else
    c1 = point_at point_a, point_a.x + point_a.outx, point_a.y + point_a.outy, ctx
    c2 = point_at point_b, point_b.x + point_b.inx, point_b.y + point_b.iny, ctx
    parts[#parts + 1] = "b"
    parts[#parts + 1] = format_number c1.x, ctx.decimals
    parts[#parts + 1] = format_number c1.y, ctx.decimals
    parts[#parts + 1] = format_number c2.x, ctx.decimals
    parts[#parts + 1] = format_number c2.y, ctx.decimals
    parts[#parts + 1] = format_number end_point.x, ctx.decimals
    parts[#parts + 1] = format_number end_point.y, ctx.decimals

render_shape_path = (shape, ctx) ->
  points = shape.points
  return nil, "Shape has fewer than two points." unless points and #points >= 2

  first = point_at points[1], points[1].x, points[1].y, ctx
  parts = {"m", format_number(first.x, ctx.decimals), format_number(first.y, ctx.decimals)}

  for i = 1, #points - 1
    append_segment parts, points[i], points[i + 1], ctx

  if shape.closed
    append_segment parts, points[#points], points[1], ctx

  table.concat parts, " "

normalize_path = (path) ->
  path = trim path
  return nil, "Generated empty ASS path." if path == ""
  if ZF
    ok, shape_or_err = pcall -> ZF.shape path
    return nil, "Generated path is not accepted by ZF.shape: #{shape_or_err}" unless ok and shape_or_err
    ok_build, built = pcall -> trim shape_or_err\build!
    return built if ok_build and built and built != ""
  path

manual_bounds = (path) ->
  min_x, min_y, max_x, max_y = math.huge, math.huge, -math.huge, -math.huge
  is_x = true
  found = false
  for token in tostring(path or "")\gmatch "%S+"
    if token == "m" or token == "l" or token == "b"
      is_x = true
    else
      n = tonumber token
      if n
        if is_x
          min_x = math.min min_x, n
          max_x = math.max max_x, n
        else
          min_y = math.min min_y, n
          max_y = math.max max_y, n
          found = true
        is_x = not is_x
  return nil unless found
  {l: min_x, t: min_y, r: max_x, b: max_y, w: max_x - min_x, h: max_y - min_y}

path_bounds = (path) ->
  if ZF
    ok, shape = pcall -> ZF.shape path
    if ok and shape and shape.l and shape.t and shape.w and shape.h
      return {l: shape.l, t: shape.t, r: shape.l + shape.w, b: shape.t + shape.h, w: shape.w, h: shape.h}
  manual_bounds path

manual_shift_path = (path, dx, dy, decimals) ->
  out = {}
  is_x = true
  for token in tostring(path or "")\gmatch "%S+"
    if token == "m" or token == "l" or token == "b"
      out[#out + 1] = token
      is_x = true
    else
      n = tonumber token
      if n
        out[#out + 1] = format_number(n + (is_x and dx or dy), decimals)
        is_x = not is_x
      else
        out[#out + 1] = token
  table.concat out, " "

starts_at = (text, pos, needle) ->
  text\sub(pos, pos + #needle - 1) == needle

shift_path = (path, dx, dy, decimals) ->
  if ZF
    ok, moved = pcall -> trim ZF.shape(path)\move(dx, dy)\build!
    return moved if ok and moved and moved != ""
  manual_shift_path path, dx, dy, decimals

build_context = (opts, meta, script_res) ->
  target_w = tonumber(opts.target_width) or script_res.x or DEFAULTS.target_width
  target_h = tonumber(opts.target_height) or script_res.y or DEFAULTS.target_height
  source_w = if opts.use_source_meta and meta.source_width then meta.source_width else tonumber(opts.source_width)
  source_h = if opts.use_source_meta and meta.source_height then meta.source_height else tonumber(opts.source_height)
  source_w = target_w unless source_w and source_w > 0
  source_h = target_h unless source_h and source_h > 0
  scale = opts.scale_to_script
  {
    sx: scale and target_w / source_w or 1
    sy: scale and target_h / source_h or 1
    dx: tonumber(opts.offset_x) or 0
    dy: tonumber(opts.offset_y) or 0
    decimals: clamp opts.decimals, 0, 4
    epsilon: tonumber(opts.tangent_epsilon) or DEFAULTS.tangent_epsilon
    target_w: target_w
    target_h: target_h
    source_w: source_w
    source_h: source_h
  }

combine_by_frame = (items) ->
  out, by_frame, order = {}, {}, {}
  for item in *items
    key = tostring item.frame
    unless by_frame[key]
      by_frame[key] = {frame: item.frame, paths: {}}
      order[#order + 1] = key
    by_frame[key].paths[#by_frame[key].paths + 1] = item.path
  for key in *order
    group = by_frame[key]
    out[#out + 1] = {frame: group.frame, path: trim table.concat group.paths, " "}
  table.sort out, (a, b) -> a.frame < b.frame
  out

compress_frames = (frames) ->
  out = {}
  for frame in *frames
    if #out == 0 or out[#out].path != frame.path
      out[#out + 1] = frame
  out

prepare_paths = (input, opts, script_res = {x: DEFAULTS.target_width, y: DEFAULTS.target_height}) ->
  parsed, err = parse_ae_mask_data input
  return nil, err unless parsed
  ctx = build_context opts, parsed.meta, script_res
  rendered = {}
  for shape in *parsed.frames
    path, path_err = render_shape_path shape, ctx
    return nil, path_err unless path
    path, norm_err = normalize_path path
    return nil, norm_err unless path
    rendered[#rendered + 1] = {frame: shape.frame, path: path}
  frames = compress_frames combine_by_frame rendered
  fps = tonumber(parsed.meta.fps) or tonumber(opts.fps) or DEFAULTS.fps
  fps = DEFAULTS.fps unless fps and fps > 0
  {
    frames: frames
    meta: parsed.meta
    ctx: ctx
    fps: fps
  }

vector_clip_tag = (mode, path) ->
  "\\#{mode}(1,#{path})"

strip_clip_tags = (text) ->
  text = tostring text or ""
  out = {}
  i, depth = 1, 0
  while i <= #text
    if depth == 0 and (starts_at(text, i, "\\clip(") or starts_at(text, i, "\\iclip("))
      open_pos = text\find "(", i, true
      _, close_pos = find_balanced text, open_pos, "(", ")"
      if close_pos
        i = close_pos + 1
        continue
    ch = text\sub i, i
    out[#out + 1] = ch
    if ch == "("
      depth += 1
    elseif ch == ")" and depth > 0
      depth -= 1
    i += 1
  table.concat out

apply_clip_to_text = (text, mode, path) ->
  tag = vector_clip_tag mode, path
  clean = strip_clip_tags text
  if clean\match "^%s*{"
    clean\gsub "^(%s*{)", "%1" .. tag, 1
  else
    "{#{tag}}" .. clean

apply_clip_with_ass = (line, mode, path) ->
  return nil unless ASS and ASS.parse and ASS.Draw and ASS.Draw.DrawingBase
  working = copy_line line
  ok, out = pcall ->
    data = ASS\parse working
    data\removeTags {"clip_vect", "iclip_vect", "clip_rect", "iclip_rect"}
    drawing = ASS.Draw.DrawingBase{str: path}
    tag_name = mode == "iclip" and "iclip_vect" or "clip_vect"
    data\replaceTags {ASS\createTag tag_name, drawing}
    data\commit!
    working.text
  if ok and out and out != "" then out else nil

shape_text = (path, opts) ->
  decimals = clamp opts.decimals, 0, 4
  bounds = path_bounds(path) or {l: 0, t: 0, w: 0, h: 0}
  local_path = shift_path path, -bounds.l, -bounds.t, decimals
  tags = opts.shape_tags or DEFAULTS.shape_tags
  "{\\an7\\pos(#{format_number bounds.l, decimals},#{format_number bounds.t, decimals})\\fscx100\\fscy100#{tags}\\p1}#{local_path}{\\p0}"

render_line_text = (base_text, mode, path, opts, line = nil) ->
  if mode == "shape"
    shape_text path, opts
  else
    ass_text = apply_clip_with_ass line, mode, path if line
    return ass_text if ass_text
    apply_clip_to_text base_text, mode, path

frame_ms = (fps) ->
  fps = tonumber(fps) or DEFAULTS.fps
  fps = DEFAULTS.fps if fps <= 0
  math.max 1, math.floor(1000 / fps + 0.5)

apply_segment_timing = (line, segment, next_segment, first_frame, fps) ->
  fps = tonumber(fps) or DEFAULTS.fps
  fps = DEFAULTS.fps if fps <= 0
  frame_len = frame_ms fps
  start_base = tonumber(line.start_time) or 0
  end_base = tonumber(line.end_time) or start_base + frame_len
  end_base = start_base + frame_len unless end_base > start_base
  start_time = start_base + math.floor(((segment.frame - first_frame) * 1000 / fps) + 0.5)
  return nil if start_time >= end_base
  end_time = if next_segment
    start_base + math.floor(((next_segment.frame - first_frame) * 1000 / fps) + 0.5)
  else
    end_base
  end_time = math.min end_time, end_base
  end_time = math.min start_time + frame_len, end_base if end_time <= start_time
  return nil if end_time <= start_time
  line.start_time = start_time
  line.end_time = end_time
  line

selected_dialogue_indices = (subs, sel) ->
  out = {}
  for idx in *sel
    line = subs[idx]
    out[#out + 1] = idx if line and line.class == "dialogue"
  out

apply_static = (subs, sel, prepared, opts) ->
  indices = selected_dialogue_indices subs, sel
  return nil, "Select at least one dialogue line." if #indices == 0
  frames = prepared.frames
  mode = opts.output_mode or DEFAULTS.output_mode
  insert_new = opts.placement == "Insert new lines"
  map_frames = opts.frame_mode == "Map keyframes to selected lines"

  if insert_new
    for pos = #indices, 1, -1
      idx = indices[pos]
      base = subs[idx]
      frame = if map_frames then frames[math.min(pos, #frames)] else frames[1]
      new_line = copy_line base
      new_line.comment = false
      new_line.layer = (tonumber(base.layer) or 0) + (tonumber(opts.layer_offset) or 1)
      new_line.text = render_line_text base.text or "", mode, frame.path, opts, base
      subs.insert idx + 1, new_line
  else
    for pos, idx in ipairs indices
      line = copy_line subs[idx]
      frame = if map_frames then frames[math.min(pos, #frames)] else frames[1]
      line.comment = false
      line.text = render_line_text line.text or "", mode, frame.path, opts, line
      subs[idx] = line
  indices

apply_ranges_at = (subs, base_idx, frames, mode, opts, fps, replace) ->
  base = subs[base_idx]
  first_frame = frames[1].frame
  layer_delta = if replace then 0 else tonumber(opts.layer_offset) or 1

  for pos = #frames, 1, -1
    segment = frames[pos]
    next_segment = frames[pos + 1]
    line = copy_line base
    line.comment = false
    line.layer = (tonumber(base.layer) or 0) + layer_delta
    line.text = render_line_text base.text or "", mode, segment.path, opts, base
    line = apply_segment_timing line, segment, next_segment, first_frame, fps
    continue unless line
    if replace and pos == 1
      subs[base_idx] = line
    else
      subs.insert base_idx + 1, line

apply_frame_ranges = (subs, sel, prepared, opts) ->
  indices = selected_dialogue_indices subs, sel
  return nil, "Select at least one dialogue line." if #indices == 0
  frames = prepared.frames
  mode = opts.output_mode or DEFAULTS.output_mode
  replace = opts.placement == "Replace selected lines"
  for pos = #indices, 1, -1
    apply_ranges_at subs, indices[pos], frames, mode, opts, prepared.fps, replace
  indices

get_script_resolution = (subs) ->
  res = {x: nil, y: nil}
  if subs
    for i = 1, #subs
      line = subs[i]
      if line and line.class == "info"
        key = tostring(line.key or "")\lower!
        if key == "playresx"
          res.x = tonumber line.value
        elseif key == "playresy"
          res.y = tonumber line.value
  res.x = res.x or DEFAULTS.target_width
  res.y = res.y or DEFAULTS.target_height
  res

meta_defaults = (input, script_res) ->
  parsed = parse_ae_mask_data input
  meta = parsed and parsed.meta or {}
  {
    source_width: meta.source_width or script_res.x
    source_height: meta.source_height or script_res.y
    fps: meta.fps or DEFAULTS.fps
  }

apply_dynamic_defaults = (interface, input, script_res) ->
  meta = meta_defaults input, script_res
  interface.main.input.value = input
  interface.main.fps.value = meta.fps
  interface.main.source_width.value = meta.source_width
  interface.main.source_height.value = meta.source_height
  interface.main.target_width.value = script_res.x
  interface.main.target_height.value = script_res.y

build_interface = (input, script_res) ->
  meta = meta_defaults input, script_res
  {
    main: {
      input_label: {class: "label", label: "Adobe After Effects Mask Data:", x: 0, y: 0, width: 8, height: 1}
      input: {class: "textbox", value: input or "", config: false, x: 0, y: 1, width: 10, height: 9}

      output_label: {class: "label", label: "Output:", x: 0, y: 10, width: 2, height: 1}
      output_mode: {class: "dropdown", items: OUTPUT_MODES, value: DEFAULTS.output_mode, config: true, x: 2, y: 10, width: 2, height: 1}
      placement_label: {class: "label", label: "Placement:", x: 4, y: 10, width: 2, height: 1}
      placement: {class: "dropdown", items: PLACEMENTS, value: DEFAULTS.placement, config: true, x: 6, y: 10, width: 4, height: 1}

      frame_label: {class: "label", label: "Frames:", x: 0, y: 11, width: 2, height: 1}
      frame_mode: {class: "dropdown", items: FRAME_MODES, value: DEFAULTS.frame_mode, config: true, x: 2, y: 11, width: 4, height: 1}
      fps_label: {class: "label", label: "FPS:", x: 6, y: 11, width: 1, height: 1}
      fps: {class: "floatedit", value: meta.fps, config: true, min: 1, x: 7, y: 11, width: 1, height: 1}

      use_source_meta: {class: "checkbox", label: "Use AE source size", value: DEFAULTS.use_source_meta, config: true, x: 8, y: 11, width: 2, height: 1}
      scale_to_script: {class: "checkbox", label: "Scale to script", value: DEFAULTS.scale_to_script, config: true, x: 8, y: 12, width: 2, height: 1}

      source_w_label: {class: "label", label: "Source W/H:", x: 0, y: 12, width: 2, height: 1}
      source_width: {class: "intedit", value: meta.source_width, config: true, min: 1, x: 2, y: 12, width: 1, height: 1}
      source_height: {class: "intedit", value: meta.source_height, config: true, min: 1, x: 3, y: 12, width: 1, height: 1}
      target_w_label: {class: "label", label: "Target W/H:", x: 4, y: 12, width: 2, height: 1}
      target_width: {class: "intedit", value: script_res.x, config: true, min: 1, x: 6, y: 12, width: 1, height: 1}
      target_height: {class: "intedit", value: script_res.y, config: true, min: 1, x: 7, y: 12, width: 1, height: 1}

      offset_label: {class: "label", label: "Offset X/Y:", x: 0, y: 13, width: 2, height: 1}
      offset_x: {class: "floatedit", value: DEFAULTS.offset_x, config: true, x: 2, y: 13, width: 1, height: 1}
      offset_y: {class: "floatedit", value: DEFAULTS.offset_y, config: true, x: 3, y: 13, width: 1, height: 1}
      decimals_label: {class: "label", label: "Decimals:", x: 4, y: 13, width: 2, height: 1}
      decimals: {class: "intedit", value: DEFAULTS.decimals, config: true, min: 0, max: 4, x: 6, y: 13, width: 1, height: 1}
      eps_label: {class: "label", label: "Tangent eps:", x: 7, y: 13, width: 2, height: 1}
      tangent_epsilon: {class: "floatedit", value: DEFAULTS.tangent_epsilon, config: true, min: 0, x: 9, y: 13, width: 1, height: 1}

      tags_label: {class: "label", label: "Shape tags:", x: 0, y: 14, width: 2, height: 1}
      shape_tags: {class: "edit", value: DEFAULTS.shape_tags, config: true, x: 2, y: 14, width: 5, height: 1}
      layer_label: {class: "label", label: "Layer offset:", x: 7, y: 14, width: 2, height: 1}
      layer_offset: {class: "intedit", value: DEFAULTS.layer_offset, config: true, min: -100, max: 100, x: 9, y: 14, width: 1, height: 1}
    }
  }

show_dialog = (script_res) ->
  input = read_clipboard!
  interface = build_interface input, script_res
  options = nil
  if ConfigHandler
    ok, loaded_options = pcall ->
      cfg = ConfigHandler interface, CONFIG_FILE, true, script_version
      cfg\read!
      cfg\updateInterface "main"
      cfg
    options = loaded_options if ok and loaded_options
    apply_dynamic_defaults interface, input, script_res
  btn, res = aegisub.dialog.display interface.main, {"Apply", "Cancel"}, {ok: "Apply", close: "Cancel"}
  aegisub.cancel! if btn != "Apply"
  if options
    pcall ->
      options\updateConfiguration res, "main"
      options\write!
  res

show_message = (title, message) ->
  aegisub.dialog.display {
    {class: "label", label: title, x: 0, y: 0, width: 60, height: 1}
    {class: "textbox", value: tostring(message or ""), x: 0, y: 1, width: 60, height: 8}
  }, {"OK"}

main = (subs, sel, active) ->
  unless sel and #sel > 0
    show_message script_name, "Select at least one dialogue line."
    aegisub.cancel!

  script_res = get_script_resolution subs
  opts = show_dialog script_res
  prepared, err = prepare_paths opts.input or "", opts, script_res
  unless prepared
    show_message "#{script_name} - invalid AE mask data", err
    aegisub.cancel!

  if opts.frame_mode == "Create keyframe ranges"
    _, apply_err = apply_frame_ranges subs, sel, prepared, opts
  else
    _, apply_err = apply_static subs, sel, prepared, opts

  if apply_err
    show_message "#{script_name} - nothing changed", apply_err
    aegisub.cancel!

  aegisub.set_undo_point "#{script_name} / #{opts.output_mode}"

validate = (subs, sel) -> sel and #sel > 0
if depctrl and depctrl.registerMacro
  depctrl\registerMacro script_name, script_description, main, validate, nil, false
else
  aegisub.register_macro script_name, script_description, main, validate
