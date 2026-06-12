export script_name = "Gradient Row"
export script_description = "Create adaptive color gradients across selected lines and visible text from palettes or inline color states."
export script_author = "Kiterow"
export script_namespace = "kite.GradientRow"
export script_version = "1.6.1"

DependencyControl = require "l0.DependencyControl"
depctrl = DependencyControl{
  feed: "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
  {
    {"a-mo.LineCollection", version: "1.3.0", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"},
    {"a-mo.Line", version: "1.5.3", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"},
    {"l0.ASSFoundation", version: "0.5.0", url: "https://github.com/TypesettingTools/ASSFoundation",
      feed: "https://raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json"},
    {"arch.Perspective", version: "1.2.1", url: "https://github.com/TypesettingTools/arch1t3cht-Aegisub-Scripts",
      feed: "https://raw.githubusercontent.com/TypesettingTools/arch1t3cht-Aegisub-Scripts/main/DependencyControl.json"},
    {"SubInspector.Inspector", version: "0.6.0", url: "https://github.com/TypesettingTools/SubInspector",
      feed: "https://raw.githubusercontent.com/TypesettingTools/SubInspector/master/DependencyControl.json",
      optional: true},
  }
}

LineCollection, Line, ASS, ArchPerspective, SubInspector = depctrl\requireModules!
logger = depctrl\getLogger!
have_SubInspector = depctrl\checkOptionalModules "SubInspector.Inspector"

color_slots = {"c", "2c", "3c", "4c"}
gradient_modes = {"Horizontal", "Vertical", "Rotated", "Char Line", "Char Selection"}

color_tag_name = (slot) ->
  return "color1" if slot == "c"
  return "color2" if slot == "2c"
  return "color3" if slot == "3c"
  return "color4" if slot == "4c"
  nil

make_default_slots = ->
  slots = {}
  for slot in *color_slots
    slots[slot] = slot == "c"
  slots

read_slots = (res) ->
  slots = make_default_slots!
  if res
    for slot in *color_slots
      slots[slot] = res[slot] and true or false
  slots

normalize_gui_color = (value) ->
  value = tostring value or ""
  r, g, b = value\match "^#(%x%x)(%x%x)(%x%x)$"
  if r
    return ("#%s%s%s")\format r\upper!, g\upper!, b\upper!
  hex = value\match "&[Hh](%x+)&?"
  if hex
    hex = hex\sub -6
    if #hex == 6
      b = hex\sub 1, 2
      g = hex\sub 3, 4
      r = hex\sub 5, 6
      return ("#%s%s%s")\format r\upper!, g\upper!, b\upper!
  nil

normalize_state = (state) ->
  state or= {}
  state.mode or= "Horizontal"
  known_mode = false
  for mode in *gradient_modes
    if state.mode == mode
      known_mode = true
      break
  state.mode = "Horizontal" unless known_mode
  state.use_between = state.use_between and true or false
  state.strip = math.max(1, tonumber(state.strip) or 2)
  state.accel = math.max(0.01, tonumber(state.accel) or 1)
  state.angle = tonumber(state.angle) or 0
  defaults = make_default_slots!
  state.slots or= {}
  for slot in *color_slots
    if state.slots[slot] == nil
      state.slots[slot] = defaults[slot]
    else
      state.slots[slot] = state.slots[slot] and true or false
  colors = {}
  for color in *(state.colors or {})
    normalized = normalize_gui_color color
    colors[#colors + 1] = normalized if normalized
  state.colors = colors
  if #state.colors < 2
    state.colors = {"#FFFFFF", "#FF0000"}
  state

default_state = ->
  normalize_state {
    mode: "Horizontal"
    use_between: false
    strip: 2
    accel: 1
    angle: 0
    slots: make_default_slots!
    colors: {"#FFFFFF", "#FF0000"}
  }

config_path = ->
  return nil unless aegisub.decode_path
  ok, path = pcall aegisub.decode_path, "?user/kite.GradientRow.conf"
  return path if ok and type(path) == "string" and #path > 0
  nil

serialize_state = (state) ->
  state = normalize_state state
  lines = {
    "mode=#{state.mode}"
    "use_between=#{tostring(state.use_between)}"
    "strip=#{state.strip}"
    "accel=#{state.accel}"
    "angle=#{state.angle}"
  }
  for slot in *color_slots
    lines[#lines + 1] = "slot_#{slot}=#{tostring(state.slots[slot])}"
  lines[#lines + 1] = "colors=#{table.concat state.colors, ","}"
  table.concat(lines, "\n") .. "\n"

save_state = (state) ->
  path = config_path!
  return unless path
  file = io.open path, "w"
  return unless file
  file\write serialize_state state
  file\close!

load_state = ->
  path = config_path!
  return default_state! unless path
  file = io.open path, "r"
  return default_state! unless file
  loaded = {slots: {}, colors: {}}
  for raw in file\lines!
    key, value = raw\match "^%s*([%w_]+)%s*=%s*(.-)%s*$"
    continue unless key
    switch key
      when "mode" then loaded.mode = value
      when "use_between" then loaded.use_between = value == "true"
      when "strip" then loaded.strip = tonumber value
      when "accel" then loaded.accel = tonumber value
      when "angle" then loaded.angle = tonumber value
      when "colors"
        for color in value\gmatch "[^,]+"
          normalized = normalize_gui_color color
          loaded.colors[#loaded.colors + 1] = normalized if normalized
      else
        if slot = key\match "^slot_(.+)$"
          loaded.slots[slot] = value == "true"
  file\close!
  normalize_state loaded

window_error = (message) ->
  aegisub.dialog.display {{class: "label", label: message, x: 0, y: 0, width: 1, height: 1}}, {"&Close"}, cancel: "&Close"
  aegisub.cancel!

copy_line = (line) ->
  out = {}
  out[k] = v for k, v in pairs line
  out

clamp = (value, low, high) ->
  math.max(low, math.min(high, value))

round = (value) ->
  math.floor(value + 0.5)

format_num = (value) ->
  value = tonumber value
  error "Gradient Row could not format a vector clip coordinate." unless value
  value = 0 if math.abs(value) < 0.0005
  ("%.2f")\format value

clip_bleed = 0.5
clip_cover_bleed = clip_bleed * 2

ass_color = (color) ->
  "&H%02X%02X%02X&"\format color.b, color.g, color.r

ensure_tag_block = (text) ->
  return text if text\find "^{"
  "{}#{text}"

strip_tags = (text) ->
  (text or "")\gsub "{[^}]*}", ""

is_vector_line = (text) ->
  text = tostring(text or "")
  text\find("\\p[1-9]") != nil

tag_value = (tag, fallback = 0) ->
  return tonumber(tag) or fallback unless type(tag) == "table"
  return tonumber(tag.value) or fallback if tag.value != nil
  fallback

layout_scale_for_line = (line) ->
  collection = line and line.parentCollection
  meta = collection and collection.meta or {}
  play_y = tonumber(meta.PlayResY or meta.playresy or meta.res_y)
  layout_y = tonumber(meta.LayoutResY or meta.layoutresy)
  return play_y / layout_y if play_y and layout_y and layout_y != 0
  1

position_from_text = (text) ->
  x, y = text\match "\\pos%(%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*%)"
  return tonumber(x), tonumber(y) if x
  x, y = text\match "\\move%(%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)"
  return tonumber(x), tonumber(y) if x
  nil, nil

origin_from_text = (line) ->
  x, y = line.text\match "\\org%(%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*%)"
  return {x: tonumber(x), y: tonumber(y)} if x
  x, y = position_from_text line.text
  return {x: x, y: y} if x and y
  nil

rotation_from_text = (line) ->
  rotation = nil
  for value in line.text\gmatch "\\frz?([%d%.%-]+)"
    rotation = tonumber(value) or rotation
  style = line.styleRef or line.styleref or {}
  rotation or tonumber(style.angle) or 0

rotate_point = (point, origin, angle) ->
  radians = math.rad angle
  cos_a, sin_a = math.cos(radians), math.sin(radians)
  dx, dy = point.x - origin.x, point.y - origin.y
  {
    x: origin.x + dx * cos_a - dy * sin_a
    y: origin.y + dx * sin_a + dy * cos_a
  }

number_tag = (text, tag, fallback) ->
  value = text\match "\\#{tag}([%d%.%-]+)"
  tonumber(value) or tonumber(fallback)

text_pad = (line) ->
  style = line.styleRef or line.styleref or {}
  outline = number_tag(line.text, "bord", style.outline or 0)
  shadow = number_tag(line.text, "shad", style.shadow or 0)
  outline + shadow + 2

anchored_text_bounds = (line, width, height, pad) ->
  x, y = position_from_text line.text
  return nil unless x and y and width and height

  style = line.styleRef or line.styleref or {}
  align = tonumber(line.text\match "\\an([1-9])") or tonumber(style.align) or 2
  pad or= text_pad line

  h_anchor = align % 3
  left = switch h_anchor
    when 1 then x
    when 2 then x - width / 2
    else x - width
  right = left + width

  v_anchor = math.ceil(align / 3)
  top = switch v_anchor
    when 3 then y
    when 2 then y - height / 2
    else y - height
  bottom = top + height

  {left - pad, top - pad, right + pad, bottom + pad}

measured_text_bounds = (line) ->
  ok_parse, data = pcall -> ASS\parse line
  return nil unless ok_parse and data
  ok, width, height = pcall -> data\getTextExtents true
  return nil unless ok and width and height and width > 0 and height > 0
  anchored_text_bounds line, width, height, text_pad line

remove_color_tag_text = (text, slot) ->
  if slot == "c"
    text = text\gsub "\\1c%s*&[Hh]%x+&", ""
    text = text\gsub "\\c%s*&[Hh]%x+&", ""
  else
    text = text\gsub "\\#{slot}%s*&[Hh]%x+&", ""
  text

apply_color_tags_text = (text, slots, color) ->
  text = ensure_tag_block text
  prefix = ""
  for slot in *color_slots
    if slots[slot]
      text = remove_color_tag_text text, slot
      tag_text = if slot == "c" then "\\c#{ass_color color}" else "\\#{slot}#{ass_color color}"
      prefix ..= tag_text
  text\gsub "^{", "{#{prefix}"

rough_text_bounds = (line) ->
  style = line.styleRef or line.styleref or {}
  visible = strip_tags line.text
  char_count = math.max(1, #visible)
  fs = number_tag(line.text, "fs", style.fontsize or 40)
  fscx = number_tag(line.text, "fscx", style.scale_x or 100) / 100
  fscy = number_tag(line.text, "fscy", style.scale_y or 100) / 100

  width = math.max(fs * 0.75, char_count * fs * 0.58 * fscx)
  height = fs * 1.15 * fscy
  anchored_text_bounds line, width, height, text_pad line

normalize_bounds = (bounds) ->
  left, top, right, bottom = unpack bounds
  left, right = right, left if left > right
  top, bottom = bottom, top if top > bottom
  {left, top, right, bottom}

bounds_to_rect = (bounds) ->
  return nil unless bounds
  if bounds.x and bounds.y and bounds.w and bounds.h and bounds.w > 0 and bounds.h > 0
    return normalize_bounds {bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h}
  if bounds[1] and bounds[2] and bounds[1].x and bounds[1].y and bounds[2].x and bounds[2].y
    return normalize_bounds {bounds[1].x, bounds[1].y, bounds[2].x, bounds[2].y}
  left = bounds.left or bounds.l
  top = bounds.top or bounds.t
  right = bounds.right or bounds.r
  bottom = bounds.bottom or bounds.b
  if left and top and right and bottom
    return normalize_bounds {left, top, right, bottom}
  nil

drawing_local_bounds = (data) ->
  left, top, right, bottom = nil, nil, nil, nil
  data\callback (section) ->
    if section.instanceOf and section.instanceOf[ASS.Section.Drawing]
      ok, ext = pcall -> section\getExtremePoints true
      if ok and ext and ext.left and ext.top and ext.right and ext.bottom
        left = ext.left.x if not left or ext.left.x < left
        top = ext.top.y if not top or ext.top.y < top
        right = ext.right.x if not right or ext.right.x > right
        bottom = ext.bottom.y if not bottom or ext.bottom.y > bottom
  return nil unless left and top and right and bottom
  normalize_bounds {left, top, right, bottom}

rect_clip_from_text = (text) ->
  x1, y1, x2, y2 = text\match "\\i?clip%(%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*%)"
  return nil unless x1
  normalize_bounds {tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)}

rect_clip_tag = (bounds) ->
  left, top, right, bottom = unpack normalize_bounds bounds
  "\\clip(#{math.floor(left)},#{math.floor(top)},#{math.ceil(right)},#{math.ceil(bottom)})"

rect_points = (bounds) ->
  left, top, right, bottom = unpack normalize_bounds bounds
  {
    {x: left, y: top}
    {x: right, y: top}
    {x: right, y: bottom}
    {x: left, y: bottom}
  }

vector_clip_tag = (points) ->
  "\\clip(m #{format_num points[1].x} #{format_num points[1].y} l #{format_num points[2].x} #{format_num points[2].y} l #{format_num points[3].x} #{format_num points[3].y} l #{format_num points[4].x} #{format_num points[4].y})"

lerp_point = (a, b, factor) ->
  {
    x: a.x + (b.x - a.x) * factor
    y: a.y + (b.y - a.y) * factor
  }

point_distance = (a, b) ->
  dx, dy = b.x - a.x, b.y - a.y
  math.sqrt dx * dx + dy * dy

normalize_vector = (x, y) ->
  length = math.sqrt x * x + y * y
  return {x: 0, y: 0} if length < 0.0005
  {x: x / length, y: y / length}

outward_edge_normal = (a, b) ->
  normalize_vector b.y - a.y, -(b.x - a.x)

offset_edge = (a, b, amount) ->
  normal = outward_edge_normal a, b
  {
    {x: a.x + normal.x * amount, y: a.y + normal.y * amount}
    {x: b.x + normal.x * amount, y: b.y + normal.y * amount}
  }

line_intersection = (a1, a2, b1, b2) ->
  dax, day = a2.x - a1.x, a2.y - a1.y
  dbx, dby = b2.x - b1.x, b2.y - b1.y
  denominator = dax * dby - day * dbx
  return nil if math.abs(denominator) < 0.0005
  t = ((b1.x - a1.x) * dby - (b1.y - a1.y) * dbx) / denominator
  {x: a1.x + dax * t, y: a1.y + day * t}

expand_quad_screen = (quad, pad_x, pad_y) ->
  return quad unless quad and #quad >= 4
  pads = {pad_y, pad_x, pad_y, pad_x}
  edges = {}
  for i = 1, 4
    next_i = i == 4 and 1 or i + 1
    edges[i] = offset_edge quad[i], quad[next_i], pads[i]
  expanded = {}
  for i = 1, 4
    prev_i = i == 1 and 4 or i - 1
    point = line_intersection edges[prev_i][1], edges[prev_i][2], edges[i][1], edges[i][2]
    unless point
      prev_normal = outward_edge_normal quad[prev_i], quad[i]
      next_i = i == 4 and 1 or i + 1
      next_normal = outward_edge_normal quad[i], quad[next_i]
      point = {
        x: quad[i].x + prev_normal.x * pads[prev_i] + next_normal.x * pads[i]
        y: quad[i].y + prev_normal.y * pads[prev_i] + next_normal.y * pads[i]
      }
    expanded[i] = point
  expanded

extract_vector_points = (data) ->
  clip_table = data\getTags "clip_vect"
  return {} if #clip_table == 0
  points = {}
  for contour in *clip_table[1].contours
    for command in *contour.commands
      got_points = false
      if command.getPoints
        ok, command_points = pcall -> command\getPoints true
        if ok and command_points
          for point in *command_points
            x, y = tonumber(point.x), tonumber(point.y)
            if x and y
              points[#points + 1] = {:x, :y}
              got_points = true
      unless got_points
        x, y = command\get!
        if x and y
          points[#points + 1] = {:x, :y}
  points

bounds_from_points = (points) ->
  return nil if #points == 0
  left, top, right, bottom = points[1].x, points[1].y, points[1].x, points[1].y
  for point in *points
    left = math.min(left, point.x)
    top = math.min(top, point.y)
    right = math.max(right, point.x)
    bottom = math.max(bottom, point.y)
  {left, top, right, bottom}

try_parse_line = (line) ->
  ok, data = pcall -> ASS\parse line
  return data if ok
  nil, data

project_local_points = nil

warn_perspective = (line, warnings) ->
  return unless warnings
  for warning in *warnings
    name, detail = warning[1], warning[2]
    switch name
      when "zero_size"
        logger\warn "Gradient Row: text has zero size; perspective clips may be inaccurate."
      when "text_and_drawings"
        logger\warn "Gradient Row: line mixes text and drawings; perspective clips may be inaccurate."
      when "move"
        logger\warn "Gradient Row: line uses \\move; perspective clips use the prepared position only."
      when "multiple_tags"
        logger\warn "Gradient Row: tag \\#{detail} appears multiple times; perspective clips may be inaccurate."
      when "transform"
        logger\warn "Gradient Row: tag \\#{detail} is used inside \\t; perspective clips may be inaccurate."

prepare_perspective_line = (line) ->
  data = try_parse_line line
  return nil unless data
  ok, tags, width, height, warnings = pcall -> ArchPerspective.prepareForPerspective ASS, data
  return nil unless ok and tags and width and height
  warn_perspective line, warnings
  data, tags, width, height

screen_padding_for_line = (line, tags) ->
  blur = number_tag line.text, "blur", 0
  blur_pad = math.abs(tonumber(blur) or 0) * 2
  pad_x = math.max(math.abs(tag_value(tags.outline_x)), math.abs(tag_value(tags.shadow_x)), 0) + blur_pad + 4
  pad_y = math.max(math.abs(tag_value(tags.outline_y)), math.abs(tag_value(tags.shadow_y)), 0) + blur_pad + 4
  pad_x, pad_y

base_local_rect_for_perspective = (data, width, height) ->
  bounds = drawing_local_bounds data
  bounds or {0, 0, math.max(width, 0.01), math.max(height, 0.01)}

projected_quad_for_line = (line, data, tags, width, height, layout_scale) ->
  bounds = base_local_rect_for_perspective data, width, height
  quad = project_local_points tags, width, height, rect_points(bounds), layout_scale
  return nil unless quad and #quad == 4
  pad_x, pad_y = screen_padding_for_line line, tags
  expand_quad_screen quad, pad_x, pad_y

subinspector_bounds = (sub, line) ->
  return nil unless have_SubInspector and SubInspector
  assi, msg = SubInspector sub
  return nil unless assi
  probe = copy_line line
  probe.assi_exhaustive = true
  bounds, times = assi\getBounds {probe}
  return nil unless bounds and bounds[1]
  b = bounds[1]
  bounds_to_rect b

line_bounds = (sub, line) ->
  if bounds = rect_clip_from_text line.text
    return bounds

  data, parse_err = try_parse_line line
  if data
    if points = extract_vector_points data
      if #points > 0
        return bounds_from_points points

    data\removeTags {"clip_rect", "iclip_rect", "clip_vect", "iclip_vect"}
    bounds = data\getLineBounds false, true
    if rect = bounds_to_rect bounds
      return rect

  if bounds = subinspector_bounds sub, line
    return bounds

  if bounds = measured_text_bounds line
    return bounds

  if bounds = rough_text_bounds line
    return bounds

  if parse_err
    logger\warn "ASSFoundation could not parse line for bounds: #{parse_err}"
  window_error "Could not determine a clip or rendered text area for the selected line."

parse_color = (value) ->
  value = tostring(value or "#FFFFFF")
  r, g, b = value\match "^#(%x%x)(%x%x)(%x%x)$"
  unless r
    b, g, r = value\match "^&H(%x%x)(%x%x)(%x%x)&$"
  unless r
    r, g, b = "FF", "FF", "FF"
  r: tonumber(r, 16), g: tonumber(g, 16), b: tonumber(b, 16)

interpolate_color = (a, b, factor) ->
  factor = clamp factor, 0, 1
  {
    r: round(a.r + (b.r - a.r) * factor)
    g: round(a.g + (b.g - a.g) * factor)
    b: round(a.b + (b.b - a.b) * factor)
  }

palette_color = (colors, factor) ->
  factor = clamp factor, 0, 1
  return colors[1] if #colors == 1
  scaled = factor * (#colors - 1)
  index = math.floor(scaled) + 1
  return colors[#colors] if index >= #colors
  interpolate_color colors[index], colors[index + 1], scaled - math.floor(scaled)

interpolation_factor = (index, total, accel) ->
  return 1 if total < 2
  ((index - 1) ^ accel) / ((total - 1) ^ accel)

boundary_delta = (a, b) ->
  return nil unless a and b and a[1] and a[2] and b[1] and b[2]
  math.max point_distance(a[1], b[1]), point_distance(a[2], b[2])

shift_boundary_t = (boundary_at, t, direction, max_step, amount = clip_bleed) ->
  return t if amount <= 0 or max_step <= 0
  base = boundary_at t
  return t unless base and base[1] and base[2]
  low, high = 0, max_step
  for _ = 1, 12
    mid = (low + high) / 2
    candidate_t = clamp t + direction * mid, 0, 1
    candidate = boundary_at candidate_t
    delta = boundary_delta base, candidate
    if delta and delta <= amount
      low = mid
    else
      high = mid
  clamp t + direction * low, 0, 1

create_rect_clips = (bounds, mode, strip) ->
  bounds = normalize_bounds bounds
  left, top, right, bottom = unpack bounds
  span = mode == "Vertical" and bottom - top or right - left
  sections = math.max(1, math.ceil(span / strip))
  clips = {}
  for i = 1, sections
    start_off = (i - 1) * strip
    end_off = i == sections and span or i * strip
    if mode == "Vertical"
      y1 = top + start_off
      y2 = top + end_off
      y1 -= clip_bleed if i > 1
      y2 += clip_bleed if i < sections
      clips[#clips + 1] = rect_clip_tag {left, y1, right, y2}
    else
      x1 = left + start_off
      x2 = left + end_off
      x1 -= clip_bleed if i > 1
      x2 += clip_bleed if i < sections
      clips[#clips + 1] = rect_clip_tag {x1, top, x2, bottom}
  clips

create_quad_clips = (points, mode, strip) ->
  return nil unless points and #points >= 4
  quad = {points[1], points[2], points[3], points[4]}
  span = if mode == "Vertical"
    (point_distance(quad[1], quad[4]) + point_distance(quad[2], quad[3])) / 2
  else
    (point_distance(quad[1], quad[2]) + point_distance(quad[4], quad[3])) / 2
  return nil if span <= 0.0005
  sections = math.max 1, math.ceil(span / math.max(1, strip))
  step_t = 1 / sections
  boundary_at = (t) ->
    if mode == "Vertical"
      {lerp_point(quad[1], quad[4], t), lerp_point(quad[2], quad[3], t)}
    else
      {lerp_point(quad[1], quad[2], t), lerp_point(quad[4], quad[3], t)}
  clips = {}
  for i = 1, sections
    t1 = (i - 1) / sections
    t2 = i / sections
    t2 = shift_boundary_t boundary_at, t2, 1, step_t / 2, clip_cover_bleed if i < sections
    if mode == "Vertical"
      top = boundary_at t1
      bottom = boundary_at t2
      clips[#clips + 1] = vector_clip_tag {top[1], top[2], bottom[2], bottom[1]}
    else
      left = boundary_at t1
      right = boundary_at t2
      clips[#clips + 1] = vector_clip_tag {left[1], right[1], right[2], left[2]}
  clips

project_point = (point, axis) ->
  point.x * axis.x + point.y * axis.y

point_on_strip = (axis, perp, along, across) ->
  {
    x: axis.x * along + perp.x * across
    y: axis.y * along + perp.y * across
  }

matrix_point = (point) ->
  return nil unless point
  x, y = tonumber(point.x), tonumber(point.y)
  if x == nil and type(point) == "table"
    x = tonumber point[1]
  if y == nil and type(point) == "table"
    y = tonumber point[2]
  if (x == nil or y == nil) and type(point) == "table"
    unless x
      ok_x, value_x = pcall -> point\x!
      x = tonumber value_x if ok_x
    unless y
      ok_y, value_y = pcall -> point\y!
      y = tonumber value_y if ok_y
  return nil unless x and y
  {:x, :y}

project_local_points = (tags, width, height, points, layout_scale) ->
  source = [{point.x, point.y} for point in *points]
  ok, projected = pcall -> ArchPerspective.transformPoints tags, width, height, source, layout_scale
  return nil unless ok and projected
  out = {}
  for i = 1, #points
    point = matrix_point projected[i]
    return nil unless point
    out[#out + 1] = point
  out

quad_uv_point = (quad, u, v) ->
  ok, point = pcall -> quad\uv_to_xy {u, v}
  return nil unless ok and point
  matrix_point point

create_quad_mesh_clips = (points, mode, strip) ->
  return nil unless points and #points >= 4 and ArchPerspective and ArchPerspective.Quad
  ok, quad = pcall -> ArchPerspective.Quad {
    {points[1].x, points[1].y}
    {points[2].x, points[2].y}
    {points[3].x, points[3].y}
    {points[4].x, points[4].y}
  }
  return nil unless ok and quad
  span = if mode == "Vertical"
    (point_distance(points[1], points[4]) + point_distance(points[2], points[3])) / 2
  else
    (point_distance(points[1], points[2]) + point_distance(points[4], points[3])) / 2
  return nil if span <= 0.0005
  sections = math.max 1, math.ceil(span / math.max(1, strip))
  step_t = 1 / sections
  boundary_at = (t) ->
    if mode == "Vertical"
      {quad_uv_point(quad, 0, t), quad_uv_point(quad, 1, t)}
    else
      {quad_uv_point(quad, t, 0), quad_uv_point(quad, t, 1)}
  clips = {}
  for i = 1, sections
    t1 = (i - 1) / sections
    t2 = i / sections
    t2 = shift_boundary_t boundary_at, t2, 1, step_t / 2, clip_cover_bleed if i < sections
    if mode == "Vertical"
      top = boundary_at t1
      bottom = boundary_at t2
      if top[1] and top[2] and bottom[1] and bottom[2]
        clips[#clips + 1] = vector_clip_tag {top[1], top[2], bottom[2], bottom[1]}
    else
      left = boundary_at t1
      right = boundary_at t2
      if left[1] and left[2] and right[1] and right[2]
        clips[#clips + 1] = vector_clip_tag {left[1], right[1], right[2], left[2]}
  clips

valid_point = (point) ->
  point and type(point.x) == "number" and type(point.y) == "number"

create_rotated_clips = (points, strip, angle) ->
  angle = tonumber(angle) or 0
  window_error "Could not create rotated clips from the selected line." unless points and #points >= 3
  for point in *points
    window_error "Could not create rotated clips from the selected line." unless valid_point point

  radians = math.rad angle
  axis = {x: math.cos(radians), y: math.sin(radians)}
  perp = {x: -math.sin(radians), y: math.cos(radians)}

  min_proj, max_proj = project_point(points[1], axis), project_point(points[1], axis)
  min_across, max_across = project_point(points[1], perp), project_point(points[1], perp)
  for point in *points
    projection = project_point point, axis
    min_proj = math.min(min_proj, projection)
    max_proj = math.max(max_proj, projection)
    across = project_point point, perp
    min_across = math.min(min_across, across)
    max_across = math.max(max_across, across)

  span = max_proj - min_proj
  sections = math.max(1, math.ceil(span / strip))
  across_pad = math.min(4, math.max(1, strip * 0.25))
  min_across -= across_pad
  max_across += across_pad
  clips = {}
  for i = 1, sections
    start_proj = min_proj + (i - 1) * strip
    end_proj = i == sections and max_proj or min_proj + i * strip
    end_proj += clip_cover_bleed if i < sections
    clips[#clips + 1] = vector_clip_tag {
      point_on_strip axis, perp, start_proj, min_across
      point_on_strip axis, perp, end_proj, min_across
      point_on_strip axis, perp, end_proj, max_across
      point_on_strip axis, perp, start_proj, max_across
    }
  clips

intersect_perpendicular = (points) ->
  x1, y1 = points[1].x, points[1].y
  x2, y2 = points[2].x, points[2].y
  x3, y3 = points[3].x, points[3].y
  denominator = (x2 - x1) ^ 2 + (y2 - y1) ^ 2
  return nil if denominator == 0
  k = ((x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1)) / denominator
  {
    x: x1 + k * (x2 - x1)
    y: y1 + k * (y2 - y1)
  }

angle_from_vector_clip = (line) ->
  data = try_parse_line line
  return nil unless data
  points = extract_vector_points data
  return nil if #points < 3
  foot = intersect_perpendicular points
  return nil unless foot
  math.deg math.atan2(points[3].y - foot.y, points[3].x - foot.x)

gradient_axis_angle = (state, line_rotation) ->
  base = switch state.mode
    when "Vertical" then 90
    when "Rotated" then state.angle
    else 0
  base - line_rotation

line_needs_projected_clips = (line) ->
  text = tostring(line.text or "")
  return true if is_vector_line text
  return true if math.abs(rotation_from_text line) >= 0.0005
  for pattern in *{"\\frx", "\\fry", "\\frz", "\\fr", "\\fax", "\\fay", "\\fscx", "\\fscy", "\\xbord", "\\ybord", "\\xshad", "\\yshad", "\\org"}
    return true if text\find pattern, 1, true
  false

projected_clip_tags_for_line = (line, state) ->
  return nil unless line_needs_projected_clips line
  data, tags, width, height = prepare_perspective_line line
  return nil unless data and tags and width and height
  layout_scale = layout_scale_for_line line
  quad = projected_quad_for_line line, data, tags, width, height, layout_scale
  return nil unless quad and #quad == 4
  clips = if state.mode == "Rotated"
    create_rotated_clips quad, math.max(1, state.strip), tonumber(state.angle) or 0
  else
    create_quad_mesh_clips(quad, state.mode, math.max(1, state.strip)) or create_quad_clips quad, state.mode, math.max(1, state.strip)
  return clips if clips and #clips > 0
  nil

explicit_clip_info = (line) ->
  if bounds = rect_clip_from_text line.text
    points = rect_points bounds
    return {:bounds, :points, is_vector_clip: false}

  data = try_parse_line line
  if data
    points = extract_vector_points data
    if points and #points > 0
      bounds = bounds_from_points points
      return {:bounds, :points, is_vector_clip: true}
  nil

gradient_points_for_line = (line, bounds) ->
  data = try_parse_line line
  if data
    points = extract_vector_points data
    return points if #points >= 4

  rotation = rotation_from_text line
  if math.abs(rotation) >= 0.0005
    text_bounds = measured_text_bounds(line) or rough_text_bounds(line)
    if text_bounds
      origin = origin_from_text line
      if origin
        return [rotate_point point, origin, -rotation for point in *rect_points text_bounds]

  rect_points bounds

clip_tags_for_line = (sub, line, state) ->
  if info = explicit_clip_info line
    strip = math.max(1, state.strip)
    line_rotation = rotation_from_text line
    if info.is_vector_clip and #info.points >= 4 and state.mode != "Rotated"
      if clips = create_quad_mesh_clips(info.points, state.mode, strip) or create_quad_clips info.points, state.mode, strip
        return clips
    if state.mode == "Rotated" or math.abs(line_rotation) >= 0.0005
      angle = angle_from_vector_clip(line) or gradient_axis_angle state, line_rotation
      return create_rotated_clips info.points, strip, angle
    return create_rect_clips info.bounds, state.mode, strip

  if clips = projected_clip_tags_for_line line, state
    return clips

  bounds = line_bounds sub, line
  strip = math.max(1, state.strip)
  line_rotation = rotation_from_text line
  if state.mode == "Rotated" or math.abs(line_rotation) >= 0.0005
    points = gradient_points_for_line line, bounds
    angle = angle_from_vector_clip(line) or gradient_axis_angle state, line_rotation
    return create_rotated_clips points, strip, angle
  create_rect_clips bounds, state.mode, strip

apply_gradient_line = (source, clip_tag, slots, color, collection) ->
  line = Line source, collection
  line.comment = false
  data, parse_err = try_parse_line line
  if data
    data\removeTags {"clip_rect", "iclip_rect", "clip_vect", "iclip_vect"}
    ok, color_err = pcall ->
      tags = {}
      for slot in *color_slots
        if slots[slot]
          tag_name = color_tag_name slot
          error "Unknown color slot: #{slot}" unless tag_name
          tags[#tags + 1] = ASS\createTag tag_name, color.b, color.g, color.r
      data\replaceTags tags if #tags > 0
      data\commit!
    unless ok
      logger\warn "ASSFoundation could not replace color tags; using text fallback: #{color_err}"
      line.text = line.text\gsub "\\i?clip%b()", ""
      line.text = apply_color_tags_text line.text, slots, color
  else
    logger\warn "ASSFoundation could not parse line for color replacement; using text fallback: #{parse_err}"
    line.text = line.text\gsub "\\i?clip%b()", ""
    line.text = apply_color_tags_text line.text, slots, color
  line.text = ensure_tag_block line.text
  line.text = line.text\gsub "^{", "{#{clip_tag}"
  line

first_tag_block = (text) ->
  tostring(text or "")\match("^({[^}]*})") or ""

remove_selected_color_tags = (text, active_slots) ->
  for slot in *active_slots
    text = remove_color_tag_text text, slot
  text

remove_selected_color_tags_clean = (text, active_slots) ->
  (remove_selected_color_tags text, active_slots)\gsub "{}", ""

color_tags_for_slots = (active_slots, color) ->
  tags = {}
  for slot in *active_slots
    tag_text = if slot == "c" then "\\c#{ass_color color}" else "\\#{slot}#{ass_color color}"
    tags[#tags + 1] = tag_text
  table.concat tags

color_tag_for_slot = (slot, color) ->
  if slot == "c" then "\\c#{ass_color color}" else "\\#{slot}#{ass_color color}"

next_utf8_char = (text, pos) ->
  byte = text\byte pos
  return "", pos + 1 unless byte
  len = if byte < 0x80
    1
  elseif byte < 0xE0
    2
  elseif byte < 0xF0
    3
  else
    4
  len = 1 if pos + len - 1 > #text
  text\sub(pos, pos + len - 1), pos + len

tokenize_visible = (text) ->
  tokens, pos = {}, 1
  text = tostring(text or "")
  while pos <= #text
    char = text\sub pos, pos
    if char == "{"
      close = text\find "}", pos + 1, true
      if close
        tokens[#tokens + 1] = {type: "tag", content: text\sub(pos, close)}
        pos = close + 1
      else
        tokens[#tokens + 1] = {type: "char", content: char}
        pos += 1
    elseif char == "\\" and pos < #text
      next_char = text\sub pos + 1, pos + 1
      if next_char == "N" or next_char == "n" or next_char == "h"
        tokens[#tokens + 1] = {type: "break", content: "\\#{next_char}"}
        pos += 2
      else
        content, next_pos = next_utf8_char text, pos
        tokens[#tokens + 1] = {type: "char", :content}
        pos = next_pos
    else
      content, next_pos = next_utf8_char text, pos
      tokens[#tokens + 1] = {type: "char", :content}
      pos = next_pos
  tokens

count_char_tokens = (tokens) ->
  total = 0
  for token in *tokens
    total += 1 if token.type == "char"
  total

char_entry_for_line = (line, offset = 0) ->
  return false if is_vector_line line.text
  head = first_tag_block line.text
  body = tostring(line.text or "")\sub #head + 1
  tokens = tokenize_visible body
  char_count = count_char_tokens tokens
  return nil if char_count == 0
  {:line, :head, :tokens, :char_count, :offset}

apply_palette_to_char_entry = (entry, active_slots, palette, accel, total) ->
  total or= entry.char_count
  result, char_index = {}, 0
  for token in *entry.tokens
    switch token.type
      when "tag"
        result[#result + 1] = remove_selected_color_tags_clean token.content, active_slots
      when "break"
        result[#result + 1] = token.content
      else
        char_index += 1
        color_index = (entry.offset or 0) + char_index
        color = palette_color palette, interpolation_factor color_index, total, accel
        result[#result + 1] = "{#{color_tags_for_slots active_slots, color}}#{token.content}"
  entry.line.text = remove_selected_color_tags_clean(entry.head, active_slots) .. table.concat result
  true

parse_ass_color_value = (value) ->
  hex = tostring(value or "")\match "&[Hh](%x+)&"
  return nil unless hex
  hex = hex\sub -6
  return nil unless #hex == 6
  b = tonumber hex\sub(1, 2), 16
  g = tonumber hex\sub(3, 4), 16
  r = tonumber hex\sub(5, 6), 16
  return nil unless r and g and b
  {:r, :g, :b}

block_color_tags = (content) ->
  colors = {}
  for raw, value in tostring(content or "")\gmatch "\\([1234]-c)%s*(&[Hh]%x+&)"
    slot = if raw == "1c" then "c" else raw
    if color_tag_name slot
      color = parse_ass_color_value value
      colors[slot] = color if color
  colors

collect_between_anchors = (entries) ->
  anchors = {slot, {} for slot in *color_slots}
  for entry in *entries
    next_char = 1
    add_anchors = (content) ->
      colors = block_color_tags content
      return unless next colors
      anchor_index = entry.offset + math.max(1, math.min(next_char, entry.char_count))
      for slot, color in pairs colors
        anchors[slot][#anchors[slot] + 1] = {index: anchor_index, :color}
    add_anchors entry.head
    for token in *entry.tokens
      switch token.type
        when "tag"
          add_anchors token.content
        when "char"
          next_char += 1
  anchors

usable_slots_from_anchors = (anchors) ->
  usable = {}
  for slot in *color_slots
    list = anchors[slot] or {}
    table.sort list, (a, b) -> a.index < b.index
    compact = {}
    for anchor in *list
      if #compact > 0 and compact[#compact].index == anchor.index
        compact[#compact] = anchor
      else
        compact[#compact + 1] = anchor
    anchors[slot] = compact
    usable[#usable + 1] = slot if #compact >= 2
  usable

between_color_at = (anchors, index) ->
  return nil unless anchors and #anchors > 0
  return anchors[1].color if index <= anchors[1].index
  for i = 1, #anchors - 1
    start_anchor, end_anchor = anchors[i], anchors[i + 1]
    if index <= end_anchor.index
      span = end_anchor.index - start_anchor.index
      factor = if span <= 0 then 1 else (index - start_anchor.index) / span
      return interpolate_color start_anchor.color, end_anchor.color, factor
  anchors[#anchors].color

between_color_tags = (usable_slots, anchors, index) ->
  tags = {}
  for slot in *usable_slots
    if color = between_color_at anchors[slot], index
      tags[#tags + 1] = color_tag_for_slot slot, color
  table.concat tags

apply_between_to_char_entry = (entry, usable_slots, anchors) ->
  result, char_index = {}, 0
  for token in *entry.tokens
    switch token.type
      when "tag"
        result[#result + 1] = remove_selected_color_tags_clean token.content, usable_slots
      when "break"
        result[#result + 1] = token.content
      else
        char_index += 1
        global_index = (entry.offset or 0) + char_index
        result[#result + 1] = "{#{between_color_tags usable_slots, anchors, global_index}}#{token.content}"
  entry.line.text = remove_selected_color_tags_clean(entry.head, usable_slots) .. table.concat result
  true

collect_char_entries = (sub, sel, global_offsets = false) ->
  entries, total = {}, 0
  for index in *sel
    line = copy_line sub[index]
    if line and (line.class == nil or line.class == "dialogue")
      offset = if global_offsets then total else 0
      if entry = char_entry_for_line line, offset
        entry.index = index
        entries[#entries + 1] = entry
        total += entry.char_count
  entries, total

apply_palette_char_line = (sub, sel, active_slots, palette, state) ->
  entries = collect_char_entries sub, sel, false
  changed = false
  for entry in *entries
    aegisub.cancel! if aegisub.progress.is_cancelled!
    if apply_palette_to_char_entry entry, active_slots, palette, state.accel, entry.char_count
      sub[entry.index] = entry.line
      changed = true
  logger\warn "Gradient Row: no visible text characters found for Char Line." unless changed
  sel

apply_palette_char_selection = (sub, sel, active_slots, palette, state) ->
  entries, total = collect_char_entries sub, sel, true
  changed = false
  for entry in *entries
    aegisub.cancel! if aegisub.progress.is_cancelled!
    if apply_palette_to_char_entry entry, active_slots, palette, state.accel, total
      sub[entry.index] = entry.line
      changed = true
  logger\warn "Gradient Row: no visible text characters found for Char Selection." unless changed
  sel

apply_between_char_line = (sub, sel) ->
  changed = false
  for index in *sel
    aegisub.cancel! if aegisub.progress.is_cancelled!
    line = copy_line sub[index]
    if line and (line.class == nil or line.class == "dialogue")
      if entry = char_entry_for_line line, 0
        anchors = collect_between_anchors {entry}
        usable_slots = usable_slots_from_anchors anchors
        if #usable_slots > 0 and apply_between_to_char_entry entry, usable_slots, anchors
          sub[index] = entry.line
          changed = true
  logger\warn "Gradient Row: Use colors between letters found no channel with at least two color states." unless changed
  sel

apply_between_char_selection = (sub, sel) ->
  entries = collect_char_entries sub, sel, true
  anchors = collect_between_anchors entries
  usable_slots = usable_slots_from_anchors anchors
  unless #usable_slots > 0
    logger\warn "Gradient Row: Use colors between letters found no channel with at least two color states."
    return sel
  for entry in *entries
    aegisub.cancel! if aegisub.progress.is_cancelled!
    if apply_between_to_char_entry entry, usable_slots, anchors
      sub[entry.index] = entry.line
  sel

apply_char_gradient = (sub, sel, active_slots, palette, state) ->
  if state.use_between
    return if state.mode == "Char Selection" then apply_between_char_selection sub, sel else apply_between_char_line sub, sel
  if state.mode == "Char Selection"
    apply_palette_char_selection sub, sel, active_slots, palette, state
  else
    apply_palette_char_line sub, sel, active_slots, palette, state

collect_sources = (sub, sel) ->
  collection = LineCollection sub, sel, ((line) -> line.class == "dialogue"), false
  by_index = {line.number, line for line in *collection.lines}
  sources = {}
  for selected_index in *sel
    source = by_index[selected_index]
    unless source
      source = Line sub[selected_index], collection
      source.number = selected_index
    sources[#sources + 1] = {index: selected_index, line: source}
  sources, collection

collect_active_slots = (slots) ->
  active = [slot for slot in *color_slots when slots[slot]]
  window_error "Select at least one color slot." if #active == 0
  active

build_gui = (state, x = 8.5) ->
  state = normalize_state state
  gui = {
    {class: "label", label: "Gradient Type:", :x, y: 0}
    {class: "dropdown", name: "mode", items: gradient_modes, value: state.mode, :x, y: 1, width: 3}
    {class: "checkbox", name: "use_between", label: "Use colors between letters", value: state.use_between, :x, y: 2, width: 3}
    {class: "label", label: "Pixels per strip:", :x, y: 4}
    {class: "intedit", name: "strip", min: 1, value: state.strip, step: 1, :x, y: 5, width: 3}
    {class: "label", label: "Acceleration:", :x, y: 6}
    {class: "floatedit", name: "accel", min: 0.01, value: state.accel, :x, y: 7, width: 3}
    {class: "label", label: "Angle:", :x, y: 8}
    {class: "floatedit", name: "angle", value: state.angle, :x, y: 9, width: 3}
    {class: "label", label: "Color slots:", :x, y: 11}
  }
  for i, slot in ipairs color_slots
    gui[#gui + 1] = {class: "checkbox", name: slot, label: "\\#{slot}", value: state.slots[slot], :x, y: 11 + i}
  colors_y = 13 + #color_slots
  gui[#gui + 1] = {class: "label", label: "Colors:", :x, y: colors_y}
  for i, color in ipairs state.colors
    gui[#gui + 1] = {class: "color", name: "color#{i}", value: color, :x, y: colors_y + i * 2 - 1, width: 3, height: 2}
  gui

read_state = (res, color_count) ->
  state = {}
  state.mode = res.mode
  state.use_between = res.use_between and true or false
  state.strip = res.strip
  state.accel = res.accel
  state.angle = res.angle
  state.slots = read_slots res
  state.colors = {}
  for i = 1, color_count
    state.colors[i] = res["color#{i}"] or "#FFFFFF"
  normalize_state state

create_dialog = ->
  state = load_state!
  while true
    gui = build_gui state
    button, res = aegisub.dialog.display gui, {"Execute", "Add+", "Rem-", "Reset", "Cancel"}, close: "Cancel"
    return nil if button == "Cancel" or not button
    if button == "Reset"
      state = default_state!
      continue
    state = read_state res, #state.colors
    switch button
      when "Add+"
        if #state.colors < 16
          state.colors[#state.colors + 1] = state.colors[#state.colors]
      when "Rem-"
        if #state.colors > 2
          table.remove state.colors
      when "Execute"
        save_state state
        return state

is_char_mode = (mode) ->
  mode == "Char Line" or mode == "Char Selection"

main = (sub, sel) ->
  state = create_dialog!
  return unless state
  state = normalize_state state
  if is_char_mode state.mode
    active_slots = if state.use_between then {} else collect_active_slots state.slots
    palette = [parse_color color for color in *state.colors]
    return apply_char_gradient sub, sel, active_slots, palette, state
  active_slots = collect_active_slots state.slots
  palette = [parse_color color for color in *state.colors]
  sources, collection = collect_sources sub, sel
  generated_selection = {}
  inserted_before = 0

  for line_no, source_info in ipairs sources
    aegisub.cancel! if aegisub.progress.is_cancelled!
    source_index = source_info.index + inserted_before
    source = source_info.line
    clips = clip_tags_for_line sub, source, state
    window_error "No gradient clips were generated." if #clips == 0

    commented = Line source, collection
    commented.comment = true
    sub[source_index] = commented
    insert_at = source_index + 1

    for i, clip_tag in ipairs clips
      aegisub.cancel! if aegisub.progress.is_cancelled!
      factor = interpolation_factor i, #clips, state.accel
      color = palette_color palette, factor
      line = apply_gradient_line source, clip_tag, state.slots, color, collection
      sub.insert insert_at, line
      generated_selection[#generated_selection + 1] = insert_at
      insert_at += 1

    inserted_before += #clips
    aegisub.progress.set math.floor(100 * line_no / #sel)

  generated_selection

validate = (sub, sel) -> #sel >= 1

depctrl\registerMacro main, validate
