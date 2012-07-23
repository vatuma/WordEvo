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

widget.setTheme( "theme_ios" )

local receiveButtonEvents = false;

-- database
local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);
local path_main_res = system.pathForFile("dict/main.sqlite", system.ResourceDirectory);

local screen;

local function updateInterest()

    local interest = {
        {start = "муха",  finish = "слон",  language = values.ru},
        {start = "ночь",  finish = "день",  language = values.ru},
        {start = "миг",   finish = "час",   language = values.ru},
        {start = "make",  finish = "deal",  language = values.en},
        {start = "hand",  finish = "made",  language = values.en},
        {start = "world", finish = "mouse", language = values.en},
    }

    db_main:exec("DELETE * FROM interest");
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
            local sql = "INSERT INTO interest ('start','finish', 'language', 'count') VALUES ('" .. start .. "','" .. finish .. "','" .. v.language .. "'," .. #start .. ");";
            db_main:exec(sql);
        end
    end
end

local function onBtnCampaignRelease()
    print("scStart", "onBtnCampaignRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    screen:insert(ui.toast{});

    return true;
end

local function onBtnSinglePlayRelease()
    print("scStart", "onBtnSinglePlayRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    local sql = "SELECT * FROM " .. values.tblsingleplay .. ";";

    local count = 0;
    for row in db_main:nrows(sql) do
        count = count + 1;
        break;
    end

    -- new or stored game
    if (count == 0) then
        storyboard.gotoScene("scSinglePlay");
    else
        storyboard.gotoScene("scPlay");
    end

    return true;
end

local function onBtnRulesRelease()
    -- temp direct start Play with default words

    print("scStart", "onBtnRulesRelease", receiveButtonEvents);

    if receiveButtonEvents == false then
        return false;
    end;

    local options =
    {
        -- effect = "fade",
        -- time = 3000,
        params = {
            start = "make",
            finish = "deal",
        }
    }

    storyboard.gotoScene("scPlay", options);

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

function scene:createScene(event)
    print("scStart", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    -- define languages and scales
    values.language = values.en;
    values.game_language = preference.getValue("game_language") or values.en;

    -- values.scale = display.contentHeight / values.main_height;
    values.scale = display.viewableContentHeight / values.main_height;

    screen = display.newGroup();

    dbInit();
    updateInterest();

    screen:insert(ui.getBackground());

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

    -- creating mask file

    dynamicMask = display.newGroup();
    dynamicMask:toBack();

    local w = display.viewableContentWidth - 10; -- values.cell * 9 * 480/1024;
    local h = values.wordmodule_height * values.scale; -- values.cell * 9 * 480/1024;

    -- print(w, h, 480/1024, 1024/display.viewableContentHeight, display.viewableContentHeight)

    local thisRect = display.newRect(0, 0, w + 10, h + 10);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(0,0,0);

    local thisRect = display.newRect(0, 0, w, h);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,255,255);

    thisRect.x = (w + 10) * 0.5;
    thisRect.y = (h + 10) * 0.5;

    --[[
    local thisRect = display.newRect(w - 11 - w*0.05, h - h*0.2, w*0.1, h*0.2);
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,0,0);

    local thisRect = display.newRect(w * 0.5, h * 0.5, w*0.1, h*0.2);
    dynamicMask:insert(thisRect);
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

    dynamicMask.x = display.screenOriginX;
    dynamicMask.y = display.screenOriginY;

    display.save(dynamicMask, "tmp.jpg",  system.TemporaryDirectory);

    dynamicMask:removeSelf();
    dynamicMask = nil;

    -- end creating mask file

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

    --[[
    local sv = display.newGroup();
    sv.x = 51 * values.scale;
    sv.y = 255 * values.scale;

    sv.sa = display.newGroup();

    sv.sa.img = display.newImage("images/o_5.png");
    sv.sa:insert(sv.sa.img)

    -- transition.to(sv.sa, {delay = 1000, time = 1000, x = 50, y = 200});

    sv:insert(sv.sa);

    local mask = graphics.newMask("images/tmp.jpg", system.ResourceDirectory);

    sv:setMask(nil);
    sv:setMask(mask);

    print(sv.x, sv.y, sv.width, sv.height, sv.sa.x, sv.sa.y, sv.sa.width, sv.sa.height);

    sv.maskX = values.cell * 9 * values.scale / 2
    sv.maskY = values.cell * 9 * values.scale / 2 - 0 * values.scale

    screen:insert(runner{area = sv.sa, size = values.cell * 9 * values.scale, sizefull = values.cell * 9 * values.scale * 2});
    ]]--

    --[[
    local function scrollViewListener( event )
        local s = event.target -- reference to scrollView object
        local dragX, dragY = s:getContentPosition();
        print(dragY);

        if event.type == "endedScroll" then
            print( "endedScroll event type" )
            s:scrollToPosition(0, 100, 500, true);
        end
    end

    local scrollView = widget.newScrollView{
        top = 255 * values.scale,
        left = 51 * values.scale,
        scrollHeight = 408 * values.scale,
        width = 255 * values.scale,
        height = 357 * values.scale,
        -- topPadding = 50,
        bgColor = { 0, 255, 0, 100 },
        listener = scrollViewListener,
        -- maskFile = "mask_200_250.png"
        -- hideBackground = true,
    }
    screen:insert(scrollView);

    local mask = graphics.newMask("mask_200_250.png");
    scrollView:setMask(mask);
    scrollView.maskScaleX, scrollView.maskScaleY = 1/scale, 1/scale;
    -- scrollView.maskX = 151 * scale
    -- scrollView.maskY = 204 * scale

    -- scrollView.isHitTestMasked = true;

    local img = display.newImage("images/o_3_selected.png");

    scrollView:insert(img);

    -- screenWidth, screenHeigth = display.contentWidth, display.contentHeight

    dynamicMask = display.newGroup();
    local thisRect = display.newRect (0,0,255 * values.scale + 10, 357 * values.scale + 10)
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(0,0,0);

    local thisRect = display.newRect (0,0,255 * values.scale, 357 * values.scale)
    dynamicMask:insert(thisRect);
    thisRect:setFillColor(255,255,255);

    thisRect.x = (255 * values.scale + 10) * 0.5;
    thisRect.y = (357 * values.scale + 10) * 0.5

    -- now the magic:
    display.save (dynamicMask, "tmp.jpg",  system.TemporaryDirectory)

    dynamicMask:removeSelf();
    dynamicMask = nil

    -- load the last saved image as our mask.
    local mask = graphics.newMask( "tmp.jpg", system.TemporaryDirectory )

    -- apply or re-apply the mask.
    scrollView:setMask(nil)
    scrollView:setMask(mask)

    -- this next bit is due to some weird bug in corona with masks...
    -- if you nil a mask, the next maskX and maskY are not right...
    -- and setting them to 0 is ignored.
    -- setting them to .01 doesn't move anything
    --  but it does make sure they're in the right spot.
    scrollView.maskX = scrollView.width/2
    scrollView.maskY = scrollView.height/2 - 23 * values.scale
    -- scrollView.maskScaleX = values.scale;
    -- scrollView.maskScaleY = values.scale;

    -- scrollView:addScrollBar();

    -- screen:insert(scrollView);
    ]]--

    -- print(storyboard.getCurrentSceneName());
end

function scene:enterScene(event)
    print("scStart", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());

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

scene:addEventListener("createScene", scene);
scene:addEventListener("enterScene", scene);
scene:addEventListener("exitScene", scene);

Runtime:addEventListener("system", onSystemEvent);

return scene;