--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 29.06.12
-- Time: 1:07
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local values = require("values");
local widget = require("widget");
local sqlite = require("sqlite3");
local preference = require("save_and_load_library_from_satheesh");

local receiveButtonEvents = false;

-- database
local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);
local path_main_res = system.pathForFile("dict/main.sqlite", system.ResourceDirectory);

local screen;

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

local function updateInterest()

    local interest = {
        {start = "муха",  finish = "слон",  language = values.ru, steps_min = 5},
        {start = "ночь",  finish = "день",  language = values.ru, steps_min = 5},
        {start = "миг",   finish = "час",   language = values.ru, steps_min = 5},
        {start = "make",  finish = "deal",  language = values.en, steps_min = 5},
        {start = "line",  finish = "like",  language = values.en, steps_min = 5},
        {start = "world", finish = "mouse", language = values.en, steps_min = 5},
    }

    db_main:exec("DELETE FROM interest");
    for k, v in pairs(interest) do
        local start = v.start;
        local finish = v.finish;

        local sql = "SELECT * FROM interest WHERE start='" .. start .. "' AND finish='" .. finish .. "';";

        local count = 0;
        for row in db_main:nrows(sql) do
            count = count + 1;
            break;
        end

        if (count == 0) then
            local sql = "INSERT INTO interest ('start','finish','language','count','steps_min') VALUES ('" .. start .. "','" .. finish .. "','" .. v.language .. "'," .. #start .. "," .. v.steps_min .. ");";
            db_main:exec(sql);
        end
    end
end

local function updateCampaign()

    local words = {
        [values.en] = {
            {level = 1, start = "make", finish = "deal", steps_min = 10},
            {level = 2, start = "make", finish = "deal", steps_min = 10},
            {level = 3, start = "make", finish = "deal", steps_min = 10},
            {level = 4, start = "make", finish = "deal", steps_min = 10},
            {level = 5, start = "line", finish = "like", steps_min = 10},
            {level = 6, start = "make", finish = "deal", steps_min = 10},
            {level = 7, start = "make", finish = "deal", steps_min = 10},
            {level = 8, start = "make", finish = "deal", steps_min = 10},
            {level = 9, start = "make", finish = "deal", steps_min = 10},
            {level = 10, start = "make", finish = "deal", steps_min = 10},
            {level = 11, start = "make", finish = "deal", steps_min = 10},
            {level = 12, start = "make", finish = "deal", steps_min = 10},
            {level = 13, start = "make", finish = "deal", steps_min = 10},
            {level = 14, start = "line", finish = "like", steps_min = 10},
            {level = 15, start = "fine", finish = "line", steps_min = 10},
        },
        [values.ru] = {
            {level = 1, start = "муха", finish = "слон", steps_min = 10},
            {level = 2, start = "муха", finish = "слон", steps_min = 10},
            {level = 3, start = "муха", finish = "слон", steps_min = 10},
            {level = 4, start = "муха", finish = "слон", steps_min = 10},
            {level = 5, start = "муха", finish = "слон", steps_min = 10},
        }
    }

    local sqlupdate = "";
    for kl,vl in pairs(words) do
        for k,v in pairs(vl) do
            local sql = "SELECT * FROM campaign WHERE start='" .. v.start .. "' AND finish='" .. v.finish .. "' AND level=" .. v.level .. " AND language='" .. kl .. "';";

            local count = 0;
            for row in db_main:nrows(sql) do
                count = count + 1;

                if row.steps_min ~= v.steps_min then
                    sqlupdate = sqlupdate ..
                        "UPDATE campaign SET steps_min=" .. v.steps_min .. " WHERE start='" .. v.start .. "' AND finish='" .. v.finish .. " AND level=" .. v.level .. " AND language='" .. kl .. "';";
                end
            end

            if count == 0 then
                local enable = 0;
                if v.level == 1 then enable = 1; end

                sqlupdate = sqlupdate ..
                    "INSERT INTO campaign ('level','start','finish','steps_min','language','enable') VALUES ("
                        .. v.level .. ",'" .. v.start .. "','" .. v.finish .. "'," .. v.steps_min .. ",'" .. kl .. "'," .. enable .. ");";
            end
        end
    end

    if sqlupdate ~= "" then
        db_main:exec(sqlupdate);
    end
end

-- start Campaign
local function onBtnCampaignRelease()
    print("scStart", "onBtnCampaignRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    local sql = "SELECT * FROM " .. values.tblcampaign .. " WHERE language='" .. values.game_language .. "';";

    local count = 0;
    for row in db_main:nrows(sql) do
        count = count + 1;
        break;
    end

    print("onBtnCampaignRelease", count, sql)

    -- new or stored game
    if (count == 0) then
        storyboard.gotoScene("scCampaign");
    else
        local options =
        {
            params = {
                gametype = values.tblcampaign,
            }
        }

        storyboard.gotoScene("scPlay", options);
    end

    return true;
end

-- start Single Play
local function onBtnSinglePlayRelease()
    print("scStart", "onBtnSinglePlayRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    local sql = "SELECT * FROM " .. values.tblsingleplay .. " WHERE language='" .. values.game_language .. "';";

    local count = 0;
    for row in db_main:nrows(sql) do
        count = count + 1;
        break;
    end

    -- new or stored game
    if (count == 0) then
        storyboard.gotoScene("scSinglePlay");
    else
        local options =
        {
            params = {
                gametype = values.tblsingleplay,
            }
        }

        storyboard.gotoScene("scPlay", options);
    end

    return true;
end

local function onBtnRulesRelease()
    -- temp direct start Play with default words
    print("scStart", "onBtnRulesRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    --[[
    local options =
    {
        params = {
            start = "line",
            finish = "like",
            gametype = values.type_singleplay,
        }
    }

    storyboard.gotoScene("scPlay", options);
    ]]--

    ui.toast{text = "не реализовано"};

    return true;
end

local function onBtnResultsRelease()
    -- temp direct start Play with default words
    print("scStart", "onBtnResultsRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    storyboard.gotoScene("scResults", options);

    --[[
    local options =
    {
        params = {
            start = "make",
            finish = "take",
            gametype = values.type_singleplay,
        }
    }

    storyboard.gotoScene("scComplete", options);
    ]]--

    return true;
end

-- -- now the magic

-- lib function
local function unwind_protect(thunk,cleanup)
    local ok,res = pcall(thunk)
    if cleanup then cleanup() end
    if not ok then error(res,0) else return res end
end

-- work with opened files
local function with_open_file(name,mode)
    return function(body)
        local f = assert(io.open(name,mode))
        return unwind_protect(function()return body(f) end,
            function()return f and f:close() end)
    end
end

-- os-copy
function os_copy2(source_path,dest_path)
    return with_open_file(source_path,"rb") (function(source)
        return with_open_file(dest_path,"wb") (function(dest)
            assert(dest:write(assert(source:read("*a"))))
            return 'copy ok'
        end)
    end)
end

-- -- finish the magic

local function dbInit()
    print("scStart", "dbInit");

    local file_main = io.open(path_main, "r");

    if (file_main == nil) then
        print(pcall(function() return os_copy2(path_main_res, path_main) end));
    end

    db_main = sqlite.open(path_main);
end

local function demo()
    local d = display.newGroup();

    local row, column = 0, 0;
    for k,v in pairs(values.demo[values.game_language]) do
        column = 0;
        row = row + 1;

        for k1,v1 in pairs(v) do
            column = column + 1;

            d["rc" .. row .. column] = ui.myText{name = "lang", refPoint = display.TopLeftReferencePoint};
            d["rc" .. row .. column].x = (values.wordmodule_x + (column - 1) * values.cell) * values.scale + display.screenOriginX;
            d["rc" .. row .. column].y = (values.wordmodule_y + (row - 1) * values.cell) * values.scale + display.screenOriginY;
            d["rc" .. row .. column].text = v1;

            d:insert(d["rc" .. row .. column]);
        end
    end

    local function animate()
        for k,v in pairs(values.demo_scheme[values.game_language]) do
            local act = v.act;
            local col = v.col or 0;
            local delay = v.delay or 0;

            if receiveButtonEvents == true then
                if act == "visible" then
                    timer.performWithDelay(delay, function() for i=2, v.cols do d["rc" .. v.row .. i].isVisible = v.visible end; end);
                elseif act == "select" then
                    timer.performWithDelay(delay, function() d["rc" .. v.row .. v.col]:setTextColor(v.color[1], v.color[2], v.color[3]) end);
                elseif act == "change" then
                    timer.performWithDelay(delay, function() d["rc" .. v.row .. v.col].text = v.text  end);
                end
            end
        end
    end

    timer.performWithDelay(0, animate, 1);
    timer.performWithDelay(7000, animate, 0);

    return d;
end

function scene:createScene(event)
    print("scStart", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    -- define languages and scales

    values.language = values.en;
    local ui_language = system.getPreference("ui", "language");

    for k,v in pairs(values.language_name) do
        print(k, v, ui_language)
        if v == ui_language then
            values.language = k;
            break;
        end
    end

    values.game_language = preference.getValue("game_language") or values.en;

    preference.save{ruword = "русское слово"};

    -- values.scale = display.contentHeight / values.main_height;
    values.scale = display.viewableContentHeight / values.main_height;

    -- print("DEFINE SCALE", values.scale, values.main_height, viewScreenW, viewScreenH, offsetW, offsetH)

    local scalex = display.contentScaleX
    local scaley = display.contentScaleY

    -- display scale values
    -- print("scalex", "scaley", scalex, scaley)

    screen = display.newGroup();
    ui.toast{text = "" .. values.language};

    dbInit();
    updateInterest();
    updateCampaign();

    screen:insert(ui.getBackground());

    screen.logo_small = display.newImage("images/logo_small.png");
    screen.logo_small.width, screen.logo_small.height = values.getImageSizes("images/logo_small.png");
    screen.logo_small:setReferencePoint(display.TopLeftReferencePoint);
    screen.logo_small.x, screen.logo_small.y = display.screenOriginX, display.screenOriginY;
    screen:insert(screen.logo_small);

    screen.logo = display.newImage("images/logo.png");
    screen.logo.width, screen.logo.height = values.getImageSizes("images/logo.png");
    screen.logo:setReferencePoint(display.TopLeftReferencePoint);
    screen.logo.x, screen.logo.y = 20 + display.screenOriginX, 335 + display.screenOriginY;
    screen:insert(screen.logo);

    screen.title = ui.myText{name = "start_results", refPoint = display.CenterReferencePoint};
    screen.title.x = display.viewableContentWidth - (display.viewableContentWidth - 2 * values.cell * values.scale) * 0.5;
    screen.title.y = values.cell * values.scale + display.screenOriginY;
    screen:insert(screen.title);

    screen.demo = demo();
    screen:insert(screen.demo);

    -- define dimensions
    local width, height = values.getImageSizes("images/btn_border_1.png");

    screen.campaign = ui.myButton{
        id = "campaign",
        onRelease = onBtnCampaignRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.campaign);

    --[[
    screen.campaign = ui.newButton{
        id = "campaign",
        onRelease = onBtnCampaignRelease,
        width = width,
        height = height,
    }
    ]]--

    screen.single_play = ui.myButton{
        id = "single_play",
        onRelease = onBtnSinglePlayRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.single_play);

    screen.rules = ui.myButton{
        id = "rules",
        onRelease = onBtnRulesRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.rules);

    screen.results = ui.myButton{
        id = "results",
        onRelease = onBtnResultsRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.results);

    --[[
    screen.res_start = ui.myText{name = "res_start", refPoint = display.TopLeftReferencePoint};
    screen.res_start.y = 150;
    screen:insert(screen.res_start);
    --screen.res_start.text = values.myLower("абвГДЕЖЗкфхцчшЩ abcd");

    file = io.open(system.pathForFile("ruword", system.DocumentsDirectory));
    screen.res_start.text = file:read(4);
    ]]--

    -- creating mask file for play screen
    local playMask = display.newGroup();

    local stroke = 5;
    local pmwidth, pmheight = viewScreenW - stroke*2, values.cell * 9 * values.scale;

    local blackRect = display.newRect(0, 0, pmwidth + stroke*2, pmheight + stroke*2);
    blackRect:setFillColor(0,0,0);
    playMask:insert(blackRect);

    local whiteRect = display.newRect(0, 0, pmwidth, pmheight);
    whiteRect:setFillColor(255,255,255);
    playMask:insert(whiteRect);

    whiteRect.x = blackRect.width * 0.5;
    whiteRect.y = blackRect.height * 0.5;

    --[[
    local thisRect = display.newRect(pmwidth - 11 - pmwidth*0.05, pmheight - pmheight*0.2, pmwidth*0.1, pmheight*0.2);
    playMask:insert(thisRect);
    thisRect:setFillColor(255,0,0);

    local thisRect = display.newRect(11, h - h*0.2, w*0.1, h*0.2);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,0,0);

    local thisRect = display.newRect(11, 11, w*0.1, h*0.2);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,0,0);

    local thisRect = display.newRect(w - 11 - w*0.05, 11, w*0.1, h*0.2);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,0,0);
    ]]--

    playMask.x = offsetW;
    playMask.y = offsetH;

    print(stroke, pmwidth, pmheight, playMask.width, playMask.height)

    display.save(playMask, "playMask.jpg",  system.TemporaryDirectory);

    playMask:removeSelf();
    playMask = nil;
    -- end creating mask file

    --[[
    local function runner(params)
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

        r.x = values.cell * values.scale;
        r.y = values.cell * values.scale;

        pstart = r.runner_back.y;
        pfinish = r.runner_back.y + r.runner_back.height - r.runner.height;

        return r;
    end
    ]]--
end

function scene:enterScene(event)
    print("scStart", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());
    if storyboard.getPrevious() == "scPlay" then
        storyboard.removeScene("scPlay");
    end

    if not db_main or not db_main:isopen() then
        dbInit();
    end
end

function scene:exitScene(event)
    print("scStart", "exitScene");

    receiveButtonEvents = false;

    if db_main and db_main:isopen() then
        db_main:close();
    end
end

local function onSystemEvent(event)
    print("scStart", "onSystemEvent", event.type);

    if(event.type == "applicationExit") then
        if db_main and db_main:isopen() then
            db_main:close();
        end
    end
end

os.setlocale("C");

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

return scene;