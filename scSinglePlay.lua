--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 22:03
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")

local language = "en";
local mode = "";

local function onBtnPlayRelease()
    local options =
    {
        params = {startWord = "main", finishWord = "over"},
    }

    storyboard.gotoScene("scPlay", options);

    return true;
end

local function onBtnRandomRelease(event)
    mode = "random";
    print(mode);

    return true;
end

function scene:createScene(event)
    local image, scale, width, height;
    local screen = display.newGroup();

    screen:insert(ui.getBackground());

    -- define scale big buttons
    image = display.newImage("images/btn_border_1.png");

    scale = display.contentHeight / dimens.main_dimens.height;
    width = image.width * scale;
    height = image.height * scale;

    image:removeSelf();
    image = nil;

    screen:insert(ui.newButton{
        id = "btn_play",
        onRelease = onBtnPlayRelease,
        width = width,
        height = height,
        scale = scale
    });

    -- define scale small buttons
    image = display.newImage("images/o_1.png");

    scale = display.contentHeight / dimens.main_dimens.height;
    width = image.width * scale;
    height = image.height * scale;

    image:removeSelf();
    image = nil;

    screen:insert(ui.newButton{
        id = "btn_random",
        onRelease = onBtnRandomRelease,
        width = width,
        height = height,
        scale = scale
    });

    screen.isFocus = true;
end

scene:addEventListener("createScene", scene);

return scene;