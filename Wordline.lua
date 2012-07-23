--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 14.07.12
-- Time: 16:38
-- To change this template use File | Settings | File Templates.
--

local values = require("values");

Wordline = {};
local cell = values.cell;
local scale = values.scale;

local function wordLine(params)
    -- create word line object
    local wl = display.newGroup();

    -- letter in word line
    local function letter(params)
        -- create letter object
        local letter = display.newGroup();

        -- event tap on letter
        local function onEvent(event)
            local target = event.target;

            -- change selected letter
            if ("ended" == event.phase) then
                -- don't touch numbers
                if (target.position ~= 1) then
                    target.parent.parent:selectLine{line = target.line, selected = target.position, update = true};
                end
            end

            return true;
        end

        -- change label by keyboard event
        function letter:setLbl(label)
            -- print(self.line, self.parent.parent.line, self.position, self.parent.parent.selected);
            -- print(type(self.line), type(self.parent.parent.line), type(self.position), type(self.parent.parent.selected));

            if (self.line == self.parent.parent.line and self.position == self.parent.parent.selected) then
                self.label.text = string.upper(label);
            end

            return self.label.text;
        end

        -- define image and color of object
        local image = "images/sq_bg_null_full.png";
        local color = dimens.color_blue;

        if (params.image) then
            image = params.image;
        end

        if (params.color) then
            color = params.color;
        end

        letter.line = params.line;
        letter.position = params.position;

        -- create image and label for letter object
        letter.back = display.newImage(image, width, height);
        letter.back.width = width;
        letter.back.height = height;
        letter.back:setReferencePoint(display.TopLeftReferencePoint);
        letter:insert(letter.back);

        letter.label = display.newText(string.upper(params.label or ""), 0, 0, "Vatuma Script slc", 18);
        letter.label:setReferencePoint(display.CenterReferencePoint);
        letter.label:setTextColor(color[1], color[2], color[3]);
        letter:insert(letter.label);

        letter.x = params.left;
        letter.y = params.top;
        letter.back.x = 0;
        letter.back.y = 0;
        letter.label.x = letter.back.x + letter.back.width * 0.5;
        letter.label.y = letter.back.y + letter.back.height * 0.5;

        letter:addEventListener("touch", onEvent);

        return letter;
    end

    wl.word = params.word;
    wl.line = params.line;
    wl.selected = params.selected;

    local left = params.left;
    local top = params.top;

    -- create all letters of word
    for i = 1, #wl.word + 1 do
        local label;
        if i == 1 then
            label = wl.line;
        else
            label = string.sub(wl.word, i - 1, i - 1);
        end

        local pos = "pos" .. i;

        -- selected letter
        if (wl.selected == i) then
            wl[pos] = letter({
                left = (left + (i - 1) * cell) * scale + display.screenOriginX,
                top = (top + (wl.line - 1) * cell) * scale + display.screenOriginY,
                label = label,
                line = wl.line,
                position = i,
                image = "images/sq_bg_yellow.png",
            });
            -- unselected letter
        else
            wl[pos] = letter({
                left = (left + (i - 1) * cell) * scale + display.screenOriginX,
                top = (top + (wl.line - 1) * cell) * scale + display.screenOriginY,
                label = label,
                line = wl.line,
                position = i,
            });
        end

        wl:insert(wl[pos]);
    end

    -- change selected letter in selected word
    function wl:setLbl(label)
        -- trying to change label letter by letter
        local newWord = "";
        for j = 1, #self.word + 1 do
            if (j > 1) then
                newWord = newWord .. self["pos" .. j]:setLbl(label);
            end
        end
        wl.word = newWord;

        -- change word in database
        --[[
        if (string.lower(self.word) ~= string.lower(newWord)) then
            if (checkWord(newWord, self.parent)) then
                print("want to add row", string.lower(wl.word), string.lower(newWord));

                self.parent:updateWord{word = newWord};
            else
                print("HAVEN't WORD " .. newWord);
            end
        end
        ]]--
    end

    return wl;
end

return Wordline;