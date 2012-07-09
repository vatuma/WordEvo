--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 27.06.12
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall);

local dimens = require("dimens");
local strings = require("strings")
local widget = require("widget");

function newButton(params)
    local id = params.id;
    local width = params.width;
    local height = params.height;
    local scale = params.scale;
    local onRelease = params.onRelease;

    local btn = widget.newButton{
        id = id,
        label = strings.buttons[id][strings.language],
        left = dimens[id].x * scale,
        top = dimens[id].y * scale,
        width = width,
        height = height,
        font = "Vatuma Script slc",
        fontSize = dimens[id].fontSize * scale,
        default = dimens[id].default,
        over = dimens[id].over,
        onRelease = onRelease
    }

    return btn;
end

function getBackground()
    local back = display.newImage("images/bg_copybook.png", display.screenOriginX, display.screenOriginY);
    back:setReferencePoint(display.TopLeftReferencePoint);

    local scale = display.contentHeight / back.contentHeight;
    -- print(scale);

    back.xScale = scale;
    back.yScale = scale;

    return back;
end