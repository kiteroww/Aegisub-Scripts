script_name        = "Chronorow Master"
script_description = "This script focuses on assisting with the timing process in Aegisub"
script_author      = "Kiterow"
script_version     = "1.2"

local function cloneLine(l) if type(l.copy)=="function" then return l:copy() end local d={class=l.class or"dialogue"} for k,v in pairs(l)do d[k]=v end setmetatable(d,getmetatable(l)) return d end
local function stripTags(t) return (t:gsub("{[^}]*}",""):gsub("%[.-%]",""):gsub("\\N","")) end
local function charCount(t) return #stripTags(t):gsub("%s",""):gsub("%p","") end
local function calcCPS(l) local d=(l.end_time-l.start_time)/1000 return d>0 and charCount(l.text)/d or 0 end
local function allocDur(seg,T) local c=0 for _,s in ipairs(seg)do c=c+charCount(s) end local d,r={},T if c==0 then local s=math.floor(T/#seg) for i=1,#seg do d[i]=s end d[#seg]=T-s*(#seg-1) return d end for i,s in ipairs(seg)do if i==#seg then d[i]=r else local v=math.floor(T*charCount(s)/c) d[i],r=v,r-v end end return d end

local DELIMS_BASE="。？！?!…‥."
local DELIMS_COMMA="、，,;；"
local function makeDelimPattern(c) return "[%.。？！?!…‥"..(c and DELIMS_COMMA or "").."]+" end
local function sliceSentences(t,rx,keep)local o,pos={},1 while pos<=#t do local s,e=t:find(rx,pos) if s then local ch,stop=t:sub(s,s),e while t:sub(stop+1,stop+1)==ch do stop=stop+1 end if keep then while t:sub(stop+1,stop+1):match("%s")do stop=stop+1 end end o[#o+1]=t:sub(pos,stop) pos=stop+1 while t:sub(pos,pos):match("%s")do pos=pos+1 end else o[#o+1]=t:sub(pos) break end end for i=#o,1,-1 do local p=o[i]:gsub("{[^}]*}",""):match("^%s*(.-)%s*$") if p:match("^%p+$")then if i>1 then o[i-1]=o[i-1]..o[i] end table.remove(o,i) end end return o end
local function addSentenceTag(l,n) local tag=(n==2 and"[2S]")or(n==3 and"[3S]")or"" if tag~=""and not l.effect:match("%"..tag) then l.effect=(l.effect==""and tag or l.effect.." "..tag) end end
local function sentenceTool(subs,sel,o) local rx=makeDelimPattern(o.comma) table.sort(sel,function(a,b)return a>b end) for _,i in ipairs(sel)do local ln=subs[i] local head=ln.text:match("^({[^}]*})+")or"" local body=ln.text:gsub("^({[^}]*})+","") local parts=sliceSentences(body,rx,o.preview) if #parts<2 then goto n end if o.preview then addSentenceTag(ln,#parts) subs[i]=ln else local segs={} for _,p in ipairs(parts)do segs[#segs+1]=head..p end local dur=allocDur(segs,ln.end_time-ln.start_time) ln.text,segs[1]=segs[1],nil ln.end_time=ln.start_time+dur[1] subs[i]=ln local t=ln.end_time for j=2,#dur do local nl=cloneLine(ln) nl.text=segs[j] nl.start_time=t nl.end_time=t+dur[j] subs.insert(i+j-1,nl) t=nl.end_time end end ::n:: end end

local function splitByNtag(t) local o,last={},1 while true do local p=t:find("\\N",last,true) if not p then o[#o+1]=t:sub(last) break else o[#o+1]=t:sub(last,p-1) last=p+2 end end return o end
local function splitByN(subs,sel) table.sort(sel,function(a,b)return a>b end) for _,i in ipairs(sel)do local ln=subs[i] if not ln.text:find("\\N",1,true)then goto sk end local parts=splitByNtag(ln.text) if #parts<2 then goto sk end local head=ln.text:match("^({[^}]*})+")or"" local slice=(ln.end_time-ln.start_time)/#parts ln.text=(parts[1]:match("^%{")and parts[1] or head..parts[1]) ln.end_time=ln.start_time+slice subs[i]=ln local t=ln.end_time for p=2,#parts do local nl=cloneLine(ln) nl.text=(parts[p]:match("^%{")and parts[p] or head..parts[p]) nl.start_time=t nl.end_time=(p==#parts)and ln.start_time+slice*#parts or t+slice subs.insert(i+p-1,nl) t=nl.end_time end ::sk:: end end

local function splitRomaji(w) local t={} for s in w:gmatch("([b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z]*[aeiouAEIOU]+n?)")do if s~=""then t[#t+1]=s end end if #t==0 then t[1]=w end return t end
local function romajiKara(subs,sel) for _,i in ipairs(sel)do local ln=subs[i] local groups={} for w in ln.text:gmatch("%S+")do groups[#groups+1]=splitRomaji(w) end local tot=0 for _,g in ipairs(groups)do tot=tot+#g end if tot==0 then tot=1 end local cs=math.floor((ln.end_time-ln.start_time)/10+0.5) local base,rem=math.floor(cs/tot),cs%tot local out,idx="",1 for wi,g in ipairs(groups)do for _,sy in ipairs(g)do local d=base+(idx<=rem and 1 or 0) out=out..("{\\k"..d.."}"..sy) idx=idx+1 end if wi<#groups then out=out.." " end end ln.text=out subs[i]=ln end end

local function sortByCPS(subs,sel) local tmp={} for _,i in ipairs(sel)do tmp[#tmp+1]=subs[i] end table.sort(tmp,function(a,b)return calcCPS(a)>calcCPS(b) end) for k,l in ipairs(tmp)do subs[sel[k]]=l end end
local function showAvgCPS(subs,sel) local ch,ms=0,0 for _,i in ipairs(sel)do local ln=subs[i] ch=ch+charCount(ln.text) ms=ms+(ln.end_time-ln.start_time) end local avg=(ms>0)and ch/(ms/1000)or 0 aegisub.dialog.display({{class="label",x=0,y=0,width=1,height=1,label=string.format("Average CPS (%d lines): %.2f",#sel,avg)}},{"OK"}) end

local function tagTiming(subs,sel,o)local kfs=aegisub.keyframes()local function isKF(ms)local f=aegisub.frame_from_ms(ms)for _,k in ipairs(kfs)do if k==f then return true end end end
local function hasKF(t1,t2)local f1,f2=aegisub.frame_from_ms(t1),aegisub.frame_from_ms(t2)for _,k in ipairs(kfs)do if k>=f1 and k<f2 then return true end end end for _,i in ipairs(sel)do local ln=subs[i]local dur=ln.end_time-ln.start_time local tag={}if o.kf and isKF(ln.end_time) then tag[#tag+1]="[KF]" end if o.ov>0 and dur>o.ov then tag[#tag+1]="[Overtime]" end if o.twin>0 and isKF(ln.end_time)and hasKF(ln.end_time-o.twin,ln.end_time-1)then tag[#tag+1]="[Twin]" end if o.miss>0 and not isKF(ln.end_time)and hasKF(ln.end_time-o.miss,ln.end_time)then tag[#tag+1]="[Missing]" end if #tag>0 then ln.effect=(ln.effect==""and table.concat(tag," ")or ln.effect.." "..table.concat(tag," "))subs[i]=ln end end end


local function tagOverlaps(subs,sel) table.sort(sel,function(a,b)return subs[a].start_time<subs[b].start_time end) for p=1,#sel-1 do local a,b=subs[sel[p]],subs[sel[p+1]] if a.end_time>b.start_time then for _,ln in ipairs{a,b}do if not ln.effect:match("%[Overlap%]")then ln.effect=(ln.effect==""and"[Overlap]"or ln.effect.." [Overlap]") end end subs[sel[p]],subs[sel[p+1]]=a,b end end end

local cfgPath=aegisub.decode_path("?user/scxvid.cfg")
local cfg={scx="",ffmpeg="",suf="_keyframes.log"}
local function loadScxCfg() local f=io.open(cfgPath,"r") if not f then return end for k,v in f:read("*a"):gmatch("([%w_]+)=([^\n]+)")do cfg[k]=v end f:close() end
local function saveScxCfg() local f=io.open(cfgPath,"w") if not f then return end for k,v in pairs(cfg)do f:write(k.."="..v.."\n") end f:close() end
local function fExists(p) local f=io.open(p) if f then f:close() return true end end
local function dirName(p) return p:match("^(.*[\\/])")or"" end
local function baseName(p) return(p:gsub("^.*[\\/]","")):gsub("%.[^.]+$","") end
local function askScxSettings() local dlg={{class="label",label="Path to scxvid.exe (PATH if empty):",x=0,y=0,width=4,height=1},{class="edit",name="scx",value=cfg.scx,x=0,y=1,width=4},{class="label",label="Path to ffmpeg.exe (PATH if empty):",x=0,y=2,width=4,height=1},{class="edit",name="ffmpeg",value=cfg.ffmpeg,x=0,y=3,width=4},{class="label",label="Log suffix:",x=0,y=4,width=2,height=1},{class="edit",name="suf",value=cfg.suf,x=2,y=4,width=2},{class="checkbox",name="save",label="Save defaults",value=true,x=0,y=5,width=4}} local b,r=aegisub.dialog.display(dlg,{"Continue","Cancel"}) if b~="Continue" then return false end cfg.scx,cfg.ffmpeg,cfg.suf=r.scx,r.ffmpeg,r.suf if r.save then saveScxCfg() end return true end
local function runScxvid() loadScxCfg() local props=aegisub.project_properties() local video=props.video_file if not video or video=="" then aegisub.dialog.display({{class="label",label="No video loaded.",x=0,y=0}},{"OK"}) return end if not askScxSettings() then return end if cfg.scx~="" and not fExists(cfg.scx) then aegisub.dialog.display({{class="label",label="SCXvid not found:\n"..cfg.scx,x=0,y=0}},{"OK"}) return end if cfg.ffmpeg~="" and not fExists(cfg.ffmpeg) then aegisub.dialog.display({{class="label",label="FFmpeg not found:\n"..cfg.ffmpeg,x=0,y=0}},{"OK"}) return end local scx=(cfg.scx~=""and cfg.scx or"scxvid.exe") local ffm=(cfg.ffmpeg~=""and cfg.ffmpeg or"ffmpeg") local outLog=dirName(video)..baseName(video)..cfg.suf local bat=aegisub.decode_path("?temp/scxvid_run.bat") local f=io.open(bat,"w") f:write("@echo off\n\""..ffm.."\" -i \""..video.."\" -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | \""..scx.."\" \""..outLog.."\"\npause\n") f:close() os.execute('start "" "'..bat..'"') aegisub.dialog.display({{class="label",label="Process started.\nLog: "..outLog,x=0,y=0}},{"OK"}) end

local helpText = [[
Chronorow Master — quick guide
================================================================
Why this panel?
Tick the tools you need, adjust the millisecond fields, then
press Run. Nothing is changed until you do, so experiment
freely.

MARK & TAG
• Keyframe Seal
  Adds [KF] when a line ends on an actual video keyframe.

• Twin (ms)
  If the previous keyframe is inside this window the line also
  gets [Twin] (e.g. twin 1000 → ≤1 s earlier).

• Missing (ms)
  The inverse of Twin.  If the end is NOT a keyframe but one
  exists inside this window the line is tagged [Missing].

• Overtime (ms)
  Any line longer than this value is flagged [Overtime].

• Overlap Alert
  Adds [Overlap] when two lines clash in time.

SPLIT & EDIT
• Divine Dividing
  Cuts the line into sentences and shares time proportionally.

• Vision Only
  Writes [2S] or [3S] in the Effect field instead of splitting,
  so you can preview the cut.

• Comma Blessed
  Treat commas and semicolons as sentence endings as well.

• Line Cleaver \N
  Splits at every \N and distributes time evenly.

• Kana-Beat {\k}
  Generates simple romaji karaoke timing with {\k} tags.

CPS TOOLS
• CPS Ranker  – Sorts the selection from highest CPS to lowest.
• CPS Avg     – Shows the average CPS of the selection.

EXTERNAL
• Extract KFs – Opens FFmpeg → SCXvid to create a keyframe
  log (.log) beside the video.

PRESET
• Kite – Instantly fills Twin = 1000, Missing = 1000,
  Overtime = 5500.  It only sets the numbers; you still press
  Run when ready.

Tips
* The dialog always opens blank — press Kite for the preset.
* You can combine as many boxes as you like in one pass.
* Ctrl+Z in Aegisub undoes everything from the last Run.

Happy timing!
]]


local function gui(subs,sel)
  local preset={twin="0",miss="0",ov="0",kf=false,ovl=false,sent=false,comma=false,preview=false,splitN=false,romaji=false,cps=false,avg=false}
  while true do
    local dlg={
      {class="label",label="Keyframes",x=0,y=0,width=6,height=1},
      {class="label",label="Twin (ms)",x=0,y=1,width=2,height=1},{class="edit",name="twin",x=2,y=1,width=1,value=preset.twin},
      {class="label",label="Missing (ms)",x=3,y=1,width=2,height=1},{class="edit",name="miss",x=5,y=1,width=1,value=preset.miss},
      {class="label",label="Overtime > ms",x=0,y=2,width=2,height=1},{class="edit",name="ov",x=2,y=2,width=1,value=preset.ov},
      {class="label",label="Tagging",x=0,y=3,width=2,height=1},
      {class="checkbox",name="kf",label="Keyframe Seal",x=0,y=4,width=3,value=preset.kf},
      {class="checkbox",name="ovl",label="Overlap Alert",x=0,y=5,width=3,value=preset.ovl},
      {class="label",label="Text tools",x=3,y=3,width=2,height=1},
      {class="checkbox",name="sent",label="Divine Dividing",x=3,y=4,width=3,value=preset.sent},
      {class="checkbox",name="preview",label="Vision Only",x=4,y=5,width=2,value=preset.preview},
      {class="checkbox",name="comma",label="Comma Blessed",x=4,y=6,width=2,value=preset.comma},
      {class="checkbox",name="splitN",label="Line Cleaver \\N",x=3,y=7,width=3,value=preset.splitN},
      {class="checkbox",name="romaji",label="Kana-Beat {\\k}",x=3,y=8,width=3,value=preset.romaji},
      {class="label",label="Misc",x=0,y=7,width=2,height=1},
      {class="checkbox",name="cps",label="CPS Ranker",x=0,y=8,width=3,value=preset.cps},
      {class="checkbox",name="avg",label="CPS Avg",x=0,y=9,width=3,value=preset.avg}
    }
    local press,res=aegisub.dialog.display(dlg,{"Run","Kite","Extract KFs","Help","Cancel"})
    if press=="Help" then aegisub.dialog.display({{class="textbox",text=helpText,x=0,y=0,width=60,height=20}},{"OK"})
    elseif press=="Extract KFs" then runScxvid() return
    elseif press=="Kite" then preset=res preset.twin,preset.miss,preset.ov="1000","1000","5500"
    elseif press=="Cancel" then return
    elseif press=="Run" then
      if res.sent   then sentenceTool(subs,sel,{comma=res.comma,preview=res.preview}) end
      if res.splitN then splitByN(subs,sel) end
      if res.romaji then romajiKara(subs,sel) end
      if res.cps    then sortByCPS(subs,sel) end
      if res.kf or tonumber(res.twin)>0 or tonumber(res.miss)>0 or tonumber(res.ov)>0 then tagTiming(subs,sel,{kf=res.kf,twin=tonumber(res.twin)or 0,miss=tonumber(res.miss)or 0,ov=tonumber(res.ov)or 0}) end
      if res.ovl then tagOverlaps(subs,sel) end
      if res.avg then showAvgCPS(subs,sel) end
      return
    end
  end
end

aegisub.register_macro(script_name, script_description, gui)
