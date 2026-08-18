-- Velora v0.3.0 "Nocturne" 🥀🎹
-- Original implementation for MrRos3/Velora.
-- High-level UX inspiration only; no TALENTLESS source is copied.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local player=Players.LocalPlayer
assert(player,"Velora must run on the Roblox client")

local parent=(gethui and gethui()) or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
local RAW="https://raw.githubusercontent.com/MrRos3/Velora/main/"
local VERSION="0.3.0"

local C={
    Base=Color3.fromRGB(12,15,23),
    Panel=Color3.fromRGB(18,22,33),
    Raised=Color3.fromRGB(27,32,47),
    Edge=Color3.fromRGB(255,255,255),
    Accent=Color3.fromRGB(147,126,255),
    Accent2=Color3.fromRGB(199,186,255),
    Text=Color3.fromRGB(248,249,255),
    Sub=Color3.fromRGB(176,183,207),
    Muted=Color3.fromRGB(104,113,143),
    Good=Color3.fromRGB(109,255,168),
    Bad=Color3.fromRGB(255,107,122),
}

local function round(o,r) local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r);x.Parent=o;return x end
local function outline(o,t,c) local x=Instance.new("UIStroke");x.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;x.Color=c or C.Edge;x.Transparency=t or .82;x.Thickness=1;x.Parent=o;return x end
local function tw(o,d,p) if not o or not o.Parent then return end local x=TweenService:Create(o,TweenInfo.new(d,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p);x:Play();return x end
local function label(p,s,z,f,col) local x=Instance.new("TextLabel");x.BackgroundTransparency=1;x.Text=s or "";x.TextSize=z or 11;x.Font=f or Enum.Font.Gotham;x.TextColor3=col or C.Text;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=p;return x end
local function btn(p,s,sz)
    local x=Instance.new("TextButton");x.AutoButtonColor=false;x.BackgroundColor3=C.Raised;x.BackgroundTransparency=.22;x.BorderSizePixel=0;x.Size=sz or UDim2.fromOffset(90,32);x.Font=Enum.Font.GothamSemibold;x.Text=s;x.TextColor3=C.Text;x.TextSize=10;x.Parent=p;round(x,9);outline(x,.8)
    x.MouseEnter:Connect(function() tw(x,.12,{BackgroundTransparency=.05}) end)
    x.MouseLeave:Connect(function() tw(x,.12,{BackgroundTransparency=.22}) end)
    return x
end
local function fetch(path)
    local raw=game:HttpGet(RAW..path.."?v="..VERSION)
    local chunk,err=loadstring(raw)
    assert(chunk,"Velora failed to compile "..path..": "..tostring(err))
    local ok,res=pcall(chunk)
    assert(ok,"Velora failed to run "..path..": "..tostring(res))
    return res
end
local function parse(sheet,bpm,spb)
    bpm=math.clamp(tonumber(bpm) or 120,30,300);spb=math.clamp(tonumber(spb) or 2,1,16)
    local step=(60/bpm)/spb;local events={};local cursor=0
    for token in tostring(sheet or ""):gmatch("%S+") do
        if token=="|" then
        elseif token=="-" or token=="_" then cursor+=step
        else
            local notes={}
            if token:sub(1,1)=="[" and token:sub(-1)=="]" then
                for n in token:sub(2,-2):gmatch("[^,%s]+") do
                    if #n==1 then table.insert(notes,n) else for i=1,#n do table.insert(notes,n:sub(i,i)) end end
                end
            else table.insert(notes,token) end
            if #notes>0 then table.insert(events,{Time=cursor,Notes=notes,Token=token}) end
            cursor+=step
        end
    end
    return {BPM=bpm,StepsPerBeat=spb,Duration=cursor,Events=events}
end

local SONGS=fetch("Songs.lua")
assert(type(SONGS)=="table","Velora Songs.lua must return a table")

local state={song=nil,entry=nil,timeline=nil,bpm=120,speed=1,playing=false,paused=false,loop=false,position=0,nextEvent=1,heartbeat=nil,category="All",search="",favorites={},keyboard=true,handler=nil,visible=true}
local API={Version=VERSION}

local function loadFavs()
    if type(readfile)~="function" then return end
    pcall(function()
        if type(isfile)=="function" and not isfile("Velora/favorites.json") then return end
        local d=HttpService:JSONDecode(readfile("Velora/favorites.json"));if type(d)=="table" then state.favorites=d end
    end)
end
local function saveFavs()
    if type(writefile)~="function" then return end
    pcall(function()
        if type(makefolder)=="function" and (type(isfolder)~="function" or not isfolder("Velora")) then makefolder("Velora") end
        writefile("Velora/favorites.json",HttpService:JSONEncode(state.favorites))
    end)
end
loadFavs()

local function press(note)
    if type(state.handler)=="function" then pcall(state.handler,note);return end
    if not state.keyboard then return end
    local ch=tostring(note):sub(1,1):upper();local byte=string.byte(ch)
    if not byte then return end
    if type(keypress)=="function" then pcall(keypress,byte) end
    if type(keyrelease)=="function" then task.delay(.025,function() pcall(keyrelease,byte) end) end
    if type(keypress)~="function" then print("[Velora] NOTE",note) end
end
function API:BindPiano(fn) state.handler=type(fn)=="function" and fn or nil end
function API:SetKeyboardBridge(v) state.keyboard=v~=false end
function API:GetSongs() return SONGS end
function API:GetState() return state end

local old=parent:FindFirstChild("VeloraNocturne");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="VeloraNocturne";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
local main=Instance.new("Frame");main.AnchorPoint=Vector2.new(.5,.5);main.Position=UDim2.fromScale(.5,.5);main.Size=UDim2.fromOffset(760,440);main.BackgroundColor3=C.Base;main.BackgroundTransparency=.04;main.BorderSizePixel=0;main.ClipsDescendants=true;main.Parent=gui;round(main,22);outline(main,.58)
local g=Instance.new("UIGradient");g.Rotation=28;g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(29,33,49)),ColorSequenceKeypoint.new(.5,C.Base),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,10,16))});g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.2),NumberSequenceKeypoint.new(1,.68)});g.Parent=main

local top=Instance.new("Frame");top.Size=UDim2.new(1,0,0,58);top.BackgroundColor3=C.Panel;top.BackgroundTransparency=.2;top.BorderSizePixel=0;top.Parent=main
local brand=label(top,"VELORA",21,Enum.Font.GothamBold);brand.Position=UDim2.fromOffset(18,8);brand.Size=UDim2.fromOffset(150,25)
local sub=label(top,"NOCTURNE  •  PIANO ENGINE",8,Enum.Font.GothamBold,C.Accent2);sub.Position=UDim2.fromOffset(18,33);sub.Size=UDim2.fromOffset(230,14)
local ver=label(top,"v"..VERSION,8,Enum.Font.GothamMedium,C.Muted);ver.AnchorPoint=Vector2.new(1,.5);ver.Position=UDim2.new(1,-58,.5,0);ver.Size=UDim2.fromOffset(50,18);ver.TextXAlignment=Enum.TextXAlignment.Right
local close=btn(top,"×",UDim2.fromOffset(32,32));close.AnchorPoint=Vector2.new(1,.5);close.Position=UDim2.new(1,-12,.5,0);close.TextSize=18

local body=Instance.new("Frame");body.Position=UDim2.fromOffset(0,58);body.Size=UDim2.new(1,0,1,-58);body.BackgroundTransparency=1;body.Parent=main
local left=Instance.new("Frame");left.Size=UDim2.fromOffset(148,382);left.BackgroundColor3=C.Panel;left.BackgroundTransparency=.5;left.BorderSizePixel=0;left.Parent=body
local center=Instance.new("Frame");center.Position=UDim2.fromOffset(148,0);center.Size=UDim2.fromOffset(364,382);center.BackgroundTransparency=1;center.Parent=body
local right=Instance.new("Frame");right.Position=UDim2.fromOffset(512,0);right.Size=UDim2.fromOffset(248,382);right.BackgroundColor3=C.Panel;right.BackgroundTransparency=.45;right.BorderSizePixel=0;right.Parent=body

local lt=label(left,"LIBRARY",9,Enum.Font.GothamBold,C.Muted);lt.Position=UDim2.fromOffset(15,16);lt.Size=UDim2.fromOffset(115,18)
local cats=Instance.new("ScrollingFrame");cats.Position=UDim2.fromOffset(10,42);cats.Size=UDim2.new(1,-20,1,-58);cats.BackgroundTransparency=1;cats.BorderSizePixel=0;cats.ScrollBarThickness=2;cats.ScrollBarImageColor3=C.Muted;cats.AutomaticCanvasSize=Enum.AutomaticSize.Y;cats.CanvasSize=UDim2.new();cats.Parent=left
local cl=Instance.new("UIListLayout");cl.Padding=UDim.new(0,7);cl.Parent=cats

local search=Instance.new("TextBox");search.Position=UDim2.fromOffset(14,14);search.Size=UDim2.new(1,-28,0,38);search.BackgroundColor3=C.Panel;search.BackgroundTransparency=.18;search.BorderSizePixel=0;search.ClearTextOnFocus=false;search.Font=Enum.Font.GothamMedium;search.PlaceholderText="Search songs, artists, tags...";search.PlaceholderColor3=C.Muted;search.Text="";search.TextColor3=C.Text;search.TextSize=10;search.TextXAlignment=Enum.TextXAlignment.Left;search.Parent=center;round(search,11);local ss=outline(search,.8)
local songs=Instance.new("ScrollingFrame");songs.Position=UDim2.fromOffset(14,62);songs.Size=UDim2.new(1,-28,1,-76);songs.BackgroundTransparency=1;songs.BorderSizePixel=0;songs.ScrollBarThickness=2;songs.ScrollBarImageColor3=C.Muted;songs.AutomaticCanvasSize=Enum.AutomaticSize.Y;songs.CanvasSize=UDim2.new();songs.Parent=center
local sl=Instance.new("UIListLayout");sl.Padding=UDim.new(0,8);sl.Parent=songs

local nt=label(right,"NOW PLAYING",9,Enum.Font.GothamBold,C.Muted);nt.Position=UDim2.fromOffset(16,16);nt.Size=UDim2.fromOffset(200,18)
local name=label(right,"Choose a song",16,Enum.Font.GothamBold);name.Position=UDim2.fromOffset(16,45);name.Size=UDim2.new(1,-32,0,42);name.TextWrapped=true
local meta=label(right,"Velora library",9,Enum.Font.Gotham,C.Sub);meta.Position=UDim2.fromOffset(16,88);meta.Size=UDim2.new(1,-32,0,28);meta.TextWrapped=true
local fav=btn(right,"☆ Favorite",UDim2.fromOffset(104,30));fav.Position=UDim2.fromOffset(16,122)
local rnd=btn(right,"Random",UDim2.fromOffset(96,30));rnd.Position=UDim2.fromOffset(128,122)
local bl=label(right,"BPM",8,Enum.Font.GothamBold,C.Muted);bl.Position=UDim2.fromOffset(16,167);bl.Size=UDim2.fromOffset(40,14)
local bp=Instance.new("TextBox");bp.Position=UDim2.fromOffset(16,186);bp.Size=UDim2.fromOffset(72,32);bp.BackgroundColor3=C.Raised;bp.BackgroundTransparency=.18;bp.BorderSizePixel=0;bp.ClearTextOnFocus=false;bp.Font=Enum.Font.GothamBold;bp.Text="120";bp.TextColor3=C.Text;bp.TextSize=10;bp.Parent=right;round(bp,9);outline(bp,.78)
local spl=label(right,"SPEED",8,Enum.Font.GothamBold,C.Muted);spl.Position=UDim2.fromOffset(104,167);spl.Size=UDim2.fromOffset(50,14)
local sp=btn(right,"1.00×",UDim2.fromOffset(120,32));sp.Position=UDim2.fromOffset(104,186)
local back=Instance.new("Frame");back.Position=UDim2.fromOffset(16,235);back.Size=UDim2.new(1,-32,0,5);back.BackgroundColor3=C.Raised;back.BorderSizePixel=0;back.Parent=right;round(back,3)
local prog=Instance.new("Frame");prog.Size=UDim2.new(0,0,1,0);prog.BackgroundColor3=C.Accent;prog.BorderSizePixel=0;prog.Parent=back;round(prog,3)
local tm=label(right,"0:00  /  0:00",8,Enum.Font.GothamMedium,C.Muted);tm.Position=UDim2.fromOffset(16,246);tm.Size=UDim2.new(1,-32,0,16);tm.TextXAlignment=Enum.TextXAlignment.Center
local play=btn(right,"▶ Play",UDim2.fromOffset(68,36));play.Position=UDim2.fromOffset(16,274)
local pause=btn(right,"Ⅱ Pause",UDim2.fromOffset(68,36));pause.Position=UDim2.fromOffset(90,274)
local stop=btn(right,"■ Stop",UDim2.fromOffset(68,36));stop.Position=UDim2.fromOffset(164,274)
local loop=btn(right,"↻ Loop",UDim2.fromOffset(96,32));loop.Position=UDim2.fromOffset(16,320)
local bridge=btn(right,"Keyboard: ON",UDim2.fromOffset(112,32));bridge.Position=UDim2.fromOffset(112,320)
local status=label(right,"Ready • keyboard bridge",8,Enum.Font.GothamMedium,C.Muted);status.Position=UDim2.fromOffset(16,356);status.Size=UDim2.new(1,-32,0,14);status.TextXAlignment=Enum.TextXAlignment.Center

local catButtons={};local cards={}
local function time(x) x=math.max(0,tonumber(x) or 0);return string.format("%d:%02d",math.floor(x/60),math.floor(x%60)) end
local function catset(e) local s={};for _,v in ipairs(e.Categories or {}) do s[tostring(v)]=true end;return s end
local function match(e)
    if state.category=="Favorites" then if not state.favorites[e.Id] then return false end elseif state.category~="All" and not catset(e)[state.category] then return false end
    local q=state.search:lower();if q=="" then return true end
    local h=(tostring(e.Name or "").." "..tostring(e.Artist or "").." "..tostring(e.Id or "").." "..table.concat(e.Categories or {}," ").." "..table.concat(e.Aliases or {}," ")):lower()
    return h:find(q,1,true)~=nil
end
local function refresh() for e,c in pairs(cards) do c.Visible=match(e) end end
local function refreshCats() for n,b in pairs(catButtons) do local a=n==state.category;b.BackgroundColor3=a and C.Accent or C.Raised;b.BackgroundTransparency=a and .1 or .5;b.TextColor3=a and C.Text or C.Sub end end
local function halt(reset)
    if state.heartbeat then state.heartbeat:Disconnect();state.heartbeat=nil end
    state.playing=false;state.paused=false;if reset~=false then state.position=0;state.nextEvent=1 end;play.Text="▶ Play";pause.Text="Ⅱ Pause"
end
local function loadSong(e)
    local ok,s=pcall(fetch,e.File);if not ok or type(s)~="table" then status.Text="Could not load song";status.TextColor3=C.Bad;warn(s);return false end
    halt(true);state.entry=e;state.song=s;state.bpm=tonumber(s.BPM or e.BPM) or 120;state.timeline=parse(s.Notes or "",state.bpm,s.StepsPerBeat);name.Text=tostring(e.Name or s.Name or "Untitled");meta.Text=string.format("%s  •  %d BPM\n%s",tostring(e.Artist or s.Artist or "Unknown"),state.bpm,table.concat(e.Categories or {}," · "));bp.Text=tostring(state.bpm);fav.Text=state.favorites[e.Id] and "★ Favorite" or "☆ Favorite";status.Text="Loaded • ready to play";status.TextColor3=C.Muted;prog.Size=UDim2.new(0,0,1,0);tm.Text="0:00  /  "..time(state.timeline.Duration);return true
end
function API:LoadSong(id) for _,e in ipairs(SONGS) do if e.Id==id then return loadSong(e) end end return false end
function API:SetLoop(v) state.loop=v==true;loop.Text=state.loop and "↻ Loop: ON" or "↻ Loop";loop.BackgroundColor3=state.loop and C.Accent or C.Raised end
function API:SetSpeed(v) state.speed=math.clamp(tonumber(v) or 1,.5,2);sp.Text=string.format("%.2f×",state.speed);return state.speed end
function API:Stop() halt(true);status.Text="Stopped";status.TextColor3=C.Muted end
function API:Pause() if state.playing then state.paused=not state.paused;pause.Text=state.paused and "▶ Resume" or "Ⅱ Pause";status.Text=state.paused and "Paused" or "Playing" end end
function API:Play()
    if not state.timeline or #state.timeline.Events==0 then status.Text="Pick a playable song first";status.TextColor3=C.Bad;return false end
    if state.playing then if state.paused then state.paused=false;pause.Text="Ⅱ Pause" end return true end
    state.playing=true;state.paused=false;status.Text="Playing";status.TextColor3=C.Good;play.Text="▶ Playing"
    state.heartbeat=RunService.Heartbeat:Connect(function(dt)
        if state.paused then return end
        state.position+=dt*state.speed
        while state.nextEvent<=#state.timeline.Events and state.timeline.Events[state.nextEvent].Time<=state.position do local ev=state.timeline.Events[state.nextEvent];for _,n in ipairs(ev.Notes) do press(n) end;state.nextEvent+=1 end
        local d=math.max(.001,state.timeline.Duration);local r=math.clamp(state.position/d,0,1);prog.Size=UDim2.new(r,0,1,0);tm.Text=time(state.position).."  /  "..time(d)
        if state.position>=d then if state.loop then state.position=0;state.nextEvent=1 else halt(true);status.Text="Finished";status.TextColor3=C.Muted end end
    end);return true
end

local catNames={All=true,Favorites=true};for _,e in ipairs(SONGS) do for _,c in ipairs(e.Categories or {}) do catNames[tostring(c)]=true end end
local ordered={};for n in pairs(catNames) do table.insert(ordered,n) end;table.sort(ordered,function(a,b) if a=="All" then return true elseif b=="All" then return false elseif a=="Favorites" then return true elseif b=="Favorites" then return false else return a:lower()<b:lower() end end)
for _,n in ipairs(ordered) do local b=btn(cats,"  "..n,UDim2.new(1,0,0,32));b.BackgroundTransparency=.5;b.TextXAlignment=Enum.TextXAlignment.Left;catButtons[n]=b;b.MouseButton1Click:Connect(function() state.category=n;refreshCats();refresh() end) end
for i,e in ipairs(SONGS) do
    local card=Instance.new("TextButton");card.AutoButtonColor=false;card.Size=UDim2.new(1,-2,0,58);card.BackgroundColor3=C.Panel;card.BackgroundTransparency=.3;card.BorderSizePixel=0;card.Text="";card.LayoutOrder=i;card.Parent=songs;round(card,12);outline(card,.84)
    local n=label(card,tostring(e.Name or "Untitled"),11,Enum.Font.GothamSemibold);n.Position=UDim2.fromOffset(13,8);n.Size=UDim2.new(1,-95,0,18)
    local m=label(card,string.format("%s  •  %s BPM",tostring(e.Artist or "Unknown"),tostring(e.BPM or "?")),8,Enum.Font.Gotham,C.Sub);m.Position=UDim2.fromOffset(13,31);m.Size=UDim2.new(1,-95,0,16)
    local t=label(card,(e.Categories and e.Categories[1]) or "",7,Enum.Font.GothamBold,C.Accent2);t.AnchorPoint=Vector2.new(1,.5);t.Position=UDim2.new(1,-12,.5,0);t.Size=UDim2.fromOffset(74,22);t.TextXAlignment=Enum.TextXAlignment.Center
    cards[e]=card;card.MouseEnter:Connect(function() tw(card,.12,{BackgroundTransparency=.12}) end);card.MouseLeave:Connect(function() tw(card,.12,{BackgroundTransparency=.3}) end);card.MouseButton1Click:Connect(function() loadSong(e) end)
end

search.Focused:Connect(function() ss.Color=C.Accent;ss.Transparency=.35 end);search.FocusLost:Connect(function() ss.Color=C.Edge;ss.Transparency=.8 end);search:GetPropertyChangedSignal("Text"):Connect(function() state.search=search.Text;refresh() end)
fav.MouseButton1Click:Connect(function() local e=state.entry;if not e then return end;state.favorites[e.Id]=not state.favorites[e.Id];fav.Text=state.favorites[e.Id] and "★ Favorite" or "☆ Favorite";saveFavs();refresh() end)
rnd.MouseButton1Click:Connect(function() local a={};for _,e in ipairs(SONGS) do if match(e) then table.insert(a,e) end end;if #a>0 then loadSong(a[math.random(1,#a)]) end end)
bp.FocusLost:Connect(function() if not state.song then return end;state.bpm=math.clamp(tonumber(bp.Text) or state.bpm,30,300);bp.Text=tostring(state.bpm);halt(true);state.timeline=parse(state.song.Notes or "",state.bpm,state.song.StepsPerBeat);meta.Text=string.format("%s  •  %d BPM\n%s",tostring(state.entry.Artist or state.song.Artist or "Unknown"),state.bpm,table.concat(state.entry.Categories or {}," · "));tm.Text="0:00  /  "..time(state.timeline.Duration) end)
local speeds={.75,1,1.25,1.5,2};local si=2;sp.MouseButton1Click:Connect(function() si+=1;if si>#speeds then si=1 end;API:SetSpeed(speeds[si]) end)
play.MouseButton1Click:Connect(function() API:Play() end);pause.MouseButton1Click:Connect(function() API:Pause() end);stop.MouseButton1Click:Connect(function() API:Stop() end);loop.MouseButton1Click:Connect(function() API:SetLoop(not state.loop) end)
bridge.MouseButton1Click:Connect(function() state.keyboard=not state.keyboard;bridge.Text=state.keyboard and "Keyboard: ON" or "Keyboard: OFF";bridge.BackgroundColor3=state.keyboard and C.Accent or C.Raised;status.Text=state.keyboard and "Keyboard bridge enabled" or "Keyboard bridge disabled" end)

local dragging=false;local dragStart;local startPos;local dragInput
top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=i.Position;startPos=main.Position end end)
top.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end end)
UIS.InputChanged:Connect(function(i) if dragging and i==dragInput then local d=i.Position-dragStart;main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
close.MouseButton1Click:Connect(function() halt(true);gui:Destroy() end)
UIS.InputBegan:Connect(function(i,p) if not p and i.KeyCode==Enum.KeyCode.RightShift then state.visible=not state.visible;main.Visible=state.visible end end)
local scale=Instance.new("UIScale");scale.Parent=main;local cam=workspace.CurrentCamera;local function fit() if cam then local v=cam.ViewportSize;scale.Scale=math.min(1,math.max(.66,math.min(v.X/820,v.Y/500))) end end;fit();if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end

refreshCats();refresh();if SONGS[1] then loadSong(SONGS[1]) end
main.Size=UDim2.fromOffset(730,420);main.BackgroundTransparency=1;tw(main,.24,{Size=UDim2.fromOffset(760,440),BackgroundTransparency=.04})
_G.Velora=API;pcall(function() if type(getgenv)=="function" then getgenv().Velora=API end end)
return API
