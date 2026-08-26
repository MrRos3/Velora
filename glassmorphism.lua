-- Velora premium smoked-glass visual layer.
-- Test branch only. This module changes presentation, never playback or layout.

return function(API)
    assert(type(API) == "table", "Velora glassmorphism expects the Velora API")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    if gui:FindFirstChild("VeloraPremiumGlassMarker") then
        return true
    end

    local window = (API.UI and API.UI.Window) or gui:FindFirstChild("Aurora", true)
    if not window or not window:IsA("GuiObject") then
        return false, "Velora window not found"
    end

    local marker = Instance.new("Folder")
    marker.Name = "VeloraPremiumGlassMarker"
    marker.Parent = gui

    local COLORS = {
        Ink = Color3.fromRGB(4, 3, 4),
        Smoke = Color3.fromRGB(10, 6, 8),
        Wine = Color3.fromRGB(24, 9, 13),
        WineLift = Color3.fromRGB(48, 18, 24),
        RubyDark = Color3.fromRGB(91, 18, 31),
        Ruby = Color3.fromRGB(211, 56, 76),
        RubyBright = Color3.fromRGB(241, 91, 108),
        Reflection = Color3.fromRGB(255, 210, 216),
        ReflectionSoft = Color3.fromRGB(228, 154, 164),
    }

    local function make(className, properties, parent)
        local object = Instance.new(className)
        for key, value in pairs(properties or {}) do
            object[key] = value
        end
        object.Parent = parent
        return object
    end

    local function findParentByLabel(root, wanted)
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Text == wanted then
                return descendant.Parent
            end
        end
        return nil
    end

    local function findIconButton(root, iconName)
        if not root then return nil end
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:GetAttribute("IconName") == iconName then
                local node = descendant
                while node and node ~= root do
                    if node:IsA("TextButton") then return node end
                    node = node.Parent
                end
            end
        end
        return nil
    end

    local function directGradient(object)
        for _, child in ipairs(object:GetChildren()) do
            if child:IsA("UIGradient") then return child end
        end
        return nil
    end

    local function ensureGradient(object, name)
        local gradient = directGradient(object)
        if not gradient then
            gradient = make("UIGradient", {}, object)
        end
        if name then gradient.Name = name end
        return gradient
    end

    local function ensureEdgeGradient(stroke, rotation)
        local gradient = stroke:FindFirstChild("VeloraPremiumEdgeReflection")
        if not gradient then
            gradient = make("UIGradient", {Name = "VeloraPremiumEdgeReflection"}, stroke)
        end
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLORS.RubyDark),
            ColorSequenceKeypoint.new(0.24, COLORS.Reflection),
            ColorSequenceKeypoint.new(0.52, COLORS.RubyBright),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 13, 23)),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.34),
            NumberSequenceKeypoint.new(0.24, 0.02),
            NumberSequenceKeypoint.new(0.55, 0.28),
            NumberSequenceKeypoint.new(1, 0.52),
        })
        gradient.Rotation = rotation or 28
        return gradient
    end

    local function findPrimaryStroke(object, preferredName, excludedName)
        local preferred = object:FindFirstChild(preferredName)
        if preferred and preferred:IsA("UIStroke") then return preferred end
        for _, child in ipairs(object:GetChildren()) do
            if child:IsA("UIStroke")
                and child.Name ~= excludedName
                and child.Name ~= "GlowHalo"
                and child.Name ~= "GlowRim"
                and not string.find(child.Name, "VeloraLabAmbientGlow", 1, true)
            then
                return child
            end
        end
        return nil
    end

    local function ensureStroke(object, name)
        local stroke = object:FindFirstChild(name)
        if stroke and stroke:IsA("UIStroke") then return stroke end
        return make("UIStroke", {
            Name = name,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, object)
    end

    local function setSurface(object, spec)
        object.BackgroundColor3 = spec.BackgroundColor or COLORS.Smoke
        object.BackgroundTransparency = spec.BackgroundTransparency or 0.08

        local gradient = ensureGradient(object, "VeloraPremiumGlassSurface")
        gradient.Color = spec.Color
        gradient.Transparency = spec.Transparency
        gradient.Rotation = spec.Rotation or 112
        return gradient
    end

    local function addTopReflection(object, inset, transparency)
        local reflection = object:FindFirstChild("VeloraPremiumTopReflection")
        if not reflection then
            reflection = make("Frame", {
                Name = "VeloraPremiumTopReflection",
                Position = UDim2.new(0, inset or 12, 0, 2),
                Size = UDim2.new(1, -(inset or 12) * 2, 0, 1),
                BackgroundColor3 = COLORS.Reflection,
                BackgroundTransparency = transparency or 0.28,
                BorderSizePixel = 0,
                Active = false,
                Selectable = false,
                ZIndex = object.ZIndex + 1,
            }, object)
            make("UICorner", {CornerRadius = UDim.new(1, 0)}, reflection)
            make("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.18, 0.58),
                    NumberSequenceKeypoint.new(0.50, 0.06),
                    NumberSequenceKeypoint.new(0.82, 0.58),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            }, reflection)
        end
        return reflection
    end

    local function styleGlassPanel(object, spec)
        if not object or not object:IsA("GuiObject") then return end
        setSurface(object, spec)

        local outer = findPrimaryStroke(object, "VeloraPremiumGlassOuterEdge", "VeloraPremiumGlassInnerEdge")
        if not outer then outer = ensureStroke(object, "VeloraPremiumGlassOuterEdge") end
        outer.Name = "VeloraPremiumGlassOuterEdge"
        outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        outer.Color = spec.EdgeColor or COLORS.Ruby
        outer.Transparency = spec.EdgeTransparency or 0.40
        outer.Thickness = spec.EdgeThickness or 1.65
        ensureEdgeGradient(outer, spec.EdgeRotation or 28)

        local inner = object:FindFirstChild("GlowRim")
        if not inner or not inner:IsA("UIStroke") then
            inner = ensureStroke(object, "VeloraPremiumGlassInnerEdge")
        end
        inner.Color = spec.InnerColor or COLORS.ReflectionSoft
        inner.Transparency = spec.InnerTransparency or 0.58
        inner.Thickness = spec.InnerThickness or 0.9
        inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(inner, (spec.EdgeRotation or 28) + 180)

        local halo = object:FindFirstChild("GlowHalo")
        if halo and halo:IsA("UIStroke") then
            halo.Color = spec.HaloColor or COLORS.RubyDark
            halo.Transparency = spec.HaloTransparency or 0.91
            halo.Thickness = spec.HaloThickness or 3
        end

        addTopReflection(object, spec.ReflectionInset, spec.ReflectionTransparency)
    end

    local function styleInset(object, stronger)
        if not object or not object:IsA("GuiObject") then return end
        setSurface(object, {
            BackgroundColor = stronger and COLORS.Wine or Color3.fromRGB(20, 10, 13),
            BackgroundTransparency = stronger and 0.08 or 0.16,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, stronger and Color3.fromRGB(61, 23, 31) or Color3.fromRGB(47, 24, 29)),
                ColorSequenceKeypoint.new(0.36, Color3.fromRGB(25, 11, 15)),
                ColorSequenceKeypoint.new(1, COLORS.Smoke),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.16),
                NumberSequenceKeypoint.new(0.52, 0.38),
                NumberSequenceKeypoint.new(1, 0.18),
            }),
            Rotation = 108,
        })

        local edge = findPrimaryStroke(object, "VeloraPremiumInsetEdge", "VeloraPremiumInsetOuter")
        if not edge then edge = ensureStroke(object, "VeloraPremiumInsetEdge") end
        edge.Name = "VeloraPremiumInsetEdge"
        edge.Color = stronger and COLORS.RubyBright or COLORS.ReflectionSoft
        edge.Transparency = stronger and 0.33 or 0.52
        edge.Thickness = stronger and 1.25 or 1
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, 34)
    end

    local buttonHoverState = setmetatable({}, {__mode = "k"})

    local function styleButton(button, kind)
        if not button or not button:IsA("TextButton") or button.BackgroundTransparency >= 0.90 then return end
        if string.find(button.Name, "VeloraPremium", 1, true) then return end

        local isPlay = kind == "play"
        local isCard = kind == "card"
        local isHeader = kind == "header"
        local hasOwnText = button.Text ~= ""

        if isPlay then
            button.BackgroundColor3 = COLORS.Ruby
            button.BackgroundTransparency = 0.02
        elseif isCard then
            button.BackgroundColor3 = Color3.fromRGB(27, 12, 16)
            button.BackgroundTransparency = math.min(button.BackgroundTransparency, 0.14)
        elseif isHeader then
            button.BackgroundColor3 = Color3.fromRGB(23, 10, 13)
            button.BackgroundTransparency = 0.12
        else
            button.BackgroundColor3 = Color3.fromRGB(29, 12, 17)
            button.BackgroundTransparency = math.min(button.BackgroundTransparency, 0.16)
        end

        -- Icon-only buttons can carry a true glossy surface gradient without
        -- tinting or fading button text.
        if not hasOwnText then
            local surface = ensureGradient(button, "VeloraPremiumButtonSurface")
            if isPlay then
                surface.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 119, 132)),
                    ColorSequenceKeypoint.new(0.30, Color3.fromRGB(226, 58, 79)),
                    ColorSequenceKeypoint.new(0.72, Color3.fromRGB(139, 22, 41)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(69, 10, 22)),
                })
                surface.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.02),
                    NumberSequenceKeypoint.new(0.34, 0.12),
                    NumberSequenceKeypoint.new(1, 0.04),
                })
                surface.Rotation = 118
            else
                surface.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 31, 38)),
                    ColorSequenceKeypoint.new(0.38, Color3.fromRGB(33, 15, 20)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 7, 9)),
                })
                surface.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.16),
                    NumberSequenceKeypoint.new(0.48, 0.36),
                    NumberSequenceKeypoint.new(1, 0.16),
                })
                surface.Rotation = 112
            end
        end

        local edge = findPrimaryStroke(button, "VeloraPremiumButtonEdge", "VeloraPremiumButtonOuter")
        if not edge then edge = ensureStroke(button, "VeloraPremiumButtonEdge") end
        edge.Name = "VeloraPremiumButtonEdge"
        edge.Color = isPlay and COLORS.Reflection or COLORS.ReflectionSoft
        edge.Transparency = isPlay and 0.17 or (isCard and math.min(edge.Transparency, 0.50) or 0.43)
        edge.Thickness = isPlay and 1.55 or (isCard and 1 or 1.2)
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, isPlay and 18 or 34)

        local outer
        if not isCard then
            outer = ensureStroke(button, "VeloraPremiumButtonOuter")
            outer.Color = isPlay and COLORS.RubyBright or COLORS.RubyDark
            outer.Transparency = isPlay and 0.70 or 0.86
            outer.Thickness = isPlay and 4.4 or 2.2
            outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        local glowRim = button:FindFirstChild("GlowRim")
        if glowRim and glowRim:IsA("UIStroke") then
            glowRim.Color = isPlay and COLORS.Reflection or COLORS.RubyBright
            glowRim.Transparency = isPlay and 0.16 or 0.62
            glowRim.Thickness = isPlay and 1.25 or 1
        end
        local glowHalo = button:FindFirstChild("GlowHalo")
        if glowHalo and glowHalo:IsA("UIStroke") then
            glowHalo.Color = COLORS.Ruby
            glowHalo.Transparency = isPlay and 0.76 or 0.93
            glowHalo.Thickness = isPlay and 5.2 or 2.8
        end

        local existingHover = buttonHoverState[button]
        if existingHover then
            existingHover.Edge = edge
            existingHover.Outer = outer
            existingHover.EdgeRest = edge.Transparency
            existingHover.OuterRest = outer and outer.Transparency
        else
            buttonHoverState[button] = {
                Edge = edge,
                Outer = outer,
                EdgeRest = edge.Transparency,
                OuterRest = outer and outer.Transparency,
            }
            button.MouseEnter:Connect(function()
                local state = buttonHoverState[button]
                if not state or not state.Edge.Parent then return end
                TweenService:Create(state.Edge, TweenInfo.new(0.13), {
                    Transparency = math.max(0.10, state.EdgeRest - 0.18),
                }):Play()
                if state.Outer and state.Outer.Parent then
                    TweenService:Create(state.Outer, TweenInfo.new(0.13), {
                        Transparency = math.max(0.58, state.OuterRest - 0.11),
                    }):Play()
                end
            end)
            button.MouseLeave:Connect(function()
                local state = buttonHoverState[button]
                if not state or not state.Edge.Parent then return end
                TweenService:Create(state.Edge, TweenInfo.new(0.18), {Transparency = state.EdgeRest}):Play()
                if state.Outer and state.Outer.Parent then
                    TweenService:Create(state.Outer, TweenInfo.new(0.18), {Transparency = state.OuterRest}):Play()
                end
            end)
        end
    end

    local function styleInput(input)
        if not input or not input:IsA("TextBox") or input.BackgroundTransparency >= 0.90 then return end
        input.BackgroundColor3 = Color3.fromRGB(21, 9, 13)
        input.BackgroundTransparency = 0.13

        local edge = findPrimaryStroke(input, "VeloraPremiumInputEdge", "VeloraPremiumInputOuter")
        if not edge then edge = ensureStroke(input, "VeloraPremiumInputEdge") end
        edge.Name = "VeloraPremiumInputEdge"
        edge.Color = COLORS.ReflectionSoft
        edge.Transparency = 0.38
        edge.Thickness = 1.25
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, 26)

        local outer = ensureStroke(input, "VeloraPremiumInputOuter")
        outer.Color = COLORS.RubyDark
        outer.Transparency = 0.86
        outer.Thickness = 2.3
        outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end

    local header = findParentByLabel(gui, "VELORA")
    local playerCard = findParentByLabel(gui, "NOW PLAYING")
    if not header or not playerCard then
        marker:Destroy()
        return false, "Velora primary panels not found"
    end

    local nav = findParentByLabel(gui, "DISCOVER")
    local searchBox
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextBox") and string.find(descendant.PlaceholderText or "", "Search", 1, true) then
            searchBox = descendant
            break
        end
    end
    local browser = searchBox and searchBox.Parent

    styleGlassPanel(window, {
        BackgroundColor = COLORS.Ink,
        BackgroundTransparency = 0.035,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 15, 21)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(16, 7, 10)),
            ColorSequenceKeypoint.new(0.72, Color3.fromRGB(7, 4, 5)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 2, 3)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.08),
            NumberSequenceKeypoint.new(0.44, 0.24),
            NumberSequenceKeypoint.new(1, 0.04),
        }),
        Rotation = 116,
        EdgeColor = COLORS.RubyDark,
        EdgeTransparency = 0.31,
        EdgeThickness = 2.25,
        InnerTransparency = 0.47,
        InnerThickness = 0.85,
        ReflectionInset = 22,
        ReflectionTransparency = 0.42,
    })

    styleGlassPanel(header, {
        BackgroundColor = Color3.fromRGB(15, 7, 10),
        BackgroundTransparency = 0.10,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(61, 23, 31)),
            ColorSequenceKeypoint.new(0.24, Color3.fromRGB(31, 12, 17)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 8)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.13),
            NumberSequenceKeypoint.new(0.50, 0.35),
            NumberSequenceKeypoint.new(1, 0.17),
        }),
        Rotation = 104,
        EdgeTransparency = 0.36,
        EdgeThickness = 1.7,
        InnerTransparency = 0.50,
        HaloTransparency = 0.91,
        ReflectionInset = 15,
        ReflectionTransparency = 0.36,
    })

    local panelSpec = {
        BackgroundColor = Color3.fromRGB(12, 7, 9),
        BackgroundTransparency = 0.12,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 23, 29)),
            ColorSequenceKeypoint.new(0.34, Color3.fromRGB(23, 11, 15)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 5, 6)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.18),
            NumberSequenceKeypoint.new(0.48, 0.40),
            NumberSequenceKeypoint.new(1, 0.20),
        }),
        Rotation = 112,
        EdgeTransparency = 0.42,
        EdgeThickness = 1.55,
        InnerTransparency = 0.58,
        InnerThickness = 0.85,
        HaloTransparency = 0.93,
        HaloThickness = 2.7,
        ReflectionInset = 13,
        ReflectionTransparency = 0.47,
    }
    styleGlassPanel(nav, panelSpec)
    styleGlassPanel(browser, panelSpec)

    styleGlassPanel(playerCard, {
        BackgroundColor = Color3.fromRGB(16, 7, 11),
        BackgroundTransparency = 0.075,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(73, 25, 35)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(38, 12, 19)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(17, 8, 11)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 4, 6)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.10),
            NumberSequenceKeypoint.new(0.40, 0.31),
            NumberSequenceKeypoint.new(1, 0.13),
        }),
        Rotation = 118,
        EdgeColor = COLORS.Ruby,
        EdgeTransparency = 0.30,
        EdgeThickness = 1.85,
        InnerTransparency = 0.40,
        InnerThickness = 1.05,
        HaloTransparency = 0.89,
        HaloThickness = 3.2,
        ReflectionInset = 14,
        ReflectionTransparency = 0.30,
    })

    styleInput(searchBox)

    for _, root in ipairs({header, playerCard}) do
        if root then
            for _, descendant in ipairs(root:GetDescendants()) do
                if descendant:IsA("TextButton") and descendant.BackgroundTransparency < 0.90 then
                    local kind = root == header and "header" or "main"
                    styleButton(descendant, kind)
                end
            end
        end
    end

    local playButton = findIconButton(playerCard, "play")
    styleButton(playButton, "play")

    -- Give the artwork, status badges, progress track, tempo pill and library
    -- count their own inset-glass depth without adding bright neon outlines.
    for _, descendant in ipairs(playerCard:GetChildren()) do
        if descendant:IsA("Frame") and descendant.BackgroundTransparency < 0.90 then
            local width = descendant.Size.X.Offset
            local height = descendant.Size.Y.Offset
            if (width == 72 and height == 72)
                or (height == 20)
                or (width == 206 and height == 8)
                or (width == 128 and height == 38)
            then
                styleInset(descendant, width == 72)
            end
        end
    end

    if nav then
        for _, descendant in ipairs(nav:GetDescendants()) do
            if descendant:IsA("Frame") and descendant.BackgroundTransparency < 0.90
                and descendant.Size.Y.Offset >= 45 and descendant.Size.Y.Offset <= 58
            then
                styleInset(descendant, true)
            end
        end
    end

    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    local drawerScroller = drawer and drawer:FindFirstChildWhichIsA("ScrollingFrame", true)
    if drawer then
        styleGlassPanel(drawer, {
            BackgroundColor = Color3.fromRGB(8, 4, 6),
            BackgroundTransparency = 0.035,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 18, 27)),
                ColorSequenceKeypoint.new(0.30, Color3.fromRGB(21, 8, 12)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 3, 4)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.12),
                NumberSequenceKeypoint.new(0.50, 0.30),
                NumberSequenceKeypoint.new(1, 0.10),
            }),
            Rotation = 112,
            EdgeTransparency = 0.27,
            EdgeThickness = 1.8,
            InnerTransparency = 0.42,
            HaloTransparency = 0.88,
            ReflectionInset = 17,
            ReflectionTransparency = 0.34,
        })

        for _, descendant in ipairs(drawer:GetDescendants()) do
            if descendant:IsA("TextButton") and descendant.BackgroundTransparency < 0.90 then
                styleButton(descendant, "drawer")
            elseif descendant:IsA("TextBox") and descendant.BackgroundTransparency < 0.90 then
                styleInput(descendant)
            elseif descendant:IsA("Frame") and descendant.Parent == drawerScroller then
                styleInset(descendant, false)
            end
        end
    end

    local navList
    if nav then
        for _, descendant in ipairs(nav:GetDescendants()) do
            if descendant:IsA("ScrollingFrame") then navList = descendant; break end
        end
    end
    local songList
    if browser then
        for _, descendant in ipairs(browser:GetDescendants()) do
            if descendant:IsA("ScrollingFrame") then songList = descendant; break end
        end
    end

    local function styleDynamic(object)
        if not object or not object.Parent or string.find(object.Name, "VeloraPremium", 1, true) then return end
        if object:IsA("TextButton") then
            if object.Parent == navList or object.Parent == songList then
                styleButton(object, "card")
            elseif drawer and object:IsDescendantOf(drawer) then
                styleButton(object, "drawer")
            end
        elseif object:IsA("TextBox") and drawer and object:IsDescendantOf(drawer) then
            styleInput(object)
        elseif object:IsA("Frame") and drawerScroller and object.Parent == drawerScroller then
            styleInset(object, false)
        end
    end

    if navList then
        for _, child in ipairs(navList:GetChildren()) do styleDynamic(child) end
    end
    if songList then
        for _, child in ipairs(songList:GetChildren()) do styleDynamic(child) end
    end

    local descendantConnection = gui.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("GuiObject") then
            task.defer(function() styleDynamic(descendant) end)
        end
    end)

    -- Wave 2 owns the user-facing glow/performance settings. This final pass
    -- infers that chosen intensity from Wave 2's values, then applies the
    -- stronger profile so the bloom stays elegant and integrated with the glass.
    local innerGlow = playerCard:FindFirstChild("VeloraLabAmbientGlowInner")
    local outerGlow = playerCard:FindFirstChild("VeloraLabAmbientGlowOuter")
    local noteKick = 0
    local noteConnection
    if API.NotePlayed then
        noteConnection = API.NotePlayed:Connect(function() noteKick = 1 end)
    end

    local function snapshot()
        local ok, snap = pcall(function() return API:GetSnapshot() end)
        return ok and type(snap) == "table" and snap or {}
    end

    local glowConnection
    if innerGlow and outerGlow and innerGlow:IsA("UIStroke") and outerGlow:IsA("UIStroke") then
        innerGlow.Color = COLORS.RubyBright
        outerGlow.Color = COLORS.Ruby

        glowConnection = RunService.RenderStepped:Connect(function(dt)
            if not innerGlow.Parent or not outerGlow.Parent then return end
            noteKick = math.max(0, noteKick - dt * 4.2)
            if not innerGlow.Enabled or not outerGlow.Enabled then return end

            local snap = snapshot()
            local breath = (math.sin(os.clock() * 2.8) + 1) * 0.5
            local oldInnerBase
            local targetInnerTransparency
            local targetOuterTransparency
            local targetInnerThickness
            local targetOuterThickness

            if snap.Playing and not snap.Paused then
                oldInnerBase = 0.44 - breath * 0.13
                targetInnerTransparency = math.clamp(0.30 - breath * 0.08 - noteKick * 0.08, 0.12, 0.32)
                targetOuterTransparency = math.clamp(0.62 - breath * 0.10 - noteKick * 0.10, 0.42, 0.64)
                targetInnerThickness = 1.70 + breath * 0.25 + noteKick * 0.20
                targetOuterThickness = 3.20 + breath * 0.60 + noteKick * 0.50
            elseif snap.Playing and snap.Paused then
                oldInnerBase = 0.66
                targetInnerTransparency = 0.58
                targetOuterTransparency = 0.80
                targetInnerThickness = 1.45
                targetOuterThickness = 2.70
            else
                oldInnerBase = 0.92
                targetInnerTransparency = 0.94
                targetOuterTransparency = 0.98
                targetInnerThickness = 1.0
                targetOuterThickness = 1.70
            end

            local intensity = math.clamp(
                (1 - innerGlow.Transparency) / math.max(0.001, 1 - oldInnerBase),
                0,
                1
            )
            innerGlow.Transparency = 1 - (1 - targetInnerTransparency) * intensity
            outerGlow.Transparency = 1 - (1 - targetOuterTransparency) * intensity
            innerGlow.Thickness = 1 + (targetInnerThickness - 1) * intensity
            outerGlow.Thickness = 1 + (targetOuterThickness - 1) * intensity
        end)
    end

    local ancestryConnection
    ancestryConnection = gui.AncestryChanged:Connect(function(_, parent)
        if parent ~= nil then return end
        if descendantConnection then descendantConnection:Disconnect() end
        if glowConnection then glowConnection:Disconnect() end
        if noteConnection then noteConnection:Disconnect() end
        if ancestryConnection then ancestryConnection:Disconnect() end
    end)

    API.PremiumGlass = {
        Version = "0.1.0-test",
        Branch = "glassmorphism-redesign-test",
    }
    return true
end
