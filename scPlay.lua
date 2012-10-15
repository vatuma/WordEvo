--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 22:42
-- To change this template use File | Settings | File Templates.
--

require("Keyboard");

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local values = require("values");
local widget = require("widget");
local sqlite = require("sqlite3");
local scrollView = require("scrollView")
local preference = require("save_and_load_library_from_satheesh");

local receiveButtonEvents = false;
local screen;

-- databases
local gametable;

local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);

local db_words;
local path_words = system.pathForFile(values.db_name[values.game_language], system.ResourceDirectory);

local tmain = {}; -- table for game process

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

local function loadMain()
    tmain = {};

    local sql = "SELECT * FROM " .. gametable .. " WHERE language='" .. values.game_language .. "' ORDER BY type, line;";

    for row in db_main:nrows(sql) do
        --print("ROW", row.modified);

        local type = row.type;
        local line = row.line;

        local ttype = tmain[type] or {};
        local tline = ttype[line] or {};

        tline.word = row.word;
        tline.linelb = row.linelb;

        tline.modified = row.modified;
        tline.selected = row.selected;
        tline.off = row.off;
        tline.type = type;

        tmain[type] = ttype;
        tmain[type][line] = tline;
    end
end

local function saveMain()
    local sql = "DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';";

    for k,v in pairs(tmain) do
        for k1,v1 in pairs(v) do
            local linelb = v1.linelb or "";

            local modified = v1.modified or "";

            sql = sql .. "INSERT into " .. gametable .. " ('type', 'line', 'linelb', 'word', 'selected', 'off', 'language', 'modified') VALUES ('"
                    .. k .. "'," .. k1 .. ",'" .. linelb .. "','" .. values.myLower(v1.word) .. "'," .. v1.selected .. "," .. v1.off .. ",'" .. values.game_language .. "','" .. modified .. "');";
        end
    end

    -- print(sql);

    db_main:exec(sql);
end

-- call back button
local function onBackBtn(event)
    if receiveButtonEvents == false then
        return false;
    end;

    if event.phase == "ended" then
        storyboard.gotoScene("scStart");
    end

    return true;
end

local function wordModule(params)
    local module = display.newGroup();

    -- fields
    module.start = params.start;
    module.finish = params.finish;
    module.steps_min = params.steps_min;
    module.level = params.level;

    module.max_row = params.max_row or 2;
    module.duplicate_row = -1;
    module.origin_row = -1;

    local function letter(params)
        local letter = display.newGroup();

        -- fields
        letter.off = params.off or false;
        letter.select = params.select or false;
        letter.flash = params.flash or false;

        letter.text = values.myUpper(params.text) or "";
        letter.text_old = values.myUpper(params.text) or "";

        letter.line = params.line;
        letter.module = params.module;

        letter.position = params.position or 1;

        letter.back = nil;
        letter.back_selected = nil;

        letter.label = nil;
        letter.label_flash = nil;
        letter.label_off = nil;

        -- letter methods
        function letter:getWord()
            local result = "";

            for i=1, self.line.lenght do
                result = result .. self.line["l" .. i].text;
            end

            return result;
        end

        function letter:update(params)
            print("function letter:update(params)", params.text)

            local text = self.text;

            if params.text ~= nil then
                text = values.myUpper(params.text) or "";
            end;

            -- change letter mode
            if params.off ~= nil then
                self.off = params.off; end;

            if params.select ~= nil then
                self.select = params.select; end;

            if params.flash ~= nil then
                self.flash = params.flash; end;

            -- print(self, self.select, params.select)

            -- create widgets if necessary
            if self.back == nil then
                local image = "images/sq_bg_null_full.png";
                local width, height = values.getImageSizes(image);

                letter.back = display.newImage(image, width, height);
                letter.back.width = width;
                letter.back.height = height;
                letter.back:setReferencePoint(display.TopLeftReferencePoint);
                letter.back.x, letter.back.y = 0,0;
                letter:insert(letter.back);
            end

            if self.back_selected == nil then
                local image = "images/sq_bg_yellow.png";
                local width, height = values.getImageSizes(image);

                letter.back_selected = display.newImage(image, width, height);
                letter.back_selected.width = width;
                letter.back_selected.height = height;
                letter.back_selected:setReferencePoint(display.TopLeftReferencePoint);
                letter.back_selected.x, letter.back_selected.y = 0,0;
                letter:insert(letter.back_selected);
            end

            if self.label == nil then
                letter.label = display.newText(text, 0, 0, values.font, 18 * 2);
                letter.label.xScale = 0.5; letter.label.yScale = 0.5;
                letter.label:setReferencePoint(display.CenterReferencePoint);
                letter.label.x, letter.label.y = letter.back.width * 0.5, letter.back.height * 0.5;
                letter.label:setTextColor(values.color_blue[1], values.color_blue[2], values.color_blue[3]);
                letter:insert(letter.label);
            end

            if self.label_flash == nil then
                letter.label_flash = display.newText(text, 0, 0, values.font, 18 * 2);
                letter.label_flash.xScale = 0.5; letter.label_flash.yScale = 0.5;
                letter.label_flash:setReferencePoint(display.CenterReferencePoint);
                letter.label_flash.x, letter.label_flash.y = letter.back.width * 0.5, letter.back.height * 0.5;
                letter.label_flash:setTextColor(values.color_red[1], values.color_red[2], values.color_red[3]);
                letter:insert(letter.label_flash);
            end

            if self.label_off == nil then
                letter.label_off = display.newText(text, 0, 0, values.font, 18 * 2);
                letter.label_off.xScale = 0.5; letter.label_off.yScale = 0.5;
                letter.label_off:setReferencePoint(display.CenterReferencePoint);
                letter.label_off.x, letter.label_off.y = letter.back.width * 0.5, letter.back.height * 0.5;
                letter.label_off:setTextColor(values.color_grey[1], values.color_grey[2], values.color_grey[3]);
                letter:insert(letter.label_off);

                -- small image for previous step letter
                letter.label_off_old = display.newText(text, 0, 0, values.font, 10 * 2);
                letter.label_off_old.xScale = 0.5; letter.label_off_old.yScale = 0.5;
                letter.label_off_old:setReferencePoint(display.CenterReferencePoint);
                letter.label_off_old.x, letter.label_off_old.y = letter.back.width * 0.5 + letter.label_off_old.width * 0.5, letter.back.height * 0.5 - letter.label_off_old.height * 0.5;
                letter.label_off_old:setTextColor(values.color_grey[1], values.color_grey[2], values.color_grey[3]);
                letter.label_off_old.text = text;
                letter:insert(letter.label_off_old);
            end

            -- change letter label
            if text ~= self.text then
                self.text = text;

                letter.label.text = text;
                letter.label_flash.text = text;
                letter.label_off.text = text;
            end

            -- set visibility of widgets
            self.label.alpha = 1;
            self.label_flash.alpha = 1;

            self.back_selected.isVisible = self.select;

            self.label.isVisible = not self.off;
            self.label_flash.isVisible = not self.off;
            self.label_off.isVisible = self.off;
            self.label_off_old.isVisible = false;

            self.label_flash.isVisible = self.flash;

            if self.flash then
                self.label_off.isVisible = not self.flash;

                self.label.isVisible = self.flash;
                self.label_flash.isVisible = self.flash;

                self.label.alpha = 0;
                self.label_flash.alpha = 1;

                transition.to(self.label, {time = 2000, alpha = 1});
                transition.to(self.label_flash, {time = 2000, alpha = 0});
            end
        end

        function letter:setOffMode(params)
            local isoff = params.isoff;

            self.label_off_old.isVisible = isoff;
            self.label_off.text = self.text_old;
            self.label_off_old.text = self.text;
            --[[
            if isoff then
            else
                self.label_off.text = self.text;
                self.label_off_old.text = self.text_old;
            end
            ]]--
        end

        local function onEvent(event)
            local phase = event.phase;
            local target = event.target;

            if "began" == phase then
                target.ypos = event.y;

            elseif "moved" == phase then
                local ypos = target.ypos or event.y;
                if math.abs(ypos - event.y) > values.wordmodule_scroll then
                    target.module.scrollarea:onbegan(event); -- send start to scroll object instead of letter
                end

                return true;

            elseif "ended" == phase then
                local ypos = target.ypos or event.y;
                if math.abs(ypos - event.y) > values.wordmodule_scroll then
                    return false;
                end

                if target.position > 0 then
                    target.line:update{};

                    if target.module.active_letter ~= nil then
                        tmain[target.module.active_line.data.type][target.module.active_line.row].selected = 0;
                        target.module.active_letter:update{select = false};
                    end;

                    target:update{select = true};
                    target.module.active_line = target.line;
                    target.module.active_letter = target;

                    tmain[target.line.data.type][target.line.row].selected = target.position;

                    target.module:offWords{};
                end
            end

            return true;
        end

        letter:addEventListener("touch", onEvent);
        letter:update{text = letter.text};

        letter.x = letter.position * values.cell * values.scale;

        return letter;
    end

    local function line(params)
        local line = display.newGroup();

        -- fields
        line.row = params.row;
        line.lenght = 0;
        line.data = params.data;
        line.word = params.data.word;
        line.module = params.module;

        line.changed_letter = nil;

        -- line methods
        function line:update(params)
            print("line:update", params, params.data, params.word)

            if params.data ~= nil then
                print("line data updated");
                self.data = params.data; end;

            local flash = params.flash or false;

            local data = self.data;
            self.word = data.word or "errrr";

            local word = self.word;
            if params.word ~= nil then
                print("word data updated");

                self.word = params.word;
                word = self.word;
            end

            if word ~= "errrr"
                and word ~= ""
                and self.data.type == "line" then
                self.module.max_row = math.max(self.module.max_row, self.row);

                -- print("line:update", self.word, self.module.max_row, self.row);
            end

            -- about previous letter
            local prev_position = 0;
            local text_old = "";
            if data.modified ~= nil then
                prev_position = string.sub(data.modified, 1, 1);
                text_old = string.sub(data.modified, 2, string.len(data.modified));
            end

            self.lenght = values.myLenght(word);
            for i = 1, self.lenght + 1 do
                local off = false;
                local select = false;

                local text = "";
                if i == 1 then
                    text = data.linelb or "-1";
                else
                    text = values.mySub(word, i - 1, i - 1);
                end;

                print("for i = 1, self.lenght + 1 do", i, text)

                local name = "l" .. i - 1;

                if data.selected == i - 1
                        and i ~= 1 then
                    select = true;
                end

                if data.off == 1 then
                    off = true; end;

                -- create new letter in current line
                if self[name] == nil then
                    --print("update", i, prev_position, text, text_old)
                    if (i + 1) .. "" == prev_position
                        and i ~= 1 then
                        --print("update", i, text, text_old)

                        self[name] = letter{module = self.module, line = self, text = text, text_old = text_old, position = i - 1, select = select, off = off};
                        self.changed_letter = self[name];
                    else
                        self[name] = letter{module = self.module, line = self, text = text, text_old = text, position = i - 1, select = select, off = off};
                    end

                    self:insert(self[name]);
                else
                    --print("update else", i, prev_position, text, text_old)

                    self[name]:update{text = text, select = select, off = off, flash = flash};
                end

                if select then
                    self.module.active_line = self;
                    self.module.active_letter = self[name];

                    -- print(data.word, data.selected, self.module.active_line, self.module.active_letter);
                end
            end
        end

        line:update{};

        return line;
    end

    local function checkdata(params)
        local type = params.type;
        local word = params.word or "";
        local line = params.line;
        local start = params.start or "";

        local data;
        local isnew = false;

        local ttype = tmain[type];
        if ttype == nil then
            isnew = true;
        else
            local tline = ttype[line];
            if tline == nil then
                isnew = true;
            else
                data = tline;
            end
        end

        if isnew then
            if ttype == nil then
                tmain[type] = {}; end;

            if type == "line"
                    and line == 2 then
                word = start;
            end

            tmain[type][line] = {};
            tmain[type][line].word = word;
            tmain[type][line].selected = 0;
            tmain[type][line].off = 0;
            tmain[type][line].type = type;
            tmain[type][line].linelb = line;

            data = tmain[type][line];
        end

        return data;
    end

    -- module methods
    function module:receiveLetter(data)
        if receiveButtonEvents == false then
            return false;
        end;
        
        self.active_letter:update{text = data};
        self.active_line.changed_letter = self.active_letter;

        local word = values.myLower(self.active_letter:getWord());
        if self:checkWord(word)
            and word ~= values.myLower(self.active_line.word) then

            -- set empty word if edit line in middle of list
            if self.active_line.row < self.max_row then
                for i = self.active_line.row + 1, self.max_row do
                    tmain["line"][i].word = string.rep(" ", self["line" .. i].lenght);
                    self["line" .. i]:update{data = tmain["line"][i]};
                end;
            end;

            self:addWord{word = word};
        end;
    end

    function module:setScrollBackground()
        local maxline = math.max(#tmain["line"], 10);

        self.scrollarea:remove(module.scrollarea.scrollBackground);

        self.scrollarea.scrollBackground = display.newRect(0, 0, values.wordmodule_width * values.scale, (maxline - 1) * values.cell * values.scale)
        self.scrollarea.scrollBackground:setFillColor(255, 255, 255, 200);
        self.scrollarea:insert(1, module.scrollarea.scrollBackground);

        self.scrollarea:addScrollBar();
    end

    function module:checkWord(word)
        local result = false;

        -- show label about incorrect word
        self.notindict.isVisible = true;
        self.iknow.isVisible = true;

        local sql = "SELECT * FROM dict WHERE word='" .. values.myLower(word) .. "';";
        for row in db_words:nrows(sql) do
            -- hide label about incorrect word
            self.notindict.isVisible = false;
            self.iknow.isVisible = false;

            result = true;
            break;
        end

        return result;
    end

    function module:addWord(params)
        print("function module:addWord(params)")

        local word = values.myLower(params.word);

        if word == self.finish then
            self:completeGame();
            return;
        end;

        self:showDuplicate(word);

        local count = 0;
        local row_max = 0;
        for k,v in pairs(tmain["line"]) do
            if v.word == "" then
                row_max = count; end;

            count = count + 1;
        end

        local curLine = self.active_line.row;
        local newLine = curLine + 1;

        tmain["line"][curLine].word = word;
        tmain["line"][curLine].modified = "" .. tmain["line"][curLine].selected .. values.myLower(self.active_letter.text_old);
        tmain["line"][curLine].selected = 0;

        self["line" .. curLine].word = word;
        self["line" .. curLine]:update{};
        print("module:addWord", word, self["line" .. curLine], self["line" .. curLine].row)

        tmain["line"][newLine].word = word;
        tmain["line"][newLine].selected = 1;

        self["line" .. newLine].word = word;
        self["line" .. newLine]:update{};

        if count < newLine + 2 then
            local nl = count + 2;

            tmain["line"][nl] = {};
            tmain["line"][nl].off = 0;
            tmain["line"][nl].word = "";
            tmain["line"][nl].selected = 0;
            tmain["line"][nl].linelb = nl;
            tmain["line"][nl].type = "line";

            local name = "line" .. nl
            if self[name] == nil then
                self[name] = line{module = self, data = tmain["line"][nl], row = nl};
                self[name].x, self[name].y = self.xoffset, (nl - 2) * values.cell * values.scale;
                self.scrollarea:insert(self[name]);
            end

            tmain["finish"][values.finish_line].linelb = nl + 1;
            self["linefinish"]:update{};
        end

        self:setScrollBackground();
        self:showLineOnScreen(newLine);
    end

    function module:offWords(params)
        print("module:offWords", self.active_line.row, self.max_row)

        local isoff = false;
        for i = 2, self.max_row do
            local off = 0;
            if i > self.active_line.row
                and self.active_line.row < self.max_row then
                isoff = true;
                off = 1;
            end;

            if off ~= tmain["line"][i].off then
                tmain["line"][i].off = off;
                self["line" .. i]:update{data = tmain["line"][i]};
            end

            self.clear.isVisible = self.active_line.row < self.max_row;
            self.clear.y = self.active_line.y;
        end

        for i = 2, self.max_row do
            if self["line" .. i].changed_letter ~= nil then
                if self["line" .. i] == self.active_line then
                    print("OFFWORD OFF", i, self["line" .. i], self.active_line)
                    self["line" .. i].changed_letter:setOffMode{isoff = isoff};
                else
                    print("OFFWORD ON", i, self["line" .. i], self.active_line)
                    self["line" .. i].changed_letter:setOffMode{isoff = false};
                end
            end;
        end

        -- show small previous letter if it is not last string
        -- self.active_letter:setOffMode{isoff = isoff};

        --[[
        if params.previous_letter ~= nil then
            params.previous_letter:setOffMode{isoff = false};
        end
        ]]--
    end

    function module:showDuplicate(word)
        self.origin_row = -1;
        self.duplicate_row = -1;
        self.duplicate.isVisible = false;
        self.origin.isVisible = false;

        for k,v in pairs(tmain["line"]) do
            if k < self.active_line.row
                and word == v.word then
                self.duplicate_row = k;
                self.origin_row = self.active_line.row;

                break;
            end
        end

        if self.duplicate_row > 0 then
            self.duplicate.isVisible = true;
            self.duplicate.y = self["line" .. self.origin_row].y;
        end
    end

    function module:gotoDuplicate()
        self["line" .. self.duplicate_row]:update{flash = true};

        self.origin.isVisible = true;
        self.origin.y = self["line" .. self.duplicate_row].y;

        self:showLineOnScreen(self.duplicate_row);
    end

    function module:gotoOrigin()
        self.origin.isVisible = false;

        self:showLineOnScreen(self.origin_row);
    end

    function module:showLineOnScreen(row)
        local cell = values.cell * values.scale;
        local vismin = self.scrollarea.y - self.tops;
        local vismax = math.abs(vismin) + cell * 9;

        local newpos = self.scrollarea.y;
        local rowpos = self["line" .. row].y;

        -- print(vismin, vismax, newpos, rowpos)

        if vismin < 0 then
            if rowpos < math.abs(vismin) then
                newpos = newpos + (math.abs(vismin) - rowpos + cell * 2);
            elseif rowpos + cell * 2 > vismax then
                newpos = newpos - (rowpos - vismax + cell * 2);
            end;
        else
            if rowpos + cell * 2 > vismax then
                newpos = newpos - (rowpos - vismax + cell * 2);
            end;
        end;

        local upperLimit = self.scrollarea.top
        local bottomLimit = display.contentHeight - self.scrollarea.height - self.scrollarea.bottom

        newpos = math.min(newpos, upperLimit);
        newpos = math.max(newpos, bottomLimit);

        -- print(upperLimit, bottomLimit, newpos)

        self.scrollarea.y = newpos;
        self.scrollarea:moveScrollBar();
    end

    function module:clearOffWords()

    end

    function module:completeGame()
        local count = self.active_line.row - 1;
        local sqlupdate = "";
        local is_insert = true;
        local sql = "SELECT * FROM results WHERE start='" .. self.start .. "' AND finish='" .. self.finish .. "';";

        for row in db_main:nrows(sql) do
            local steps = row.steps;

            if steps > count then
                sqlupdate = "UPDATE results SET steps=" .. count .. " WHERE start='" .. self.start .. "' AND finish='" .. self.finish .. "';";
            end

            is_insert = false;
        end

        if is_insert then
            sqlupdate = "INSERT INTO results ('start','finish','steps','rated') VALUES ('" .. self.start .. "','" .. self.finish .. "'," .. count .. ",0);";
        end

        if gametable == values.tblcampaign then
            sqlupdate = sqlupdate .. "UPDATE OR IGNORE campaign SET steps=" .. count .. " WHERE level=" .. self.level .. " AND language='" .. values.game_language .. "';";
            sqlupdate = sqlupdate .. "UPDATE OR IGNORE campaign SET enable=" .. 1 .. " WHERE level=" .. self.level + 1 .. " AND language='" .. values.game_language .. "';";
        end

        sqlupdate = sqlupdate .. "DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';";
        db_main:exec(sqlupdate);

        tmain = {};

        -- launch complete screen
        local options =
        {
            params = {
                start = self.start,
                finish = self.finish,
                level = self.level,
                steps = count,
                steps_min = self.steps_min,
                gametype = gametable,
            }
        }

        storyboard:gotoScene("scComplete", options);
    end

    -- creating module
    -- text widgets
    module.notindict = ui.myText{name = "wm_notindict", refPoint = display.TopLeftReferencePoint};
    module.notindict.isVisible = false;
    module:insert(module.notindict);

    module.iknow = ui.myText{name = "wm_iknow", refPoint = display.TopLeftReferencePoint};
    module.iknow.isVisible = false;
    module:insert(module.iknow);

    module.xoffset = values.cell * values.scale + offsetW;

    -- start and finish
    module["linestart"] = line{module = module, data = checkdata{type = "start", word = module.start, line = values.start_line}, row = values.start_line};
    module["linestart"].x, module["linestart"].y = module.xoffset, values.wordmodule_y * values.scale + offsetH;
    module:insert(module["linestart"]);

    module["linefinish"] = line{module = module, data = checkdata{type = "finish", word = module.finish, line = values.finish_line}, row = values.finish_line};
    module["linefinish"].x, module["linefinish"].y = module.xoffset, (values.wordmodule_y + 10 * values.cell) * values.scale + offsetH;
    module:insert(module["linefinish"]);

    -- scrollable area
    module.scroll = display.newGroup();
    module:insert(module.scroll);

    local tops = (values.wordmodule_y + values.cell) * values.scale + offsetH;
    local bottoms = viewScreenH - (values.wordmodule_y + values.cell * 10) * values.scale - offsetH;

    module.tops = tops;
    module.bottoms = bottoms;

    module.scrollarea = scrollView.new{
        top = tops,
        bottom = bottoms,
        offsetScroll = values.cell * (values.myLenght("lite") + 3) * values.scale, --!!!
    };
    module.scroll:insert(module.scrollarea);

    -- add control labels
    local function onDuplicate(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            event.target.module:gotoDuplicate();
        end

        return true;
    end

    module.duplicate = ui.myTextWithImage{name = "wm_duplicate"};
    module.duplicate.module = module;
    module.duplicate:addEventListener("touch", onDuplicate);
    module.duplicate.isVisible = false;
    module.scrollarea:insert(module.duplicate);

    local function onOrigin(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            event.target.module:gotoOrigin();
        end

        return true;
    end

    module.origin = ui.myTextWithImage{name = "wm_origin"};
    module.origin.module = module;
    module.origin:addEventListener("touch", onOrigin);
    module.origin.isVisible = false;
    module.scrollarea:insert(module.origin);

    local function onClear(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            ui.toast{text = "все слова ниже будут стерты при изменении"};
        end

        return true;
    end

    module.clear = ui.myTextWithImage{name = "wm_clear"};
    module.clear.module = module;
    module.clear:addEventListener("touch", onClear);
    module.clear.isVisible = false;
    module.scrollarea:insert(module.clear);

    -- masking scroll area
    local mask;
    if viewScreenH < display.contentHeight then
        mask = graphics.newMask("images/playMaskIpad.jpg", system.ResourceDirectory);
    else
        mask = graphics.newMask("images/playMask.jpg", system.ResourceDirectory);
    end

    module.scroll:setMask(nil);
    module.scroll:setMask(mask);

    module.scroll.maskX = values.cell * 9 * values.scale / 2 + values.wordmodule_x * values.scale + offsetW;
    module.scroll.maskY = values.cell * 9 * values.scale / 2 + (values.wordmodule_y + values.cell) * values.scale + offsetH;

    local count = 0;
    if tmain["line"] ~= nil then
        for k,v in pairs(tmain["line"]) do
            count = count + 1;
        end
    end

    -- create lines from database, min 9 lines from 2 to 10
    local maxline = math.max(count + 1, 10); print("create lines", count, maxline, tmain["line"])
    for i = 2, maxline do
        local name = "line" .. i;
        module[name] = line{module = module, data = checkdata{type = "line", line = i, start = module.start}, row = i};
        module[name].x, module[name].y = module.xoffset, (i - 2) * values.cell * values.scale;
        module.scrollarea:insert(module[name]);
    end

    module:setScrollBackground();
    module.scrollarea:addScrollBar();

    module:showLineOnScreen(module.max_row);

    module.scrollarea:moveScrollBar();

    return module;
end

local function dbInit()
    db_main = sqlite.open(path_main);
    db_words = sqlite.open(path_words);
end

function scene:createScene(event)
    print("scPlay", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    local params = event.params;
    local name;
    local start, finish = "", "";

    gametable = values.tblsingleplay;

    if params then
        gametable = params.gametype or values.tblsingleplay;
        start, finish = params.start or "", params.finish or "";
    end

    -- create screen
    screen = display.newGroup();
    screen:insert(ui.getBackground());

    -- module for words editing
    dbInit();

    -- clearing word module for new game
    if (start ~= "" and finish ~= "") then
        db_main:exec("DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';");
    end

    loadMain(); -- load data into temp table

    -- print(start, values.myLower(start), finish, values.myLower(finish));

    -- creating game module
    local wm = wordModule{start = values.myLower(start), finish = values.myLower(finish), steps_min = params.steps_min or 0, level = params.level};

    screen.wm = wm;
    screen:insert(screen.wm);

    --[[ TODO
    name = "startfinish";
    screen.startfinish = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, text = wm.start .. " -> " .. wm.finish};
    screen:insert(screen.startfinish);
    ]]--

    -- temp clear game

    local function onKillStop()
        if receiveButtonEvents == false then
            return false;
        end;
        -- print(gametable);

        local sql = "DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';";
        db_main:exec(sql);

        tmain = {};

        storyboard.gotoScene("scStart");
    end

    local width, height = values.getImageSizes("images/btn_border_1.png");
    screen.kill_stop = ui.myButton{
        id = "kill_stop",
        onRelease = onKillStop,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.kill_stop);

    -- end temp clear game

    screen.back = ui.myBackButton{scene = storyboard.getCurrentSceneName()};
    screen.back:addEventListener("touch", onBackBtn);
    screen:insert(screen.back);

    -- add fixed keyboard
    screen.keyboard = Keyboard:new({wm = wm});
    screen:insert(screen.keyboard);

    scene.screen = screen;
end

function scene:enterScene(event)
    print("scPlay", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
    end

    -- loadMain();
    -- scene.screen.wm:updateColors{all = true};
end

function scene:exitScene(event)
    print("scPlay", "exitScene");

    receiveButtonEvents = false;

    saveMain();

    if db_main and db_main:isopen() then
        db_main:close();
    end

    display.remove(screen);
    screen = nil;
end

local function onSystemEvent(event)
    print("scPlay", "onSystemEvent", event.type);

    if(event.type == "applicationExit") then
        saveMain();

        if db_main and db_main:isopen() then
            db_main:close();
        end
    end
end

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

return scene;