script_name = "Kite Styles Manager"
script_description = "Multiple actor style management"
script_author = "Kiterow"
script_version = "1.4"

actor_styles = {}
actor_ui_values = {}

function ass_to_rgb(ass_color)
    local b, g, r = ass_color:match("&H(%x%x)(%x%x)(%x%x)&")
    if r and g and b then
        return "#" .. r .. g .. b
    else
        return "#FFFFFF"
    end
end

function rgb_to_ass(color)
    if not color or type(color) ~= "string" or not color:match("^#%x%x%x%x%x%x$") then
        return "&HFFFFFF&"
    end
    local r, g, b = color:match("#(%x%x)(%x%x)(%x%x)")
    return string.format("&H%02X%02X%02X&", tonumber(b,16), tonumber(g,16), tonumber(r,16))
end

function parse_tags(text)
    local tags = {}
    local tagblock = text:match("^{(.-)}")
    if tagblock then
        local blur = tagblock:match("\\blur([%d%.]+)")
        if blur then tags.blur = tonumber(blur) end
        local be = tagblock:match("\\be([%d%.]+)")
        if be then tags.be = tonumber(be) end
        local shad = tagblock:match("\\shad([%d%.]+)")
        if shad then tags.shad = tonumber(shad) end
        local bord = tagblock:match("\\bord([%d%.]+)")
        if bord then tags.bord = tonumber(bord) end
        local xshad = tagblock:match("\\xshad([%-%d%.]+)")
        if xshad then tags.xshad = tonumber(xshad) end
        local yshad = tagblock:match("\\yshad([%-%d%.]+)")
        if yshad then tags.yshad = tonumber(yshad) end
        local alpha = tagblock:match("\\alpha(&H%x%x&)")
        if alpha then tags.alpha = alpha end
        local fsp = tagblock:match("\\fsp([%-%d%.]+)")
        if fsp then tags.fsp = tonumber(fsp) end
        local fscx = tagblock:match("\\fscx([%d%.]+)")
        if fscx then tags.fscx = tonumber(fscx) end
        local fscy = tagblock:match("\\fscy([%d%.]+)")
        if fscy then tags.fscy = tonumber(fscy) end
        for i = 1, 4 do
            local pattern = "\\" .. i .. "c(&H%x+&)"
            local ass_color = tagblock:match(pattern)
            if ass_color then 
                tags[i.."c"] = ass_to_rgb(ass_color)
                tags["mod" .. i .. "c"] = true
            end
            local alpha_pattern = "\\" .. i .. "a(&H%x%x&)"
            local color_alpha = tagblock:match(alpha_pattern)
            if color_alpha then 
                tags[i.."a"] = color_alpha 
            end
        end
    end
    return tags
end

function load_actor_styles(subs)
    local styles = {}
    local default_values = {
        blur = 0, be = 0, shad = 0, bord = 0,
        xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
        alpha = "&H00&",
        ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
        ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
        ["1a"] = "&H00&", ["2a"] = "&H00&",
        ["3a"] = "&H00&", ["4a"] = "&H00&",
        mod1c = false, mod2c = false, mod3c = false, mod4c = false
    }
    for i = 1, #subs do
        if subs[i].class == "dialogue" then
            local actor = subs[i].actor
            if actor == "" then actor = "No Actor" end
            if not styles[actor] then
                styles[actor] = {}
                for k, v in pairs(default_values) do
                    styles[actor][k] = v
                end
            end
            local parsed = parse_tags(subs[i].text)
            for k, v in pairs(parsed) do
                if styles[actor][k] == default_values[k] then
                    styles[actor][k] = v
                end
            end
            for i = 1, 4 do
                if styles[actor]["mod" .. i .. "c"] == nil then
                    styles[actor]["mod" .. i .. "c"] = false
                end
            end
        end
    end
    return styles
end

function build_style_string(new, original)
    local tags = {}
    local numeric_tags = {
        blur = "\\blur%.1f", be = "\\be%.1f",
        bord = "\\bord%.1f", shad = "\\shad%.1f",
        xshad = "\\xshad%.1f", yshad = "\\yshad%.1f",
        fsp = "\\fsp%.1f"
    }
    for tag, format in pairs(numeric_tags) do
        if new[tag] and new[tag] ~= 0 and (not original[tag] or new[tag] ~= original[tag]) then
            table.insert(tags, string.format(format, new[tag]))
        end
    end
    if new.fscx and new.fscx ~= 100 and (not original.fscx or new.fscx ~= original.fscx) then
        table.insert(tags, string.format("\\fscx%.1f", new.fscx))
    end
    if new.fscy and new.fscy ~= 100 and (not original.fscy or new.fscy ~= original.fscy) then
        table.insert(tags, string.format("\\fscy%.1f", new.fscy))
    end
    if new.alpha and new.alpha ~= "&H00&" and (not original.alpha or new.alpha ~= original.alpha) then
        table.insert(tags, "\\alpha" .. new.alpha)
    end
    for i = 1, 4 do
        local tag = i.."c"
        if new["mod" .. i .. "c"] then
            table.insert(tags, "\\" .. tag .. rgb_to_ass(new[tag]))
        end
        local alpha_tag = i.."a"
        if new[alpha_tag] and new[alpha_tag] ~= "&H00&" and (not original[alpha_tag] or new[alpha_tag] ~= original[alpha_tag]) then
            table.insert(tags, "\\" .. alpha_tag .. new[alpha_tag])
        end
    end
    return table.concat(tags)
end

-- Save changes for all actors; only insert a tag block if nonempty.
function save_all_changes(subs, sel, actors)
    local total = 0
    local neutral = {
        blur = 0, be = 0, shad = 0, bord = 0,
        xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
        alpha = "&H00&",
        ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
        ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
        ["1a"] = "&H00&", ["2a"] = "&H00&",
        ["3a"] = "&H00&", ["4a"] = "&H00&"
    }
    local known_tags = {"blur","be","shad","bord","xshad","yshad","fsp","fscx","fscy","alpha",
                          "1c","2c","3c","4c","1a","2a","3a","4a"}
    for _, actor in ipairs(actors) do
        local style = actor_styles[actor] or neutral
        local style_str = build_style_string(style, neutral)
        for _, i in ipairs(sel) do
            local line = subs[i]
            if line.actor == actor or (actor == "No Actor" and line.actor == "") then
                local original_tagblock = line.text:match("^{(.-)}") or ""
                for _, tag in ipairs(known_tags) do
                    original_tagblock = original_tagblock:gsub("\\" .. tag .. "[^\\}]*", "")
                end
                local rest = line.text:gsub("^{[^}]*}", "")
                local new_tagblock = style_str .. original_tagblock
                if new_tagblock == "" then
                    line.text = rest
                else
                    line.text = "{" .. new_tagblock .. "}" .. rest
                end
                subs[i] = line
                total = total + 1
            end
        end
    end
    return total
end

function save_styles(styles)
    local filename = aegisub.file_name()
    if not filename then 
        aegisub.dialog.display({{class="label", x=0, y=0, label="File not saved. Please save it first."}}, {"OK"})
        return false
    end
    local path = aegisub.decode_path("?script/" .. filename:gsub("%..-$", "") .. " [Kite Styles].txt")
    local save_dialog = {
        {class="label", x=0, y=0, label="Save styles as:"},
        {class="edit", x=0, y=1, width=40, name="file_path", value=path}
    }
    local save_buttons = {"Save", "Cancel"}
    local save_pressed, save_result = aegisub.dialog.display(save_dialog, save_buttons)
    if save_pressed == "Cancel" then return false end
    path = save_result.file_path
    local file, err = io.open(path, "w")
    if not file then
        aegisub.dialog.display({{class="label", x=0, y=0, label="Error saving file: " .. (err or "unknown")}}, {"OK"})
        return false
    end
    for actor, tag_str in pairs(styles) do
        file:write(string.format("%s: %s\n", actor, tag_str))
    end
    file:close()
    aegisub.dialog.display({{class="label", x=0, y=0, label="Styles saved in:\n" .. path}}, {"OK"})
    return true
end

function parse_style_string(style_str)
    local style = {
        blur = 0, be = 0, shad = 0, bord = 0,
        xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
        alpha = "&H00&",
        ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
        ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
        ["1a"] = "&H00&", ["2a"] = "&H00&",
        ["3a"] = "&H00&", ["4a"] = "&H00&"
    }
    local blur = style_str:match("\\blur([%d%.]+)")
    if blur then style.blur = tonumber(blur) end
    local be = style_str:match("\\be([%d%.]+)")
    if be then style.be = tonumber(be) end
    local shad = style_str:match("\\shad([%d%.]+)")
    if shad then style.shad = tonumber(shad) end
    local bord = style_str:match("\\bord([%d%.]+)")
    if bord then style.bord = tonumber(bord) end
    local xshad = style_str:match("\\xshad([%-%d%.]+)")
    if xshad then style.xshad = tonumber(xshad) end
    local yshad = style_str:match("\\yshad([%-%d%.]+)")
    if yshad then style.yshad = tonumber(yshad) end
    local fscx = style_str:match("\\fscx([%d%.]+)")
    if fscx then style.fscx = tonumber(fscx) end
    local fscy = style_str:match("\\fscy([%d%.]+)")
    if fscy then style.fscy = tonumber(fscy) end
    local fsp = style_str:match("\\fsp([%-%d%.]+)")
    if fsp then style.fsp = tonumber(fsp) end
    local alpha = style_str:match("\\alpha(&H%x%x&)")
    if alpha then style.alpha = alpha end
    for i = 1, 4 do
        local pattern = "\\" .. i .. "c(&H%x+&)"
        local ass_color = style_str:match(pattern)
        if ass_color then 
            style[i.."c"] = ass_to_rgb(ass_color)
            style["mod" .. i .. "c"] = true
        else
            style["mod" .. i .. "c"] = false
        end
        local alpha_pattern = "\\" .. i .. "a(&H%x%x&)"
        local color_alpha = style_str:match(alpha_pattern)
        if color_alpha then style[i.."a"] = color_alpha end
    end
    return style
end

function load_styles(subs, sel, actor_list)
    local suggested_path = ""
    local filename = aegisub.file_name()
    if filename then
        suggested_path = aegisub.decode_path("?script/" .. filename:gsub("%..-$", "") .. " [Kite Styles].txt")
    end
    local dialog_config = {
        {class="label", x=0, y=0, label="Select styles file:"},
        {class="edit", x=0, y=1, width=40, name="file_path", value=suggested_path}
    }
    local button, result = aegisub.dialog.display(dialog_config, {"Load", "Cancel"})
    if button == "Cancel" then return false end
    local path = result.file_path
    local file, err = io.open(path, "r")
    if not file then
        aegisub.dialog.display({{class="label", x=0, y=0, label="Styles file not found:\n" .. path}}, {"OK"})
        return false
    end
    local loaded_styles = {}
    for line in file:lines() do
        local actor, style_str = line:match("^([^:]+):%s*(.+)$")
        if actor and style_str then
            loaded_styles[actor] = parse_style_string(style_str)
        end
    end
    file:close()
    local missing_actors = {}
    for _, actor in ipairs(actor_list) do
        if not loaded_styles[actor] then
            table.insert(missing_actors, actor)
        end
    end
    local extra_actors = {}
    for actor in pairs(loaded_styles) do
        if not table.contains(actor_list, actor) then
            table.insert(extra_actors, actor)
        end
    end
    local log_text = ""
    if #missing_actors > 0 then
        log_text = log_text .. "Actors not present in the styles file:\n" .. table.concat(missing_actors, "\n") .. "\n\n"
    end
    if #extra_actors > 0 then
        log_text = log_text .. "Actors in the file but not in the selection:\n" .. table.concat(extra_actors, "\n")
    end
    if log_text == "" then
        log_text = "All actors loaded correctly."
    end
    for actor, style in pairs(loaded_styles) do
        actor_styles[actor] = style
        actor_ui_values[actor] = deepcopy(style)
    end
    local modified_count = 0
    local neutral = {
        blur = 0, be = 0, shad = 0, bord = 0,
        xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
        alpha = "&H00&",
        ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
        ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
        ["1a"] = "&H00&", ["2a"] = "&H00&",
        ["3a"] = "&H00&", ["4a"] = "&H00&",
        mod1c = false, mod2c = false, mod3c = false, mod4c = false
    }
    local known_tags = {"blur","be","shad","bord","xshad","yshad","fsp","fscx","fscy","alpha",
                          "1c","2c","3c","4c","1a","2a","3a","4a"}
    for _, i in ipairs(sel) do
        local line = subs[i]
        local actor = (line.actor == "" and "No Actor") or line.actor
        if actor_styles[actor] then
            local original_tagblock = line.text:match("^{(.-)}") or ""
            for _, tag in ipairs(known_tags) do
                original_tagblock = original_tagblock:gsub("\\" .. tag .. "[^\\}]*", "")
            end
            local rest = line.text:gsub("^{[^}]*}", "")
            local combined_tags = build_style_string(actor_styles[actor], neutral) .. original_tagblock
            if combined_tags == "" then
                line.text = rest
            else
                line.text = "{" .. combined_tags .. "}" .. rest
            end
            subs[i] = line
            modified_count = modified_count + 1
        end
    end
    log_text = log_text .. "\n\nModified lines: " .. modified_count
    aegisub.dialog.display({{class="textbox", x=0, y=0, width=40, height=10, name="log", value=log_text}}, {"OK"})
    aegisub.set_undo_point("Load Styles")
    return true
end

function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function get_actors_from_selection(subs, sel)
    local actors = {}
    local actor_count = {}
    for _, i in ipairs(sel) do
        local line = subs[i]
        if line.class == "dialogue" then
            local actor_name = line.actor
            if actor_name == "" then actor_name = "No Actor" end
            if not actor_count[actor_name] then
                actor_count[actor_name] = 1
                table.insert(actors, actor_name)
            else
                actor_count[actor_name] = actor_count[actor_name] + 1
            end
        end
    end
    table.sort(actors, function(a, b)
        if a == "No Actor" then return true
        elseif b == "No Actor" then return false
        else return a < b end
    end)
    return actors, actor_count
end

function update_dialog_for_actor(actor, config)
    local current_style = actor_ui_values[actor] or actor_styles[actor] or {
        blur = 0, be = 0, shad = 0, bord = 0,
        xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
        alpha = "&H00&",
        ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
        ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
        ["1a"] = "&H00&", ["2a"] = "&H00&",
        ["3a"] = "&H00&", ["4a"] = "&H00&",
        mod1c = false, mod2c = false, mod3c = false, mod4c = false
    }
    for _, field in ipairs({"blur", "be", "bord", "shad", "xshad", "yshad", "fsp", "fscx", "fscy"}) do
        for i, control in ipairs(config) do
            if control.name == field then
                config[i].value = current_style[field] or ((field=="fscx" or field=="fscy") and 100 or 0)
            end
        end
    end
    for i, control in ipairs(config) do
        if control.name == "alpha" then
            config[i].value = current_style.alpha or "&H00&"
        end
    end
    for i = 1, 4 do
        for j, control in ipairs(config) do
            if control.name == "c" .. i then
                config[j].value = current_style[i.."c"] or "#FFFFFF"
            end
        end
        for j, control in ipairs(config) do
            if control.name == "mod" .. i .. "c" then
                config[j].value = current_style["mod" .. i .. "c"] or false
            end
        end
        for j, control in ipairs(config) do
            if control.name == "a" .. i then
                config[j].value = current_style[i.."a"] or "&H00&"
            end
        end
    end
    return config
end

function main(subs, sel)
    if #sel == 0 then
        aegisub.dialog.display({{class="label", x=0, y=0, label="No lines selected."}}, {"OK"})
        return
    end
    actor_styles = load_actor_styles(subs)
    local actors, actor_count = get_actors_from_selection(subs, sel)
    if #actors == 0 then
        actors = {"No Actor"}
        actor_styles["No Actor"] = {
            blur = 0, be = 0, shad = 0, bord = 0,
            xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
            alpha = "&H00&",
            ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
            ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
            ["1a"] = "&H00&", ["2a"] = "&H00&",
            ["3a"] = "&H00&", ["4a"] = "&H00&",
            mod1c = false, mod2c = false, mod3c = false, mod4c = false
        }
    end
    if next(actor_ui_values) == nil then
        for _, actor in ipairs(actors) do
            actor_ui_values[actor] = deepcopy(actor_styles[actor] or {
                blur = 0, be = 0, shad = 0, bord = 0,
                xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
                alpha = "&H00&",
                ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
                ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
                ["1a"] = "&H00&", ["2a"] = "&H00&",
                ["3a"] = "&H00&", ["4a"] = "&H00&",
                mod1c = false, mod2c = false, mod3c = false, mod4c = false
            })
        end
    end
    local current_actor = actors[1]
    local actor_labels = {}
    for i, actor in ipairs(actors) do
        local count = actor_count[actor] or 0
        actor_labels[i] = actor .. " (" .. count .. " lines)"
    end
    local config_base = {
        {class="label", x=0, y=0, width=1, height=1, label="Actor:"},
        {class="dropdown", name="selected_actor", x=1, y=0, width=4, height=1, items=actor_labels, value=current_actor .. " (" .. (actor_count[current_actor] or 0) .. " lines)"},
        {class="label", x=0, y=1, width=5, height=1, label="Basic Effects:", bold=true},
        {class="label", x=0, y=2, width=1, height=1, label="Blur:"},
        {class="floatedit", x=1, y=2, width=1, height=1, name="blur", value=0, min=0},
        {class="label", x=2, y=2, width=1, height=1, label="Be:"},
        {class="floatedit", x=3, y=2, width=1, height=1, name="be", value=0, min=0},
        {class="label", x=0, y=3, width=1, height=1, label="Border:"},
        {class="floatedit", x=1, y=3, width=1, height=1, name="bord", value=0, min=0},
        {class="label", x=2, y=3, width=1, height=1, label="Shadow:"},
        {class="floatedit", x=3, y=3, width=1, height=1, name="shad", value=0, min=0},
        {class="label", x=0, y=4, width=5, height=1, label="Advanced Shadows:", bold=true},
        {class="label", x=0, y=5, width=1, height=1, label="X Shadow:"},
        {class="floatedit", x=1, y=5, width=1, height=1, name="xshad", value=0},
        {class="label", x=2, y=5, width=1, height=1, label="Y Shadow:"},
        {class="floatedit", x=3, y=5, width=1, height=1, name="yshad", value=0},
        {class="label", x=0, y=6, width=5, height=1, label="Text Format:", bold=true},
        {class="label", x=0, y=7, width=1, height=1, label="Spacing:"},
        {class="floatedit", x=1, y=7, width=1, height=1, name="fsp", value=0},
        {class="label", x=2, y=7, width=1, height=1, label="Global Alpha:"},
        {class="edit", x=3, y=7, width=1, height=1, name="alpha", value="&H00&"},
        {class="label", x=0, y=8, width=1, height=1, label="Scale X:"},
        {class="floatedit", x=1, y=8, width=1, height=1, name="fscx", value=100, min=0},
        {class="label", x=2, y=8, width=1, height=1, label="Scale Y:"},
        {class="floatedit", x=3, y=8, width=1, height=1, name="fscy", value=100, min=0},
        {class="label", x=0, y=9, width=5, height=1, label="Colors:", bold=true},
        {class="label", x=0, y=10, width=1, height=1, label="Primary (1c):"},
        {class="color", x=1, y=10, width=1, height=1, name="c1", value="#FFFFFF"},
        {class="checkbox", x=2, y=10, width=1, height=1, name="mod1c", value=false, label="Modify"},
        {class="label", x=3, y=10, width=1, height=1, label="Alpha 1:"},
        {class="edit", x=4, y=10, width=1, height=1, name="a1", value="&H00&"},
        {class="label", x=0, y=11, width=1, height=1, label="Secondary (2c):"},
        {class="color", x=1, y=11, width=1, height=1, name="c2", value="#FFFFFF"},
        {class="checkbox", x=2, y=11, width=1, height=1, name="mod2c", value=false, label="Modify"},
        {class="label", x=3, y=11, width=1, height=1, label="Alpha 2:"},
        {class="edit", x=4, y=11, width=1, height=1, name="a2", value="&H00&"},
        {class="label", x=0, y=12, width=1, height=1, label="Border (3c):"},
        {class="color", x=1, y=12, width=1, height=1, name="c3", value="#FFFFFF"},
        {class="checkbox", x=2, y=12, width=1, height=1, name="mod3c", value=false, label="Modify"},
        {class="label", x=3, y=12, width=1, height=1, label="Alpha 3:"},
        {class="edit", x=4, y=12, width=1, height=1, name="a3", value="&H00&"},
        {class="label", x=0, y=13, width=1, height=1, label="Shadow (4c):"},
        {class="color", x=1, y=13, width=1, height=1, name="c4", value="#FFFFFF"},
        {class="checkbox", x=2, y=13, width=1, height=1, name="mod4c", value=false, label="Modify"},
        {class="label", x=3, y=13, width=1, height=1, label="Alpha 4:"},
        {class="edit", x=4, y=13, width=1, height=1, name="a4", value="&H00&"}
    }
    local buttons = {"Refresh", "Apply", "Save All", "Load Styles", "Export Styles", "Help", "Cancel"}
    local button, result
    repeat
        config_base[2].value = current_actor .. " (" .. (actor_count[current_actor] or 0) .. " lines)"
        local config = update_dialog_for_actor(current_actor, deepcopy(config_base))
        button, result = aegisub.dialog.display(config, buttons)
        local new_actor = result.selected_actor:match("^(.-) %(") or result.selected_actor
        if new_actor ~= current_actor then
            current_actor = new_actor
            button = "Refresh"
        end
        if button == "Cancel" then
            aegisub.cancel()
        elseif button == "Help" then
            local help_text = [[Kite Styles Manager v1.4 - Help

Basic Functionality:
  • Select an actor from the dropdown. The fields show the current recognized style tags.
  • Modify the desired values and check "Modify" for the colors you wish to change.
  • Click "Refresh" button reloads the dialog with the stored values for the selected actor.
  • Click "Apply" to update the stored style for the active actor (this does not immediately modify the subtitles).
  • Click "Save All" to apply all stored changes to the selected lines.

Neutral Values (Unchanged):
  • Blur, Be, Border, Shadow, XShad, YShad, Fsp: 0
  • FscX, FscY: 100
  • Colors remain unchanged unless "Modify" is checked.
  • Alpha: &H00& 
  
Save and Load:
  • Load Styles: Imports styles from a previously saved file.
  • Export Styles: Saves all actor styles to a file.
  • Changes accumulate per actor until "Save All" is pressed.]]
            aegisub.dialog.display({{class="textbox", x=0, y=0, width=50, height=20, name="help_text", value=help_text}}, {"OK"})
            button = "Refresh"
        elseif button == "Export Styles" then
            local styles_to_export = {}
            local neutral = {
                blur = 0, be = 0, shad = 0, bord = 0,
                xshad = 0, yshad = 0, fsp = 0, fscx = 100, fscy = 100,
                alpha = "&H00&",
                ["1c"] = "#FFFFFF", ["2c"] = "#FFFFFF",
                ["3c"] = "#FFFFFF", ["4c"] = "#FFFFFF",
                ["1a"] = "&H00&", ["2a"] = "&H00&",
                ["3a"] = "&H00&", ["4a"] = "&H00&",
                mod1c = false, mod2c = false, mod3c = false, mod4c = false
            }
            for _, actor in ipairs(actors) do
                local style = actor_styles[actor] or neutral
                styles_to_export[actor] = build_style_string(style, neutral)
            end
            save_styles(styles_to_export)
            button = "Refresh"
        elseif button == "Load Styles" then
            load_styles(subs, sel, actors)
            button = "Refresh"
        elseif button == "Apply" then
            local new_style = {
                blur = result.blur or 0,
                be = result.be or 0,
                shad = result.shad or 0,
                bord = result.bord or 0,
                xshad = result.xshad or 0,
                yshad = result.yshad or 0,
                fsp = result.fsp or 0,
                fscx = result.fscx or 100,
                fscy = result.fscy or 100,
                alpha = result.alpha or "&H00&",
                ["1c"] = result.c1 or "#FFFFFF",
                ["2c"] = result.c2 or "#FFFFFF",
                ["3c"] = result.c3 or "#FFFFFF",
                ["4c"] = result.c4 or "#FFFFFF",
                ["1a"] = result.a1 or "&H00&",
                ["2a"] = result.a2 or "&H00&",
                ["3a"] = result.a3 or "&H00&",
                ["4a"] = result.a4 or "&H00&",
                mod1c = result.mod1c,
                mod2c = result.mod2c,
                mod3c = result.mod3c,
                mod4c = result.mod4c
            }
            actor_styles[current_actor] = new_style
            actor_ui_values[current_actor] = deepcopy(new_style)
            aegisub.dialog.display({{class="label", x=0, y=0, label="Changes applied for " .. current_actor}}, {"OK"})
            button = "Refresh"
        elseif button == "Save All" then
            local modified = save_all_changes(subs, sel, actors)
            aegisub.set_undo_point("Save All Changes")
            aegisub.dialog.display({{class="label", x=0, y=0, label="Total modified lines: " .. modified}}, {"OK"})
            break
        end
    until false
end

aegisub.register_macro(script_name, script_description, main)
