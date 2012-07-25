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

local function loadMain()
    local sql = "SELECT * FROM " .. gametable .. " ORDER BY type, line;";

    for row in db_main:nrows(sql) do
        local type = row.type;
        local line = row.line;

        local ttype = tmain[type] or {};
        local tline = ttype[line] or {};

        tline.word = row.word;
        tline.linelb = row.linelb;
        tline.modified = row.modified;
        tline.selected = row.selected;
        tline.off = row.off;

        tmain[type] = ttype;
        tmain[type][line] = tline;

        print(type, line, tline.word);
    end
end

local function saveMain()
    local sql = "DELETE FROM " .. gametable .. ";";

    for k,v in pairs(tmain) do
        for k1,v1 in pairs(v) do
            -- print("INSERT", k, k1, v1.word, v1.selected, v1.modified, v1.off);

            local linelb = v1.linelb or "";
            sql = sql .. "INSERT into " .. gametable .. " ('type', 'line', 'linelb', 'word', 'selected', 'modified', 'off') VALUES ('" .. k .. "'," .. k1 .. ",'" .. linelb .. "','" .. v1.word:lower() .. "'," .. v1.selected .. "," .. v1.modified .. "," .. v1.off .. ");";
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

-- entirely module of words
local function wordModule(params)
    local cell = values.cell;

    -- define sizes of image
    local width, height = values.getImageSizes("images/sq_bg_null_full.png");

    -- create word module
    local wm = display.newGroup();

    wm.start = params.start or ""; -- start word
    wm.finish = params.finish or ""; -- finish word

    wm.line = 2; -- edited line
    wm.selected = 2; -- edited position of letter (first is row number)

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

        local sql = "SELECT * FROM dict WHERE word='" .. string.lower(word) .. "';";
        for row in db_words:nrows(sql) do
            -- hide label about incorrect word
            self.notindict.isVisible = false;
            self.iknow.isVisible = false;

            result = true;
            break;
        end

        return result;
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
                if (self.line == self.wordmodule.line and self.position == self.wordmodule.selected) then
                    self.label.text = string.upper(label);
                end

                return self.label.text or "#";
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

            letter.label = display.newText(string.upper(params.label or ""), 0, 0, values.font, 18 * 2);
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

                letter.labeld = display.newText(string.upper(params.label or ""), 0, 0, values.font, 18 * 2);
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

        print(wl.type, wl.line, wl.word)

        -- create all letters of word
        for i = 1, #wl.word + 1 do
            local label;
            if i == 1 then
                if wl.linelb == "" then
                    label = wl.line;
                else
                    label = wl.linelb;
                end
            else
                label = string.sub(wl.word, i - 1, i - 1);
            end

            local pos = "pos" .. i;

            local top = 0;
            local left = (values.wordmodule_x + (i - 1) * cell) * values.scale + display.screenOriginX;
            if wl.type == "line" then
                top = ((wl.line - 2) * cell) * values.scale + display.screenOriginY;
            else
                top = (values.wordmodule_y + (wl.line - 1) * cell) * values.scale + display.screenOriginY;
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

        -- change selected letter in selected word
        function wl:setLbl(label)
            -- trying to change label letter by letter
            local newWord = "";
            for j = 1, #self.word + 1 do
                if (j > 1) then
                    newWord = newWord .. self["pos" .. j]:setLbl(label);
                end
            end

            -- change word in database
            if (self.word:lower() ~= newWord:lower()) then
                if (self.wordmodule:checkWord(newWord)) then

                    self.wordmodule:updateWord{word = newWord};
                    self.wordmodule:showDuplicate{};
                end
            end
        end

        return wl;
    end

    -- change word in database
    function wm:updateWord(params)
        local word = params.word:lower();

        local line = self.line;
        local newLine = line + 1;

        tmain["line"][line].word = word;
        tmain["line"][line].modified = 1;

        local count = 0;
        for k,v in pairs(tmain["line"]) do
            count = count + 1;
        end

        print("update", count, newLine);

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

        for k,v in pairs(tmain["line"]) do
            print("updateline", k, v.word);
        end

        tmain["line"][newLine].word = word;
        tmain["line"][newLine].modified = 1;

        -- positioning on added line
        self:selectLine{line = newLine, selected = 2, update = true};
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
        for kt,vt in pairs(tmain) do
            for k,v in pairs(vt) do
                if v.modified == 1 then
                    print(kt, k, v.word);

                    self:readLine{line = k, type = kt};
                    v.modified = 0;
                end
            end
        end
    end

    -- get letter from keyboard
    function wm:receiveLetter(letter)
        print("scPlay", "receiveLetter", letter, self.line, self.selected);

        self.lines["line" .. self.line]:setLbl(letter);
    end

    -- get start and finish lines
    wm.start = wm:readLine{type = "start", word = wm.start, line = values.start_line};
    wm.finish = wm:readLine{type = "finish", word = wm.finish, line = values.finish_line};

    -- add scrollable area
    wm.scroll = display.newGroup();
    wm:insert(wm.scroll);

    wm.scroll.area = scrollView.new{top = (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY,
        bottom = display.contentHeight - (values.wordmodule_y + values.cell * 10) * values.scale - display.screenOriginY,
        offsetScroll = values.cell * (#wm.start + 3) * values.scale};
    wm.scroll:insert(wm.scroll.area);

    -- masking scroll area
    local mask = graphics.newMask("images/tmp.jpg", system.ResourceDirectory);

    wm.scroll:setMask(nil);
    wm.scroll:setMask(mask);

    wm.scroll.maskX = values.cell * 9 * values.scale / 2 + values.wordmodule_x * values.scale + display.screenOriginX;
    wm.scroll.maskY = values.cell * 9 * values.scale / 2 + (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY;

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
    for row in db_main:nrows("SELECT * FROM " .. gametable .. " WHERE type='line';") do
        count = count + 1;
    end

    -- create lines from database, min 9 lines from 2 to 10
    for i = 2, math.max(count + 1, 10) do
        wm:readLine({line = i, type = "line"});
    end

    local scrollBackground = display.newRect(0, 0, values.wordmodule_width * values.scale, 14 * values.cell * values.scale)
    scrollBackground:setFillColor(255, 255, 255, 200)
    wm.scroll.area:insert(1, scrollBackground)

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
        gametable = params.gametable or values.tblsingleplay;
        start, finish = params.start or "", params.finish or "";
    end

    -- create screen
    local screen = display.newGroup();

    -- module for words editing
    dbInit();

    -- clearing word module for new game
    if (start ~= "" and finish ~= "") then
        db_main:exec("DELETE FROM " .. gametable .. ";");
    end

    -- load data to temp table
    loadMain();

    -- creating game module
    local wm = wordModule{start = start, finish = finish};

    screen:insert(ui.getBackground());

    screen.wm = wm;
    screen:insert(screen.wm);

    name = "startfinish";
    screen.startfinish = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, text = wm.start .. " -> " .. wm.finish};
    screen:insert(screen.startfinish);

    -- temp clear game

    local function onKillStop()
        if receiveButtonEvents == false then
            return false;
        end;

        tmain = {};

        local sql = "DELETE FROM " .. gametable .. ";";
        db_main:exec(sql);

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
end

function scene:enterScene(event)
    print("scPlay", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
        loadMain();
    end
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