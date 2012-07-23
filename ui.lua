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
local values = require("values");
local storyboard = require("storyboard");

function newButton(params)
    local id = params.id;
    local width = params.width;
    local height = params.height;
    local scale = params.scale;
    local onRelease = params.onRelease;

    local btn = widget.newButton{
        id = id,
        label = strings.buttons[id][strings.language],
        left = dimens[id].x * scale + display.screenOriginX,
        top = dimens[id].y * scale + display.screenOriginY,
        width = width,
        height = height,
        font = "Vatuma Script slc",
        fontSize = dimens[id].fontSize * scale,
        labelColor = {76, 70, 149},
        default = dimens[id].default,
        over = dimens[id].over,
        onRelease = onRelease
    }

    return btn;
end

function myText(params)
    local name = params.name;
    local refPoint = params.refPoint;
    local old = params.old or false;
    local scale = values.scale;
    local upper = params.upper or false;

    local v = values.labels[name];
    local label = values.getText(v);

    if params.text then
        label = params.text;
    end

    if (upper) then
        label = string.upper(label);
    end

    local text = display.newText(label, 0, 0, values.font, v.fontSize * scale * 2);
    text.xScale = 0.5; text.yScale = 0.5;
    text:setReferencePoint(refPoint);
    if old then
        text.xOld = v.x * scale + display.screenOriginX;
        text.x = text.xOld;
    else
        text.x = v.x * scale + display.screenOriginX;
    end
    text.y = v.y * scale + display.screenOriginY;
    text:setTextColor(v.textColor[1], v.textColor[2], v.textColor[3]);

    return text;
end

function myButton(params)
    local id = params.id;
    local width = params.width;
    local height = params.height;
    local scale = params.scale;
    local onRelease = params.onRelease;

    local v = values.buttons[id];

    local btn = widget.newButton{
        id = id,
        label = values.getText(v),
        left = v.x * scale + display.screenOriginX,
        top = v.y * scale + display.screenOriginY,
        width = width,
        height = height,
        font = values.font,
        fontSize = v.fontSize * scale,
        labelColor = {v.textColor[1], v.textColor[2], v.textColor[3]},
        default = v.default,
        over = v.over,
        onRelease = onRelease
    }

    return btn;
end

function myBackButton(params)
    local scene = params.scene;

    local rb = display.newGroup();

    local width, height = values.getImageSizes("images/ic_clear.png");

    rb.image = display.newImage("images/ic_clear.png");
    rb.image.width = width;
    rb.image.height = height;
    rb:insert(rb.image);

    rb.label = display.newText(values.backbtn[values.game_language], values.cell * 1.2 * values.scale, 0, values.font, 36 * values.scale * 2);
    rb.label.xScale = 0.5; rb.label.yScale = 0.5;
    rb.label:setTextColor(values.color_blue[1], values.color_blue[2], values.color_blue[3]);
    rb:insert(rb.label);

    rb.image:setReferencePoint(display.TopLeftReferencePoint);
    rb.image.x = 0;
    rb.image.y = 0;

    rb.label:setReferencePoint(display.CenterLeftReferencePoint);
    rb.label.x = rb.image.x + values.cell * 1.2 * values.scale;
    rb.label.y = height * 0.5 --rb.image.y + (height - rb.label.height) * 0.5;

    rb:setReferencePoint(display.TopLeftReferencePoint);
    rb.x = values.backbtn[scene].x * values.scale + display.screenOriginX;
    rb.y = values.backbtn[scene].y * values.scale + display.screenOriginY;

    return rb;
end

function myTextWithImage(params)
    local name = params.name;

    local v = values.labels[name];
    local label = values.getText(v);
    local image = v.image;

    local rb = display.newGroup();

    local width, height = values.getImageSizes(image);

    rb.image = display.newImage(image);
    rb.image.width = width;
    rb.image.height = height;
    rb:insert(rb.image);

    rb.label = display.newText(label, values.cell * 1.2 * values.scale, 0, values.font, v.fontSize * values.scale * 2);
    rb.label.xScale = 0.5; rb.label.yScale = 0.5;
    rb.label:setTextColor(v.textColor[1], v.textColor[2], v.textColor[3]);
    rb:insert(rb.label);

    rb.image:setReferencePoint(display.TopLeftReferencePoint);
    rb.image.x = 0;
    rb.image.y = 0;

    rb.label:setReferencePoint(display.CenterLeftReferencePoint);
    rb.label.x = rb.image.x + values.cell * 1.2 * values.scale;
    rb.label.y = height * 0.5 --rb.image.y + (height - rb.label.height) * 0.5;

    rb:setReferencePoint(display.TopLeftReferencePoint);
    rb.x = v.x * values.scale + display.screenOriginX;
    rb.y = v.y * values.scale + display.screenOriginY;

    return rb;
end

function getBackground()
    local back = display.newImage("images/bg_copybook.png", display.screenOriginX, display.screenOriginY);
    back:setReferencePoint(display.TopLeftReferencePoint);

    local scale = values.scale;

    back.xScale = scale;
    back.yScale = scale;

    return back;
end

function toast(params)
    local text = params.text or "test test test test";
    local delay = params.time or 2000;
    local time = 1000;

    local x = display.viewableContentWidth / 2;
    local y = display.viewableContentHeight * 0.7;

    local obj = display.newGroup();

    obj.back = display.newRoundedRect(0, 0, 150, 50, 15);
    obj.back.strokeWidth = 3;
    obj.back:setFillColor(0, 125, 0);
    obj.back:setStrokeColor(0, 0, 125);
    obj.back:setReferencePoint(display.CenterReferencePoint);
    obj.back.x = x;
    obj.back.y = y;

    obj.label = display.newText(text, 0, 0, 150, 0, values.font, 16);
    obj.label:setReferencePoint(display.CenterReferencePoint);
    obj.label.x = x;
    obj.label.y = y;
    obj.label.width = 130;
    obj.label:setTextColor(0,0,0);

    obj.back.height = obj.label.height + 10;

    obj:insert(obj.back);
    obj:insert(obj.label);

    transition.to(obj, {delay = delay, time = time, alpha = 0});

    timer.performWithDelay(time + delay, function() obj:removeSelf(); obj = nil; end);

    return obj;
end

function runner(params)
    local pstart;
    local pfinish;

    local asize;
    local asizefull;
    local asizescroll;

    local offset;

    local area = params.area;

    asize = params.size;
    asizefull = params.sizefull;

    local r = display.newGroup();

    local function scrollArea(y)
        area.y = - (y / pfinish) * (asizefull - asize);
    end

    local function onEvent(event)
        local target = event.target;

        if (event.phase == "moved") then
            target.y = event.y - offset;

            target.y = math.max(target.y, pstart);
            target.y = math.min(target.y, pfinish);

            scrollArea(target.y);
        elseif event.phase == "began" then
            offset = event.y - target.y;
        end
    end

    r.runner_back = display.newImage("images/runner_back.png");
    r.runner_back.width = r.runner_back.width * values.scale;
    r.runner_back.height = r.runner_back.height * values.scale;
    r.runner_back:setReferencePoint(display.TopLeftReferencePoint);
    r.runner_back.x = 0;
    r.runner_back.y = 0;
    r:insert(r.runner_back);

    r.runner = display.newImage("images/runner.png");
    r.runner.width = r.runner.width * values.scale;
    r.runner.height = r.runner.height * values.scale;
    r.runner:setReferencePoint(display.TopLeftReferencePoint);
    r.runner.x = 0;
    r.runner.y = 0;
    r:insert(r.runner);

    r.runner:addEventListener("touch", onEvent);

    r.x = (values.wordmodule_x - values.cell) * values.scale + display.screenOriginX;
    r.y = (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY;

    pstart = r.runner_back.y;
    pfinish = r.runner_back.y + r.runner_back.height - r.runner.height;

    return r;
end
