export script_name        = "Field Group Manager"
export script_description = "Group unique dialogue field values and write mapped values into another field"
export script_author      = "Kiterow"
export script_version     = "1.0.3"
export script_namespace   = "kite.FieldGroupManager"

DependencyControl = require "l0.DependencyControl"
depctrl = DependencyControl{
  feed: "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
}

MIXED_MARK = "<mixed>"
EMPTY_MARK = "<empty>"
NO_GROUPS_MARK = "<no groups>"

FIELDS = {
  { label: "Effect",   key: "effect",     kind: "string" }
  { label: "Layer",    key: "layer",      kind: "number", min: 0 }
  { label: "Actor",    key: "actor",      kind: "string" }
  { label: "Style",    key: "style",      kind: "string" }
  { label: "Text",     key: "text",       kind: "string" }
  { label: "Start",    key: "start_time", kind: "time" }
  { label: "End",      key: "end_time",   kind: "time" }
  { label: "Margin L", key: "margin_l",   kind: "number", min: 0 }
  { label: "Margin R", key: "margin_r",   kind: "number", min: 0 }
  { label: "Margin V", key: "margin_t",   kind: "number", min: 0, alt_key: "margin_v" }
  { label: "Comment",  key: "comment",    kind: "bool" }
}

FIELD_LABELS = {}
for field in *FIELDS
  table.insert FIELD_LABELS, field.label

SCOPES = { "Selection", "Whole script" }
MODES = { "Parallel list", "Single value" }

trim = (value) ->
  text = tostring(value or "")
  text = text\gsub "^%s+", ""
  text = text\gsub "%s+$", ""
  text

string_value = (value) ->
  if value == nil then "" else tostring value

bool_key = (value) ->
  if value then "1" else "0"

choice_or_default = (value, items, default_value) ->
  for item in *items
    return item if value == item
  default_value

find_field = (label) ->
  for field in *FIELDS
    return field if field.label == label
  FIELDS[1]

is_dialogue = (line) ->
  type(line) == "table" and (line.class == nil or line.class == "dialogue")

ass_time = (ms) ->
  total_cs = math.max 0, math.floor(((tonumber(ms) or 0) / 10) + 0.5)
  cs = total_cs % 100
  total_s = math.floor total_cs / 100
  s = total_s % 60
  total_m = math.floor total_s / 60
  m = total_m % 60
  h = math.floor total_m / 60
  string.format "%d:%02d:%02d.%02d", h, m, s, cs

parse_time = (value) ->
  text = trim value
  return 0 if text == ""
  return tonumber text if text\match "^%d+$"

  h, m, s, cs = text\match "^(%d+):(%d%d):(%d%d)%.(%d%d)$"
  if h
    return nil, "use minutes and seconds below 60" if tonumber(m) >= 60 or tonumber(s) >= 60
    return (((tonumber(h) * 60 + tonumber(m)) * 60 + tonumber(s)) * 1000) + tonumber(cs) * 10

  m2, s2, cs2 = text\match "^(%d+):(%d%d)%.(%d%d)$"
  if m2
    return nil, "use seconds below 60" if tonumber(s2) >= 60
    return ((tonumber(m2) * 60 + tonumber(s2)) * 1000) + tonumber(cs2) * 10

  nil, "use h:mm:ss.cc, mm:ss.cc, or milliseconds"

parse_bool = (value) ->
  text = trim(value)\lower!
  return true if text == "1" or text == "true" or text == "yes" or text == "y" or text == "si" or text == "comment" or text == "commented"
  return false if text == "0" or text == "false" or text == "no" or text == "n" or text == "dialogue" or text == "dialog"
  nil, "use Comment/Dialogue, yes/no, true/false, or 1/0"

read_raw_field = (line, field) ->
  value = line[field.key]
  if value == nil and field.alt_key
    value = line[field.alt_key]
  value

field_text = (line, field) ->
  value = read_raw_field line, field
  if field.kind == "time"
    ass_time value
  elseif field.kind == "number"
    tostring(tonumber(value) or 0)
  elseif field.kind == "bool"
    if value then "Comment" else "Dialogue"
  else
    string_value value

display_group_value = (value) ->
  if value == "" then EMPTY_MARK else value

parse_target_value = (field, value) ->
  if field.kind == "time"
    parsed, err = parse_time value
    return nil, err unless parsed != nil
    parsed, nil
  elseif field.kind == "number"
    text = trim value
    text = "0" if text == ""
    return nil, "use a numeric value" unless text\match "^%-?%d+$"
    number = tonumber text
    if field.min != nil and number < field.min
      return nil, "use a value of #{field.min} or higher"
    number, nil
  elseif field.kind == "bool"
    parsed, err = parse_bool value
    return nil, err unless parsed != nil
    parsed, nil
  else
    string_value(value), nil

write_field = (line, field, value) ->
  line[field.key] = value
  if field.key == "margin_t"
    line.margin_v = value
  line

parse_lines = (value) ->
  text = tostring(value or "")
  text = text\gsub "\r\n", "\n"
  text = text\gsub "\r", "\n"
  rows = {}
  pos = 1
  while true
    next_pos = text\find "\n", pos, true
    unless next_pos
      table.insert rows, text\sub(pos)
      break
    table.insert rows, text\sub(pos, next_pos - 1)
    pos = next_pos + 1
  rows

collect_indexes = (subs, sel, state) ->
  indexes = {}
  add_index = (idx) ->
    line = subs[idx]
    if is_dialogue(line) and (state.include_comments or not line.comment)
      table.insert indexes, idx

  if state.scope == "Whole script"
    for idx = 1, #subs
      add_index idx
  else
    for idx in *(sel or {})
      add_index idx
  indexes

group_compare = (field) ->
  (a, b) ->
    if field.kind == "number" or field.kind == "time"
      return (tonumber(a.sort_value) or 0) < (tonumber(b.sort_value) or 0)
    a.value < b.value

collect_groups = (subs, indexes, source_field, state) ->
  groups = {}
  seen = {}
  for idx in *indexes
    line = subs[idx]
    source = field_text line, source_field
    if source != "" or state.include_empty_source
      group = seen[source]
      unless group
        group = { value: source, sort_value: read_raw_field(line, source_field), indexes: {} }
        seen[source] = group
        table.insert groups, group
      table.insert group.indexes, idx
  table.sort groups, group_compare source_field
  groups

target_summary = (subs, group, target_field) ->
  values = {}
  seen = {}
  for idx in *group.indexes
    value = field_text subs[idx], target_field
    unless seen[value]
      seen[value] = true
      table.insert values, value
  if #values == 0
    "", false
  elseif #values == 1
    values[1], false
  else
    MIXED_MARK, true

build_list_texts = (subs, groups, target_field) ->
  source_rows = {}
  target_rows = {}
  if #groups == 0
    return NO_GROUPS_MARK, ""
  for group in *groups
    table.insert source_rows, display_group_value group.value
    summary = target_summary subs, group, target_field
    table.insert target_rows, summary
  table.concat(source_rows, "\n"), table.concat(target_rows, "\n")

state_signature = (state) ->
  table.concat {
    state.source
    state.target
    state.scope
    bool_key state.include_comments
    bool_key state.include_empty_source
  }, "\t"

read_state = (res, previous) ->
  {
    source: choice_or_default(res.source, FIELD_LABELS, previous.source)
    target: choice_or_default(res.target, FIELD_LABELS, previous.target)
    scope: choice_or_default(res.scope, SCOPES, previous.scope)
    mode: choice_or_default(res.mode, MODES, previous.mode)
    include_comments: res.include_comments == true
    include_empty_source: res.include_empty_source == true
    single_value: string_value res.single_value
  }

show_message = (message) ->
  msg = tostring message
  lines = 0
  max_len = 0
  for line in (msg .. "\n")\gmatch "(.-)\n"
    lines += 1
    max_len = #line if #line > max_len
  if lines > 4 or max_len > 70 or #msg > 180
    width = math.max 45, math.min(90, math.floor(max_len / 2) + 8)
    height = math.max 8, math.min(26, lines + 4)
    aegisub.dialog.display { { class: "textbox", text: msg, x: 0, y: 0, width: width, height: height } }, { "OK" }
  else
    width = math.max 30, math.min(70, max_len + 4)
    height = math.max 3, math.min(8, lines + 2)
    aegisub.dialog.display { { class: "label", label: msg, x: 0, y: 0, width: width, height: height } }, { "OK" }

build_dialog = (state, source_text, target_text, group_count, line_count) ->
  list_height = math.max 8, math.min 20, math.max(group_count, 1)
  y_lists = 4
  y_single = y_lists + list_height + 1
  {
    { class: "label",    label: "Group by",       x: 0,  y: 0, width: 3, height: 1 }
    { class: "dropdown", name: "source",          x: 3,  y: 0, width: 5, height: 1, items: FIELD_LABELS, value: state.source }
    { class: "label",    label: "Write field",    x: 8,  y: 0, width: 4, height: 1 }
    { class: "dropdown", name: "target",          x: 12, y: 0, width: 5, height: 1, items: FIELD_LABELS, value: state.target }
    { class: "label",    label: "Mode",           x: 17, y: 0, width: 2, height: 1 }
    { class: "dropdown", name: "mode",            x: 19, y: 0, width: 6, height: 1, items: MODES, value: state.mode }

    { class: "label",    label: "Scope",          x: 0,  y: 1, width: 3, height: 1 }
    { class: "dropdown", name: "scope",           x: 3,  y: 1, width: 5, height: 1, items: SCOPES, value: state.scope }
    { class: "checkbox", name: "include_comments", label: "Include comments", x: 8,  y: 1, width: 7, height: 1, value: state.include_comments }
    { class: "checkbox", name: "include_empty_source", label: "Include empty source", x: 15, y: 1, width: 8, height: 1, value: state.include_empty_source }

    { class: "label", label: "Groups: #{group_count} / Lines: #{line_count}", x: 0, y: 2, width: 25, height: 1 }

    { class: "label",   label: "Grouped values",       x: 0,  y: 3, width: 15, height: 1 }
    { class: "label",   label: "New values",           x: 15, y: 3, width: 15, height: 1 }
    { class: "textbox", name: "source_list", text: source_text, x: 0,  y: y_lists, width: 15, height: list_height }
    { class: "textbox", name: "dest",        text: target_text, x: 15, y: y_lists, width: 15, height: list_height }

    { class: "label", label: "Single value", x: 0, y: y_single, width: 4, height: 1 }
    { class: "edit",  name: "single_value", value: state.single_value, x: 4, y: y_single, width: 26, height: 1 }
    { class: "label", label: "#{MIXED_MARK} in the right list is skipped unless edited.", x: 0, y: y_single + 1, width: 30, height: 1 }
  }

prepare_parallel_tasks = (subs, groups, target_field, dest_text) ->
  rows = parse_lines dest_text
  if #rows < #groups
    return nil, "The right list has fewer rows than the grouped list."
  for idx = #groups + 1, #rows
    if trim(rows[idx]) != ""
      return nil, "The right list has extra non-empty rows."

  tasks = {}
  skipped = 0
  for idx, group in ipairs groups
    row = rows[idx]
    if row == nil
      skipped += 1
    elseif row == MIXED_MARK
      _, is_mixed = target_summary subs, group, target_field
      if is_mixed
        skipped += 1
      else
        value, err = parse_target_value target_field, row
        return nil, "Row #{idx} (#{display_group_value group.value}): #{err}" if err
        table.insert tasks, { group: group, value: value }
    else
      value, err = parse_target_value target_field, row
      return nil, "Row #{idx} (#{display_group_value group.value}): #{err}" if err
      table.insert tasks, { group: group, value: value }
  tasks, nil, skipped

prepare_single_tasks = (groups, target_field, single_value) ->
  value, err = parse_target_value target_field, single_value
  return nil, err if err
  tasks = {}
  for group in *groups
    table.insert tasks, { group: group, value: value }
  tasks, nil, 0

validate_tasks = (subs, tasks, target_field) ->
  return nil unless target_field.key == "start_time" or target_field.key == "end_time"
  for task in *tasks
    for idx in *task.group.indexes
      line = subs[idx]
      start_time = if target_field.key == "start_time" then task.value else tonumber(line.start_time) or 0
      end_time = if target_field.key == "end_time" then task.value else tonumber(line.end_time) or 0
      if start_time > end_time
        return "Line #{idx}: start time would be after end time."
  nil

apply_tasks = (subs, tasks, target_field) ->
  changed_lines = 0
  changed_groups = 0
  for task in *tasks
    group_changed = false
    for idx in *task.group.indexes
      line = subs[idx]
      before = field_text line, target_field
      write_field line, target_field, task.value
      after = field_text line, target_field
      if after != before
        changed_lines += 1
        group_changed = true
      subs[idx] = line
    changed_groups += 1 if group_changed
  changed_groups, changed_lines

field_group_manager = (subs, sel) ->
  state = {
    source: "Effect"
    target: "Layer"
    scope: if sel and #sel > 0 then "Selection" else "Whole script"
    mode: "Parallel list"
    include_comments: true
    include_empty_source: false
    single_value: ""
  }

  while true
    source_field = find_field state.source
    target_field = find_field state.target
    indexes = collect_indexes subs, sel, state
    groups = collect_groups subs, indexes, source_field, state
    source_text, target_text = build_list_texts subs, groups, target_field
    signature = state_signature state
    if state.dest != nil
      target_text = state.dest
    dialog = build_dialog state, source_text, target_text, #groups, #indexes
    button, res = aegisub.dialog.display dialog, { "Apply", "Refresh list", "Cancel" }, { ok: "Apply", close: "Cancel" }
    return unless button and button != "Cancel"

    new_state = read_state res, state
    if button == "Refresh list" or state_signature(new_state) != signature
      new_state.dest = nil
      state = new_state
      continue

    if #groups == 0
      show_message "No grouped values were found with the current options."
      new_state.dest = nil
      state = new_state
      continue

    tasks, err, skipped = nil, nil, 0
    if new_state.mode == "Single value"
      tasks, err, skipped = prepare_single_tasks groups, target_field, new_state.single_value
    else
      tasks, err, skipped = prepare_parallel_tasks subs, groups, target_field, res.dest

    if err
      show_message err
      new_state.dest = res.dest unless new_state.mode == "Single value"
      state = new_state
      continue

    err = validate_tasks subs, tasks, target_field
    if err
      show_message err
      new_state.dest = res.dest unless new_state.mode == "Single value"
      state = new_state
      continue

    changed_groups, changed_lines = apply_tasks subs, tasks, target_field
    aegisub.set_undo_point script_name if changed_lines > 0
    show_message "Updated #{changed_groups} group(s) and #{changed_lines} line(s).\nSkipped #{skipped} group(s)."
    return

can_run = (subs, sel) ->
  true

if depctrl and depctrl.registerMacro
  depctrl\registerMacro script_name, script_description, field_group_manager, can_run, nil, false
else
  aegisub.register_macro script_name, script_description, field_group_manager, can_run