-- Velora Nova runtime source patches.
-- Keeps the public loader lightweight while hotfixing the current release source.

local function replaceOnce(source, oldText, newText, name)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        warn("[Velora patch] Could not apply " .. tostring(name or "patch"))
        return source
    end
    return source:sub(1, first - 1) .. newText .. source:sub(last + 1)
end

local function replaceAll(source, oldText, newText)
    local cursor = 1
    local pieces = {}
    local changed = false

    while true do
        local first, last = string.find(source, oldText, cursor, true)
        if not first then
            table.insert(pieces, source:sub(cursor))
            break
        end

        changed = true
        table.insert(pieces, source:sub(cursor, first - 1))
        table.insert(pieces, newText)
        cursor = last + 1
    end

    return changed and table.concat(pieces) or source
end

return function(source)
    assert(type(source) == "string", "Velora patcher expects release source text")

    -- Hotfix version marker.
    source = replaceOnce(source, 'Velora v0.10.18 "Nova"', 'Velora v0.10.20 "Nova"', "version header")
    source = replaceOnce(source, 'Version = "0.10.18"', 'Version = "0.10.20"', "runtime version")

    -- Remove legacy violet/purple UI remnants.
    source = replaceAll(source, "Color3.fromRGB(101,92,145)", "Color3.fromRGB(118,58,65)")
    source = replaceAll(source, "Color3.fromRGB(143,108,255)", "Color3.fromRGB(211,76,90)")
    source = replaceAll(source, "Color3.fromRGB(88,81,119)", "Color3.fromRGB(118,58,65)")
    source = replaceAll(source, "Color3.fromRGB(106,88,153)", "Color3.fromRGB(126,58,67)")
    source = replaceAll(source, "Color3.fromRGB(73,57,111)", "P.Card")
    source = replaceAll(source, "Color3.fromRGB(27,25,40)", "P.Card")

    -- Make Settings + Minimize use the same glass-border construction as Close.
    source = replaceOnce(source,
        'local settingsButton=radius(edge(make("TextButton",{Position=UDim2.new(1,-98,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),Color3.fromRGB(118,58,65),.58),12)',
        'local settingsButton=radius(make("TextButton",{Position=UDim2.new(1,-98,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),12)',
        "settings border")
    source = replaceOnce(source,
        'nova.minimizeButton=radius(edge(make("TextButton",{Position=UDim2.new(1,-144,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),Color3.fromRGB(118,58,65),.58),12)',
        'nova.minimizeButton=radius(make("TextButton",{Position=UDim2.new(1,-144,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),12)',
        "minimize border")

    -- Compact mode: hide library immediately so it never bleeds through while shrinking.
    source = replaceOnce(source,
        '    nova.nav.Visible=true\n    nova.browser.Visible=true\n\n    if enabled then\n',
        '    if enabled then\n        nova.nav.Visible=false\n        nova.browser.Visible=false\n',
        "compact pre-hide")

    source = replaceOnce(source,
        '        task.delay(.39,function()\n            if transition==nova.compactTransition then\n                nova.nav.Visible=false\n                nova.browser.Visible=false\n            end\n        end)\n',
        '',
        "compact late-hide removal")

    -- Keep VELORA visible in compact mode and tuck it neatly beside the logo.
    source = replaceOnce(source,
        '        animate(nova.brandTitle,{TextTransparency=1},.16)\n        animate(nova.brandSubtitle,{TextTransparency=1},.16)\n        animate(settingsButton,{BackgroundTransparency=1},.16)\n',
        '        nova.brandTitle.Visible=true\n        nova.brandTitle.TextSize=17\n        animate(nova.brandTitle,{Position=UDim2.fromOffset(62,20),Size=UDim2.fromOffset(78,22),TextTransparency=0},.24)\n        animate(nova.brandSubtitle,{TextTransparency=1},.12)\n        animate(settingsButton,{BackgroundTransparency=1},.14)\n',
        "compact title")

    source = replaceOnce(source,
        '                nova.brandTitle.Visible=false\n                nova.brandSubtitle.Visible=false\n                settingsButton.Visible=false\n',
        '                nova.brandSubtitle.Visible=false\n                settingsButton.Visible=false\n',
        "compact title persistence")

    -- Restore mode: expand the shell first, then softly reveal the library/browser.
    source = replaceOnce(source,
        '        nova.navScale.Scale=.985\n        nova.browserScale.Scale=.985\n        nova.brandTitle.Visible=true\n        nova.brandSubtitle.Visible=true\n        settingsButton.Visible=true\n        nova.brandTitle.TextTransparency=1\n',
        '        nova.navScale.Scale=.94\n        nova.browserScale.Scale=.94\n        nova.nav.Visible=false\n        nova.browser.Visible=false\n        nova.brandTitle.Visible=true\n        nova.brandSubtitle.Visible=true\n        settingsButton.Visible=true\n        nova.brandTitle.TextSize=20\n        nova.brandTitle.TextTransparency=0\n        animate(nova.brandTitle,{Position=UDim2.fromOffset(68,10),Size=UDim2.fromOffset(190,24),TextTransparency=0},.24)\n',
        "restore staging")

    source = replaceOnce(source,
        '        animate(nova.playerCard,{Position=UDim2.fromOffset(494,0)},.40)\n        animate(nova.navScale,{Scale=1},.32)\n        animate(nova.browserScale,{Scale=1},.32)\n        animate(nova.minimizeButton,{Position=UDim2.new(1,-144,0,14)},.34)\n',
        '        animate(nova.playerCard,{Position=UDim2.fromOffset(494,0)},.40)\n        animate(nova.minimizeButton,{Position=UDim2.new(1,-144,0,14)},.34)\n        task.delay(.08,function()\n            if transition==nova.compactTransition then\n                nova.nav.Visible=true\n                nova.browser.Visible=true\n                animate(nova.navScale,{Scale=1},.24)\n                animate(nova.browserScale,{Scale=1},.24)\n            end\n        end)\n',
        "restore reveal")

    source = replaceOnce(source,
        '        task.delay(.06,function()\n            if transition==nova.compactTransition then\n                animate(nova.brandTitle,{TextTransparency=0},.22)\n                animate(nova.brandSubtitle,{TextTransparency=0},.22)\n                animate(settingsButton,{BackgroundTransparency=.16},.22)\n',
        '        task.delay(.12,function()\n            if transition==nova.compactTransition then\n                animate(nova.brandSubtitle,{TextTransparency=0},.22)\n                animate(settingsButton,{BackgroundTransparency=.16},.22)\n',
        "restore header reveal")

    -- Give Loop a visible crimson rim + soft halo.
    source = replaceOnce(source,
        'nova.loop=radius(edge(make("TextButton",{Position=UDim2.fromOffset(154,232),Size=UDim2.fromOffset(68,38),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),P.Violet,.76,1),13)\nnova.loopBorder=nova.loop:FindFirstChildOfClass("UIStroke")\n',
        'nova.loop=radius(edge(make("TextButton",{Position=UDim2.fromOffset(154,232),Size=UDim2.fromOffset(68,38),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),P.Violet,.48,1),13)\nnova.loopBorder=nova.loop:FindFirstChildOfClass("UIStroke")\nnova.loopGlow,nova.loopRim=glowEdge(nova.loop,P.Violet,.92,.52,2.6)\n',
        "loop border")
    source = replaceOnce(source,
        '    nova.bpmBorder,nova.loopBorder,nova.resetBorder,nova.resetGlow,nova.resetRim,\n',
        '    nova.bpmBorder,nova.loopBorder,nova.loopGlow,nova.loopRim,nova.resetBorder,nova.resetGlow,nova.resetRim,\n',
        "loop themed strokes")

    -- Close is instant: no fade, no scale-down, no delayed destruction.
    source = replaceOnce(source,
        'function nova.dismiss()\n    if nova.closing then return end\n    nova.closing=true\n    saveFavorites(state.Favorites)\n    API:Stop()\n    if nova.reveal then animate(nova.reveal,{GroupTransparency=1},.20) end\n    animate(nova.windowScale,{Scale=nova.windowScale.Scale*.96},.20)\n    task.delay(.21,function()\n        nova.disposeVisuals()\n        if nova.gui then nova.gui:Destroy() end\n    end)\nend\n',
        'function nova.dismiss()\n    if nova.closing then return end\n    nova.closing=true\n    saveFavorites(state.Favorites)\n    API:Stop()\n    nova.disposeVisuals()\n    if nova.gui then nova.gui:Destroy() end\nend\n',
        "instant close")

    return source
end
