script_name = "Chronorow Master"
script_description = "Ultimate Timing & Styling Suite"
script_author = "Kiterow"
script_version = "2.0"
menu_embedding = "Kite-Macros/"

include("karaskel.lua")

local unicode = aegisub.unicode or {}
local DEBUG = false
local function log(msg) if DEBUG then aegisub.debug.out(msg.."\n") end end
local function trim(s) return s and s:gsub("^%s*(.-)%s*$","%1") or "" end
local function cloneLine(l) 
  if type(l.copy)=="function" then return l:copy() end 
  local d={class=l.class or"dialogue"} 
  for k,v in pairs(l)do 
    if type(v)=="table" then d[k]={} for ki,vi in pairs(v)do d[k][ki]=vi end 
    else d[k]=v end 
  end 
  setmetatable(d,getmetatable(l)) 
  return d 
end
local function stripTags(t) return (t:gsub("{[^}]*}",""):gsub("%[.-%]",""):gsub("\\N","")) end
local function charCount(t) 
  local stripped = stripTags(t):gsub("%s",""):gsub("%p","")
  return unicode.len and unicode.len(stripped) or #stripped
end
local function safeUpper(t) return unicode.to_upper and unicode.to_upper(t) or t:upper() end
local function isUppercase(t) local c=stripTags(t):gsub("%s+",""):gsub("%p+","") return c~="" and c==safeUpper(c) end
local function safeDelete(subs,idxs) table.sort(idxs,function(a,b) return a>b end) for _,i in ipairs(idxs)do subs.delete(i) end end
local function validateDuration(l) return l.end_time and l.start_time and l.end_time > l.start_time end
local function addTag(l, tag, force)
  if not l.effect then l.effect = "" end
  local clean_tag = tag:gsub("[%[%]]", "")
  if force or not l.effect:match("%["..clean_tag:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1").."[^%]]*%]") then
    l.effect = (l.effect == "" and tag or l.effect .. " " .. tag)
  end
end

local function getTargetedSelection(subs,sel,c) if not c or c.mode=="All Selected" then return sel end local f={} local v=c.value for _,i in ipairs(sel)do local l=subs[i] local m=false if c.mode=="By Style" and l.style==v then m=true elseif c.mode=="By Actor" and l.actor==v then m=true elseif c.mode=="By Layer" and l.layer==tonumber(v) then m=true elseif c.mode=="By Effect" and l.effect:find(v,1,true) then m=true end if m then table.insert(f,i) end end return f end

local DELIMS_BASE, DELIMS_COMMA = "。？！?!…‥.", "、，,;；"
local function sliceSentences(t, mode_comma)
  local parts = {}
  local current_part = ""
  local chars = {}
  for c in t:gmatch("[%z\1-\127\194-\244][\128-\191]*") do table.insert(chars, c) end
  
  local i = 1
  while i <= #chars do
    local c = chars[i]
    local next_c = chars[i+1] or ""
    local prev_c = chars[i-1] or ""
    local is_split = false
    
    if c:match("[%.%?!]") or c == "。" or c == "？" or c == "！" or c == "…" or c == "‥" then is_split = true end
    if mode_comma and (c:match("[,;]") or c == "、" or c == "，" or c == "；") then is_split = true end
    if c == "-" and prev_c == " " and next_c == " " then is_split = true end
    
    current_part = current_part .. c
    
    if is_split then
      while chars[i+1] and (
        chars[i+1]:match("[%.%?!]") or chars[i+1] == "。" or chars[i+1] == "？" or chars[i+1] == "！" or chars[i+1] == "…" or chars[i+1] == "‥" or
        (mode_comma and (chars[i+1]:match("[,;]") or chars[i+1] == "、" or chars[i+1] == "，" or chars[i+1] == "；"))
      ) do
        i = i + 1
        current_part = current_part .. chars[i]
      end
      table.insert(parts, current_part)
      current_part = ""
      while chars[i+1] and chars[i+1]:match("%s") do i = i + 1 end
    end
    i = i + 1
  end
  if current_part ~= "" then table.insert(parts, current_part) end
  
  local clean_parts = {}
  for _, p in ipairs(parts) do
    local txt = p:gsub("{[^}]*}", ""):gsub("%s+", "")
    if txt ~= "" then table.insert(clean_parts, p) end
  end
  return clean_parts
end
local function allocDur(seg,T) local c=0 for _,s in ipairs(seg)do c=c+charCount(s) end local d,r={},T if c==0 then local s=math.floor(T/#seg) for i=1,#seg do d[i]=s end d[#seg]=T-s*(#seg-1) return d end for i,s in ipairs(seg)do if i==#seg then d[i]=r else local v=math.floor(T*charCount(s)/c) d[i],r=v,r-v end end return d end
local function addSentenceTag(l,n) if n<2 then return end addTag(l, string.format("[%dS]",n)) end

local function sentenceTool(subs,sel,o) 
  table.sort(sel,function(a,b)return a>b end) 
  aegisub.progress.task("Divine Dividing...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    if not validateDuration(ln) then 
      log("Skipping line "..i.." - invalid duration")
      goto n 
    end
    local head=ln.text:match("^({[^}]*})+")or"" 
    local body=ln.text:gsub("^({[^}]*})+","") 
    local parts=sliceSentences(body,o.comma) 
    if #parts<2 then goto n end 
    if o.preview then 
      addSentenceTag(ln,#parts) 
      subs[i]=ln 
    else 
      local segs={} 
      for _,p in ipairs(parts)do 
        local cleanP = p:gsub("{[^}]*}",""):gsub("%s",""):gsub("%p","")
        if #cleanP > 0 then
          segs[#segs+1]=head..p 
        end
      end
      if #segs < 2 then goto n end
      local dur=allocDur(segs,ln.end_time-ln.start_time) 
      ln.text,segs[1]=segs[1],nil 
      ln.end_time=ln.start_time+dur[1] 
      subs[i]=ln 
      local t=ln.end_time 
      for j=2,#dur do 
        local nl=cloneLine(ln) 
        nl.text=segs[j] 
        nl.start_time=t 
        nl.end_time=t+dur[j] 
        subs.insert(i+j-1,nl) 
        t=nl.end_time 
      end 
    end 
    ::n:: 
  end 
end
local function splitByNtag(t) local o,last={},1 while true do local p=t:find("\\N",last,true) if not p then o[#o+1]=t:sub(last) break else o[#o+1]=t:sub(last,p-1) last=p+2 end end return o end
local function splitByN(subs,sel) 
  table.sort(sel,function(a,b)return a>b end) 
  aegisub.progress.task("Line Cleaver \\\\N...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    if not ln.text:find("\\N",1,true)then goto sk end 
    if not validateDuration(ln) then 
      log("Skipping line "..i.." - invalid duration")
      goto sk 
    end
    local parts=splitByNtag(ln.text) 
    if #parts<2 then goto sk end 
    local head=ln.text:match("^({[^}]*})+")or"" 
    local slice=(ln.end_time-ln.start_time)/#parts 
    ln.text=(parts[1]:match("^%{")and parts[1] or head..parts[1]) 
    ln.end_time=ln.start_time+slice 
    subs[i]=ln 
    local t=ln.end_time 
    for p=2,#parts do 
      local nl=cloneLine(ln) 
      nl.text=(parts[p]:match("^%{")and parts[p] or head..parts[p]) 
      nl.start_time=t 
      nl.end_time=(p==#parts)and ln.start_time+slice*#parts or t+slice 
      subs.insert(i+p-1,nl) 
      t=nl.end_time 
    end 
    ::sk:: 
  end 
end

local function splitRomaji(w) local t,pos,len={},1,#w local function peek(n) return pos+n-1<=len and w:sub(pos,pos+n-1) or nil end local function consume(n) local s=w:sub(pos,pos+n-1); pos=pos+n; return s end local function isVowel(c) return c and c:match("[aiueo]") end while pos<=len do local found=false local c1,c2,c3,c4=peek(1),peek(2),peek(3),peek(4) if c4 then local p4={"kky[auo]","ssy[auo]","tty[auo]","ppy[auo]","ggy[auo]","zzy[auo]","ddy[auo]","bby[auo]","mmy[auo]","nny[auo]","rry[auo]","hhy[auo]"} for _,p in ipairs(p4)do if c4:match("^"..p.."$")then t[#t+1]=consume(4) found=true break end end end if not found and c3 then local p3={"nn[aiueo]","mm[aiueo]","kk[aiueo]","ss[aiueo]","tt[aiueo]","pp[aiueo]","gg[aiueo]","zz[aiueo]","dd[aiueo]","bb[aiueo]","rr[aiueo]","hh[aiueo]","yy[aiueo]","kya","kyu","kyo","gya","gyu","gyo","sha","shu","sho","cha","chu","cho","nya","nyu","nyo","hya","hyu","hyo","bya","byu","byo","pya","pyu","pyo","mya","myu","myo","rya","ryu","ryo","tsu","shi","chi","tta","kka","ssa","ppa","gga","zza","dda","bba","mma","nna","rra","hha","yya"} for _,p in ipairs(p3)do if c3:match("^"..p.."$")then t[#t+1]=consume(3) found=true break end end end if not found and c2 then local p2={"ka","ki","ku","ke","ko","ga","gi","gu","ge","go","sa","si","su","se","so","za","zi","zu","ze","zo","ta","ti","tu","te","to","da","di","du","de","do","na","ni","nu","ne","no","ha","hi","hu","he","ho","ba","bi","bu","be","bo","pa","pi","pu","pe","po","ma","mi","mu","me","mo","ya","yu","yo","ra","ri","ru","re","ro","wa","wi","wu","we","wo","nn","n'","aa","ii","uu","ee","oo","ou","oa","oe","oi","ue","ua","ui","ai","au","ei","ia","ie","iu","uo"} for _,p in ipairs(p2)do if c2:match("^"..p.."$")then if p=="nn"and isVowel(peek(3))then t[#t+1]=consume(1) found=true break else t[#t+1]=consume(2) found=true break end end end end if not found and c1 then if c1:match("[aiueon]")then t[#t+1]=consume(1) found=true elseif c1=="n"then if not isVowel(peek(2))and not (peek(2)and peek(2):match("[yp]"))then t[#t+1]=consume(1) found=true end end end if not found then t[#t+1]=consume(1) end end if #t==0 then t[1]=w end return t end
local function romajiKara(subs,sel) 
  aegisub.progress.task("Kana-Beat {\\\\k}...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    local groups={} 
    for w in ln.text:gmatch("%S+")do groups[#groups+1]=splitRomaji(w) end 
    local tot=0 
    for _,g in ipairs(groups)do tot=tot+#g end 
    if tot==0 then tot=1 end 
    local cs=math.floor((ln.end_time-ln.start_time)/10+0.5) 
    local base,rem=math.floor(cs/tot),cs%tot 
    local out,idx="",1 
    for wi,g in ipairs(groups)do 
      for _,sy in ipairs(g)do 
        local d=base+(idx<=rem and 1 or 0) 
        out=out..("{\\k"..d.."}"..sy) 
        idx=idx+1 
      end 
      if wi<#groups then out=out.." " end 
    end 
    ln.text=out 
    subs[i]=ln 
  end 
end

local function calcCPS(l) local d=(l.end_time-l.start_time)/1000 return d>0 and charCount(l.text)/d or 0 end
local function sortByCPS(subs,sel) local tmp={} for _,i in ipairs(sel)do tmp[#tmp+1]=subs[i] end table.sort(tmp,function(a,b)return calcCPS(a)>calcCPS(b) end) for k,l in ipairs(tmp)do subs[sel[k]]=l end end
local function showAvgCPS(subs,sel) local ch,ms=0,0 for _,i in ipairs(sel)do local ln=subs[i] ch=ch+charCount(ln.text) ms=ms+(ln.end_time-ln.start_time) end local avg=(ms>0)and ch/(ms/1000)or 0 aegisub.dialog.display({{class="label",label=string.format("Average CPS (%d lines): %.2f",#sel,avg)}},{"OK"}) end

local function isKeyframe(ms) 
  local kfs=aegisub.keyframes() 
  if not kfs or #kfs==0 then 
    log("Warning: No keyframes loaded")
    return false 
  end 
  local f=aegisub.frame_from_ms(ms) 
  if not f then return false end
  for _,k in ipairs(kfs)do if k==f then return true end end 
  return false 
end
local function hasKFinRange(t1,t2) 
  local kfs=aegisub.keyframes() 
  if not kfs or #kfs==0 then return false end 
  local f1,f2=aegisub.frame_from_ms(t1),aegisub.frame_from_ms(t2) 
  if not f1 or not f2 then return false end
  for _,k in ipairs(kfs)do if k>=f1 and k<f2 then return true end end 
  return false 
end
local function addEffectTag(line,tag) addTag(line, tag) end

local function tagTiming(subs,sel,o) 
  aegisub.progress.task("Applying timing markers...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local ln=subs[i] 
    local dur=ln.end_time-ln.start_time 
    local mode=o.mode or "End Only" 
    
    if o.kf then
      if mode=="End Only" and isKeyframe(ln.end_time) then 
        addEffectTag(ln,"[KF-E]") 
      elseif mode=="Start Only" and isKeyframe(ln.start_time) then 
        addEffectTag(ln,"[KF-S]") 
      elseif mode=="Both" then
        if isKeyframe(ln.end_time) then addEffectTag(ln,"[KF-E]") end
        if isKeyframe(ln.start_time) then addEffectTag(ln,"[KF-S]") end
      end
    end
    
    if o.ov>0 and dur>o.ov then addEffectTag(ln,"[Overtime]") end 
    
    if mode=="End Only" or mode=="Both" then 
      if o.twin>0 and isKeyframe(ln.end_time) then 
        local search_start = math.max(ln.start_time, ln.end_time - o.twin)
        if hasKFinRange(search_start, ln.end_time - 1) then 
          addEffectTag(ln,"[Twin-E]") 
        end 
      end 
      if o.miss>0 and not isKeyframe(ln.end_time) then 
        local search_start = math.max(ln.start_time, ln.end_time - o.miss)
        if hasKFinRange(search_start, ln.end_time - 1) then 
          addEffectTag(ln,"[Miss-E]") 
        end 
      end 
    end 
    
    if mode=="Start Only" or mode=="Both" then 
      if o.twin>0 and isKeyframe(ln.start_time) then 
        local search_start = math.max(0, ln.start_time - o.twin)
        if hasKFinRange(search_start, ln.start_time - 1) then 
          addEffectTag(ln,"[Twin-S]") 
        end 
      end 
      if o.miss>0 and not isKeyframe(ln.start_time) then 
        local search_start = math.max(0, ln.start_time - o.miss)
        if hasKFinRange(search_start, ln.start_time - 1) then 
          addEffectTag(ln,"[Miss-S]") 
        end 
      end 
    end 
    
    subs[i]=ln 
  end 
end

local function tagOverlaps(subs,sel) 
  aegisub.progress.task("Detecting overlaps...")
  table.sort(sel,function(a,b)return subs[a].start_time<subs[b].start_time end) 
  for p=1,#sel-1 do 
    aegisub.progress.set(p/(#sel-1)*100)
    local a,b=subs[sel[p]],subs[sel[p+1]] 
    if a.end_time>b.start_time then 
      for _,ln in ipairs{a,b}do addEffectTag(ln,"[Overlap]") end 
    end 
    subs[sel[p]],subs[sel[p+1]]=a,b 
  end 
end

local function markSmallGaps(subs,sel,opt) 
  local maxGap=math.min(opt.maxGap or 300, 5000)
  aegisub.progress.task("Marking gaps...")
  local lines={} 
  for i,idx in ipairs(sel)do 
    lines[i]={index=idx,line=subs[idx],start_time=subs[idx].start_time,end_time=subs[idx].end_time} 
  end 
  table.sort(lines,function(a,b)return a.start_time<b.start_time end) 
  local cnt=0 
  for i=1,#lines-1 do 
    aegisub.progress.set(i/(#lines-1)*100)
    local c,n=lines[i],lines[i+1] 
    local gap=n.start_time-c.end_time 
    local mark=false 
    if opt.markContinuous and gap==0 then mark=true 
    elseif gap>0 and gap<maxGap then mark=true end 
    if mark then 
      if opt.ignoreKeyframes and isKeyframe(c.end_time) then mark=false end 
      if mark then 
        local t="["..opt.gapTag..(gap==0 and " 0ms]" or " "..gap.."ms]") 
        addEffectTag(c.line,t) 
        addEffectTag(n.line,t) 
        subs[c.index]=c.line 
        subs[n.index]=n.line 
        cnt=cnt+2 
      end 
    end 
  end 
  return cnt 
end
local function gapMarker(subs,sel) local cfg={maxGap="300",ignoreKeyframes=false,markContinuous=false,gapTag="SmallGap"} while true do local dlg={{class="label",label="Gap Marker - Detect subtitle blinks",x=0,y=0,width=4,height=1},{class="label",label="Max gap (ms):",x=0,y=1,width=2,height=1},{class="edit",name="maxGap",value=cfg.maxGap,x=2,y=1,width=2},{class="label",label="Custom tag:",x=0,y=2,width=2,height=1},{class="edit",name="gapTag",value=cfg.gapTag,x=2,y=2,width=2},{class="checkbox",name="markContinuous",label="Also mark continuous lines (gap = 0ms)",value=cfg.markContinuous,x=0,y=3,width=4},{class="checkbox",name="ignoreKeyframes",label="Ignore when previous line ends on keyframe",value=cfg.ignoreKeyframes,x=0,y=4,width=4},{class="label",label="Selected: "..#sel.." lines",x=0,y=5,width=4,height=1}} local btn,res=aegisub.dialog.display(dlg,{"Mark Gaps","Help","Cancel"}) if btn=="Help" then local helpText=[[
Gap Marker - Usage Guide
========================
This script tags lines with VERY SMALL gaps (time spaces) between dialogues, useful for detecting subtitle "BLINKS".
CONFIGURATION:
• Max gap: Tags lines with gaps SMALLER than this value (in ms)
IMPORTANT: By default does NOT include continuous lines (gap = 0)
• Custom tag: Name of the tag to add to the Effect field
• Additional option to include adjacent lines (gap = 0ms)
• Ignore keyframes: Do not tag when previous line ends exactly on a keyframe

FUNCTIONALITY:
The script specifically looks for "BLINKS":
By default: 0 < gap < max value (excludes continuous lines)
With option enabled: also includes gap = 0

EXAMPLE:
Max gap: 100ms
→ Tags lines with gaps of 1-99ms (annoying blinks)
→ Does NOT tag continuous lines (gap = 0ms) unless you enable the option

TYPICAL USE:
• Detect subtitle blinks (very short gaps)
• Find timings that cause annoying "flashes"
• Gaps of 1-100ms typically appear as blinks

RESULT:
Tagged lines will have in Effect: [SmallGap XXXms] where XXX is the exact gap time detected.

TIPS:
• Typical blinks: 1-250ms (very annoying)
• Normal gaps: 250ms+ (comfortable to read)
• Use small values (50-250ms) to detect blinks
]] aegisub.dialog.display({{class="textbox",text=helpText,x=0,y=0,width=55,height=25}},{"OK"}) elseif btn=="Cancel" then return elseif btn=="Mark Gaps" then local mg=tonumber(res.maxGap) if not mg or mg<0 then aegisub.dialog.display({{class="label",label="Invalid gap value"}},{"OK"}) goto c end if res.gapTag=="" then aegisub.dialog.display({{class="label",label="Must specify a tag"}},{"OK"}) goto c end if #sel<2 then aegisub.dialog.display({{class="label",label="Need 2+ lines"}},{"OK"}) return end local opt={maxGap=mg,ignoreKeyframes=res.ignoreKeyframes,markContinuous=res.markContinuous,gapTag=res.gapTag} local c=markSmallGaps(subs,sel,opt) aegisub.dialog.display({{class="label",label="Tagged "..c.." lines."}},{"OK"}) return end ::c:: cfg=res end end

local function markUppercase(subs,sel) for _,i in ipairs(sel)do local l=subs[i] if isUppercase(l.text) then addEffectTag(l,"[Uppercase]") subs[i]=l end end end
local function markMissingPunctuation(subs,sel) for _,i in ipairs(sel)do local l=subs[i] local c=stripTags(l.text):gsub("%s+$","") if c~="" and not c:match("[%.,!?！？]%s*$") then addEffectTag(l,"[Missing Final Punctuation]") subs[i]=l end end end

local function parseTime(t) t=t:gsub("^%s+",""):gsub("%s+$","") local h,m,s=t:match("(%d+):(%d+):(%d+%.%d+)") return h and (tonumber(h)*3600+tonumber(m)*60+tonumber(s))*1000 end
local function timeInt(s1,e1,s2,e2) local s,e=math.max(s1,s2),math.min(e1,e2) return s<e and e-s or 0 end
local function parseDialogue(l) 
  l=trim(l) 
  if not l:match("^Dialogue:") then return nil end 
  local c,p={},1 
  while p do 
    p=l:find(",",p) 
    if p then table.insert(c,p) p=p+1 end 
  end 
  if #c<9 then 
    log("Error: Invalid dialogue format, less than 9 fields")
    return nil 
  end 
  local sp,f=l:find(":",1,true)+1,{} 
  for i=1,8 do 
    table.insert(f,trim(l:sub(sp,c[i]-1))) 
    sp=c[i]+1 
  end 
  table.insert(f,trim(l:sub(sp,c[9]-1))) 
  table.insert(f,trim(l:sub(c[9]+1))) 
  return f 
end

local function antEffects(subs,sel,raw) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,ef=parseTime(f[2]),parseTime(f[3]),f[9] if s and e and ef~="" then table.insert(src,{start=s,end_time=e,effect=ef}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local add={} for _,s in ipairs(src)do if timeInt(l.start_time,l.end_time,s.start,s.end_time)>0 then table.insert(add,s.effect) end end if #add>0 then if l.effect~="" then table.insert(add,1,l.effect) end l.effect=table.concat(add,"; ") mod=mod+1 end subs[i]=l end return mod end
local function antLines(subs,sel,raw,comm) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,tx=parseTime(f[2]),parseTime(f[3]),f[10] if s and e and tx~="" then table.insert(src,{start=s,end_time=e,text=tx}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local add="" for _,s in ipairs(src)do if timeInt(l.start_time,l.end_time,s.start,s.end_time)>0 then local t=comm and "{"..s.text.."}" or s.text add=(add=="" and t or add.." "..t) end end if add~="" then l.text=l.text.." "..add mod=mod+1 end subs[i]=l end return mod end
local function antActor(subs,sel,raw) local src={} for l in raw:gmatch("[^\r\n]+")do local f=parseDialogue(l) if f then local s,e,ac=parseTime(f[2]),parseTime(f[3]),f[5] if s and e and ac~="" then table.insert(src,{start=s,end_time=e,actor=ac}) end end end if #src==0 then return 0 end local mod=0 for _,i in ipairs(sel)do local l=subs[i] local ba,bd=nil,0 for _,s in ipairs(src)do local d=timeInt(l.start_time,l.end_time,s.start,s.end_time) if d>bd then bd,ba=d,s.actor end end if ba then l.actor=ba mod=mod+1 end subs[i]=l end return mod end

local lazyConfig={weights={proximity=0.30,silence_q=0.22,source_c=0.13,clarity=0.08,vad=0.30,flux=0.30},cluster_max_dist=120,min_cluster_mass=0.6,min_score_threshold=0.25,min_duration=200,max_duration=8000,epsilon=50,thresholds={[30]={min_silence_dur=350,reliability=1.0},[40]={min_silence_dur=120,reliability=0.9},[50]={min_silence_dur=120,reliability=0.6}}}
local tableConfig={merge_gap_ms=120,min_noise_ms=80,edge_drop_ms=60,w_cov=0.65,w_prox=0.25,w_frag=0.10,sigma_ms=200,eps=1}
local g_aux_vad, g_aux_flux = nil, nil
local function normalizeProximity(d,w) if w<=0 then return 0 end return math.exp(-(d*d)/(w*w)) end
local function normalizeSilenceQuality(d) if d<100 then return 0.1 elseif d<500 then return 0.3+0.4*(d-100)/400 elseif d<1500 then return 0.7+0.2*(d-500)/1000 else return 0.9+0.1*(1-math.exp(-(d-1500)/1000)) end end
local function getSourceConfidence(t) return (lazyConfig.thresholds[t] and lazyConfig.thresholds[t].reliability) or 0.5 end
local function normalizeContextClarity(d) return 1/(1+d*d) end
local function calculateScore(c,rt,sw,sd) local d=math.abs(c.time-rt) local fp=normalizeProximity(d,sw) local fq=normalizeSilenceQuality(c.duration or 0) local fc=getSourceConfidence(c.threshold) local fl=normalizeContextClarity(sd) local fflux, fvad = (c.flux_boost or 0), (c.vad_align or 0) return (fp*lazyConfig.weights.proximity)+(fq*lazyConfig.weights.silence_q)+(fc*lazyConfig.weights.source_c)+(fl*lazyConfig.weights.clarity)+(fflux*lazyConfig.weights.flux)+(fvad*lazyConfig.weights.vad) end
local function findClusters(cs,md) if not cs or #cs==0 then return{} end if #cs<2 then return{cs} end table.sort(cs,function(a,b)return a.time<b.time end) local cls,ccl={},{cs[1]} for i=2,#cs do if cs[i].time-ccl[#ccl].time<=md then table.insert(ccl,cs[i]) else table.insert(cls,ccl) ccl={cs[i]} end end table.insert(cls,ccl) return cls end
local function weighted_median_time(cl) table.sort(cl,function(a,b)return a.time<b.time end) local sum=0 for _,p in ipairs(cl)do sum=sum+(p.score or 0) end if sum<=0 then local mid=math.floor((#cl+1)/2) return cl[mid].time end local acc=0 for _,p in ipairs(cl)do acc=acc+(p.score or 0) if acc>=sum*0.5 then return p.time end end return cl[#cl].time end
local function getCentroid(cl) local tw,ws=0,0 for _,p in ipairs(cl)do local s=(p.score or 0) tw=tw+s*s ws=ws+(p.time*s*s) end if tw==0 then return cl[1].time end return ws/tw end
local function addLazyTag(l,t) addTag(l, "[LZ "..t.."]" , true) end
local function getLazyPath(t) return aegisub.dialog.open(t,"","","*.txt;*.log",false,true) end
local function validateIntra(ns,ne,os,oe) if ns<os or ne>oe then return false,"out_of_range" end if ne-ns<lazyConfig.min_duration then return false,"min_dur" end return true end
local function clampIntra(ns,ne,os,oe) local ns2,ne2=math.max(ns,os),math.min(ne,oe) if ne2-ns2<lazyConfig.min_duration then return false,"min_dur",ns,ne end return true,nil,ns2,ne2 end
local function getDensity(t,s,ws) ws=ws or 5000 local c,sw,ew=0,t-ws/2,t+ws/2 for _,seg in ipairs(s)do local ov=not(seg["end"]<=sw or seg.start>=ew) if ov then c=c+1 end end return c/(ws/1000) end
local function parseLazyFile(fp,t) 
  local segs={} 
  local fh=io.open(fp,"r") 
  if not fh then 
    log("Error: Cannot open lazy file: "..fp)
    return segs 
  end 
  local cs=nil 
  local line_count = 0
  for l in fh:lines()do 
    line_count = line_count + 1
    local ss=l:match("silence_start:%s*([%d%.]+)") 
    if ss then cs=tonumber(ss)*1000 end 
    local se,sd=l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)") 
    if se and cs then 
      local dms=tonumber(sd)*1000 
      if dms>=((lazyConfig.thresholds[t] and lazyConfig.thresholds[t].min_silence_dur)or 100) then 
        table.insert(segs,{start=cs,["end"]=tonumber(se)*1000,duration=dms,threshold=t}) 
      end 
      cs=nil 
    end 
  end 
  fh:close() 
  log("Loaded "..#segs.." silence segments from "..fp.." ("..line_count.." lines)")
  return segs 
end
local function parseVADtsv(path) local segs={} local f=io.open(path,"r") if not f then return segs end local first=true for line in f:lines()do if first then first=false else local a,b=line:match("([%d%.]+)%s+([%d%.]+)") if a and b then table.insert(segs,{start=tonumber(a),["end"]=tonumber(b)}) end end end f:close() return segs end
local function parseFLUXtsv(path) local cands={} local f=io.open(path,"r") if not f then return cands end local first=true for line in f:lines()do if first then first=false else local t,ty,sc=line:match("([%d%.]+)%s+(%a+)%s+([%d%.]+)") if t and ty and sc then table.insert(cands,{time=tonumber(t),type=ty,score=tonumber(sc)}) end end end f:close() return cands end
local function enrich_with_aux(cands,flux,vad,want_type) local function nearest_flux(t) local best_d,best_s=math.huge,0 for _,c in ipairs(flux or{})do if c.type==want_type then local d=math.abs(c.time-t) if d<best_d then best_d,best_s=d,c.score end end end if best_d<=40 then return(1-best_d/40)*best_s else return 0 end end local function vad_margin(t) local best=math.huge for _,s in ipairs(vad or{})do local d1=math.abs(s.start-t) local d2=math.abs(s["end"]-t) local d=(d1<d2)and d1 or d2 if d<best then best=d end end if best==math.huge then return 0 end return math.exp(-(best*best)/1600) end for _,c in ipairs(cands)do c.flux_boost=nearest_flux(c.time) c.vad_align=vad_margin(c.time) end end
local function loadLazyData(fps) local rs={} for t,p in pairs(fps)do for _,s in ipairs(parseLazyFile(p,t))do table.insert(rs,s) end end table.sort(rs,function(a,b)return a.start<b.start end) local ss,se={},{} for _,s in ipairs(rs)do table.insert(ss,{time=s["end"],duration=s.duration,threshold=s.threshold}) table.insert(se,{time=s.start,duration=s.duration,threshold=s.threshold}) end return ss,se,rs end
local function copyCandidate(ev) return{time=ev.time,duration=ev.duration,threshold=ev.threshold} end
local function round_ms(x) return math.floor(x+0.5) end
local function ordered_by_start(subs,sel) local arr={} for _,i in ipairs(sel)do table.insert(arr,{i=i,st=subs[i].start_time}) end table.sort(arr,function(a,b)return a.st<b.st end) local out={} for _,e in ipairs(arr)do table.insert(out,e.i) end return out end
local function stripLZ(effect) effect=effect or"" return(effect:gsub("%s*%[LZ[^%]]*%]","")) end
local function tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) if not enable_tagging or tag_mode=="None" then return end local chs=(apply_start and ns~=os) local che=(apply_end and ne~=oe) local scope_s=(tag_scope=="Both" or tag_scope=="Start only") local scope_e=(tag_scope=="Both" or tag_scope=="End only") if tag_mode=="Only 0ms" then if scope_s and apply_start and not chs then addLazyTag(l,"~0ms-s") end if scope_e and apply_end and not che then addLazyTag(l,"~0ms-e") end elseif tag_mode=="Only changes" then if scope_s and chs then addLazyTag(l,string.format("Δs=%+dms",ns-os)) end if scope_e and che then addLazyTag(l,string.format("Δe=%+dms",ne-oe)) end elseif tag_mode=="Both" then if scope_s and apply_start then addLazyTag(l,chs and string.format("Δs=%+dms",ns-os) or "~0ms-s") end if scope_e and apply_end then addLazyTag(l,che and string.format("Δe=%+dms",ne-oe) or "~0ms-e") end end end
local function rank_fusion_pick(cands,rt,is_start) local M=#cands if M==0 then return nil end if M==1 then return cands[1] end local function rank_by(fn,desc) local t={} for i,c in ipairs(cands)do t[i]={i=i,v=fn(c)} end table.sort(t,function(a,b)if desc then return a.v>b.v else return a.v<b.v end end) local r={} for k,rec in ipairs(t)do r[rec.i]=k end return r end local r_flux=rank_by(function(c)return c.flux_boost or 0 end,true) local r_vad=rank_by(function(c)return c.vad_align or 0 end,true) local r_prox=rank_by(function(c)return math.abs(c.time-rt)end,false) local r_dur=rank_by(function(c)return c.duration or 0 end,true) local r_src=rank_by(function(c)return getSourceConfidence(c.threshold)end,true) local best_i,best_sum=1,1e9 for i=1,M do local s=(r_flux[i]/M)+(r_vad[i]/M)+(r_prox[i]/M)+(r_dur[i]/M)+(r_src[i]/M) if s<best_sum then best_sum=s best_i=i end end return cands[best_i] end
local function pick_time_for_start(sc,os,lim,den) local scls=findClusters(sc,lazyConfig.cluster_max_dist) local bc,bcm=nil,0 for _,cl in ipairs(scls)do local cm=0 for _,p in ipairs(cl)do cm=cm+(p.score or 0) end if cm>bcm then bcm=cm bc=cl end end if bc then local k=math.min(3,#bc) local bcm_norm=bcm/k if bcm_norm>lazyConfig.min_cluster_mass then return weighted_median_time(bc),true end end table.sort(sc,function(a,b)return(a.score or 0)>(b.score or 0)end) if sc[1] and (sc[1].score or 0)>lazyConfig.min_score_threshold then return sc[1].time,true end local alt=rank_fusion_pick(sc,os,true) if alt then return alt.time,true end return os,false end
local function pick_time_for_end(ec,oe,lim,den) local ecls=findClusters(ec,lazyConfig.cluster_max_dist) local bc,bcm=nil,0 for _,cl in ipairs(ecls)do local cm=0 for _,p in ipairs(cl)do cm=cm+(p.score or 0) end if cm>bcm then bcm=cm bc=cl end end if bc then local k=math.min(3,#bc) local bcm_norm=bcm/k if bcm_norm>lazyConfig.min_cluster_mass then return weighted_median_time(bc),true end end table.sort(ec,function(a,b)return(a.score or 0)>(b.score or 0)end) if ec[1] and (ec[1].score or 0)>lazyConfig.min_score_threshold then return ec[1].time,true end local alt=rank_fusion_pick(ec,oe,false) if alt then return alt.time,true end return oe,false end
local function runClusterAnalysis(subs,sel,lim,files,opts) local ss,se,asg=loadLazyData(files) if #ss==0 then return 0 end local modified=0 local apply_start=opts.apply_start local apply_end=opts.apply_end local enable_tagging=opts.enable_tagging local tag_mode=opts.tag_mode local tag_scope=opts.tag_scope aegisub.progress.task("Analyzing (Cluster, intra ±"..tostring(lim).." ms)...") local seq=ordered_by_start(subs,sel) for idx,ii in ipairs(seq)do aegisub.progress.set(idx/#seq*100) local l=subs[ii] if l.class=="dialogue" then local os,oe=l.start_time,l.end_time local ns,ne=os,oe local den=getDensity((os+oe)/2,asg) if apply_start then local sc={} for _,ev in ipairs(ss)do if ev.time>=os and ev.time<=math.min(os+lim,oe-lazyConfig.min_duration) then local c=copyCandidate(ev) table.insert(sc,c) end end if g_aux_flux or g_aux_vad then enrich_with_aux(sc,g_aux_flux,g_aux_vad,"onset") end for _,cv in ipairs(sc)do cv.score=calculateScore(cv,os,lim,den) end if #sc>0 then local pt,ok=pick_time_for_start(sc,os,lim,den) if ok then ns=round_ms(pt) end end end if apply_end then local ec={} for _,ev in ipairs(se)do if ev.time<=oe and ev.time>=math.max(oe-lim,os+lazyConfig.min_duration) then local c=copyCandidate(ev) table.insert(ec,c) end end if g_aux_flux or g_aux_vad then enrich_with_aux(ec,g_aux_flux,g_aux_vad,"offset") end for _,cv in ipairs(ec)do cv.score=calculateScore(cv,oe,lim,den) end if #ec>0 then local pt,ok=pick_time_for_end(ec,oe,lim,den) if ok then ne=round_ms(pt) end end end if apply_start or apply_end then local changed=(ns~=os) or (ne~=oe) if changed then local ok,why=validateIntra(ns,ne,os,oe) if not ok then local ok2,why2,ns2,ne2=clampIntra(ns,ne,os,oe) if ok2 then l.start_time=ns2 l.end_time=ne2 modified=modified+1 tag_decider(l,os,oe,ns2,ne2,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) else if enable_tagging then addLazyTag(l,"Reject:"..(why2 or why)) end end else l.start_time=ns l.end_time=ne modified=modified+1 tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) end else tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tagging,tag_mode,tag_scope) end subs[ii]=l end end end return modified end
local function clamp(x,a,b) if x<a then return a elseif x>b then return b else return x end end
local function merge_intervals(ints,eps) table.sort(ints,function(a,b)return a.start<b.start end) local out={} for _,it in ipairs(ints)do if #out==0 then out[1]={start=it.start,["end"]=it["end"]} else local L=out[#out] if it.start<=L["end"]+(eps or 0) then if it["end"]>L["end"] then L["end"]=it["end"] end else out[#out+1]={start=it.start,["end"]=it["end"]} end end end return out end
local function intersect(a1,a2,b1,b2) local s=math.max(a1,b1) local e=math.min(a2,b2) if s<e then return s,e end end
local function noise_in_window(merged_silence,W1,W2,eps) local cut={} for _,si in ipairs(merged_silence)do local s,e=intersect(W1,W2,si.start,si["end"]) if s and e then cut[#cut+1]={start=s,["end"]=e} end end cut=merge_intervals(cut,eps) local noise={} local cur=W1 for _,si in ipairs(cut)do if si.start>cur+(eps or 0) then noise[#noise+1]={start=cur,["end"]=si.start} end cur=math.max(cur,si["end"]) end if cur<W2-(eps or 0) then noise[#noise+1]={start=cur,["end"]=W2} end return noise end
local function total_ms(ints) local s=0 for _,x in ipairs(ints)do s=s+(x["end"]-x.start) end return s end
local function merge_noise_small_gaps(noise,gap_ms) if #noise<=1 then return noise end local out={{start=noise[1].start,["end"]=noise[1]["end"]}} for i=2,#noise do local L=out[#out] local g=noise[i].start-L["end"] if g<=gap_ms then if noise[i]["end"]>L["end"] then L["end"]=noise[i]["end"] end else out[#out+1]={start=noise[i].start,["end"]=noise[i]["end"]} end end return out end
local function drop_edge_inconclusives(noise,W1,W2,edge_ms) if #noise==0 then return noise end local has_inner=false for _,n in ipairs(noise)do if n.start>W1 and n["end"]<W2 then has_inner=true break end end if not has_inner then return noise end local out={} for k,n in ipairs(noise)do local len=n["end"]-n.start local edge_left=(n.start<=W1+tableConfig.eps) local edge_right=(n["end"]>=W2-tableConfig.eps) if (edge_left or edge_right) and len<=edge_ms then else out[#out+1]=n end end return (#out>0) and out or noise end
local function center(t1,t2) return(t1+t2)/2 end
local function group_noise(noise,merge_gap_ms) if #noise==0 then return{} end local groups={} local cur={noise[1]} for i=2,#noise do local g=noise[i].start-noise[i-1]["end"] if g<=merge_gap_ms then cur[#cur+1]=noise[i] else groups[#groups+1]=cur cur={noise[i]} end end groups[#groups+1]=cur return groups end
local function cluster_span(G) return G[1].start,G[#G]["end"] end
local function cluster_score(G,W1,W2) local gs=total_ms(G) local s,e=cluster_span(G) local width=math.max(1,e-s) local cov=gs/width local prox=math.exp(-((center(s,e)-center(W1,W2))^2)/(tableConfig.sigma_ms^2)) local frag=(#G-1)/#G return tableConfig.w_cov*cov+tableConfig.w_prox*prox-tableConfig.w_frag*frag end
local function parseLazyFileTable(fp,t) local segs,duration_ms={},nil local fh=io.open(fp,"r") if not fh then return segs,duration_ms end local cur_start=nil for l in fh:lines()do local H,M,S=l:match("Duration:%s*(%d+):(%d+):([%d%.]+)") if H then duration_ms=(tonumber(H)*3600+tonumber(M)*60+tonumber(S))*1000 end local ss=l:match("silence_start:%s*([%d%.]+)") if ss then cur_start=tonumber(ss)*1000 end local se,sd=l:match("silence_end:%s*([%d%.]+)%s*|%s*silence_duration:%s*([%d%.]+)") if se and cur_start then local dms=tonumber(sd)*1000 if dms>=((lazyConfig.thresholds[t] and lazyConfig.thresholds[t].min_silence_dur)or 100) then table.insert(segs,{start=cur_start,["end"]=tonumber(se)*1000,duration=dms,threshold=t}) end cur_start=nil end end fh:close() return segs,duration_ms end
local function loadLazyDataTable(fps) local rs,maxdur={},0 for t,p in pairs(fps)do local lst,dur=parseLazyFileTable(p,t) if dur and dur>maxdur then maxdur=dur end for _,s in ipairs(lst)do table.insert(rs,s) end end table.sort(rs,function(a,b)return a.start<b.start end) local ss,se={},{} for _,s in ipairs(rs)do table.insert(ss,{time=s["end"],duration=s.duration,threshold=s.threshold}) table.insert(se,{time=s.start,duration=s.duration,threshold=s.threshold}) end return ss,se,rs,maxdur end
local function buildNoiseTable(merged_silences,W1,W2,save_path) local noise=noise_in_window(merged_silences,W1,W2,tableConfig.eps) noise=merge_noise_small_gaps(noise,tableConfig.merge_gap_ms) if save_path then local f=io.open(save_path,"w") if f then f:write("start_ms,end_ms,duration_ms\n") for _,n in ipairs(noise)do f:write(string.format("%d,%d,%d\n",n.start,n["end"],n["end"]-n.start)) end f:close() end end return noise end
local function runTableAnalysis(subs,sel,lim,files,opts) local _,_,rs,maxdur=loadLazyDataTable(files) if not rs or #rs==0 then return 0 end local raw_sil={} for _,s in ipairs(rs)do raw_sil[#raw_sil+1]={start=s.start,["end"]=s["end"]} end local merged_sil=merge_intervals(raw_sil,tableConfig.eps) local base_folder=files[40] or files[30] or files[50] if base_folder and maxdur and maxdur>0 then local path_folder=base_folder:gsub("[^\\/]+$","") local out_csv=path_folder.."noise_table_global.csv" buildNoiseTable(merged_sil,0,maxdur,out_csv) end local apply_start=opts.apply_start local apply_end=opts.apply_end local enable_tag=opts.enable_tagging local tag_mode=opts.tag_mode local tag_scope=opts.tag_scope local modified=0 local seq=ordered_by_start(subs,sel) aegisub.progress.task("Analyzing (Table, intra ±"..tostring(lim).." ms)...") for idx,ii in ipairs(seq)do aegisub.progress.set(idx/#seq*100) local l=subs[ii] if l.class=="dialogue" then local os,oe=l.start_time,l.end_time local min_d=lazyConfig.min_duration local Slo,Shi=os,math.min(oe-min_d,os+lim) local Elo,Ehi=math.max(os+min_d,oe-lim),oe if Shi<Slo then Shi=Slo end if Ehi<Elo then Elo=Ehi end local noise=noise_in_window(merged_sil,os,oe,tableConfig.eps) noise=merge_noise_small_gaps(noise,tableConfig.merge_gap_ms) noise=drop_edge_inconclusives(noise,os,oe,tableConfig.edge_drop_ms) if #noise>1 then local pruned={} for _,n in ipairs(noise)do if(n["end"]-n.start)>=tableConfig.min_noise_ms then pruned[#pruned+1]=n end end if #pruned>0 then noise=pruned end end local ns,ne=os,oe local changed=false if #noise==0 then elseif #noise==1 then local n=noise[1] if apply_start then ns=clamp(n.start,Slo,Shi) end if apply_end then ne=clamp(n["end"],Elo,Ehi) end if ne-ns<min_d then local c=center(n.start,n["end"]) ns=clamp(math.floor(c-min_d/2+0.5),Slo,Shi) ne=clamp(ns+min_d,Elo,Ehi) end changed=(ns~=os) or (ne~=oe) else local groups=group_noise(noise,tableConfig.merge_gap_ms) local bestG,bestScore=groups[1],-1e9 for _,G in ipairs(groups)do local sc=cluster_score(G,os,oe) if sc>bestScore then bestScore,bestG=sc,G end end local cs,ce=cluster_span(bestG) if bestG[1].start<=os+tableConfig.eps and(bestG[1]["end"]-bestG[1].start)<=tableConfig.edge_drop_ms and #bestG>1 then cs=bestG[2].start end if bestG[#bestG]["end"]>=oe-tableConfig.eps and(bestG[#bestG]["end"]-bestG[#bestG].start)<=tableConfig.edge_drop_ms and #bestG>1 then ce=bestG[#bestG-1]["end"] end if apply_start then ns=clamp(cs,Slo,Shi) end if apply_end then ne=clamp(ce,Elo,Ehi) end if ne-ns<min_d then local big=bestG[1] local blen=big["end"]-big.start for _,n in ipairs(bestG)do local len=n["end"]-n.start if len>blen then big,blen=n,len end end ns=clamp(big.start,Slo,Shi) ne=clamp(big["end"],Elo,Ehi) if ne-ns<min_d then local c=center(ns,ne) ns=clamp(math.floor(c-min_d/2+0.5),Slo,Shi) ne=clamp(ns+min_d,Elo,Ehi) end end changed=(ns~=os) or (ne~=oe) end if apply_start or apply_end then if changed then local ok,why=validateIntra(ns,ne,os,oe) if not ok then local ok2,why2,ns2,ne2=clampIntra(ns,ne,os,oe) if ok2 then l.start_time,l.end_time=ns2,ne2 modified=modified+1 tag_decider(l,os,oe,ns2,ne2,apply_start,apply_end,enable_tag,tag_mode,tag_scope) else if enable_tag then addLazyTag(l,"Reject:"..(why2 or why)) end end else l.start_time,l.end_time=ns,ne modified=modified+1 tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tag,tag_mode,tag_scope) end subs[ii]=l else tag_decider(l,os,oe,ns,ne,apply_start,apply_end,enable_tag,tag_mode,tag_scope) subs[ii]=l end end end end return modified end

local function lazyTimer(subs,sel) if not sel or #sel==0 then return end local cfg_dlg={{class="label",label="Method:",x=0,y=0,width=1,height=1},{class="dropdown",name="method",items={"Cluster (±ms)","Table (±ms)"},value="Cluster (±ms)",x=1,y=0,width=1,height=1},{class="label",label="Trim Limit (±ms):",x=0,y=1,width=1,height=1},{class="edit",name="lim",value="800",x=1,y=1,width=1,height=1},{class="checkbox",name="apply_start",label="Apply Start",value=true,x=0,y=2,width=1,height=1},{class="checkbox",name="apply_end",label="Apply End",value=true,x=1,y=2,width=1,height=1},{class="checkbox",name="enable_tagging",label="Enable Tagging",value=true,x=0,y=3,width=1,height=1},{class="dropdown",name="tag_mode",items={"Both","Only changes","Only 0ms","None"},value="Both",x=1,y=3,width=1,height=1},{class="dropdown",name="tag_scope",items={"Both","Start only","End only"},value="Both",x=0,y=4,width=2,height=1}} local pressed,res=aegisub.dialog.display(cfg_dlg,{"Run","Cancel"}) if not pressed or pressed=="Cancel" then return end local files={} if res.method=="Table (±ms)" then local ftable=getLazyPath("Silence file (any threshold)") if not ftable then return end files={[40]=ftable} else local f30=getLazyPath("Silence file (-30 dB)") if not f30 then return end local f40=getLazyPath("Silence file (-40 dB)") if not f40 then return end local f50=getLazyPath("Silence file (-50 dB)") if not f50 then return end files={[30]=f30,[40]=f40,[50]=f50} end local f_vad=aegisub.dialog.open("VAD segments (.tsv) [optional - CANCEL to skip]","","","*.tsv",false,true) local f_flux=aegisub.dialog.open("Flux candidates (.tsv) [optional - CANCEL to skip]","","","*.tsv",false,true) g_aux_vad=f_vad and parseVADtsv(f_vad) or nil g_aux_flux=f_flux and parseFLUXtsv(f_flux) or nil local ot={} for _,i in ipairs(sel)do if subs[i].class=="dialogue" then ot[i]={st=subs[i].start_time,et=subs[i].end_time} subs[i].effect=stripLZ(subs[i].effect) end end local opts={apply_start=res.apply_start,apply_end=res.apply_end,enable_tagging=res.enable_tagging,tag_mode=res.tag_mode,tag_scope=res.tag_scope} if res.method=="Cluster (±ms)" then local lim=tonumber(res.lim) or 500 local modified=runClusterAnalysis(subs,sel,lim,files,opts) aegisub.debug.out(string.format("\n=== CLUSTER (INTRA) ===\nLines processed: %d\nLines modified: %d\nVAD: %s\nFLUX: %s\n",#sel,modified,g_aux_vad and"YES"or"NO",g_aux_flux and"YES"or"NO")) else local lim=tonumber(res.lim) or 500 local modified=runTableAnalysis(subs,sel,lim,files,opts) aegisub.debug.out(string.format("\n=== TABLE (INTRA) ===\nLines processed: %d\nLines modified: %d\n(noise-table logic)\n",#sel,modified)) end g_aux_vad=nil g_aux_flux=nil end

local cfgPath,cfg=aegisub.decode_path("?user/scxvid.cfg"),{scx="",ffmpeg="",suf="_keyframes.log"}
local function loadScxCfg() local f=io.open(cfgPath,"r") if not f then return end for k,v in f:read("*a"):gmatch("([%w_]+)=([^\n]+)")do cfg[k]=v end f:close() end
local function saveScxCfg() local f=io.open(cfgPath,"w") if not f then return end for k,v in pairs(cfg)do f:write(k.."="..v.."\n") end f:close() end
local function fExists(p) local f=io.open(p) if f then f:close() return true end end
local function dirName(p) return p:match("^(.*[\\/])")or"" end
local function baseName(p) return(p:gsub("^.*[\\/]","")):gsub("%.[^.]+$","") end
local function askScxSettings() local dlg={{class="label",label="Path to scxvid.exe (PATH if empty):",x=0,y=0,width=4,height=1},{class="edit",name="scx",value=cfg.scx,x=0,y=1,width=4},{class="label",label="Path to ffmpeg.exe (PATH if empty):",x=0,y=2,width=4,height=1},{class="edit",name="ffmpeg",value=cfg.ffmpeg,x=0,y=3,width=4},{class="label",label="Log suffix:",x=0,y=4,width=2,height=1},{class="edit",name="suf",value=cfg.suf,x=2,y=4,width=2},{class="checkbox",name="save",label="Save defaults",value=true,x=0,y=5,width=4}} local b,r=aegisub.dialog.display(dlg,{"Continue","Cancel"}) if b~="Continue" then return false end cfg.scx,cfg.ffmpeg,cfg.suf=r.scx,r.ffmpeg,r.suf if r.save then saveScxCfg() end return true end
local function runScxvid() loadScxCfg() local props=aegisub.project_properties() local video=props.video_file if not video or video=="" then aegisub.dialog.display({{class="label",label="No video loaded.",x=0,y=0}},{"OK"}) return end if not askScxSettings() then return end if cfg.scx~="" and not fExists(cfg.scx) then aegisub.dialog.display({{class="label",label="SCXvid not found:\n"..cfg.scx,x=0,y=0}},{"OK"}) return end if cfg.ffmpeg~="" and not fExists(cfg.ffmpeg) then aegisub.dialog.display({{class="label",label="FFmpeg not found:\n"..cfg.ffmpeg,x=0,y=0}},{"OK"}) return end local scx=(cfg.scx~=""and cfg.scx or"scxvid.exe") local ffm=(cfg.ffmpeg~=""and cfg.ffmpeg or"ffmpeg") local outLog=dirName(video)..baseName(video)..cfg.suf local bat=aegisub.decode_path("?temp/scxvid_run.bat") local f=io.open(bat,"w") f:write("@echo off\n\""..ffm.."\" -i \""..video.."\" -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | \""..scx.."\" \""..outLog.."\"\npause\n") f:close() os.execute('start "" "'..bat..'"') aegisub.dialog.display({{class="label",label="Process started.\nLog: "..outLog,x=0,y=0}},{"OK"}) end

function hd_extract_tags(subs,sel) for _,i in ipairs(sel)do local l=subs[i] local t=l.text local g=t:match("^{[^}]*}") if g then t=t:gsub("^{[^}]*}",""):gsub("^%s*(.-)%s*$","%1") l.effect=g else l.effect="" end l.text=t subs[i]=l end end
function hd_reinsert_tags(subs,sel) for _,i in ipairs(sel)do local l=subs[i] if l.effect~="" then l.text=l.effect:gsub(";",",")..l.text l.effect="" end subs[i]=l end end
function hd_copy_times(subs,sel) if #sel<2 then return end local f=subs[sel[1]] local s,e=f.start_time,f.end_time for i=2,#sel do local l=subs[sel[i]] l.start_time=s l.end_time=e subs[sel[i]]=l end end
function hd_swap_comment(subs,sel) for _,i in ipairs(sel)do local l=subs[i] local m,c=l.text:match("^(.-)%s*({.+})%s*$") if m and c then local cc=c:match("^{(.-)}$") l.text=cc.." {"..m:gsub("^%s*(.-)%s*$","%1").."}" subs[i]=l end end end
local function processPunctuation(subs,sel,type) for _,i in ipairs(sel)do local l=subs[i] local t=l.text local c=t:gsub("{[^}]*}","") if c~="" then local p,s="","" if type==1 then p,s="¡","!" elseif type==2 then p,s="¿","?" elseif type==3 then p,s="¡¿","?!" end if not c:match("^"..p) then c=p..c end if not c:match(s.."$") then c=c..s end l.text=t:gsub("[^{}]+$",c) subs[i]=l end end end
function hd_punct_exclamation(subs,sel) processPunctuation(subs,sel,1) end
function hd_punct_question(subs,sel) processPunctuation(subs,sel,2) end
function hd_punct_both(subs,sel) processPunctuation(subs,sel,3) end
function hd_sort_by_length(subs,sel) local t={} for _,i in ipairs(sel)do table.insert(t,{l=subs[i],n=charCount(subs[i].text),idx=i}) end table.sort(t,function(a,b)return a.n>b.n end) for k,v in ipairs(t)do subs[sel[k]]=v.l end end
function blank_eraser(subs,sel) local d={} for _,i in ipairs(sel)do if stripTags(subs[i].text):gsub("%s+","")=="" then table.insert(d,i) end end safeDelete(subs,d) aegisub.dialog.display({{class="label",label="Deleted "..#d.." lines."}},{"OK"}) end
function join_same_text(subs,sel) table.sort(sel,function(a,b)return a>b end) for _,i in ipairs(sel)do if i>1 and subs[i-1] then local l,p=subs[i],subs[i-1] if l.text==p.text then p.end_time=math.max(p.end_time,l.end_time) subs[i-1]=p subs.delete(i) end end end end
function time_picker(subs,sel) local ms,me for _,i in ipairs(sel)do local l=subs[i] if not ms or l.start_time<ms then ms=l.start_time end if not me or l.end_time>me then me=l.end_time end end if not ms then return sel end local n={} for i=1,#subs do local l=subs[i] if l.class=="dialogue" and l.start_time>=ms and l.end_time<=me then table.insert(n,i) end end return n end
function style_sentinel(subs,sel) local s={} for _,i in ipairs(sel)do s[subs[i].style]=true end local l="" for k in pairs(s)do l=l..k.."\n" end local b,r=aegisub.dialog.display({{class="label",label="Keep styles:",x=0,y=0,width=1},{class="label",label="                                        ",x=1,y=0,width=1},{class="textbox",text=l,name="k",x=0,y=1,width=2,height=6}},{"Filter","Cancel"}) if b~="Filter" then return end local k={} for x in r.k:gmatch("[^\n]+")do k[x]=true end local d={} for _,i in ipairs(sel)do if not k[subs[i].style] then table.insert(d,i) end end safeDelete(subs,d) end
function caption_clarifier(subs,sel) for _,i in ipairs(sel)do local l=subs[i] l.text=l.text:gsub("（[^（）]*）",""):gsub("%([^%(%)]*%)",""):gsub("［[^［］]*］",""):gsub("%[[^%[%]]*%]","") subs[i]=l end end

local lb_cfg={minLength=15,widthDiffPenalty=100,ragPenaltyFactor=10,shortCharsPenalty=500,minChars=5,shortWordsPenalty=1000,minWords=2}
local function isWS(c) return c==" " or c=="\t" end
local function cntW(t) local c,inW=0,false for i=1,#t do local h=t:sub(i,i) if not isWS(h) and not inW then c=c+1 inW=true elseif isWS(h) then inW=false end end return c end
local function measW(t,s) if not t or t=="" then return 0 end return aegisub.text_extents(s,stripTags(t)) or 0 end
local function findBP(t) local p,inT={},false for i=1,#t do local c=t:sub(i,i) if c=="{" then inT=true elseif c=="}" then inT=false elseif not inT and isWS(c) then table.insert(p,i) end end return p end
local function splT(t,p) local a=t:sub(1,p) local s=p+1 while s<=#t and isWS(t:sub(s,s)) do s=s+1 end return a,t:sub(s) end
local function fBest(t,s,mw) local bp=findBP(t) if #bp==0 then return nil end local bc,bi=math.huge,nil for _,p in ipairs(bp)do local p1,p2=splT(t,p) local w1,w2=measW(p1,s),measW(p2,s) local diff=math.abs(w1-w2) local c=lb_cfg.widthDiffPenalty*diff if #stripTags(p2)<lb_cfg.minChars then c=c+lb_cfg.shortCharsPenalty end if cntW(stripTags(p2))<lb_cfg.minWords then c=c+lb_cfg.shortWordsPenalty end if c<bc then bc=c bi=p end end return bi end
local function insN(t,p) return t:sub(1,p).."\\N"..t:sub(p+1) end
local function leblanc_six(subs,sel) 
  local vw=aegisub.video_size() or 1920 
  if type(vw)=="table" then vw=vw.width end 
  local st={} 
  for i=1,#subs do 
    if subs[i].class=="style" then st[subs[i].name]=subs[i] end 
  end 
  aegisub.progress.task("LeBlanc Six Auto-Break...")
  for idx,i in ipairs(sel)do 
    aegisub.progress.set(idx/#sel*100)
    local l=subs[i] 
    local s=st[l.style] 
    if s and not l.text:find("\\N") and #stripTags(l.text)>lb_cfg.minLength then 
      local av=vw-(l.margin_l>0 and l.margin_l or s.margin_l)-(l.margin_r>0 and l.margin_r or s.margin_r) 
      if measW(l.text,s)>av then 
        local bp=fBest(l.text,s,av) 
        if bp then 
          l.text=insN(l.text,bp) 
          subs[i]=l 
        end 
      end 
    end 
  end 
end

local hd_items={"Blank Eraser","Join Same Text","Time Picker","Caption Clarifier","Style Sentinel","LeBlanc Six","Copy Times","Extract Tags","Reinsert Tags","Sort by Length","Punctuation: ¡!","Punctuation: ¿?","Punctuation: ¡¿?!","Swap Comment","Add an8"}
local hd_info={
    ["Blank Eraser"]="Removes empty lines (no visible text)",
    ["Join Same Text"]="Joins consecutive lines with identical text",
    ["LeBlanc Six"]="Divides lines automatically by video width",
    ["Style Sentinel"]="Removes lines not matching selected styles",
    ["Time Picker"]="Selects lines within current time range",
    ["Caption Clarifier"]="Removes text between parentheses/brackets",
    ["Sort by Length"]="Sorts selection by character count",
    ["Copy Times"]="Copies times from first line to others",
    ["Extract Tags"]="Extracts tags to Effect field",
    ["Reinsert Tags"]="Reinserts tags from Effect to text",
    ["Swap Comment"]="Swaps text with comment in curly braces",
    ["Add an8"]="Adds the tag {\\an8} (top alignment) to lines"
}

local function hd_add_an8(subs,sel)
    for _,i in ipairs(sel)do
        local l=subs[i]
        local existing_tags=l.text:match("^{[^}]*}")
        if existing_tags then
            if not existing_tags:match("\\an%d") then
                l.text=l.text:gsub("^({[^}]*)","%1\\an8")
            end
        else
            l.text="{\\an8}"..l.text
        end
        subs[i]=l
    end
end

local globalHelpText = [[
Chronorow Master — Complete Guide
================================================================

Why this panel?
Activate the tools you need, adjust fields in
milliseconds, and press EXECUTE. Nothing is modified until you
do so, so experiment freely.

DOGGO MODE
If you enable the "Doggo Mode" checkbox, EXECUTE will apply only
the selected tool in Hot Dog Utils. If disabled,
all marked options are executed.

TIMING & MARKERS

• Mode: Controls which time to verify
  - End Only: Only verifies line ending
  - Start Only: Only verifies line start
  - Both: Verifies start AND end

• Keyframe Seal - Marks lines on keyframes
  End Only: [KF-E] if ends on KF
  Start Only: [KF-S] if starts on KF
  Both: [KF-E] and/or [KF-S] as appropriate

• Twin KF (ms) - Detects twin keyframes
  End Only: [Twin-E] if end IS already on KF AND there's another previous KF (within X ms before)
  Start Only: [Twin-S] if start IS already on KF AND there's another previous KF (within X ms before)
  Both: Verifies both
  Value: 0=off, 1000 recommended
  
  Example: If end is on KF and Twin=1000, marks [Twin-E] if there's
  another KF between [end-1000ms] and [end-1ms]

• Miss KF (ms) - Detects missed keyframes
  End Only: [Miss-E] if end is NOT on KF BUT there's one nearby before
  Start Only: [Miss-S] if start is NOT on KF BUT there's one nearby before
  Both: Verifies both
  Value: 0=off, 1000 recommended
  
  Example: If end is NOT on KF and Miss=1000, marks [Miss-E] if there's
  a KF between [end-1000ms] and [end-1ms]
  Both: Verifies both
  Value: 0=off, 500-1000 recommended

• Overtime (ms) - Marks [Overtime] if line lasts longer
  Value: 0=disabled, 5500+ for long lines

• Overlap Alert - Marks [Overlap] on overlapping lines
• Gap Marker (auto) - Marks 0-300ms gaps automatically
• Mark Uppercase - Marks lines in CAPITALS
• CPS Ranker - Sorts by CPS (characters/second)
• Show Avg - Displays average CPS

TEXT TOOLS

• Divine Dividing - Divides lines by sentences (.?!)
  - Preview only: Marks [2S][3S] without dividing
  - Include commas: Also divides by commas and semicolons
• Line Cleaver \\N - Divides by \\N
• Kana-Beat {\\k} - Generates romaji karaoke
• Mark Miss Punct - Marks lines missing final punctuation

HOT DOG UTILS (Tools)
• Blank Eraser - Deletes empty lines
• Join Same Text - Joins consecutive identical lines
• Time Picker - Selects by time range
• Caption Clarifier - Removes parentheses/brackets
• Style Sentinel - Filters by styles
• LeBlanc Six - Divides by video width
• Copy Times - Copies times from first line
• Extract Tags - Moves tags to Effect
• Reinsert Tags - Returns tags to text
• Sort by Length - Sorts by characters
• Punctuation - Adds ¡!¿?
• Swap Comment - Swaps text/comment
• Add an8 - Adds {\\an8} (top alignment)

MARABUNTA
Paste lines in format:
Dialogue: 0,0:00:00.00,0:00:05.00,Style,,0,0,0,,Text

• Ant Effects - Imports Effects by time overlap
• Ant Lines - Imports text by overlap
• Ant Actor - Assigns actors by overlap
• As comment - Wraps text in {}

ADVANCED OPTIONS
• LazyTimer - Automatic timing from FFmpeg silence files
  - Cluster: Groups events by temporal proximity.
  - Table: Uses global noise table (good for continuous audio).
• Extract KF - Generates keyframes with SCXvid
• GapMarker - Advanced gap configuration (max 5000ms)

KITE PRESET
Fills: Twin=1000, Miss=1000, Overtime=5500

APPLY TO (Targeting)
• All Selected - All lines
• By Style/Actor/Effect/Layer - Filters by field

COMBINATIONS TO AVOID
• Divine Dividing + Line Cleaver \\N = will duplicate divisions
• Split tools + Marabunta = may cause desynchronisation

TIPS
• Ctrl+Z undoes everything
• Doggo Mode: only executes one Hot Dog tool
• Be careful combining options, recommended to execute one function at a time
• Numeric values must be numbers >= 0
]]

local function row_master_gui(subs,sel)
    if not sel or #sel == 0 then
        aegisub.dialog.display({{class="label",label="No lines selected. Please select at least one line."}},{"OK"})
        return
    end
    
    local p={twin="0",miss="0",ov="0",mode="End Only",kf=false,ovl=false,gap=false,upp=false,punct=false,
             sent=false,preview=false,comma=false,splitN=false,romaji=false,cps=false,avg=false,
             tm="All Selected",tv="",ht="Blank Eraser",mm="Ant Effects",mr="",mc=false,doggo_mode=false}
    
    while true do
        local d={
            {class="label",label="Apply to:",x=0,y=0,width=1,height=1},
            {class="dropdown",name="tm",items={"All Selected","By Style","By Actor","By Effect","By Layer"},value=p.tm,x=1,y=0,width=3,height=1},
            {class="edit",name="tv",value=p.tv,hint="Filter value (style, actor, etc.)",x=4,y=0,width=4,height=1},
            {class="checkbox",name="doggo_mode",label="Doggo Mode",value=p.doggo_mode,x=8,y=0,width=4,height=1,hint="If active, EXECUTE only applies the selected Hot Dog tool"},
            
            {class="label",label="──── TIMING & MARKERS ────",x=0,y=1,width=4,height=1},
            
            {class="label",label="Mode:",x=0,y=2,width=1,height=1},
            {class="dropdown",name="mode",items={"End Only","Start Only","Both"},value=p.mode,x=1,y=2,width=3,height=1,hint="End Only: end only | Start Only: start only | Both: both"},
            
            {class="label",label="Twin KF (ms):",x=0,y=3,width=1,height=1},
            {class="edit",name="twin",value=p.twin,x=1,y=3,width=3,height=1,hint="Detects twin keyframes (multiple KFs nearby). 0=disabled, 500-1000 recommended"},
            
            {class="label",label="Miss KF (ms):",x=0,y=4,width=1,height=1},
            {class="edit",name="miss",value=p.miss,x=1,y=4,width=3,height=1,hint="Detects missed KFs (line doesn't end on KF but one nearby). 0=off, 500-1000 recom"},
            
            {class="label",label="Overtime (ms):",x=0,y=5,width=1,height=1},
            {class="edit",name="ov",value=p.ov,x=1,y=5,width=3,height=1,hint="Marks lines lasting longer than X ms. 0=disabled, 5500+ for long lines"},
            
            {class="checkbox",name="kf",label="Keyframe Seal",value=p.kf,x=0,y=6,width=4,height=1,hint="Marks lines ending exactly on keyframe"},
            {class="checkbox",name="ovl",label="Overlap Alert",value=p.ovl,x=0,y=7,width=4,height=1,hint="Detects and marks overlapping lines in time"},
            {class="checkbox",name="gap",label="Gap Marker (auto)",value=p.gap,x=0,y=8,width=4,height=1,hint="Marks small gaps between lines (blinks). Preset: 0-500ms"},
            {class="checkbox",name="upp",label="Mark Uppercase",value=p.upp,x=0,y=9,width=4,height=1,hint="Marks lines completely in CAPITALS"},
            
            {class="label",label="─── CPS Tools ───",x=0,y=10,width=4,height=1},
            {class="checkbox",name="cps",label="CPS Ranker",value=p.cps,x=0,y=11,width=2,height=1,hint="Sorts lines by CPS (characters per second)"},
            {class="checkbox",name="avg",label="Show Avg",value=p.avg,x=2,y=11,width=2,height=1,hint="Displays average CPS of selection"},
            
            {class="label",label="──── TEXT TOOLS ────",x=4,y=1,width=4,height=1},
            
            {class="label",label="Divine Dividing:",x=4,y=2,width=4,height=1},
            {class="checkbox",name="sent",label="  Divide (.?!)",value=p.sent,x=4,y=3,width=4,height=1,hint="Divides lines by sentences (uses full stops .?!)"},
            {class="checkbox",name="preview",label="  Preview",value=p.preview,x=4,y=4,width=4,height=1,hint="Doesn't divide, only marks [NS] at start"},
            {class="checkbox",name="comma",label="  Include commas",value=p.comma,x=4,y=5,width=4,height=1,hint="Also divides by commas ,;、 and hyphens ' - '"},
            
            {class="label",label="─── Other Tools ───",x=4,y=6,width=4,height=1},
            {class="checkbox",name="splitN",label="Line Cleaver \\N",value=p.splitN,x=4,y=7,width=4,height=1,hint="Divides lines by \\N into separate lines"},
            {class="checkbox",name="romaji",label="Kana-Beat {\\k}",value=p.romaji,x=4,y=8,width=4,height=1,hint="Generates \\k tags for romaji (karaoke)"},
            {class="checkbox",name="punct",label="Mark Miss Punct",value=p.punct,x=4,y=9,width=4,height=1,hint="Marks lines missing final punctuation"},
            
            {class="label",label="─── Hot Dog Utils ───",x=4,y=10,width=4,height=1},
            {class="dropdown",name="ht",items=hd_items,value=p.ht,x=4,y=11,width=4,height=1,hint="Quick editing tools"},
            
            {class="label",label="─── MARABUNTA ───",x=8,y=1,width=4,height=1},
            {class="label",label="Format: Dialogue: L,Start,End,...",x=8,y=2,width=4,height=1},
            
            {class="dropdown",name="mm",items={"Ant Effects","Ant Lines","Ant Actor"},value=p.mm,x=8,y=3,width=4,height=1,hint="What to import: Effects/Text/Actor"},
            {class="textbox",name="mr",value=p.mr,x=8,y=4,width=4,height=7,hint="Paste 'Dialogue:' lines from another .ass here. Will merge by time overlap"},
            {class="checkbox",name="mc",label="As comment {...}",value=p.mc,x=8,y=11,width=4,height=1,hint="When importing text, wraps in {...}"},
        }
        
        local buttons={"EXECUTE","Kite","LazyTimer","Extract KF","GapMarker","HELP","Cancel"}
        local b,r=aegisub.dialog.display(d,buttons)
        
        if b=="Cancel" or not b then return end 
        p=r
        
        if b=="HELP" then
            aegisub.dialog.display({{class="textbox",text=globalHelpText,x=0,y=0,width=60,height=25}},{"OK"})
        elseif b=="Kite" then 
            p.twin,p.miss,p.ov="1000","1000","5500"
        elseif b=="LazyTimer" then 
            lazyTimer(subs,sel)
            return
        elseif b=="Extract KF" then 
            runScxvid()
        elseif b=="GapMarker" then 
            gapMarker(subs,sel)
            return
        elseif b=="EXECUTE" then
            local twin_val = tonumber(r.twin)
            local miss_val = tonumber(r.miss)
            local ov_val = tonumber(r.ov)
            
            if not twin_val or twin_val < 0 then
                aegisub.dialog.display({{class="label",label="Twin KF must be a number ≥ 0"}},{"OK"})
                goto continue
            end
            if not miss_val or miss_val < 0 then
                aegisub.dialog.display({{class="label",label="Miss KF must be a number ≥ 0"}},{"OK"})
                goto continue
            end
            if not ov_val or ov_val < 0 then
                aegisub.dialog.display({{class="label",label="Overtime must be a number ≥ 0"}},{"OK"})
                goto continue
            end
            
            local tsel=getTargetedSelection(subs,sel,{mode=r.tm,value=r.tv})
            if #tsel==0 then 
                aegisub.dialog.display({{class="label",label="Filter resulted in 0 lines."}},{"OK"}) 
                goto continue
            end
            
            if r.sent and r.splitN then
                aegisub.dialog.display({{class="label",label="⚠ Avoid combining Divine Dividing with Line Cleaver (will duplicate divisions)"}},{"OK"})
                goto continue
            end
            
            aegisub.progress.task("Processing...")
            
            if r.doggo_mode then
                if r.ht=="Blank Eraser" then blank_eraser(subs,tsel) 
                elseif r.ht=="Join Same Text" then join_same_text(subs,tsel) 
                elseif r.ht=="Time Picker" then tsel=time_picker(subs,tsel) 
                elseif r.ht=="Style Sentinel" then style_sentinel(subs,tsel) 
                elseif r.ht=="Caption Clarifier" then caption_clarifier(subs,tsel) 
                elseif r.ht=="LeBlanc Six" then leblanc_six(subs,tsel) 
                elseif r.ht=="Copy Times" then hd_copy_times(subs,tsel) 
                elseif r.ht=="Extract Tags" then hd_extract_tags(subs,tsel) 
                elseif r.ht=="Reinsert Tags" then hd_reinsert_tags(subs,tsel) 
                elseif r.ht=="Sort by Length" then hd_sort_by_length(subs,tsel) 
                elseif r.ht:match("Punctuation") then 
                    if r.ht:match("¡!") then hd_punct_exclamation(subs,tsel) 
                    elseif r.ht:match("¿%?") then hd_punct_question(subs,tsel) 
                    else hd_punct_both(subs,tsel) end 
                elseif r.ht=="Swap Comment" then hd_swap_comment(subs,tsel) 
                elseif r.ht=="Add an8" then hd_add_an8(subs,tsel)
                end
                aegisub.set_undo_point("Chronorow Master - "..r.ht) 
                return
            end
            
            if r.preview then sentenceTool(subs,tsel,{comma=r.comma,preview=true}) 
            elseif r.sent then sentenceTool(subs,tsel,{comma=r.comma,preview=false}) end
            if r.splitN then splitByN(subs,tsel) end
            if r.romaji then romajiKara(subs,tsel) end
            if r.cps then sortByCPS(subs,tsel) end
            if r.kf or tonumber(r.twin)>0 or tonumber(r.miss)>0 or tonumber(r.ov)>0 then 
                tagTiming(subs,tsel,{kf=r.kf,twin=tonumber(r.twin)or 0,miss=tonumber(r.miss)or 0,ov=tonumber(r.ov)or 0,mode=r.mode}) 
            end
            if r.ovl then tagOverlaps(subs,tsel) end
            if r.gap then markSmallGaps(subs,tsel,{maxGap=300, ignoreKeyframes=false, markContinuous=false, gapTag="SmallGap"}) end
            if r.upp then markUppercase(subs,tsel) end
            if r.punct then markMissingPunctuation(subs,tsel) end
            if r.mr~="" then 
                if r.mm=="Ant Effects" then antEffects(subs,tsel,r.mr) 
                elseif r.mm=="Ant Lines" then antLines(subs,tsel,r.mr,r.mc) 
                elseif r.mm=="Ant Actor" then antActor(subs,tsel,r.mr) 
                end 
            end
            if r.avg then showAvgCPS(subs,tsel) end
            aegisub.set_undo_point("Chronorow Master - Executed") 
            return
        end
        ::continue::
    end
end

aegisub.register_macro(menu_embedding..script_name,script_description,row_master_gui)
aegisub.register_macro(menu_embedding.."Hot Dog/Extract Tags","Extract Tags",hd_extract_tags)
aegisub.register_macro(menu_embedding.."Hot Dog/Reinsert Tags","Reinsert Tags",hd_reinsert_tags)
aegisub.register_macro(menu_embedding.."Hot Dog/Copy Times","Copy Times",hd_copy_times)
aegisub.register_macro(menu_embedding.."Hot Dog/Swap Comment","Swap Comment",hd_swap_comment)
aegisub.register_macro(menu_embedding.."Utility/Blank Eraser","Delete empty",blank_eraser)
aegisub.register_macro(menu_embedding.."Utility/Join Same Text","Join Identical",join_same_text)
aegisub.register_macro(menu_embedding.."Utility/Time Picker","Select range",function(s,sel) return time_picker(s,sel) end)
aegisub.register_macro(menu_embedding.."Utility/Style Sentinel","Filter Styles",style_sentinel)
aegisub.register_macro(menu_embedding.."Utility/Caption Clarifier","Remove brackets",caption_clarifier)
aegisub.register_macro(menu_embedding.."Utility/LeBlanc Six","Auto Break",leblanc_six)
aegisub.register_macro(menu_embedding.."Utility/Sort by Length","Sort length",hd_sort_by_length)
aegisub.register_macro(menu_embedding.."Utility/Mark Uppercase","Mark Uppercase",markUppercase)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Exclamation","¡!",hd_punct_exclamation)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Question","¿?",hd_punct_question)
aegisub.register_macro(menu_embedding.."Utility/Punctuation/Both","¡¿?!",hd_punct_both)
aegisub.register_macro(menu_embedding.."Utility/Add an8","Add top alignment",hd_add_an8)
