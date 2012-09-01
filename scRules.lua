--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 28.08.12
-- Time: 21:03
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local values = require("values");

local receiveButtonEvents = false;
local screen;

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

local function onBtnCloseRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    return true;
end

function scene:createScene(event)
    print("scRules", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    screen = display.newGroup();

    screen:insert(ui.getBackground());

    screen.webView = native.newWebView(0, 0, 320, 480);
    screen.webView:request("http://www.coronalabs.com/")
    -- screen.webView:request("includes/rules_ru.html", system.ResourceDirectory);
    screen:insert(screen.webView);
end

function scene:enterScene(event)
    print("scRules", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());
end

function scene:exitScene(event)
    print("scRules", "exitScene");

    receiveButtonEvents = false;
end

local function onSystemEvent(event)
    print("scRules", "onSystemEvent", event.type);

    if(event.type == "applicationExit") then
    end
end

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

return scene;