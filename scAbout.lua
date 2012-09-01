--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 28.08.12
-- Time: 19:47
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

local function onBtnOurGamesRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    ui.toast{text = "не реализовано"};

    return true;
end

local function onBtnCloseRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    storyboard.gotoScene("scStart");

    return true;
end

local function onWebLink(event)
    if receiveButtonEvents == false then
        return false;
    end;

    if event.phase == "ended" then
        system.openURL("http://www.vatumagames.com");
    end;

    return true;
end

function scene:createScene(event)
    print("scAbout", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    screen = display.newGroup();

    screen:insert(ui.getBackground());

    screen.logo_small = display.newImage("images/logo_small.png");
    screen.logo_small.width, screen.logo_small.height = values.getImageSizes("images/logo_small.png");
    screen.logo_small:setReferencePoint(display.TopLeftReferencePoint);
    screen.logo_small.x, screen.logo_small.y = offsetW, offsetH;
    screen:insert(screen.logo_small);

    screen.logo = display.newImage("images/logo.png");
    screen.logo.width, screen.logo.height = values.getImageSizes("images/logo.png");
    screen.logo:setReferencePoint(display.TopLeftReferencePoint);
    screen.logo.x, screen.logo.y = 20 + offsetW, 333 * values.scale + offsetH;
    screen:insert(screen.logo);

    screen.title = ui.myText{name = "title_about", refPoint = display.CenterReferencePoint};
    screen.title.x = viewScreenW - (viewScreenW - 2 * values.cell * values.scale) * 0.5;
    screen.title.y = values.cell * values.scale + offsetH;
    screen:insert(screen.title);

    local width, height = values.getImageSizes("images/btn_border_1.png");

    screen.our_games = ui.myButton{
        id = "our_games",
        onRelease = onBtnOurGamesRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.our_games);

    screen.close = ui.myButton{
        id = "about_close",
        onRelease = onBtnCloseRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.close);

    screen.name = ui.myText{name = "about_name", refPoint = display.TopLeftReferencePoint, ingroup = false};
    screen:insert(screen.name);

    -- print(screen.name.x, screen.name.width)

    screen.version = ui.myText{name = "about_name", refPoint = display.TopLeftReferencePoint, ingroup = false};
    screen.version.text = values.getText(values.version);
    screen.version.fontSize = 20;
    screen.version.x = screen.name.x + screen.name.width;
    screen:insert(screen.version);

    screen.weblink = ui.myText{name = "weblink", refPoint = display.CenterReferencePoint};
    screen.weblink.x = viewScreenW * 0.5;
    screen.weblink:addEventListener("touch", onWebLink);
    screen:insert(screen.weblink);
end

function scene:enterScene(event)
    print("scAbout", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());
end

function scene:exitScene(event)
    print("scAbout", "exitScene");

    receiveButtonEvents = false;
end

local function onSystemEvent(event)
    print("scAbout", "onSystemEvent", event.type);

    if(event.type == "applicationExit") then
    end
end

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

return scene;