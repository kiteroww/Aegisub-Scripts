script_name = "Zheus Colormaster"
script_description = "Color & Animation Master Suite"
script_author = "Kiterow"
script_version = "2.0"
menu_embedding = "Kite-Macros/"

require"karaskel"
local u = require'aegisub.unicode'
local Z = {C={}, S={}, T={}, A={}, U={}}

local CFG_FILE = aegisub.decode_path("?user") .. "/zheus_config.lua"

function Z.U.SaveCfg(r)
    local keys = {"it","gdir","gt","iv1","iv2","gc1","gc2","inm","ia","iacv","iy","g3","gc3","g4","gc4","itb","ims","ioff","g5","gc5","kc1","kc2","kct","vct","vcl","vc1","vc2","vc3","vc4"}
    local f = io.open(CFG_FILE, "w")
    if not f then return end
    f:write("return {\n")
    for _, k in ipairs(keys) do
        local v = r[k]
        if v ~= nil then
            if type(v) == "string" then
                f:write(string.format("  [%q]=%q,\n", k, v))
            elseif type(v) == "number" then
                if v ~= v or v == math.huge or v == -math.huge then v = 0 end
                f:write(string.format("  [%q]=%s,\n", k, v))
            elseif type(v) == "boolean" then
                f:write(string.format("  [%q]=%s,\n", k, tostring(v)))
            end
        end
    end
    f:write("}\n")
    f:close()
end

function Z.U.LoadCfg()
    local f = io.open(CFG_FILE, "r")
    if not f then return {} end
    local src = f:read("*a")
    f:close()
    local chunk = loadstring(src)
    if not chunk then return {} end
    local ok, cfg = pcall(chunk)
    return ok and type(cfg) == "table" and cfg or {}
end

local saved_cfg = Z.U.LoadCfg()

function Z.C.Normalize(c)
    if not c or c == "" then return "&HFFFFFF&" end
    if type(c) == "number" then
        if c < 0 then c = c + 4294967296 end
        return string.format("&H%06X&", c % 16777216)
    end
    local hex = c:match("&[Hh]([%xA-Fa-f]+)&?")
    if hex then
        if #hex > 6 then hex = hex:sub(-6) end
        return "&H" .. hex:upper() .. "&"
    end
    local rgb = c:match("#([%xA-Fa-f]+)")
    if rgb and #rgb >= 6 then
        local r, g, b = rgb:sub(1,2), rgb:sub(3,4), rgb:sub(5,6)
        return "&H" .. b:upper() .. g:upper() .. r:upper() .. "&"
    end
    return "&HFFFFFF&"
end

function Z.C.FromStyle(n)
    if type(n) == "string" then return Z.C.Normalize(n) end
    if type(n) ~= "number" then return "&HFFFFFF&" end
    if n < 0 then n = n + 4294967296 end
    return string.format("&H%06X&", n % 16777216)
end

function Z.C.ToNumber(c)
    local hex = Z.C.Normalize(c):match("&H([%x]+)&")
    if not hex then return 16777215 end
    if #hex > 6 then hex = hex:sub(-6) end
    return tonumber(hex, 16) or 16777215
end

function Z.C.ToHex(c)
    local n = Z.C.ToNumber(c)
    local b = math.floor(n / 65536) % 256
    local g = math.floor(n / 256) % 256
    local r = n % 256
    return string.format("#%02X%02X%02X", r, g, b)
end

function Z.C.FromHex(h)
    local rgb = h:match("#([%xA-Fa-f]+)")
    if not rgb or #rgb < 6 then return "&HFFFFFF&" end
    local r, g, b = rgb:sub(1,2), rgb:sub(3,4), rgb:sub(5,6)
    return "&H" .. b:upper() .. g:upper() .. r:upper() .. "&"
end

function Z.C.Mix(f, c1, c2)
    f = math.max(0, math.min(1, f))
    local n1, n2 = Z.C.ToNumber(c1), Z.C.ToNumber(c2)
    local b1, g1, r1 = math.floor(n1/65536)%256, math.floor(n1/256)%256, n1%256
    local b2, g2, r2 = math.floor(n2/65536)%256, math.floor(n2/256)%256, n2%256
    return string.format("&H%02X%02X%02X&", 
        math.floor(b1+(b2-b1)*f), math.floor(g1+(g2-g1)*f), math.floor(r1+(r2-r1)*f))
end

function Z.C.Lum(c)
    local n = Z.C.ToNumber(c)
    local b, g, r = (math.floor(n/65536)%256)/255, (math.floor(n/256)%256)/255, (n%256)/255
    local f = function(v) return v <= 0.03928 and v/12.92 or ((v+0.055)/1.055)^2.4 end
    return 0.2126*f(r) + 0.7152*f(g) + 0.0722*f(b)
end

function Z.C.Rat(c1, c2)
    local l1, l2 = Z.C.Lum(c1) + 0.05, Z.C.Lum(c2) + 0.05
    return (l1 > l2) and l1/l2 or l2/l1
end

function Z.C.Grad(i, n, cl)
    if n <= 1 or #cl < 2 then return Z.C.Normalize(cl[1] or "&HFFFFFF&") end
    local f = (i-1)/(n-1)
    local s = #cl - 1
    local k = math.max(1, math.min(math.floor(f * s) + 1, s))
    local localF = (f - (k-1)/s) * s
    localF = math.max(0, math.min(1, localF))
    return Z.C.Mix(localF, cl[k], cl[k+1])
end

function Z.C.Alpha(f, a1, a2)
    local s1 = type(a1) == "string" and a1 or "00"
    local s2 = type(a2) == "string" and a2 or "00"
    local v1 = tonumber(s1:match("%x+"), 16) or 0
    local v2 = tonumber(s2:match("%x+"), 16) or 0
    return string.format("&H%02X&", math.floor(v1 + (v2 - v1) * f))
end

function Z.S.Cl(t)
    if not t then return "" end
    t = t:gsub("\\[1-4]?c&H%x+&", "")
    t = t:gsub("\\[1-4]?vc%([^)]+%)", "")
    t = t:gsub("\\t%([^)]-,?\\[1-4]?c&H%x+&%)", "")
    t = t:gsub("\\t%([%d%s,%.%-]*)%)", "")
    t = t:gsub("{%s*}", "")
    return t
end

function Z.S.GetSty(subs)
    local s = {}
    for i = 1, #subs do
        if subs[i].class == "style" then s[subs[i].name] = subs[i] end
    end
    return s
end

function Z.S.Scan(subs, sel, sm)
    local d, act = {}, {}
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto continue end
        local a = (l.actor and l.actor ~= "") and l.actor or "[Sin Actor]"
        if not d[a] then
            local s = sm[l.style] or sm["Default"]
            local sc1 = s and Z.C.FromStyle(s.color1) or "&HFFFFFF&"
            local sc2 = s and Z.C.FromStyle(s.color2) or "&H000000&"
            local sc3 = s and Z.C.FromStyle(s.color3) or "&H000000&"
            local sc4 = s and Z.C.FromStyle(s.color4) or "&H000000&"
            d[a] = {
                ids = {},
                c = {
                    c = sc1,
                    ["2c"] = sc2,
                    ["3c"] = sc3,
                    ["4c"] = sc4
                },
                vc = {
                    ["1vc"] = {sc1, sc1, sc1, sc1},
                    ["3vc"] = {sc3, sc3, sc3, sc3},
                    ["4vc"] = {sc4, sc4, sc4, sc4}
                },
                hasVSF = false,
                mx = false,
                line_count = 0,
                conflicts = {}
            }
            table.insert(act, a)
        end
        table.insert(d[a].ids, i)
        d[a].line_count = d[a].line_count + 1
        for v in l.text:gmatch("\\1?c(&H%x+&)") do
            if d[a].c.c ~= v then d[a].mx = true; table.insert(d[a].conflicts, {ln=i, tag="\\c", old=d[a].c.c, new=v}) end
            d[a].c.c = v
        end
        for n, v in l.text:gmatch("\\([234])c(&H%x+&)") do
            local k = n.."c"
            if d[a].c[k] ~= v then d[a].mx = true; table.insert(d[a].conflicts, {ln=i, tag="\\"..n.."c", old=d[a].c[k], new=v}) end
            d[a].c[k] = v
        end
        for n, colors in l.text:gmatch("\\([1-4])vc%(([^)]+)%)") do
            local k = n.."vc"
            d[a].hasVSF = true
            local cols = {}
            for c in colors:gmatch("(&H%x+&)") do table.insert(cols, Z.C.Normalize(c)) end
            if d[a].vc[k] then
                if #cols >= 4 then
                    d[a].vc[k] = {cols[1], cols[2], cols[3], cols[4]}
                elseif #cols >= 1 then
                    d[a].vc[k][1] = cols[1]
                end
            end
        end
        ::continue::
    end
    table.sort(act)
    return d, act
end

function Z.A.Summary(act, d)
    local lines = {"#  RESUMEN DE ACTORES ", ""}
    for i, a in ipairs(act) do
        local info = d[a]
        local ct = Z.C.Rat(info.c.c, info.c["3c"])
        local flag = ""
        if info.mx then flag = "⚠MX " end
        if ct < 2.5 then flag = flag.."⛔CR:"..string.format("%.1f", ct)
        elseif ct < 4.5 then flag = flag.."CR:"..string.format("%.1f", ct)
        else flag = flag.."✓CR:"..string.format("%.1f", ct) end
        table.insert(lines, string.format("%-15s  c:%s  3c:%s  [%s]", a:sub(1,15), Z.C.ToHex(info.c.c), Z.C.ToHex(info.c["3c"]), flag))
    end
    return table.concat(lines, "\n")
end

function Z.A.Conflicts(act, d)
    local lines = {}
    local totalChanges, totalLowCR, totalVSF, totalDup = 0, 0, 0, 0
    table.insert(lines, "# REPORTE DE CONFLICTOS")
    table.insert(lines, "")
    table.insert(lines, "== CAMBIOS DE COLOR ==")
    table.insert(lines, "")
    local hasChanges = false
    for _, a in ipairs(act) do
        local info = d[a]
        if info.mx and #info.conflicts > 0 then
            hasChanges = true
            table.insert(lines, "► "..a.." ("..info.line_count.." lineas):")
            for _, c in ipairs(info.conflicts) do
                table.insert(lines, string.format("   Linea %d: %s cambio %s -> %s", c.ln, c.tag, Z.C.ToHex(c.old or "&HFFFFFF&"), Z.C.ToHex(c.new)))
                totalChanges = totalChanges + 1
            end
            table.insert(lines, "")
        end
    end
    if not hasChanges then
        table.insert(lines, "  Sin cambios de color detectados.")
        table.insert(lines, "")
    end
    table.insert(lines, "== CONTRASTE (c vs 3c) ==")
    table.insert(lines, "")
    for _, a in ipairs(act) do
        local info = d[a]
        local ct = Z.C.Rat(info.c.c, info.c["3c"])
        local label
        if ct < 2.5 then
            label = "FALLA"
            totalLowCR = totalLowCR + 1
        elseif ct < 4.5 then
            label = "BAJO"
            totalLowCR = totalLowCR + 1
        else
            label = "OK"
        end
        local dup = ""
        if info.c.c == info.c["3c"] then dup = " [c = 3c DUPLICADO]"; totalDup = totalDup + 1 end
        if info.c.c == info.c["4c"] then dup = dup.." [c = 4c]" end
        table.insert(lines, string.format("  %-12s  CR:%.1f %s%s", a:sub(1,12), ct, label, dup))
    end
    table.insert(lines, "")
    table.insert(lines, "== VSF ==")
    table.insert(lines, "")
    local vsfActors, noVsfActors = {}, {}
    for _, a in ipairs(act) do
        if d[a].hasVSF then table.insert(vsfActors, a); totalVSF = totalVSF + 1
        else table.insert(noVsfActors, a) end
    end
    if #vsfActors > 0 and #noVsfActors > 0 then
        table.insert(lines, "  Mezcla de actores con y sin VSFilterMod:")
        table.insert(lines, "  Con VSF: "..table.concat(vsfActors, ", "))
        table.insert(lines, "  Sin VSF: "..table.concat(noVsfActors, ", "))
    elseif #vsfActors > 0 then
        table.insert(lines, "  Todos usan VSFilterMod ("..#vsfActors..")")
    else
        table.insert(lines, "  Sin VSFilterMod.")
    end
    table.insert(lines, "")
    table.insert(lines, "== RESUMEN ==")
    table.insert(lines, "")
    table.insert(lines, "  Actores: "..#act)
    table.insert(lines, "  Cambios de color: "..totalChanges)
    table.insert(lines, "  Contraste bajo/fallido: "..totalLowCR)
    table.insert(lines, "  Color duplicado c=3c: "..totalDup)
    table.insert(lines, "  Con VSFilterMod: "..totalVSF)
    return table.concat(lines, "\n")
end

function Z.A.GUI(pg, lim, act, d, view, vsfTag)
    local total = #act
    local pages = math.max(1, math.ceil(total / lim))
    

    if view == "summary" then
        return {
            {class="label", label="╔═════════ LISTA DE ACTORES ═════════╗", x=0, y=0, width=6},
            {class="textbox", name="tb", text=Z.A.Summary(act, d), x=0, y=1, width=6, height=12},
            {class="label", label="Formato: Actor  c:#RRGGBB  3c:#RRGGBB  [Estado]", x=0, y=13, width=6}
        }, 0
    elseif view == "conflicts" then
        return {
            {class="label", label="╔═════════ REPORTE CONFLICTOS ═════════╗", x=0, y=0, width=6},
            {class="textbox", name="tb", text=Z.A.Conflicts(act, d), x=0, y=1, width=6, height=12},
            {class="label", label="Los conflictos indican colores mixtos en líneas del mismo actor.", x=0, y=13, width=6}
        }, 0
    elseif view == "vsf" then
        local vcTag = vsfTag or "1vc"
        local g = {
            {class="label", label="╔═══════ 4-CORNER MANAGER ═══════╗", x=0, y=0, width=6},
            {class="label", label="Pág "..pg.."/"..pages.."  |  "..total.." actores", x=0, y=1, width=4},
            {class="dropdown", name="vctag", items={"1vc","3vc","4vc"}, value=vcTag, x=4, y=1, width=2, hint="Tag a editar"},
            {class="label", label="─ACTOR─", x=0, y=2},
            {class="label", label="Esq1", x=1, y=2, hint="Esquina sup-izq"},
            {class="label", label="Esq2", x=2, y=2, hint="Esquina sup-der"},
            {class="label", label="Esq3", x=3, y=2, hint="Esquina inf-izq"},
            {class="label", label="Esq4", x=4, y=2, hint="Esquina inf-der"},
            {class="label", label="─VSF─", x=5, y=2}
        }
        local s, e = (pg-1)*lim + 1, math.min(total, pg*lim)
        for k = s, e do
            local a = act[k]
            local r = k - s + 3
            local info = d[a]
            local vc = info.vc[vcTag]
            table.insert(g, {class="label", label=a:sub(1,10), x=0, y=r, hint=a})
            table.insert(g, {class="coloralpha", name="V_"..k.."_1", value=vc[1], x=1, y=r})
            table.insert(g, {class="coloralpha", name="V_"..k.."_2", value=vc[2], x=2, y=r})
            table.insert(g, {class="coloralpha", name="V_"..k.."_3", value=vc[3], x=3, y=r})
            table.insert(g, {class="coloralpha", name="V_"..k.."_4", value=vc[4], x=4, y=r})
            table.insert(g, {class="label", label=info.hasVSF and "✓" or "", x=5, y=r})
        end
        return g, e - s + 1
    end
    

    local g = {
        {class="label", label="╔═════════ CHROMA MANAGER ═════════╗", x=0, y=0, width=5},
        {class="label", label="Pág "..pg.."/"..pages.."  |  "..total.." actores", x=0, y=1, width=3},
        {class="label", label="──ACTOR──", x=0, y=2},
        {class="label", label="\\c", x=1, y=2},
        {class="label", label="\\3c", x=2, y=2},
        {class="label", label="\\4c", x=3, y=2},
        {class="label", label="──INFO──", x=4, y=2}
    }
    local s, e = (pg-1)*lim + 1, math.min(total, pg*lim)
    for k = s, e do
        local a = act[k]
        local r = k - s + 3
        local info = d[a]
        table.insert(g, {class="label", label=a:sub(1,12), x=0, y=r, hint=a.." ("..info.line_count.." líneas)"})
        table.insert(g, {class="coloralpha", name="C_"..k.."_c", value=info.c.c, x=1, y=r})
        table.insert(g, {class="coloralpha", name="C_"..k.."_3c", value=info.c["3c"], x=2, y=r})
        table.insert(g, {class="coloralpha", name="C_"..k.."_4c", value=info.c["4c"], x=3, y=r})
        local ct = Z.C.Rat(info.c.c, info.c["3c"])
        local status = info.mx and "⚠MX " or ""
        if info.hasVSF then status = status.."VSF " end
        if ct < 2.5 then status = status.."⛔"..string.format("%.1f", ct)
        elseif ct < 4.5 then status = status..string.format("%.1f", ct)
        else status = status.."✓"..string.format("%.1f", ct) end
        table.insert(g, {class="label", label=status, x=4, y=r})
    end
    return g, e - s + 1
end

function Z.A.Sync(d, act, res, pg, lim, mode, vsfTag)
    local s, e = (pg-1)*lim + 1, math.min(#act, pg*lim)
    for k = s, e do
        local a = act[k]
        if mode == "vsf" and vsfTag then
            if res["V_"..k.."_1"] then
                d[a].vc[vsfTag][1] = res["V_"..k.."_1"]
                d[a].vc[vsfTag][2] = res["V_"..k.."_2"]
                d[a].vc[vsfTag][3] = res["V_"..k.."_3"]
                d[a].vc[vsfTag][4] = res["V_"..k.."_4"]
            end
        elseif not mode then
            if res["C_"..k.."_c"] then
                d[a].c.c = res["C_"..k.."_c"]
                d[a].c["3c"] = res["C_"..k.."_3c"]
                d[a].c["4c"] = res["C_"..k.."_4c"]
            end
        end
    end
end

function Z.A.Exec(subs, d, act, sm, op, cl, vsfMode, vsfTag)
    local cnt = 0
    
    if op == "Estilos" and vsfMode then
        return -1, "Error: Los estilos ASS no soportan colores VSFilterMod.\nUsa 'Tags' para aplicar los colores."
    end
    
    if op == "Estilos" then
        local styleMap = {}
        local newStyles = {}
        local pos = 1
        for si = 1, #subs do
            if subs[si].class == "style" then pos = si + 1 end
        end
        for _, a in ipairs(act) do
            local sc1 = Z.C.Normalize(d[a].c.c)
            local sc3 = Z.C.Normalize(d[a].c["3c"])
            local sc4 = Z.C.Normalize(d[a].c["4c"])
            local firstId = d[a].ids[1]
            if not firstId or not subs[firstId] or subs[firstId].class ~= "dialogue" then goto skipActor end
            local styleName = subs[firstId].style
            local base = sm[styleName]
            local rawName = a:gsub("[^%w_]", "_").."_Z"
            local name = rawName
            if styleMap[name] then
                local suf = 2
                while styleMap[rawName..suf] do suf = suf + 1 end
                name = rawName..suf
            end
            local ns = {class="style", name=name}
            if base then
                for k, v in pairs(base) do
                    if k ~= "name" and k ~= "class" then ns[k] = v end
                end
            else
                ns.fontname = "Arial"; ns.fontsize = 48
                ns.bold = false; ns.italic = false; ns.underline = false; ns.strikeout = false
                ns.scale_x = 100; ns.scale_y = 100; ns.spacing = 0; ns.angle = 0
                ns.borderstyle = 1; ns.outline = 2; ns.shadow = 2; ns.align = 2
                ns.margin_l = 10; ns.margin_r = 10; ns.margin_t = 10; ns.margin_b = 10
                ns.encoding = 1
            end
            ns.color1 = string.format("&H00%06X&", Z.C.ToNumber(sc1))
            ns.color2 = base and base.color2 or "&H000000FF&"
            ns.color3 = string.format("&H00%06X&", Z.C.ToNumber(sc3))
            ns.color4 = string.format("&H00%06X&", Z.C.ToNumber(sc4))
            local existingIdx = nil
            for si = 1, #subs do
                if subs[si].class == "style" and subs[si].name == name then
                    existingIdx = si
                    break
                end
            end
            if existingIdx then
                subs[existingIdx] = ns
            else
                table.insert(newStyles, ns)
            end
            styleMap[a] = name
            ::skipActor::
        end
        for si = #newStyles, 1, -1 do
            subs.insert(pos, newStyles[si])
        end
        local offset = #newStyles
        for _, a in ipairs(act) do
            local sname = styleMap[a]
            if not sname then goto skipDlg end
            for _, id in ipairs(d[a].ids) do
                local idx = id + offset
                local l = subs[idx]
                if l and l.class == "dialogue" then
                    l.style = sname
                    if cl then l.text = Z.S.Cl(l.text) end
                    subs[idx] = l
                    cnt = cnt + 1
                end
            end
            ::skipDlg::
        end
        return cnt
    end
    
    for _, a in ipairs(act) do
        local c1 = Z.C.Normalize(d[a].c.c)
        local c3 = Z.C.Normalize(d[a].c["3c"])
        local c4 = Z.C.Normalize(d[a].c["4c"])
        
        if op == "Tags" then
            for _, id in ipairs(d[a].ids) do
                local l = subs[id]
                if cl then l.text = Z.S.Cl(l.text) end
                
                local tags
                if vsfMode and vsfTag then
                    local vc = d[a].vc[vsfTag]
                    tags = "\\"..vsfTag.."("..Z.C.Normalize(vc[1])..","..Z.C.Normalize(vc[2])..","..Z.C.Normalize(vc[3])..","..Z.C.Normalize(vc[4])..")"
                    local n = vsfTag:sub(1,1)
                    l.text = l.text:gsub("\\"..n.."vc%([^)]+%)", "")
                    if n == "1" then
                        l.text = l.text:gsub("\\1?c&H%x+&", "")
                    else
                        l.text = l.text:gsub("\\"..n.."c&H%x+&", "")
                    end
                    l.text = l.text:gsub("{%s*}", "")
                else
                    tags = "\\c"..c1.."\\3c"..c3.."\\4c"..c4
                    local head = l.text:match("^{[^}]*}")
                    if head then
                        local cleaned = head:gsub("\\[1-4]?c&H%x+&", "")
                        l.text = cleaned .. l.text:sub(#head + 1)
                        l.text = l.text:gsub("{%s*}", "")
                    end
                end
                
                if l.text:match("^{") then
                    l.text = l.text:gsub("^{", "{"..tags)
                else
                    l.text = "{"..tags.."}"..l.text
                end
                subs[id] = l
                cnt = cnt + 1
            end
        elseif op == "Limpiar" then
            for _, id in ipairs(d[a].ids) do
                local l = subs[id]
                l.text = Z.S.Cl(l.text)
                subs[id] = l
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

function Z.A.IO(d, act, mode)
    if mode == "Export" then
        local fp = aegisub.dialog.save("Exportar Colores", "", "", "*.txt", false)
        if not fp then return nil end
        local f = io.open(fp, "w")
        if not f then return "Error al escribir" end
        local hasAnyVSF = false
        for _, a in ipairs(act) do if d[a].hasVSF then hasAnyVSF = true; break end end
        f:write("# Zheus Color Database v2\n")
        f:write("# Type: " .. (hasAnyVSF and "VSF" or "NORMAL") .. "\n")
        f:write("# Actor|c,3c,4c[|1vc:c1,c2,c3,c4|...]\n\n")
        for _, a in ipairs(act) do
            local line = a.."|"..d[a].c.c..","..d[a].c["3c"]..","..d[a].c["4c"]
            if d[a].hasVSF then
                for _, tag in ipairs({"1vc", "3vc", "4vc"}) do
                    local vc = d[a].vc[tag]
                    if vc then
                        line = line.."|"..tag..":"..vc[1]..","..vc[2]..","..vc[3]..","..vc[4]
                    end
                end
            end
            f:write(line.."\n")
        end
        f:close()
        return "Exportados "..#act.." actores"
    else
        local fn = aegisub.dialog.open("Importar Colores", "", "", "*.txt", false, true)
        if not fn then return nil end
        local f = io.open(fn, "r")
        if not f then return "Error al leer" end
        local imported, missing, hasVSFData = 0, {}, false
        local updated = {}
        for l in f:lines() do
            if not l:match("^#") and l ~= "" then
                local parts = {}
                for p in l:gmatch("[^|]+") do table.insert(parts, p) end
                if #parts >= 2 then
                    local actor = parts[1]
                    if d[actor] then
                        local t = {}
                        for x in parts[2]:gmatch("[^,]+") do table.insert(t, x) end
                        if #t >= 3 then
                            d[actor].c.c = Z.C.Normalize(t[1])
                            d[actor].c["3c"] = Z.C.Normalize(t[2])
                            d[actor].c["4c"] = Z.C.Normalize(t[3])
                            imported = imported + 1
                            updated[actor] = true
                        end
                        for pi = 3, #parts do
                            local tag, cols = parts[pi]:match("^(%dvc):(.+)$")
                            if tag and cols and d[actor].vc[tag] then
                                local vc = {}
                                for x in cols:gmatch("[^,]+") do table.insert(vc, Z.C.Normalize(x)) end
                                if #vc >= 4 then
                                    d[actor].vc[tag] = {vc[1], vc[2], vc[3], vc[4]}
                                    d[actor].hasVSF = true
                                    hasVSFData = true
                                end
                            end
                        end
                    else
                        table.insert(missing, actor)
                    end
                end
            end
        end
        f:close()
        local noData = {}
        for _, a in ipairs(act) do
            if not updated[a] then table.insert(noData, a) end
        end
        local msg = "Importados: "..imported.."/"..#act
        if #missing > 0 then
            local ml = table.concat(missing, ", ")
            msg = msg.."\nEn archivo pero no en seleccion: "..ml:sub(1, 60)
            if #ml > 60 then msg = msg.."..." end
        end
        if #noData > 0 then
            local nl = table.concat(noData, ", ")
            msg = msg.."\nSin datos en archivo: "..nl:sub(1, 60)
            if #nl > 60 then msg = msg.."..." end
        end
        return msg, hasVSFData
    end
end



function Z.T.Grad(subs, sel, cfg)
    local cl = {cfg.gc1, cfg.gc2}
    if cfg.g3 then table.insert(cl, cfg.gc3) end
    if cfg.g4 then table.insert(cl, cfg.gc4) end
    if cfg.g5 then table.insert(cl, cfg.gc5) end
    
    if cfg.gdir == "Linea" then
        for i, x in ipairs(sel) do
            local l = subs[x]
            local color = Z.C.Grad(i, #sel, cl)
            local cleaned = Z.S.Cl(l.text)
            if cleaned:match("^{") then
                l.text = cleaned:gsub("^{", "{"..cfg.gt..color)
            else
                l.text = "{"..cfg.gt..color.."}"..cleaned
            end
            subs[x] = l
        end
    else
        for _, x in ipairs(sel) do
            local l = subs[x]
            local head = l.text:match("^{[^}]*}") or ""
            local body = l.text:sub(#head + 1)
            
            local tokens = {}
            local pos = 1
            while pos <= #body do
                if body:sub(pos, pos+1) == "\\N" then
                    table.insert(tokens, {type="break", val="\\N"})
                    pos = pos + 2
                elseif body:sub(pos, pos+1) == "\\n" then
                    table.insert(tokens, {type="break", val="\\n"})
                    pos = pos + 2
                elseif body:sub(pos, pos) == "{" then
                    local j = body:find("}", pos)
                    if j then
                        table.insert(tokens, {type="tag", val=body:sub(pos, j)})
                        pos = j + 1
                    else
                        pos = pos + 1
                    end
                else
                    local ch = ""
                    for c in u.chars(body:sub(pos)) do ch = c; break end
                    if ch ~= "" then
                        table.insert(tokens, {type="char", val=ch})
                        pos = pos + #ch
                    else
                        pos = pos + 1
                    end
                end
            end
            
            local total = 0
            for _, tok in ipairs(tokens) do
                if tok.type == "char" then total = total + 1 end
            end
            if total == 0 then goto skip end
            local result, idx = "", 1
            for _, tok in ipairs(tokens) do
                if tok.type == "break" then
                    result = result .. tok.val
                elseif tok.type == "tag" then
                    local pat = cfg.gt:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1") .. "&H%x+&"
                    local cleaned = tok.val:gsub(pat, "")
                    cleaned = cleaned:gsub("{%s*}", "")
                    result = result .. cleaned
                else
                    result = result .. "{" .. cfg.gt .. Z.C.Grad(idx, total, cl) .. "}" .. tok.val
                    idx = idx + 1
                end
            end
            
            l.text = head .. result
            subs[x] = l
            ::skip::
        end
    end
    return #sel
end

function Z.T.Kine(subs, sel, cfg)
    for _, i in ipairs(sel) do
        local l = subs[i]
        local dur = l.end_time - l.start_time
        if dur <= 0 then goto skip end
        local offset = cfg.ioff or 0
        local effDur = dur - offset
        if effDur <= 0 then goto skip end
        local it = cfg.itb and math.floor(effDur / math.max(50, cfg.ims)) or cfg.inm
        if it < 2 then it = 2 end
        local tr = ""
        for j = 1, it do
            local f = (j-1)/(it-1)
            if cfg.iy and j%2 == 0 then f = 1 - f end
            local ts = offset + math.floor((effDur/it)*(j-1))
            local te = offset + math.floor((effDur/it)*j)
            local v
            if cfg.it:match("alpha") then
                v = Z.C.Alpha(f, cfg.iv1, cfg.iv2)
            else
                local n1, n2 = tonumber(cfg.iv1) or 0, tonumber(cfg.iv2) or 0
                v = string.format("%.1f", n1+(n2-n1)*f):gsub("%.0$", "")
            end
            tr = tr..string.format("\\t(%d,%d,%s%s%s)", ts, te, cfg.ia and string.format("%.1f,", cfg.iacv or 0.8) or "", cfg.it, v)
        end
        local h = l.text:match("^{[^}]*}")
        if h then l.text = h:sub(1,-2)..tr.."}"..l.text:sub(#h+1)
        else l.text = "{"..tr.."}"..l.text end
        subs[i] = l
        ::skip::
    end
    return #sel
end

function Z.T.KineColor(subs, sel, cfg)
    local c1 = Z.C.Normalize(cfg.kc1)
    local c2 = Z.C.Normalize(cfg.kc2)
    local tag = cfg.kct
    for _, i in ipairs(sel) do
        local l = subs[i]
        local dur = l.end_time - l.start_time
        if dur <= 0 then goto skip end
        local offset = cfg.ioff or 0
        local effDur = dur - offset
        if effDur <= 0 then goto skip end
        local it = cfg.itb and math.floor(effDur / math.max(50, cfg.ims)) or cfg.inm
        if it < 2 then it = 2 end
        local tr = ""
        for j = 1, it do
            local f = (j-1)/(it-1)
            if cfg.iy and j%2 == 0 then f = 1 - f end
            local ts = offset + math.floor((effDur/it)*(j-1))
            local te = offset + math.floor((effDur/it)*j)
            local v = Z.C.Mix(f, c1, c2)
            tr = tr..string.format("\\t(%d,%d,%s%s%s)", ts, te, cfg.ia and string.format("%.1f,", cfg.iacv or 0.8) or "", tag, v)
        end
        local h = l.text:match("^{[^}]*}")
        if h then l.text = h:sub(1,-2)..tr.."}"..l.text:sub(#h+1)
        else l.text = "{"..tr.."}"..l.text end
        subs[i] = l
        ::skip::
    end
    return #sel
end

function Z.T.GBC(subs, sel)
    for _, i in ipairs(sel) do
        local l = subs[i]
        l.text = l.text:gsub("({[^}]*)(\\1c)(&H)", "%1\\c%3")
        if not l.text:match("^{") then l.text = "{}"..l.text end
        local b = {}
        for t, x in l.text:gmatch("({[^{}]*})([^{}]*)") do table.insert(b, {t=t, x=x}) end
        if #b < 2 then goto nx end
        local st = {}
        for k = 1, #b do st[k] = {c=b[k].t:match("\\c(&H%x+&)"), fr=b[k].t:match("\\frz([%d%.%-]+)")} end
        local cur = st[1]
        for k = 2, #b do
            local txt = b[k-1].x
            if txt ~= "" then
                local tokens = {}
                local pos = 1
                while pos <= #txt do
                    if txt:sub(pos, pos+1) == "\\N" then
                        table.insert(tokens, {type="break", val="\\N"})
                        pos = pos + 2
                    elseif txt:sub(pos, pos+1) == "\\n" then
                        table.insert(tokens, {type="break", val="\\n"})
                        pos = pos + 2
                    else
                        local ch = ""
                        for c in u.chars(txt:sub(pos)) do ch = c; break end
                        if ch ~= "" then
                            table.insert(tokens, {type="char", val=ch})
                            pos = pos + #ch
                        else
                            pos = pos + 1
                        end
                    end
                end
                local len = 0
                for _, tok in ipairs(tokens) do
                    if tok.type == "char" then len = len + 1 end
                end
                local r, idx = "", 0
                for _, tok in ipairs(tokens) do
                    if tok.type == "break" then
                        r = r .. tok.val
                    else
                        local f = len > 1 and idx/(len-1) or 0
                        local nt = ""
                        if st[k].c and cur.c then nt = nt.."\\c"..Z.C.Mix(f, cur.c, st[k].c) end
                        if st[k].fr and cur.fr then
                            local n1, n2 = tonumber(cur.fr), tonumber(st[k].fr)
                            nt = nt..string.format("\\frz%.2f", n1+(n2-n1)*f)
                        end
                        r = r..(nt=="" and "" or "{*"..nt.."}")..tok.val
                        idx = idx + 1
                    end
                end
                b[k-1].x = r
            end
            if st[k].c then cur.c = st[k].c end
            if st[k].fr then cur.fr = st[k].fr end
        end
        local ft = ""
        for _, bk in ipairs(b) do ft = ft..bk.t..bk.x end
        l.text = ft
        subs[i] = l
        ::nx::
    end
    return #sel
end

function Z.T.VSF(subs, sel, cfg)
    local c1 = Z.C.Normalize(cfg.vc1)
    local c2 = Z.C.Normalize(cfg.vc2)
    local c3 = Z.C.Normalize(cfg.vc3)
    local c4 = Z.C.Normalize(cfg.vc4)
    local tag = cfg.vct.."("..c1..","..c2..","..c3..","..c4..")"
    
    for _, i in ipairs(sel) do
        local l = subs[i]
        if cfg.vcl then
            l.text = l.text:gsub("\\[1-4]vc%([^)]+%)", "")
            l.text = l.text:gsub("{%s*}", "")
        end
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{"..tag)
        else
            l.text = "{"..tag.."}"..l.text
        end
        subs[i] = l
    end
    return #sel
end

function Z.T.Swap(subs, sel)
    local m, o = {}, {}
    for _, i in ipairs(sel) do
        local txt = subs[i].text
        for _, c in txt:gmatch("(\\[1-4]?c)(&H%x+&)") do
            if not m[c] then m[c] = true; table.insert(o, c) end
        end
        for c in txt:gmatch("\\[1-4]vc%(([^)]+)%)") do
            for v in c:gmatch("(&H%x+&)") do
                if not m[v] then m[v] = true; table.insert(o, v) end
            end
        end
    end
    if #o == 0 then return 0, "Sin colores" end
    local g = {{class="label", label="REEMPLAZAR", x=0, y=0, width=3}}
    for i, v in ipairs(o) do
        table.insert(g, {class="coloralpha", name="o"..i, value=v, x=0, y=i})
        table.insert(g, {class="label", label=">", x=1, y=i})
        table.insert(g, {class="coloralpha", name="n"..i, value=v, x=2, y=i})
    end
    local btn, res = aegisub.dialog.display(g, {"OK", "Cancelar"})
    if btn ~= "OK" then return 0, nil end
    local rp, cnt = {}, 0
    for i, v in ipairs(o) do
        local nv = Z.C.Normalize(res["n"..i])
        if v ~= nv then rp[v] = nv end
    end
    for _, i in ipairs(sel) do
        local l, ch = subs[i], false
        for k, v in pairs(rp) do
            local esc = k:gsub("([%W])", "%%%1")
            local new = l.text:gsub("(\\[1-4]?c)" .. esc, "%1" .. v)
            if new ~= l.text then ch = true; l.text = new end
            new = l.text:gsub("(\\[1-4]vc%([^)]*" .. esc .. ")", function(m)
                return m:gsub(esc, v)
            end)
            if new ~= l.text then ch = true; l.text = new end
        end
        if ch then subs[i] = l; cnt = cnt + 1 end
    end
    return cnt, nil
end

function Z.U.Help()
    return {{class="textbox", text=
"Zheus Colormaster v2.0\n"..
"================================================\n"..
"\n"..
"KINETIC TRANSFORM  [Transform]\n"..
"------------------------------------------------\n"..
"Genera animaciones con \\t sobre propiedades ASS.\n"..
"\n"..
"> Tag: Propiedad a animar\n"..
"> Inicio / Final: Valores numericos\n"..
"> Pasos: Intervalos de \\t (min 2)\n"..
"> Accel: Curva de aceleracion (configurable)\n"..
"    Menor a 1 = desacelera, Mayor a 1 = acelera\n"..
"> Yoyo: Alterna direccion en pasos pares\n"..
"> Time: Calcula pasos por duracion (ms/paso)\n"..
"> Offset: Retraso antes de iniciar (ms)\n"..
"\n"..
"Tip: Inicio/Final aceptan decimales.\n"..
"Para colores, usa KColor en vez de Transform.\n"..
"\n"..
"KINETIC COLOR  [KColor]\n"..
"------------------------------------------------\n"..
"Transicion animada de color con \\t.\n"..
"\n"..
"> De / A: Color inicial y final\n"..
"> Tag: \\c, \\2c, \\3c, \\4c\n"..
"> Comparte Pasos, Accel, Yoyo, Time y Offset.\n"..
"\n"..
"SPECTRUM GRADIENT  [Gradiente]\n"..
"------------------------------------------------\n"..
"Degradado de 2 a 5 colores.\n"..
"\n"..
"> Modo:\n"..
"  - Linea: cada linea recibe un color\n"..
"  - Caracter: cada letra recibe un color\n"..
"  - GBC: interpola entre tags \\c existentes\n"..
"    (no usa C1-C5, usa colores del texto)\n"..
"> Tag: \\c, \\2c, \\3c, \\4c\n"..
"> C1/C2: Colores extremos (siempre activos)\n"..
"> C3/C4/C5: Colores intermedios (checkbox)\n"..
"\n"..
"Tip GBC: calcula gradiente entre bloques\n"..
"existentes como {\\c&H...&}texto{\\c&H...&}\n"..
"\n"..
"4-CORNER GRADIENT  [4Corner]\n"..
"------------------------------------------------\n"..
"Degradado de 4 esquinas (VSFilterMod).\n"..
"\n"..
"> Sup: esquinas superiores (Izq, Der)\n"..
"> Inf: esquinas inferiores (Izq, Der)\n"..
"> Tag: \\1vc, \\2vc, \\3vc, \\4vc\n"..
"> Limpiar: elimina tags \\vc previos\n"..
"\n"..
"Requiere VSFilterMod o xy-VSFilter.\n"..
"\n"..
"BOTONES PRINCIPALES\n"..
"------------------------------------------------\n"..
"> Manager: Gestion masiva de colores por actor.\n"..
"  Asigna colores como Tags o Estilos nuevos.\n"..
"> Reemplazar: Buscar y reemplazar colores.\n"..
"  Muestra pickers para cada color encontrado.\n"..
"> Save: Guarda configuracion del dashboard.\n"..
"  Se restaura automaticamente al abrir.\n"..
"\n"..
"LUA CONSOLE  [Lua]\n"..
"------------------------------------------------\n"..
"Ejecuta codigo Lua. Entorno aislado.\n"..
"\n"..
"Variables disponibles:\n"..
"  subs     - Subtitulos (lectura/escritura)\n"..
"  sel      - Indices seleccionados\n"..
"  meta     - Metadatos del video\n"..
"  styles   - Estilos por nombre\n"..
"  karaskel - Libreria karaskel\n"..
"  aegisub  - API de Aegisub\n"..
"  print()  - Consola de debug\n"..
"  Z        - Funciones del script\n"..
"\n"..
"Ejemplo:\n"..
"  for i, idx in ipairs(sel) do\n"..
"    local line = subs[idx]\n"..
"    line.text = line.text:upper()\n"..
"    subs[idx] = line\n"..
"  end\n"..
"\n"..
"FX TOOLS  [FX]\n"..
"------------------------------------------------\n"..
"Efectos rapidos. Requieren video cargado\n"..
"(excepto Flashback). Usa | como punto de corte.\n"..
"\n"..
"> One Color: \\t al color C1 desde frame actual\n"..
"  Afecta \\c, \\3c y \\4c.\n"..
"> To Style: \\t desde C1 a colores del estilo\n"..
"  Va de inicio de linea a frame actual.\n"..
"> Split Line: divide en frame actual con |\n"..
"  L1: antes de | visible, despues oculto\n"..
"  L2: texto completo desde frame actual\n"..
"> Split Line Fad: como Split con transicion\n"..
"  L2: layer superior + \\fad(250,0)\n"..
"> V-Shake: vibracion vertical con \\org+\\frz\n"..
"> H-Shake: vibracion horizontal con \\org+\\frz\n"..
"  (ambos usan Time como intervalo en ms)\n"..
"> Flashback: agrega \\fad(200,200)\n"..
"> Scale Up: escala 110% desde frame actual\n"..
"> Scale Down: escala 90% desde frame actual\n"..
"\n"..
"Tip: posiciona el video en el frame deseado\n"..
"antes de ejecutar cualquier FX.\n"
, width=50, height=35, readonly=true}}
end

local fx_items = {"", "One Color", "To Style", "Split Line", "Split Line Fad", "V-Shake", "H-Shake", "Flashback", "Scale Up", "Scale Down"}


local function get_frame_ms()
    if not aegisub.project_properties then return nil, "Requiere Aegisub 3.2.2+" end
    local props = aegisub.project_properties()
    if not props or not props.video_position then return nil, "No hay video cargado." end
    local frameMs = aegisub.ms_from_frame(props.video_position)
    if not frameMs then return nil, "No se pudo obtener el tiempo del frame." end
    return frameMs, nil
end

local function fx_one_color(subs, sel, color)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    local cnt = 0
    local normColor = Z.C.Normalize(color)
    
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class == "dialogue" then
            
            local startOffset = frameMs - l.start_time
            if startOffset < 0 then startOffset = 0 end
            local endOffset = l.end_time - l.start_time
            
            local transformTag = string.format("\\t(%d,%d,\\c%s\\3c%s\\4c%s)", 
                startOffset, endOffset, normColor, normColor, normColor)
            
            if l.text:match("^{") then
                l.text = l.text:gsub("^{", "{" .. transformTag)
            else
                l.text = "{" .. transformTag .. "}" .. l.text
            end
            subs[i] = l
            cnt = cnt + 1
        end
        ::skip::
    end
    return cnt
end

local function fx_split_line(subs, sel)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    
    local cnt = 0
    local errors = {}
    
    for idx = #sel, 1, -1 do
        local i = sel[idx]
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        if not l.text:find("|", 1, true) then
            table.insert(errors, "Linea "..i..": sin marcador |")
            goto skip
        end
        
        if frameMs < l.start_time or frameMs > l.end_time then
            table.insert(errors, string.format("Linea %d: frame fuera de rango (%d-%dms)", i, l.start_time, l.end_time))
            goto skip
        end
        
        local head = l.text:match("^({[^}]*})") or ""
        local body = l.text:sub(#head + 1)
        
        local beforeMarker, afterMarker = body:match("^(.-)%|(.*)$")
        if not beforeMarker then
            table.insert(errors, "Linea "..i..": error al procesar marcador |")
            goto skip
        end
        
        local line1 = {}
        for k, v in pairs(l) do line1[k] = v end
        line1.end_time = frameMs
        line1.text = head .. beforeMarker .. "{\\alpha&HFF&}" .. afterMarker
        
        local line2 = {}
        for k, v in pairs(l) do line2[k] = v end
        line2.start_time = frameMs
        line2.text = head .. beforeMarker .. afterMarker
        
        subs[i] = line1
        subs.insert(i + 1, line2)
        cnt = cnt + 1
        ::skip::
    end
    
    if cnt == 0 and #errors > 0 then return 0, table.concat(errors, "\n") end
    return cnt, #errors > 0 and table.concat(errors, "\n") or nil
end

local function fx_split_line_fad(subs, sel)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    
    local cnt = 0
    local errors = {}
    
    for idx = #sel, 1, -1 do
        local i = sel[idx]
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        if not l.text:find("|", 1, true) then
            table.insert(errors, "Linea "..i..": sin marcador |")
            goto skip
        end
        
        if frameMs < l.start_time or frameMs > l.end_time then
            table.insert(errors, string.format("Linea %d: frame fuera de rango (%d-%dms)", i, l.start_time, l.end_time))
            goto skip
        end
        
        local head = l.text:match("^({[^}]*})") or ""
        local body = l.text:sub(#head + 1)
        
        local beforeMarker, afterMarker = body:match("^(.-)%|(.*)$")
        if not beforeMarker then
            table.insert(errors, "Linea "..i..": error al procesar marcador |")
            goto skip
        end
        
        local line1 = {}
        for k, v in pairs(l) do line1[k] = v end
        line1.text = head .. beforeMarker .. "{\\alpha&HFF&}" .. afterMarker
        
        local line2 = {}
        for k, v in pairs(l) do line2[k] = v end
        line2.layer = l.layer + 1
        line1.layer = l.layer
        line2.start_time = frameMs
        
        local fadTag = "\\fad(250,0)\\alpha&HFF&"
        if head ~= "" then
            line2.text = head:gsub("^{", "{" .. fadTag) .. beforeMarker .. "{\\alpha&H00&}" .. afterMarker
        else
            line2.text = "{" .. fadTag .. "}" .. beforeMarker .. "{\\alpha&H00&}" .. afterMarker
        end
        
        subs[i] = line1
        subs.insert(i + 1, line2)
        cnt = cnt + 1
        ::skip::
    end
    
    if cnt == 0 and #errors > 0 then return 0, table.concat(errors, "\n") end
    return cnt, #errors > 0 and table.concat(errors, "\n") or nil
end

local function fx_to_style(subs, sel, color, styles)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    
    local cnt = 0
    local normColor = Z.C.Normalize(color)
    
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local style = styles[l.style]
        if not style then
            return 0, "Estilo '" .. l.style .. "' no encontrado."
        end
        
        if frameMs < l.start_time or frameMs > l.end_time then
            return 0, string.format("Frame actual (%dms) fuera del rango de la linea (%d-%dms).", frameMs, l.start_time, l.end_time)
        end
        
        local styleC1 = Z.C.FromStyle(style.color1)
        local styleC3 = Z.C.FromStyle(style.color3)
        local styleC4 = Z.C.FromStyle(style.color4)
        
        local endOffset = frameMs - l.start_time
        if endOffset <= 0 then goto skip end
        
        local initTags = string.format("\\c%s\\3c%s\\4c%s", normColor, normColor, normColor)
        local transformTag = string.format("\\t(0,%d,\\c%s\\3c%s\\4c%s)", 
            endOffset, styleC1, styleC3, styleC4)
        
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. initTags .. transformTag)
        else
            l.text = "{" .. initTags .. transformTag .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    
    return cnt, nil
end

local function fx_vshake(subs, sel, stepMs)
    local cnt = 0
    local maxAngle = 0.12
    local orgDistance = 1500
    
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local dur = l.end_time - l.start_time
        if dur <= 0 then goto skip end
        
        local posX, posY = l.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
        if not posX then
            posX, posY = 960, 540
        else
            posX, posY = tonumber(posX), tonumber(posY)
        end
        
        l.text = l.text:gsub("\\org%([^)]+%)", "")
        local orgTag = string.format("\\org(%d,%d)", math.floor(posX) - orgDistance, math.floor(posY))
        
        local transforms = ""
        local t = 0
        local direction = 1
        while t < dur do
            local t1 = t
            local t2 = math.min(t + stepMs, dur)
            local angle = maxAngle * direction
            transforms = transforms .. string.format("\\t(%d,%d,\\frz%.2f)", t1, t2, angle)
            t = t2
            direction = -direction
        end
        
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. orgTag .. transforms)
        else
            l.text = "{" .. orgTag .. transforms .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    
    return cnt, nil
end

local function fx_hshake(subs, sel, stepMs)
    local cnt = 0
    local maxAngle = 0.12
    local orgDistance = 1500
    
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local dur = l.end_time - l.start_time
        if dur <= 0 then goto skip end
        
        local posX, posY = l.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
        if not posX then
            posX, posY = 960, 540
        else
            posX, posY = tonumber(posX), tonumber(posY)
        end
        
        l.text = l.text:gsub("\\org%([^)]+%)", "")
        local orgTag = string.format("\\org(%d,%d)", math.floor(posX), math.floor(posY) - orgDistance)
        
        local transforms = ""
        local t = 0
        local direction = 1
        while t < dur do
            local t1 = t
            local t2 = math.min(t + stepMs, dur)
            local angle = maxAngle * direction
            transforms = transforms .. string.format("\\t(%d,%d,\\frz%.2f)", t1, t2, angle)
            t = t2
            direction = -direction
        end
        
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. orgTag .. transforms)
        else
            l.text = "{" .. orgTag .. transforms .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    
    return cnt, nil
end

local function fx_flashback(subs, sel)
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local fadTag = "\\fad(200,200)"
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. fadTag)
        else
            l.text = "{" .. fadTag .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    return cnt, nil
end

local function fx_scale_up(subs, sel)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local startOffset = frameMs - l.start_time
        if startOffset < 0 then startOffset = 0 end
        local endOffset = l.end_time - l.start_time
        
        local scaleTag = string.format("\\t(%d,%d,\\fscx110\\fscy110)", startOffset, endOffset)
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. scaleTag)
        else
            l.text = "{" .. scaleTag .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    return cnt, nil
end

local function fx_scale_down(subs, sel)
    local frameMs, fErr = get_frame_ms()
    if not frameMs then return 0, fErr end
    
    local cnt = 0
    for _, i in ipairs(sel) do
        local l = subs[i]
        if l.class ~= "dialogue" then goto skip end
        
        local startOffset = frameMs - l.start_time
        if startOffset < 0 then startOffset = 0 end
        local endOffset = l.end_time - l.start_time
        
        local scaleTag = string.format("\\t(%d,%d,\\fscx90\\fscy90)", startOffset, endOffset)
        if l.text:match("^{") then
            l.text = l.text:gsub("^{", "{" .. scaleTag)
        else
            l.text = "{" .. scaleTag .. "}" .. l.text
        end
        subs[i] = l
        cnt = cnt + 1
        ::skip::
    end
    return cnt, nil
end

function Z.U.Dash(stat)
    local c = saved_cfg
    return {
        {class="label", label="TRANSFORM  [Transform]  [KColor]", x=0, y=0, width=6},
        {class="label", label="GRADIENT  [Gradiente]  [4Corner]", x=6, y=0, width=6},
        {class="label", label="Tag:", x=0, y=1, width=1},
        {class="dropdown", name="it", items={"\\fscx","\\fscy","\\frz","\\bord","\\blur","\\alpha","\\fsp"}, value=c.it or "\\fscx", x=1, y=1, width=5, hint="Propiedad ASS a animar"},
        {class="label", label="Modo:", x=6, y=1, width=1},
        {class="dropdown", name="gdir", items={"Linea","Caracter","GBC"}, value=c.gdir or "Linea", x=7, y=1, width=2, hint="Linea=por linea, Caracter=por letra, GBC=entre tags existentes"},
        {class="dropdown", name="gt", items={"\\c","\\2c","\\3c","\\4c"}, value=c.gt or "\\c", x=9, y=1, width=2, hint="Tag de color a usar"},
        {class="label", label="", x=11, y=1, width=1},
        {class="label", label="Inicio:", x=0, y=2, width=1},
        {class="floatedit", name="iv1", value=c.iv1 or 100, x=1, y=2, width=2, hint="Valor inicial (ej: 100 para escala)"},
        {class="label", label="Final:", x=3, y=2, width=1},
        {class="floatedit", name="iv2", value=c.iv2 or 120, x=4, y=2, width=2, hint="Valor final (ej: 120 para escala)"},
        {class="label", label="C1:", x=6, y=2, width=1},
        {class="coloralpha", name="gc1", value=c.gc1 or "&HFFCC00&", x=7, y=2, width=2, hint="Color degradado + FX One Color"},
        {class="label", label="C2:", x=9, y=2, width=1},
        {class="coloralpha", name="gc2", value=c.gc2 or "&HFF6600&", x=10, y=2, width=2, hint="Color fin del degradado"},
        {class="label", label="Pasos:", x=0, y=3, width=1},
        {class="intedit", name="inm", value=c.inm or 4, min=2, x=1, y=3, width=1, hint="Numero de pasos (min 2)"},
        {class="checkbox", name="ia", label="Accel", value=c.ia or false, x=2, y=3, width=1, hint="Activar curva aceleracion"},
        {class="floatedit", name="iacv", value=c.iacv or 0.8, min=0.1, max=10, step=0.1, x=3, y=3, width=1, hint="Valor aceleracion (<1 desacelera, >1 acelera)"},
        {class="checkbox", name="iy", label="Yoyo", value=c.iy or false, x=4, y=3, width=2, hint="Alternar direccion"},
        {class="checkbox", name="g3", label="C3:", x=6, y=3, width=1},
        {class="coloralpha", name="gc3", value=c.gc3 or "&HFF3300&", x=7, y=3, width=2, hint="Color intermedio 3"},
        {class="checkbox", name="g4", label="C4:", x=9, y=3, width=1},
        {class="coloralpha", name="gc4", value=c.gc4 or "&HFF0066&", x=10, y=3, width=2, hint="Color intermedio 4"},
        {class="checkbox", name="itb", label="Time", value=c.itb or false, x=0, y=4, width=1, hint="Calcular pasos por duracion"},
        {class="floatedit", name="ims", value=c.ims or 100, min=50, x=1, y=4, width=2, hint="Milisegundos por paso"},
        {class="label", label="Offset:", x=3, y=4, width=1},
        {class="floatedit", name="ioff", value=c.ioff or 0, min=0, x=4, y=4, width=2, hint="Retraso inicio (ms)"},
        {class="checkbox", name="g5", label="C5:", x=6, y=4, width=1},
        {class="coloralpha", name="gc5", value=c.gc5 or "&HFF00CC&", x=7, y=4, width=2, hint="Color intermedio 5"},
        {class="label", label="", x=9, y=4, width=3},
        {class="label", label="", x=0, y=5, width=12},
        {class="label", label="KCOLOR  [KColor]", x=0, y=6, width=6},
        {class="label", label="4-CORNER  [4Corner]", x=6, y=6, width=6},
        {class="label", label="De:", x=0, y=7, width=1},
        {class="coloralpha", name="kc1", value=c.kc1 or "&HFFCC00&", x=1, y=7, width=2, hint="Color inicial transicion"},
        {class="label", label="A:", x=3, y=7, width=1},
        {class="coloralpha", name="kc2", value=c.kc2 or "&HFF00CC&", x=4, y=7, width=2, hint="Color final transicion"},
        {class="label", label="Tag:", x=6, y=7, width=1},
        {class="dropdown", name="vct", items={"\\1vc","\\2vc","\\3vc","\\4vc"}, value=c.vct or "\\1vc", x=7, y=7, width=2, hint="Tag de 4 esquinas"},
        {class="checkbox", name="vcl", label="Limpiar", value=c.vcl or false, x=9, y=7, width=3, hint="Limpiar tags \\vc previos"},
        {class="label", label="Tag:", x=0, y=8, width=1},
        {class="dropdown", name="kct", items={"\\c","\\2c","\\3c","\\4c"}, value=c.kct or "\\c", x=1, y=8, width=2, hint="Tag de color KColor"},
        {class="label", label="", x=3, y=8, width=3},
        {class="label", label="Sup:", x=6, y=8, width=1},
        {class="coloralpha", name="vc1", value=c.vc1 or "&HFFCC00&", x=7, y=8, width=2, hint="Superior Izquierda"},
        {class="coloralpha", name="vc2", value=c.vc2 or "&HFF6600&", x=9, y=8, width=2, hint="Superior Derecha"},
        {class="label", label="", x=11, y=8, width=1},
        {class="label", label="", x=0, y=9, width=6},
        {class="label", label="Inf:", x=6, y=9, width=1},
        {class="coloralpha", name="vc3", value=c.vc3 or "&HFF0066&", x=7, y=9, width=2, hint="Inferior Izquierda"},
        {class="coloralpha", name="vc4", value=c.vc4 or "&HFF00CC&", x=9, y=9, width=2, hint="Inferior Derecha"},
        {class="label", label="", x=11, y=9, width=1},
        {class="label", label="", x=0, y=10, width=12},
        {class="label", label="LUA CONSOLE  [Lua]", x=0, y=11, width=6},
        {class="label", label="Variables: subs, sel, meta, styles, karaskel, aegisub, Z", x=6, y=11, width=9},
        {class="textbox", name="sbx", text=Z.sandbox_last_code or "-- Escribe codigo Lua aqui\n-- Usa print() para debug\n", x=0, y=12, width=15, height=3, hint="Codigo Lua a ejecutar"},
        {class="label", label="FX TOOLS  [FX] - Requieren video. C1 = color base. Time = intervalo shake. | = punto de corte.", x=0, y=15, width=15},
        {class="dropdown", name="fxt", items=fx_items, value="", x=0, y=16, width=12, hint="Selecciona efecto y presiona FX"},
        {class="label", label=stat or "", x=0, y=17, width=15},
    }
end

function Z.Main(subs, sel, init_mode, d_in, act_in)
    if #sel == 0 then
        aegisub.dialog.display({{class="label", label="Selecciona líneas."}}, {"OK"})
        return
    end
    
    local sm = Z.S.GetSty(subs)
    local mode = (type(init_mode) == "string" and init_mode) or "DASH"
    local d, act = d_in, act_in
    local pg, stat = 1, ""
    local vsfTag = "1vc"
    
    while true do
        local ui, btns, shown
        
        if mode == "DASH" then
            ui = Z.U.Dash(stat)
            btns = {"Transform", "KColor", "Gradiente", "4Corner", "Lua", "FX", "Manager", "Reemplazar", "Save", "Ayuda"}
        elseif mode == "ARCH" then
            ui, shown = Z.A.GUI(pg, 8, act, d, nil, nil)
            local y = 3 + shown
            table.insert(ui, {class="label", label="", x=0, y=y, width=6})
            table.insert(ui, {class="dropdown", name="op", items={"Tags","Estilos","Limpiar"}, value="Tags", x=0, y=y+1, width=2})
            table.insert(ui, {class="checkbox", name="cl", label="Auto-limpiar", value=true, x=2, y=y+1})
            table.insert(ui, {class="label", label=stat, x=3, y=y+1, width=3})
            btns = {"Aplicar", "◀", "▶", "VSF Mode", "Lista", "Conflictos", "Exportar", "Importar", "Volver"}
        elseif mode == "ARCHVSF" then
            ui, shown = Z.A.GUI(pg, 8, act, d, "vsf", vsfTag)
            local y = 3 + shown
            table.insert(ui, {class="label", label="VSF (\\"..vsfTag..") - Tags solo", x=0, y=y, width=6})
            table.insert(ui, {class="dropdown", name="op", items={"Tags","Limpiar"}, value="Tags", x=0, y=y+1, width=2})
            table.insert(ui, {class="checkbox", name="cl", label="Auto-limpiar", value=true, x=2, y=y+1})
            table.insert(ui, {class="label", label=stat, x=3, y=y+1, width=3})
            btns = {"Aplicar", "◀", "▶", "Exportar", "Importar", "Normal", "Volver"}
        elseif mode == "LIST" then
            ui, shown = Z.A.GUI(pg, 8, act, d, "summary", nil)
            btns = {"Volver"}
        elseif mode == "CONF" then
            ui, shown = Z.A.GUI(pg, 8, act, d, "conflicts", nil)
            btns = {"Volver"}
        elseif mode == "HELP" then
            ui = Z.U.Help()
            btns = {"Volver"}
        end
        
        local b, r = aegisub.dialog.display(ui, btns)
        if not b then break end
        
        if mode == "ARCHVSF" and r.vctag then vsfTag = r.vctag end
        
        if b == "Manager" then
            d, act = Z.S.Scan(subs, sel, sm)
            if #act == 0 then
                stat = "Sin actores en selección."
            else
                mode = "ARCH"
                stat = #act.." actores cargados."
            end
        elseif b == "Ayuda" then
            mode = "HELP"
        elseif b == "Lista" then
            Z.A.Sync(d, act, r, pg, 8, nil, nil)
            mode = "LIST"
        elseif b == "Conflictos" then
            Z.A.Sync(d, act, r, pg, 8, nil, nil)
            mode = "CONF"
        elseif b == "VSF Mode" then
            Z.A.Sync(d, act, r, pg, 8, nil, nil)
            mode = "ARCHVSF"
        elseif b == "Normal" then
            Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
            mode = "ARCH"
        elseif b == "Volver" then
            if mode == "ARCH" then Z.A.Sync(d, act, r, pg, 8, nil, nil) end
            if mode == "ARCHVSF" then Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag) end
            if mode == "LIST" or mode == "CONF" then mode = "ARCH" 
            elseif mode == "ARCHVSF" then mode = "ARCH"
            else mode = "DASH" end
        elseif b == "◀" then
            if mode == "ARCHVSF" then
                Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
            else
                Z.A.Sync(d, act, r, pg, 8, nil, nil)
            end
            pg = math.max(1, pg - 1)
        elseif b == "▶" then
            if mode == "ARCHVSF" then
                Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
            else
                Z.A.Sync(d, act, r, pg, 8, nil, nil)
            end
            pg = math.min(math.ceil(#act/8), pg + 1)
        elseif b == "Aplicar" then
            if mode == "ARCHVSF" then
                Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
                local cnt, err = Z.A.Exec(subs, d, act, sm, r.op, r.cl, true, vsfTag)
                if cnt == -1 then
                    aegisub.dialog.display({{class="label", label=err}}, {"OK"})
                    stat = "⛔ No se puede crear estilo con VSF"
                else
                    aegisub.dialog.display({{class="label", label=cnt.." líneas con \\"..vsfTag.."."}}, {"OK"})
                    aegisub.set_undo_point("Colormaster Manager VSF")
                    break
                end
            else
                Z.A.Sync(d, act, r, pg, 8, nil, nil)
                local cnt, err = Z.A.Exec(subs, d, act, sm, r.op, r.cl, false, nil)
                if cnt == -1 then
                    aegisub.dialog.display({{class="label", label=err}}, {"OK"})
                else
                    aegisub.dialog.display({{class="label", label=cnt.." líneas procesadas."}}, {"OK"})
                    aegisub.set_undo_point("Colormaster Manager")
                    break
                end
            end
        elseif b == "Exportar" then
            if mode == "ARCHVSF" then
                Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
            else
                Z.A.Sync(d, act, r, pg, 8, nil, nil)
            end
            local msg = Z.A.IO(d, act, "Export")
            if msg then stat = msg end
        elseif b == "Importar" then
            if mode == "ARCHVSF" then
                Z.A.Sync(d, act, r, pg, 8, "vsf", vsfTag)
            else
                Z.A.Sync(d, act, r, pg, 8, nil, nil)
            end
            local msg, hasVSFData = Z.A.IO(d, act, "Import")
            if msg then 
                stat = msg
                if hasVSFData and mode ~= "ARCHVSF" then
                    aegisub.dialog.display({{class="label", label=msg.."\n\nEl archivo contiene colores VSFilterMod.\nSe importaron. Cambiando a VSF Mode."}}, {"OK"})
                    mode = "ARCHVSF"
                else
                    aegisub.dialog.display({{class="label", label=msg}}, {"OK"})
                end
            end
        elseif b == "Gradiente" then
            local n
            if r.gdir == "GBC" then
                n = Z.T.GBC(subs, sel)
                aegisub.dialog.display({{class="label", label=n.." líneas (GBC)."}}, {"OK"})
                aegisub.set_undo_point("Colormaster GBC")
            else
                n = Z.T.Grad(subs, sel, r)
                aegisub.dialog.display({{class="label", label=n.." líneas."}}, {"OK"})
                aegisub.set_undo_point("Colormaster Gradiente")
            end
            break
        elseif b == "Transform" then
            local n = Z.T.Kine(subs, sel, r)
            aegisub.dialog.display({{class="label", label=n.." líneas."}}, {"OK"})
            aegisub.set_undo_point("Colormaster Transform")
            break

        elseif b == "Reemplazar" then
            local n, err = Z.T.Swap(subs, sel)
            if err then 
                aegisub.dialog.display({{class="label", label="Reemplazar: " .. err}}, {"OK"})
                stat = err
            elseif n > 0 then
                aegisub.dialog.display({{class="label", label=n.." líneas."}}, {"OK"})
                aegisub.set_undo_point("Colormaster Reemplazar")
                break
            end
        elseif b == "KColor" then
            local n = Z.T.KineColor(subs, sel, r)
            aegisub.dialog.display({{class="label", label=n.." lineas con "..r.kct.."."}}, {"OK"})
            aegisub.set_undo_point("Colormaster KColor")
            break
        elseif b == "4Corner" then
            local n = Z.T.VSF(subs, sel, r)
            aegisub.dialog.display({{class="label", label=n.." lineas con "..r.vct.."."}}, {"OK"})
            aegisub.set_undo_point("Colormaster 4Corner")
            break
        elseif b == "Save" then
            Z.U.SaveCfg(r)
            saved_cfg = r
            stat = "Configuracion guardada."
        elseif b == "Lua" then
            if r.sbx and r.sbx ~= "" then
                Z.sandbox_last_code = r.sbx
                local meta, styles = karaskel.collect_head(subs, false)
                local env = {
                    subs = subs, sel = sel, meta = meta, styles = styles,
                    karaskel = karaskel, aegisub = aegisub,
                    print = aegisub.debug.out,
                    math = math, string = string, table = table,
                    pairs = pairs, ipairs = ipairs, next = next,
                    tonumber = tonumber, tostring = tostring, type = type,
                    select = select, unpack = unpack, error = error, pcall = pcall,
                    Z = Z
                }
                local chunk, err = loadstring(r.sbx)
                if not chunk then
                    stat = "Syntax Error: " .. (err or "unknown")
                else
                    setfenv(chunk, env)
                    aegisub.set_undo_point("Colormaster Lua Console")
                    local ok, runtime_err = pcall(chunk)
                    if not ok then
                        stat = "Runtime Error: " .. (runtime_err or "unknown")
                    else
                        break
                    end
                end
            else
                stat = "Consola vacia"
            end
        elseif b == "FX" then
            if r.fxt and r.fxt ~= "" then
                local n, err = 0, nil
                if r.fxt == "One Color" then
                    n = fx_one_color(subs, sel, r.gc1)
                elseif r.fxt == "To Style" then
                    n, err = fx_to_style(subs, sel, r.gc1, sm)
                elseif r.fxt == "Split Line" then
                    n, err = fx_split_line(subs, sel)
                elseif r.fxt == "Split Line Fad" then
                    n, err = fx_split_line_fad(subs, sel)
                elseif r.fxt == "V-Shake" then
                    n, err = fx_vshake(subs, sel, r.ims)
                elseif r.fxt == "H-Shake" then
                    n, err = fx_hshake(subs, sel, r.ims)
                elseif r.fxt == "Flashback" then
                    n, err = fx_flashback(subs, sel)
                elseif r.fxt == "Scale Up" then
                    n, err = fx_scale_up(subs, sel)
                elseif r.fxt == "Scale Down" then
                    n, err = fx_scale_down(subs, sel)
                end
                if err then
                    aegisub.dialog.display({{class="label", label="FX Error: " .. err}}, {"OK"})
                    stat = err
                elseif n > 0 then
                    aegisub.dialog.display({{class="label", label=n.." lineas procesadas."}}, {"OK"})
                    aegisub.set_undo_point("Colormaster FX: "..r.fxt)
                    break
                else
                    stat = "FX: sin cambios"
                end
            else
                stat = "Selecciona una herramienta FX"
            end
        end
    end
end

aegisub.register_macro(menu_embedding..script_name, script_description, Z.Main)


aegisub.register_macro(menu_embedding.."Utility/Chroma Manager", "Open Chroma Manager Directly", function(s, l)
    local sm = Z.S.GetSty(s)
    local d, act = Z.S.Scan(s, l, sm)
    if #act == 0 then
        aegisub.dialog.display({{class="label", label="Sin actores en selección."}}, {"OK"})
    else
        Z.Main(s, l, "ARCH", d, act)
    end
end)
aegisub.register_macro(menu_embedding.."Utility/Gradient by Char (GBC)", "Interpolate colors between tags", function(s, l)
    local n = Z.T.GBC(s, l)
    aegisub.set_undo_point("Zheus GBC Direct")
end)
aegisub.register_macro(menu_embedding.."Utility/Reemplazar Colores", "Search and Replace Colors", function(s, l)
    local n = Z.T.Swap(s, l)
    if n and n > 0 then aegisub.set_undo_point("Zheus Swap Direct") end
end)


local function wrap_fx(name, func, ...)
    local args = {...}
    return function(s, l)
       local n, err = func(s, l, unpack(args))
       if err then aegisub.dialog.display({{class="label", label=err}}, {"OK"})
       elseif n > 0 then aegisub.set_undo_point("Zheus FX: "..name) end
    end
end

aegisub.register_macro(menu_embedding.."Utility/FX/One Color (Gold)", "Transform to Gold", wrap_fx("One Color", fx_one_color, "&HFFCC00&"))
aegisub.register_macro(menu_embedding.."Utility/FX/To Style (Gold)", "Transform to Style from Gold", function(s, l)
    local sm = Z.S.GetSty(s)
    local n, err = fx_to_style(s, l, "&HFFCC00&", sm)
    if err then aegisub.dialog.display({{class="label", label=err}}, {"OK"})
    elseif n > 0 then aegisub.set_undo_point("Zheus FX: To Style") end
end)
aegisub.register_macro(menu_embedding.."Utility/FX/Split Line", "Split at |", wrap_fx("Split", fx_split_line))
aegisub.register_macro(menu_embedding.."Utility/FX/Split Line Fad", "Split at | with Fade", wrap_fx("Split Fad", fx_split_line_fad))
aegisub.register_macro(menu_embedding.."Utility/FX/V-Shake", "Vertical Shake (50ms)", wrap_fx("V-Shake", fx_vshake, 50))
aegisub.register_macro(menu_embedding.."Utility/FX/H-Shake", "Horizontal Shake (50ms)", wrap_fx("H-Shake", fx_hshake, 50))
aegisub.register_macro(menu_embedding.."Utility/FX/Flashback", "Add Flashback Fade", wrap_fx("Flashback", fx_flashback))
aegisub.register_macro(menu_embedding.."Utility/FX/Scale Up", "Scale Up Animation", wrap_fx("Scale Up", fx_scale_up))
aegisub.register_macro(menu_embedding.."Utility/FX/Scale Down", "Scale Down Animation", wrap_fx("Scale Down", fx_scale_down))