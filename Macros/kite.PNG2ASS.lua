script_name        = "PNG2ASS"
script_description = "Convert PNG images into ASS drawing lines"
script_author      = "Kiterow"
script_version     = "1.1.1"
script_namespace   = "kite.PNG2ASS"

local PNG2ASS = {}

local is_windows = package.config:sub(1, 1) == "\\"
local sep = is_windows and "\\" or "/"
local module_name = "ass_png2ass"
local config_file_name = "kite.PNG2ASS.conf"
local default_install_source = "git+https://github.com/kiteroww/ass-png2ass.git"

local depctrl
do
    local ok, DependencyControl = pcall(require, "l0.DependencyControl")
    if ok and DependencyControl then
        depctrl = DependencyControl({
            feed = "https://raw.githubusercontent.com/kiteroww/Aegisub-Scripts/main/DependencyControl.json",
            {
                {
                    "aka.command",
                    version = "1.0.2",
                    url = "https://github.com/Akatmks/Akatsumekusa-Aegisub-Scripts",
                    feed = "https://raw.githubusercontent.com/Akatmks/Akatsumekusa-Aegisub-Scripts/master/DependencyControl.json",
                },
            }
        })
    end
end

local command_api
do
    if depctrl and depctrl.requireModules then
        local ok, api = pcall(function()
            return depctrl:requireModules()
        end)
        if ok and api then
            command_api = api
        end
    end
    if not command_api then
        local ok, api = pcall(require, "aka.command")
        if ok and api then
            command_api = api
        end
    end
end

local lfs
do
    local ok, module = pcall(require, "lfs")
    if ok and module then
        lfs = module
    end
end

local DEFAULTS = {
    python = "python",
    install_source = default_install_source,
    engine = "auto",
    mode = "auto",
    threshold = 50,
    p_scale = 4,
    simplify = 1.0,
    min_area = 2,
    max_chars = 200000,
    position = "0,0",
    x = 0,
    y = 0,
    blur = 0,
    color = "style",
    filter_speckle = 2,
}

local ENGINES = { "auto", "vtracer", "opencv" }
local MODES = { "auto", "alpha", "white-matte", "dark-matte", "luma", "color" }
local POSITIONS = { "0,0", "Active pos", "Manual" }
local COLORS = { "style", "source" }

local function trim(value)
    value = tostring(value or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function shell_quote(value)
    value = tostring(value or "")
    if is_windows then
        return '"' .. value:gsub('"', '""') .. '"'
    end
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function join_path(left, right)
    left = tostring(left or "")
    right = tostring(right or "")
    if left == "" then
        return right
    end
    local tail = left:sub(-1)
    if tail == "\\" or tail == "/" then
        return left .. right
    end
    return left .. sep .. right
end

local function file_exists(path)
    local handle = io.open(path, "rb")
    if handle then
        handle:close()
        return true
    end
    return false
end

local function read_file(path)
    local handle = io.open(path, "rb")
    if not handle then
        return nil
    end
    local content = handle:read("*a")
    handle:close()
    return content
end

local function write_file(path, content)
    local handle = io.open(path, "wb")
    if not handle then
        return false
    end
    handle:write(content or "")
    handle:close()
    return true
end

local function read_lines(path)
    local content = read_file(path)
    if not content then
        return nil
    end
    local lines = {}
    for line in (content .. "\n"):gmatch("([^\r\n]*)\r?\n") do
        line = trim(line)
        if line ~= "" then
            lines[#lines + 1] = line
        end
    end
    return lines
end

local function ensure_dir(path)
    if trim(path) == "" then
        return false
    end
    if lfs then
        local attr = lfs.attributes(path)
        if attr and attr.mode == "directory" then
            return true
        end
        return lfs.mkdir(path) ~= nil
    end
    if is_windows then
        os.execute("cmd /c if not exist " .. shell_quote(path) .. " mkdir " .. shell_quote(path))
    else
        os.execute("mkdir -p " .. shell_quote(path))
    end
    return true
end

local function show_message(message)
    aegisub.dialog.display({
        { class = "textbox", value = tostring(message or ""), x = 0, y = 0, width = 74, height = 12 },
    }, { "OK" })
end

local function cancel_with(message)
    show_message(message)
    aegisub.cancel()
end

local temp_paths

local function continue_after_many_lines(message)
    if not message or not message:find("Too many ASS lines", 1, true) then
        return false
    end
    local button = aegisub.dialog.display({
        { class = "textbox", value = message .. "\n\nContinue anyway?", x = 0, y = 0, width = 74, height = 12 },
    }, { "Continue", "Cancel" }, { ok = "Continue", close = "Cancel" })
    return button == "Continue"
end

local function command_ok(status)
    return status == true or status == 0
end

local function command_program(value)
    value = trim(value)
    if value == "" then
        value = DEFAULTS.python
    end
    if value:find("[\\/]") then
        return shell_quote(value)
    end
    return value
end

local function wrap_command(command, log_path)
    command = tostring(command or ""):gsub("\r?\n", " && ")
    if log_path and trim(log_path) ~= "" then
        command = command .. " > " .. shell_quote(log_path) .. " 2>&1"
    end
    if is_windows then
        return 'cmd /c "' .. command .. '"'
    end
    return command
end

local function run_command(command, log_path)
    if command_api and command_api.run_cmd_c then
        local output, ok = command_api.run_cmd_c(command, true)
        write_file(log_path, output or "")
        return ok == true
    end
    return command_ok(os.execute(wrap_command(command, log_path)))
end

local function run_command_dialog(title, command, ok_message)
    local current = command
    local log = nil
    while true do
        local interface = {
            { class = "label", label = title, x = 0, y = 0, width = 8, height = 1 },
            { class = "label", label = "Run this command.", x = 0, y = 1, width = 8, height = 1 },
            { class = "textbox", name = "command", value = current, x = 0, y = 2, width = 74, height = 8 },
        }
        if log and trim(log) ~= "" then
            table.insert(interface, { class = "label", label = "Output", x = 0, y = 10, width = 8, height = 1 })
            table.insert(interface, { class = "textbox", name = "log", value = log, x = 0, y = 11, width = 74, height = 8 })
        end

        local run_label = log and "Run Again" or "Run"
        local button, result = aegisub.dialog.display(interface, { run_label, "Cancel" }, { ok = run_label, close = "Cancel" })
        if button ~= run_label then
            aegisub.cancel()
        end

        current = trim(result.command)
        if current == "" then
            log = "Command is empty."
        else
            local paths = temp_paths()
            if run_command(current, paths.cmdlog) then
                show_message(ok_message)
                return true
            end
            log = read_file(paths.cmdlog) or "Command failed."
        end
    end
end

local function source_dir()
    if not debug or not debug.getinfo then
        return nil
    end
    local info = debug.getinfo(1, "S")
    local source = info and info.source or ""
    if source:sub(1, 1) ~= "@" then
        return nil
    end
    local path = source:sub(2)
    local dir = path:match("^(.*)[\\/]")
    if dir and dir ~= "" then
        return dir
    end
    return nil
end

local function decoded_path(spec)
    if aegisub and aegisub.decode_path then
        local ok, path = pcall(aegisub.decode_path, spec)
        if ok and type(path) == "string" and path ~= "" and path ~= spec then
            return path
        end
    end
    return nil
end

local function script_dir()
    local dir = source_dir()
    if dir then
        return dir
    end
    local user_path = decoded_path("?user")
    if user_path then
        return join_path(join_path(user_path, "automation"), "autoload")
    end
    return decoded_path("?script") or "."
end

local function local_package_source()
    local source = join_path(script_dir(), "ass_png2ass")
    if file_exists(join_path(source, "pyproject.toml")) then
        return source
    end
    return default_install_source
end

local function default_python()
    local path = join_path(join_path(join_path(script_dir(), "ass_png2ass"), ".venv"), is_windows and "Scripts\\python.exe" or "bin/python")
    if file_exists(path) then
        return path
    end
    return DEFAULTS.python
end

local function default_config()
    return {
        python = default_python(),
        install_source = local_package_source(),
    }
end

local function config_path(create)
    local user_path = decoded_path("?user")
    if user_path then
        local dir = join_path(user_path, "config")
        if create then
            ensure_dir(dir)
        end
        return join_path(dir, config_file_name)
    end
    return join_path(script_dir(), config_file_name)
end

local function read_config()
    local cfg = default_config()
    local content = read_file(config_path(false))
    if not content then
        return cfg
    end
    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("^([%w_]+)=(.*)$")
        if key == "python" or key == "install_source" then
            cfg[key] = value
        end
    end
    if trim(cfg.python) == "" then
        cfg.python = default_python()
    end
    if trim(cfg.install_source) == "" then
        cfg.install_source = local_package_source()
    elseif cfg.install_source:find("png2ass_" .. "back" .. "end", 1, true) or cfg.install_source:find("png2ass-" .. "back" .. "end", 1, true) then
        cfg.install_source = local_package_source()
    end
    return cfg
end

local function write_config(cfg)
    return write_file(config_path(true), "python=" .. trim(cfg.python) .. "\ninstall_source=" .. trim(cfg.install_source) .. "\n")
end

function temp_paths()
    local stamp = os.date("%Y%m%d%H%M%S") .. "_" .. tostring(math.random(100000, 999999))
    local out_name = "png2ass_" .. stamp .. ".txt"
    local list_name = "png2ass_" .. stamp .. ".list"
    local sequence_name = "png2ass_" .. stamp .. ".seq"
    local log_name = "png2ass_" .. stamp .. ".log"
    local cmd_log_name = "png2ass_" .. stamp .. ".cmd.log"
    local out_path = decoded_path("?temp/" .. out_name)
    local list_path = decoded_path("?temp/" .. list_name)
    local sequence_path = decoded_path("?temp/" .. sequence_name)
    local log_path = decoded_path("?temp/" .. log_name)
    local cmd_log_path = decoded_path("?temp/" .. cmd_log_name)
    if out_path and list_path and sequence_path and log_path and cmd_log_path then
        return { out = out_path, list = list_path, sequence = sequence_path, log = log_path, cmdlog = cmd_log_path }
    end
    local temp = join_path(script_dir(), "temp")
    ensure_dir(temp)
    return {
        out = out_path or join_path(temp, out_name),
        list = list_path or join_path(temp, list_name),
        sequence = sequence_path or join_path(temp, sequence_name),
        log = log_path or join_path(temp, log_name),
        cmdlog = cmd_log_path or join_path(temp, cmd_log_name),
    }
end

local function active_pos(text)
    local x, y = tostring(text or ""):match("\\pos%(%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*%)")
    return tonumber(x), tonumber(y)
end

local function copy_line(line)
    local out = {}
    for key, value in pairs(line) do
        out[key] = value
    end
    return out
end

local function natural_key(path)
    local name = tostring(path or ""):match("([^\\/]+)$") or tostring(path or "")
    name = name:lower()
    return name:gsub("(%d+)", function(number)
        return string.format("%012d", tonumber(number) or 0)
    end)
end

local function normalize_paths(value)
    local paths = {}
    if type(value) == "table" then
        for _, path in ipairs(value) do
            if type(path) == "string" and trim(path) ~= "" then
                paths[#paths + 1] = path
            end
        end
    elseif type(value) == "string" and trim(value) ~= "" then
        paths[#paths + 1] = value
    end
    table.sort(paths, function(left, right)
        return natural_key(left) < natural_key(right)
    end)
    return paths
end

local function select_pngs()
    local result = aegisub.dialog.open(
        "Select PNG Images",
        "",
        script_dir(),
        "PNG files (.png)|*.png",
        true,
        true
    )
    local paths = normalize_paths(result)
    if #paths == 0 then
        aegisub.cancel()
    end
    return paths
end

local function package_config_dialog(title, buttons)
    local cfg = read_config()
    local interface = {
        title = { class = "label", label = title, x = 0, y = 0, width = 8, height = 1 },
        python_label = { class = "label", label = "Python", x = 0, y = 1, width = 2, height = 1 },
        python = { class = "edit", name = "python", value = cfg.python, x = 2, y = 1, width = 14, height = 1 },
        source_label = { class = "label", label = "Install source", x = 0, y = 2, width = 3, height = 1 },
        install_source = { class = "edit", name = "install_source", value = cfg.install_source, x = 3, y = 2, width = 13, height = 1 },
    }
    local button, result = aegisub.dialog.display(interface, buttons or { "Save", "Cancel" }, { ok = buttons and buttons[1] or "Save", close = "Cancel" })
    if button == "Cancel" then
        aegisub.cancel()
    end
    result.python = trim(result.python)
    result.install_source = trim(result.install_source)
    if result.python == "" then
        result.python = default_python()
    end
    if result.install_source == "" then
        result.install_source = local_package_source()
    end
    return button, result
end

local function check_package(cfg, quiet)
    local paths = temp_paths()
    local command = command_program(cfg.python) .. " -m " .. module_name .. " --check-dependencies --quiet"
    local ok = run_command(command, paths.cmdlog)
    if not ok and not quiet then
        local log = read_file(paths.cmdlog) or "Package check failed."
        show_message(log)
    end
    return ok, paths
end

local function install_package_main()
    local _, cfg = package_config_dialog("PNG2ASS Package", { "Install/Update", "Cancel" })
    write_config(cfg)
    local python = command_program(cfg.python)
    local command = table.concat({
        python .. " -m ensurepip",
        python .. " -m pip install --upgrade pip setuptools wheel",
        python .. " -m pip install --upgrade --no-build-isolation " .. shell_quote(cfg.install_source),
        python .. " -m " .. module_name .. " --check-dependencies",
    }, "\n")
    run_command_dialog("PNG2ASS Package", command, "Package is installed and ready.")
end

local function configure_package_main()
    local _, cfg = package_config_dialog("PNG2ASS Package", { "Save", "Cancel" })
    write_config(cfg)
    show_message("Package configuration saved.")
end

local function check_package_main()
    local cfg = read_config()
    if check_package(cfg, true) then
        show_message("Package is ready.")
    else
        local paths = temp_paths()
        run_command(command_program(cfg.python) .. " -m " .. module_name .. " --check-dependencies", paths.cmdlog)
        show_message(read_file(paths.cmdlog) or "Package check failed.")
        aegisub.cancel()
    end
end

local function create_dialog(line, cfg, image_count, frame_count)
    local px, py = active_pos(line.text)
    local default_position = (px and py) and "Active pos" or DEFAULTS.position
    local count_label = "Images: " .. tostring(image_count or 1)
    if frame_count then
        count_label = count_label .. " / Frames: " .. tostring(frame_count)
    end
    local interface = {
        title = { class = "label", label = "PNG2ASS", x = 0, y = 0, width = 6, height = 1 },
        engine_label = { class = "label", label = "Engine", x = 0, y = 1, width = 2, height = 1 },
        engine = { class = "dropdown", name = "engine", items = ENGINES, value = DEFAULTS.engine, x = 2, y = 1, width = 3, height = 1 },
        mode_label = { class = "label", label = "Mode", x = 5, y = 1, width = 2, height = 1 },
        mode = { class = "dropdown", name = "mode", items = MODES, value = DEFAULTS.mode, x = 7, y = 1, width = 3, height = 1 },
        color_label = { class = "label", label = "Color", x = 10, y = 1, width = 2, height = 1 },
        color = { class = "dropdown", name = "color", items = COLORS, value = DEFAULTS.color, x = 12, y = 1, width = 3, height = 1 },
        threshold_label = { class = "label", label = "Threshold", x = 0, y = 2, width = 2, height = 1 },
        threshold = { class = "intedit", name = "threshold", value = DEFAULTS.threshold, min = 1, max = 99, x = 2, y = 2, width = 2, height = 1 },
        scale_label = { class = "label", label = "Scale", x = 4, y = 2, width = 2, height = 1 },
        p_scale = { class = "intedit", name = "p_scale", value = DEFAULTS.p_scale, min = 1, max = 6, x = 6, y = 2, width = 2, height = 1 },
        speckle_label = { class = "label", label = "Speckle", x = 8, y = 2, width = 2, height = 1 },
        filter_speckle = { class = "intedit", name = "filter_speckle", value = DEFAULTS.filter_speckle, min = 0, max = 100, x = 10, y = 2, width = 2, height = 1 },
        simplify_label = { class = "label", label = "Simplify", x = 0, y = 3, width = 3, height = 1 },
        simplify = { class = "floatedit", name = "simplify", value = DEFAULTS.simplify, min = 0, max = 20, step = 0.25, x = 3, y = 3, width = 2, height = 1 },
        min_area_label = { class = "label", label = "Min area", x = 5, y = 3, width = 2, height = 1 },
        min_area = { class = "floatedit", name = "min_area", value = DEFAULTS.min_area, min = 0, max = 10000, step = 1, x = 7, y = 3, width = 2, height = 1 },
        position_label = { class = "label", label = "Position", x = 0, y = 4, width = 2, height = 1 },
        position = { class = "dropdown", name = "position", items = POSITIONS, value = default_position, x = 2, y = 4, width = 3, height = 1 },
        x_label = { class = "label", label = "X", x = 5, y = 4, width = 1, height = 1 },
        x = { class = "intedit", name = "x", value = px or DEFAULTS.x, min = -20000, max = 20000, x = 6, y = 4, width = 2, height = 1 },
        y_label = { class = "label", label = "Y", x = 8, y = 4, width = 1, height = 1 },
        y = { class = "intedit", name = "y", value = py or DEFAULTS.y, min = -20000, max = 20000, x = 9, y = 4, width = 2, height = 1 },
        blur_label = { class = "label", label = "Blur", x = 0, y = 5, width = 2, height = 1 },
        blur = { class = "floatedit", name = "blur", value = DEFAULTS.blur, min = 0, max = 20, step = 0.1, x = 2, y = 5, width = 2, height = 1 },
        max_label = { class = "label", label = "Max chars", x = 4, y = 5, width = 2, height = 1 },
        max_chars = { class = "intedit", name = "max_chars", value = DEFAULTS.max_chars, min = 1000, max = 2000000, x = 6, y = 5, width = 3, height = 1 },
        count_label = { class = "label", label = count_label, x = 0, y = 6, width = 15, height = 1 },
        python_label = { class = "label", label = "Python", x = 0, y = 7, width = 2, height = 1 },
        python = { class = "edit", name = "python", value = cfg.python, x = 2, y = 7, width = 11, height = 1 },
        save_config = { class = "checkbox", name = "save_config", label = "Save", value = false, x = 13, y = 7, width = 2, height = 1 },
    }
    local button, result = aegisub.dialog.display(interface, { "Insert", "Cancel" }, { ok = "Insert", close = "Cancel" })
    if button ~= "Insert" then
        aegisub.cancel()
    end
    result.python = trim(result.python)
    if result.python == "" then
        result.python = cfg.python
    end
    return result
end

local function build_command(paths, png_path, options, pos_x, pos_y, allow_many_lines)
    local parts = {
        command_program(options.python),
        "-m", module_name,
        "--input", shell_quote(png_path),
        "--mode", shell_quote(options.mode),
        "--engine", shell_quote(options.engine),
        "--threshold", tostring(options.threshold),
        "--p-scale", tostring(options.p_scale),
        "--simplify", tostring(options.simplify),
        "--min-area", tostring(options.min_area),
        "--max-chars", tostring(options.max_chars),
        "--filter-speckle", tostring(options.filter_speckle),
        "--pos-x", tostring(pos_x),
        "--pos-y", tostring(pos_y),
        "--blur", tostring(options.blur),
        "--out", shell_quote(paths.out),
        "--log", shell_quote(paths.log),
        "--quiet",
    }
    if options.color == "source" or options.mode == "color" then
        parts[#parts + 1] = "--keep-color"
    end
    if allow_many_lines then
        parts[#parts + 1] = "--allow-many-lines"
    end
    return table.concat(parts, " ")
end

local function build_sequence_command(paths, options, pos_x, pos_y, allow_many_lines)
    local parts = {
        command_program(options.python),
        "-m", module_name,
        "--input-list", shell_quote(paths.list),
        "--mode", shell_quote(options.mode),
        "--engine", shell_quote(options.engine),
        "--threshold", tostring(options.threshold),
        "--p-scale", tostring(options.p_scale),
        "--simplify", tostring(options.simplify),
        "--min-area", tostring(options.min_area),
        "--max-chars", tostring(options.max_chars),
        "--filter-speckle", tostring(options.filter_speckle),
        "--pos-x", tostring(pos_x),
        "--pos-y", tostring(pos_y),
        "--blur", tostring(options.blur),
        "--sequence-out", shell_quote(paths.sequence),
        "--log", shell_quote(paths.log),
        "--quiet",
    }
    if options.color == "source" or options.mode == "color" then
        parts[#parts + 1] = "--keep-color"
    end
    if allow_many_lines then
        parts[#parts + 1] = "--allow-many-lines"
    end
    return table.concat(parts, " ")
end

local function resolve_position(options, line)
    if options.position == "Active pos" then
        local px, py = active_pos(line.text)
        return px or 0, py or 0
    end
    if options.position == "Manual" then
        return tonumber(options.x) or 0, tonumber(options.y) or 0
    end
    return 0, 0
end

local function insert_shapes(subs, index, ass_lines)
    local source = subs[index]
    local new_sel = {}
    for i, ass_text in ipairs(ass_lines) do
        local new_line = copy_line(source)
        new_line.layer = (tonumber(source.layer) or 0) + 1
        new_line.text = ass_text
        subs.insert(index + i, new_line)
        new_sel[#new_sel + 1] = index + i
    end
    return new_sel
end

local function selected_dialogue_indices(subs, sel)
    local indices = {}
    for _, index in ipairs(sel or {}) do
        local line = subs[index]
        if line and line.class == "dialogue" then
            indices[#indices + 1] = index
        end
    end
    table.sort(indices)
    return indices
end

local function round_to_cs(time)
    time = tonumber(time) or 0
    return (time + 5) - ((time + 5) % 10)
end

local function build_frame_jobs(subs, sel)
    if not aegisub.frame_from_ms or not aegisub.ms_from_frame then
        return nil, "A loaded video is required to map images to frames."
    end

    local jobs = {}
    local indices = selected_dialogue_indices(subs, sel)
    if #indices == 0 then
        return nil, "Select at least one dialogue line."
    end

    for _, index in ipairs(indices) do
        local line = subs[index]
        local start_frame = aegisub.frame_from_ms(round_to_cs(line.start_time))
        local end_frame = aegisub.frame_from_ms(round_to_cs(line.end_time))
        if not start_frame or not end_frame then
            return nil, "Could not read frame timing from the selected lines."
        end
        if end_frame <= start_frame then
            return nil, "Selected line " .. tostring(index) .. " is shorter than one frame."
        end

        for frame = start_frame, end_frame - 1 do
            local start_ms = aegisub.ms_from_frame(frame)
            local end_ms = aegisub.ms_from_frame(frame + 1)
            if not start_ms or not end_ms then
                return nil, "Could not convert frame timing to milliseconds."
            end
            if end_ms <= start_ms then
                return nil, "Invalid frame timing at frame " .. tostring(frame) .. "."
            end
            jobs[#jobs + 1] = {
                index = index,
                line = line,
                frame = frame,
                start_time = start_ms,
                end_time = end_ms,
                sequence_index = #jobs + 1,
            }
        end
    end

    if #jobs == 0 then
        return nil, "The selected lines do not cover any frames."
    end
    return jobs
end

local function read_sequence(path)
    local content = read_file(path)
    if not content then
        return nil, "Sequence output was not created."
    end

    local rows = {}
    for line in (content .. "\n"):gmatch("([^\r\n]*)\r?\n") do
        rows[#rows + 1] = line
    end
    if trim(rows[1]) ~= "PNG2ASS_SEQUENCE 1" then
        return nil, "Sequence output has an unsupported format."
    end

    local frames = {}
    local i = 2
    while i <= #rows do
        local row = trim(rows[i])
        if row == "" then
            i = i + 1
        else
            local frame_index = tonumber(row:match("^FRAME%s+(%d+)$"))
            if not frame_index then
                return nil, "Sequence output is malformed near line " .. tostring(i) .. "."
            end
            i = i + 1
            local count = tonumber(trim(rows[i] or ""):match("^LINES%s+(%d+)$"))
            if not count then
                return nil, "Sequence output is missing a line count for frame " .. tostring(frame_index) .. "."
            end
            i = i + 1
            local ass_lines = {}
            for _ = 1, count do
                if i > #rows then
                    return nil, "Sequence output ended before frame " .. tostring(frame_index) .. " was complete."
                end
                ass_lines[#ass_lines + 1] = rows[i]
                i = i + 1
            end
            frames[frame_index] = ass_lines
        end
    end

    return frames
end

local function insert_sequence_shapes(subs, jobs, frames)
    local groups = {}
    local indices = {}
    for _, job in ipairs(jobs) do
        if not groups[job.index] then
            groups[job.index] = {}
            indices[#indices + 1] = job.index
        end
        groups[job.index][#groups[job.index] + 1] = job
    end
    table.sort(indices, function(left, right)
        return left > right
    end)

    for _, index in ipairs(indices) do
        local insert_at = index
        local inserted = 0
        for _, job in ipairs(groups[index]) do
            local ass_lines = frames[job.sequence_index]
            if not ass_lines or #ass_lines == 0 then
                cancel_with("Missing converted shape for frame " .. tostring(job.sequence_index) .. ".")
            end
            for _, ass_text in ipairs(ass_lines) do
                local new_line = copy_line(job.line)
                new_line.layer = (tonumber(job.line.layer) or 0) + 1
                new_line.start_time = job.start_time
                new_line.end_time = job.end_time
                new_line.text = ass_text
                subs.insert(insert_at + inserted + 1, new_line)
                inserted = inserted + 1
            end
        end
    end
end

function PNG2ASS.main(subs, sel, active_line)
    if not sel or #sel == 0 then
        cancel_with("Select one dialogue line first.")
    end
    local index = active_line or sel[1]
    local line = subs[index]
    if not line or line.class ~= "dialogue" then
        index = sel[1]
        line = subs[index]
    end
    if not line or line.class ~= "dialogue" then
        cancel_with("Select one dialogue line first.")
    end
    local cfg = read_config()
    local image_paths = select_pngs()
    local frame_jobs = nil
    if #image_paths > 1 then
        local err
        frame_jobs, err = build_frame_jobs(subs, sel)
        if not frame_jobs then
            cancel_with(err)
        end
        if #image_paths ~= #frame_jobs then
            cancel_with("Image count does not match selected frame count.\n\nImages: " .. tostring(#image_paths) .. "\nFrames: " .. tostring(#frame_jobs))
        end
    end

    local options = create_dialog(line, cfg, #image_paths, frame_jobs and #frame_jobs or nil)
    if options.save_config then
        cfg.python = options.python
        write_config(cfg)
    end
    local paths = temp_paths()
    local pos_x, pos_y = resolve_position(options, line)

    if #image_paths == 1 then
        local command = build_command(paths, image_paths[1], options, pos_x, pos_y, false)
        local ok = run_command(command, paths.cmdlog)
        local ass_lines = read_lines(paths.out)
        if not ok or not ass_lines or #ass_lines == 0 then
            local log = read_file(paths.log)
            if not log or trim(log) == "" then
                log = read_file(paths.cmdlog)
            end
            if continue_after_many_lines(log) then
                command = build_command(paths, image_paths[1], options, pos_x, pos_y, true)
                ok = run_command(command, paths.cmdlog)
                ass_lines = read_lines(paths.out)
                if not ok or not ass_lines or #ass_lines == 0 then
                    log = read_file(paths.log)
                    if not log or trim(log) == "" then
                        log = read_file(paths.cmdlog)
                    end
                end
            end
            if not ok or not ass_lines or #ass_lines == 0 then
                if log and trim(log) ~= "" then
                    cancel_with(log)
                end
                cancel_with("PNG conversion failed. Use Check Package or Install/Update Package.")
            end
        end
        local new_sel = insert_shapes(subs, index, ass_lines)
        aegisub.set_undo_point(script_name)
        return new_sel
    end

    write_file(paths.list, table.concat(image_paths, "\n"))
    local command = build_sequence_command(paths, options, pos_x, pos_y, false)
    local ok = run_command(command, paths.cmdlog)
    local frames, parse_error = read_sequence(paths.sequence)
    if not ok or not frames then
        local log = read_file(paths.log)
        if not log or trim(log) == "" then
            log = read_file(paths.cmdlog)
        end
        if continue_after_many_lines(log) then
            command = build_sequence_command(paths, options, pos_x, pos_y, true)
            ok = run_command(command, paths.cmdlog)
            frames, parse_error = read_sequence(paths.sequence)
            if not ok or not frames then
                log = read_file(paths.log)
                if not log or trim(log) == "" then
                    log = read_file(paths.cmdlog)
                end
            end
        end
        if not ok or not frames then
            if log and trim(log) ~= "" then
                cancel_with(log)
            end
            cancel_with(parse_error or "PNG sequence conversion failed. Use Check Package or Install/Update Package.")
        end
    end

    for i = 1, #frame_jobs do
        if not frames[i] or #frames[i] == 0 then
            cancel_with("Missing converted shape for frame " .. tostring(i) .. ".")
        end
    end
    insert_sequence_shapes(subs, frame_jobs, frames)
    aegisub.set_undo_point(script_name)
    return sel
end

function PNG2ASS.can_run(subs, sel)
    if not sel or #sel == 0 then
        return false
    end
    for _, index in ipairs(sel) do
        local line = subs[index]
        if line and line.class == "dialogue" then
            return true
        end
    end
    return false
end

if aegisub and aegisub.register_macro then
    if depctrl and depctrl.registerMacro and depctrl.registerMacros then
        depctrl:registerMacros({
            { script_name, script_description, PNG2ASS.main, PNG2ASS.can_run },
            { "Install or Update Package", "Install or update the Python package", install_package_main },
            { "Check Package", "Check the Python package", check_package_main },
            { "Configure Package", "Configure Python and package source", configure_package_main },
        })
    else
        aegisub.register_macro(script_name .. "/" .. script_name, script_description, PNG2ASS.main, PNG2ASS.can_run)
        aegisub.register_macro(script_name .. "/Install or Update Package", "Install or update the Python package", install_package_main)
        aegisub.register_macro(script_name .. "/Check Package", "Check the Python package", check_package_main)
        aegisub.register_macro(script_name .. "/Configure Package", "Configure Python and package source", configure_package_main)
    end
end

return PNG2ASS
