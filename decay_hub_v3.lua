-- DECAY HUB V3 / MINIMAL EDITION
-- Single LocalScript. Recommended location: StarterPlayerScripts.
-- Tabs: Home, Visuals (ESP), Players (ESP), Utility (Auto Harvest + Auto Research), Aim (Aimlock + Hitbox), Config.
-- No login: the hub opens immediately. RightShift shows / hides the window.
-- Includes a draggable player radar (size + range sliders on the Config tab).
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- GUI container: CoreGui first (survives respawns), then gethui(), then PlayerGui as a last resort.
local function getGuiParent()
    local okCore, core = pcall(function() return game:GetService("CoreGui") end)
    if okCore and core then
        local probe = Instance.new("Folder")
        local writable = pcall(function() probe.Parent = core end)
        probe:Destroy()
        if writable then return core end
    end
    local okHui, hui = pcall(function() return gethui and gethui() end)
    if okHui and typeof(hui) == "Instance" then return hui end
    return playerGui
end
local guiParent = getGuiParent()
for _, container in ipairs({guiParent, playerGui}) do
    for _, name in ipairs({"DecayHubV3", "DecayHubWorldOverlays"}) do
        local old = container:FindFirstChild(name)
        if old then old:Destroy() end
    end
end

----------------------------------------------------------------------
-- Theme + helpers
----------------------------------------------------------------------
local ThemePresets = {
    {name="Obsidian", bg=Color3.fromRGB(14,17,26), side=Color3.fromRGB(19,23,35), card=Color3.fromRGB(26,31,46), elevated=Color3.fromRGB(38,45,66), accent=Color3.fromRGB(115,101,255), text=Color3.fromRGB(240,243,255), muted=Color3.fromRGB(140,152,178), line=Color3.fromRGB(48,57,80)},
    {name="Glacier", bg=Color3.fromRGB(8,19,30), side=Color3.fromRGB(13,29,43), card=Color3.fromRGB(18,39,56), elevated=Color3.fromRGB(27,53,72), accent=Color3.fromRGB(30,199,244), text=Color3.fromRGB(239,250,255), muted=Color3.fromRGB(146,181,200), line=Color3.fromRGB(45,80,102)},
    {name="Ember", bg=Color3.fromRGB(21,12,17), side=Color3.fromRGB(29,17,24), card=Color3.fromRGB(43,25,34), elevated=Color3.fromRGB(58,35,44), accent=Color3.fromRGB(255,92,116), text=Color3.fromRGB(255,242,245), muted=Color3.fromRGB(194,154,166), line=Color3.fromRGB(83,48,61)},
    {name="Matrix", bg=Color3.fromRGB(9,19,16), side=Color3.fromRGB(12,29,23), card=Color3.fromRGB(20,42,32), elevated=Color3.fromRGB(28,57,43), accent=Color3.fromRGB(73,224,145), text=Color3.fromRGB(238,255,245), muted=Color3.fromRGB(150,184,166), line=Color3.fromRGB(46,83,63)},
    {name="Pearl", bg=Color3.fromRGB(234,239,248), side=Color3.fromRGB(220,229,242), card=Color3.fromRGB(251,253,255), elevated=Color3.fromRGB(235,241,249), accent=Color3.fromRGB(77,103,235), text=Color3.fromRGB(25,37,55), muted=Color3.fromRGB(101,120,147), line=Color3.fromRGB(190,205,224)},
    {name="Midnight", bg=Color3.fromRGB(5,7,12), side=Color3.fromRGB(10,13,20), card=Color3.fromRGB(16,20,30), elevated=Color3.fromRGB(26,32,46), accent=Color3.fromRGB(90,140,255), text=Color3.fromRGB(235,240,255), muted=Color3.fromRGB(130,142,165), line=Color3.fromRGB(38,46,64)},
    {name="Sunset", bg=Color3.fromRGB(24,13,16), side=Color3.fromRGB(33,18,20), card=Color3.fromRGB(46,26,27), elevated=Color3.fromRGB(62,36,34), accent=Color3.fromRGB(255,138,76), text=Color3.fromRGB(255,244,238), muted=Color3.fromRGB(196,160,148), line=Color3.fromRGB(88,54,46)},
    {name="Rose", bg=Color3.fromRGB(24,12,22), side=Color3.fromRGB(33,17,31), card=Color3.fromRGB(46,25,43), elevated=Color3.fromRGB(62,35,58), accent=Color3.fromRGB(255,110,199), text=Color3.fromRGB(255,242,251), muted=Color3.fromRGB(190,150,182), line=Color3.fromRGB(86,48,80)},
    {name="Mint", bg=Color3.fromRGB(10,22,22), side=Color3.fromRGB(14,31,31), card=Color3.fromRGB(20,43,42), elevated=Color3.fromRGB(29,58,57), accent=Color3.fromRGB(94,234,212), text=Color3.fromRGB(238,255,252), muted=Color3.fromRGB(148,186,182), line=Color3.fromRGB(46,84,82)},
    {name="Amber", bg=Color3.fromRGB(22,18,9), side=Color3.fromRGB(31,25,12), card=Color3.fromRGB(44,36,18), elevated=Color3.fromRGB(60,49,25), accent=Color3.fromRGB(255,196,61), text=Color3.fromRGB(255,250,235), muted=Color3.fromRGB(192,176,140), line=Color3.fromRGB(84,70,38)},
    {name="Violet", bg=Color3.fromRGB(17,11,30), side=Color3.fromRGB(24,16,42), card=Color3.fromRGB(33,23,58), elevated=Color3.fromRGB(46,33,78), accent=Color3.fromRGB(176,124,255), text=Color3.fromRGB(247,242,255), muted=Color3.fromRGB(165,150,196), line=Color3.fromRGB(66,50,104)},
    {name="Crimson", bg=Color3.fromRGB(20,8,10), side=Color3.fromRGB(28,11,14), card=Color3.fromRGB(40,16,19), elevated=Color3.fromRGB(56,23,27), accent=Color3.fromRGB(235,50,60), text=Color3.fromRGB(255,240,240), muted=Color3.fromRGB(190,148,150), line=Color3.fromRGB(80,36,40)},
    {name="Mono", bg=Color3.fromRGB(12,12,12), side=Color3.fromRGB(18,18,18), card=Color3.fromRGB(25,25,25), elevated=Color3.fromRGB(36,36,36), accent=Color3.fromRGB(235,235,235), text=Color3.fromRGB(245,245,245), muted=Color3.fromRGB(140,140,140), line=Color3.fromRGB(52,52,52)},
}
local theme = ThemePresets[1]
local bindings = {}
local conns = {}
local authenticated = true
local aimBusy = false -- true while the aim keybind is being rebound (keeps RightShift from toggling the hub)
local function on(signal, fn) local c = signal:Connect(fn); conns[#conns+1] = c; return c end
local function make(kind, properties, parent)
    local object = Instance.new(kind)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end
local function skin(obj, prop, token)
    obj[prop] = theme[token]
    table.insert(bindings, {obj=obj, prop=prop, token=token})
    return obj
end
local function tint(obj, token, prop)
    return skin(obj, prop or "BackgroundColor3", token)
end
local function setToken(obj, prop, token)
    for _, entry in ipairs(bindings) do
        if entry.obj == obj and entry.prop == prop then entry.token = token end
    end
end
local function rounded(obj, r)
    make("UICorner", {CornerRadius=UDim.new(0,r or 8)},obj)
    return obj
end
local function outline(obj)
    local stroke=make("UIStroke",{Thickness=1, Transparency=.4},obj)
    skin(stroke,"Color","line")
    return stroke
end
local function animate(obj, fields, seconds, style)
    local t=TweenService:Create(obj,TweenInfo.new(seconds or .2,style or Enum.EasingStyle.Quint,Enum.EasingDirection.Out),fields)
    t:Play()
    return t
end
local function label(parent, content, size, bold, color)
    local t=make("TextLabel",{BackgroundTransparency=1,Text=content,TextSize=size or 12,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd},parent)
    skin(t,"TextColor3",color or "text")
    return t
end
local function themedButton(parent, text, accent)
    local b=make("TextButton",{Text=text,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,BorderSizePixel=0},parent)
    tint(b,accent and "accent" or "elevated")
    skin(b,"TextColor3",accent and "bg" or "text")
    rounded(b,6)
    b.MouseEnter:Connect(function() animate(b,{BackgroundTransparency=.16},.16) end)
    b.MouseLeave:Connect(function() animate(b,{BackgroundTransparency=0},.16) end)
    return b
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
local screen=make("ScreenGui",{Name="DecayHubV3",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=60,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},guiParent)
local WIN_W,WIN_H=320,380
local TAB_COUNT=6
screen.Destroying:Connect(function() for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end end)
local window=tint(make("Frame",{Name="Main",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.fromOffset(WIN_W,WIN_H),BorderSizePixel=0,Visible=false,ClipsDescendants=true},screen),"bg")
rounded(window,10); outline(window)
local scale=make("UIScale",{Scale=1},window)
local function resizeScale()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    scale.Scale=math.min(1,math.max(.55, math.min((v.X-26)/WIN_W,(v.Y-48)/WIN_H)))
end
resizeScale()
if workspace.CurrentCamera then on(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),resizeScale) end

tint(make("Frame",{Size=UDim2.new(1,0,0,2),BorderSizePixel=0,ZIndex=3},window),"accent")
local top=make("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1},window)
local dot=tint(make("Frame",{Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(8,8),BorderSizePixel=0},top),"accent");rounded(dot,4)
local brand=label(top,"DECAY HUB",12,true);brand.Position=UDim2.fromOffset(26,0);brand.Size=UDim2.new(1,-90,1,0)
local minimize=themedButton(top,"—");minimize.Size=UDim2.fromOffset(22,18);minimize.Position=UDim2.new(1,-54,0,7)
local xbtn=themedButton(top,"×");xbtn.Size=UDim2.fromOffset(22,18);xbtn.Position=UDim2.new(1,-28,0,7)
local nav=make("Frame",{Position=UDim2.fromOffset(8,32),Size=UDim2.fromOffset(WIN_W-16,22),BackgroundTransparency=1},window)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},nav)
tint(make("Frame",{Position=UDim2.fromOffset(8,57),Size=UDim2.fromOffset(WIN_W-16,1),BorderSizePixel=0},window),"line")
local holder=make("Frame",{Position=UDim2.fromOffset(8,62),Size=UDim2.fromOffset(WIN_W-16,WIN_H-70),BackgroundTransparency=1},window)
local toast=tint(make("Frame",{Position=UDim2.fromOffset(16,WIN_H-34),Size=UDim2.fromOffset(WIN_W-32,24),Visible=false,BorderSizePixel=0,ZIndex=15},window),"elevated");rounded(toast,6);outline(toast)
local toastText=label(toast,"",10,true);toastText.Position=UDim2.fromOffset(10,0);toastText.Size=UDim2.new(1,-20,1,0);toastText.ZIndex=16
local toastCounter=0
local function notify(message)
    toastCounter+=1
    local id=toastCounter
    toastText.Text=message;toast.Visible=true
    task.delay(2.2,function() if toastCounter==id then toast.Visible=false end end)
end

----------------------------------------------------------------------
-- UI components (compact rows, same look as the aimlock window)
----------------------------------------------------------------------
local UI={}; local pages={};local navItems={};local activePage
local function row(parent,h)
    local f=tint(make("Frame",{Size=UDim2.new(1,0,0,h or 28),BorderSizePixel=0},parent),"card")
    rounded(f,6)
    return f
end
function UI.Page(name, glyph, description)
    local button=make("TextButton",{Text=name,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,BorderSizePixel=0,BackgroundTransparency=1,Size=UDim2.new(1/TAB_COUNT,-2,1,0)},nav)
    tint(button,"elevated");skin(button,"TextColor3","muted");rounded(button,6)
    local page=make("ScrollingFrame",{Name=name.."Page",Size=UDim2.new(1,0,1,-38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},holder)
    skin(page,"ScrollBarImageColor3","accent")
    make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},page)
    make("UIPadding",{PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},page)
    pages[name]={page=page}
    navItems[name]=button
    button.MouseButton1Click:Connect(function() UI.Switch(name) end)
    return page
end
function UI.Switch(name)
    if not pages[name] then return end
    activePage=name
    for key,record in pairs(pages) do record.page.Visible=key==name end
    for key,button in pairs(navItems) do
        local chosen=key==name
        setToken(button,"TextColor3",chosen and "accent" or "muted")
        animate(button,{BackgroundTransparency=chosen and 0 or 1,TextColor3=chosen and theme.accent or theme.muted},.18)
    end
    pages[name].page.CanvasPosition=Vector2.zero
end
function UI.Title(parent,text,detail)
    local l=label(parent,string.upper(text),9,true,"muted")
    l.Size=UDim2.new(1,0,0,16)
    return l
end
function UI.Card(parent,title,desc,tag)
    local f=row(parent)
    local a=label(f,title,11,false);a.Position=UDim2.fromOffset(10,0);a.Size=UDim2.new(1,-110,1,0)
    if tag then
        local t=label(f,tag,9,true,"accent");t.Position=UDim2.new(1,-100,0,0);t.Size=UDim2.fromOffset(90,28);t.TextXAlignment=Enum.TextXAlignment.Right
    end
    return f
end
function UI.Toggle(parent,title,desc,onChange,initial)
    local f=row(parent)
    local l=label(f,title,11,false);l.Position=UDim2.fromOffset(10,0);l.Size=UDim2.new(1,-60,1,0)
    local state=false
    local track=tint(make("TextButton",{Position=UDim2.new(1,-42,.5,-8),Size=UDim2.fromOffset(32,16),Text="",AutoButtonColor=false,BorderSizePixel=0},f),"elevated");rounded(track,8)
    local circle=tint(make("Frame",{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(10,10),BorderSizePixel=0},track),"muted");rounded(circle,5)
    local function setState(value)
        state = not not value
        setToken(track,"BackgroundColor3",state and "accent" or "elevated")
        setToken(circle,"BackgroundColor3",state and "bg" or "muted")
        animate(track,{BackgroundColor3=state and theme.accent or theme.elevated},.18)
        animate(circle,{Position=state and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3),BackgroundColor3=state and theme.bg or theme.muted},.18)
        if onChange then onChange(state) end
    end
    track.MouseButton1Click:Connect(function() setState(not state) end)
    if initial then setState(true) end
    return f, setState
end
function UI.Action(parent,title,desc,action,buttonText)
    local f=row(parent)
    local l=label(f,title,11,false);l.Position=UDim2.fromOffset(10,0);l.Size=UDim2.new(1,-90,1,0)
    local b=themedButton(f,buttonText or "RUN",true)
    b.Position=UDim2.new(1,-74,.5,-10);b.Size=UDim2.fromOffset(64,20)
    b.MouseButton1Click:Connect(function() if action then action(b) end end)
    return f,b
end
function UI.ButtonRow(parent,title,valueText,cb)
    local f=row(parent)
    local l=label(f,title,11,false);l.Position=UDim2.fromOffset(10,0);l.Size=UDim2.new(1,-110,1,0)
    local b=themedButton(f,valueText)
    b.Position=UDim2.new(1,-94,.5,-10);b.Size=UDim2.fromOffset(84,20)
    b.MouseButton1Click:Connect(function() cb(b) end)
    return f,b
end
function UI.Dropdown(parent,title,options,selected,callback)
    local idx=table.find(options,selected) or 1
    local _,b=UI.ButtonRow(parent,title,options[idx],function(btn)
        idx=idx%#options+1
        btn.Text=options[idx]
        if callback then callback(options[idx]) end
    end)
    return b
end
function UI.Swatches(parent,title,presets,selected,callback)
    local f=row(parent,40)
    local l=label(f,title.."  ·  "..selected,11,false);l.Position=UDim2.fromOffset(10,3);l.Size=UDim2.new(1,-20,0,14)
    local strip=make("Frame",{Position=UDim2.fromOffset(10,21),Size=UDim2.new(1,-20,0,16),BackgroundTransparency=1},f)
    make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)},strip)
    for _,p in ipairs(presets) do
        local b=make("TextButton",{Text="",Size=UDim2.fromOffset(16,16),BackgroundColor3=p.accent,AutoButtonColor=false,BorderSizePixel=0},strip)
        rounded(b,8)
        make("UIStroke",{Color=p.muted,Thickness=1,Transparency=.5},b)
        b.MouseButton1Click:Connect(function()
            l.Text=title.."  ·  "..p.name
            callback(p.name)
        end)
    end
    return f
end
local sliderDrag=nil
function UI.Slider(parent,name,minV,maxV,initial,suffix,cb,step)
    step=step or 1
    local f=row(parent,36)
    local l=label(f,name,11,false);l.Position=UDim2.fromOffset(10,3);l.Size=UDim2.new(1,-80,0,16)
    local val=label(f,"",10,true,"accent");val.Position=UDim2.new(1,-70,0,3);val.Size=UDim2.fromOffset(60,16);val.TextXAlignment=Enum.TextXAlignment.Right
    local bar=tint(make("Frame",{Position=UDim2.fromOffset(10,26),Size=UDim2.new(1,-20,0,3),BorderSizePixel=0},f),"elevated");rounded(bar,2)
    local fill=tint(make("Frame",{Size=UDim2.fromScale(0,1),BorderSizePixel=0},bar),"accent");rounded(fill,2)
    local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.fromOffset(4,18),Size=UDim2.new(1,-8,0,16)},f)
    local function set(v)
        v=minV+math.floor((v-minV)/step+.5)*step
        v=math.clamp(v,minV,maxV)
        fill.Size=UDim2.fromScale((v-minV)/(maxV-minV),1)
        val.Text=tostring(v)..(suffix or "")
        cb(v)
    end
    local function fromX(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)
        set(minV+(maxV-minV)*rel)
    end
    set(initial)
    hit.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            sliderDrag={fromX=fromX,input=input}
            fromX(input.Position.X)
        end
    end)
    return f
end
on(UIS.InputChanged,function(input)
    if sliderDrag and (input.UserInputType==Enum.UserInputType.MouseMovement or input==sliderDrag.input) then
        sliderDrag.fromX(input.Position.X)
    end
end)
on(UIS.InputEnded,function(input)
    if sliderDrag and (input.UserInputType==Enum.UserInputType.MouseButton1 or input==sliderDrag.input) then
        sliderDrag=nil
    end
end)
-- Kept for the module code: a stepper is just a snapped slider now.
function UI.Stepper(parent, title, minValue, maxValue, step, initialValue, callback)
    return UI.Slider(parent,title,minValue,maxValue,initialValue,"",callback,step)
end
local function statusCard(parent, name, starting)
    local f=row(parent)
    local a=label(f,name,11,false);a.Position=UDim2.fromOffset(10,0);a.Size=UDim2.new(.4,-10,1,0)
    local value=label(f,starting or "—",10,true,"accent")
    value.Position=UDim2.new(.4,0,0,0);value.Size=UDim2.new(.6,-10,1,0);value.TextXAlignment=Enum.TextXAlignment.Right
    return value
end

----------------------------------------------------------------------
-- Pages
----------------------------------------------------------------------
local dashboard=UI.Page("Home")
local visuals=UI.Page("Visuals")
local playersPage=UI.Page("Players")
local utilities=UI.Page("Utility")
local aimPage=UI.Page("Aim")
local settings=UI.Page("Config")

UI.Title(dashboard,"Decay Hub")
UI.Card(dashboard,"Framework","","ONLINE")
UI.Card(dashboard,"Toggle window","","RIGHT SHIFT")
UI.Title(utilities,"Tools")
UI.Action(utilities,"Test notification","",function() notify("Decay Hub is ready ✦") end)

UI.Title(settings,"Appearance")
local function applyTheme(name)
    for _,preset in ipairs(ThemePresets) do if preset.name==name then theme=preset;break end end
    for i=#bindings,1,-1 do
        local entry=bindings[i]
        if entry.obj.Parent==nil then table.remove(bindings,i)
        else entry.obj[entry.prop]=theme[entry.token] end
    end
    notify("Theme: "..name)
end
UI.Swatches(settings,"Color theme",ThemePresets,theme.name,applyTheme)
UI.Toggle(settings,"Status notifications","",function(value) notify("Notifications "..(value and "on" or "off")) end)

-- ================================================================
-- MODULE: ESP (ores, base claims, players/NPCs, monuments)
-- ================================================================
local ESP = {}
ESP.Options = {
    FillTransparency = 0.5,
    ScanInterval = 2,
}
ESP.Ores = {
    Enabled = false, MaxDistance = 500,
    ShowName = true, ShowDistance = true, ShowHighlight = true, ShowTracers = false,
    SelectedOres = {},
    Categories = { Desert = true, Grass = true, Sand = true, Snow = true },
}
ESP.Claims = {
    Enabled = false, MaxDistance = 1500,
    ShowName = true, ShowDistance = true, ShowHighlight = true, ShowTracers = false,
    -- Base ESP: each deployable type has its own toggle + colour.
    Types = { ["Base Claim"] = true, ["Flame Turret"] = true, ["Shotgun Trap"] = true },
}
local BASE_TYPES = {
    {name = "Base Claim",   color = Color3.fromRGB(255, 85, 70)},
    {name = "Flame Turret", color = Color3.fromRGB(255, 150, 40)},
    {name = "Shotgun Trap", color = Color3.fromRGB(190, 110, 255)},
}
local BASE_COLORS = {}
for _, t in ipairs(BASE_TYPES) do BASE_COLORS[t.name] = t.color end
ESP.Players = {
    Enabled = false, MaxDistance = 1500,
    ShowName = true, ShowDistance = true, ShowHealth = true,
    ShowHighlight = true, ShowTracers = false, IncludeNPCs = false,
}
ESP.Monuments = {
    Enabled = false, MaxDistance = 6000,
    ShowName = true, ShowDistance = true, ShowGrid = true, ShowTracers = false,
}
local oreEntries, claimEntries, playerEntries = {}, {}, {}
local monumentEntries = {}
local orePickers = {}
local oreNames = {}
local espActive = true
local overlayGui = make("ScreenGui", {
    Name = "DecayHubWorldOverlays", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 30,
}, guiParent)
local layer = make("Frame", {
    Name = "ESPTracers", Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 0,
}, overlayGui)
local espFolder = make("Folder", {Name = "DecayESPObjects"}, overlayGui)
local function colorForName(name)
    local h = 0
    for i = 1, #name do
        h = (h * 31 + string.byte(name, i)) % 997
    end
    return Color3.fromHSV((h % 360) / 360, 0.72, 1)
end
local function getPart(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst:FindFirstChild("HumanoidRootPart")
            or inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end
local function newEntry(bucket, inst, displayName, color, extra)
    local part = getPart(inst)
    if not part then return nil end
    local highlight = make("Highlight", {
        Name = "DecayHighlight", Adornee = inst,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillColor = color, OutlineColor = Color3.new(1, 1, 1),
        FillTransparency = ESP.Options.FillTransparency,
        OutlineTransparency = 0, Enabled = false,
    }, espFolder)
    local billboard = make("BillboardGui", {
        Name = "DecayBillboard", Adornee = part, AlwaysOnTop = true,
        Size = UDim2.fromOffset(175, 65),
        StudsOffset = Vector3.new(0, 3, 0), Enabled = false,
    }, espFolder)
    local text = make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        TextColor3 = color, TextStrokeTransparency = 0.3,
        Text = displayName, Font = Enum.Font.GothamBold,
        TextSize = 13, TextWrapped = true,
    }, billboard)
    local tracer = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color, BorderSizePixel = 0,
        Size = UDim2.fromOffset(0, 1), Visible = false, ZIndex = 0,
    }, layer)
    local e = { Name = displayName, Part = part, Highlight = highlight,
        Billboard = billboard, Label = text, Tracer = tracer }
    for k, v in pairs(extra or {}) do e[k] = v end
    bucket[inst] = e
    return e
end
local function removeEntry(bucket, inst)
    local e = bucket[inst]
    if not e then return end
    for _, k in ipairs({"Highlight", "Billboard", "Tracer"}) do
        if e[k] then e[k]:Destroy() end
    end
    bucket[inst] = nil
end
local function hideEntry(e)
    e.Highlight.Enabled = false
    e.Billboard.Enabled = false
    e.Tracer.Visible = false
end
local function getOrigin()
    local char = player.Character
    local root = typeof(char) == "Instance" and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    return root and root.Position or (cam and cam.CFrame.Position) or Vector3.zero
end
local function drawTracer(gui, from, to)
    local d = to - from
    gui.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
    gui.Size = UDim2.fromOffset(d.Magnitude, 1)
    gui.Rotation = math.deg(math.atan2(d.Y, d.X))
    gui.Visible = true
end
local function drawEntry(e, active, cfg, origin, screenBottom, cam)
    if not active or not e.Part or not e.Part.Parent then
        hideEntry(e)
        return false
    end
    local dist = (e.Part.Position - origin).Magnitude
    if dist > cfg.MaxDistance then
        hideEntry(e)
        return false
    end
    e.Highlight.Enabled = cfg.ShowHighlight
    e.Highlight.FillTransparency = ESP.Options.FillTransparency
    local showHealth = cfg.ShowHealth and e.Humanoid ~= nil
    e.Billboard.Enabled = cfg.ShowName or cfg.ShowDistance or showHealth
    local contents = {}
    if cfg.ShowName then table.insert(contents, e.Name) end
    if cfg.ShowDistance then table.insert(contents, ("[%d studs]"):format(dist)) end
    if showHealth and e.Humanoid then
        table.insert(contents, ("%d / %d HP"):format(e.Humanoid.Health, e.Humanoid.MaxHealth))
    end
    e.Label.Text = table.concat(contents, "\n")
    if cfg.ShowTracers and cam then
        local p, onScreen = cam:WorldToViewportPoint(e.Part.Position)
        if onScreen then
            drawTracer(e.Tracer, screenBottom, Vector2.new(p.X, p.Y))
        else
            e.Tracer.Visible = false
        end
    else
        e.Tracer.Visible = false
    end
    return true
end
local function addOptions(page, name, cfg)
    UI.Toggle(page, name .. " | Names", "", function(v) cfg.ShowName = v end, cfg.ShowName)
    UI.Toggle(page, name .. " | Distance", "", function(v) cfg.ShowDistance = v end, cfg.ShowDistance)
    if cfg.ShowHealth ~= nil then
        UI.Toggle(page, name .. " | Health", "", function(v) cfg.ShowHealth = v end, cfg.ShowHealth)
    end
    if cfg.ShowHighlight ~= nil then
        UI.Toggle(page, name .. " | Highlights", "", function(v) cfg.ShowHighlight = v end, cfg.ShowHighlight)
    end
    UI.Toggle(page, name .. " | Tracers", "", function(v) cfg.ShowTracers = v end, cfg.ShowTracers)
    UI.Stepper(page, name .. " | Max range", 100, 10000,
        (name == "Monuments" and 500 or 100), cfg.MaxDistance,
        function(v) cfg.MaxDistance = v end)
end

-- ORES UI
UI.Title(visuals, "Ore Finder")
local oreStats = statusCard(visuals, "Ore scanner", "Waiting for OreSpawns")
local _, setOreEnabled = UI.Toggle(visuals, "Ore ESP", "", function(v) ESP.Ores.Enabled = v end)
local oreList = make("Frame", {
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
}, visuals)
make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, oreList)
UI.Title(oreList, "Tracked ore types")
UI.Action(oreList, "Select all detected ores", "", function()
    ESP.Ores.Enabled = true
    setOreEnabled(true)
    for name, setter in pairs(orePickers) do setter(true) end
    notify("All detected ores selected")
end, "ALL")
UI.Action(oreList, "Clear ore selection", "", function()
    for _, setter in pairs(orePickers) do setter(false) end
    notify("Ore selection cleared")
end, "CLEAR")
for _, category in ipairs({"Desert", "Grass", "Sand", "Snow"}) do
    UI.Toggle(visuals, category .. " ores", "", function(v)
        ESP.Ores.Categories[category] = v
    end, true)
end
addOptions(visuals, "Ores", ESP.Ores)

-- CLAIMS + MONUMENTS UI
UI.Title(visuals, "Base ESP")
local claimStats = statusCard(visuals, "Base targets", "0 found")
local _, setClaimEnabled = UI.Toggle(visuals, "Base ESP (master)", "", function(v)
    ESP.Claims.Enabled = v
end)
for _, t in ipairs(BASE_TYPES) do
    UI.Toggle(visuals, t.name .. " ESP", "", function(v)
        ESP.Claims.Types[t.name] = v
    end, true)
end
addOptions(visuals, "Base", ESP.Claims)
UI.Title(visuals, "Monuments")
local monumentStats = statusCard(visuals, "Map data", "Waiting for map")
local _, setMonumentEnabled = UI.Toggle(visuals, "Monument ESP", "", function(v)
    ESP.Monuments.Enabled = v
end)
UI.Toggle(visuals, "Monument grid coordinates", "", function(v)
    ESP.Monuments.ShowGrid = v
end, true)
addOptions(visuals, "Monuments", ESP.Monuments)

-- PLAYERS UI
UI.Title(playersPage, "Player / NPC ESP")
local playerStats = statusCard(playersPage, "Scanner", "0 players / 0 NPCs")
local _, setPlayerEnabled = UI.Toggle(playersPage, "Player ESP", "", function(v)
    ESP.Players.Enabled = v
end)
UI.Toggle(playersPage, "Include NPCs", "", function(v)
    ESP.Players.IncludeNPCs = v
end)
addOptions(playersPage, "Players", ESP.Players)

local totalOres, totalClaims, totalPlayers, totalNPCs = 0, 0, 0, 0
local mapData, mapModule
local mapTryCount = 0
local function gridLetter(n)
    local out = ""
    while n > 0 do
        out = string.char((n - 1) % 26 + 65) .. out
        n = math.floor((n - 1) / 26)
    end
    return out
end
local function worldToGrid(pos)
    if not mapData or not mapData.Bounds or not mapData.Grid then return "?" end
    local b, grid = mapData.Bounds, mapData.Grid
    local x = (pos.X - b.MinX) / math.max(0.001, b.MaxX - b.MinX)
    local z = (pos.Z - b.MinZ) / math.max(0.001, b.MaxZ - b.MinZ)
    local col = math.clamp(math.floor(math.clamp(x, 0, 0.999999) * (grid.Columns or 13)) + 1, 1, grid.Columns or 13)
    local row = math.clamp(math.floor(math.clamp(z, 0, 0.999999) * (grid.Rows or 13)) + 1, 1, grid.Rows or 13)
    return gridLetter(col) .. tostring(row)
end
local function loadMonuments()
    local ok, data = pcall(function()
        local mapGeneration = ReplicatedStorage:FindFirstChild("MapGeneration")
        local mod = mapGeneration and mapGeneration:FindFirstChild("MapImageClient")
        if not mod then return nil end
        mapModule = mapModule or require(mod)
        return mapModule.GetData()
    end)
    if not ok or type(data) ~= "table" or type(data.Monuments) ~= "table" then
        monumentStats.Text = "Map unavailable"
        return false
    end
    mapData = data
    for _, e in ipairs(monumentEntries) do
        e.Label:Destroy()
        e.Tracer:Destroy()
    end
    table.clear(monumentEntries)
    for _, m in ipairs(data.Monuments) do
        if typeof(m.Position) == "Vector3" then
            local labelObj = make("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(210, 52),
                BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(80, 205, 190),
                TextStrokeTransparency = 0.3, Font = Enum.Font.GothamBold,
                TextSize = 13, TextWrapped = true, Visible = false, ZIndex = 0,
            }, layer)
            local tracer = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(80, 205, 190),
                Size = UDim2.fromOffset(0, 1), Visible = false, ZIndex = 0,
            }, layer)
            table.insert(monumentEntries, {
                Name = m.Name or "Monument", Position = m.Position,
                Grid = m.Grid or worldToGrid(m.Position),
                Label = labelObj, Tracer = tracer,
            })
        end
    end
    monumentStats.Text = ("%d monuments"):format(#monumentEntries)
    return true
end
local function scanOres()
    local spawns = workspace:FindFirstChild("OreSpawns")
    local seen, names, count = {}, {}, 0
    if spawns then
        for _, biome in ipairs(spawns:GetChildren()) do
            for _, container in ipairs(biome:GetChildren()) do
                for _, obj in ipairs(container:GetChildren()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        seen[obj] = true
                        count += 1
                        names[obj.Name] = true
                        if not oreEntries[obj] then
                            newEntry(oreEntries, obj, obj.Name, colorForName(obj.Name), {
                                Category = biome.Name,
                            })
                        end
                    end
                end
            end
        end
    end
    for obj in pairs(oreEntries) do
        if not seen[obj] or not obj:IsDescendantOf(workspace) then
            removeEntry(oreEntries, obj)
        end
    end
    local sortedNames = {}
    for name in pairs(names) do
        if not oreNames[name] then
            oreNames[name] = true
            table.insert(sortedNames, name)
        end
    end
    table.sort(sortedNames)
    for _, name in ipairs(sortedNames) do
        local _, setter = UI.Toggle(oreList, "Track " .. name, "", function(value)
            ESP.Ores.SelectedOres[name] = value
        end)
        orePickers[name] = setter
    end
    totalOres = count
    local oreTypeCount = 0
    for _ in pairs(oreNames) do oreTypeCount += 1 end
    oreStats.Text = spawns and ("%d deposits · %d types"):format(count, oreTypeCount)
        or "Waiting for OreSpawns"
end
local function scanClaims()
    local built = workspace:FindFirstChild("PlayerBuiltStructures")
    local deployables = built and built:FindFirstChild("Deployables")
    local seen, count = {}, 0
    local perType = {}
    if deployables then
        for _, obj in ipairs(deployables:GetDescendants()) do
            local color = BASE_COLORS[obj.Name]
            if color and (obj:IsA("Model") or obj:IsA("BasePart")) then
                seen[obj] = true
                count += 1
                perType[obj.Name] = (perType[obj.Name] or 0) + 1
                if not claimEntries[obj] then
                    newEntry(claimEntries, obj, obj.Name, color)
                end
            end
        end
    end
    for obj in pairs(claimEntries) do
        if not seen[obj] or not obj:IsDescendantOf(workspace) then
            removeEntry(claimEntries, obj)
        end
    end
    totalClaims = count
    claimStats.Text = ("%d claims · %d flame · %d shotgun"):format(
        perType["Base Claim"] or 0, perType["Flame Turret"] or 0, perType["Shotgun Trap"] or 0)
end
local function scanPlayers()
    local seen, playerCount, npcCount = {}, 0, 0
    local function include(model)
        if typeof(model) ~= "Instance" or not model:IsA("Model") or model == player.Character then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local owner = Players:GetPlayerFromCharacter(model)
        if not owner and not ESP.Players.IncludeNPCs then return end
        seen[model] = true
        if owner then playerCount += 1 else npcCount += 1 end
        if not playerEntries[model] then
            newEntry(playerEntries, model, owner and owner.DisplayName or model.Name,
                owner and Color3.fromRGB(232, 176, 74) or Color3.fromRGB(120, 170, 255),
                {Humanoid = hum, IsPlayer = owner ~= nil})
        end
    end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then include(other.Character) end
    end
    if ESP.Players.IncludeNPCs then
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("Humanoid") then include(descendant.Parent) end
        end
    end
    for model in pairs(playerEntries) do
        if not seen[model] or not model:IsDescendantOf(workspace) then
            removeEntry(playerEntries, model)
        end
    end
    totalPlayers, totalNPCs = playerCount, npcCount
    playerStats.Text = ("%d players / %d NPCs"):format(playerCount, npcCount)
end
local function scanAll()
    scanOres()
    scanClaims()
    scanPlayers()
end
local overlayConn = RunService.RenderStepped:Connect(function()
    if not espActive or not screen.Parent then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local origin = getOrigin()
    local viewport = cam.ViewportSize
    local bottom = Vector2.new(viewport.X * 0.5, viewport.Y - 4)
    for _, e in pairs(oreEntries) do
        drawEntry(e, ESP.Ores.Enabled and ESP.Ores.SelectedOres[e.Name]
            and ESP.Ores.Categories[e.Category], ESP.Ores, origin, bottom, cam)
    end
    for _, e in pairs(claimEntries) do
        drawEntry(e, ESP.Claims.Enabled and ESP.Claims.Types[e.Name], ESP.Claims, origin, bottom, cam)
    end
    for _, e in pairs(playerEntries) do
        drawEntry(e, ESP.Players.Enabled and e.Humanoid and e.Humanoid.Health > 0
            and (e.IsPlayer or ESP.Players.IncludeNPCs), ESP.Players, origin, bottom, cam)
    end
    for _, m in ipairs(monumentEntries) do
        local d = (m.Position - origin).Magnitude
        if ESP.Monuments.Enabled and d <= ESP.Monuments.MaxDistance then
            local p, visible = cam:WorldToViewportPoint(m.Position)
            if visible then
                local parts = {}
                if ESP.Monuments.ShowName then table.insert(parts, m.Name) end
                if ESP.Monuments.ShowDistance then table.insert(parts, ("%d studs"):format(d)) end
                if ESP.Monuments.ShowGrid then table.insert(parts, tostring(m.Grid)) end
                m.Label.Text = table.concat(parts, "\n")
                m.Label.Position = UDim2.fromOffset(p.X, p.Y)
                m.Label.Visible = #parts > 0
                if ESP.Monuments.ShowTracers then
                    drawTracer(m.Tracer, bottom, Vector2.new(p.X, p.Y))
                else
                    m.Tracer.Visible = false
                end
            else
                m.Label.Visible = false
                m.Tracer.Visible = false
            end
        else
            m.Label.Visible = false
            m.Tracer.Visible = false
        end
    end
end)

-- ESP settings (Config page)
UI.Title(settings, "ESP")
UI.Toggle(settings, "More transparent highlights", "", function(v)
    ESP.Options.FillTransparency = v and 0.8 or 0.5
end)
UI.Stepper(settings, "Ore scan interval (s)", 1, 10, 1, 2, function(v)
    ESP.Options.ScanInterval = v
end)
UI.Action(visuals, "Rescan every ESP target", "", function()
    scanAll()
    loadMonuments()
    notify("ESP scans refreshed")
end, "RESCAN")
UI.Action(visuals, "Reload monument data", "", function()
    notify(loadMonuments() and "Monument data loaded" or "Map data is not ready")
end, "RELOAD")
local dashboardOres = statusCard(dashboard, "Detected ores", "0")
local dashboardTargets = statusCard(dashboard, "World targets", "0 base · 0 players")
UI.Action(dashboard, "Disable all ESP", "", function()
    setOreEnabled(false)
    setClaimEnabled(false)
    setPlayerEnabled(false)
    setMonumentEnabled(false)
    notify("All ESP layers disabled")
end, "OFF")
-- Scanners run while the GUI exists, even when the window is minimized.
task.spawn(function()
    while espActive and screen.Parent do
        local ok, err = pcall(function()
            scanOres()
            scanClaims()
            dashboardOres.Text = tostring(totalOres)
            dashboardTargets.Text = ("%d base · %d players"):format(totalClaims, totalPlayers)
        end)
        if not ok then warn("[DecayHub ESP] scan:", err) end
        task.wait(math.max(1, ESP.Options.ScanInterval))
    end
end)
task.spawn(function()
    while espActive and screen.Parent do
        local ok, err = pcall(scanPlayers)
        if not ok then warn("[DecayHub ESP] player scan:", err) end
        task.wait(1)
    end
end)
task.spawn(function()
    while espActive and screen.Parent and not mapData and mapTryCount < 10 do
        mapTryCount += 1
        if loadMonuments() then break end
        task.wait(8)
    end
end)
function ESP.Disable()
    setOreEnabled(false)
    setClaimEnabled(false)
    setPlayerEnabled(false)
    setMonumentEnabled(false)
end
function ESP.Destroy()
    espActive = false
    overlayConn:Disconnect()
    for inst in pairs(oreEntries) do removeEntry(oreEntries, inst) end
    for inst in pairs(claimEntries) do removeEntry(claimEntries, inst) end
    for inst in pairs(playerEntries) do removeEntry(playerEntries, inst) end
    for _, m in ipairs(monumentEntries) do
        m.Label:Destroy()
        m.Tracer:Destroy()
    end
    table.clear(monumentEntries)
    overlayGui:Destroy()
end

-- ================================================================
-- MODULE: AUTO HARVEST  (Utility tab)
-- ================================================================
do
    local AutoHarvest = {
        Enabled = false,
        Alive = true,
        Firing = false,
        Delay = 0.4,           -- seconds between swings
        RayRange = 30,         -- raycast distance along the swing direction
        FallbackRange = 25,    -- nearest-resource search radius if the raycast misses
        CancelRange = 15,      -- cancel if farther than this from the resource's nearest edge
        MoveCancel = 10,       -- cancel if you move this far from where you started swinging
        MaxSwings = 60,        -- safety cap per resource
    }

    UI.Title(utilities, "Auto Harvest")
    local harvestStatus = statusCard(utilities, "Status", "Idle")
    UI.Toggle(utilities, "Auto Harvest", "", function(v)
        AutoHarvest.Enabled = v
        if not v then harvestStatus.Text = "Idle" end
    end)
    UI.Stepper(utilities, "Swing delay (x0.1s)", 1, 20, 1, math.floor(AutoHarvest.Delay * 10 + 0.5),
        function(v) AutoHarvest.Delay = v / 10 end)
    UI.Stepper(utilities, "Max swings", 10, 200, 10, AutoHarvest.MaxSwings,
        function(v) AutoHarvest.MaxSwings = v end)
    UI.Stepper(utilities, "Cancel range", 5, 40, 5, AutoHarvest.CancelRange,
        function(v) AutoHarvest.CancelRange = v end)

    -- The swing hook runs on the game's thread, which cannot touch CoreGui instances.
    -- So the hook only stores the text; the executor thread applies it to the label.
    local pendingStatus = nil
    local function setStatus(text)
        if AutoHarvest.Alive then pendingStatus = text end
    end
    on(RunService.Heartbeat, function()
        if pendingStatus then
            harvestStatus.Text = pendingStatus
            pendingStatus = nil
        end
    end)

    local function getHealthValue(model)
        local direct = model:FindFirstChild("Health")
        if direct and direct:IsA("ValueBase") then return direct end
        local sys = model:FindFirstChild("System")
        local nested = sys and sys:FindFirstChild("Health")
        if nested and nested:IsA("ValueBase") then return nested end
        return nil
    end

    local function findResourceFromPart(part)
        local current = part
        while current and current ~= workspace do
            if current:IsA("Model") then
                local hv = getHealthValue(current)
                if hv then return current, hv end
            end
            current = current.Parent
        end
        return nil
    end

    local function getRoot()
        local char = player.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function findResource(direction)
        local char = player.Character
        local root = getRoot()
        if not root then return nil end

        if typeof(direction) == "Vector3" and direction.Magnitude > 0 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { char }
            local result = workspace:Raycast(root.Position, direction.Unit * AutoHarvest.RayRange, params)
            if result then
                local model, hv = findResourceFromPart(result.Instance)
                if model then return model, hv end
            end
        end

        local best, bestHV, bestDist
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Health" and obj:IsA("ValueBase") and not obj:IsDescendantOf(char) then
                local model = obj.Parent
                if model and model.Name == "System" then model = model.Parent end
                if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                    local ok, pivot = pcall(function() return model:GetPivot().Position end)
                    if ok then
                        local dist = (pivot - root.Position).Magnitude
                        if dist <= AutoHarvest.FallbackRange and (not bestDist or dist < bestDist) then
                            best, bestHV, bestDist = model, obj, dist
                        end
                    end
                end
            end
        end
        return best, bestHV
    end

    local function distanceTo(model)
        local root = getRoot()
        if not root or not model.Parent then return nil end
        local ok, cf, size = pcall(function() return model:GetBoundingBox() end)
        if not ok then return nil end
        local rel = cf:PointToObjectSpace(root.Position)
        local half = size / 2
        local clamped = Vector3.new(
            math.clamp(rel.X, -half.X, half.X),
            math.clamp(rel.Y, -half.Y, half.Y),
            math.clamp(rel.Z, -half.Z, half.Z)
        )
        return (rel - clamped).Magnitude
    end

    local function safetyCheck(model, startPos)
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local root = getRoot()
        if not humanoid or not root or humanoid.Health <= 0 then
            return "Cancelled: died"
        end
        if (root.Position - startPos).Magnitude > AutoHarvest.MoveCancel then
            return "Cancelled: you moved"
        end
        local dist = distanceTo(model)
        if not dist then return "Resource gone" end
        if dist > AutoHarvest.CancelRange then
            return "Cancelled: out of range"
        end
        return nil, dist
    end

    local toolSystem = ReplicatedStorage:WaitForChild("ToolSystem", 5)
    local remotes = toolSystem and toolSystem:WaitForChild("RemoteEvents", 5)
    local Event = remotes and remotes:WaitForChild("Swing", 5)

    if not Event then
        setStatus("Swing remote not found")
        warn("[DecayHub] Auto Harvest: ToolSystem.RemoteEvents.Swing not found")
    elseif not (hookmetamethod and newcclosure and getnamecallmethod and checkcaller) then
        setStatus("Executor lacks hook support")
        warn("[DecayHub] Auto Harvest: required executor functions missing")
    else
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if AutoHarvest.Alive and AutoHarvest.Enabled and not AutoHarvest.Firing
                and self == Event
                and getnamecallmethod() == "FireServer"
                and not checkcaller() then
                local args = table.pack(...)
                AutoHarvest.Firing = true
                task.spawn(function()
                    local model, hv = findResource(args[1])
                    local root = getRoot()
                    if not model or not root then
                        setStatus("No resource found")
                        AutoHarvest.Firing = false
                        return
                    end
                    local startPos = root.Position
                    local swings = 1
                    local reason = "Done"

                    while AutoHarvest.Alive and AutoHarvest.Enabled do
                        if swings >= AutoHarvest.MaxSwings then
                            reason = "Max swings"
                            break
                        end

                        local cancelled = false
                        local waited = 0
                        while waited < AutoHarvest.Delay and AutoHarvest.Alive and AutoHarvest.Enabled do
                            task.wait(0.1)
                            waited += 0.1
                            local why, dist = safetyCheck(model, startPos)
                            if why then
                                reason = why
                                cancelled = true
                                break
                            end
                            setStatus(("%s: %s HP | %.1f studs"):format(model.Name, tostring(hv.Value), dist))
                        end
                        if cancelled or not (AutoHarvest.Alive and AutoHarvest.Enabled) then break end

                        if not hv.Parent or hv.Value <= 0 then
                            reason = "Harvested"
                            break
                        end

                        Event:FireServer(table.unpack(args, 1, args.n))
                        swings += 1
                    end

                    setStatus(reason .. " (" .. swings .. " swings)")
                    AutoHarvest.Firing = false
                end)
            end
            return oldNamecall(self, ...)
        end))
    end

    screen.Destroying:Connect(function()
        AutoHarvest.Alive = false
        AutoHarvest.Enabled = false
    end)
end

-- ================================================================
-- MODULE: AUTO RESEARCH  (Utility tab)
-- ================================================================
do
    local Research = {
        Alive = true,
        Running = false,
        Delay = 0.5,            -- seconds between research requests
        -- Items to skip per tree. Set an item to true to skip it
        -- (matches the old standalone script: `false` = NOT skipped).
        Skip = {
            [1] = {},
            [2] = { ["Hazmat Suit"] = false },
        },
    }

    local ItemData, Remote

    UI.Title(utilities, "Auto Research")
    local scrapStatus = statusCard(utilities, "Scrap", "Checking...")
    local treeStatus = {
        [1] = statusCard(utilities, "Tech Tree 1", "—"),
        [2] = statusCard(utilities, "Tech Tree 2", "—"),
    }
    local researchStatus = statusCard(utilities, "Research", "Loading...")

    -- Inventory scrap -------------------------------------------------
    local function getScrap()
        local dataFolder = player:FindFirstChild("Data")
        if not dataFolder then return nil end
        local total = 0
        for _, slot in ipairs(dataFolder:GetChildren()) do
            if slot.Name:match("^Slot%d+$") then
                local itemName = slot:FindFirstChild("ItemName")
                local amount = slot:FindFirstChild("Amount")
                if itemName and amount and itemName.Value == "Scrap" then
                    total += amount.Value
                end
            end
        end
        return total
    end

    -- Tech tree data --------------------------------------------------
    local function getItems(tree)
        local result = {}
        local techTree = ItemData and ItemData["TechTree" .. tree]
        if not techTree then return result end
        for _, name in ipairs(techTree) do
            if not Research.Skip[tree][name] then
                table.insert(result, name)
            end
        end
        return result
    end

    local function getCost(tree)
        local total = 0
        for _, name in ipairs(getItems(tree)) do
            local info = ItemData.Items[name]
            if info then total += info.ResearchCost or 0 end
        end
        return total
    end

    local function refresh()
        if not ItemData then return end
        local scrap = getScrap()
        scrapStatus.Text = scrap ~= nil and tostring(scrap) or "Unknown"
        for tree = 1, 2 do
            local cost = getCost(tree)
            local msg
            if scrap == nil then
                msg = ("%d · inventory unknown"):format(cost)
            elseif scrap >= cost then
                msg = ("%d · enough"):format(cost)
            else
                msg = ("%d · need %d more"):format(cost, cost - scrap)
            end
            treeStatus[tree].Text = msg
        end
    end

    -- Research run ----------------------------------------------------
    local function startResearch(tree)
        if not (ItemData and Remote) then
            researchStatus.Text = "Not loaded"
            return
        end
        if Research.Running then
            researchStatus.Text = "Already researching"
            return
        end
        local scrap = getScrap()
        local cost = getCost(tree)
        if scrap == nil then
            researchStatus.Text = "Can't read Scrap"
            return
        end
        if scrap < cost then
            researchStatus.Text = ("Not enough Scrap (Tree %d)"):format(tree)
            return
        end

        Research.Running = true
        local items = getItems(tree)
        task.spawn(function()
            local stopped = false
            for i, itemName in ipairs(items) do
                if not Research.Running or not Research.Alive then
                    stopped = true
                    break
                end
                researchStatus.Text = ("T%d %d/%d %s"):format(tree, i, #items, itemName)
                local ok, err = pcall(function() Remote:FireServer(tree, itemName) end)
                if not ok then warn("[DecayHub] Research error:", itemName, err) end
                task.wait(Research.Delay)
            end
            if Research.Alive then
                researchStatus.Text = stopped and "Stopped" or "All requests sent"
                Research.Running = false
                pcall(refresh)
            end
        end)
    end

    UI.Action(utilities, "Research Tech Tree 1", "", function() startResearch(1) end, "START")
    UI.Action(utilities, "Research Tech Tree 2", "", function() startResearch(2) end, "START")
    UI.Action(utilities, "Stop research", "", function()
        if Research.Running then
            Research.Running = false
            researchStatus.Text = "Stopping..."
        end
    end, "STOP")
    UI.Stepper(utilities, "Research delay (x0.1s)", 1, 20, 1, math.floor(Research.Delay * 10 + 0.5),
        function(v) Research.Delay = v / 10 end)

    -- Load game modules without blocking the rest of the hub ------------
    task.spawn(function()
        local ok, err = pcall(function()
            local itemModule = ReplicatedStorage:WaitForChild("ItemData", 10)
            local techFolder = ReplicatedStorage:WaitForChild("TechTree", 10)
            local remote = techFolder and techFolder:WaitForChild("TechTreeResearch", 10)
            if not (itemModule and remote) then error("ItemData or TechTreeResearch missing") end
            ItemData = require(itemModule)
            Remote = remote
        end)
        if not ok then
            researchStatus.Text = "Game data not found"
            warn("[DecayHub] Auto Research:", err)
            return
        end
        researchStatus.Text = "Ready"
        while Research.Alive and screen.Parent do
            pcall(refresh)
            task.wait(1)
        end
    end)

    screen.Destroying:Connect(function()
        Research.Alive = false
        Research.Running = false
    end)
end

-- ================================================================
-- MODULE: AIMLOCK + HITBOX EXPANDER  (Aim tab)
-- ================================================================
do
    local Aim = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- default: hold right mouse button
        Mode = "Hold",                         -- "Hold" or "Toggle"
        FOV = 150,
        Smooth = 3,                            -- 1 = instant, higher = slower
        ShowFOV = true,
        TeamCheck = true,
        WallCheck = false,
        MaxDistance = 1000,
        TargetPart = "Head",                   -- "Head" or "HumanoidRootPart"
        Hitbox = false,
        HitboxSize = 8,
        HitboxTransparency = 0.7,
        HitboxPart = "HumanoidRootPart",
    }
    local holding, capturing = false, false
    local restoreHitboxes

    -- FOV circle (lives in the world overlay gui)
    local fovCircle = make("Frame", {
        Name = "AimFOV", AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(Aim.FOV * 2, Aim.FOV * 2),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
    }, overlayGui)
    rounded(fovCircle, 9999)
    local fovStroke = make("UIStroke", {Color = theme.accent, Thickness = 1.5, Transparency = 0.2}, fovCircle)
    local function refreshFOV()
        fovCircle.Size = UDim2.fromOffset(Aim.FOV * 2, Aim.FOV * 2)
    end

    local function keyName() return Aim.Key.Name end

    -- UI ---------------------------------------------------------
    UI.Title(aimPage, "Aimlock")
    local aimStatus = statusCard(aimPage, "Status", "Ready")
    UI.Toggle(aimPage, "Aimlock enabled", "", function(v)
        Aim.Enabled = v
        if not v then holding = false end
    end, Aim.Enabled)
    local _, keyButton = UI.ButtonRow(aimPage, "Keybind", keyName(), function(b)
        capturing = true
        aimBusy = true
        b.Text = "press key..."
    end)
    UI.ButtonRow(aimPage, "Mode", Aim.Mode, function(b)
        Aim.Mode = (Aim.Mode == "Hold") and "Toggle" or "Hold"
        holding = false
        b.Text = Aim.Mode
    end)
    UI.ButtonRow(aimPage, "Target part", "Head", function(b)
        if Aim.TargetPart == "Head" then
            Aim.TargetPart = "HumanoidRootPart"; b.Text = "Body"
        else
            Aim.TargetPart = "Head"; b.Text = "Head"
        end
    end)
    UI.Slider(aimPage, "FOV radius", 20, 600, Aim.FOV, " px", function(v)
        Aim.FOV = v
        refreshFOV()
    end)
    UI.Slider(aimPage, "Smoothness", 1, 20, Aim.Smooth, "", function(v) Aim.Smooth = v end)
    UI.Slider(aimPage, "Max distance", 50, 3000, Aim.MaxDistance, " st", function(v) Aim.MaxDistance = v end, 50)
    UI.Toggle(aimPage, "Show FOV circle", "", function(v) Aim.ShowFOV = v end, Aim.ShowFOV)
    UI.Toggle(aimPage, "Team check", "", function(v) Aim.TeamCheck = v end, Aim.TeamCheck)
    UI.Toggle(aimPage, "Wall check", "", function(v) Aim.WallCheck = v end, Aim.WallCheck)

    UI.Title(aimPage, "Hitbox expander")
    UI.Toggle(aimPage, "Hitbox expander", "", function(v)
        Aim.Hitbox = v
        if not v and restoreHitboxes then restoreHitboxes() end
    end, Aim.Hitbox)
    UI.ButtonRow(aimPage, "Hitbox part", "Body", function(b)
        if restoreHitboxes then restoreHitboxes() end
        if Aim.HitboxPart == "HumanoidRootPart" then
            Aim.HitboxPart = "Head"; b.Text = "Head"
        else
            Aim.HitboxPart = "HumanoidRootPart"; b.Text = "Body"
        end
    end)
    UI.Slider(aimPage, "Hitbox size", 2, 30, Aim.HitboxSize, " st", function(v) Aim.HitboxSize = v end)
    UI.Slider(aimPage, "Hitbox transparency", 0, 100, math.floor(Aim.HitboxTransparency * 100), "%", function(v)
        Aim.HitboxTransparency = v / 100
    end)

    -- Keybind handling -------------------------------------------
    local function matches(input)
        if Aim.Key.EnumType == Enum.KeyCode then
            return input.KeyCode == Aim.Key
        end
        return input.UserInputType == Aim.Key
    end
    local function finishCapture()
        capturing = false
        holding = false
        keyButton.Text = keyName()
        task.defer(function() aimBusy = false end)
    end

    on(UIS.InputBegan, function(input, processed)
        if capturing then
            if input.KeyCode == Enum.KeyCode.Escape then
                finishCapture()
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Aim.Key = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                Aim.Key = input.UserInputType
            else
                return -- ignore left click etc. and keep waiting
            end
            finishCapture()
            return
        end
        if processed or not Aim.Enabled or not authenticated then return end
        if matches(input) then
            if Aim.Mode == "Hold" then holding = true else holding = not holding end
        end
    end)
    on(UIS.InputEnded, function(input)
        if Aim.Mode == "Hold" and matches(input) then holding = false end
    end)

    -- Targeting --------------------------------------------------
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local function isVisible(camera, part, char)
        local filter = {char}
        if player.Character then filter[#filter + 1] = player.Character end
        rayParams.FilterDescendantsInstances = filter
        local origin = camera.CFrame.Position
        return workspace:Raycast(origin, part.Position - origin, rayParams) == nil
    end
    local function getTarget(camera)
        local mouse = UIS:GetMouseLocation()
        local best, bestDist, bestName
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local sameTeam = Aim.TeamCheck and p.Team ~= nil and p.Team == player.Team
                local char = p.Character
                if char and not sameTeam then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local part = char:FindFirstChild(Aim.TargetPart) or char:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and part then
                        if (camera.CFrame.Position - part.Position).Magnitude <= Aim.MaxDistance then
                            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local d = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                                if d <= Aim.FOV and (not bestDist or d < bestDist) then
                                    if not Aim.WallCheck or isVisible(camera, part, char) then
                                        best, bestDist, bestName = part, d, p.DisplayName
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best, bestName
    end

    -- Hitbox expander --------------------------------------------
    local originals = {}
    local function restorePart(part)
        local o = originals[part]
        originals[part] = nil
        if o and part.Parent then
            pcall(function()
                part.Size = o.Size
                part.Transparency = o.Transparency
                part.CanCollide = o.CanCollide
                part.Massless = o.Massless
            end)
        end
    end
    restoreHitboxes = function()
        for part in pairs(originals) do restorePart(part) end
    end
    on(RunService.Heartbeat, function()
        if not Aim.Hitbox or not authenticated then
            if next(originals) then restoreHitboxes() end
            return
        end
        local seen = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local sameTeam = Aim.TeamCheck and p.Team ~= nil and p.Team == player.Team
                local char = p.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local part = char and char:FindFirstChild(Aim.HitboxPart)
                if part and part:IsA("BasePart") and hum and hum.Health > 0 and not sameTeam then
                    if not originals[part] then
                        originals[part] = {
                            Size = part.Size, Transparency = part.Transparency,
                            CanCollide = part.CanCollide, Massless = part.Massless,
                        }
                    end
                    local s = Aim.HitboxSize
                    part.Size = Vector3.new(s, s, s)
                    part.Transparency = Aim.HitboxTransparency
                    part.CanCollide = false
                    part.Massless = true
                    seen[part] = true
                end
            end
        end
        for part in pairs(originals) do
            if not seen[part] then restorePart(part) end
        end
    end)

    -- Main loop --------------------------------------------------
    local lastStatus = ""
    local function setStatus(str)
        if str ~= lastStatus then
            lastStatus = str
            aimStatus.Text = str
        end
    end
    RunService:BindToRenderStep("DecayHubAim", Enum.RenderPriority.Camera.Value + 1, function()
        local camera = workspace.CurrentCamera
        if not camera then return end
        if not authenticated then
            holding = false
            fovCircle.Visible = false
            return
        end
        local mouse = UIS:GetMouseLocation()
        fovCircle.Position = UDim2.fromOffset(mouse.X, mouse.Y)
        fovCircle.Visible = Aim.Enabled and Aim.ShowFOV

        if not Aim.Enabled then
            setStatus("Disabled")
            return
        end
        if holding then
            local target, name = getTarget(camera)
            if target then
                local goal = CFrame.new(camera.CFrame.Position, target.Position)
                camera.CFrame = camera.CFrame:Lerp(goal, 1 / math.max(1, Aim.Smooth))
                setStatus("Locked: " .. tostring(name))
                fovStroke.Color = Color3.fromRGB(255, 92, 116)
            else
                setStatus("No target in FOV")
                fovStroke.Color = theme.accent
            end
        else
            setStatus("Ready [" .. keyName() .. "]")
            fovStroke.Color = theme.accent
        end
    end)

    screen.Destroying:Connect(function()
        holding = false
        pcall(function() RunService:UnbindFromRenderStep("DecayHubAim") end)
        restoreHitboxes()
    end)
end

-- ================================================================
-- MODULE: PLAYER RADAR  (draggable; size + range sliders on Config)
-- ================================================================
do
    local Radar = { Enabled = true, Size = 150, Range = 300, Rotate = true }
    local MAX_RANGE = 1000

    local frame = tint(make("Frame", {
        Name = "Radar", AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.new(1, -110, 0, 120),
        Size = UDim2.fromOffset(Radar.Size, Radar.Size),
        BorderSizePixel = 0, BackgroundTransparency = .2,
        Active = true, Visible = false, ZIndex = 5,
    }, overlayGui), "card")
    make("UICorner", {CornerRadius = UDim.new(.5, 0)}, frame)
    skin(make("UIStroke", {Thickness = 1.5, Transparency = .15}, frame), "Color", "accent")

    local ring = make("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromScale(.5, .5), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5}, frame)
    make("UICorner", {CornerRadius = UDim.new(.5, 0)}, ring)
    skin(make("UIStroke", {Thickness = 1, Transparency = .6}, ring), "Color", "line")
    local vLine = tint(make("Frame", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.fromScale(.5, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundTransparency = .65, ZIndex = 5}, frame), "line")
    local hLine = tint(make("Frame", {AnchorPoint = Vector2.new(0, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = .65, ZIndex = 5}, frame), "line")
    local me = tint(make("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, ZIndex = 7}, frame), "accent")
    make("UICorner", {CornerRadius = UDim.new(.5, 0)}, me)
    local rangeLabel = label(frame, "", 8, true, "muted")
    rangeLabel.AnchorPoint = Vector2.new(.5, 1)
    rangeLabel.Position = UDim2.new(.5, 0, 1, -6)
    rangeLabel.Size = UDim2.new(1, -20, 0, 10)
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Center
    rangeLabel.ZIndex = 6

    -- Settings (Config tab)
    UI.Title(settings, "Radar")
    UI.Toggle(settings, "Player radar", "", function(v) Radar.Enabled = v end, Radar.Enabled)
    UI.Toggle(settings, "Rotate with camera", "", function(v) Radar.Rotate = v end, Radar.Rotate)
    UI.Slider(settings, "Radar size", 80, 300, Radar.Size, " px", function(v)
        Radar.Size = v
        frame.Size = UDim2.fromOffset(v, v)
    end, 10)
    UI.Slider(settings, "Radar range", 50, MAX_RANGE, Radar.Range, " st", function(v)
        Radar.Range = v
        rangeLabel.Text = v .. " st"
    end, 50)

    -- Dragging
    local dragging, pointer, startInput, startPos = false, nil, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; pointer = input; startInput = input.Position; startPos = frame.Position
        end
    end)
    on(UIS.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == pointer) then
            local d = input.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    on(UIS.InputEnded, function(input)
        if input == pointer or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false; pointer = nil
        end
    end)

    -- Player dots
    local dots = {}
    local function getDot(p)
        local d = dots[p]
        if d then return d end
        d = make("Frame", {AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, Visible = false, ZIndex = 6}, frame)
        make("UICorner", {CornerRadius = UDim.new(.5, 0)}, d)
        dots[p] = d
        return d
    end
    on(Players.PlayerRemoving, function(p)
        if dots[p] then dots[p]:Destroy(); dots[p] = nil end
    end)

    on(RunService.RenderStepped, function()
        local show = Radar.Enabled and authenticated
        frame.Visible = show
        if not show then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local origin = getOrigin()
        local half = Radar.Size / 2
        local reach = half - 4
        local fwd = Vector3.new(0, 0, -1)
        if Radar.Rotate then
            local look = cam.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 1e-3 then fwd = flat.Unit end
        end
        local right = Vector3.new(-fwd.Z, 0, fwd.X)

        local seen = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char = p.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local rel = root.Position - origin
                    local dx, dy = rel:Dot(right), rel:Dot(fwd)
                    if math.sqrt(dx * dx + dy * dy) <= Radar.Range then
                        local dot = getDot(p)
                        dot.Position = UDim2.fromOffset(half + dx / Radar.Range * reach, half - dy / Radar.Range * reach)
                        local friendly = p.Team ~= nil and p.Team == player.Team
                        dot.BackgroundColor3 = friendly and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(255, 80, 90)
                        dot.Visible = true
                        seen[p] = true
                    end
                end
            end
        end
        for p, dot in pairs(dots) do
            if not seen[p] then dot.Visible = false end
        end
    end)
end

screen.Destroying:Connect(function()
    ESP.Destroy()
end)
-- End merged modules.
UI.Switch("Home")

----------------------------------------------------------------------
-- Mini launcher, drag, login
----------------------------------------------------------------------
local launcher=tint(make("TextButton",{Name="MiniLauncher",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,6),Size=UDim2.fromOffset(110,24),Visible=false,Text="◆  DECAY HUB",Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false,BorderSizePixel=0},screen),"side")
skin(launcher,"TextColor3","text");rounded(launcher,8);outline(launcher)
local function openHub()
    if not authenticated then return end
    window.Visible=true;launcher.Visible=false
    window.Position=UDim2.fromScale(.5,.53)
    window.BackgroundTransparency=.35
    animate(window,{Position=UDim2.fromScale(.5,.5),BackgroundTransparency=0},.26)
    resizeScale()
end
local function minimizeHub()
    if not authenticated then return end
    animate(window,{Position=UDim2.fromScale(.5,.54),BackgroundTransparency=.32},.16)
    task.delay(.17,function()
        if not authenticated then return end
        window.Visible=false;launcher.Visible=true
        launcher.Position=UDim2.new(.5,0,0,-40)
        animate(launcher,{Position=UDim2.new(.5,0,0,6)},.32,Enum.EasingStyle.Back)
    end)
end
minimize.MouseButton1Click:Connect(minimizeHub)
xbtn.MouseButton1Click:Connect(minimizeHub)
launcher.MouseButton1Click:Connect(openHub)

-- Drag: mouse and touch
local dragging=false;local pointer;local origin;local windowOrigin
local function validDrag(input)
    return input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
end
top.InputBegan:Connect(function(input)
    if validDrag(input) then
        dragging=true;pointer=input;origin=input.Position;windowOrigin=window.Position
    end
end)
on(UIS.InputChanged,function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input==pointer then
        local diff=(input.Position-origin)/scale.Scale
        window.Position=UDim2.new(windowOrigin.X.Scale,windowOrigin.X.Offset+diff.X,windowOrigin.Y.Scale,windowOrigin.Y.Offset+diff.Y)
    end
end)
on(UIS.InputEnded,function(input)
    if input==pointer or (pointer and pointer.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then dragging=false;pointer=nil end
end)

local function destroyHub()
    authenticated=false
    screen:Destroy() -- Destroying handlers stop ESP, Auto Harvest, Auto Research, Aimlock, restore hitboxes and disconnect every listener
    print("[DecayHub] UI destroyed")
end

-- Session controls (Config tab)
UI.Title(settings,"Session")
UI.Action(settings,"Reset window position","",function() animate(window,{Position=UDim2.fromScale(.5,.5)},.3) end,"RESET")
local destroyArmed=false
UI.Action(settings,"Destroy UI","",function(btn)
    if not destroyArmed then
        destroyArmed=true;btn.Text="CONFIRM?"
        task.delay(3,function()
            if destroyArmed and btn.Parent then destroyArmed=false;btn.Text="DESTROY" end
        end)
        return
    end
    destroyHub()
end,"DESTROY")

on(UIS.InputBegan,function(input,handled)
    if handled or aimBusy then return end
    if input.KeyCode==Enum.KeyCode.RightShift and authenticated then
        if window.Visible then minimizeHub() else openHub() end
    end
end)
openHub()
notify("Welcome, "..player.DisplayName.." ✦")
print("[DecayHub] V3 minimal ready")