script_name="Rhearow Master"
script_description="Advanced toolkit for dramaturgy & visual effects"
script_author="Kiterow"
script_version="3.0"
menu_embedding="Kite-Macros/"
require"karaskel"
local unicode=require'aegisub.unicode'
function table.copy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    setmetatable(c, getmetatable(t))
    return c
end


local LANG = {
  es = {

    lbl_act1 = "━━━━ ◆ PERSPECTIVA ◆ ━━━━",
    lbl_act2 = "━━━━ ◆ MÁSCARAS ◆ ━━━━",
    lbl_act3 = "━━━━ ◆ ESCENA ◆ ━━━━",
    lbl_act4 = "━━━━ ◆ TEXTO ◆ ━━━━",
    lbl_act5 = "━━━━ ◆ CIRCULAR ◆ ━━━━",
    lbl_act6 = "━━━━ ◆ FOCUS ◆ ━━━━",
    lbl_act7 = "━━━━ ◆ BORDES ◆ ━━━━",

    sep_h = "────────────────────",
    sep_v = "│",

    lbl_persp_mode = "Modo:",
    lbl_mask_source = "Fuente:",
    lbl_margin = "Margen (px):",
    lbl_case = "Mayúsculas:",
    lbl_typewriter = "Typewriter:",
    lbl_rotation = "Rotación:",
    lbl_radio = "Radio (+/-):",
    lbl_track = "Kerning:",
    lbl_blur_mode = "Modo Blur:",
    lbl_glow_int = "Intensidad:",
    lbl_glow_alpha = "Opacidad:",
    lbl_fade_offset = "Offset Fade:",
    lbl_bord_header = "[✓]  Grosor  Color",
    lbl_bord1 = "Borde 1:",
    lbl_bord2 = "Borde 2:",
    lbl_bord3 = "Borde 3:",
    lbl_bord4 = "Borde 4:",

    btn_perspective = "Perspectiva",
    btn_mask = "Máscara",
    btn_scale = "Escalar",
    btn_text = "Texto",
    btn_blur = "Focus",
    btn_bord = "Crear Bordes",
    btn_circle = "Circular",
    btn_fades = "Fix Fades",
    btn_help = "Ayuda/Config",
    btn_config = "Recordar",
    btn_tools = "Tools",
    btn_mass_signs = "Mass-Signs",

    chk_copy = "Copiar \\clip a otras líneas",
    chk_keep = "Mantener original (comentario)",
    chk_rmclip = "Quitar \\clip",
    chk_new = "Crear en nueva capa",
    chk_repl = "Reemplazar máscara actual",
    chk_alpha = "Transparencia",
    chk_color = "Colorear",
    chk_invert = "Invertir dirección",
    chk_delete = "Borrar línea original",
    chk_2nd_bord = "Crear doble capa",
    chk_fix_fade = "Corregir Fades en capas",
    chk_vert = "Texto Vertical ⚠",
    chk_pnorm = "Normalizar Vértices",
    chk_mq2 = "Modo Bicúbico (q2)",
    chk_glow_color = "Colorear Glow →",

    hint_pnorm = "Normaliza orden de vértices (ignora orden de dibujo)",
    hint_pmode = "Genera 4to punto o aplica rotación 3D desde clip",
    hint_mmask = "from clip: usa \\clip existente | otras: máscaras predefinidas",
    hint_fmode = "fill: estira | prop: proporcional | center: centra | justify: justifica",
    hint_case = "Cambio de mayúsculas/minúsculas del texto",
    hint_type = "Frame: 42ms/char | Duration: proporcional a duración",
    hint_vert = "⚠ Puede fallar con emojis o caracteres compuestos",
    hint_circ_rot = "Normal: curva | Invertido: 180° | Vertical: sin rotar",
    hint_circ_radio = "Modificador de radio (+/-)",
    hint_circ_track = "Espaciado adicional entre caracteres",
    hint_blur_mode = "Glow: añade resplandor | Capas: solo borde",
    hint_glow_blur = "Cantidad de blur para el glow",
    hint_glow_alpha = "Transparencia del glow (00=opaco, FF=invisible)",
    hint_borde = "Tamaño adicional del borde",
    lbl_lang = "Idioma:",

    lbl_act_tools = "━━━━ ◆ TOOLS ◆ ━━━━",
    opt_none = "-",
    opt_persp_proj = "Copiar Persp. (Proyectar)",
    opt_persp_exact = "Copiar Persp. (Exacto)",
    opt_copy_clip = "Copiar Clip",
    opt_clip_to_iclip = "Clip → iClip",
    opt_iclip_to_clip = "iClip → Clip",

    opt_gen4 = "Generar 4ta esquina",
    opt_genapply = "Calcular y Aplicar \\fr",
    opt_apply = "Solo Aplicar Rotación",
    opt_fill = "Estirar (Fill)",
    opt_prop = "Proporcional",
    opt_center = "Centrar",
    opt_justify = "Justificar",
    opt_frame = "Por Cuadro (42ms)",
    opt_duration = "Ajustar a Duración",
    opt_normal = "Normal",
    opt_inverted = "Invertido",
    opt_vertical = "Vertical",
    opt_glow = "Blur + Glow",
    opt_layers = "Blur + Capas",
  },
  en = {
    -- SECTION TITLES (decorative)
    lbl_act1 = "━━━━ ◆ PERSPECTIVE ◆ ━━━━",
    lbl_act2 = "━━━━ ◆ MASKS ◆ ━━━━",
    lbl_act3 = "━━━━ ◆ SCENE ◆ ━━━━",
    lbl_act4 = "━━━━ ◆ TEXT ◆ ━━━━",
    lbl_act5 = "━━━━ ◆ CIRCLE ◆ ━━━━",
    lbl_act6 = "━━━━ ◆ FOCUS ◆ ━━━━",
    lbl_act7 = "━━━━ ◆ BORDERS ◆ ━━━━",
    -- SEPARATORS
    sep_h = "────────────────────",
    sep_v = "│",
    -- SUB-LABELS
    lbl_persp_mode = "Mode:",
    lbl_mask_source = "Source:",
    lbl_margin = "Margin (px):",
    lbl_case = "Case:",
    lbl_typewriter = "Typewriter:",
    lbl_rotation = "Rotation:",
    lbl_radio = "Radius (+/-):",
    lbl_track = "Kerning:",
    lbl_blur_mode = "Blur Mode:",
    lbl_glow_int = "Intensity:",
    lbl_glow_alpha = "Opacity:",
    lbl_fade_offset = "Fade Offset:",
    lbl_bord_header = "[✓]  Size   Color",
    lbl_bord1 = "Border 1:",
    lbl_bord2 = "Border 2:",
    lbl_bord3 = "Border 3:",
    lbl_bord4 = "Border 4:",
    -- BUTTONS
    btn_perspective = "Perspective",
    btn_mask = "Mask",
    btn_scale = "Scale",
    btn_text = "Text",
    btn_blur = "Focus",
    btn_bord = "Create Borders",
    btn_circle = "Circle",
    btn_fades = "Fix Fades",
    btn_help = "Help/Config",
    btn_config = "Remember",
    btn_tools = "Tools",
    btn_mass_signs = "Mass-Signs",
    -- CHECKBOXES (descriptive)
    chk_copy = "Copy \\clip to other lines",
    chk_keep = "Keep original (as comment)",
    chk_rmclip = "Remove \\clip",
    chk_new = "Create in new layer",
    chk_repl = "Replace current mask",
    chk_alpha = "Transparency",
    chk_color = "Colorize",
    chk_invert = "Invert direction",
    chk_delete = "Delete original line",
    chk_2nd_bord = "Create double layer",
    chk_fix_fade = "Fix Fades on layers",
    chk_vert = "Vertical Text ⚠",
    chk_pnorm = "Normalize Vertices",
    chk_mq2 = "Bicubic Mode (q2)",
    chk_glow_color = "Colorize Glow →",
    -- HINTS
    hint_pnorm = "Normalize vertex order (ignores drawing order)",
    hint_pmode = "Generate 4th point or apply 3D rotation from clip",
    hint_mmask = "from clip: use existing \\clip | others: predefined masks",
    hint_fmode = "fill: stretch | prop: proportional | center: center | justify: justify",
    hint_case = "Change text case",
    hint_type = "Frame: 42ms/char | Duration: proportional to duration",
    hint_vert = "⚠ May fail with emojis or composed characters",
    hint_circ_rot = "Normal: curve | Inverted: 180° | Vertical: no rotation",
    hint_circ_radio = "Radius modifier (+/-)",
    hint_circ_track = "Additional spacing between characters",
    hint_blur_mode = "Glow: adds glow | Layers: border layers only",
    hint_glow_blur = "Blur amount for glow",
    hint_glow_alpha = "Glow transparency (00=opaque, FF=invisible)",
    hint_borde = "Additional border size",
    lbl_lang = "Language:",
    -- TOOLS
    lbl_act_tools = "━━━━ ◆ TOOLS ◆ ━━━━",
    opt_none = "-",
    opt_persp_proj = "Copy Persp. (Project)",
    opt_persp_exact = "Copy Persp. (Exact)",
    opt_copy_clip = "Copy Clip",
    opt_clip_to_iclip = "Clip → iClip",
    opt_iclip_to_clip = "iClip → Clip",
    -- DROPDOWN OPTIONS
    opt_gen4 = "Generate 4th corner",
    opt_genapply = "Calculate and Apply \\fr",
    opt_apply = "Apply Rotation Only",
    opt_fill = "Stretch (Fill)",
    opt_prop = "Proportional",
    opt_center = "Center",
    opt_justify = "Justify",
    opt_frame = "Per Frame (42ms)",
    opt_duration = "Fit to Duration",
    opt_normal = "Normal",
    opt_inverted = "Inverted",
    opt_vertical = "Vertical",
    opt_glow = "Blur + Glow",
    opt_layers = "Blur + Layers",
  }
}
local current_lang = "es"
local function set_lang(l) if LANG[l] then current_lang=l end end
local function L(key) return (LANG[current_lang] and LANG[current_lang][key]) or LANG["en"][key] or key end

local EPS=0.001
local DEF_Z=312.5
local function get_default_pos()
    local xres, yres = aegisub.video_size()
    if xres and yres then return {x=xres/2, y=yres/2} end
    return {x=640, y=360}
end
local DEF_POS=get_default_pos()
local MAX_SC=2000
local MIN_SC=5
local MIN_FS=6
local CFG_FILE=aegisub.decode_path("?user").."/rhearow.conf"
local MSK_FILE=aegisub.decode_path("?user").."/maya_masks.txt"
local DEF_MSK=[[mask:square:m 0 0 l 100 0 100 100 0 100:
mask:rounded:m -100 -25 b -100 -92 -92 -100 -25 -100 l 25 -100 b 92 -100 100 -92 100 -25 l 100 25 b 100 92 92 100 25 100 l -25 100 b -92 100 -100 92 -100 25 l -100 -25:
mask:circle:m -100 -100 b -45 -155 45 -155 100 -100 b 155 -45 155 45 100 100 b 46 155 -45 155 -100 100 b -155 45 -155 -45 -100 -100:
mask:triangle:m -122 70 l 122 70 l 0 -141:
]]
local function Cue(s) return s:gsub("[%%%(%)%[%]%.%-%+%*%?%^%$]","%%%1") end
local function Beat(n,d) d=d or 0; local m=10^d; return math.floor(n*m+0.5)/m end
local function AdLib(t) return t:gsub("{[^}]*}",""):gsub("%[.-%]",""):gsub("\\N","") end
local function Exit(g,t) return t:gsub("\\"..g.."%b()",""):gsub("{}","") end
local function Cast(x,y,z) return {x=x,y=y,z=z or 0,add=function(s,p) return Cast(s.x+p.x,s.y+p.y,s.z+p.z) end,sub=function(s,p) return Cast(s.x-p.x,s.y-p.y,s.z-p.z) end,mul=function(s,v) return Cast(s.x*v,s.y*v,s.z*v) end,len=function(s) return math.sqrt(s.x^2+s.y^2+s.z^2) end,rot_x=function(s,a) local c,si=math.cos(a),math.sin(a); return Cast(s.x,s.y*c+s.z*si,-s.y*si+s.z*c) end,rot_y=function(s,a) local c,si=math.cos(a),math.sin(a); return Cast(s.x*c-s.z*si,s.y,s.x*si+s.z*c) end,rot_z=function(s,a) local c,si=math.cos(a),math.sin(a); return Cast(s.x*c+s.y*si,-s.x*si+s.y*c,s.z) end} end
local function Flux(a,b) return Cast(a.y*b.z-a.z*b.y,-a.x*b.z+a.z*b.x,a.x*b.y-a.y*b.x) end
local function Core(a,b) return a.x*b.x+a.y*b.y+a.z*b.z end
local function Meet(l1,l2) local d=(l1[1].x-l1[2].x)*(l2[1].y-l2[2].y)-(l1[1].y-l1[2].y)*(l2[1].x-l2[2].x); if math.abs(d)<EPS then return l1[1]:add(l1[2]:sub(l1[1]):mul(1e30)) end local c1=Flux(l1[1],l1[2]).z; local c2=Flux(l2[1],l2[2]).z; local x=(c1*(l2[1].x-l2[2].x)-c2*(l1[1].x-l1[2].x))/d; local y=(c1*(l2[1].y-l2[2].y)-c2*(l1[1].y-l1[2].y))/d; return Cast(x,y,0) end
local function Fill(ax,ay,bx,by,cx,cy) local abx,aby,bcx,bcy=bx-ax,by-ay,cx-bx,cy-by; local d=abx*bcy-aby*bcx; if math.abs(d)<EPS then return ax+bcx,ay+bcy end local t=((ax-cx)*bcy-(ay-cy)*bcx)/d; return cx+t*abx,cy+t*aby end
local function Trio(t) local c=t:match("\\clip%(m%s*([^%)]+)%)"); if not c then local x1,y1,x2,y2=t:match("\\clip%(([%d%.%-eE%+]+),([%d%.%-eE%+]+),([%d%.%-eE%+]+),([%d%.%-eE%+]+)%)"); if x1 then return tonumber(x1),tonumber(y1),tonumber(x2),tonumber(y1),tonumber(x2),tonumber(y2) end return nil end local p={}; for x,y in c:gmatch("([%d%.%-eE%+]+)%s+([%d%.%-eE%+]+)") do table.insert(p,{x=tonumber(x),y=tonumber(y)}) if #p>=3 then break end end if #p>=3 then return p[1].x,p[1].y,p[2].x,p[2].y,p[3].x,p[3].y end return nil end
local function Quat(t) local c=t:match("\\clip%(m%s*([^%)]+)%)"); if not c then return nil end local p={}; for x,y in c:gmatch("([%d%.%-eE%+]+)%s+([%d%.%-eE%+]+)") do table.insert(p,{x=tonumber(x),y=tonumber(y)}) if #p>=4 then break end end return #p>=4 and p or nil end
local function Rect(t) local x1,y1,x2,y2=t:match("\\clip%(([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%)"); if not x1 then return nil end x1,y1,x2,y2=tonumber(x1),tonumber(y1),tonumber(x2),tonumber(y2); if not(x1 and y1 and x2 and y2 and x1~=x2 and y1~=y2) then return nil end return math.min(x1,x2),math.min(y1,y2),math.max(x1,x2),math.max(y1,y2) end
local function NormQuad(p) local cx,cy=0,0; for i=1,4 do cx,cy=cx+p[i].x,cy+p[i].y end cx,cy=cx/4,cy/4; for i=1,4 do p[i].a=math.atan2(p[i].y-cy,p[i].x-cx) end table.sort(p,function(a,b) return a.a<b.a end); local mi,md=1,math.huge; for i=1,4 do local d=math.sqrt((p[i].x-cx)^2+(p[i].y-cy)^2)+p[i].a; if p[i].x<=cx and p[i].y<=cy and d<md then mi,md=i,d end end if mi>1 then local t={}; for i=1,4 do t[i]=p[((i-1+mi-1)%4)+1] end p=t end return p end
local function Get_Clip_BBox(t) local x1,y1,x2,y2=t:match("\\i?clip%(([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%s*,%s*([%-%d%.eE%+]+)%)"); if x1 then x1,y1,x2,y2=tonumber(x1),tonumber(y1),tonumber(x2),tonumber(y2); return math.min(x1,x2),math.min(y1,y2),math.max(x1,x2),math.max(y1,y2) end local vect=t:match("\\i?clip%(m%s+([^%)]+)%)"); if vect then local minx,maxx,miny,maxy=math.huge,-math.huge,math.huge,-math.huge; local found=false; for x,y in vect:gmatch("([%-%d%.eE%+]+)%s+([%-%d%.eE%+]+)") do x,y=tonumber(x),tonumber(y); if x and y then minx,maxx=math.min(minx,x),math.max(maxx,x); miny,maxy=math.min(miny,y),math.max(maxy,y); found=true end end if found then return minx,miny,maxx,maxy end end return nil end
local function Plot(co,o,norm) if norm then co=NormQuad(co) end local w1=math.sqrt((co[2].x-co[1].x)^2+(co[2].y-co[1].y)^2); local w2=math.sqrt((co[3].x-co[2].x)^2+(co[3].y-co[2].y)^2); local rc=co; if w2>w1 then rc={co[2],co[3],co[4],co[1]} end local sh=o:mul(-1); local ce={}; for i=1,4 do ce[i]=rc[i]:add(sh) end local ctr=Meet({ce[1],ce[3]},{ce[2],ce[4]}); ctr=Cast(ctr.x,ctr.y,DEF_Z); local rays={}; for i=1,4 do rays[i]=Cast(ce[i].x,ce[i].y,DEF_Z) end local fp={}; for i=0,1 do local v1=Flux(rays[1+i],ctr):len(); local v2=Flux(rays[3+i],ctr):len(); local pa,pc=rays[1+i],rays[3+i]:mul(v1/v2); local mp=pa:add(pc):mul(0.5); local r=ctr.z/mp.z; table.insert(fp,pa:mul(r)); table.insert(fp,pc:mul(r)) end local a,c,b,d=fp[1],fp[2],fp[3],fp[4]; local n=Flux(b:sub(a),c:sub(a)); local n0=Flux(rays[2]:sub(rays[1]),rays[3]:sub(rays[1])); if Core(n,n0)<0 then return nil end local fry=math.atan(n.x/n.z); local rn=n:rot_y(fry); local frx=-math.atan(rn.y/rn.z); if n0.z<0 then frx=frx+math.pi end local ru=b:sub(a):rot_y(fry):rot_x(frx); local rd=d:sub(a):rot_y(fry):rot_x(frx); local frz=math.atan2(ru.y,ru.x); rd=rd:rot_z(frz); local fax=rd.x/rd.y; local r=string.format("\\fry%.2f\\frx%.2f\\frz%.2f",-fry/math.pi*180,-frx/math.pi*180,-frz/math.pi*180); if math.abs(fax)>0.01 then r=r..string.format("\\fax%.2f",fax) end return r end
local function Scene(sub,sel,opt) local lc,lp; for _,i in ipairs(sel) do local l=sub[i]; if not l or not l.text then goto s end local ax,ay,bx,by,cx,cy=Trio(l.text); if not ax then local fp=Quat(l.text); if fp and(opt.mode=="apply" or opt.mode=="gen_apply") then local px,py=l.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)"); if not px then px,py=l.text:match("\\org%(([%d%.%-]+),([%d%.%-]+)%)") end px,py=px or DEF_POS.x,py or DEF_POS.y; local org=Cast(tonumber(px),tonumber(py)); local cs={}; for j=1,4 do cs[j]=Cast(fp[j].x,fp[j].y) end local p=Plot(cs,org,opt.pnorm); if p then l.text=l.text:gsub("\\fr[xyz][%d%.%-]+",""):gsub("\\fax[%d%.%-]+",""); if l.text:match("^{") then l.text=l.text:gsub("^{","{"..p) else l.text="{"..p.."}"..l.text end lp=p end lc=l.text:match("(\\clip%([^%)]*%))"); sub[i]=l end if not l.text:match("\\clip") and lc and opt.copy then if l.text:match("^{") then l.text=l.text:gsub("^{","{"..lc) else l.text="{"..lc.."}"..l.text end if lp and(opt.mode=="gen_apply" or opt.mode=="apply") then l.text=l.text:gsub("\\fr[xyz][%d%.%-]+",""):gsub("\\fax[%d%.%-]+",""); if l.text:match("^{") then l.text=l.text:gsub("^{","{"..lp) else l.text="{"..lp.."}"..l.text end end sub[i]=l end goto s end if opt.mode=="gen" or opt.mode=="gen_apply" then local dx,dy=Fill(ax,ay,bx,by,cx,cy); local cl=string.format("\\clip(m %.1f %.1f l %.1f %.1f l %.1f %.1f l %.1f %.1f)",ax,ay,bx,by,cx,cy,dx,dy); l.text=l.text:gsub("\\clip%([^%)]*%)",cl); if not l.text:match("\\clip") then if l.text:match("^{") then l.text=l.text:gsub("^{","{"..cl) else l.text="{"..cl.."}"..l.text end end lc=cl end if opt.mode=="gen_apply" or opt.mode=="apply" then local fp=Quat(l.text); if fp then local px,py=l.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)"); if not px then px,py=l.text:match("\\org%(([%d%.%-]+),([%d%.%-]+)%)") end px,py=px or DEF_POS.x,py or DEF_POS.y; local org=Cast(tonumber(px),tonumber(py)); local cs={}; for j=1,4 do cs[j]=Cast(fp[j].x,fp[j].y) end local p=Plot(cs,org,opt.pnorm); if p then l.text=l.text:gsub("\\fr[xyz][%d%.%-]+",""):gsub("\\fax[%d%.%-]+",""); if l.text:match("^{") then l.text=l.text:gsub("^{","{"..p) else l.text="{"..p.."}"..l.text end lp=p end end end if opt.keep then l.comment=true; sub[i]=l; local nl={}; for k,v in pairs(l) do nl[k]=v end nl.comment=false; sub.insert(i+1,nl) else sub[i]=l end ::s:: end if opt.rmclip then for _,i in ipairs(sel) do local l=sub[i]; if l then l.text=l.text:gsub("\\i?clip%([^%)]*%)",""); sub[i]=l end end end end
local function Intro() local f=io.open(MSK_FILE); local c=f and f:read("*all") or ""; if f then io.close(f) end local am={}; local mn={"from clip"}; for n,m in(DEF_MSK..c):gmatch("mask:(.-):(.-):") do table.insert(mn,n); table.insert(am,{name=n,mask=m}) end return am,mn end
local function Memo(mn,dm,sl) local f=io.open(MSK_FILE); local c=f and f:read("*all") or ""; if f then io.close(f) end local _,ml=Intro(); if dm then for i,n in ipairs(ml) do if n==mn and i>10 then c=c:gsub("mask:"..Cue(mn)..":.-:\n\n",""); break end end elseif mn~="" and mn~="del" then if sl and sl[1] then local nm=sl[1].text:gsub("{[^}]-}",""):match("m [%d%s%-mbl]+"); if nm then nm=nm:gsub("%s*$",""); c=c.."mask:"..mn..":"..nm..":\n\n" end end end f=io.open(MSK_FILE,"w"); if f then f:write(c); f:close() end end
local function Veil(sub,sel,opt) local am,_=Intro(); local ns={}; for z,i in ipairs(sel) do table.insert(ns,i) end for z=#sel,1,-1 do local i=sel[z]; local l=sub[i]; if not l then goto s end local tx=l.text; local err=false; if opt.new and not opt.remask then if opt.mask=="from clip" then if not tx:match("\\i?clip") then err=true else l.text=Exit("clip",l.text) end end if not err then for j=1,#ns do if ns[j]>i then ns[j]=ns[j]+1 end end table.insert(ns,i+1); l.layer=l.layer+1; sub.insert(i+1,l) end l.layer=l.layer-1 end local mc="\\c"..opt.mcolor:gsub("#(%x%x)(%x%x)(%x%x).*","&H%3%2%1&"); local ma=opt.alpha and "\\alpha&H"..opt.alphaval.."&" or ""; if opt.remask then if tx:match("\\p1") then if opt.mask=="from clip" then if tx:match("\\i?clip") then local ct=tx:match("\\i?clip%(m ([^%)]+)%)") or ""; l.text=Exit("clip",l.text); l.text=l.text:gsub("\\fsc[xy][^}\\]+",""):gsub("}m [^{]+","\\fscx100\\fscy100}m "..ct); if opt.mask=="square" then l.text=l.text:gsub("\\an7","\\an5") end end else for k=1,#am do if am[k].name==opt.mask then l.text=l.text:gsub("\\fsc[xy][^}\\]+",""):gsub("}m [^{]+","\\fscx100\\fscy100}"..am[k].mask); if opt.mask=="square" then l.text=l.text:gsub("\\an7","\\an5") end end end end end else if opt.mask=="from clip" then if tx:match("\\i?clip") then local off=tx:match("\\i?clip%((%d+),m"); if off then local fac=2^(tonumber(off)-1); tx=tx:gsub("(\\i?clip%()(%d*,?)m ([^%)]+)%)",function(a,b,c) return a.."m "..c:gsub("([%d%.%-]+)",function(d) return Beat(tonumber(d)/fac) end)..")" end) end tx=tx:gsub("\\i?clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\clip(m %1 %2 l %3 %2 %3 %4 %1 %4)"); local pm=tx:match("\\move") and "\\move" or "\\pos"; local ct=tx:match("\\i?clip%(m ([^%)]+)%)") or ""; if not ct or ct=="" then err=true end if not err then local ca=ct; local ps; if tx:match("\\pos") or tx:match("\\move") then ps=tx:match("\\pos(%([^%)]+%))") or tx:match("\\move(%([^%)]+%))"); local xx,yy=tx:match("\\pos%(([%d%.%-]+),([%d%.%-]+)"); if not xx then xx,yy=tx:match("\\move%(([%d%.%-]+),([%d%.%-]+)") end if xx then xx,yy=Beat(tonumber(xx)),Beat(tonumber(yy)); ca=ct:gsub("([%d%.%-]+)%s([%d%.%-]+)",function(a,b) return Beat(tonumber(a)-xx).." "..Beat(tonumber(b)-yy) end) end else ps="(0,0)"; ca=ct end ca="m "..ca:gsub("([%d%.]+)",function(a) return Beat(tonumber(a)) end); l.text="{\\an7\\blur1\\bord0\\shad0\\fscx100\\fscy100"..mc..ma..pm..ps.."\\p1}"..ca end end else local at=""; local og=tx:match("\\org%b()"); local fz=tx:match("\\frz[%d%.%-]+"); local fx=tx:match("\\frx[%d%.%-]+"); local fy=tx:match("\\fry[%d%.%-]+"); if og then at=at..og end if fz then at=at..fz end if fx then at=at..fx end if fy then at=at..fy end l.text=l.text:gsub(".*(\\pos%([%d%,%.%-]-%)).*","%1"); if not l.text:match("\\pos") then l.text="" end for k=1,#am do if am[k].name==opt.mask then l.text="{\\"..opt.an.."\\bord0\\shad0\\blur1"..l.text..mc..ma.."\\p1}"..am[k].mask; if opt.mask=="square" and opt.an=="an5" then l.text=l.text:gsub("\\an7","") end end end if not l.text:match("\\pos") then l.text=l.text:gsub("\\p1","\\pos(640,360)\\p1") end end end if opt.q2 then if l.text:match("\\q2") then l.text=l.text:gsub("\\q2",""):gsub("{}","") else l.text="{\\q2}"..l.text; l.text=l.text:gsub("\\q2}{\\","\\q2\\") end end sub[i]=l ::s:: end return ns end
local function Role(t,s) local p={fontname=s.fontname,fontsize=s.fontsize,scale_x=s.scale_x,scale_y=s.scale_y,bold=s.bold,italic=s.italic}; local tg=t:match("^{([^}]*)}"); if not tg then return p end local fn=tg:match("\\fn([^\\}]+)"); if fn then p.fontname=fn end local fs=tonumber(tg:match("\\fs([%d%.]+)")); if fs then p.fontsize=fs end local fx=tonumber(tg:match("\\fscx([%d%.]+)")); if fx then p.scale_x=fx end local fy=tonumber(tg:match("\\fscy([%d%.]+)")); if fy then p.scale_y=fy end if tg:match("\\b1") then p.bold=true elseif tg:match("\\b0") then p.bold=false end if tg:match("\\i1") then p.italic=true elseif tg:match("\\i0") then p.italic=false end return p end
local function Wardrobe(bs,p) local t=table.copy(bs); t.fontname=p.fontname; t.fontsize=p.fontsize; t.scale_x=p.scale_x; t.scale_y=p.scale_y; t.bold=p.bold; t.italic=p.italic; return t end
local function Lines(t,s) local p={}; for pa in t:gmatch("[^"..s.."]+") do table.insert(p,pa) end return p end
local function Audit(ts,tb) local l=Lines(tb,"\\N"); local mw,th=0,0; local _,lh,d,el=aegisub.text_extents(ts,"Ag"); local ls=lh+(ts.spacing or 0); for i,ln in ipairs(l) do local lw=aegisub.text_extents(ts,ln); mw=math.max(mw,lw); th=th+(i==1 and lh or ls) end return mw,th end
local function Block(w,mw,ts) local r={}; local cl={}; local cw=0; local fsz=ts.fontsize or 40; local scx=(ts.scale_x or 100)/100; local sw=aegisub.text_extents(ts," ")*scx; for _,wd in ipairs(w) do local ww=aegisub.text_extents(ts,wd)*scx; local wi=cw+(#cl>0 and sw or 0)+ww; if wi>mw and #cl>0 then table.insert(r,table.concat(cl," ")); cl={wd}; cw=ww else table.insert(cl,wd); cw=cw+(#cl>1 and sw or 0)+ww end end if #cl>0 then table.insert(r,table.concat(cl," ")) end return table.concat(r,"\\N") end
local function Wipe(t) return t:gsub("\\fs[%d%.%-]+",""):gsub("\\fscx[%d%.%-]+",""):gsub("\\fscy[%d%.%-]+","") end
local function Clean(t) return t:gsub("{[^}]-}","") end
local function Prop(sub,sel,opt) if not sel or #sel==0 then return end local m,st=karaskel.collect_head(sub); if not m or not st then return end for i,idx in ipairs(sel) do local l=sub[idx]; if not l or not l.text or l.text=="" then goto s end local cx1,cy1,cx2,cy2=Get_Clip_BBox(l.text); if not cx1 then goto s end local cw=math.abs(cx2-cx1)-(opt.margin*2); local ch=math.abs(cy2-cy1)-(opt.margin*2); local center_x,center_y=(cx1+cx2)/2,(cy1+cy2)/2; if cw<=10 or ch<=10 then goto s end local tc=Clean(l.text); if tc=="" or tc:match("^%s*$") then goto s end local sty=st[l.style]; if not sty then goto s end local p=Role(l.text,sty); local ts=Wardrobe(sty,p); local tw,th=Audit(ts,tc) if tw<=0 or th<=0 then goto s end local sx=cw/tw; local sy=ch/th; local nf,nfx,nfy; if opt.mode=="fill" then nf=p.fontsize; nfx=math.max(MIN_SC,math.min(MAX_SC,p.scale_x*sx)); nfy=math.max(MIN_SC,math.min(MAX_SC,p.scale_y*sy)) elseif opt.mode=="prop" then local ms=math.min(sx,sy); nf=p.fontsize; nfx=math.max(MIN_SC,math.min(MAX_SC,p.scale_x*ms)); nfy=math.max(MIN_SC,math.min(MAX_SC,p.scale_y*ms)) elseif opt.mode=="center" then local ms=math.min(sx,sy); nf=math.max(MIN_FS,p.fontsize*ms); nfx=p.scale_x; nfy=p.scale_y elseif opt.mode=="justify" then local tnb=tc:gsub("\\N"," "):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""); local words=Lines(tnb," "); if #words==0 then goto s end local jfs=p.fontsize; local jt; for iter=1,20 do local jts=table.copy(ts); jts.fontsize=jfs; local jt_try=Block(words,cw,jts); local _,jh=Audit(jts,jt_try); if jh<=ch then jt=jt_try; break end jfs=jfs*0.92; if jfs<MIN_FS then jfs=MIN_FS; local jts2=table.copy(ts); jts2.fontsize=jfs; jt=Block(words,cw,jts2); break end end if not jt then local jts=table.copy(ts); jts.fontsize=jfs; jt=Block(words,cw,jts) end local head=l.text:match("^{[^}]*}") or ""; head=head:gsub("\\fs[%d%.%-]+",""):gsub("\\fscx[%d%.%-]+",""):gsub("\\fscy[%d%.%-]+",""):gsub("\\pos%([^%)]*%)",""):gsub("\\move%([^%)]*%)",""):gsub("\\an[1-9]",""):gsub("{}",""); local fstag=(math.abs(jfs-p.fontsize)>0.5) and string.format("\\fs%.0f",jfs) or ""; local newtags=string.format("\\an7\\pos(%.1f,%.1f)%s",cx1+opt.margin,cy1+opt.margin,fstag); if head~="" then head=head:gsub("^{",""):gsub("}$",""); l.text="{"..newtags..head.."}"..jt else l.text="{"..newtags.."}"..jt end if opt.rmclip then l.text=l.text:gsub("\\i?clip%([^%)]*%)","") end l.text=l.text:gsub("{}",""); sub[idx]=l; goto s end nf=math.floor(nf+0.5); nfx=math.floor(nfx+0.5); nfy=math.floor(nfy+0.5); local twt=Wipe(l.text); twt=twt:gsub("\\pos%([^%)]*%)",""):gsub("\\move%([^%)]*%)",""):gsub("\\an[1-9]",""); local nt=string.format("\\an5\\pos(%.1f,%.1f)\\fs%d\\fscx%d\\fscy%d",center_x,center_y,nf,nfx,nfy); local ft; if twt:match("^{") then ft=twt:gsub("^{","{"..nt,1) else ft="{"..nt.."}"..twt end l.text=ft; if opt.rmclip then l.text=l.text:gsub("\\i?clip%([^%)]*%)","") end sub[idx]=l ::s:: end end
local Vocal={}
local ul=unicode.to_lower_case
local uu=unicode.to_upper_case
local function isLetter(c) if not c or c=="" then return false end local lo,up=ul(c),uu(c); return lo~=up or c:match("^[%a]$")~=nil end
local function isWordBoundary(c) if not c or c=="" then return true end if c:match("^[%s%p]$") then return true end return not isLetter(c) end
local function splitTags(text) local p,pos={},1; while pos<=#text do local ts=text:find("{",pos,true); if ts==pos then local te=text:find("}",pos,true); if te then table.insert(p,{type="tag",text=text:sub(pos,te)}); pos=te+1 else table.insert(p,{type="char",text=text:sub(pos,pos)}); pos=pos+1 end else local c=text:match("^[%z\1-\127\194-\244][\128-\191]*",pos); if c then table.insert(p,{type="char",text=c}); pos=pos+#c else table.insert(p,{type="char",text=text:sub(pos,pos)}); pos=pos+1 end end end return p end
local function toTitleCase(text) local parts,result,prev=splitTags(text),{},true; for _,part in ipairs(parts) do if part.type=="tag" then table.insert(result,part.text) else local c=part.text; if isLetter(c) then if prev then table.insert(result,uu(c)) else table.insert(result,ul(c)) end prev=false else table.insert(result,c); prev=isWordBoundary(c) end end end return table.concat(result) end
local function toSentenceCase(text) local parts,result,needUp=splitTags(text),{},true; local se={["."]=true,["?"]=true,["!"]=true,["¿"]=true,["¡"]=true}; for _,part in ipairs(parts) do if part.type=="tag" then table.insert(result,part.text) else local c=part.text; if isLetter(c) then if needUp then table.insert(result,uu(c)); needUp=false else table.insert(result,ul(c)) end else table.insert(result,c); if se[c] then needUp=true end end end end local f=table.concat(result); f=f:gsub(" i([' %?!%.,])"," I%1"):gsub(" i$"," I"); return f end
function Vocal.Tone(sub,sel,m) for _,i in ipairs(sel) do local l=sub[i]; local t=l.text; if m=="UPPER" then t=t:gsub("\\[Nnh]","{%1}"); t=t:gsub("^([^{]*)",function(u) return uu(u) end); t=t:gsub("}([^{]*)",function(u) return "}"..uu(u) end); t=t:gsub("{(\\[Nnh])}","%1") elseif m=="lower" then t=t:gsub("\\[Nnh]","{%1}"); t=t:gsub("^([^{]*)",function(u) return ul(u) end); t=t:gsub("}([^{]*)",function(u) return "}"..ul(u) end); t=t:gsub("{(\\[Nnh])}","%1") elseif m=="Title" then t=toTitleCase(t) elseif m=="Sentence" then t=toSentenceCase(t) end l.text=t; sub[i]=l end end
function Vocal.Echo(sub,sel,m) for _,i in ipairs(sel) do local l=sub[i]; local h=l.text:match("^{[^}]*}") or ""; h=h:gsub("\\alpha[%d%.%-]+",""):gsub("\\t%b()",""); local p=l.text:gsub("{[^}]*}",""); local c={}; for ch in unicode.chars(p) do table.insert(c,ch) end if #c==0 then goto s end local d=l.end_time-l.start_time; local mpc=m=="Frame" and 42 or (d/#c); local r=""; for k,ch in ipairs(c) do local ts=math.floor((k-1)*mpc); r=r..string.format("{\\alpha&HFF&\\t(%d,%d,\\alpha&H00&)}%s",ts,ts+1,ch) end l.text=h..r:gsub("}{",""); sub[i]=l ::s:: end end
function Vocal.Drop(sub,sel) local m,s=karaskel.collect_head(sub,false); local nl,dl={},{}; for _,i in ipairs(sel) do local l=sub[i]; karaskel.preproc_line(sub,m,s,l); local px,py=l.text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)"); px,py=tonumber(px) or l.x,tonumber(py) or l.y; local p=l.text_stripped; local c={}; for ch in unicode.chars(p) do table.insert(c,ch) end local cy=0; local h=l.text:match("^{[^}]*}") or ""; h=h:gsub("\\pos%b()",""):gsub("\\an%d",""); for k,ch in ipairs(c) do local n=table.copy(l); local _,chH=aegisub.text_extents(l.styleref,ch); local chh=chH*(l.styleref.scale_y/100); n.text=string.format("{\\an5\\pos(%.1f,%.1f)%s}%s",px,py+cy,h:gsub("[{}]",""),ch); cy=cy+chh; table.insert(nl,{idx=i,line=n}) end table.insert(dl,i) end local o=0; for _,d in ipairs(nl) do sub.insert(d.idx+1+o,d.line); o=o+1 end for j=#dl,1,-1 do sub.delete(dl[j]) end end
local function Ring_Tag(t) local r=t; r=r:gsub("\\pos%b()",""):gsub("\\org%b()",""):gsub("\\move%b()",""); r=r:gsub("\\frz[%d%.%-]+",""):gsub("\\an%d",""); return r end
local function Ring_Style(s,t) if not t then return end local fn=t:match("\\fn([^\\}]+)"); local fs=t:match("\\fs([%d%.]+)"); local fx=t:match("\\fscx([%d%.]+)"); local fp=t:match("\\fsp([%d%.%-]+)"); local b=t:match("\\b([01])"); local i=t:match("\\i([01])"); if fn then s.fontname=fn end if fs then s.fontsize=tonumber(fs) end if fx then s.scale_x=tonumber(fx) end if fp then s.spacing=tonumber(fp) end if b then s.bold=(b=="1") end if i then s.italic=(i=="1") end end
function Vocal.Orbit(sub,sel,opt) opt=opt or {}; opt.rot_mode=opt.rot_mode or "Normal"; opt.radio_mod=opt.radio_mod or 0; opt.tracking=opt.tracking or 0; opt.invertir_dir=opt.invertir_dir or false; opt.borrar=opt.borrar or false; local m,s=karaskel.collect_head(sub,false); for z=#sel,1,-1 do local idx=sel[z]; local l=sub[idx]; karaskel.preproc_line(sub,m,s,l); local px,py=l.text:match("\\pos%(([%d%.%-eE%+]+),([%d%.%-eE%+]+)%)"); local ox,oy=l.text:match("\\org%(([%d%.%-eE%+]+),([%d%.%-eE%+]+)%)"); if not(px and py and ox and oy) then aegisub.log("Error line "..idx..": Missing \\pos or \\org.\n") goto s end px,py,ox,oy=tonumber(px),tonumber(py),tonumber(ox),tonumber(oy); local rad=math.sqrt((px-ox)^2+(py-oy)^2)+opt.radio_mod; local ang=math.atan2(py-oy,px-ox); if rad<1 then goto s end local tok={}; local tf=l.text; if tf:sub(1,1)~="{" then tf="{}"..tf end local sv=table.copy(l.styleref); for tb,tx in tf:gmatch("({[^}]*})([^{]*)") do Ring_Style(sv,tb); local tl=Ring_Tag(tb); table.insert(tok,{tags=tl,texto=tx,estilo=table.copy(sv)}) end local dl={}; local aw=0; local ht=""; local t1=tok[1]; local fh=t1 and (t1.estilo.fontsize*(t1.estilo.scale_y/100)) or 20; local bord_val=tonumber(l.text:match("\\bord([%d%.]+)")) or l.styleref.outline or 0; local ro=rad+(fh/2.2); for _,tk in ipairs(tok) do ht=ht..tk.tags; local sx=tk.estilo.scale_x/100; local sy=tk.estilo.scale_y/100; for ch in unicode.chars(tk.texto) do local w,h,d,el=aegisub.text_extents(tk.estilo,ch); local ar=(w*sx)+(tk.estilo.spacing*sx)+opt.tracking+(bord_val*2*sx); local ac=ar/ro; table.insert(dl,{char=ch,angulo_rad=ac,tags_activos=ht,descent=d*sy}); aw=aw+ac end end if #dl>0 then aw=aw-(opt.tracking/ro) end local th=(py<oy); local pd=th and 1 or -1; if opt.invertir_dir then pd=pd*-1 end local acur=ang-(pd*(aw/2)); local nl={}; for _,let in ipairs(dl) do if not let.char:match("^%s*$") then local am=acur+(pd*(let.angulo_rad/2)); local fx=ox+rad*math.cos(am); local fy=oy+rad*math.sin(am); local rot=-math.deg(am)-90; if opt.rot_mode=="Vertical" then rot=0 elseif opt.rot_mode=="Invertido" then rot=rot+180 end local nln=table.copy(l); local tb=let.tags_activos:gsub("}$",""); if not tb:match("^{") and tb~="" then tb="{"..tb end if tb=="" then tb="{" end local tg=string.format("\\an5\\pos(%.2f,%.2f)\\frz%.2f}",fx,fy,rot); nln.text=tb..tg..let.char; nln.layer=l.layer+1; table.insert(nl,nln) end acur=acur+(pd*let.angulo_rad) end for i,n in ipairs(nl) do sub.insert(idx+i,n) end if opt.borrar then sub.delete(idx) else l.comment=true; l.text="{Origin} "..l.text; sub[idx]=l end ::s:: end end
local Focus={}
local function Lens_Info(t,s) local i={}; local tg=t:match("^{\\[^}]-}") or ""; tg=tg:gsub("\\t%b()",""); i.cp=tg:match("^{[^}]-\\c(&H%x+&)") or s.color1:gsub("H%x%x","H"); i.cbe=s.color3:gsub("H%x%x","H"); i.cb=tg:match("^{[^}]-\\3c(&H%x+&)") or i.cbe; i.tb=tg:match("^{[^}]-\\bord([%d%.]+)") or tostring(s.outline); i.ts=tg:match("^{[^}]-\\shad([%d%.]+)") or tostring(s.shadow); i.rcb=i.cbe; i.rcp=i.cp; i.rtb=i.tb; return i end
local function Lens_Pre(t,bd,i) local function ab(x) if not x:match("^{\\") then return "{\\blur"..bd.."}"..x end if not x:match("\\blur") then return x:gsub("^{\\","{\\blur"..bd.."\\") end if x:match("\\blur") and not x:match("^{[^}]*blur[^}]*}") then return x:gsub("^{\\","{\\blur"..bd.."\\") end return x end t=ab(t); t=t:gsub("(\\r[^}]-)}","%1\\blur"..bd.."}"); if t:match("^{[^}]-\\t[^}]-}") and not t:match("^{[^}]-\\3c[^}]-\\t") then t=t:gsub("^{\\","{\\3c"..i.cbe.."\\") end t=t:gsub("\\1c","\\c"); return t end
local function Lens_Top(t,ts,k) local x=t; x=x:gsub("(\\t%([^%)]*)\\bord[%d%.]+","%1"):gsub("(\\t%([^%)]*)\\shad[%d%.]+","%1"):gsub("\\t%([^\\]*%)",""); if not x:match("^{[^}]-\\bord") then x=x:gsub("^{\\","{\\bord0\\") end x=x:gsub("\\bord[%d%.]+","\\bord0"):gsub("(\\r[^}]-)}","%1\\bord0}"); x=x:gsub("(\\[xy]bord)[%d%.]+",""):gsub("\\3c&H%x+&",""); if ts~="0" then x=x:gsub("^({\\[^}]+)}","%1\\shad"..ts.."}") end x=x:gsub("^({\\[^}]-)}","%1\\4a&HFF&}"); x=x:gsub("(\\r[^}]-)}","%1\\shad"..ts.."\\4a&HFF&}"); x=x:gsub("\\bord[%d%.%-]+([^}]-)(\\bord[%d%.%-]+)","%1%2"); x=x:gsub("\\shad[%d%.%-]+([^}]-)(\\shad[%d%.%-]+)","%1%2"); if k then x=x:gsub("\\4a&HFF&","") end x=x:gsub("{}",""); return x end
local function Lens_Mid(t,i,c) local x=t:gsub("\\c&H%x+&",""); if x:match("^{[^}]-\\t%([^%)]-\\3c") then local pt=t:match("^{(\\[^}]-)\\t"); if pt and not pt:match("^{[^}]-\\3c") then x=x:gsub("^{\\","{\\c"..i.cbe.."\\") end end if not x:match("^{[^}]-\\3c&[^}]-}") then x=x:gsub("^({\\[^}]+)}","%1\\c"..i.cbe.."}"):gsub("(\\r[^}]-)}","%1\\c"..i.rcb.."}") end x=x:gsub("(\\3c)(&H%x+&)","%1%2\\c%2"):gsub("(\\r[^}]-)}","%1\\c"..i.rcb.."}"):gsub("(\\r[^}]-\\3c)(&H%x+&)([^}]-)}","%1%2\\c%2%3}"); x=x:gsub("\\c&H%x+&([^}]-)(\\c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end); x=x:gsub("{%*?}",""); if c.blur_fondo_activo and not c.es_doble then x=x:gsub("\\blur[%d%.]+","\\blur"..c.val_blur_fondo) end return x end
local function Lens_Bot(t,i,c) local x=t; local cc=i.cp; if c.color2_activo then cc=c.color2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&") end if not x:match("^{[^}]-\\bord") then x=x:gsub("^{\\","{\\bord"..i.tb.."\\") end x=x:gsub("(\\r[^\\}]-)([\\}])","%1\\bord"..i.rtb.."%2"):gsub("(\\bord)([%d%.]+)",function(g,v) local s=c.tam_borde2_activo and c.tam_borde2 or tonumber(v); return g..(tonumber(v)+s) end):gsub("(\\[xy]bord)([%d%.]+)",function(g,v) return g..(tonumber(v)*2) end); x=x:gsub("\\3c&H%x+&",""):gsub("^({\\[^}]+)}","%1\\3c"..cc.."}") if c.color2_activo then x=x:gsub("\\c&H%x+&([^}]-)}","\\c"..cc.."\\3c"..cc.."%1}") else x=x:gsub("(\\c)(&H%x+&)([^}]-)}","%1%2%3\\3c%2}") end x=x:gsub("(\\r[^}]+)}","%1\\3c"..i.rcp.."}") if c.blur_fondo_activo and c.es_doble then x=x:gsub("\\blur[%d%.]+","\\blur"..c.val_blur_fondo) end return x end
local function Lens_Glow(t,c,ca) local x=t; local a=c.glow_alpha; local b=c.glow_blur; x=x:gsub("\\alpha&H(%x%x)&",function(v) return (tonumber(v,16)>tonumber(a,16)) and "\\alpha&H"..v.."&" or "\\alpha&H"..a.."&" end); local cn=c.glow_desde_borde and "3" or "1"; x=x:gsub("\\"..cn.."a&H(%x%x)&",function(v) return (tonumber(v,16)>tonumber(a,16)) and "\\"..cn.."a&H"..v.."&" or "\\"..cn.."a&H"..a.."&" end); x=x:gsub("(\\blur)[%d%.]*([\\}])","%1"..b.."%2"); if not x:match("^{[^}]-\\alpha") then x=x:gsub("^({\\[^}]-)}","%1\\alpha&H"..a.."&}") end if c.color_glow_activo and ca then local tc=c.glow_desde_borde and "3c" or "c"; if x:match("^{\\[^}]-\\"..tc.."&") then x=x:gsub("\\"..tc.."&H%x+&","\\"..tc..ca) else x=x:gsub("^({\\[^}]-)}","%1\\"..tc..ca.."}") end end return x end
local function Lens_Fade(t,d,o,m) local fi,fo=t:match("\\fad%((%d+),(%d+)"); if not fi then return t end fi,fo=tonumber(fi),tonumber(fo); local ix=m and fi or o; local ox=m and fo or o; if fi>0 then t=t:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t("..(fi-ix)..","..fi..",\\1a&H00&)}") end if fo>0 then t=t:gsub("^({\\[^}]-)}","%1\\t("..(d-fo)..","..(d-fo+ox)..",\\1a&HFF&)}") end return t end
function Focus.Dim(sub,sel,c) for _,i in ipairs(sel) do local l=sub[i]; local d=l.end_time-l.start_time; if l.text:match("\\fad") then l.text=l.text:gsub("\\1a&H%x+&",""):gsub("\\t%([^\\%(%)]-%)",""); l.text=Lens_Fade(l.text,d,c.offset,c.is_max); sub[i]=l end end end
function Focus.Haze(sub,sel,c) local st={}; for i=1,#sub do if sub[i].class=="style" then st[sub[i].name]=sub[i] end end local cga=c.color_glow_activo and c.glow_color:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&") or nil; c.blur_defecto=c.blur_defecto or 0.6; c.glow_blur=c.glow_blur or 3; c.glow_alpha=c.glow_alpha or "80"; for z=#sel,1,-1 do local i=sel[z]; local l=sub[i]; local s=st[l.style] or st["Default"]; if not s then aegisub.log("Warning: Style '"..l.style.."' not found, skipping line "..i.."\n"); goto cont end local d=l.end_time-l.start_time; local bl=l.layer; local infor=Lens_Info(l.text,s); l.text=Lens_Pre(l.text,c.blur_defecto,infor); local tb=(infor.tb~="0" or l.text:match("\\[xy]bord")); local n={}; local tf=l.text; local lo=0; if c.modo=="Blur+Glow" then c.glow_desde_borde=tb; if tb then if c.es_doble then local l1=table.copy(l); l1.text=Lens_Bot(l.text,infor,c); l1.layer=bl; local l2=table.copy(l); l2.text=Lens_Mid(l.text,infor,c); l2.layer=bl+1; if infor.ts~="0" then l2.text=l2.text:gsub("^({\\[^}]+)}","%1\\shad"..infor.ts.."}") end l2.text=l2.text:gsub("^({\\[^}]-)}","%1\\4a&HFF&}"); local l3=table.copy(l); l3.text=Lens_Top(l.text,infor.ts,false); l3.layer=bl+2; table.insert(n,l1); table.insert(n,l2); table.insert(n,l3); tf=Lens_Bot(l.text,infor,c); tf=Lens_Glow(tf,c,cga); lo=3 else local l2=table.copy(l); l2.text=Lens_Mid(l.text,infor,c); l2.layer=bl; local l3=table.copy(l); l3.text=Lens_Top(l.text,infor.ts,false); l3.layer=bl+1; table.insert(n,l2); table.insert(n,l3); tf=Lens_Glow(l.text,c,cga); lo=2 end else local l2=table.copy(l); l2.layer=bl; table.insert(n,l2); tf=Lens_Glow(l.text,c,cga); lo=1 end elseif c.modo=="Blur+Capas" then if c.es_doble then local l2=table.copy(l); l2.text=Lens_Mid(l.text,infor,c); l2.layer=bl; l2.text=l2.text:gsub("^({\\[^}]-)}","%1\\4a&HFF&}"); local l3=table.copy(l); l3.text=Lens_Top(l.text,infor.ts,false); l3.layer=bl+1; table.insert(n,l2); table.insert(n,l3); tf=Lens_Bot(l.text,infor,c); lo=2 else local l3=table.copy(l); l3.text=Lens_Top(l.text,infor.ts,false); l3.layer=bl; table.insert(n,l3); tf=Lens_Mid(l.text,infor,c); lo=1 end end if c.corregir_fade and tf:match("\\fad") then tf=Lens_Fade(tf,d,c.tiempo_fade,c.modo_fade_max) end l.text=tf; l.layer=bl+lo; sub[i]=l; for idx,nl in ipairs(n) do sub.insert(i+idx,nl) end for sz=z,#sel do sel[sz]=sel[sz]+#n end ::cont:: end return sel end
local RowBox={}
local function RB_esVectorial(t) return t:find("\\p1")~=nil end
local function RB_analizarLinea(texto)
  local tags_ini,resto="",texto
  while resto:match("^{[^}]-}") do local tag=resto:match("^({[^}]-})"); tags_ini=tags_ini..tag; resto=resto:sub(#tag+1) end
  local partes,i={},1
  while i<=#resto do if resto:sub(i,i)=="{" then local fin=resto:find("}",i); if fin then table.insert(partes,{tipo="tag",contenido=resto:sub(i,fin)}); i=fin+1 else table.insert(partes,{tipo="texto",contenido=resto:sub(i,i)}); i=i+1 end else table.insert(partes,{tipo="texto",contenido=resto:sub(i,i)}); i=i+1 end end
  local vis,tags_mid="","" for _,p in ipairs(partes) do if p.tipo=="texto" then vis=vis..p.contenido else tags_mid=tags_mid..p.contenido end end
  return tags_ini,vis,tags_mid
end
local function RB_agruparLineas(sub,sel,usarCap,limite,omitirVect)
  local grupos,lista,omC,omV={},{},0,0
  for _,i in ipairs(sel) do local l=sub[i]; local ti,vis,tf=RB_analizarLinea(l.text)
    if vis~="" then local incluir=true
      if omitirVect and RB_esVectorial(l.text) then incluir=false; omV=omV+1 end
      if incluir and usarCap and #vis>limite then incluir=false; omC=omC+1 end
      if not grupos[vis] then grupos[vis]={}; if incluir then table.insert(lista,vis) end end
      table.insert(grupos[vis],{idx=i,tags_ini=ti,tags_fin=tf,omitida=not incluir})
    end
  end
  return grupos,lista,omC,omV
end
function RowBox.MassSigns(sub,sel)
  if #sel==0 then return "cancelled" end
  local cfgDlg={{class="label",x=0,y=0,width=2,height=1,label="TAG-PRESERVING EDITOR SETTINGS"},{class="checkbox",x=0,y=1,width=2,name="omitir_vectoriales",label="Skip vector drawings (\\p1)",value=true},{class="checkbox",x=0,y=2,width=2,name="usar_cap",label="Apply character limit",value=false},{class="intedit",x=0,y=3,width=1,name="limite",value=150,min=1,max=1000}}
  local ret1,res1=aegisub.dialog.display(cfgDlg,{"Continue","Cancel"},{ok="Continue",close="Cancel"})
  if ret1~="Continue" then return "cancelled" end
  local grupos,lista,omC,omV=RB_agruparLineas(sub,sel,res1.usar_cap,res1.limite,res1.omitir_vectoriales)
  if #lista==0 then return "cancelled" end
  local original=table.concat(lista,"\n")
  local editDlg={{class="label",x=0,y=0,width=40,height=1,label="ORIGINAL VISIBLE TEXT"},{class="textbox",x=0,y=1,width=40,height=12,name="original",text=original},{class="label",x=41,y=0,width=40,height=1,label="MODIFIED TEXT"},{class="textbox",x=41,y=1,width=40,height=12,name="cambios",text=original},{class="label",x=0,y=13,width=81,height=1,label="Identical texts grouped. Each line keeps unique tags."}}
  local ret2,res2=aegisub.dialog.display(editDlg,{"Apply","Cancel"},{ok="Apply",close="Cancel"})
  if ret2~="Apply" then return "cancelled" end
  local cambios={}; for line in res2.cambios:gmatch("[^\r\n]+") do table.insert(cambios,line) end
  if #cambios~=#lista then return "cancelled" end
  local mapa={}; for i,orig in ipairs(lista) do mapa[orig]=cambios[i] end
  local mod=0
  for txt,datos in pairs(grupos) do local nuevo=mapa[txt]
    if nuevo then for _,d in ipairs(datos) do if not d.omitida then local l=sub[d.idx]; l.text=d.tags_ini..nuevo..d.tags_fin; sub[d.idx]=l; mod=mod+1 end end end
  end
  aegisub.set_undo_point("Mass-Signs")
  return "ok"
end
local Tools={}
local function Tool_ExtractTags(t) local r={}; r.frx=t:match("\\frx(%-?[%d%.]+)"); r.fry=t:match("\\fry(%-?[%d%.]+)"); r.frz=t:match("\\frz(%-?[%d%.]+)"); r.fax=t:match("\\fax(%-?[%d%.]+)"); r.fay=t:match("\\fay(%-?[%d%.]+)"); local px,py=t:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)"); r.px,r.py=tonumber(px),tonumber(py); local ox,oy=t:match("\\org%(([%d%.%-]+),([%d%.%-]+)%)"); r.ox,r.oy=tonumber(ox) or r.px,tonumber(oy) or r.py; return r end
local function Tool_HasPersp(t) return t.frx or t.fry or t.frz or t.fax or t.fay end
function Tools.CopyPerspProj(sub,sel) if #sel<2 then aegisub.dialog.display({{class="label",label="Select at least 2 lines."}},{"OK"}); return end local src=Tool_ExtractTags(sub[sel[1]].text); if not Tool_HasPersp(src) then aegisub.dialog.display({{class="label",label="First line has no perspective tags."}},{"OK"}); return end local ox,oy=0,0; if src.px and src.ox then ox,oy=src.px-src.ox,src.py-src.oy end for i=2,#sel do local l=sub[sel[i]]; local d=Tool_ExtractTags(l.text); local dx,dy=d.px or 640,d.py or 360; local nx,ny=dx-ox,dy-oy; local p=""; if src.frx then p=p.."\\frx"..src.frx end if src.fry then p=p.."\\fry"..src.fry end if src.frz then p=p.."\\frz"..src.frz end if src.fax then p=p.."\\fax"..src.fax end if src.fay then p=p.."\\fay"..src.fay end p=p..string.format("\\org(%.2f,%.2f)",nx,ny); local t=l.text:gsub("\\fr[xyz]%-?[%d%.]+",""):gsub("\\fa[xy]%-?[%d%.]+",""):gsub("\\org%([^%)]+%)",""); if t:match("^{") then t=t:gsub("^{","{"..p) else t="{"..p.."}"..t end l.text=t:gsub("{}",""); sub[sel[i]]=l end aegisub.set_undo_point("Copy Persp Project") end
function Tools.CopyPerspExact(sub,sel) if #sel<2 then aegisub.dialog.display({{class="label",label="Select at least 2 lines."}},{"OK"}); return end local src=Tool_ExtractTags(sub[sel[1]].text); if not Tool_HasPersp(src) then aegisub.dialog.display({{class="label",label="First line has no perspective tags."}},{"OK"}); return end local p=""; if src.frx then p=p.."\\frx"..src.frx end if src.fry then p=p.."\\fry"..src.fry end if src.frz then p=p.."\\frz"..src.frz end if src.fax then p=p.."\\fax"..src.fax end if src.fay then p=p.."\\fay"..src.fay end if src.ox and src.oy then p=p..string.format("\\org(%.2f,%.2f)",src.ox,src.oy) end for i=2,#sel do local l=sub[sel[i]]; local t=l.text:gsub("\\fr[xyz]%-?[%d%.]+",""):gsub("\\fa[xy]%-?[%d%.]+",""):gsub("\\org%([^%)]+%)",""); if t:match("^{") then t=t:gsub("^{","{"..p) else t="{"..p.."}"..t end l.text=t:gsub("{}",""); sub[sel[i]]=l end aegisub.set_undo_point("Copy Persp Exact") end
function Tools.CopyClip(sub,sel) if #sel<2 then return end local cmd,val,si; for _,i in ipairs(sel) do local f,a=sub[i].text:match("\\(i?)clip%(([^%)]+)%)"); if a then cmd=f=="i" and "iclip" or "clip"; val=a; si=i; break end end if not val then return end for _,i in ipairs(sel) do if i~=si then local l=sub[i]; if l.text:find("\\clip") or l.text:find("\\iclip") then l.text=l.text:gsub("\\i?clip%([^%)]+%)","\\"..cmd.."("..val..")") elseif l.text:match("^{") then l.text=l.text:gsub("^{","{\\"..cmd.."("..val..")") else l.text="{\\"..cmd.."("..val..")}"..l.text end sub[i]=l end end aegisub.set_undo_point("Copy Clip") end
function Tools.ClipToIClip(sub,sel) for _,i in ipairs(sel) do local l=sub[i]; l.text=l.text:gsub("\\clip%(","\\iclip("); sub[i]=l end aegisub.set_undo_point("Clip to iClip") end
function Tools.IClipToClip(sub,sel) for _,i in ipairs(sel) do local l=sub[i]; l.text=l.text:gsub("\\iclip%(","\\clip("); sub[i]=l end aegisub.set_undo_point("iClip to Clip") end
local Ensemble={}
function Ensemble.Trope(sub,sel,c) local st={}; for i=1,#sub do if sub[i].class=="style" then st[sub[i].name]=sub[i] end end for z=#sel,1,-1 do local i=sel[z]; local l=sub[i]; local s=st[l.style] or st["Default"]; if l.text:sub(1,1)~="{" then l.text="{}"..l.text end local bb=c.use_borde1 and c.tam_borde1 or (tonumber(l.text:match("\\bord([%d%.]+)")) or s.outline); local bl=l.layer; local dp=1; if c.use_borde1 then dp=dp+1 end if c.use_borde2 then dp=dp+1 end if c.use_borde3 then dp=dp+1 end if c.use_borde4 then dp=dp+1 end local cp={}; local f=table.copy(l); f.text=l.text:gsub("\\bord[%d%.]+","\\bord0"); if not f.text:match("\\bord") then f.text=f.text:gsub("^{","{\\bord0") end f.layer=bl+dp; table.insert(cp,f); local ac=0; local cd=dp; local function ab(u,sz,o) if u then cd=cd-1; ac=ac+sz; local b=table.copy(l); b.text=l.text:gsub("\\bord[%d%.]+","\\bord"..ac); if not b.text:match("\\bord") then b.text=b.text:gsub("^{","{\\bord"..ac) end b.text=b.text:gsub("^({[^}]-)}","%1\\1a&HFF&}"); if o then local cl=o:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&"); b.text=b.text:gsub("\\3c&H%x+&",""):gsub("^({[^}]-)}","%1\\3c"..cl.."}") end b.layer=bl+cd; table.insert(cp,b) end end ab(c.use_borde1,c.tam_borde1,c.color_borde1); ab(c.use_borde2,c.tam_borde2,c.color_borde2); ab(c.use_borde3,c.tam_borde3,c.color_borde3); ab(c.use_borde4,c.tam_borde4,c.color_borde4); sub.delete(i); for idx,v in ipairs(cp) do sub.insert(i+idx-1,v) end for sz=z,#sel do sel[sz]=sel[sz]+(#cp-1) end end return sel end
local function load_cfg() local f=io.open(CFG_FILE,"r"); if not f then return nil end local c=f:read("*all"); f:close(); local chunk=loadstring("return "..c); if chunk then local ok,t=pcall(chunk); if ok and type(t)=="table" then return t end end return nil end
local function save_cfg(c) local f=io.open(CFG_FILE,"w"); if not f then return end f:write("{\n"); for k,v in pairs(c) do if type(v)=="string" then f:write(string.format("  %s = %q,\n",k,v)) elseif type(v)=="boolean" then f:write(string.format("  %s = %s,\n",k,tostring(v))) else f:write(string.format("  %s = %s,\n",k,tostring(v))) end end f:write("}\n"); f:close() end
local HELP_EN=[[
RHEAROW MASTER v3.0 - Help
══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────┐
   PERSPECTIVA - 3D Rotation Tool     
└─────────────────────────────────────┘
  Creates 3D perspective from a 3-4 point \clip.
  
  Modes:
    • Generate 4th    → Completes quadrilateral from 3 points
    • Gen+Apply       → Generates 4th point AND applies \frx\fry\frz
    • Apply Only      → Only applies rotation (requires 4-point clip)
  
  Options:
    • Copy \clip      → Copies clip to subsequent lines without one
    • Keep original   → Preserves original line as comment
    • Normalize       → Auto-sorts vertices (ignores drawing order)
  
  Vertex order (without Normalize): clockwise 1→2→3→4
      1────2
      │    │
      4────3

┌─────────────────────────────────────┐
   MÁSCARAS - Vector Shape Masks      
└─────────────────────────────────────┘
  Creates solid shapes from \clip or predefined masks.
  
  Sources:
    • from clip   → Uses existing \clip as mask shape
    • Predefined  → square, circle, triangle, rounded
  
  Options:
    • New layer       → Creates mask on new layer above
    • Replace         → Converts existing p1 drawing to new mask
    • Bicubic (q2)    → Enables smoother anti-aliasing
    • Transparency    → Sets alpha value for the mask
    • Colorize        → Applies custom color to mask

┌─────────────────────────────────────┐
   TOOLS - Perspective & Clip Utils   
└─────────────────────────────────────┘
  Perspective copy:
    • Copy Persp (Project) → Copies \frx\fry\frz with \org recalculated
    • Copy Persp (Exact)   → Copies exact perspective tags
  
  Clip operations:
    • Copy Clip       → Copies \clip/\iclip from 1st line to others
    • Clip to iClip   → Converts \clip to \iclip
    • iClip to Clip   → Converts \iclip to \clip

┌─────────────────────────────────────┐
   SCALE - Text Fitting               
└─────────────────────────────────────┘
  Fits text inside a rectangular \clip area.
  
  Modes:
    • fill      → Stretches text to fill entire area (may distort)
    • prop      → Scales proportionally to fit
    • center    → Centers text at clip center with scaled size
    • justify   → Auto-wraps with \N and justifies to margins
  
  Margin: Extra padding in pixels from clip edges.

┌─────────────────────────────────────┐
   TEXTO - Text Manipulation          
└─────────────────────────────────────┘
  Case conversion:
    • UPPER     → ALL UPPERCASE
    • lower     → all lowercase
    • Title     → Each Word Capitalized
    • Sentence  → First letter of sentences
  
  Typewriter effect:
    • Frame     → 42ms per character (standard frame timing)
    • Duration  → Distributes evenly across line duration
  
  Vertical: Splits each character to separate line with \pos.
    Warning: May fail with emojis or composed Unicode.

┌─────────────────────────────────────┐
   CIRCULAR - Curved Text             
└─────────────────────────────────────┘
  Creates curved text around a center point.
  
  Requirements: Line must have both \pos AND \org tags.
    • \pos defines start position on the curve
    • \org defines center of the circle
  
  Rotation modes:
    • Normal    → Letters rotate to follow curve
    • Inverted  → Letters rotated 180° (upside down curve)
    • Vertical  → No rotation (letters stay upright)
  
  Radio (+/-): Adjusts radius from calculated distance.
  Kerning: Extra spacing between characters.
  Spaces are automatically filtered out.

┌─────────────────────────────────────┐
   FOCUS - Blur & Glow Effects        
└─────────────────────────────────────┘
  Creates multi-layer blur and glow effects.
  
  Modes:
    • Blur+Glow   → Adds glowing aura behind text
    • Blur+Capas  → Border layers only (no glow)
  
  Intensity: Blur amount for glow layer.
  Opacity: Alpha of glow (00=solid, C0=faint).
  Colorize Glow: Custom color for glow effect.
  Double layer: Creates extra border layer for depth.
  Fix Fades: Corrects \fad timing on generated layers.

┌─────────────────────────────────────┐
   BORDES - Stacked Borders           
└─────────────────────────────────────┘
  Creates up to 4 stacked border layers.
  
  Each border:
    • Enable checkbox → Activates this border layer
    • Size value      → Cumulative border thickness
    • Color picker    → Border color (\3c)
  
  Borders stack from innermost to outermost.
  Original text appears on top with \bord0.

┌─────────────────────────────────────┐
   MASS-SIGNS - Tag-Preserving Editor 
└─────────────────────────────────────┘
  Bulk edit text while preserving unique tags per line.
  Groups identical visible texts, lets you edit all at once.
  
  Options:
    • Skip vectors    → Ignore lines with \p1
    • Character limit → Skip lines over N characters
  
  Changes apply to all lines with matching text.
]]
local function showHelpLang()
  local lang_btn = (current_lang == "es") and "EN" or "ES"
  local h = (current_lang == "en") and HELP_EN or [[
RHEAROW MASTER v3.0 - Ayuda
══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────┐
   PERSPECTIVA - Rotación 3D          
└─────────────────────────────────────┘
  Crea perspectiva 3D desde un \clip de 3-4 puntos.
  
  Modos:
    • Generate 4th    → Completa cuadrilátero desde 3 puntos
    • Gen+Apply       → Genera 4to punto Y aplica \frx\fry\frz
    • Apply Only      → Solo aplica rotación (requiere 4 puntos)
  
  Opciones:
    • Copiar \clip    → Copia el clip a líneas siguientes sin él
    • Mantener orig.  → Conserva línea original como comentario
    • Normalizar      → Ordena vértices automáticamente
  
  Orden de vértices (sin Normalizar): horario 1→2→3→4
      1────2
      │    │
      4────3

┌─────────────────────────────────────┐
   MÁSCARAS - Formas Vectoriales      
└─────────────────────────────────────┘
  Crea formas sólidas desde \clip o máscaras predefinidas.
  
  Fuentes:
    • from clip   → Usa \clip existente como forma
    • Predefinidas → square, circle, triangle, rounded
  
  Opciones:
    • Nueva capa      → Crea máscara en capa superior
    • Reemplazar      → Convierte dibujo p1 existente
    • Bicúbico (q2)   → Activa anti-aliasing suave
    • Transparencia   → Establece valor alpha
    • Colorear        → Aplica color personalizado

┌─────────────────────────────────────┐
   TOOLS - Utils de Perspectiva/Clip  
└─────────────────────────────────────┘
  Copia de perspectiva:
    • Copiar Persp (Proyectar) → Copia \frx\fry\frz recalculando \org
    • Copiar Persp (Exacto)    → Copia tags de perspectiva exactos
  
  Operaciones de clip:
    • Copiar Clip     → Copia \clip/\iclip de 1ra línea a otras
    • Clip a iClip    → Convierte \clip a \iclip
    • iClip a Clip    → Convierte \iclip a \clip

┌─────────────────────────────────────┐
   SCALE - Ajuste de Texto            
└─────────────────────────────────────┘
  Ajusta texto dentro de un área \clip rectangular.
  
  Modos:
    • fill      → Estira para llenar (puede distorsionar)
    • prop      → Escala proporcionalmente
    • center    → Centra texto con tamaño escalado
    • justify   → Auto-envuelve con \N y justifica
  
  Margen: Padding adicional en píxeles desde bordes.

┌─────────────────────────────────────┐
   TEXTO - Manipulación de Texto      
└─────────────────────────────────────┘
  Conversión de mayúsculas:
    • UPPER     → TODO EN MAYÚSCULAS
    • lower     → todo en minúsculas
    • Title     → Cada Palabra Con Mayúscula
    • Sentence  → Primera letra de oraciones
  
  Efecto Typewriter:
    • Frame     → 42ms por carácter (timing estándar)
    • Duration  → Distribuye uniformemente en duración
  
  Vertical: Separa cada carácter en línea con \pos.
    Advertencia: Puede fallar con emojis o Unicode compuesto.

┌─────────────────────────────────────┐
   CIRCULAR - Texto en Curva          
└─────────────────────────────────────┘
  Crea texto curvado alrededor de un punto central.
  
  Requisitos: La línea debe tener \pos Y \org.
    • \pos define posición inicial en la curva
    • \org define centro del círculo
  
  Modos de rotación:
    • Normal    → Letras rotan siguiendo la curva
    • Invertido → Letras rotadas 180° (curva invertida)
    • Vertical  → Sin rotación (letras verticales)
  
  Radio (+/-): Ajusta radio desde distancia calculada.
  Kerning: Espaciado extra entre caracteres.
  Los espacios se filtran automáticamente.

┌─────────────────────────────────────┐
   FOCUS - Efectos de Blur y Glow     
└─────────────────────────────────────┘
  Crea efectos de blur y glow multicapa.
  
  Modos:
    • Blur+Glow   → Añade aura brillante detrás del texto
    • Blur+Capas  → Solo capas de borde (sin glow)
  
  Intensidad: Cantidad de blur para capa glow.
  Opacidad: Alpha del glow (00=sólido, C0=tenue).
  Colorear Glow: Color personalizado para efecto.
  Doble capa: Crea capa de borde extra para profundidad.
  Corregir Fades: Corrige timing \fad en capas generadas.

┌─────────────────────────────────────┐
   BORDES - Bordes Apilados           
└─────────────────────────────────────┘
  Crea hasta 4 capas de borde apiladas.
  
  Cada borde:
    • Checkbox activar → Activa esta capa de borde
    • Valor grosor     → Grosor acumulativo del borde
    • Selector color   → Color del borde (\3c)
  
  Los bordes se apilan de interior a exterior.
  El texto original aparece arriba con \bord0.

┌─────────────────────────────────────┐
   MASS-SIGNS - Editor Preserva-Tags  
└─────────────────────────────────────┘
  Edita texto en masa preservando tags únicos por línea.
  Agrupa textos visibles idénticos para editar todos a la vez.
  
  Opciones:
    • Omitir vectores  → Ignora líneas con \p1
    • Límite caracteres → Omite líneas sobre N caracteres
  
  Los cambios aplican a todas las líneas con texto coincidente.
]]
  local hbtn=aegisub.dialog.display({{class="textbox",name="h",text=h,x=0,y=0,width=60,height=30}},{"OK",L("btn_config"),lang_btn})
  return hbtn
end
local function Overture(sub,sel,def_cfg)
local _,mn=Intro()
local D={pmode="Gen+Apply",pcopy=true,pkeep=false,prmclip=false,pnorm=false,mmask="from clip",man="an7",mnew=true,mremask=false,mq2=false,malpha=false,malphaval="80",mcolor=true,mcolorval="#000000",tools_mode="-",fmode="fill",fmargin=2,frmclip=false,case_mode="-",type_mode="-",do_vert=false,blur_mode="Blur+Glow",glow_blur=3,glow_alpha="80",use_glow_color=false,glow_color="#FFFFFF",es_doble=false,fix_fades=false,fade_offset="45",use_borde1=false,tam_borde1=0,color_borde1="#000000",use_borde2=false,tam_borde2=2,color_borde2="#000000",use_borde3=false,tam_borde3=2,color_borde3="#000000",use_borde4=false,tam_borde4=2,color_borde4="#000000",circ_rot="Normal",circ_radio=0,circ_track=0,circ_invert=false,circ_delete=false,lang="es"}
local loaded=load_cfg(); local C=(type(def_cfg)=="table" and def_cfg) or (type(loaded)=="table" and loaded) or D
if C.lang then set_lang(C.lang) end
if sel and sel[1] then local fl=sub[sel[1]]; if fl and fl.text then local db=fl.text:match("\\bord([%d%.]+)"); local d3c=fl.text:match("\\3c&H(%x%x)(%x%x)(%x%x)&"); if db then C.use_borde1=true; C.tam_borde1=tonumber(db) or 0 end if d3c then C.color_borde1="#"..d3c end end end
local ui={
{class="label",label=L("lbl_act1"),x=0,y=0,width=5},
{class="dropdown",name="pmode",x=0,y=1,width=3,items={"Generate 4th","Gen+Apply","Apply Only"},value=C.pmode,hint=L("hint_pmode")},
{class="checkbox",name="pcopy",label=L("chk_copy"),x=0,y=2,width=3,value=C.pcopy},
{class="checkbox",name="pkeep",label=L("chk_keep"),x=0,y=3,width=3,value=C.pkeep},
{class="checkbox",name="prmclip",label=L("chk_rmclip"),x=3,y=2,width=2,value=C.prmclip},
{class="checkbox",name="pnorm",label=L("chk_pnorm"),x=3,y=3,width=2,value=C.pnorm,hint=L("hint_pnorm")},
{class="label",label=L("sep_h"),x=0,y=4,width=5},
{class="label",label=L("lbl_act2"),x=0,y=5,width=5},
{class="dropdown",name="mmask",x=0,y=6,width=3,items=mn,value=C.mmask,hint=L("hint_mmask")},
{class="dropdown",name="man",x=3,y=6,width=2,items={"an1","an2","an3","an4","an5","an6","an7","an8","an9"},value=C.man},
{class="checkbox",name="mnew",label=L("chk_new"),x=0,y=7,width=3,value=C.mnew},
{class="checkbox",name="mremask",label=L("chk_repl"),x=0,y=8,width=3,value=C.mremask},
{class="checkbox",name="mq2",label=L("chk_mq2"),x=3,y=7,width=2,value=C.mq2},
{class="checkbox",name="malpha",label=L("chk_alpha"),x=0,y=9,value=C.malpha},
{class="dropdown",name="malphaval",x=1,y=9,width=2,items={"00","40","60","80","A0","C0","FF"},value=C.malphaval},
{class="checkbox",name="mcolor",label=L("chk_color"),x=3,y=9,width=2,value=C.mcolor},
{class="coloralpha",name="mcolorval",x=0,y=10,width=5,value=C.mcolorval},
{class="label",label=L("lbl_act_tools"),x=0,y=11,width=5},
{class="dropdown",name="tools_mode",x=0,y=12,width=5,items={L("opt_none"),L("opt_persp_proj"),L("opt_persp_exact"),L("opt_copy_clip"),L("opt_clip_to_iclip"),L("opt_iclip_to_clip")},value=C.tools_mode or L("opt_none")},
{class="label",label=L("lbl_act3"),x=5,y=0,width=5},
{class="label",label=L("lbl_margin"),x=5,y=1,width=2},
{class="intedit",name="fmargin",x=7,y=1,width=1,value=C.fmargin,min=0},
{class="dropdown",name="fmode",x=5,y=2,width=4,items={"fill","prop","center","justify"},value=C.fmode,hint=L("hint_fmode")},
{class="checkbox",name="frmclip",label=L("chk_rmclip"),x=5,y=3,width=4,value=C.frmclip},
{class="label",label=L("sep_h"),x=5,y=4,width=5},
{class="label",label=L("lbl_act4"),x=5,y=5,width=5},
{class="label",label=L("lbl_case"),x=5,y=6,width=2},
{class="dropdown",name="case_mode",x=7,y=6,width=3,items={"-","UPPER","lower","Title","Sentence"},value=C.case_mode,hint=L("hint_case")},
{class="label",label=L("lbl_typewriter"),x=5,y=7,width=2},
{class="dropdown",name="type_mode",x=7,y=7,width=3,items={"-","Frame","Duration"},value=C.type_mode,hint=L("hint_type")},
{class="checkbox",name="do_vert",label=L("chk_vert"),x=5,y=8,width=5,value=C.do_vert,hint=L("hint_vert")},
{class="label",label=L("sep_h"),x=5,y=9,width=5},
{class="label",label=L("lbl_act5"),x=5,y=10,width=5},
{class="label",label=L("lbl_rotation"),x=5,y=11,width=2},
{class="dropdown",name="circ_rot",x=7,y=11,width=3,items={"Normal","Invertido","Vertical"},value=C.circ_rot,hint=L("hint_circ_rot")},
{class="label",label=L("lbl_radio"),x=5,y=12,width=2},
{class="floatedit",name="circ_radio",x=7,y=12,width=1,value=C.circ_radio,hint=L("hint_circ_radio")},
{class="label",label=L("lbl_track"),x=8,y=12,width=1},
{class="floatedit",name="circ_track",x=9,y=12,width=1,value=C.circ_track,hint=L("hint_circ_track")},
{class="checkbox",name="circ_invert",label=L("chk_invert"),x=5,y=13,width=3,value=C.circ_invert},
{class="checkbox",name="circ_delete",label=L("chk_delete"),x=8,y=13,width=2,value=C.circ_delete},
{class="label",label=L("lbl_act6"),x=10,y=0,width=5},
{class="label",label=L("lbl_blur_mode"),x=10,y=1,width=2},
{class="dropdown",name="blur_mode",x=12,y=1,width=3,items={"Blur+Glow","Blur+Capas"},value=C.blur_mode,hint=L("hint_blur_mode")},
{class="label",label=L("lbl_glow_int"),x=10,y=2,width=2},
{class="floatedit",name="glow_blur",x=12,y=2,width=1,value=C.glow_blur,min=0,hint=L("hint_glow_blur")},
{class="label",label=L("lbl_glow_alpha"),x=10,y=3,width=2},
{class="dropdown",name="glow_alpha",x=12,y=3,width=1,items={"00","40","60","80","A0","C0"},value=C.glow_alpha,hint=L("hint_glow_alpha")},
{class="checkbox",name="use_glow_color",label=L("chk_glow_color"),x=10,y=4,width=3,value=C.use_glow_color},
{class="color",name="glow_color",x=13,y=4,width=2,value=C.glow_color},
{class="checkbox",name="es_doble",label=L("chk_2nd_bord"),x=10,y=5,width=3,value=C.es_doble},
{class="checkbox",name="fix_fades",label=L("chk_fix_fade"),x=10,y=6,width=3,value=C.fix_fades},
{class="dropdown",name="fade_offset",x=13,y=6,width=2,items={"0","45","80","120","max"},value=C.fade_offset},
{class="label",label=L("sep_h"),x=10,y=7,width=5},
{class="label",label=L("lbl_act7"),x=10,y=8,width=5},
{class="label",label=L("lbl_bord_header"),x=10,y=9,width=5},
{class="checkbox",name="use_borde1",label=L("lbl_bord1"),x=10,y=10,width=2,value=C.use_borde1},
{class="floatedit",name="tam_borde1",x=12,y=10,width=1,value=C.tam_borde1,min=0,hint=L("hint_borde")},
{class="color",name="color_borde1",x=13,y=10,width=2,value=C.color_borde1},
{class="checkbox",name="use_borde2",label=L("lbl_bord2"),x=10,y=11,width=2,value=C.use_borde2},
{class="floatedit",name="tam_borde2",x=12,y=11,width=1,value=C.tam_borde2,min=0,hint=L("hint_borde")},
{class="color",name="color_borde2",x=13,y=11,width=2,value=C.color_borde2},
{class="checkbox",name="use_borde3",label=L("lbl_bord3"),x=10,y=12,width=2,value=C.use_borde3},
{class="floatedit",name="tam_borde3",x=12,y=12,width=1,value=C.tam_borde3,min=0,hint=L("hint_borde")},
{class="color",name="color_borde3",x=13,y=12,width=2,value=C.color_borde3},
{class="checkbox",name="use_borde4",label=L("lbl_bord4"),x=10,y=13,width=2,value=C.use_borde4},
{class="floatedit",name="tam_borde4",x=12,y=13,width=1,value=C.tam_borde4,min=0,hint=L("hint_borde")},
{class="color",name="color_borde4",x=13,y=13,width=2,value=C.color_borde4}
}
local btn,res=aegisub.dialog.display(ui,{L("btn_perspective"),L("btn_mask"),L("btn_tools"),L("btn_scale"),L("btn_text"),L("btn_circle"),L("btn_blur"),L("btn_bord"),L("btn_fades"),L("btn_mass_signs"),L("btn_help")},{ok=L("btn_text")})
if btn==L("btn_help") then
  local hb=showHelpLang()
  if hb=="EN" then res.lang="en"; set_lang("en"); save_cfg(res)
  elseif hb=="ES" then res.lang="es"; set_lang("es"); save_cfg(res)
  elseif hb==L("btn_config") then res.lang=current_lang; save_cfg(res) end
  Overture(sub,sel,res) return
end
if btn==L("btn_tools") then
  local tm=res.tools_mode
  if tm==L("opt_persp_proj") then Tools.CopyPerspProj(sub,sel)
  elseif tm==L("opt_persp_exact") then Tools.CopyPerspExact(sub,sel)
  elseif tm==L("opt_copy_clip") then Tools.CopyClip(sub,sel)
  elseif tm==L("opt_clip_to_iclip") then Tools.ClipToIClip(sub,sel)
  elseif tm==L("opt_iclip_to_clip") then Tools.IClipToClip(sub,sel) end
  return
end
if btn==L("btn_mass_signs") then local r=RowBox.MassSigns(sub,sel); if r=="cancelled" then Overture(sub,sel,res) end return end
if btn==L("btn_perspective") then Scene(sub,sel,{mode=res.pmode=="Generate 4th" and "gen" or res.pmode=="Gen+Apply" and "gen_apply" or "apply",copy=res.pcopy,keep=res.pkeep,rmclip=res.prmclip,pnorm=res.pnorm})
elseif btn==L("btn_mask") then Veil(sub,sel,{mask=res.mmask,new=res.mnew,remask=res.mremask,alpha=res.malpha,alphaval=res.malphaval,color=res.mcolor,mcolor=res.mcolorval,an=res.man,q2=res.mq2})
elseif btn==L("btn_scale") then Prop(sub,sel,{mode=res.fmode,margin=res.fmargin,rmclip=res.frmclip})
elseif btn==L("btn_text") then if res.case_mode~="-" then Vocal.Tone(sub,sel,res.case_mode) end if res.type_mode~="-" then Vocal.Echo(sub,sel,res.type_mode) end if res.do_vert then Vocal.Drop(sub,sel) end
elseif btn==L("btn_circle") then Vocal.Orbit(sub,sel,{rot_mode=res.circ_rot,radio_mod=res.circ_radio,tracking=res.circ_track,invertir_dir=res.circ_invert,borrar=res.circ_delete})
elseif btn==L("btn_blur") then Focus.Haze(sub,sel,{modo=res.blur_mode,glow_blur=res.glow_blur,glow_alpha=res.glow_alpha,color_glow_activo=res.use_glow_color,glow_color=res.glow_color,es_doble=res.es_doble,corregir_fade=res.fix_fades,tiempo_fade=res.fade_offset=="max" and 0 or tonumber(res.fade_offset),modo_fade_max=res.fade_offset=="max"})
elseif btn==L("btn_bord") then Ensemble.Trope(sub,sel,{use_borde1=res.use_borde1,tam_borde1=res.tam_borde1,color_borde1=res.color_borde1,use_borde2=res.use_borde2,tam_borde2=res.tam_borde2,color_borde2=res.color_borde2,use_borde3=res.use_borde3,tam_borde3=res.tam_borde3,color_borde3=res.color_borde3,use_borde4=res.use_borde4,tam_borde4=res.tam_borde4,color_borde4=res.color_borde4})
elseif btn==L("btn_fades") then Focus.Dim(sub,sel,{offset=res.fade_offset=="max" and 0 or tonumber(res.fade_offset),is_max=res.fade_offset=="max"}) end
end
aegisub.register_macro(menu_embedding.."Rhearow Master",script_description,Overture)


local function run_for_macro(sub, sel, func)
  local conf = load_cfg() or {}
  if conf.lang then set_lang(conf.lang) end

  local defaults={pmode="Gen+Apply",pcopy=true,pkeep=false,prmclip=false,pnorm=false,mmask="from clip",man="an7",mnew=true,mremask=false,mq2=false,malpha=false,malphaval="80",mcolor=true,mcolorval="#000000",tools_mode="-",fmode="fill",fmargin=2,frmclip=false,case_mode="-",type_mode="-",do_vert=false,blur_mode="Blur+Glow",glow_blur=3,glow_alpha="80",use_glow_color=false,glow_color="#FFFFFF",es_doble=false,fix_fades=false,fade_offset="45",use_borde1=false,tam_borde1=0,color_borde1="#000000",use_borde2=false,tam_borde2=2,color_borde2="#000000",use_borde3=false,tam_borde3=2,color_borde3="#000000",use_borde4=false,tam_borde4=2,color_borde4="#000000",circ_rot="Normal",circ_radio=0,circ_track=0,circ_invert=false,circ_delete=false}
  for k,v in pairs(defaults) do if conf[k]==nil then conf[k]=v end end
  
  func(sub, sel, conf)
end
aegisub.register_macro(menu_embedding.."Utility/Perspective", "Run Perspective with saved settings", function(s,l) run_for_macro(s,l, function(sub,sel,res)
  Scene(sub,sel,{mode=res.pmode=="Generate 4th" and "gen" or res.pmode=="Gen+Apply" and "gen_apply" or "apply",copy=res.pcopy,keep=res.pkeep,rmclip=res.prmclip,pnorm=res.pnorm})
end) end)
aegisub.register_macro(menu_embedding.."Utility/Masks", "Run Masks with saved settings", function(s,l) run_for_macro(s,l, function(sub,sel,res)
  Veil(sub,sel,{mask=res.mmask,new=res.mnew,remask=res.mremask,alpha=res.malpha,alphaval=res.malphaval,color=res.mcolor,mcolor=res.mcolorval,an=res.man,q2=res.mq2})
end) end)
aegisub.register_macro(menu_embedding.."Utility/Scale", "Run Scale with saved settings", function(s,l) run_for_macro(s,l, function(sub,sel,res)
  Prop(sub,sel,{mode=res.fmode,margin=res.fmargin,rmclip=res.frmclip})
end) end)
aegisub.register_macro(menu_embedding.."Utility/Circular", "Run Circular with saved settings", function(s,l) run_for_macro(s,l, function(sub,sel,res)
  Vocal.Orbit(sub,sel,{rot_mode=res.circ_rot,radio_mod=res.circ_radio,tracking=res.circ_track,invertir_dir=res.circ_invert,borrar=res.circ_delete})
end) end)
aegisub.register_macro(menu_embedding.."Utility/Focus", "Run Focus with saved settings", function(s,l) run_for_macro(s,l, function(sub,sel,res)
  Focus.Haze(sub,sel,{modo=res.blur_mode,glow_blur=res.glow_blur,glow_alpha=res.glow_alpha,color_glow_activo=res.use_glow_color,glow_color=res.glow_color,es_doble=res.es_doble,corregir_fade=res.fix_fades,tiempo_fade=res.fade_offset=="max" and 0 or tonumber(res.fade_offset),modo_fade_max=res.fade_offset=="max"})
end) end)
aegisub.register_macro(menu_embedding.."Utility/Text - Vertical Drop", "Run Text Vertical Drop", function(s,l) Vocal.Drop(s,l) end)
aegisub.register_macro(menu_embedding.."Utility/Mass-Signs", "Run Mass-Signs Editor", RowBox.MassSigns)

aegisub.register_macro(menu_embedding.."Utility/Tools/Copy Persp (Project)", "Copy perspective projecting org", Tools.CopyPerspProj)
aegisub.register_macro(menu_embedding.."Utility/Tools/Copy Persp (Exact)", "Copy exact perspective tags", Tools.CopyPerspExact)
aegisub.register_macro(menu_embedding.."Utility/Tools/Copy Clip", "Copy clip to other lines", Tools.CopyClip)
aegisub.register_macro(menu_embedding.."Utility/Tools/Clip to iClip", "Convert clip to iclip", Tools.ClipToIClip)
aegisub.register_macro(menu_embedding.."Utility/Tools/iClip to Clip", "Convert iclip to clip", Tools.IClipToClip)