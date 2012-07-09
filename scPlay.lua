--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 22:42
-- To change this template use File | Settings | File Templates.
--

require("Keyboard");

local storyboard = require("storyboard");
local widget = require("widget");
local strings = require("strings")
local dimens = require("dimens")
local sqlite = require("sqlite3");

local scene = storyboard.newScene();

local ui = require("ui")

local screenWidth;
local screenHeight;

local scale = dimens.scale;

local name_main = "main.sqlite"; -- working database inside of application
local name_mainr = "dict/main.sqlite";
local name_words = strings.db_name["en"]; -- dictionary database

local path_main = system.pathForFile(name_main, system.DocumentsDirectory);
local file_main = io.open(path_main, "r");
local db_main;

local path_words = system.pathForFile(name_words, system.ResourceDirectory);
-- local file_words = io.open(path_words, "r");
local db_words;

local function checkWord(word)
    local result = false;

    local sql = "SELECT * FROM dict WHERE word='" .. string.lower(word) .. "';";
    print(sql);
    for row in db_words:nrows(sql) do
        result = true;
        break;
    end

    return result;
end

-- entirely module of words
local function wordModule(params)
    local cell = dimens.main_dimens.cell;

    -- define sizes of image
    local image = display.newImage("images/sq_bg_null_full.png");
    local width = image.width * scale;
    local height = image.height * scale;
    image:removeSelf();
    image = nil;

    -- create word module
    local wm = display.newGroup();

    wm.start = params.start; -- start word
    wm.finish = params.finish; -- finish word

    wm.line = 2; -- edited line
    wm.selected = 2; -- edited position of letter (first is row number)

    wm.lines = {}; -- all lined

    -- single word line
    local function wordLine(params)
        -- create word line object
        local wl = display.newGroup();

        -- letter in word line
        local function letter(params)
            -- create letter object
            local letter = display.newGroup();

            local function onEvent(event)
                local target = event.target;

                -- change selected letter
                if ("ended" == event.phase) then
                    -- don't touch numbers
                    if (target.position ~= 1) then
                        target.parent.parent:selectLine{line = target.line, selected = target.position, update = true};
                    end

                    --[[
                    target.parent.parent.line = target.line;
                    target.parent.parent.selected = target.position;

                    -- update line in database
                    local sql2 = "UPDATE wordmodule SET selected=" .. target.position .. " WHERE line=" .. target.line .. " AND type='line';";
                    db_main:exec(sql2);

                    -- refresh line from database
                    target.parent.parent:readLine{type = "line", line = target.line};
                    ]]--
                end
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
            local color = {0, 0, 0};

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
            letter.label:setTextColor(color);
            letter:insert(letter.label);

            letter.x = params.left;
            letter.y = params.top;
            letter.back.x = 0;
            letter.back.y = 0;
            letter.label.x = letter.back.x + letter.back.width * 0.5;
            letter.label.y = letter.back.y + letter.back.height * 0.5;

            letter:addEventListener("touch", onEvent);

            --[[
            local l = widget.newButton{
                label = string.upper(params.label or ""),
                left = params.left,
                top = params.top,
                width = width,
                height = height,
                font = "Vatuma Script slc",
                fontSize = 18,
                default = "images/sq_bg_null_full.png",
                onEvent = onEvent,
            };
            ]]--

            --[[
            l.line = params.line;
            l.position = params.position;

            function l:invert()
                local label = self:getLabel();
                if (self.line == self.parent.parent.line and self.position == self.parent.parent.selected) then
                    print("LOWER", label, self.line, self.parent.parent.line, self.position, self.parent.parent.selected);
                    self:setLabel(string.lower(label));
                else
                    print("UPPER", label, type(self.line), type(self.parent.parent.line), type(self.position), type(self.parent.parent.selected));
                    self:setLabel(string.upper(label));
                end
            end
            ]]--

            return letter;
        end

        wl.word = params.word;
        wl.line = params.line;
        wl.selected = params.selected;

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
                    left = (dimens.word_block.x + (i - 1) * cell) * scale,
                    top = (dimens.word_block.y + (wl.line - 1) * cell) * scale,
                    label = label,
                    line = wl.line,
                    position = i,
                    image = "images/sq_bg_yellow.png",
                });
            -- unselected letter
            else
                wl[pos] = letter({
                    left = (dimens.word_block.x + (i - 1) * cell) * scale,
                    top = (dimens.word_block.y + (wl.line - 1) * cell) * scale,
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

            -- change word in database
            if (string.lower(self.word) ~= string.lower(newWord)) then
                if (checkWord(newWord)) then
                    print("want to add row", string.lower(wl.word), string.lower(newWord));

                    self.parent:updateWord{word = newWord};
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
        print("UPDATE WORD", self.line, self.selected, word);

        local line = self.line;
        local newLine = line + 1;

        local sql = "UPDATE wordmodule SET word='" .. word .. "', modified=1 WHERE line=" .. line .. " AND type='line';";
        local sqlnew = "UPDATE wordmodule SET word='" .. word .. "', modified=1 WHERE line=" .. newLine .. " AND type='line';";

        -- there check total line count, add new line before update if necessary

        print(sql);
        print(sqlnew);

        -- update word lines in database
        db_main:exec(sql);
        db_main:exec(sqlnew);

        self:selectLine{line = newLine, selected = 2, update = true};
        -- self:updateColors();

        --[[
        -- refresh lines on screen
        self:readLine({line = line, type = "line"});
        self:readLine({line = newLine, type = "line"});

        -- update current line and selected in word module
        self.line = newLine;
        self.selected = 2;
        ]]--
    end

    function wm:selectLine(params)
        self.line = params.line;
        self.selected = params.selected;

        local sql = "SELECT * FROM wordmodule WHERE NOT selected=0;";
        for row in db_main:nrows(sql) do
            local sql = "UPDATE wordmodule SET selected=" .. 0 .. ", modified=1 WHERE line=" .. row.line .. " AND type='line';";
            db_main:exec(sql);
        end

        local sqlnew = "UPDATE wordmodule SET selected=" .. self.selected .. ", modified=1 WHERE line=" .. self.line .. " AND type='line';";
        db_main:exec(sqlnew);

        if (params.update and params.update == true) then
            self:updateColors();
        end
    end

    -- get word line from database
    function wm:readLine(params)
        -- print("wm:readLine " .. type(params.line));

        local word = params.word or "";
        local line = params.line or 0;
        local type = params.type;
        local selected = 0;

        local sql;
        local count = 0;

        -- trying to get word from database
        if (line == 0) then
            sql = "SELECT * FROM wordmodule WHERE type='" .. type .. "';";
        else
            sql = "SELECT * FROM wordmodule WHERE type='" .. type .. "' AND line=" .. line .. ";";
        end

        -- get data from database
        for row in db_main:nrows(sql) do
            word = row.word or "";
            line = row.line;
            selected = row.selected;

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
            local sql = "INSERT into wordmodule ('line', 'type', 'word', 'selected') VALUES (" .. line .. ", '" .. type .. "', '" .. word .. "', " .. selected .. ");"
            print(sql);
            db_main:exec(sql);
        end

        -- add new object into parent object
        local name = type .. line;

        -- delete old word line
        self:remove(self[name]);

        -- create and add new word line
        self[type .. line] = wordLine({word = word, line = line, selected = selected});
        self:insert(self[name]);

        -- rewrite ref to word line in word module
        if (type == "line") then
            self.lines[line] = self[name];
        end
    end

    wm:readLine{type = "start", word = wm.start, line = 1};
    wm:readLine{type = "finish", word = wm.finish, line = 11};

    -- creating lines
    local count = 0;
    for row in db_main:nrows("SELECT * FROM wordmodule WHERE type='line';") do
        count = count + 1;
    end

    for i = 2, math.max(count + 1, 10) do
        wm:readLine({line = i, type = "line"});
    end

    -- get letter from keyboard
    function wm:receiveLetter(letter)
        print("RECEIVE " .. letter, self.line, self.selected);

        self.lines[self.line]:setLbl(letter);
    end

    function wm:updateColors(params)
        local sql = "SELECT * FROM wordmodule WHERE modified = 1;";
        for row in db_main:nrows(sql) do
            self:readLine{line = row.line, type = "line"};

            if (row.modified == 1) then
                local sql = "UPDATE wordmodule SET modified = 0 WHERE line=" .. row.line .. " AND type='line';";
                db_main:exec(sql);
            end
        end
    end

    return wm;
end

local function dbInit()
    -- main db init
    if(file_main == nil) then
        local pathS = system.pathForFile(name_mainr, system.ResourceDirectory);
        local fileS = io.open(pathS, "r");
        local contentS = fileS:read("*a");

        local pathD = system.pathForFile(name_main, system.DocumentsDirectory);
        local fileD = io.open(pathD, "w");
        fileD:write(contentS);

        io.close(fileS);
        io.close(fileD);
    end

    db_main = sqlite.open(path_main);

    --[[
    -- word db init
    if(file_words == nil) then
        local pathS = system.pathForFile(name_words, system.ResourceDirectory);
        local fileS = io.open(pathS, "r");
        local contentS = fileS:read("*a");

        local pathD = system.pathForFile(name_words, system.DocumentsDirectory);
        local fileD = io.open(pathD, "w");
        fileD:write(contentS);

        io.close(fileS);
        io.close(fileD);
    end
    ]]--

    db_words = sqlite.open(path_words);
end

function scene:createScene(event)
    screenWidth = display.viewableContentWidth;
    screenHeight = display.viewableContentHeight;

    local screen = display.newGroup();

    -- module for words editing
    dbInit();

    local params = event.params;
    db_main:exec("DELETE FROM wordmodule");
    local wm = wordModule{start = params.start, finish = params.finish};

    -- create screen
    screen:insert(ui.getBackground());

    screen.wm = wm;
    screen:insert(screen.wm);

    local d = dimens["txt_startfinish"];

    screen.txtStartFinish = display.newText(wm.start .. " -> " .. wm.finish, d.x * scale, d.y * scale, "Vatuma Script slc", d.fontSize * scale);
    screen.txtStartFinish:setTextColor(d.textColor);
    screen:setReferencePoint(display.TopLeftReferencePoint);
    screen:insert(screen.txtStartFinish);

    screen.keyboard = Keyboard:new({wm = wm});
    screen:insert(screen.keyboard);
end

local function onSystemEvent(event)
    if(event.type == "applicationExit") then
        db_main:close();
        db_words:close();
    end
end

scene:addEventListener("createScene", scene);
Runtime:addEventListener("system", onSystemEvent);

return scene;