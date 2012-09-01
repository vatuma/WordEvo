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
    -- print("loadMain " .. gametable, sql);

    for row in db_main:nrows(sql) do
        local type = row.type;
        local line = row.line;

        local ttype = tmain[type] or {};
        local tline = ttype[line] or {};

        tline.word = row.word;
        tline.linelb = row.linelb;
        -- tline.modified = row.modified;
        tline.selected = row.selected;
        tline.off = row.off;
        tline.type = type;

        tmain[type] = ttype;
        tmain[type][line] = tline;

        -- print(type, line, tline.word);
    end

    -- print("loadMain " .. gametable, #tmain);
end

local function saveMain()
    -- print("saveMain " .. gametable, #tmain);

    local sql = "DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';";

    for k,v in pairs(tmain) do
        for k1,v1 in pairs(v) do
            -- print("save", k, k1, v1.word)

            local linelb = v1.linelb or "";

            --[[
            sql = sql .. "INSERT into " .. gametable .. " ('type', 'line', 'linelb', 'word', 'selected', 'modified', 'off', 'language') VALUES ('"
                    .. k .. "'," .. k1 .. ",'" .. linelb .. "','" .. values.myLower(v1.word) .. "'," .. v1.selected .. "," .. v1.modified .. "," .. v1.off .. ",'" .. values.game_language .. "');";
            ]]--

            sql = sql .. "INSERT into " .. gametable .. " ('type', 'line', 'linelb', 'word', 'selected', 'off', 'language') VALUES ('"
                    .. k .. "'," .. k1 .. ",'" .. linelb .. "','" .. values.myLower(v1.word) .. "'," .. v1.selected .. "," .. v1.off .. ",'" .. values.game_language .. "');";
        end
    end

    -- print(sql, #tmain);

    db_main:exec(sql);

    -- tmain = {};
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
            local text = self.text;
            if params.text then
                text = values.myUpper(params.text) or ""; end;

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

        local function onEvent(event)
            local phase = event.phase;
            local target = event.target;

            if "began" == phase then
                target.ypos = event.y;

            elseif "moved" == phase then
                local ypos = target.ypos or event.y;
                if math.abs(ypos - event.y) > values.wordmodule_scroll then
                    target.module.scrollarea:onbegan(event);
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

                    target.module:offWords();
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

        -- line methods
        function line:update(params)
            if params.data then
                print("line data updated");
                self.data = params.data; end;

            local flash = params.flash or false;

            local data = self.data;
            self.word = data.word or "errrr";

            local word = self.word;
            if params.word then
                word = params.word;
            end

            if word ~= "errrr"
                and word ~= ""
                and self.data.type == "line" then
                self.module.max_row = math.max(self.module.max_row, self.row);
                print("line:update", self.word, self.module.max_row, self.row);
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

                local name = "l" .. i - 1;

                if data.selected == i - 1
                        and i ~= 1 then
                    select = true;
                end

                if data.off == 1 then
                    off = true; end;

                if self[name] == nil then
                    self[name] = letter{module = self.module, line = self, text = text, position = i - 1, select = select, off = off};
                    self:insert(self[name]);
                else
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

        local word = values.myLower(self.active_letter:getWord());
        if self:checkWord(word)
            and word ~= values.myLower(self.active_line.word) then

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

        local newLine = self.active_line.row + 1;

        tmain["line"][self.active_line.row].word = word;
        tmain["line"][self.active_line.row].selected = 0;
        self.active_line:update{};

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

    function module:offWords()
        print("module:offWords", self.active_line.row, self.max_row)

        for i = 2, self.max_row do
            local off = 0;
            if i > self.active_line.row
                and self.active_line.row < self.max_row then
                off = 1; end;

            if off ~= tmain["line"][i].off then
                tmain["line"][i].off = off;
                self["line" .. i]:update{data = tmain["line"][i]};
            end

            self.clear.isVisible = self.active_line.row < self.max_row;
            self.clear.y = self.active_line.y;
        end
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

-- entirely module of words
local function wordModuleOld(params)
    local cell = values.cell;

    -- define sizes of image
    local width, height = values.getImageSizes("images/sq_bg_null_full.png");

    -- create word module
    local wm = display.newGroup();

    wm.level = params.level or 0;
    wm.steps_min = params.steps_min or 0;
    wm.start = params.start or ""; -- start word
    wm.finish = params.finish or ""; -- finish word

    -- print("steps_min = " .. wm.steps_min)
    -- ui.toast{text = "steps_min = " .. wm.steps_min};

    wm.line = 2; -- edited line
    wm.selected = 2; -- edited position of letter (1 - is row number)

    wm.clear_max = 2; -- count of filled lines
    wm.clear_pos = -1;
    wm.duplicate_pos = -1; -- line to go duplicate

    wm.lines = {}; -- all lines for quick link

    -- check new word by dictionary and show signal labels
    function wm:checkWord(word)
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

    -- finish current game and save results
    function wm:completeGame()
        local count = wm.line - 1;
        local sqlupdate = "";
        local is_insert = true;
        local sql = "SELECT * FROM results WHERE start='" .. wm.start .. "' AND finish='" .. wm.finish .. "';";

        for row in db_main:nrows(sql) do
            local steps = row.steps;

            if steps > count then
                sqlupdate = "UPDATE results SET steps=" .. count .. " WHERE start='" .. wm.start .. "' AND finish='" .. wm.finish .. "';";
            end

            is_insert = false;
        end

        if is_insert then
            sqlupdate = "INSERT INTO results ('start','finish','steps','rated') VALUES ('" .. wm.start .. "','" .. wm.finish .. "'," .. count .. ",0);";
        end

        if gametable == values.tblcampaign then
            sqlupdate = sqlupdate .. "UPDATE OR IGNORE campaign SET steps=" .. count .. " WHERE level=" .. self.level .. " AND language='" .. values.game_language .. "';";
            sqlupdate = sqlupdate .. "UPDATE OR IGNORE campaign SET enable=" .. 1 .. " WHERE level=" .. self.level + 1 .. " AND language='" .. values.game_language .. "';";
        end

        sqlupdate = sqlupdate .. "DELETE FROM " .. gametable .. " WHERE language='" .. values.game_language .. "';";
        db_main:exec(sqlupdate);

        tmain = {};

        -- print(sqlupdate);
        -- print("completeGame", wm.start, wm.finish, count, wm.steps_min, gametable)

        local options =
        {
            params = {
                start = wm.start,
                finish = wm.finish,
                level = wm.level,
                steps = count,
                steps_min = wm.steps_min,
                gametype = gametable,
            }
        }

        storyboard:gotoScene("scComplete", options);
    end

    function wm:gotoDuplicate()
        tmain["line"][wm.duplicate_pos].modified = 1;
        wm:updateColors();

        self.goback.isVisible = true;
        self.goback.y = self.scroll.area["line" .. wm.duplicate_pos][1].y;
    end

    function wm:gotoBack()
    end

    function wm:showDuplicate(params)
        -- hide duplicate indicator
        self.duplicate_pos = -1;
        self.duplicate.isVisible = false;

        local word = tmain["line"][self.line].word;

        for k,v in pairs(tmain["line"]) do
            if k < self.line - 1 and word == v.word then
                self.duplicate_pos = k;
                break;
            end
        end

        if self.duplicate_pos > 0 then
            self.duplicate.isVisible = true;
            self.duplicate.y = self.scroll.area["line" .. self.line][1].y;
        end
    end

    -- modified all lines for clean
    function wm:setOff()
        local tm = os.time();
        -- print("setOff start " .. os.time());

        if self.line < self.clear_max then
            for k,v in pairs(tmain["line"]) do
                if v.off == 1 then
                    v.off = 0;
                    v.modified = 1;
                end

                if k > self.line then
                    v.off = 1;
                    v.modified = 1;
                end
            end
        else
            for k,v in pairs(tmain["line"]) do
                if v.off == 1 then
                    v.off = 0;
                    v.modified = 1;
                end
            end
        end

        self:updateColors();
        self:showClear{};

        -- print("setOff finish " .. os.time());
        -- ui.toast{text = (os.time() - tm)};
    end

    function wm:showClear(params)
        self.clear.isVisible = false;

        if self.line < self.clear_max then
            self.clear.isVisible = true;
            self.clear.y = self.scroll.area["line" .. self.line][1].y;
        end
    end

    local function onDuplicate(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            event.target.wm:gotoDuplicate();
        end

        return true;
    end

    local function onGoback(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            event.target.wm:gotoBack();
        end

        return true;
    end

    local function onClear(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            ui.toast{text = values.getText(values.labels["wm_clear_comment"])};
        end

        return true;
    end

    -- single word line
    local function wordLine(params)
        -- create word line object
        local wl = display.newGroup();

        function wl:update()

        end

        -- letter in word line
        local function letter(params)
            -- create letter object
            local letter = display.newGroup();

            -- event tap on letter
            local function onEvent(event)
                local target = event.target;

                -- change selected letter
                if ("ended" == event.phase) then
                    local ypos = target.ypos or event.y;
                    if math.abs(ypos - event.y) > 2 then
                        return false;
                    end

                    -- don't touch numbers
                    if (target.position ~= 1) then
                        target.wordmodule:selectLine{line = target.line, selected = target.position, update = true};
                        target.wordmodule:setOff();

                        -- hide info about duplicate
                        target.wordmodule.duplicate_pos = -1;
                        target.wordmodule.duplicate.isVisible = false;
                    end

                elseif event.phase == "began" then
                    target.ypos = event.y;

                elseif event.phase == "moved" then
                    -- transition move event to scroll area
                    local ypos = target.ypos or event.y;
                    if math.abs(ypos - event.y) > 2 then
                        target.wordmodule.scroll.area:onbegan(event);
                    end

                    return true;
                end

                return true;
            end

            -- change label by keyboard event
            function letter:setLbl(label)
                local time = os.time();

                if (self.line == self.wordmodule.line and self.position == self.wordmodule.selected) then
                    self.label.text = values.myUpper(label);
                end

                -- print("letter set label " .. (os.time() - time));

                return self.label.text or "#";
            end

            --
            function letter:setMode()
            end

            -- define image and color of object
            local image_nil = true;
            local image = "images/sq_bg_null_full.png";
            local color = values.color_blue;

            if (params.image) then
                image = params.image;
                image_nil = false;
            end

            if (params.color) then
                color = params.color;
            end

            letter.line = params.line;
            letter.position = params.position;
            letter.wordmodule = params.wordmodule;

            -- create image and label for letter object
            letter.back = display.newImage(image, width, height);
            letter.back.width = width;
            letter.back.height = height;
            letter.back:setReferencePoint(display.TopLeftReferencePoint);
            letter:insert(letter.back);

            letter.label = display.newText(values.myUpper(params.label or ""), 0, 0, values.font, 18 * 2);
            letter.label.xScale = 0.5; letter.label.yScale = 0.5;
            letter.label:setReferencePoint(display.CenterReferencePoint);
            letter.label:setTextColor(color[1], color[2], color[3]);
            letter:insert(letter.label);

            letter.x = params.left;
            letter.y = params.top;
            letter.back.x = 0;
            letter.back.y = 0;
            letter.label.x = letter.back.x + letter.back.width * 0.5;
            letter.label.y = letter.back.y + letter.back.height * 0.5;

            if color == values.color_red then
                letter.label.alpha = 0;
                letter.label:setTextColor(values.color_blue[1], values.color_blue[2], values.color_blue[3]);

                letter.labeld = display.newText(values.myUpper(params.label or ""), 0, 0, values.font, 18 * 2);
                letter.labeld.xScale = 0.5; letter.labeld.yScale = 0.5;
                letter.labeld:setReferencePoint(display.CenterReferencePoint);
                letter.labeld:setTextColor(color[1], color[2], color[3]);
                letter:insert(letter.labeld);

                letter.labeld.x = letter.back.x + letter.back.width * 0.5;
                letter.labeld.y = letter.back.y + letter.back.height * 0.5;

                transition.to(letter.label, {time = 2000, alpha = 1});
                transition.to(letter.labeld, {time = 2000, alpha = 0});
            end

            if image_nil then
                letter:remove(letter.back);
            end

            letter:addEventListener("touch", onEvent);

            return letter;
        end

        wl.word = params.word;
        wl.line = params.line;
        wl.linelb = params.linelb or "";
        wl.off = params.off or 0;
        wl.type = params.type or "";
        wl.selected = params.selected;
        wl.wordmodule = params.wordmodule;

        if (wl.word ~= "" and wl.type == "line") then
            wl.wordmodule.clear_max = math.max(wl.wordmodule.clear_max, wl.line);
        end

        -- print("CREATE WORDLINE", wl.word, string.len(wl.word), #wl.word, string.byte(wl.word, 1, #wl.word))
        -- create all letters of word
        -- for i = 1, #wl.word + 1 do
        for i = 1, values.getWordLenght(wl.word) + 1 do
            local label;
            if i == 1 then
                if wl.linelb == "" then
                    label = wl.line;
                    -- label = wl.word
                else
                    label = wl.linelb;
                end
            else
                -- label = string.sub(wl.word, i - 1, i - 1);
                label = values.getLetter(wl.word, i - 1);
            end

            -- print("CREATE LABEL", wl.word:upper(), i, label); -- ui.toast{text = wl.word}
            local pos = "pos" .. i;

            local top = 0;
            local left = (values.wordmodule_x + (i - 1) * cell) * values.scale + offsetW;
            if wl.type == "line" then
                top = ((wl.line - 2) * cell) * values.scale;
            else
                top = (values.wordmodule_y + (wl.line - 1) * cell) * values.scale + offsetH;
            end

            local function newLetter(params)
                local result;
                local color = params.color or values.color_blue;
                local image = params.image or "images/sq_bg_null_full.png";

                result = letter({
                    left = left,
                    top = top,
                    label = label,
                    line = wl.line,
                    position = i,
                    image = image,
                    color = color,
                    wordmodule = wl.wordmodule,
                });

                return result;
            end

            -- selected letter
            if (wl.selected == i) then
                wl[pos] = newLetter{image = "images/sq_bg_yellow.png"};

            -- off letter
            elseif (wl.off == 1) then
                wl[pos] = newLetter{color = values.color_grey};

            -- unselected letter
            else
                if wl.wordmodule.duplicate_pos == wl.line
                    and wl.type == "line" then
                    wl[pos] = newLetter{color = values.color_red};
                else
                    wl[pos] = newLetter{};
                end
            end

            wl:insert(wl[pos]);
        end

        -- print("WORDLINE", wl.line, wl.x, wl.y, wl.height)

        -- change selected letter in selected word
        function wl:setLbl(label)
            local tm = os.time();

            -- trying to change label letter by letter
            local newWord = "";
            -- for j = 1, #self.word + 1 do
            for j = 1, values.getWordLenght(self.word) + 1 do
                if (j > 1) then
                    newWord = newWord .. self["pos" .. j]:setLbl(label);
                end
            end

            -- change word in database
            if (values.myLower(self.word) ~= values.myLower(newWord)) then
                if (self.wordmodule:checkWord(newWord)) then

                    if self.wordmodule:updateWord{word = newWord} then
                        self.wordmodule:showDuplicate{};
                    end
                end
            end

            -- print("wordline set label " .. (os.time() - tm), "time " .. tm, "ostime " .. os.time());
        end

        return wl;
    end

    -- change word in database
    function wm:updateWord(params)
        local tm = os.time();

        local word = values.myLower(params.word);

        local count = 0;
        for k,v in pairs(tmain["line"]) do
            count = count + 1;
        end

        -- finish game
        -- print("finish game", "<" .. word .. ">", "<" .. self.finish .. ">")
        if word == self.finish then
            self:completeGame();

            return false;
        end

        local line = self.line;
        local newLine = line + 1;

        tmain["line"][line].word = word;
        tmain["line"][line].modified = 1;

        -- print("update", count, newLine);

        if count < newLine + 2 then
            local nl = count + 2;

            tmain["line"][nl] = {};
            tmain["line"][nl].off = 0;
            tmain["line"][nl].word = "";
            tmain["line"][nl].modified = 1;
            tmain["line"][nl].selected = 0;

            tmain["finish"][values.finish_line].linelb = nl + 1;
            tmain["finish"][values.finish_line].modified = 1;
        end

        --[[
        for k,v in pairs(tmain["line"]) do
            print("updateline", k, v.word);
        end
        ]]--

        tmain["line"][newLine].word = word;
        tmain["line"][newLine].modified = 1;

        -- positioning on added line
        self:selectLine{line = newLine, selected = 2, update = true};

        self:setScrollBackground();

        -- print("updateWord time " .. (os.time() - tm), "time " .. tm, "ostime " .. os.time());

        return true;
    end

    -- update info about selected line on database
    function wm:selectLine(params)
        self.line = params.line;
        self.selected = params.selected;

        for k,v in pairs(tmain["line"]) do
            if v.selected ~= 0 then
                v.selected = 0;
                v.modified = 1;
            end

            if k == self.line then
                v.selected = self.selected;
                v.modified = 1;
            end
        end

        -- refresh lines in word module, if update is needed
        if (params.update and params.update == true) then
            self:updateColors();
        end
    end

    -- get word line from database
    function wm:readLine(params)
        local linelb;
        local type = params.type;
        local line = params.line or 0;
        local word = params.word or "";
        local selected, off = 0, 0;

        local sql;
        local count = 0;

        -- print("readLine " .. #tmain)

        -- searching word in table by line and type
        local isnew = false;
        local ttype = tmain[type] or nil;
        if ttype == nil then
            isnew = true;
        else
            local tline = ttype[line];

            if tline == nil then
                isnew = true;
            else
                word = tline.word;
                linelb = tline.linelb or "";
                selected = tline.selected;
                off = tline.off;
            end
        end

        -- first filling
        if (line == 2 and word == "") then
            word = self.start;
            selected = 2;
        end

        -- set selected number for word module
        if (selected ~= 0) then
            self.line = line;
            self.selected = selected;
        end

        -- inserting data into database
        if isnew then
            if tmain[type] == nil then
                tmain[type] = {};
            end

            tmain[type][line] = {};
            tmain[type][line].word = word;
            tmain[type][line].selected = selected;
            tmain[type][line].modified = 0;
            tmain[type][line].off = 0;
        end

        -- add new object into parent object
        local name = type .. line;

        -- rewrite ref to word line in word module
        if (type == "line") then
            if self.scroll.area[name] then
                self.scroll.area[name]:removeSelf();
            end

            self.scroll.area:remove(self.scroll.area[name]);

            -- create and add new word line
            self.scroll.area[name] = nil;
            self.scroll.area[name] = wordLine({word = word, line = line, selected = selected, wordmodule = self, off = off, type = "line"});
            self.scroll.area:insert(self.scroll.area[name]);

            self.lines["line" .. line] = self.scroll.area[name];
        else
            -- delete old word line
            self:remove(self[name]);

            -- create and add new word line
            self[name] = nil;
            self[name] = wordLine({word = word, line = line, selected = selected, wordmodule = self, type = type, linelb = linelb});
            self:insert(self[name]);
        end

        return word;
    end

    -- update modified lines
    function wm:updateColors(params)
        local t = os.time();
        -- print(params.all, #tmain)

        for kt,vt in pairs(tmain) do
            for k,v in pairs(vt) do
                if v.modified == 1 then
                    -- print(kt, k, v.word);

                    self:readLine{line = k, type = kt};
                    v.modified = 0;
                end
            end
        end

        -- print(params.all, #tmain)
        ui.toast{text = "updateColors " .. (os.time() - t)}
        -- print("updateColors " .. (os.time() - t));
    end

    -- get letter from keyboard
    function wm:receiveLetter(letter)
        if receiveButtonEvents == false then
            return false;
        end;

        print("scPlay", "receiveLetter", letter, self.line, self.selected);

        self.lines["line" .. self.line]:setLbl(letter);
    end

    function wm:setScrollBackground()
        local maxline = math.max(#tmain["line"], 10);

        self.scroll.area:remove(wm.scroll.area.scrollBackground);

        self.scroll.area.scrollBackground = display.newRect(0, 0, values.wordmodule_width * values.scale, (maxline - 1) * values.cell * values.scale)
        self.scroll.area.scrollBackground:setFillColor(255, 255, 255, 200);
        self.scroll.area:insert(1, wm.scroll.area.scrollBackground);

        -- wm.scroll.area:removeScrollBar();
        self.scroll.area:addScrollBar();

        -- print("setScrollBackground", self.scroll.area.scrollBackground.x, self.scroll.area.scrollBackground.y, self.scroll.area.scrollBackground.height)
    end

    -- get start and finish lines
    wm.start = wm:readLine{type = "start", word = wm.start, line = values.start_line};
    wm.finish = wm:readLine{type = "finish", word = wm.finish, line = values.finish_line};

    -- add scrollable area
    wm.scroll = display.newGroup();
    wm:insert(wm.scroll);

    local tops = (values.wordmodule_y + values.cell) * values.scale + offsetH;
    local bottoms = viewScreenH - (values.wordmodule_y + values.cell * 10) * values.scale - offsetH;

    -- print("TOP BOTTOM", tops, bottoms, offsetW, offsetH)
    -- print(display.contentHeight, display.viewableContentHeight, values.wordmodule_y, display.screenOriginY, (values.wordmodule_y + values.cell * 10), (values.wordmodule_y + values.cell * 10) * values.scale)

    -- print(wm.start, wm.finish);

    wm.scroll.area = scrollView.new{
        top = tops,
        bottom = bottoms,
        offsetScroll = values.cell * (values.myLenght(wm.start) + 3) * values.scale,
    };
    wm.scroll:insert(wm.scroll.area);

    -- masking scroll area
    local mask;
    if viewScreenH < display.contentHeight then
        mask = graphics.newMask("images/playMaskIpad.jpg", system.ResourceDirectory);
    else
        mask = graphics.newMask("images/playMask.jpg", system.ResourceDirectory);
    end

    wm.scroll:setMask(nil);
    wm.scroll:setMask(mask);

    wm.scroll.maskX = values.cell * 9 * values.scale / 2 + values.wordmodule_x * values.scale + offsetW;
    wm.scroll.maskY = values.cell * 9 * values.scale / 2 + (values.wordmodule_y + values.cell) * values.scale + offsetH;

    -- add control labels
    wm.duplicate = ui.myTextWithImage{name = "wm_duplicate"};
    wm.duplicate.wm = wm;
    wm.duplicate:addEventListener("touch", onDuplicate);
    wm.duplicate.isVisible = false;
    wm.scroll.area:insert(wm.duplicate);

    wm.goback = ui.myTextWithImage{name = "wm_goback"};
    wm.goback.wm = wm;
    wm.goback:addEventListener("touch", onGoback);
    wm.goback.isVisible = false;
    wm.scroll.area:insert(wm.goback);

    wm.clear = ui.myTextWithImage{name = "wm_clear"};
    wm.clear.wm = wm;
    wm.clear:addEventListener("touch", onClear);
    wm.clear.isVisible = false;
    wm.scroll.area:insert(wm.clear);

    -- creating lines
    local count = 0;
    for row in db_main:nrows("SELECT * FROM " .. gametable .. " WHERE type='line' AND language='" .. values.game_language .. "';") do
        count = count + 1;
    end

    -- create lines from database, min 9 lines from 2 to 10
    local maxline = math.max(count + 1, 10);
    for i = 2, maxline do
        wm:readLine({line = i, type = "line"});
    end

    wm:setScrollBackground();

    -- print("SCROLL AREA", wm.scroll.area.x, wm.scroll.area.y, wm.scroll.area.height)

    wm.scroll.area:addScrollBar();

    wm.notindict = ui.myText{name = "wm_notindict", refPoint = display.TopLeftReferencePoint};
    wm:insert(wm.notindict);

    wm.iknow = ui.myText{name = "wm_iknow", refPoint = display.TopLeftReferencePoint};
    wm:insert(wm.iknow);

    wm.notindict.isVisible = false;
    wm.iknow.isVisible = false;

    -- print(wm.line, wm.selected);

    return wm;
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
    local screen = display.newGroup();
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

    --[[
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