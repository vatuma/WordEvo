--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 26.07.12
-- Time: 16:53
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ads = require("ads");
local sqlite = require("sqlite3");

local receiveButtonEvents = false;

local steps, steps_min;
local start, finish;
local level;
local gametype;

local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);

local function dbInit()
    db_main = sqlite.open(path_main);
end

local function onRelease(event)
    local targetid = event.target.id;

    if targetid == "replay" then
        if gametype == values.tblsingleplay then
            local options =
            {
                params = {
                    start = start,
                    finish = finish,
                    steps_min = steps_min,
                    gametype = values.tblsingleplay,
                }
            }

            storyboard.gotoScene("scPlay", options);
        else
            local options =
            {
                params = {
                    start = start,
                    finish = finish,
                    steps_min = steps_min,
                    level = level,
                    gametype = values.tblcampaign,
                }
            }

            storyboard.gotoScene("scPlay", options);
        end
    elseif targetid == "quit" then
        storyboard:gotoScene("scStart");
    elseif targetid == "continue" then
        if gametype == values.tblsingleplay then
            storyboard:gotoScene("scSinglePlay");
        else
            local sql = "SELECT * FROM campaign WHERE language='" .. values.game_language .. "';";

            local count = 0;
            for row in db_main:nrows(sql) do
                print(row.level, row.enable)

                if row.level == level + 1
                    and row.enable == 1 then

                    local options =
                    {
                        params = {
                            start = row.start,
                            finish = row.finish,
                            steps_min = row.steps_min,
                            level = row.level,
                            gametype = values.tblcampaign,
                        }
                    }

                    storyboard.gotoScene("scPlay", options);

                    count = 1;

                    break;
                end
            end

            if count == 0 then
                storyboard.gotoScene("scCampaign");
            end
        end
    end
end

function scene:createScene(event)
    print("scComplete", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    local params = event.params;

    gametype = values.tblsingleplay;
    dbInit();

    if params then
        gametype = params.gametype or values.tblsingleplay;

        start, finish = params.start, params.finish;
        steps = params.steps or 100;
        steps_min = params.steps_min or 0;
        level = params.level;
    end

    print(start, finish, steps, steps_min)

    local screen = display.newGroup();

    -- screen:insert(ui.getBackground());

    screen.back = display.newRect(0, 0, display.viewableContentWidth, display.viewableContentHeight);
    screen.back:setFillColor(150,150,150,200);
    screen:insert(screen.back);

    local window = display.newGroup();

    window.back = display.newImage("images/bg_window.png", 0, 0);
    window.back:setReferencePoint(display.TopLeftReferencePoint);
    window.back.x = 0;
    window.back.y = 0;
    window.back.xScale = values.scale;
    window.back.yScale = values.scale;

    window:insert(window.back);

    -- print(window.x, window.y, window.back.x, window.back.y, window.back.width)

    -- screen:insert(screen.window);

    local islast = false;
    if gametype == values.tblsingleplay then
        window.completed = ui.myText{name = "complete_singleplay", refPoint = display.TopCenterReferencePoint};
        window:insert(window.completed);
    else
        local sql = "SELECT * FROM campaign WHERE language='" .. values.game_language .. "';";

        local islast = true;
        for row in db_main:nrows(sql) do
            if row.level == level + 1 then
                islast = false;
            end
        end

        if islast then
            window.completed = ui.myText{name = "complete_campaign_islast", refPoint = display.TopCenterReferencePoint};
        else
            window.completed = ui.myText{name = "complete_campaign", refPoint = display.TopCenterReferencePoint};
        end
        window:insert(window.completed);
    end

    window.stars = ui.myText{name = "complete_stars", refPoint = display.TopCenterReferencePoint};
    window:insert(window.stars);

    window.stars.text = values.getStars(steps, steps_min);

    window.like = ui.myText{name = "complete_like", refPoint = display.TopCenterReferencePoint};
    window:insert(window.like);

    window.lsteps = ui.myText{name = "complete_lsteps", refPoint = display.TopLeftReferencePoint};
    window:insert(window.lsteps);

    window.lsteps_min = ui.myText{name = "complete_lsteps_min", refPoint = display.TopLeftReferencePoint};
    window:insert(window.lsteps_min);

    window.steps = ui.myText{name = "complete_steps", refPoint = display.TopCenterReferencePoint, text = steps};
    window:insert(window.steps);

    window.steps_min = ui.myText{name = "complete_steps_min", refPoint = display.TopCenterReferencePoint, text = steps_min};
    window:insert(window.steps_min);

    local width, height = values.getImageSizes("images/complete.png");

    window.replay = ui.myButton{
        id = "replay",
        onRelease = onRelease,
        width = width,
        height = height,
    }
    window:insert(window.replay);

    window.quit = ui.myButton{
        id = "quit",
        onRelease = onRelease,
        width = width,
        height = height,
    }
    window:insert(window.quit);

    window.continue = ui.myButton{
        id = "continue",
        onRelease = onRelease,
        width = width,
        height = height,
    }
    window:insert(window.continue);

    window:setReferencePoint(display.CenterReferencePoint);
    window.x = display.viewableContentWidth * 0.5;
    window.y = display.viewableContentHeight * 0.5;

    print(window.x, window.y, window.width, window.height)

    screen:insert(window);

    ads.init("inmobi", "123");
    ads.show("banner320x48", {x = 0, y = display.viewableContentHeight - 48, interval = 5, testMode = true});
end

function scene:enterScene(event)
    print("scComplete", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
    end
end

function scene:exitScene(event)
    print("scComplete", "exitScene");

    receiveButtonEvents = false;

    if db_main and db_main:isopen() then
        db_main:close();
    end
end

local function onSystemEvent(event)
    print("scComplete", "onSystemEvent", event.type);

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