--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 22:03
-- To change this template use File | Settings | File Templates.
--

require("Keyboard");

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local ads = require("ads");
local values = require("values");
local sqlite = require("sqlite3");
local preference = require("save_and_load_library_from_satheesh");

local receiveButtonEvents = false;

local cell = values.cell;
local scale = values.scale;

local btn_play;

local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);
local db_main;

local function dbInit()
    print("scSinglePlay", "dbInit");

    db_main = sqlite.open(path_main);
end

-- get words for play depend on game type
local function getPlayWords()
    local start, finish, error, steps_min = "", "", "", 0;
    local type = preference.getValue("type") or "type_random";

    if (type == "type_random") then

        local count = preference.getValue("count") or "count_3";
        local wherecount = "";

        if count == "count_3" then
            wherecount = 3;
        elseif count == "count_4" then
            wherecount = 4;
        elseif count == "count_5" then
            wherecount = 5;
        else
            wherecount = math.random(3, 5);
        end

        local sql = "SELECT * FROM dict WHERE length=" .. wherecount .. ";";
        local db_words = sqlite.open(system.pathForFile(values.db_name[values.game_language], system.ResourceDirectory));

        local dict = {};
        for row in db_words:nrows(sql) do
            dict[#dict + 1] = row.word:lower();
        end

        local function startFinish()
            local sp = math.random(1, #dict);
            local start = dict[sp];

            local fp = math.random(1, #dict);
            while (sp == fp) do
                fp = math.random(1, #dict);
            end
            local finish = dict[fp];

            return start, finish;
        end

        start, finish = startFinish();
        steps_min = values.getLevel{start = start, finish = finish};

        while (steps_min <= 0) do
            start, finish = startFinish();
            steps_min = values.getLevel{start = start, finish = finish};
        end

    elseif (type == "type_interest") then

        start = string.gsub((preference.getValue("start_interest" .. values.game_language) or ""), " ", "");
        finish = string.gsub((preference.getValue("finish_interest" .. values.game_language) or ""), " ", "");
        steps_min = preference.getValue("steps_min_interest" .. values.game_language) or "";

    elseif (type == "type_own") then
        -- print(preference.getValue("start_own" .. values.game_language) or "", preference.getValue("finish_own" .. values.game_language) or "")

        start = string.gsub((preference.getValue("start_own" .. values.game_language) or ""), " ", "");
        finish = string.gsub((preference.getValue("finish_own" .. values.game_language) or ""), " ", "");

        -- check possibility to construct a chain
        if #start ~= #finish then
            error = "diffrent lenght of words";
        else
            steps_min = values.getLevel{start = start, finish = finish};
        end

        if (steps_min > 0) then
        else
            if error == "" then
                error = "chain construct is impossible";
            end
        end;
    end

    return start, finish, error, steps_min;
end

local function onBtnPlayRelease()
    print("scSinglePlay", "onBtnPlayRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    local start, finish, error, steps_min = getPlayWords();

    if (error ~= "") then
        ui.toast{text = error};
    else
        local options =
        {
            params = {
                start = start,
                finish = finish,
                steps_min = steps_min,
                gametype = values.type_singleplay,
            }
        }

        storyboard.gotoScene("scPlay", options);
    end

    return true;
end

-- call interest words selection
local function onBtnSelectRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    storyboard.gotoScene("scSelectWords");

    return true;
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

-- visible part for select type of game
local function selectModule(params)
    local typeW;
    local typeH;

    local countW;
    local countH;

    local buttonW;
    local buttonH;

    local sm = display.newGroup();

    -- define sizes of images
    local countW, countH = values.getImageSizes("images/o_3.png");
    local typeW, typeH = values.getImageSizes("images/type_random.png");
    local buttonW, buttonH = values.getImageSizes("images/btn_border_1.png");

    function sm:refresh()
        sm.detailsline:refresh();
    end

    -- create single image
    local function singleImage(params)
        local name = params.name;
        local v = values.buttons[name];

        local si = display.newGroup();

        function si:setDefault(default)
            self.over.isVisible = default;
            self.default.isVisible = not default;
        end

        local function onEvent(event)
            local target = event.target;

            if ("ended" == event.phase) then
                -- type selected
                if (string.match(target.name, "type") ~= nil) then
                    target.parent:selectType(target.name);
                    target.parent.parent.detailsline:selectType();
                -- count selected
                elseif (string.match(target.name, "count") ~= nil) then
                    target.parent.parent:selectCount(target.name);
                end
            end

            return true;
        end

        -- name of image for searching
        si.name = params.name;
        si.comment = values.getText(v);

        si.x = (v.x or 0) * scale + display.screenOriginX;
        si.y = (v.y or 0) * scale + display.screenOriginY;

        local width = params.width or 100;
        local height = params.height or 100;

        si.default = display.newImage(v.default);
        si.default.width = width;
        si.default.height = height;
        si.default:setReferencePoint(display.TopLeftReferencePoint);
        si.default.x = 0;
        si.default.y = 0;
        si:insert(si.default);

        si.over = display.newImage(v.over);
        si.over.width = width;
        si.over.height = height;
        si.over:setReferencePoint(display.TopLeftReferencePoint);
        si.over.x = 0;
        si.over.y = 0;
        si:insert(si.over);

        si:addEventListener("touch", onEvent);

        return si;
    end

    -- type of game selection
    local function typeline(params)
        local v, d, s, name;

        local tl = display.newGroup();

        function tl:selectType(name)
            for k, v in pairs(self.names) do
                if (k == name) then
                    preference.save{type = name};

                    self.parent.type = name;

                    self:remove(self.comment);
                    self.comment = ui.myText{name = "type_comment", refPoint = display.TopRightReferencePoint, text = v.comment};
                    self.comment.alpha = 0;
                    self:insert(self.comment);

                    transition.to(self.comment, {delay = 300, alpha = 1});

                    v:setDefault(true);
                else
                    v:setDefault(false);
                end

                if k ~= "type_own"
                    and self.parent.detailsline ~= nil
                    and self.parent.detailsline.type_own ~= nil then
                    self.parent.detailsline.type_own.wordmodule:onReady();
                end
            end
        end

        tl.names = {};

        name = "type";
        tl.label = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        tl:insert(tl.label);

        name = "type_comment";
        tl.comment = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, old = true};
        tl:insert(tl.comment);

        name = "type_random";
        tl.type_random = singleImage{name = name, width = typeW, height = typeH};
        tl:insert(tl.type_random);
        tl.names[name] = tl.type_random;

        name = "type_interest";
        tl.type_interest = singleImage{name = name, width = typeW, height = typeH};
        tl:insert(tl.type_interest);
        tl.names[name] = tl.type_interest;

        name = "type_own";
        tl.type_own = singleImage{name = name, width = typeW, height = typeH};
        tl:insert(tl.type_own);
        tl.names[name] = tl.type_own;

        -- get type from preferences
        tl:selectType(preference.getValue("type") or "type_random");
        -- tl.parent.detailsline:selectType(preference.getValue("type") or "type_random");

        return tl;
    end

    -- additional params selection
    local function detailsline(params)
        local v, name;

        local dl = display.newGroup();

        function dl:selectCount(name)
            for k, v in pairs(self.counts) do
                if (k == name) then
                    preference.save{count = name};

                    v:setDefault(true);
                else
                    v:setDefault(false);
                end
            end
        end

        function dl:refresh()
            print("dl:refresh", preference.getValue("start_interest" .. values.game_language) or "", preference.getValue("finish_interest" .. values.game_language) or "")

            dl.type_own.wordmodule:refresh();

            dl.type_interest.wordstart.text = preference.getValue("start_interest" .. values.game_language) or "";
            dl.type_interest.wordfinish.text = preference.getValue("finish_interest" .. values.game_language) or "";
        end

        function dl:selectType()
            for k, v in pairs(self.types) do
                v.isVisible = k == self.parent.type;
            end
        end

        dl.types = {};
        dl.counts = {};

        -- random game
        local type_random = display.newGroup();
        type_random.counts = {};

        name = "count";
        type_random.label = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_random:insert(type_random.label);

        name = "count_3";
        type_random.count_3 = singleImage{name = name, width = typeW, height = typeH};
        type_random:insert(type_random.count_3);
        type_random.counts[name] = type_random.count_3;
        dl.counts[name] = type_random.count_3;

        name = "count_4";
        type_random.count_4 = singleImage{name = name, width = typeW, height = typeH};
        type_random:insert(type_random.count_4);
        type_random.counts[name] = type_random.count_4;
        dl.counts[name] = type_random.count_4;

        name = "count_5";
        type_random.count_5 = singleImage{name = name, width = typeW, height = typeH};
        type_random:insert(type_random.count_5);
        type_random.counts[name] = type_random.count_5;
        dl.counts[name] = type_random.count_5;

        name = "count_r";
        type_random.count_r = singleImage{name = name, width = typeW, height = typeH};
        type_random:insert(type_random.count_r);
        type_random.counts[name] = type_random.count_r;
        dl.counts[name] = type_random.count_r;

        dl.type_random = type_random;
        dl:insert(dl.type_random);
        dl.types["type_random"] = dl.type_random;

        -- interest game
        local type_interest = display.newGroup();

        name = "selectpair";
        type_interest.label = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_interest:insert(type_interest.label);

        type_interest.select = ui.myButton{
            id = "selectpair",
            onRelease = onBtnSelectRelease,
            width = buttonW,
            height = buttonH,
            scale = scale
        }
        type_interest:insert(type_interest.select);

        name = "selectpair_ws";
        type_interest.wordstart = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_interest.wordstart.text = preference.getValue("start_interest" .. values.game_language) or "";
        type_interest:insert(type_interest.wordstart);

        name = "selectpair_wf";
        type_interest.wordfinish = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_interest.wordfinish.text = preference.getValue("finish_interest" .. values.game_language) or "";
        type_interest:insert(type_interest.wordfinish);

        dl.type_interest = type_interest;
        dl:insert(dl.type_interest);
        dl.types["type_interest"] = dl.type_interest;

        -- own game
        local type_own = display.newGroup();

        name = "selectpair_own";
        type_own.selectpair_own = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_own:insert(type_own.selectpair_own);

        name = "selectpair_own_sl";
        type_own.selectpair_own_sl = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_own:insert(type_own.selectpair_own_sl);

        name = "selectpair_own_fl";
        type_own.selectpair_own_sl = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
        type_own:insert(type_own.selectpair_own_sl);

        -- own game words and keyboard
        local function wordmodule(params)
            local wm = display.newGroup()

            wm.line = 1;
            wm.selected = 0;
            wm.ws = preference.getValue("start_own" .. values.game_language) or string.rep(" ", 5);
            wm.wf = preference.getValue("finish_own" .. values.game_language) or string.rep(" ", 5);

            local top = 505;
            local left = 246;

            -- define sizes of image
            local image = display.newImage("images/sq_bg_grey.png");
            local width = image.width * scale;
            local height = image.height * scale;
            image:removeSelf();
            image = nil;

            function wm:refresh()
                -- refresh own words
                self.ws = preference.getValue("start_own" .. values.game_language) or string.rep(" ", 5);
                self.wf = preference.getValue("finish_own" .. values.game_language) or string.rep(" ", 5);

                self:updateColors{show = false};

                -- recreate keyboard
                self:remove(self.keyboard);
                self.keyboard = nil;

                self.keyboard = Keyboard:new{wm = self};
                self:insert(self.keyboard);

                self:showKeyboard(false);
            end

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
                            target.parent.parent.line = target.line;
                            target.parent.parent.selected = target.position;
                            target.parent.parent:updateColors{show = true};
                        end

                        return true;
                    end

                    -- change label by keyboard event
                    function letter:setLbl(label)
                        if (self.line == self.parent.parent.line and self.position == self.parent.parent.selected) then
                            -- self.label.text = string.upper(label);
                            self.label.text = label;
                            print(label:byte(1, #label));
                            print(self.label.text:byte(1, #self.label.text));
                        end

                        return self.label.text;
                    end

                    -- define image and color of object
                    local image = "images/sq_bg_grey.png";
                    local color = values.color_blue;

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

                if wl.word == "" then
                    wl.word = string.rep(" ", 5);
                end

                -- print("wordline", wl.word, wl.line, #wl.word)

                -- create all letters of word
                for i = 1, values.getWordLenght(wl.word) do
                    print("setlbl", i, wl.word, values.getWordLenght(wl.word))

                    local label = values.getLetter(wl.word, i, i);

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
                            image = "images/sq_bg_grey.png",
                        });
                    end

                    wl:insert(wl[pos]);
                end

                -- change selected letter in selected word
                function wl:setLbl(label)
                    -- trying to change label letter by letter
                    local newWord = "";
                    for j = 1, values.getWordLenght(self.word) do
                        newWord = newWord .. self["pos" .. j]:setLbl(label);
                    end

                    return newWord;
                end

                return wl;
            end

            function wm:updateColors(params)
                self:remove(self.start);
                self:remove(self.finish);

                if self.line == 1 then
                    self.start = wordLine{word = self.ws, line = 1, selected = self.selected};
                    self.finish = wordLine{word = self.wf, line = 2, selected = 0};
                else
                    self.start = wordLine{word = self.ws, line = 1, selected = 0};
                    self.finish = wordLine{word = self.wf, line = 2, selected = self.selected};
                end

                self:insert(self.start);
                self:insert(self.finish);

                self:showKeyboard(params.show);
                scene.screen.back.isVisible = not params.show;
            end

            function wm:receiveLetter(letter)
                print("single play receive letter")

                if letter == "#" then
                    letter = " ";
                end

                if self.line == 1 then
                    self.ws = self.start:setLbl(letter);
                else
                    self.wf = self.finish:setLbl(letter);
                end

                if self.selected == 5 then
                    self.selected = 1;
                else
                    self.selected = self.selected + 1;
                end

                self:updateColors{show = true};
            end

            function wm:showKeyboard(show)
                self.keyboard.isVisible = show;
                self.selectpair_own_ready.isVisible = show;
                btn_play.isVisible = not show;
            end

            function wm:onReady()
                self:showKeyboard(false);
                self.selected = 0;
                self:updateColors{show = false};

                preference.save{
                    ["start_own" .. values.game_language] = self.ws,
                    ["finish_own" .. values.game_language] = self.wf};
            end

            -- touch on Ready button (label)
            local function onEvent(event)
                local target = event.target;

                if ("ended" == event.phase) then
                    target.parent:onReady();

                    --[[
                    target.parent:showKeyboard(false);
                    target.parent.selected = 0;
                    target.parent:updateColors{show = false};

                    preference.save{
                        ["start_own" .. values.game_language] = target.parent.ws,
                        ["finish_own" .. values.game_language] = target.parent.wf};
                    ]]--
                end

                return true;
            end

            name = "selectpair_own_ready";
            wm.selectpair_own_ready = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
            wm.selectpair_own_ready:addEventListener("touch", onEvent);
            wm:insert(wm.selectpair_own_ready);

            wm.start = wordLine{word = wm.ws, line = 1, selected = wm.selected};
            wm.finish = wordLine{word = wm.wf, line = 2, selected = 0};

            wm:insert(wm.start);
            wm:insert(wm.finish);

            wm.keyboard = Keyboard:new{wm = wm};
            wm:insert(wm.keyboard);

            wm:showKeyboard(false);

            return wm;
        end

        type_own.wordmodule = wordmodule();
        type_own:insert(type_own.wordmodule);

        dl.type_own = type_own;
        dl:insert(dl.type_own);
        dl.types["type_own"] = dl.type_own;

        dl:selectCount(preference.getValue("count") or "count_3");

        return dl;
    end

    sm.type = "";

    sm.typeline = typeline();
    sm:insert(sm.typeline);

    sm.detailsline = detailsline();
    sm.detailsline:selectType();
    sm:insert(sm.detailsline);

    return sm;
end

function scene:unlock(state)
    receiveButtonEvents = state;
end

function scene:refresh()
    self.screen.sm:refresh();
end

function scene:createScene(event)
    print("scSinglePlay", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    scene.screen = display.newGroup();

    dbInit();

    scene.screen:insert(ui.getBackground());

    local width, height = values.getImageSizes("images/btn_border_1.png");

    scene.screen.play = ui.myButton{
        id = "play_single",
        onRelease = onBtnPlayRelease,
        width = width,
        height = height,
        scale = values.scale
    };
    scene.screen:insert(scene.screen.play);
    btn_play = scene.screen.play;

    scene.screen.back = ui.myBackButton{scene = storyboard.getCurrentSceneName()};
    scene.screen.back:addEventListener("touch", onBackBtn);
    scene.screen:insert(scene.screen.back);

    -- create select module
    scene.screen.sm = selectModule();
    scene.screen:insert(scene.screen.sm);

    scene.screen.langl = ui.myText{name = "langl", refPoint = display.TopLeftReferencePoint};
    scene.screen:insert(scene.screen.langl);

    scene.screen.lang = ui.myLanguage(self);
    scene.screen:insert(scene.screen.lang);

    ads.init("inmobi", "123");
    ads.show("banner320x48", {x = 0, y = display.viewableContentHeight - 48, interval = 5, testMode = true});
end

function scene:enterScene(event)
    print("scSinglePlay", "enterScene");

    receiveButtonEvents = true;
    scene.screen.lang.isVisible = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
    end
end

function scene:exitScene(event)
    print("scSinglePlay", "exitScene");

    receiveButtonEvents = false;
    scene.screen.lang.isVisible = false;

    if db_main and db_main:isopen() then
        db_main:close();
    end
end

local function onSystemEvent(event)
    print("scSinglePlay", "onSystemEvent", event.type);

    if(event.type == "applicationExit") then
        if db_main and db_main:isopen() then
            db_main:close();
        end
    end
end

local function onKeyEvent(event)
    local keyname = event.keyName;

    if event.phase == "up"
        and event.keyName == "back" then
        storyboard.gotoScene("scStart");
    end

    return true;
end

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

if system.getInfo("platformName") == "Android" then
    Runtime:addEventListener("key", onKeyEvent) end

return scene;