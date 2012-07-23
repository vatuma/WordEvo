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

local receiveButtonEvents = false;

-- databases
local gametable;

local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);

local db_words;
local path_words = system.pathForFile(values.db_name[values.game_language], system.ResourceDirectory);

local main = {}; -- table for game process

local function loadMain()
    local sql = "SELECT * FROM " .. gametable .. " ORDER BY type, line;";

    for row in db_main:nrows(sql) do
        local type = row.type;
        local line = row.line;

        local ttype = main[type] or {};
        local tline = ttype[line] or {};

        tline.word = row.word;

        print(type, line, tline.word);
    end
end

local function saveMain()
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

-- check new word by dictionary
local function checkWord(word, wordmodule)
    local result = false;

    wordmodule.notindict.isVisible = true;
    wordmodule.iknow.isVisible = true;

    wordmodule.dup = -1;
    wordmodule.duplicate.isVisible = false;

    wordmodule.cle = -1;
    wordmodule.clear.isVisible = false;

    local sql = "SELECT * FROM dict WHERE word='" .. string.lower(word) .. "';";
    for row in db_words:nrows(sql) do
        wordmodule.notindict.isVisible = false;
        wordmodule.iknow.isVisible = false;

        result = true;
        break;
    end

    local sqld = "SELECT * FROM " .. gametable .. " WHERE word='" .. string.lower(word) .. "' AND type='line';";
    for row in db_main:nrows(sqld) do
        wordmodule.dup = row.line;
        wordmodule:showDuplicate{};
    end

    return result;
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
    wm.dup = -1; -- line to go duplicate
    wm.max = 2; -- count of filled lines
    wm.selected = 2; -- edited position of letter (first is row number)

    wm.lines = {}; -- all lines for quick link

    function wm:gotoDuplicate()

    end

    function wm:showDuplicate(params)
        self.duplicate.isVisible = true;
        self.duplicate.y = self.scroll.area["line" .. self.line][1].y;
    end

    function wm:showClear(params)
        self.clear.isVisible = false;

        print(self.line, self.max)

        if self.line < self.max then
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

    local function onClear(event)
        if receiveButtonEvents == false then
            return false;
        end;

        if event.phase == "ended" then
            ui.toast{text = values.getText(values.labels["wm_clear_comment"])};
        end

        return true;
    end

    function wm:setOff()
        local sql;

        print(self.line, self.max)

        if (self.line < self.max) then
            sql = "UPDATE " .. gametable .. " SET off=0, modified=1 WHERE off=1 AND type='line';";
            db_main:exec(sql);

            sql = "UPDATE " .. gametable .. " SET off=1, modified=1 WHERE line>" .. self.line .. " AND type='line';";
        else
            sql = "UPDATE " .. gametable .. " SET off=0, modified=1 WHERE off=1;";
        end

        db_main:exec(sql);
        self:updateColors();
        self:showClear{};
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

                -- print("TOUCH LETTER", target.label.text, target.line, target.position);

                -- change selected letter
                if ("ended" == event.phase) then
                    -- don't touch numbers
                    if (target.position ~= 1) then
                        target.wordmodule:selectLine{line = target.line, selected = target.position, update = true};
                        target.wordmodule:setOff();
                    end
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

            -- print("LABEL", letter.label.text);

            letter.x = params.left;
            letter.y = params.top;
            letter.back.x = 0;
            letter.back.y = 0;
            letter.label.x = letter.back.x + letter.back.width * 0.5;
            letter.label.y = letter.back.y + letter.back.height * 0.5;

            if image_nil then
                letter:remove(letter.back);
            end

            letter:addEventListener("touch", onEvent);

            return letter;
        end

        wl.word = params.word;
        wl.line = params.line;
        wl.off = params.off or 0;
        wl.type = params.type or "";
        wl.selected = params.selected;
        wl.wordmodule = params.wordmodule;

        if (wl.word ~= "" and wl.type == "line") then
            wl.wordmodule.max = math.max(wl.wordmodule.max, wl.line);
        end

        -- create all letters of word
        for i = 1, #wl.word + 1 do
            local label;
            if i == 1 then
                label = wl.line;
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

            -- selected letter
            if (wl.selected == i) then
                wl[pos] = letter({
                    left = left,
                    top = top,
                    label = label,
                    line = wl.line,
                    position = i,
                    image = "images/sq_bg_yellow.png",
                    wordmodule = wl.wordmodule,
                });
            elseif (wl.off == 1) then
                wl[pos] = letter({
                    left = left,
                    top = top,
                    label = label,
                    line = wl.line,
                    position = i,
                    wordmodule = wl.wordmodule,
                    color = values.color_grey,
                });
                -- unselected letter
            else
                wl[pos] = letter({
                    left = left,
                    top = top,
                    label = label,
                    line = wl.line,
                    position = i,
                    wordmodule = wl.wordmodule,
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

            -- change word in database
            if (self.word:lower() ~= newWord:lower()) then
                if (checkWord(newWord, self.wordmodule)) then
                    print("want to add row", string.lower(wl.word), string.lower(newWord));

                    self.wordmodule:updateWord{word = newWord};
                else
                    print("HAVEN't WORD " .. newWord);
                end
            end
        end

        return wl;
    end

    -- change word in database
    function wm:updateWord(params)
        local word = params.word;

        local line = self.line;
        local newLine = line + 1;

        local sql = "UPDATE " .. gametable .. " SET word='" .. word:lower() .. "', modified=1 WHERE  line=" .. line .. " AND type='line';";
        local sqlnew = "UPDATE " .. gametable .. " SET word='" .. word:lower() .. "', modified=1 WHERE line=" .. newLine .. " AND type='line';";

        -- there check total line count, add new line before update if necessary

        -- update word lines in database
        db_main:exec(sql);
        db_main:exec(sqlnew);

        -- positioning on added line
        self:selectLine{line = newLine, selected = 2, update = true};
    end

    -- update info about selected line on database
    function wm:selectLine(params)
        self.line = params.line;
        self.selected = params.selected;

        -- modified lines with selected letter in database
        local sql = "SELECT * FROM " .. gametable .. " WHERE NOT selected=0;";
        for row in db_main:nrows(sql) do
            local sql = "UPDATE " .. gametable .. " SET selected=0, modified=1 WHERE line=" .. row.line .. " AND type='line';";
            db_main:exec(sql);
        end

        -- modified added line
        local sqlnew = "UPDATE " .. gametable .. " SET selected=" .. self.selected .. ", modified=1 WHERE line=" .. self.line .. " AND type='line';";
        db_main:exec(sqlnew);

        -- refresh lines in word module, if update is needed
        if (params.update and params.update == true) then
            self:updateColors();
        end
    end

    -- get word line from database
    function wm:readLine(params)
        local word = params.word or "";
        local line = params.line or 0;
        local type = params.type;
        local selected = 0;
        local off = 0;

        local sql;
        local count = 0;

        -- trying to get word from database
        if (line == 0) then
            sql = "SELECT * FROM " .. gametable .. " WHERE type='" .. type .. "';";
        else
            sql = "SELECT * FROM " .. gametable .. " WHERE type='" .. type .. "' AND line=" .. line .. ";";
        end

        -- get data from database
        for row in db_main:nrows(sql) do
            word = row.word or "";
            line = row.line;
            selected = row.selected;
            off = row.off;

            count = count + 1;
        end

        -- first filling
        if (line == 2 and word == "") then
            word = self.start;
            selected = 2;
        end

        -- set selected number for word module
        if (selected ~= 0) then
            self.selected = selected;
        end

        -- inserting data into database
        if (count == 0) then
            local sql = "INSERT into " .. gametable .. " ('line', 'type', 'word', 'selected') VALUES (" .. line .. ", '" .. type .. "', '" .. word:lower() .. "', " .. selected .. ");"
            db_main:exec(sql);
        end

        -- add new object into parent object
        local name = type .. line;

        -- rewrite ref to word line in word module
        if (type == "line") then
            -- print("LB", self.scroll.numChildren, self.numChildren, self.scroll[name]);

            -- delete old word line
            -- --[[
            if self.scroll.area[name] then
                self.scroll.area[name]:removeSelf();
            end

            self.scroll.area:remove(self.scroll.area[name]);
            -- ]]--

            --[[
            if self.scroll[name] then
                self.scroll[name]:removeSelf();
            end

            self.scroll:remove(self.scroll[name]);
            ]]--

            -- create and add new word line
            -- --[[
            self.scroll.area[name] = nil;
            self.scroll.area[name] = wordLine({word = word, line = line, selected = selected, wordmodule = self, off = off, type = "line"});
            self.scroll.area:insert(self.scroll.area[name]);

            self.lines["line" .. line] = self.scroll.area[name];
            -- ]]--

            --[[
            self.scroll[name] = nil;
            self.scroll[name] = wordLine({word = word, line = line, selected = selected, wordmodule = self, off = off, type = "line"});
            self.scroll:insert(self.scroll[name]);

            self.lines["line" .. line] = self.scroll[name];
            ]]--

            -- print("LA", self.scroll.numChildren, self.numChildren, self.scroll[name]);
        else
            -- print("NL", self.numChildren);

            -- delete old word line
            self:remove(self[name]);

            -- create and add new word line
            self[name] = nil;
            self[name] = wordLine({word = word, line = line, selected = selected, wordmodule = self});
            self:insert(self[name]);
        end

        return word;
    end

    -- update modified lines
    function wm:updateColors(params)
        local sql = "SELECT * FROM " .. gametable .. " WHERE modified = 1;";
        for row in db_main:nrows(sql) do
            self:readLine{line = row.line, type = "line"};

            -- unmodified readed line
            if (row.modified == 1) then
                local sql = "UPDATE " .. gametable .. " SET modified = 0 WHERE line=" .. row.line .. " AND type='line';";
                db_main:exec(sql);
            end
        end
    end

    -- get letter from keyboard
    function wm:receiveLetter(letter)
        print("scPlay", "receiveLetter", letter, self.line, self.selected);

        self.lines["line" .. self.line]:setLbl(letter);
    end

    -- get start and finish lines
    wm.start = wm:readLine{type = "start", word = wm.start, line = 1};
    wm.finish = wm:readLine{type = "finish", word = wm.finish, line = 11};

    -- add scrollable area
    local mask = graphics.newMask("images/tmp.jpg", system.ResourceDirectory);

    wm.scroll = display.newGroup();
    wm:insert(wm.scroll);

    wm.scroll.area = scrollView.new{top = (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY, bottom = display.contentHeight - (values.wordmodule_y + values.cell * 10) * values.scale - display.screenOriginY};
    wm.scroll:insert(wm.scroll.area);

    -- wm.scroll.x = values.wordmodule_x * values.scale + display.screenOriginX;
    -- wm.scroll.y = (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY

    -- print(wm.scroll.top, wm.scroll.bottom, wm.scroll.x, wm.scroll.y, wm.scroll.width)

    print(wm.scroll.x, wm.scroll.y, wm.scroll.area.top, wm.scroll.area.bottom)

    wm.scroll:setMask(nil);
    wm.scroll:setMask(mask);

    wm.scroll.maskX = values.cell * 9 * values.scale / 2 + values.wordmodule_x * values.scale + display.screenOriginX;
    wm.scroll.maskY = values.cell * 9 * values.scale / 2 + (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY;

    --[[
    wm.scroll = widget.newScrollView{
        left = values.wordmodule_x * values.scale + display.screenOriginX,
        top = (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY,
        width = values.cell * 9 * values.scale,
        height = values.cell * 9 * values.scale,
        bgColor = {0, 255, 0, 100},
        -- listener = "",
    };
    wm:insert(wm.scroll);

    wm.scroll:setMask(nil);
    wm.scroll:setMask(mask);

    wm.scroll.maskX = wm.scroll.width/2
    wm.scroll.maskY = wm.scroll.height/2 - 0 * values.scale
    ]]--

    --[[
    local function onArea(event)
        local target = event.target;

        print("onArea");

        if event.phase == "moved" then
            target.y = event.y;
        end
    end

    wm.scroll = display.newGroup();
    wm.scroll:addEventListener("touch", onArea);
    wm:insert(wm.scroll);

    wm.scroll.area = display.newGroup();
    wm.scroll.area:addEventListener("touch", onArea);
    wm.scroll:insert(wm.scroll.area);

    wm.scroll:setMask(nil);
    wm.scroll:setMask(mask);

    print(wm.scroll.maskX, wm.scroll.maskY)

    wm.scroll.maskX = values.cell * 9 * values.scale / 2 + values.wordmodule_x * values.scale + display.screenOriginX;
    wm.scroll.maskY = values.cell * 9 * values.scale / 2 + (values.wordmodule_y + values.cell) * values.scale + display.screenOriginY;

    print(wm.scroll.maskX, wm.scroll.maskY)

    wm:insert(ui.runner{area = wm.scroll.area, size = values.cell * 9 * values.scale, sizefull = values.cell * 14 * values.scale});
    ]]--

    wm.duplicate = ui.myTextWithImage{name = "wm_duplicate"};
    wm.duplicate.wm = wm;
    wm.duplicate:addEventListener("touch", onDuplicate);
    wm.duplicate.isVisible = false;
    -- wm.scroll.area:insert(wm.duplicate);
    wm.scroll:insert(wm.duplicate);

    wm.clear = ui.myTextWithImage{name = "wm_clear"};
    wm.clear.wm = wm;
    wm.clear:addEventListener("touch", onClear);
    wm.clear.isVisible = false;
    -- wm.scroll.area:insert(wm.clear);
    wm.scroll:insert(wm.clear);

    -- creating lines
    local count = 0;
    for row in db_main:nrows("SELECT * FROM " .. gametable .. " WHERE type='line';") do
        count = count + 1;
    end

    -- print("LS", wm.scroll.numChildren, wm.numChildren);

    -- create lines from database, min 9 lines from 2 to 10
    for i = 2, math.max(count + 1, 15) do
        wm:readLine({line = i, type = "line"});
    end

    local scrollBackground = display.newRect(0, 0, values.wordmodule_width * values.scale, 14 * values.cell * values.scale)
    scrollBackground:setFillColor(255, 255, 255, 200)
    wm.scroll.area:insert(1, scrollBackground)

    wm.scroll.area:addScrollBar();

    -- print("LF", wm.scroll.numChildren, wm.numChildren);

    local name;

    name = "wm_notindict";
    wm.notindict = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
    wm:insert(wm.notindict);

    name = "wm_iknow";
    wm.iknow = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
    wm:insert(wm.iknow);

    wm.notindict.isVisible = false;
    wm.iknow.isVisible = false;

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

    local screen = display.newGroup();

    -- module for words editing
    dbInit();
    loadMain();

    -- clearing word module for new game
    if (start ~= "" and finish ~= "") then
        db_main:exec("DELETE FROM " .. gametable .. ";");
    end

    local wm = wordModule{start = start, finish = finish};

    -- create screen
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
    end
end

function scene:exitScene(event)
    print("scPlay", "exitScene");

    receiveButtonEvents = false;

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