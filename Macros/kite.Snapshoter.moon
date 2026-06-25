export script_name        = "Snapshoter"
export script_description = "Capture subtitle frames, frame lists, frame sequences, and rectangular crops from the loaded video"
export script_author      = "Kiterow"
export script_version     = "1.2.1"
export script_namespace   = "kite.Snapshoter"

DependencyControl = require "l0.DependencyControl"
depctrl = DependencyControl{
  feed: "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
  {
    {"a-mo.LineCollection", version: "1.3.0", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
    {"a-mo.ConfigHandler", version: "1.1.4", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
    {"a-mo.Tags", version: "1.3.4", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
    {"a-mo.Log", version: "1.0.0", url: "https://github.com/TypesettingTools/Aegisub-Motion",
      feed: "https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
    {"l0.ASSFoundation", version: "0.5.0", url: "https://github.com/TypesettingTools/ASSFoundation",
      feed: "https://raw.githubusercontent.com/TypesettingTools/ASSFoundation/master/DependencyControl.json"}
  }
}
LineCollection, ConfigHandler, Tags, log, ASS = depctrl\requireModules!

CONFIG_FILE = "kite-snapshoter.json"

isWindows = package.config\sub(1, 1) == "\\"
sep = isWindows and "\\" or "/"

CAPTURE_MODES = {
  "Selected lines"
  "Frame list"
  "Frame sequence"
  "Rectangular clip"
  "Manual rectangle"
  "Densest subtitle frame"
}

TIMING_MODES = {
  "Midpoint"
  "Start and end"
  "Start, middle, end"
}

choice_or_default = (value, items, defaultValue) ->
  for item in *items
    return item if value == item
  defaultValue

round_ms = (value) ->
  math.floor((tonumber(value) or 0) + 0.5)

trim = (value) ->
  text = tostring(value or "")
  text = text\gsub "^%s+", ""
  text = text\gsub "%s+$", ""
  text

file_exists = (path) ->
  file = io.open path, "rb"
  if file
    file\close!
    return true
  false

dir_name = (path) ->
  tostring(path or "")\match("^(.*)[\\/]") or ""

base_name = (path) ->
  name = tostring(path or "")\match("([^\\/]+)$") or tostring(path or "")
  name\gsub "%.[^%.]*$", ""

safe_name = (text, defaultValue = "snapshoter") ->
  value = trim(text)\gsub("[\\/:*?\"<>|]+", "_")\gsub("%s+", "_")
  value = value\gsub "_+", "_"
  value = value\gsub "^_+", ""
  value = value\gsub "_+$", ""
  value = value\gsub "[%.%s]+$", ""
  lower = value\lower!
  reserved = lower == "con" or lower == "prn" or lower == "aux" or lower == "nul" or lower\match("^com[1-9]$") or lower\match("^lpt[1-9]$")
  return defaultValue if value == "." or value == ".." or value\match("^%.+$") or reserved
  if value == "" then defaultValue else value

join_path = (left, right) ->
  left = tostring(left or "")
  right = tostring(right or "")
  return right if left == ""
  tail = left\sub -1
  if tail == "\\" or tail == "/"
    left .. right
  else
    left .. sep .. right

write_file = (path, content) ->
  file = io.open path, "w"
  return false unless file
  file\write content or ""
  file\close!
  true

decoded_path = (spec) ->
  return "" unless aegisub.decode_path
  ok, path = pcall aegisub.decode_path, spec
  if ok and type(path) == "string" and path != spec
    path
  else
    ""

shell_quote = (value) ->
  value = tostring(value or "")
  if isWindows
    '"' .. value\gsub('"', '""') .. '"'
  else
    "'" .. value\gsub("'", "'\\''") .. "'"

batch_escape = (value) ->
  tostring(value or "")\gsub "%%", "%%%%"

script_quote = (value) ->
  if isWindows
    shell_quote batch_escape value
  else
    shell_quote value

filter_path_quote = (value) ->
  value = tostring(value or "")\gsub "\\", "/"
  value = value\gsub ":", "\\:"
  value = value\gsub "'", "\\'"
  "'" .. value .. "'"

command_quote = (value) ->
  exe = trim(value)
  exe = "ffmpeg" if exe == ""
  script_quote exe

ensure_dir = (path) ->
  return false if trim(path) == ""
  if isWindows
    os.execute 'cmd /c if not exist ' .. shell_quote(path) .. ' mkdir ' .. shell_quote(path)
  else
    os.execute 'mkdir -p ' .. shell_quote(path)
  true

run_script = (path) ->
  if isWindows
    os.execute 'cmd /c ' .. shell_quote(path)
  else
    os.execute 'sh ' .. shell_quote(path)

command_ok = (status) ->
  status == true or status == 0

show_message = (text) ->
  aegisub.dialog.display {
    { class: "label", label: tostring(text or ""), x: 0, y: 0, width: 72, height: 4 }
  }, { "OK" }

video_path = ->
  path = decoded_path "?video"
  return path if path != "" and file_exists path
  props = aegisub.project_properties and aegisub.project_properties! or {}
  path = props.video_file or ""
  return path if path != "" and file_exists path
  nil

root_folder = (spec, video) ->
  spec = trim(spec)
  spec = "?script" if spec == ""
  path = if spec\match "^%?"
    decoded_path spec
  else
    spec
  if path != "" and file_exists path
    return dir_name path
  if path != "" and path\match "%.[^\\/%.]+$"
    folder = dir_name path
    return folder if folder != ""
  if path != "" then path else dir_name video

ass_time = (ms) ->
  ms = math.max 0, round_ms(ms)
  h = math.floor(ms / 3600000)
  m = math.floor((ms % 3600000) / 60000)
  s = math.floor((ms % 60000) / 1000)
  cs = math.floor((ms % 1000) / 10)
  string.format "%d:%02d:%02d.%02d", h, m, s, cs

file_time = (ms) ->
  ms = math.max 0, round_ms(ms)
  h = math.floor(ms / 3600000)
  m = math.floor((ms % 3600000) / 60000)
  s = math.floor((ms % 60000) / 1000)
  mm = ms % 1000
  string.format "%02d-%02d-%02d-%03d", h, m, s, mm

ffmpeg_time = (ms) ->
  string.format "%.3f", math.max(0, tonumber(ms) or 0) / 1000

clean_text = (text) ->
  text = tostring(text or "")\gsub "%b{}", ""
  text = text\gsub "\\[Nnh]", " "
  text = text\gsub "%s+", " "
  trim(text)

frame_duration_ms = (ms) ->
  frame = aegisub.frame_from_ms(ms)
  now = aegisub.ms_from_frame(frame)
  nextMs = aegisub.ms_from_frame(frame + 1)
  if nextMs and now and nextMs > now then nextMs - now else 1

current_video_frame = ->
  return nil unless aegisub.project_properties
  ok, props = pcall aegisub.project_properties
  return nil unless ok and props
  return nil if props.video_position == nil
  tonumber props.video_position

line_intervals = (lines) ->
  raw = {}
  for line in *lines
    startFrame = aegisub.frame_from_ms line.start_time
    endFrame = aegisub.frame_from_ms math.max(line.start_time, line.end_time - 1)
    if startFrame and endFrame
      endFrame = startFrame if endFrame < startFrame
      table.insert raw, { first: startFrame, last: endFrame }
  table.sort raw, (a, b) ->
    if a.first == b.first then a.last < b.last else a.first < b.first
  merged = {}
  for item in *raw
    last = merged[#merged]
    if last and item.first <= last.last + 1
      last.last = item.last if item.last > last.last
    else
      table.insert merged, { first: item.first, last: item.last }
  merged

frame_in_intervals = (frame, intervals) ->
  for item in *(intervals or {})
    return true if frame >= item.first and frame <= item.last
  false

collect_effect_frames = (lines, intervals) ->
  seen, out = {}, {}
  for line in *lines
    effect = tostring line.effect or ""
    for token in effect\gmatch "[^;,%s]+"
      raw = token\match "^[Ff]?(%d+)$"
      raw = token\match("^[Ff]?(%d+)[Ff]?$") unless raw
      if raw
        frame = tonumber raw
        if frame and frame_in_intervals(frame, intervals) and not seen[frame]
          seen[frame] = true
          table.insert out, frame
  table.sort out
  out

default_frame_list = (lines) ->
  unless lines and #lines > 0
    frame = current_video_frame!
    return if frame then { frame } else {}
  intervals = line_intervals lines
  effectFrames = collect_effect_frames lines, intervals
  return effectFrames if #effectFrames > 0
  frame = current_video_frame!
  return { frame } if frame and frame_in_intervals frame, intervals
  out = {}
  for item in *intervals
    table.insert out, item.first
  out

parse_frame_token = (token) ->
  token = trim token
  return nil if token == ""
  raw = token\match "^[Ff]?(%d+)[Ff]?$"
  if raw then tonumber raw else nil

parse_frame_list = (text) ->
  frames, seen, errors = {}, {}, {}
  for rawLine in tostring(text or "")\gmatch "[^\n]+"
    line = trim rawLine\gsub("^%-%-%s*", "")
    if line != ""
      line = line\gsub "%f[%a][Ff][Aa][Dd][Ee]%f[%A]%s+[^,%s;]+", ""
      line = line\match("^(.-)>") or line
      for token in line\gmatch "[^,%s;]+"
        frame = parse_frame_token token
        if frame
          unless seen[frame]
            seen[frame] = true
            table.insert frames, frame
        else
          table.insert errors, "Invalid frame token: #{token}"
  table.sort frames
  frames, errors

build_frame_defaults = (frames) ->
  items = {}
  for frame in *(frames or {})
    table.insert items, "#{frame}f"
  table.concat items, " "

line_points = (line, timingMode) ->
  startMs = tonumber(line.start_time) or 0
  endMs = tonumber(line.end_time) or startMs
  midMs = startMs + (endMs - startMs) / 2
  if timingMode == "Start and end"
    lastMs = math.max startMs, endMs - frame_duration_ms(endMs)
    {
      { key: "start", label: "start", time: startMs }
      { key: "end", label: "end", time: lastMs }
    }
  elseif timingMode == "Start, middle, end"
    lastMs = math.max startMs, endMs - frame_duration_ms(endMs)
    {
      { key: "start", label: "start", time: startMs }
      { key: "mid", label: "midpoint", time: midMs }
      { key: "end", label: "end", time: lastMs }
    }
  else
    {
      { key: "mid", label: "midpoint", time: midMs }
    }

selected_lines = (subs, sel) ->
  collection = LineCollection subs, sel, ((line) -> line.class == "dialogue" and not line.comment and line.end_time and line.end_time > line.start_time), true
  lines = {}
  for line in *collection.lines
    table.insert lines, line if line.end_time > line.start_time
  table.sort lines, (a, b) -> (a.number or 0) < (b.number or 0)
  collection, lines

video_size = ->
  width, height = aegisub.video_size!
  tonumber(width) or 0, tonumber(height) or 0

normalize_crop = (x, y, w, h, padding, videoW, videoH) ->
  padding = math.max 0, tonumber(padding) or 0
  x1 = math.floor((tonumber(x) or 0) - padding)
  y1 = math.floor((tonumber(y) or 0) - padding)
  x2 = math.ceil((tonumber(x) or 0) + (tonumber(w) or 0) + padding)
  y2 = math.ceil((tonumber(y) or 0) + (tonumber(h) or 0) + padding)
  x1 = math.max 0, math.min(videoW - 1, x1)
  y1 = math.max 0, math.min(videoH - 1, y1)
  x2 = math.max x1 + 1, math.min(videoW, x2)
  y2 = math.max y1 + 1, math.min(videoH, y2)
  {
    x: x1
    y: y1
    w: x2 - x1
    h: y2 - y1
  }

scale_clip_rect = (rect, collection, cfg) ->
  videoW, videoH = cfg.videoW, cfg.videoH
  playX = tonumber(collection.meta and collection.meta.PlayResX) or videoW
  playY = tonumber(collection.meta and collection.meta.PlayResY) or videoH
  sx = if playX > 0 then videoW / playX else 1
  sy = if playY > 0 then videoH / playY else 1
  x1 = math.min(rect.x1, rect.x2) * sx
  y1 = math.min(rect.y1, rect.y2) * sy
  x2 = math.max(rect.x1, rect.x2) * sx
  y2 = math.max(rect.y1, rect.y2) * sy
  normalize_crop x1, y1, x2 - x1, y2 - y1, cfg.cropPadding, videoW, videoH

manual_crop = (cfg) ->
  normalize_crop cfg.manualX, cfg.manualY, cfg.manualW, cfg.manualH, cfg.cropPadding, cfg.videoW, cfg.videoH

clip_rect_from_tags = (text) ->
  for key in *{ "rectClip", "rectiClip" }
    tag = Tags.allTags[key]
    raw = text\match tag.pattern
    if raw
      values = tag\convert raw
      x1, y1, x2, y2 = tonumber(values.xLeft), tonumber(values.yTop), tonumber(values.xRight), tonumber(values.yBottom)
      return { :x1, :y1, :x2, :y2 } if x1 and y1 and x2 and y2
  nil

line_clip_rect = (line) ->
  rect = clip_rect_from_tags line.text
  return rect if rect
  ok, data = pcall -> ASS\parse line
  return nil unless ok and data
  clips = data\getTags { "clip_rect", "iclip_rect" }
  return nil unless clips and #clips > 0
  x1, y1, x2, y2 = clips[1]\getTagParams!
  x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
  return nil unless x1 and y1 and x2 and y2
  { :x1, :y1, :x2, :y2 }

densest_frame = (lines) ->
  events = {}
  for line in *lines
    log.checkCancellation!
    startFrame = aegisub.frame_from_ms line.start_time
    endFrame = math.max startFrame, aegisub.frame_from_ms(line.end_time) - 1
    table.insert events, { frame: startFrame, delta: 1 }
    table.insert events, { frame: endFrame + 1, delta: -1 }
  table.sort events, (a, b) ->
    if a.frame == b.frame then a.delta > b.delta else a.frame < b.frame
  active, bestCount, bestFrame = 0, 0, nil
  i = 1
  while i <= #events
    frame = events[i].frame
    while i <= #events and events[i].frame == frame
      active += events[i].delta
      i += 1
    if active > bestCount
      bestCount = active
      bestFrame = frame
  bestFrame, bestCount

shot_name = (seq, line, point, mode, includeText, extra = nil) ->
  parts = {
    string.format "%04d", seq
    line and string.format("L%04d", line.number or 0) or "dense"
    point.key
    file_time(point.time)
  }
  table.insert parts, extra if extra
  if includeText and line
    label = safe_name(clean_text(line.text), "")\sub 1, 48
    table.insert parts, label if label != ""
  table.concat(parts, "_") .. ".png"

frame_shot_name = (seq, frame, time) ->
  string.format "%04d_F%06d_%s.png", seq, frame, file_time(time)

make_jobs = (collection, lines, cfg) ->
  jobs, skipped, errors, seq = {}, {}, {}, 0
  mode = cfg.mode
  if mode == "Frame list"
    frames, parseErrors = parse_frame_list cfg.frameText
    return jobs, skipped, parseErrors if #parseErrors > 0
    return jobs, skipped, { "No valid frames were listed." } if #frames == 0
    for frame in *frames
      time = aegisub.ms_from_frame frame
      if time
        seq += 1
        table.insert jobs, {
          time: time
          frame: frame
          name: frame_shot_name seq, frame, time
          subtitle: ""
          label: "frame #{frame}"
          mode: mode
        }
      else
        table.insert errors, "Could not convert frame to milliseconds: #{frame}"
    return jobs, skipped, errors

  return jobs, skipped, { "Select at least one timed dialogue line." } unless lines and #lines > 0

  manualRect = manual_crop(cfg) if mode == "Manual rectangle"
  if mode == "Densest subtitle frame"
    frame, count = densest_frame lines
    return jobs, skipped, errors unless frame
    time = aegisub.ms_from_frame(frame)
    seq += 1
    table.insert jobs, {
      time: time
      frame: frame
      name: shot_name seq, nil, { key: "dense", time: time }, mode, false, "#{count}lines"
      subtitle: ""
      label: "densest frame"
      mode: mode
      overlap: count
    }
    return jobs, skipped, errors

  for line in *lines
    log.checkCancellation!
    rect = nil
    if mode == "Rectangular clip"
      assRect = line_clip_rect line
      if assRect
        rect = scale_clip_rect assRect, collection, cfg
      else
        table.insert skipped, line.number
        continue
    elseif mode == "Manual rectangle"
      rect = manualRect

    for point in *line_points(line, cfg.timing)
      seq += 1
      extra = if rect then "crop" else nil
      table.insert jobs, {
        time: point.time
        frame: aegisub.frame_from_ms(point.time)
        name: shot_name seq, line, point, mode, cfg.includeText, extra
        subtitle: line.number
        label: point.label
        mode: mode
        crop: rect
      }
  jobs, skipped, errors

crop_filter = (crop) ->
  string.format "crop=%d:%d:%d:%d", crop.w, crop.h, crop.x, crop.y

write_capture_script = (video, outDir, ffmpeg, jobs) ->
  scriptPath = join_path outDir, "_snapshoter_capture.bat"
  logPath = join_path outDir, "_snapshoter_ffmpeg.log"
  rows = {}
  if isWindows
    table.insert rows, "@echo off"
    table.insert rows, "setlocal"
    table.insert rows, "if not exist " .. script_quote(outDir) .. " mkdir " .. script_quote(outDir)
    table.insert rows, "type nul > " .. script_quote(logPath)
  else
    scriptPath = join_path outDir, "_snapshoter_capture.sh"
    table.insert rows, "#!/bin/sh"
    table.insert rows, "mkdir -p " .. script_quote(outDir)
    table.insert rows, ": > " .. script_quote(logPath)

  for job in *jobs
    outPath = join_path outDir, job.name
    command = command_quote(ffmpeg) ..
      " -hide_banner -loglevel error -y -ss " .. ffmpeg_time(job.time) ..
      " -i " .. script_quote(video) ..
      " -frames:v 1"
    if job.crop
      command ..= " -vf " .. script_quote(crop_filter job.crop)
    command ..= " " .. script_quote(outPath)
    command ..= " >> " .. script_quote(logPath) .. " 2>&1"
    command ..= " || exit /b %ERRORLEVEL%" if isWindows
    command ..= " || exit $?" unless isWindows
    table.insert rows, command

  if isWindows
    table.insert rows, "exit /b %ERRORLEVEL%"
    table.insert rows, ""
    return nil unless write_file scriptPath, table.concat(rows, "\r\n")
  else
    return nil unless write_file scriptPath, table.concat(rows, "\n")
  scriptPath, logPath

write_manifest = (outDir, video, jobs, skipped, scriptPath, logPath) ->
  rows = { "file\tsubtitle_line\tpoint\tframe\ttime\tmode\tcrop\toverlap" }
  for job in *jobs
    crop = ""
    if job.crop
      crop = string.format "%d,%d,%d,%d", job.crop.x, job.crop.y, job.crop.w, job.crop.h
    table.insert rows, table.concat({
      job.name
      tostring(job.subtitle or "")
      job.label
      tostring(job.frame or "")
      ass_time(job.time)
      job.mode
      crop
      tostring(job.overlap or "")
    }, "\t")
  table.insert rows, ""
  table.insert rows, "video\t" .. tostring(video or "")
  table.insert rows, "capture_script\t" .. tostring(scriptPath or "")
  table.insert rows, "ffmpeg_log\t" .. tostring(logPath or "")
  if #skipped > 0
    table.insert rows, "skipped_no_rect_clip\t" .. table.concat skipped, ","
  write_file join_path(outDir, "_snapshoter_manifest.tsv"), table.concat(rows, "\n")

ass_field = (value, fallback = "") ->
  value = tostring(value or fallback)
  value = value\gsub "[\r\n]", " "
  value\gsub ",", " "

ass_text = (value) ->
  value = tostring(value or "")
  value = value\gsub "\r\n", "\\N"
  value\gsub "[\r\n]", "\\N"

ass_number = (value, fallback = 0) ->
  number = tonumber value
  if number then number else fallback

ass_int = (value, fallback = 0) ->
  math.floor(ass_number(value, fallback) + 0.5)

ass_bool = (value) ->
  if value == true
    -1
  elseif value == false or value == nil
    0
  else
    ass_int value, 0

ass_color = (value, fallback = "&H00FFFFFF&") ->
  if type(value) == "number"
    number = value
    number += 4294967296 if number < 0
    return string.format "&H%08X&", number % 4294967296
  text = trim value
  if text == "" then fallback else text

style_ass_line = (style) ->
  values = {
    ass_field style.name, "Default"
    ass_field style.fontname, "Arial"
    tostring ass_number(style.fontsize, 20)
    ass_color style.color1, "&H00FFFFFF&"
    ass_color style.color2, "&H000000FF&"
    ass_color style.color3, "&H00000000&"
    ass_color style.color4, "&H00000000&"
    tostring ass_bool(style.bold)
    tostring ass_bool(style.italic)
    tostring ass_bool(style.underline)
    tostring ass_bool(style.strikeout)
    tostring ass_number(style.scale_x, 100)
    tostring ass_number(style.scale_y, 100)
    tostring ass_number(style.spacing, 0)
    tostring ass_number(style.angle, 0)
    tostring ass_int(style.borderstyle, 1)
    tostring ass_number(style.outline, 2)
    tostring ass_number(style.shadow, 0)
    tostring ass_int(style.align, 2)
    tostring ass_int(style.margin_l, 10)
    tostring ass_int(style.margin_r, 10)
    tostring ass_int(style.margin_t or style.margin_v, 10)
    tostring ass_int(style.encoding, 1)
  }
  "Style: " .. table.concat values, ","

default_style_line = ->
  "Style: Default,Arial,20,&H00FFFFFF&,&H000000FF&,&H00000000&,&H00000000&,0,0,0,0,100,100,0,0,1,2,0,2,10,10,10,1"

dialogue_ass_line = (line, range) ->
  return nil unless line and line.class == "dialogue" and not line.comment
  lineStart = ass_int line.start_time, 0
  lineEnd = ass_int line.end_time, lineStart
  return nil if lineEnd <= range.startMs or lineStart >= range.endMs
  startMs = math.max 0, ass_int(lineStart - range.startMs, 0)
  endMs = math.min range.durationMs, ass_int(lineEnd - range.startMs, range.durationMs)
  endMs = math.min range.durationMs, math.max(startMs + 1, endMs)
  return nil if endMs <= startMs
  values = {
    "Dialogue: " .. tostring(ass_int(line.layer, 0))
    ass_time startMs
    ass_time endMs
    ass_field line.style, "Default"
    ass_field line.actor, ""
    string.format "%04d", ass_int(line.margin_l, 0)
    string.format "%04d", ass_int(line.margin_r, 0)
    string.format "%04d", ass_int(line.margin_t or line.margin_v, 0)
    ass_field line.effect, ""
    ass_text line.text
  }
  table.concat values, ","

sequence_range = (lines) ->
  intervals = line_intervals lines
  return nil unless #intervals > 0
  startFrame = intervals[1].first
  endFrame = intervals[1].last
  for item in *intervals
    startFrame = math.min startFrame, item.first
    endFrame = math.max endFrame, item.last
  startMs = aegisub.ms_from_frame startFrame
  endMs = aegisub.ms_from_frame(endFrame + 1)
  return nil unless startMs and endMs and endMs > startMs
  {
    :startFrame
    :endFrame
    frameCount: endFrame - startFrame + 1
    :startMs
    :endMs
    durationMs: endMs - startMs
  }

write_sequence_ass = (subs, assPath, range, videoW, videoH) ->
  rows = { "[Script Info]" }
  hasScriptType, hasPlayResX, hasPlayResY = false, false, false
  for i = 1, #subs
    line = subs[i]
    if line and line.class == "info" and line.key
      key = trim line.key
      value = tostring(line.value or "")
      if key != ""
        lower = key\lower!
        hasScriptType = true if lower == "scripttype"
        hasPlayResX = true if lower == "playresx"
        hasPlayResY = true if lower == "playresy"
        table.insert rows, "#{key}: #{value}"
  table.insert rows, "ScriptType: v4.00+" unless hasScriptType
  table.insert rows, "PlayResX: #{ass_int(videoW, 0)}" unless hasPlayResX or ass_int(videoW, 0) <= 0
  table.insert rows, "PlayResY: #{ass_int(videoH, 0)}" unless hasPlayResY or ass_int(videoH, 0) <= 0
  table.insert rows, ""
  table.insert rows, "[V4+ Styles]"
  table.insert rows, "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"
  styleCount = 0
  for i = 1, #subs
    line = subs[i]
    if line and line.class == "style"
      table.insert rows, style_ass_line line
      styleCount += 1
  table.insert rows, default_style_line! if styleCount == 0
  table.insert rows, ""
  table.insert rows, "[Events]"
  table.insert rows, "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"
  rendered = 0
  for i = 1, #subs
    line = subs[i]
    row = dialogue_ass_line line, range
    if row
      table.insert rows, row
      rendered += 1
  ok = write_file assPath, table.concat(rows, "\n")
  ok, rendered

sequence_outputs = (cfg) ->
  {
    clean: if cfg.captureClean == nil then true else cfg.captureClean == true
    withSubtitles: cfg.captureWithSubtitles == true
    subtitlesOnly: cfg.captureSubtitlesOnly == true
  }

sequence_output_count = (outputs) ->
  count = 0
  count += 1 if outputs.clean
  count += 1 if outputs.withSubtitles
  count += 1 if outputs.subtitlesOnly
  count

write_sequence_script = (video, outDir, ffmpeg, assPath, range, outputs) ->
  outputs = sequence_outputs {} unless outputs
  scriptPath = join_path outDir, "_snapshoter_sequence.bat"
  logPath = join_path outDir, "_snapshoter_ffmpeg.log"
  dirs = {}
  dirs.clean = join_path outDir, "clean" if outputs.clean
  dirs.withSubtitles = join_path outDir, "with_subtitles" if outputs.withSubtitles
  dirs.subtitlesOnly = join_path outDir, "subtitles_only" if outputs.subtitlesOnly
  rows = {}
  if isWindows
    table.insert rows, "@echo off"
    table.insert rows, "setlocal"
    table.insert rows, "if not exist " .. script_quote(outDir) .. " mkdir " .. script_quote(outDir)
    for _, dir in pairs dirs
      table.insert rows, "if not exist " .. script_quote(dir) .. " mkdir " .. script_quote(dir)
      table.insert rows, "del /q " .. script_quote(join_path(dir, "*.png")) .. " >nul 2>nul"
    table.insert rows, "type nul > " .. script_quote(logPath)
  else
    scriptPath = join_path outDir, "_snapshoter_sequence.sh"
    table.insert rows, "#!/bin/sh"
    table.insert rows, "mkdir -p " .. script_quote(outDir)
    for _, dir in pairs dirs
      table.insert rows, "mkdir -p " .. script_quote(dir)
      table.insert rows, "rm -f " .. script_quote(dir) .. "/*.png"
    table.insert rows, ": > " .. script_quote(logPath)

  output_pattern = (dir) -> script_quote join_path(dir, "frame_%06d.png")
  base_command = ->
    command_quote(ffmpeg) ..
      " -hide_banner -loglevel error -y -ss " .. ffmpeg_time(range.startMs) ..
      " -i " .. script_quote(video) ..
      " -an -frames:v " .. tostring(range.frameCount) ..
      " -start_number " .. tostring(range.startFrame) ..
      " -vsync 0"
  add_command = (filter, dir) ->
    command = base_command!
    command ..= " -vf " .. script_quote(filter) if filter and filter != ""
    command ..= " " .. output_pattern(dir)
    command ..= " >> " .. script_quote(logPath) .. " 2>&1"
    command ..= " || exit /b %ERRORLEVEL%" if isWindows
    command ..= " || exit $?" unless isWindows
    table.insert rows, command

  add_command "", dirs.clean if outputs.clean
  if outputs.withSubtitles or outputs.subtitlesOnly
    assFilter = filter_path_quote assPath
    add_command "setpts=PTS-STARTPTS,subtitles=#{assFilter}", dirs.withSubtitles if outputs.withSubtitles
    add_command "setpts=PTS-STARTPTS,format=rgba,colorchannelmixer=aa=0,subtitles=#{assFilter}:alpha=1,format=rgba", dirs.subtitlesOnly if outputs.subtitlesOnly

  if isWindows
    table.insert rows, "exit /b %ERRORLEVEL%"
    table.insert rows, ""
    return nil unless write_file scriptPath, table.concat(rows, "\r\n")
  else
    return nil unless write_file scriptPath, table.concat(rows, "\n")
  scriptPath, logPath, dirs

write_sequence_manifest = (outDir, video, range, assPath, scriptPath, logPath, dirs, rendered) ->
  rows = {
    "type\tframe_sequence"
    "video\t#{tostring(video or "")}"
    "start_frame\t#{range.startFrame}"
    "end_frame\t#{range.endFrame}"
    "frame_count\t#{range.frameCount}"
    "start_time\t#{ass_time range.startMs}"
    "end_time\t#{ass_time range.endMs}"
    "rendered_dialogue_lines\t#{rendered or 0}"
    "capture_script\t#{tostring(scriptPath or "")}"
    "ffmpeg_log\t#{tostring(logPath or "")}"
  }
  table.insert rows, "ass_file\t#{tostring(assPath or "")}" if assPath and assPath != ""
  table.insert rows, "clean_dir\t#{dirs.clean}" if dirs.clean
  table.insert rows, "with_subtitles_dir\t#{dirs.withSubtitles}" if dirs.withSubtitles
  table.insert rows, "subtitles_only_dir\t#{dirs.subtitlesOnly}" if dirs.subtitlesOnly
  write_file join_path(outDir, "_snapshoter_manifest.tsv"), table.concat(rows, "\n")

list_files = (dir) ->
  cmd = if isWindows
    "cmd /c dir /b /a-d " .. shell_quote(dir)
  else
    "find " .. shell_quote(dir) .. " -maxdepth 1 -type f"
  pipe = io.popen cmd, "r"
  return {} unless pipe
  files = {}
  for line in pipe\lines!
    name = tostring(line or "")
    name = name\match("([^\\/]+)$") or name unless isWindows
    table.insert files, name if name != ""
  pipe\close!
  files

cleanup_non_capture_files = (outDir, jobs) ->
  captureNames = {}
  for job in *(jobs or {})
    captureNames[(tostring(job.name or "")\lower!)] = true
  removed, failed = 0, {}
  for name in *list_files(outDir)
    lower = tostring(name or "")\lower!
    unless captureNames[lower] or lower\match "%.png$"
      ok, err = os.remove join_path(outDir, name)
      if ok
        removed += 1
      else
        table.insert failed, "#{name}: #{err or "unknown error"}"
  removed, failed

run_frame_sequence = (subs, lines, video, outDir, cfg) ->
  return false, "Select at least one timed dialogue line for Frame sequence." unless lines and #lines > 0
  range = sequence_range lines
  return false, "Could not build a frame range from the selected lines." unless range

  outputs = sequence_outputs cfg
  return false, "Select at least one Frame sequence output." if sequence_output_count(outputs) == 0

  assPath, rendered = "", 0
  if outputs.withSubtitles or outputs.subtitlesOnly
    assPath = join_path outDir, "_snapshoter_sequence.ass"
    ok, count = write_sequence_ass subs, assPath, range, cfg.videoW, cfg.videoH
    return false, "Snapshoter could not write the temporary ASS file." unless ok
    rendered = count

  scriptPath, logPath, dirs = write_sequence_script video, outDir, cfg.ffmpeg, assPath, range, outputs
  return false, "Snapshoter could not write the FFmpeg sequence script." unless scriptPath

  aegisub.progress.title "Snapshoter"
  aegisub.progress.task "Extracting frame sequence with FFmpeg"
  status = run_script scriptPath
  write_sequence_manifest outDir, video, range, assPath, scriptPath, logPath, dirs, rendered

  if command_ok status
    cleanupMessage = ""
    if cfg.keepOnlyCaptures
      removed, failed = cleanup_non_capture_files outDir, {}
      cleanupMessage = "\nRemoved #{removed} non-capture file"
      cleanupMessage ..= "s" if removed != 1
      cleanupMessage ..= "."
      if #failed > 0
        cleanupMessage ..= "\nCould not remove:\n" .. table.concat failed, "\n"
    message = "Frame sequence written to:\n#{outDir}"
    message ..= "\nFrames: #{range.startFrame}-#{range.endFrame} (#{range.frameCount})"
    message ..= "\nSubtitle lines rendered: #{rendered or 0}"
    folderRows = {}
    table.insert folderRows, dirs.clean if dirs.clean
    table.insert folderRows, dirs.withSubtitles if dirs.withSubtitles
    table.insert folderRows, dirs.subtitlesOnly if dirs.subtitlesOnly
    message ..= "\nFolders:\n" .. table.concat folderRows, "\n"
    message ..= cleanupMessage
    true, message
  else
    false, "FFmpeg returned an error. Check the sequence script and log:\n#{scriptPath}\n#{logPath}"

build_interface = (video, lineCount, frameDefaults) ->
  {
    main: {
      title: { class: "label", label: "Snapshoter", x: 0, y: 0, width: 4, height: 1 }
      count: { class: "label", label: "Selected dialogue lines: #{lineCount}", x: 4, y: 0, width: 8, height: 1 }
      modeLabel: { class: "label", label: "Capture", x: 0, y: 1, width: 2, height: 1 }
      mode: { class: "dropdown", value: "Selected lines", items: CAPTURE_MODES, config: true, x: 2, y: 1, width: 5, height: 1 }
      timingLabel: { class: "label", label: "Timing", x: 7, y: 1, width: 2, height: 1 }
      timing: { class: "dropdown", value: "Midpoint", items: TIMING_MODES, config: true, x: 9, y: 1, width: 5, height: 1 }
      ffmpegLabel: { class: "label", label: "FFmpeg", x: 0, y: 2, width: 2, height: 1 }
      ffmpeg: { class: "edit", value: "ffmpeg", config: true, x: 2, y: 2, width: 12, height: 1 }
      rootLabel: { class: "label", label: "Output root", x: 0, y: 3, width: 2, height: 1 }
      outputRoot: { class: "edit", value: "?script", config: true, x: 2, y: 3, width: 12, height: 1 }
      folderLabel: { class: "label", label: "Folder", x: 0, y: 4, width: 2, height: 1 }
      folder: { class: "edit", value: "Snapshoter_" .. safe_name(base_name(video), "video") .. "_" .. os.date("%Y%m%d_%H%M%S"), x: 2, y: 4, width: 12, height: 1 }
      includeText: { class: "checkbox", label: "Add subtitle text to filenames", value: true, config: true, x: 2, y: 5, width: 6, height: 1 }
      saveSettings: { class: "checkbox", label: "Save settings", value: true, config: true, x: 8, y: 5, width: 4, height: 1 }
      keepOnlyCaptures: { class: "checkbox", label: "Only PNG captures", value: false, config: true, x: 12, y: 5, width: 4, height: 1 }
      sequenceInfo: { class: "label", label: "Frame sequence outputs", x: 0, y: 6, width: 4, height: 1 }
      captureClean: { class: "checkbox", label: "No subtitles", value: true, config: true, x: 4, y: 6, width: 4, height: 1 }
      captureWithSubtitles: { class: "checkbox", label: "With subtitles", value: false, config: true, x: 8, y: 6, width: 4, height: 1 }
      captureSubtitlesOnly: { class: "checkbox", label: "Subtitles only", value: false, config: true, x: 12, y: 6, width: 4, height: 1 }
      frameInfo: { class: "label", label: "Frame list mode accepts: 120f, 130f or 120f > P1 fade 6f.", x: 0, y: 7, width: 14, height: 1 }
      frameText: { class: "textbox", value: frameDefaults or "", config: false, x: 2, y: 8, width: 12, height: 4 }
      rectInfo: { class: "label", label: "Manual rectangle uses video pixels. Rectangular clip uses ASS \\clip and scales to video.", x: 0, y: 12, width: 14, height: 1 }
      paddingLabel: { class: "label", label: "Padding", x: 0, y: 13, width: 2, height: 1 }
      cropPadding: { class: "intedit", value: 0, min: 0, max: 256, config: true, x: 2, y: 13, width: 2, height: 1 }
      xLabel: { class: "label", label: "X", x: 4, y: 13, width: 1, height: 1 }
      manualX: { class: "intedit", value: 0, min: 0, max: 20000, config: true, x: 5, y: 13, width: 2, height: 1 }
      yLabel: { class: "label", label: "Y", x: 7, y: 13, width: 1, height: 1 }
      manualY: { class: "intedit", value: 0, min: 0, max: 20000, config: true, x: 8, y: 13, width: 2, height: 1 }
      wLabel: { class: "label", label: "W", x: 10, y: 13, width: 1, height: 1 }
      manualW: { class: "intedit", value: 320, min: 1, max: 20000, config: true, x: 11, y: 13, width: 2, height: 1 }
      hLabel: { class: "label", label: "H", x: 13, y: 13, width: 1, height: 1 }
      manualH: { class: "intedit", value: 180, min: 1, max: 20000, config: true, x: 14, y: 13, width: 2, height: 1 }
    }
  }

read_config = (video, lineCount, frameDefaults) ->
  interface = build_interface video, lineCount, frameDefaults
  options = ConfigHandler interface, CONFIG_FILE, true, script_version
  options\read!
  options\updateInterface "main"
  button, result = aegisub.dialog.display interface.main, { "Capture", "Cancel" }, { ok: "Capture", close: "Cancel" }
  return nil unless button == "Capture"
  if result.saveSettings
    options\updateConfiguration result, "main"
    options\write!
  {
    mode: choice_or_default(result.mode, CAPTURE_MODES, "Selected lines")
    timing: choice_or_default(result.timing, TIMING_MODES, "Midpoint")
    ffmpeg: trim(result.ffmpeg)
    outputRoot: trim(result.outputRoot)
    folder: safe_name result.folder, "Snapshoter"
    includeText: result.includeText == true
    keepOnlyCaptures: result.keepOnlyCaptures == true
    captureClean: result.captureClean == true
    captureWithSubtitles: result.captureWithSubtitles == true
    captureSubtitlesOnly: result.captureSubtitlesOnly == true
    frameText: tostring(result.frameText or "")
    cropPadding: tonumber(result.cropPadding) or 0
    manualX: tonumber(result.manualX) or 0
    manualY: tonumber(result.manualY) or 0
    manualW: tonumber(result.manualW) or 1
    manualH: tonumber(result.manualH) or 1
  }

can_run = (subs, sel) ->
  if not aegisub.frame_from_ms or not aegisub.ms_from_frame
    return false, "Load a video before running Snapshoter."
  if not video_path!
    return false, "Load a video before running Snapshoter."
  true

snapshoter = (subs, sel) ->
  video = video_path!
  unless video
    show_message "Load a video before running Snapshoter."
    return

  collection, lines = selected_lines subs, sel or {}

  frameDefaults = build_frame_defaults default_frame_list(lines)
  cfg = read_config video, #lines, frameDefaults
  return unless cfg
  cfg.ffmpeg = "ffmpeg" if cfg.ffmpeg == ""
  cfg.videoW, cfg.videoH = video_size!

  outRoot = root_folder cfg.outputRoot, video
  outDir = join_path outRoot, cfg.folder
  ensure_dir outDir

  if cfg.mode == "Frame sequence"
    ok, message = run_frame_sequence subs, lines, video, outDir, cfg
    show_message message
    return

  jobs, skipped, errors = make_jobs collection, lines, cfg
  if #errors > 0
    show_message table.concat errors, "\n"
    return
  if #jobs == 0
    show_message "No captures were queued. Rectangular clip mode needs at least one rectangular \\clip."
    return
  log.debug "Snapshoter queued %d capture job(s) in %s", #jobs, outDir

  scriptPath, logPath = write_capture_script video, outDir, cfg.ffmpeg, jobs
  unless scriptPath
    show_message "Snapshoter could not write the FFmpeg script."
    return

  aegisub.progress.title "Snapshoter"
  aegisub.progress.task "Capturing PNG frames with FFmpeg"
  status = run_script scriptPath
  write_manifest outDir, video, jobs, skipped, scriptPath, logPath

  if command_ok status
    cleanupMessage = ""
    if cfg.keepOnlyCaptures
      removed, failed = cleanup_non_capture_files outDir, jobs
      cleanupMessage = "\nRemoved #{removed} non-capture file"
      cleanupMessage ..= "s" if removed != 1
      cleanupMessage ..= "."
      if #failed > 0
        cleanupMessage ..= "\nCould not remove:\n" .. table.concat failed, "\n"
    message = "#{#jobs} PNG capture"
    message ..= "s" if #jobs != 1
    message ..= " written to:\n#{outDir}"
    if #skipped > 0
      message ..= "\nSkipped #{#skipped} line(s) without rectangular \\clip."
    message ..= cleanupMessage
    show_message message
  else
    show_message "FFmpeg returned an error. Check the capture script and log:\n#{scriptPath}\n#{logPath}"

if depctrl and depctrl.registerMacro
  depctrl\registerMacro script_name, script_description, snapshoter, can_run, nil, false
else
  aegisub.register_macro script_name, script_description, snapshoter, can_run
