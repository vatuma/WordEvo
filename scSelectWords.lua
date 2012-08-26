--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 11.07.12
-- Time: 21:12
-- To change this template use File | Settings | File Templates.
--

local storyboard = require("storyboard");
local scene = storyboard.newScene();

local ui = require("ui")
local tableView = require("tableView");
local values = require("values");
local sqlite = require("sqlite3");
local preference = require("save_and_load_library_from_satheesh");

local receiveButtonEvents = false;

local scale = values.scale;

local path_main = system.pathForFile("main.sqlite", system.DocumentsDirectory);
local db_main;

local viewScreenW, viewScreenH = display.viewableContentWidth, display.viewableContentHeight;
local offsetW, offsetH = display.screenOriginX, display.screenOriginY;

local function dbInit()
    db_main = sqlite.open(path_main);
end

function scene:createScene(event)
    display.setStatusBar(display.HiddenStatusBar);

    local name;

    local screen = display.newGroup();

    dbInit();

    screen:insert(ui.getBackground());

    name = "selectpair_interest";
    screen.selectpair_interest = ui.myText{name = name, refPoint = display.TopLeftReferencePoint};
    screen:insert(screen.selectpair_interest);

    -- define sizes of image
    local width, height = values.getImageSizes("images/tableView_default.png");

    -- get interest pair from database
    local data = {};
    local number = 0;

    local sql = "SELECT * FROM interest WHERE language='" .. values.game_language .. "';";

    for row in db_main:nrows(sql) do
        number = number + 1;

        data[number] = {};
        data[number].number = number;
        data[number].start = row.start;
        data[number].finish = row.finish;
        data[number].steps_min = row.steps_min;
    end

    -- create head of table
    screen.header = display.newGroup();

    name = "spi_number";
    screen.header.spi_number = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.spi_number);

    name = "spi_start";
    screen.header.spi_start = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.spi_start);

    name = "spi_finish";
    screen.header.spi_finish = ui.myText{name = name, refPoint = display.TopLeftReferencePoint, ingroup = true};
    screen.header:insert(screen.header.spi_finish);

    screen.header.x = offsetW;
    screen.header.y = values.cell * scale + offsetH;
    screen:insert(screen.header);

    function listItemRelease(event)
        if receiveButtonEvents == false then
            return false;
        end;

        local target = event.target;
        local id = target.id;

        preference.save{
            ["start_interest" .. values.game_language] = data[id].start,
            ["finish_interest" .. values.game_language] = data[id].finish,
            ["steps_min_interest" .. values.game_language] = data[id].steps_min};

        storyboard.gotoScene("scSinglePlay");
    end

    screen.tableview = tableView.newList{
        data = data,
        top = 102 * scale + offsetH,
        bottom = 0,
        onRelease = listItemRelease,
        callback = function(item)
            local row = display.newGroup();

            --[[
            row.back = display.newImage("images/tableView_default.png");
            row.back.height = height;
            row.back:setReferencePoint(display.TopLeftReferencePoint);
            row.back.x = 0;
            row.back.y = 0;
            row:insert(row.back);
            ]]--

            row.back = display.newRect(0,0, viewScreenW, values.cell * values.scale);
            row.back:setFillColor(255, 255, 255, 0);
            row:insert(row.back);

            name = "spi_number";
            row.spi_number = ui.myText{name = name, text = item.number, refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row:insert(row.spi_number);

            name = "spi_start";
            row.spi_start = ui.myText{name = name, text = item.start, refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row:insert(row.spi_start);

            name = "spi_finish";
            row.spi_finish = ui.myText{name = name, text = item.finish, refPoint = display.TopLeftReferencePoint, upper = true, ingroup = true};
            row:insert(row.spi_finish);

            return row;
        end
    }
    screen:insert(screen.tableview);
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