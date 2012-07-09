--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 1:07
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local dimens = require("dimens");
local strings = require("strings")
local widget = require("widget");
local util = require("util");

local language = system.getPreference("ui", "language")

local btnCampaign;
local receiveButtonEvents = false;

local function onBtnCampaignRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    storyboard.gotoScene("scSinglePlay");

    return true;
end

local function onBtnSinglePlayRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    local options =
    {
        effect = "slideLeft",
        time = 2000,
        params = {
            start = "made",
            finish = "slon",
        }
    }

    storyboard.gotoScene("scPlay", options);

    return true;
end

function scene:createScene(event)
    language = "en";
    -- print(language);

    dimens.scale = display.contentHeight / dimens.main_dimens.height;
    local scale = dimens.scale;

    local screen = display.newGroup();

    screen:insert(ui.getBackground());

    -- define dimensions
    local image = display.newImage("images/btn_border_1.png");

    local width = image.width * scale;
    local height = image.height * scale;

    image:removeSelf();
    image = nil;

    screen:insert(ui.newButton{
        id = "btn_campaign",
        onRelease = onBtnCampaignRelease,
        width = width,
        height = height,
        scale = scale
    });

    local btn_singleplay = ui.newButton{
        id = "btn_singleplay",
        onRelease = onBtnSinglePlayRelease,
        width = width,
        height = height,
        scale = scale
    }

    screen:insert(btn_singleplay);

    --[[
    local function scrollViewListener( event )
        local s = event.target -- reference to scrollView object
        local dragX, dragY = s:getContentPosition();
        print(dragY);

        if event.type == "endedScroll" then
            print( "endedScroll event type" )
            s:scrollToPosition(0, 100, 500, true);
        end
    end

    local scrollView = widget.newScrollView{
        top = 204 * scale,
        left = 151 * scale,
        scrollHeight = 500,
        -- width = 200,
        -- height = 250,
        -- topPadding = 50,
        bgColor = { 255, 135, 255, 100 },
        listener = scrollViewListener,
        -- maskFile = "mask_200_250.png"
        -- hideBackground = true,
    }

    local mask = graphics.newMask("mask_200_250.png");
    scrollView:setMask(mask);
    scrollView.maskScaleX, scrollView.maskScaleY = 1/scale, 1/scale;
    -- scrollView.maskX = 151 * scale
    -- scrollView.maskY = 204 * scale

    -- scrollView.isHitTestMasked = true;

    local img = display.newImage("images/o_1.png");

    scrollView:insert(img);

    -- scrollView:addScrollBar();

    screen:insert(scrollView);
    ]]--
end

function scene:enterScene(event)
    receiveButtonEvents = true;
end

function scene:exitScene(event)
    receiveButtonEvents = false;
end

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

return scene;