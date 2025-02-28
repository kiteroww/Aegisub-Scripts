script_name = "Froggie Tags"
script_description = "Move tags between text and effects field with improved handling"
script_author = "Kiterow"
script_version = "1.2"

include("karaskel.lua")

function extract_tags(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]
        local text = line.text
        
        local tags = text:match("^{[^}]*}")
        if tags then
            text = text:gsub("^{[^}]*}", "")
            text = text:gsub("^%s*(.-)%s*$", "%1")
            line.effect = tags
            line.text = text
        else
            line.effect = ""
        end
        
        subs[i] = line
    end
    aegisub.set_undo_point("Extract Tags")
end

function reinsert_tags(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]
        
        if line.effect ~= "" then
            local modified_effect = line.effect:gsub(";", ",")
            line.text = modified_effect .. line.text
            line.effect = ""
        end
        
        subs[i] = line
    end
    aegisub.set_undo_point("Reinsert Tags")
end

aegisub.register_macro(script_name .. "/Extract", "Extract initial tags to effects", extract_tags)
aegisub.register_macro(script_name .. "/Reinsert", "Move tags from effects to text", reinsert_tags)