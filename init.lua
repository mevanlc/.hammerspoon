hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.loadSpoon('EmmyLua')

require('hs.ipc')
-- hs.ipc.cliInstall()

function p(...)
    local args = {...}
    local str = "@@\n"
    for i, v in ipairs(args) do
        str = str .. tostring(v) .. " "
    end
    -- remove the trailing space from the string
    str = string.sub(str, 1, -2) .. "\n@@"
    print(str)
end

hs.hotkey.bind("ctrl shift cmd", "h", function() hs.toggleConsole() end)

hs.hotkey.bind("alt cmd", "g", function() hs.application.launchOrFocus("MacVim") end)

OpenCmmUninstaller = false
hs.hotkey.bind("cmd ctrl alt shift", "u", function()
    if hs.application.open("CleanMyMac X") then
        OpenCmmUninstaller = true
    end
end)

hs.hotkey.bind("alt cmd", "e", function()
    hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind("cmd ctrl shift", "p", function()
    local initFile = hs.configdir .. "/init.lua"
    local codeBin = "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    local cmd = '"' .. codeBin .. '" ' .. initFile
    p("cmd:", cmd)
    output, status, etype, rc = hs.execute(cmd)
    p("output:", output, "status:", status, "etype:", etype, "rc:", rc)
end)

--WasdKeyMap = { w="k", a="-", s="j", d="=", z="up", x="down" }
WasdKeyMap = { w="up", a="left", s="down", d="right" }
WasdEnabled = false
WasdMenu = nil
KeyUpDownEventTypes = {
    [hs.eventtap.event.types.keyDown] = true,
    [hs.eventtap.event.types.keyUp] = false
}

---@diagnostic disable: undefined-field
WasdBinding = hs.hotkey.bind("cmd ctrl shift", "z", function()
    WasdEnabled = not WasdEnabled
    if WasdMenu ~= nil then
        WasdMenu:delete()
    end
    if WasdEnabled then
        WasdMenu = hs.menubar.new()
        WasdMenu:autosaveName("hs.wasd")
        WasdMenu:setTitle("W")
    end
    p("wasdEnabled? ", WasdEnabled)
end)

hs.hotkey.bind("cmd ctrl shift", "t", function()
    p("focused window: ", hs.window.focusedWindow():title())
    p("focused app: ", hs.window.focusedWindow():application())
end)


function keyEvent(event)
    if not WasdEnabled then return end
    local echars = event:getCharacters()
    local mapto = WasdKeyMap[echars]
    local etype = event:getType()
    local edown = KeyUpDownEventTypes[etype]
    if edown == nil then
        -- p("etype is neither keyDown or keyUp")
        return
    end
    if mapto == nil then
        -- p("echars are not in key map")
        return
    end
    hs.eventtap.event.newKeyEvent({}, mapto, edown):post()
    return true
    -- p("echars=", echars, " mapto=", s(mapto), " edown=", s(edown))
end

tap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, keyEvent)
tap:start()

hs.application.watcher.new(function(name, event, app)
    if name == "CleanMyMac X" then
        if event == hs.application.watcher.activated then
            if OpenCmmUninstaller then
                OpenCmmUninstaller = false
                hs.eventtap.keyStroke("cmd", "6")
            end
        end
    end
end):start()