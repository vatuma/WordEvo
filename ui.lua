--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 27.06.12
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall);

local widget = require("widget");
local values = require("values");
local preference = require("save_and_load_library_from_satheesh");

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

--[[
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
]]--

function myText(params)
    local name = params.name;
    local refPoint = params.refPoint or display.CenterReferencePoint;
    local old = params.old or false;
    local scale = values.scale;
    local upper = params.upper or false;

    local v = values.labels[name];
    local label = values.getText(v);

    local offsetX, offsetY = offsetW, offsetH;

    if params.text then
        label = params.text;
    end

    if params.ingroup then
        offsetX, offsetY = 0, 0;
    end

    if (upper) then
        label = string.upper(label);
    end

    local text = display.newText(label, 0, 0, values.font, v.fontSize * scale * 2);
    -- text.font = native.newFont("Helvetica-Bold", v.fontSize * scale * 2);
    text.xScale = 0.5; text.yScale = 0.5;
    text:setReferencePoint(refPoint);

    if v.x == nil then
        text:setReferencePoint(display.TopCenterReferencePoint);
        text.x = viewScreenW * 0.5 + offsetW;
    else
        if old then
            text.xOld = v.x * scale + offsetX;
            text.x = text.xOld;
        else
            text.x = v.x * scale + offsetX;
        end
    end

    text.y = v.y * scale + offsetY;
    text:setTextColor(v.textColor[1], v.textColor[2], v.textColor[3]);

    return text;
end

function myLanguage(scene)
    local g = display.newGroup();

    local function selector(parent)
        local s = display.newGroup();

        scene:unlock(false);

        local function onEvent(event)
            local id = event.target.id;
            local target = event.target;

            print("selector", event.phase, id);

            if event.phase == "began" then
                values.game_language = id;
                preference.save{game_language = id};
                scene:unlock(true);
                g.label.text = values.language_name[id];

                s:removeSelf();
                s = nil;

                scene:refresh();
            end
        end

        s.back = display.newRoundedRect(0, 0, viewScreenW * 0.5, 100, 15);
        s.back.strokeWidth = 2;
        s.back:setFillColor(255, 255, 255);
        s.back:setStrokeColor(values.color_blue[1], values.color_blue[2], values.color_blue[3]);
        s:insert(s.back);

        local offset = 20;
        local height = 50;

        local count = 0;
        for k,v in pairs(values.language_name) do
            s[k] = ui.myText{name = "lang", refPoint = display.CenterReferencePoint};
            s[k].id = k;
            s[k].text = v;
            s[k].x = viewScreenW * 0.5 - s.back.width * 0.5;
            s[k].y = count * height + offset;
            s[k]:addEventListener("touch", onEvent);
            s:insert(s[k]);

            count = count + 1;
        end

        s.back.height = 2 * offset + count * height;

        s.x = viewScreenW * 0.5 - s.back.width * 0.5 + offsetW;
        s.y = viewScreenH * 0.3;

        s:toFront();

        return s;
    end

    local function onEvent(event)
        if event.phase == "ended" then
            print("start selector")
            event.target.selector = selector();
        end
    end

    g.back = display.newImage("images/o_lang.png");
    g.back.width, g.back.height = values.getImageSizes("images/o_lang.png");
    g.back:setReferencePoint(display.TopLeftReferencePoint);
    g.back.x, g.back.y = 0, 0;
    g:insert(g.back);

    g.label = ui.myText{name = "lang", text = values.language_name[values.game_language], refPoint = display.CenterLeftReferencePoint, ingroup = true};
    g:insert(g.label);

    g.x = 245 * values.scale + offsetW;
    g.y = 41 * values.scale + offsetH;

    print(viewScreenW, viewScreenH, offsetW, offsetH, display.screenOriginX, display.screenOriginY)

    g:addEventListener("touch", onEvent);

    return g;
end

function myButton(params)
    local id = params.id;
    local width = params.width;
    local height = params.height;
    local scale = params.scale or values.scale;
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
        -- labelColor = {v.textColor[1], v.textColor[2], v.textColor[3]},
        labelColor = {255, 255, 0, 255},
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

    rb.label = display.newText(values.backbtn[values.language], values.cell * 1.2 * values.scale, 0, values.font, 36 * values.scale * 2);
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

    local x = viewScreenW * 0.5 + offsetW;
    local y = viewScreenH * 0.7 + offsetH;

    local obj = display.newGroup();

    obj.back = display.newRoundedRect(0, 0, 150, 50, 10);
    obj.back.strokeWidth = 2;
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

--[[
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
]]--

-----------------
-- Helper function for newButton utility function below
local function newButtonHandler( self, event )

    local result = true

    local default = self[1]
    local over = self[2]

    -- General "onEvent" function overrides onPress and onRelease, if present
    local onEvent = self._onEvent

    local onPress = self._onPress
    local onRelease = self._onRelease

    local buttonEvent = {}
    if (self._id) then
        buttonEvent.id = self._id
    end

    local phase = event.phase
    if "began" == phase then
        if over then
            default.isVisible = false
            over.isVisible = true
        end

        if onEvent then
            buttonEvent.phase = "press"
            result = onEvent( buttonEvent )
        elseif onPress then
            result = onPress( event )
        end

        -- Subsequent touch events will target button even if they are outside the contentBounds of button
        display.getCurrentStage():setFocus( self, event.id )
        self.isFocus = true

    elseif self.isFocus then
        local bounds = self.contentBounds
        local x,y = event.x,event.y
        local isWithinBounds =
        bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

        if "moved" == phase then
            if over then
                -- The rollover image should only be visible while the finger is within button's contentBounds
                default.isVisible = not isWithinBounds
                over.isVisible = isWithinBounds
            end

        elseif "ended" == phase or "cancelled" == phase then
            if over then
                default.isVisible = true
                over.isVisible = false
            end

            if "ended" == phase then
                -- Only consider this a "click" if the user lifts their finger inside button's contentBounds
                if isWithinBounds then
                    if onEvent then
                        buttonEvent.phase = "release"
                        result = onEvent( buttonEvent )
                    elseif onRelease then
                        result = onRelease( event )
                    end
                end
            end

            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( self, nil )
            self.isFocus = false
        end
    end

    return result
end


---------------
-- Button class

function newButton( params )
    local button, default, over, size, font, textColor, offset

    if params.default then
        button = display.newGroup()
        default = display.newImage( params.default )
        button:insert( default, true )
    end

    if params.over then
        over = display.newImage( params.over )
        over.isVisible = false
        button:insert( over, true )
    end

    -- Public methods
    function button:setText( newText )

        local labelText = self.text
        if ( labelText ) then
            labelText:removeSelf()
            self.text = nil
        end

        local labelShadow = self.shadow
        if ( labelShadow ) then
            labelShadow:removeSelf()
            self.shadow = nil
        end

        local labelHighlight = self.highlight
        if ( labelHighlight ) then
            labelHighlight:removeSelf()
            self.highlight = nil
        end

        if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
        if ( params.font ) then font=params.font else font=native.systemFontBold end
        if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end

        -- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
        if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end

        if ( params.emboss ) then
            -- Make the label text look "embossed" (also adjusts effect for textColor brightness)
            local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3

            labelHighlight = display.newText( newText, 0, 0, font, size )
            if ( textBrightness > 127) then
                labelHighlight:setTextColor( 255, 255, 255, 20 )
            else
                labelHighlight:setTextColor( 255, 255, 255, 140 )
            end
            button:insert( labelHighlight, true )
            labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
            self.highlight = labelHighlight

            labelShadow = display.newText( newText, 0, 0, font, size )
            if ( textBrightness > 127) then
                labelShadow:setTextColor( 0, 0, 0, 128 )
            else
                labelShadow:setTextColor( 0, 0, 0, 20 )
            end
            button:insert( labelShadow, true )
            labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
            self.shadow = labelShadow
        end

        labelText = display.newText( newText, 0, 0, font, size )
        labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
        button:insert( labelText, true )
        labelText.y = labelText.y + offset
        self.text = labelText
    end

    if params.text then
        button:setText( params.text )
    end

    if ( params.onPress and ( type(params.onPress) == "function" ) ) then
        button._onPress = params.onPress
    end
    if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
        button._onRelease = params.onRelease
    end

    if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
        button._onEvent = params.onEvent
    end

    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = newButtonHandler
    button:addEventListener( "touch", button )

    if params.x then
        button.x = params.x
    end

    if params.y then
        button.y = params.y
    end

    if params.id then
        button._id = params.id
    end

    return button
end


--------------
-- Label class

function newLabel( params )
    local labelText
    local size, font, textColor, align
    local t = display.newGroup()

    if ( params.bounds ) then
        local bounds = params.bounds
        local left = bounds[1]
        local top = bounds[2]
        local width = bounds[3]
        local height = bounds[4]

        if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
        if ( params.font ) then font=params.font else font=native.systemFontBold end
        if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
        if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
        if ( params.align ) then align = params.align else align = "center" end

        if ( params.text ) then
            labelText = display.newText( params.text, 0, 0, font, size )
            labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
            t:insert( labelText )
            -- TODO: handle no-initial-text case by creating a field with an empty string?

            if ( align == "left" ) then
                labelText.x = left + labelText.contentWidth * 0.5
            elseif ( align == "right" ) then
                labelText.x = (left + width) - labelText.contentWidth * 0.5
            else
                labelText.x = ((2 * left) + width) * 0.5
            end
        end

        labelText.y = top + labelText.contentHeight * 0.5

        -- Public methods
        function t:setText( newText )
            if ( newText ) then
                labelText.text = newText

                if ( "left" == align ) then
                    labelText.x = left + labelText.contentWidth / 2
                elseif ( "right" == align ) then
                    labelText.x = (left + width) - labelText.contentWidth / 2
                else
                    labelText.x = ((2 * left) + width) / 2
                end
            end
        end

        function t:setTextColor( r, g, b, a )
            local newR = 255
            local newG = 255
            local newB = 255
            local newA = 255

            if ( r and type(r) == "number" ) then newR = r end
            if ( g and type(g) == "number" ) then newG = g end
            if ( b and type(b) == "number" ) then newB = b end
            if ( a and type(a) == "number" ) then newA = a end

            labelText:setTextColor( r, g, b, a )
        end
    end

    -- Return instance (as display group)
    return t

end
