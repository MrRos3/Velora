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
        Smoke = Color3.fromRGB(6, 3, 5),
        Wine = Color3.fromRGB(17, 5, 10),
        WineLift = Color3.fromRGB(31, 7, 17),
        RubyDark = Color3.fromRGB(92, 12, 31),
        Ruby = Color3.fromRGB(198, 38, 68),
        RubyBright = Color3.fromRGB(226, 70, 96),
        Reflection = Color3.fromRGB(236, 172, 194),
        ReflectionSoft = Color3.fromRGB(190, 91, 119),
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
            ColorSequenceKeypoint.new(0, Color3.fromRGB(62, 7, 27)),
            ColorSequenceKeypoint.new(0.24, COLORS.Reflection),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(206, 38, 75)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 5, 22)),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.58),
            NumberSequenceKeypoint.new(0.24, 0.12),
            NumberSequenceKeypoint.new(0.55, 0.46),
            NumberSequenceKeypoint.new(1, 0.75),
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

    local function addPanelReflections(object, inset, transparency)
        local reflection = object:FindFirstChild("VeloraPremiumTopReflection")
        if not reflection then
            reflection = make("Frame", {
                Name = "VeloraPremiumTopReflection",
                Position = UDim2.new(0, inset or 12, 0, 2),
                Size = UDim2.new(1, -(inset or 12) * 2, 0, 1),
                BackgroundColor3 = COLORS.Reflection,
                BackgroundTransparency = transparency or 0.76,
                BorderSizePixel = 0,
                Active = false,
                Selectable = false,
                ZIndex = object.ZIndex + 1,
            }, object)
            make("UICorner", {CornerRadius = UDim.new(1, 0)}, reflection)
            make("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.18, 0.72),
                    NumberSequenceKeypoint.new(0.50, 0.28),
                    NumberSequenceKeypoint.new(0.82, 0.72),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            }, reflection)
        end

        local leftReflection = object:FindFirstChild("VeloraPremiumLeftReflection")
        if not leftReflection then
            leftReflection = make("Frame", {
                Name = "VeloraPremiumLeftReflection",
                Position = UDim2.new(0, 2, 0, inset or 12),
                Size = UDim2.new(0, 1, 1, -(inset or 12) * 2),
                BackgroundColor3 = COLORS.ReflectionSoft,
                BackgroundTransparency = math.min(0.98, (transparency or 0.76) + 0.04),
                BorderSizePixel = 0,
                Active = false,
                Selectable = false,
                ZIndex = object.ZIndex + 1,
            }, object)
            make("UICorner", {CornerRadius = UDim.new(1, 0)}, leftReflection)
            make("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.20, 0.74),
                    NumberSequenceKeypoint.new(0.50, 0.36),
                    NumberSequenceKeypoint.new(0.80, 0.74),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Rotation = 90,
            }, leftReflection)
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
        outer.Transparency = spec.EdgeTransparency or 0.74
        outer.Thickness = spec.EdgeThickness or 1
        ensureEdgeGradient(outer, spec.EdgeRotation or 28)

        local inner = object:FindFirstChild("GlowRim")
        if not inner or not inner:IsA("UIStroke") then
            inner = ensureStroke(object, "VeloraPremiumGlassInnerEdge")
        end
        inner.Color = spec.InnerColor or COLORS.ReflectionSoft
        inner.Transparency = spec.InnerTransparency or 0.84
        inner.Thickness = spec.InnerThickness or 0.75
        inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(inner, (spec.EdgeRotation or 28) + 180)

        local halo = object:FindFirstChild("GlowHalo")
        if halo and halo:IsA("UIStroke") then
            halo.Color = spec.HaloColor or Color3.fromRGB(20, 5, 10)
            halo.Transparency = spec.HaloTransparency or 0.98
            halo.Thickness = spec.HaloThickness or 2.2
        end

        addPanelReflections(object, spec.ReflectionInset, spec.ReflectionTransparency)
    end

    local function styleInset(object, stronger)
        if not object or not object:IsA("GuiObject") then return end
        setSurface(object, {
            BackgroundColor = stronger and Color3.fromRGB(13, 4, 8) or Color3.fromRGB(10, 4, 7),
            BackgroundTransparency = stronger and 0.13 or 0.21,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, stronger and Color3.fromRGB(34, 7, 20) or Color3.fromRGB(21, 7, 15)),
                ColorSequenceKeypoint.new(0.36, Color3.fromRGB(12, 4, 9)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 2, 4)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.30),
                NumberSequenceKeypoint.new(0.52, 0.52),
                NumberSequenceKeypoint.new(1, 0.32),
            }),
            Rotation = 108,
        })

        local edge = findPrimaryStroke(object, "VeloraPremiumInsetEdge", "VeloraPremiumInsetOuter")
        if not edge then edge = ensureStroke(object, "VeloraPremiumInsetEdge") end
        edge.Name = "VeloraPremiumInsetEdge"
        edge.Color = stronger and COLORS.RubyBright or COLORS.ReflectionSoft
        edge.Transparency = stronger and 0.57 or 0.80
        edge.Thickness = stronger and 1.1 or 0.75
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, 34)

        local rim = object:FindFirstChild("GlowRim")
        if rim and rim:IsA("UIStroke") then
            rim.Color = COLORS.ReflectionSoft
            rim.Transparency = stronger and 0.68 or 0.89
            rim.Thickness = 0.8
        end
        local halo = object:FindFirstChild("GlowHalo")
        if halo and halo:IsA("UIStroke") then
            halo.Color = Color3.fromRGB(24, 5, 11)
            halo.Transparency = stronger and 0.92 or 0.98
            halo.Thickness = stronger and 2.4 or 1.8
        end
    end

    local buttonHoverState = setmetatable({}, {__mode = "k"})

    local function styleButton(button, kind)
        if not button or not button:IsA("TextButton") or button.BackgroundTransparency >= 0.90 then return end
        if string.find(button.Name, "VeloraPremium", 1, true) then return end

        local isPlay = kind == "play"
        local isCard = kind == "card"
        local isHeader = kind == "header"
        local isDrawer = kind == "drawer"
        local hasOwnText = button.Text ~= ""

        if isPlay then
            button.BackgroundColor3 = COLORS.Ruby
            button.BackgroundTransparency = 0.03
        elseif isCard then
            button.BackgroundColor3 = Color3.fromRGB(18, 6, 12)
            button.BackgroundTransparency = math.max(button.BackgroundTransparency, 0.24)
        elseif isHeader then
            button.BackgroundColor3 = Color3.fromRGB(16, 5, 10)
            button.BackgroundTransparency = 0.20
        else
            button.BackgroundColor3 = Color3.fromRGB(20, 6, 12)
            button.BackgroundTransparency = isDrawer and 0.22 or 0.20
        end

        -- Icon-only buttons can carry a true glossy surface gradient without
        -- tinting or fading button text.
        if not hasOwnText then
            local surface = ensureGradient(button, "VeloraPremiumButtonSurface")
            if isPlay then
                surface.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 100, 119)),
                    ColorSequenceKeypoint.new(0.30, Color3.fromRGB(207, 43, 72)),
                    ColorSequenceKeypoint.new(0.72, Color3.fromRGB(123, 14, 38)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 7, 20)),
                })
                surface.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.02),
                    NumberSequenceKeypoint.new(0.34, 0.12),
                    NumberSequenceKeypoint.new(1, 0.04),
                })
                surface.Rotation = 118
            else
                surface.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(36, 12, 23)),
                    ColorSequenceKeypoint.new(0.38, Color3.fromRGB(20, 7, 13)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 3, 6)),
                })
                surface.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.28),
                    NumberSequenceKeypoint.new(0.48, 0.48),
                    NumberSequenceKeypoint.new(1, 0.26),
                })
                surface.Rotation = 112
            end
        end

        local edge = findPrimaryStroke(button, "VeloraPremiumButtonEdge", "VeloraPremiumButtonOuter")
        if not edge then edge = ensureStroke(button, "VeloraPremiumButtonEdge") end
        local selectedCard = false
        if isCard then
            selectedCard = button:GetAttribute("VeloraPremiumSelectedCard")
            if selectedCard == nil then
                selectedCard = edge.Transparency <= 0.40
                button:SetAttribute("VeloraPremiumSelectedCard", selectedCard)
            end
        end
        edge.Name = "VeloraPremiumButtonEdge"
        edge.Color = isPlay and COLORS.Reflection or COLORS.ReflectionSoft
        edge.Transparency = isPlay and 0.22
            or (isCard and (selectedCard and 0.36 or 0.85))
            or (isHeader and 0.72)
            or (isDrawer and 0.75)
            or 0.68
        edge.Thickness = isPlay and 1.45 or (isCard and (selectedCard and 1.1 or 0.75) or 0.9)
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, isPlay and 18 or 34)

        local outer
        if isPlay then
            outer = ensureStroke(button, "VeloraPremiumButtonOuter")
            outer.Color = COLORS.RubyBright
            outer.Transparency = 0.74
            outer.Thickness = 4.2
            outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        else
            local oldOuter = button:FindFirstChild("VeloraPremiumButtonOuter")
            if oldOuter and oldOuter:IsA("UIStroke") then oldOuter.Enabled = false end
        end

        local glowRim = button:FindFirstChild("GlowRim")
        if glowRim and glowRim:IsA("UIStroke") then
            glowRim.Color = isPlay and COLORS.Reflection or COLORS.RubyBright
            glowRim.Transparency = isPlay and 0.24 or 0.90
            glowRim.Thickness = isPlay and 1.2 or 0.8
        end
        local glowHalo = button:FindFirstChild("GlowHalo")
        if glowHalo and glowHalo:IsA("UIStroke") then
            glowHalo.Color = COLORS.Ruby
            glowHalo.Transparency = isPlay and 0.80 or 0.98
            glowHalo.Thickness = isPlay and 5 or 1.8
        end

        local hoverTransparency = isPlay and 0.12
            or (isCard and (selectedCard and 0.24 or 0.62))
            or (isHeader and 0.58)
            or (isDrawer and 0.64)
            or 0.54

        local existingHover = buttonHoverState[button]
        if existingHover then
            existingHover.Edge = edge
            existingHover.Outer = outer
            existingHover.EdgeRest = edge.Transparency
            existingHover.OuterRest = outer and outer.Transparency
            existingHover.EdgeHover = hoverTransparency
        else
            buttonHoverState[button] = {
                Edge = edge,
                Outer = outer,
                EdgeRest = edge.Transparency,
                OuterRest = outer and outer.Transparency,
                EdgeHover = hoverTransparency,
            }
            button.MouseEnter:Connect(function()
                local state = buttonHoverState[button]
                if not state or not state.Edge.Parent then return end
                TweenService:Create(state.Edge, TweenInfo.new(0.13), {
                    Transparency = state.EdgeHover,
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
        input.BackgroundColor3 = Color3.fromRGB(14, 4, 9)
        input.BackgroundTransparency = 0.19

        local edge = findPrimaryStroke(input, "VeloraPremiumInputEdge", "VeloraPremiumInputOuter")
        if not edge then edge = ensureStroke(input, "VeloraPremiumInputEdge") end
        edge.Name = "VeloraPremiumInputEdge"
        edge.Color = COLORS.ReflectionSoft
        edge.Transparency = 0.69
        edge.Thickness = 0.9
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ensureEdgeGradient(edge, 26)

        local oldOuter = input:FindFirstChild("VeloraPremiumInputOuter")
        if oldOuter and oldOuter:IsA("UIStroke") then oldOuter.Enabled = false end
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
        BackgroundColor = Color3.fromRGB(2, 1, 3),
        BackgroundTransparency = 0.025,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 3, 10)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(6, 2, 5)),
            ColorSequenceKeypoint.new(0.72, Color3.fromRGB(3, 2, 4)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(1, 1, 2)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.44, 0.28),
            NumberSequenceKeypoint.new(1, 0.09),
        }),
        Rotation = 118,
        EdgeColor = COLORS.RubyDark,
        EdgeTransparency = 0.36,
        EdgeThickness = 2.15,
        InnerTransparency = 0.73,
        InnerThickness = 0.75,
        ReflectionInset = 22,
        ReflectionTransparency = 0.74,
    })

    styleGlassPanel(header, {
        BackgroundColor = Color3.fromRGB(7, 3, 6),
        BackgroundTransparency = 0.13,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 6, 16)),
            ColorSequenceKeypoint.new(0.24, Color3.fromRGB(12, 3, 8)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 2, 4)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.24),
            NumberSequenceKeypoint.new(0.50, 0.44),
            NumberSequenceKeypoint.new(1, 0.25),
        }),
        Rotation = 104,
        EdgeTransparency = 0.66,
        EdgeThickness = 1.1,
        InnerTransparency = 0.78,
        InnerThickness = 0.7,
        HaloTransparency = 0.98,
        HaloThickness = 2,
        ReflectionInset = 15,
        ReflectionTransparency = 0.80,
    })

    local panelSpec = {
        BackgroundColor = Color3.fromRGB(6, 3, 5),
        BackgroundTransparency = 0.17,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 7, 15)),
            ColorSequenceKeypoint.new(0.34, Color3.fromRGB(11, 4, 8)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 2, 4)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.28),
            NumberSequenceKeypoint.new(0.48, 0.50),
            NumberSequenceKeypoint.new(1, 0.30),
        }),
        Rotation = 112,
        EdgeTransparency = 0.72,
        EdgeThickness = 0.9,
        InnerTransparency = 0.82,
        InnerThickness = 0.7,
        HaloTransparency = 0.985,
        HaloThickness = 2,
        ReflectionInset = 13,
        ReflectionTransparency = 0.86,
    }
    styleGlassPanel(nav, panelSpec)
    styleGlassPanel(browser, panelSpec)

    styleGlassPanel(playerCard, {
        BackgroundColor = Color3.fromRGB(8, 3, 6),
        BackgroundTransparency = 0.10,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 7, 20)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(19, 4, 12)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(7, 3, 6)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 2, 4)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.18),
            NumberSequenceKeypoint.new(0.40, 0.38),
            NumberSequenceKeypoint.new(1, 0.22),
        }),
        Rotation = 118,
        EdgeColor = COLORS.Ruby,
        EdgeTransparency = 0.61,
        EdgeThickness = 1.15,
        InnerTransparency = 0.72,
        InnerThickness = 0.8,
        HaloTransparency = 0.96,
        HaloThickness = 2.6,
        ReflectionInset = 14,
        ReflectionTransparency = 0.71,
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
                styleInset(descendant, false)
            end
        end
    end

    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    local drawerScroller = drawer and drawer:FindFirstChildWhichIsA("ScrollingFrame", true)
    if drawer then
        styleGlassPanel(drawer, {
            BackgroundColor = Color3.fromRGB(4, 2, 4),
            BackgroundTransparency = 0.06,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 5, 15)),
                ColorSequenceKeypoint.new(0.30, Color3.fromRGB(10, 3, 7)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 1, 3)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.22),
                NumberSequenceKeypoint.new(0.50, 0.42),
                NumberSequenceKeypoint.new(1, 0.20),
            }),
            Rotation = 112,
            EdgeTransparency = 0.62,
            EdgeThickness = 1.15,
            InnerTransparency = 0.74,
            InnerThickness = 0.8,
            HaloTransparency = 0.96,
            HaloThickness = 2.2,
            ReflectionInset = 17,
            ReflectionTransparency = 0.73,
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
        Version = "0.2.2-test",
        Branch = "glassmorphism-redesign-test",
    }
    return true
end
