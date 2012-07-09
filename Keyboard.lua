--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 04.07.12
-- Time: 19:41
-- To change this template use File | Settings | File Templates.
--

local dimens = require("dimens");
local widget = require("widget");
local strings = require("strings");

Keyboard = {};

function Keyboard:new(params)
    local scale = dimens.scale;
    local screenWidth = display.viewableContentWidth;
    local screenHeight = display.viewableContentHeight;

    local keyboard = display.newGroup();

    local wm = params.wm;

    local function onKeyEvent(event)
        local phase = event.phase;
        local target = event.target;

        if "release" == phase then
            wm:receiveLetter(target.label.text);
            -- print(target.label.text);
        end

        return true;
    end

    -- define button size ratio
    local image = display.newImage("images/kbd_button.png");
    local scaleV = image.height / image.width;
    image:removeSelf();
    image = nil;

    local paddingH = 3;
    local paddingV = 3;

    -- define max length of keyboard line
    local hlength = 0;
    for k, v in ipairs(strings.keylines) do
        local hchength = #strings.keylines[k][strings.language];
        hlength = math.max(hlength, hchength);
    end

    local width = ((screenWidth - paddingH) / hlength - paddingH);
    local height = width * scaleV;

    local countH;
    local countV = 0;
    for k, v in ipairs(strings.keylines) do
        local paddingC;

        countH = 0;
        countV = countV + 1;

        local keyline = display.newGroup();

        local hchength = #strings.keylines[k][strings.language];
        if hchength < hlength then
            paddingC = 0.5 * (hlength - hchength) * (paddingH + width);
        else
            paddingC = 0;
        end

        for k1, v1 in ipairs(strings.keylines[k][strings.language]) do
            keyline:insert(widget.newButton{
                id = k .. countV .. countH,
                label = string.upper(v1),
                left = countH * (paddingH + width) + paddingH + display.screenOriginX + paddingC,
                top = screenHeight - countV * (paddingV + height),
                width = width,
                height = height,
                font = "Vatuma Script slc",
                fontSize = 40 * scale,
                default = "images/kbd_button.png",
                over = "images/kbd_key_pressed.png",
                onEvent = onKeyEvent
            });

            countH = countH + 1;
        end

        keyboard:insert(keyline);
    end

    return keyboard;
end

return Keyboard;