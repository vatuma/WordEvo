--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 10.07.12
-- Time: 21:16
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local sqlite = require("sqlite3");
local values = require("values");
local slideView = require("slideView")

local receiveButtonEvents = false;

local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);

local screenW = display.viewableContentWidth;
local screenH = 11 * values.cell * values.scale;

local function dbInit()
    db_main = sqlite.open(path_main);
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

local function sheetsTable()
    local st = display.newGroup();
    st.active = 1;

    local offset = 0;

    local function level(params)
        local row = params.row;
        local column = params.column;
        local label = params.label;
        local steps = params.steps or 0;
        local steps_min = params.steps_min;
        local enable = params.enable or 0;
        local size = values.cell * 2 * values.scale;

        local lv = display.newGroup();
        lv.st = params.st;
        lv.enable = enable;

        function lv:onEnded()
            -- print ("self.enable", self.label, self.enable, self.parent.enable)

            if self.enable ~= 1 then
                return false;
            end

            local options =
            {
                params = {
                    start = self.start,
                    finish = self.finish,
                    level = label,
                    steps_min = steps_min,
                    gametype = values.tblcampaign,
                }
            }

            -- print("LEVEL", self.start, self.finish, steps_min)

            storyboard.gotoScene("scPlay", options);
        end

        local function onEvent(event)
            print("LEVEL BUTTON", event.phase, receiveButtonEvents)

            local target = event.target;

            if receiveButtonEvents == false then
                return false;
            end;

            if event.phase == "ended" then
                target.onEnded();

                --[[
                if target.enable ~= 1 then
                    return false;
                end

                local options =
                {
                    params = {
                        start = target.start,
                        finish = target.finish,
                        level = label,
                        steps_min = steps_min,
                        gametype = values.tblcampaign,
                    }
                }

                storyboard.gotoScene("scPlay", options);
                ]]--
            elseif event.phase == "began" then
                -- target.start_x = event.x;
                -- target.st.slider:setReceive(false);
                target.st.slider:setTarget(target);
            elseif event.phase == "moved" then
                --[[
                print(event.x - target.start_x, event.x, target.start_x)
                if math.abs(event.x - target.start_x or event.x) > 3 then
                    target.st.slider:setReceive(true);
                end
                ]]--
                -- target.st.slider:setReceive(target);
            else
                -- target.st.slider:setReceive(true);
            end
        end

        lv.start = params.start;
        lv.finish = params.finish;

        lv.back = display.newRoundedRect(0, 0, size, size, 0);
        lv.back.strokeWidth = 1;
        lv.back:setFillColor(255, 255, 255, 100);
        lv.back:setStrokeColor(0, 0, 0);
        lv:insert(lv.back);

        local color = values.color_blue;
        lv.label = display.newText(label, 0, 0, values.font, 18*2);
        lv.label.xScale = 0.5; lv.label.yScale = 0.5;
        lv.label:setTextColor(color[1], color[2], color[3]);
        lv.label.x = lv.back.x;
        lv.label.y = lv.back.y - size*0.25;
        lv:insert(lv.label);

        if enable == 1 then
            lv.labels = display.newText(values.getStars(steps, steps_min), 0, 0, values.font, 25*2);
            lv.labels.xScale = 0.5; lv.labels.yScale = 0.5;
            lv.labels:setTextColor(color[1], color[2], color[3]);
            lv.labels.x = lv.back.x;
            lv.labels.y = lv.back.y + size*0.4;
            lv:insert(lv.labels);
        else
            local width, height = values.getImageSizes("images/o_lock.png");

            lv.lock = display.newImage("images/o_lock.png");
            lv.lock.width = width;
            lv.lock.height = height;
            lv:insert(lv.lock);
        end

        lv.x = (values.campaign_x + (column - 1) * values.cell * 3) * values.scale + display.screenOriginX;
        lv.y = ((row - 1) * values.cell * 3) * values.scale;

        lv:addEventListener("touch", onEvent);

        return lv;
    end

    local function onEvent(event)
        local target = event.target;

        if event.phase == "began" then
            offset = event.x - target.parent.x;

            print("began", offset, event.x, target.x)
        elseif event.phase == "moved" then
            target.parent.x = event.x - offset;

            print("moved", offset, event.x, target.x)
        else
        end
    end

    local slides = {};

    local name = "page" .. st.active;
    st[name] = display.newGroup();

    slides[1] = st[name];

    local page = st.active;
    local row, column = 1, 1;
    local sql = "SELECT * FROM campaign WHERE language='" .. values.game_language .. "' ORDER BY level;";

    for dbrow in db_main:nrows(sql) do
        if column > 3 then
            column = 1;
            row = row + 1;
        end

        if row > 4 then
            page = page + 1;

            name = "page" .. page;
            st[name] = display.newGroup();
            row, column = 1, 1;

            st[name].x = display.viewableContentWidth;

            slides[page] = st[name];
        end

        print("CAMPAIGN", dbrow.level, dbrow.steps_min)

        st[name]:insert(level{
            label = dbrow.level,
            row = row,
            column = column,
            start = dbrow.start,
            finish = dbrow.finish,
            st = st,
            steps = dbrow.steps,
            steps_min = dbrow.steps_min,
            enable = dbrow.enable,
        });

        column = column + 1;
    end

    st.slider = slideView.new(slides, screenH);
    st:insert(st.slider);

    return st;
end

function scene:unlock(state)
    receiveButtonEvents = state;
    self.screen.cs.slider:setReceive(state);
end

function scene:refresh()
    display.remove(self.screen.cs);

    scene.screen.cs = sheetsTable();
    scene.screen:insert(scene.screen.cs);
end

function scene:createScene(event)
    print("scCampaign", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    scene.screen = display.newGroup();
    dbInit();

    scene.screen:insert(ui.getBackground());

    scene.screen.cs = sheetsTable();
    scene.screen:insert(scene.screen.cs);

    scene.screen.back = ui.myBackButton{scene = storyboard.getCurrentSceneName()};
    scene.screen.back:addEventListener("touch", onBackBtn);
    scene.screen:insert(scene.screen.back);

    scene.screen.langl = ui.myText{name = "langl", refPoint = display.TopLeftReferencePoint};
    scene.screen:insert(scene.screen.langl);

    scene.screen.lang = ui.myLanguage(self);
    scene.screen:insert(scene.screen.lang);
end

function scene:enterScene(event)
    print("scCampaign", "enterScene");

    receiveButtonEvents = true;
    scene.screen.lang.isVisible = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
    end
end

function scene:exitScene(event)
    print("scCampaign", "exitScene");

    receiveButtonEvents = false;
    scene.screen.lang.isVisible = false;

    if db_main and db_main:isopen() then
        db_main:close();
    end
end

local function onSystemEvent(event)
    print("scCampaign", "onSystemEvent", event.type);

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