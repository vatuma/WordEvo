--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 04.07.12
-- Time: 19:41
-- To change this template use File | Settings | File Templates.
--

local widget = require("widget");
local values = require("values");

Keyboard = {};

function Keyboard:new(params)
    local scale = values.scale;
    local screenWidth = display.viewableContentWidth;
    local screenHeight = display.viewableContentHeight;

    local keyboard = display.newGroup();

    local wm = params.wm;

    local function onKeyEvent(event)
        local phase = event.phase;
        local target = event.target;

        -- send letter to word module, for ex.
        if "release" == phase then
            wm:receiveLetter(target.label.text);
        end

        return true;
    end

    -- define button size ratio
    local image = display.newImage("images/kbd_button.png");
    local scaleV = image.height / image.width;
    image:removeSelf();
    image = nil;

    local paddingH = 0;
    local paddingV = 0;

    local keylines = values.keylines;
    local language = values.game_language;

    -- define max length of keyboard line
    local hlength = 0;
    for k, v in ipairs(keylines) do
        local hchength = #keylines[k][language];
        hlength = math.max(hlength, hchength);
    end

    local width = ((screenWidth - paddingH) / hlength - paddingH);
    local height = width * scaleV;

    local countH;
    local countV = 0;
    for k, v in ipairs(keylines) do
        local paddingC;

        countH = 0;
        countV = countV + 1;

        local keyline = display.newGroup();

        local hchength = #keylines[k][language];
        if hchength < hlength then
            paddingC = 0.5 * (hlength - hchength) * (paddingH + width);
        else
            paddingC = 0;
        end

        for k1, v1 in ipairs(keylines[k][language]) do
            local top = screenHeight + display.screenOriginY - countV * (paddingV + height);

            keyline:insert(widget.newButton{
                id = k .. countV .. countH,
                label = values.myUpper(v1),
                left = countH * (paddingH + width) + paddingH + display.screenOriginX + paddingC,
                top = top,
                width = width,
                height = height,
                font = values.font,
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