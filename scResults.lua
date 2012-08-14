--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 30.07.12
-- Time: 17:23
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui");
local tableView = require("tableView");
local sqlite = require("sqlite3");

local receiveButtonEvents = false;

local db_main;
local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

local function dbInit()
    db_main = sqlite.open(path_main);
end

local function onCloseRelease()
    if receiveButtonEvents == false then
        return false;
    end;

    -- system.openURL("market://details?id=com.anddeveloper.ru424242");
    storyboard.gotoScene("scStart");

    return true;
end

local function getData()
    local data= {};
    local sql = "SELECT * FROM results;";

    for row in db_main:nrows(sql) do
        local id = row.id;

        data[id] = {};
        data[id].start = row.start;
        data[id].finish = row.finish;
        data[id].steps = row.steps;
        data[id].rated = row.rated;
    end

    return data;
end

function scene:createScene(event)
    print("scResults", "createScene");

    display.setStatusBar(display.HiddenStatusBar);

    local screen = display.newGroup();
    dbInit();

    screen:insert(ui.getBackground());

    local data = getData();

    screen.logo_small = display.newImage("images/logo_small.png");
    screen.logo_small.width, screen.logo_small.height = values.getImageSizes("images/logo_small.png");
    screen.logo_small:setReferencePoint(display.TopLeftReferencePoint);
    screen.logo_small.x, screen.logo_small.y = offsetW, offsetH;
    screen:insert(screen.logo_small);

    screen.title = ui.myText{name = "title_results", refPoint = display.CenterReferencePoint};
    screen.title.x = viewScreenW - (viewScreenW - 2 * values.cell * values.scale) * 0.5;
    screen.title.y = values.cell * values.scale + offsetH;
    screen:insert(screen.title);

    screen.chains = ui.myText{name = "allchains", refPoint = display.TopLeftReferencePoint};
    screen.chains.text = #data;
    screen:insert(screen.chains);

    screen.lchains = ui.myText{name = "lallchains", refPoint = display.TopLeftReferencePoint};
    screen:insert(screen.lchains);

    local width, height = values.getImageSizes("images/btn_border_1.png");
    screen.close = ui.myButton{
        id = "results_close",
        onRelease = onCloseRelease,
        width = width,
        height = height,
        scale = values.scale
    }
    screen:insert(screen.close);

    -- create head of table
    screen.header = display.newGroup();

    screen.header.res_start = ui.myText{name = "res_start", refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.res_start);

    screen.header.res_finish = ui.myText{name = "res_finish", refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.res_finish);

    screen.header.res_steps = ui.myText{name = "res_steps", refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.res_steps);

    screen.header.res_rated = ui.myText{name = "res_rated", refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.res_rated);

    screen.header.x = offsetW;
    screen.header.y = values.cell * values.scale * 5 + offsetH;
    screen:insert(screen.header);

    screen.scroll = display.newGroup();
    screen:insert(screen.scroll);

    local top, bottom = 306 * values.scale + offsetH, viewScreenH - 816 * values.scale;

    width, height = values.getImageSizes("images/tableView_default.png");
    screen.scroll.tableview = tableView.newList{
        data = data,
        top = top,
        bottom = bottom,
        -- onRelease = listItemRelease,
        -- maskFile = "images/resultMask.jpg",
        -- backgroundColor = {125,125,125},
        callback = function(item)
            local row = display.newGroup();

            row.back = display.newRect(0,0, viewScreenW, values.cell * values.scale);
            row.back:setFillColor(255, 255, 255, 0);
            row:insert(row.back);

            row.res_start = ui.myText{name = "res_start", refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row.res_start.text = item.start;
            row:insert(row.res_start);

            row.res_finish = ui.myText{name = "res_finish", refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row.res_finish.text = item.finish;
            row:insert(row.res_finish);

            row.res_steps = ui.myText{name = "res_steps", refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row.res_steps.text = item.steps;
            row:insert(row.res_steps);

            row.res_rated = ui.myText{name = "res_rated", refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row.res_rated.text = item.rated;
            row:insert(row.res_rated);

            return row;
        end
    }
    screen.scroll:insert(screen.scroll.tableview);

    local mask;
    if viewScreenH < display.contentHeight then
        mask = graphics.newMask("images/resultMask.jpg", system.ResourceDirectory);
    else
        mask = graphics.newMask("images/resultMask.jpg", system.ResourceDirectory);
    end

    screen.scroll:setMask(nil);
    screen.scroll:setMask(mask);

    screen.scroll.maskX = viewScreenW * 0.5;
    screen.scroll.maskY = values.cell * 11 * values.scale * 0.5 + top + offsetH; print(values.cell * 11 * values.scale)
end

function scene:enterScene(event)
    print("scResults", "enterScene");

    receiveButtonEvents = true;

    storyboard.purgeScene(storyboard.getPrevious());

    if not db_main or not db_main:isopen() then
        dbInit();
    end
end

function scene:exitScene(event)
    print("scResults", "exitScene");

    receiveButtonEvents = false;

    if db_main and db_main:isopen() then
        db_main:close();
    end
end

local function onSystemEvent(event)
    print("scResults", "onSystemEvent", event.type);

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