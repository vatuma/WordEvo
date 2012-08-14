--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 10.07.12
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall);

local sqlite = require("sqlite3");
-- os.setlocale("Russian_Russia.1251");

-- scaling
cell = 51;
scale = 1;
main_height = 1024;
wordmodule_x = 51;
wordmodule_y = 153;
wordmodule_width = 612;
wordmodule_height = 459;

campaign_x = 102;
campaign_y = 153;

-- localization
en = "en";
ru = "ru";
language = en;
game_language = en;
db_name = {
    [en] = "dict/dicten.sqlite",
    [ru] = "dict/dictrus.sqlite",
}
language_name = {
    [en] = "english",
    [ru] = "русский",
}

-- game types
tblcampaign = "wmcampaign";
tblsingleplay = "wmsingleplay";

-- genetic algorithm
max_level = 10;
max_population = 50;

start_line = 1;
finish_line = 11;

alphabet = {
    [en] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "u", "v", "w", "t", "x", "y", "z"},
    [ru] = {"а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ь", "ы", "ъ", "э", "ю", "я"},
}

vowels = {
    [en] = {"a", "e", "i", "o", "u", "y"},
    [ru] = {"а", "е", "ё", "и", "о", "у", "ы", "э", "ю", "я"},
}

demo = {
    [en] = {{"1", "M", "A", "K", "E"}, {"2", "M", "A", "R", "E"}, {"3", "M", "E", "R", "E"}, {"4", "M", "E", "R", "L"}, {"5"}, {"6"}, {"7"}, {"8"}, {"9"}, {"10"}, {"11", "D", "E", "A", "L"}},
    [ru] = {},
}

-- font and colors
font = "Vatuma Script slc";
-- font = native.newFont("Vatuma Script slc");
color_blue =  {76,  70,  149};
color_red  =  {255, 0,   0};
color_green = {19,  148, 40};
color_grey =  {127, 134, 145};

demo_scheme = {
    [en] = {
        {act = "visible", row = 2, cols = 5, visible = false},
        {act = "visible", row = 3, cols = 5, visible = false},
        {act = "visible", row = 4, cols = 5, visible = false},
        {act = "change", row = 2, col = 4, text = "K", delay = 500},
        {act = "visible", row = 2, cols = 5, visible = true, delay = 500},
        {act = "select", row = 2, col = 4, color = color_red, delay = 1000},
        {act = "change", row = 2, col = 4, text = "R", delay = 1500},
        {act = "change", row = 3, col = 3, text = "A", delay = 2000},
        {act = "visible", row = 3, cols = 5, visible = true, delay = 2000},
        {act = "select", row = 2, col = 4, color = color_blue, delay = 2500},
        {act = "select", row = 3, col = 3, color = color_red, delay = 3000},
        {act = "change", row = 3, col = 3, text = "E", delay = 3500},
        {act = "change", row = 4, col = 5, text = "E", delay = 4000},
        {act = "visible", row = 4, cols = 5, visible = true, delay = 4000},
        {act = "select", row = 3, col = 3, color = color_blue, delay = 4500},
        {act = "select", row = 4, col = 5, color = color_red, delay = 5000},
        {act = "change", row = 4, col = 5, text = "L", delay = 5500},
        {act = "select", row = 4, col = 5, color = color_blue, delay = 6000},
    },
    [ru] = {},
}

buttons = {
    campaign = {
        x = 344,
        y = 131,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        [en] = "Campaign",
        [ru] = "Кампания",
    },
    single_play = {
        x = 344,
        y = 282,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_2.png",
        over = "images/btn_border_2_pressed.png",
        [en] = "Single\n play",
        [ru] = "Одиночная\n игра",
    },
    rules = {
        x = 344,
        y = 436,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_4.png",
        over = "images/btn_border_4_pressed.png",
        [en] = "Rules",
        [ru] = "Правила",
    },
    results = {
        x = 344,
        y = 592,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_4.png",
        over = "images/btn_border_4_pressed.png",
        [en] = "Results",
        [ru] = "Результаты",
    },
    play_single = {
        x = 344,
        y = 748,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        [en] = "Play",
        [ru] = "Играть",
    },
    type_random = {
        x = 142,
        y = 200,
        default = "images/type_random.png",
        over = "images/type_random_selected.png",
        [en] = "Random - random select words",
        [ru] = "Случайная - случайный выбор слов",
    },
    type_interest = {
        x = 296,
        y = 200,
        default = "images/type_interest.png",
        over = "images/type_interest_selected.png",
        [en] = "Interest - select top pairs",
        [ru] = "Интересная - выбор из лучших пар",
    },
    type_own = {
        x = 450,
        y = 200,
        default = "images/type_own.png",
        over = "images/type_own_selected.png",
        [en] = "Own game - enter own words",
        [ru] = "Своя игра - ввод своих слов",
    },
    count_3 = {
        x = 142,
        y = 508,
        default = "images/o_3.png",
        over = "images/o_3_selected.png",
    },
    count_4 = {
        x = 244,
        y = 508,
        default = "images/o_4.png",
        over = "images/o_4_selected.png",
    },
    count_5 = {
        x = 346,
        y = 508,
        default = "images/o_5.png",
        over = "images/o_5_selected.png",
    },
    count_r = {
        x = 448,
        y = 508,
        default = "images/o_r.png",
        over = "images/o_r_selected.png",
        [en] = "Own game - enter own words",
        [ru] = "Своя игра - ввод своих слов",
    },
    selectpair = {
        x = 141,
        y = 489,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        textColor = color_blue,
        fontSize = 36,
        [en] = "Select pair\n of words",
        [ru] = "Выбрать\n пару слов:",
    },
    replay = {
        x = 51,
        y = 459,
        default = "images/complete.png",
        over = "images/complete_pressed.png",
        textColor = color_blue,
        fontSize = 28,
        [en] = "replay",
        [ru] = "повторить",
    },
    quit = {
        x = 204,
        y = 459,
        default = "images/complete.png",
        over = "images/complete_pressed.png",
        textColor = color_blue,
        fontSize = 28,
        [en] = "quit",
        [ru] = "выход",
    },
    continue = {
        x = 357,
        y = 459,
        default = "images/complete.png",
        over = "images/complete_pressed.png",
        textColor = color_blue,
        fontSize = 28,
        [en] = "continue",
        [ru] = "продолжить",
    },
    kill_stop = {
        x = 396,
        y = 78,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        fontSize = 40,
        textColor = color_red,
        [en] = "Stop",
        [ru] = "Закончить",
    },
    results_close = {
        x = 192,
        y = 847,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        fontSize = 40,
        textColor = color_blue,
        [en] = "Close",
        [ru] = "Закрыть",
    },
}

labels = {
    type = {
        x = 51,
        y = 153,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Type of the game:",
        [ru] = "Тип игры:",
    },
    type_comment = {
        x = 561,
        y = 306,
        fontSize = 30,
        textColor = color_blue,
        [en] = "",
        [ru] = "",
    },
    count = {
        x = 51,
        y = 408,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Count of letter:",
        [ru] = "Количество букв:",
    },
    selectpair = {
        x = 51,
        y = 408,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Select pair of words:",
        [ru] = "Выбрать пару слов:",
    },
    selectpair_ws = {
        x = 408,
        y = 510,
        fontSize = 36,
        textColor = color_blue,
        [en] = "ws",
        [ru] = "cc",
    },
    selectpair_wf = {
        x = 408,
        y = 561,
        fontSize = 36,
        textColor = color_blue,
        [en] = "wf",
        [ru] = "фс",
    },
    selectpair_own = {
        x = 51,
        y = 408,
        fontSize = 32,
        textColor = color_blue,
        [en] = "Select pair of words (3 to 5 letters):",
        [ru] = "Выбрать пару слов (от 3 до 5 букв):",
    },
    selectpair_own_sl = {
        x = 51,
        y = 510,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Start",
        [ru] = "Начальное",
    },
    selectpair_own_fl = {
        x = 51,
        y = 561,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Finish",
        [ru] = "Конечное",
    },
    selectpair_own_ready = {
        x = 306,
        y = 663,
        fontSize = 36,
        textColor = color_red,
        [en] = "Ready",
        [ru] = "Готово",
    },
    selectpair_interest = {
        y = 10,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Select pair of words:",
        [ru] = "Выбор пары слов:",
    },
    spi_number = {
        x = 51 + 10,
        y = 10,
        fontSize = 36,
        textColor = color_blue,
        [en] = "№",
        [ru] = "№",
    },
    spi_start = {
        x = 102 + 10,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "Start",
        [ru] = "Начальное",
    },
    spi_finish = {
        x = 306 + 10,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "Finish",
        [ru] = "Конечное",
    },
    startfinish = {
        x = 51,
        y = 10,
        fontSize = 30,
        textColor = color_blue,
    },
    wm_notindict = {
        x = 51,
        y = 102,
        fontSize = 36,
        textColor = color_red,
        [en] = "no word in the dictionary",
        [ru] = "нет такого слова в словаре",
    },
    wm_iknow = {
        x = 357,
        y = 51,
        fontSize = 32,
        textColor = color_green,
        [en] = "I know it!",
        [ru] = "Есть такое!",
    },
    wm_duplicate = {
        x = 408,
        y = 306,
        fontSize = 32,
        textColor = color_red,
        [en] = "duplicate",
        [ru] = "дубль",
        image = "images/ic_duplicate.png",
    },
    wm_goback = {
        x = 408,
        y = 306,
        fontSize = 32,
        textColor = color_red,
        [en] = "go back",
        [ru] = "вернуться",
        image = "images/ic_duplicate.png",
    },
    wm_clear = {
        x = 408,
        y = 357,
        fontSize = 32,
        textColor = color_red,
        [en] = "clear",
        [ru] = "удаление",
        image = "images/ic_duplicate.png",
    },
    wm_clear_comment = {
        [en] = "clear all words",
        [ru] = "слова ниже будут удалены",
    },
    complete_campaign = {
        x = 255,
        y = 0,
        fontSize = 40,
        textColor = color_green,
        [en] = "Level completed!",
        [ru] = "Уровень завершен!",
    },
    complete_singleplay = {
        x = 255,
        y = 0,
        fontSize = 40,
        textColor = color_green,
        [en] = "Game completed!",
        [ru] = "Игра завершена",
    },
    complete_stars = {
        x = 255,
        y = 102,
        fontSize = 80,
        textColor = color_red,
        [en] = "*",
        [ru] = "*",
    },
    complete_like = {
        x = 255,
        y = 204,
        fontSize = 36,
        textColor = color_blue,
        [en] = "I like this word pair!",
        [ru] = "Мне нравится эта пара слов!",
    },
    complete_lsteps = {
        x = 51,
        y = 306,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Value of steps:",
        [ru] = "Количество шагов:",
    },
    complete_lsteps_min = {
        x = 51,
        y = 357,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Minimum of steps:",
        [ru] = "Минимум шагов:",
    },
    complete_steps = {
        x = 433,
        y = 306,
        fontSize = 36,
        textColor = color_blue,
        [en] = "0",
        [ru] = "0",
    },
    complete_steps_min = {
        x = 433,
        y = 357,
        fontSize = 36,
        textColor = color_blue,
        [en] = "0",
        [ru] = "0",
    },
    title_results = {
        x = 0,
        y = 0,
        fontSize = 60,
        textColor = color_blue,
        [en] = "Results",
        [ru] = "Результаты",
    },
    start_results = {
        x = 0,
        y = 0,
        fontSize = 60,
        textColor = color_blue,
        [en] = "WORDEVO",
        [ru] = "МУХОСЛОН",
    },
    allchains = {
        x = 459,
        y = 153,
        fontSize = 36,
        textColor = color_blue,
        [en] = "0",
        [ru] = "0",
    },
    lallchains = {
        x = 102,
        y = 153,
        fontSize = 36,
        textColor = color_blue,
        [en] = "All chains:",
        [ru] = "Всего решено цепочек:",
    },
    res_start = {
        x = 51,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "Start",
        [ru] = "Начальное",
    },
    res_finish = {
        x = 255,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "Finish",
        [ru] = "Конечное",
    },
    res_steps = {
        x = 469,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "S",
        [ru] = "Ш",
    },
    res_rated = {
        x = 520,
        y = 10,
        fontSize = 32,
        textColor = color_blue,
        [en] = "R",
        [ru] = "Р",
    },
    lang = {
        x = 20,
        y = 33,
        fontSize = 40,
        textColor = color_blue,
        [en] = "*",
        [ru] = "*",
    },
    langl = {
        x = 51,
        y = 51,
        fontSize = 40,
        textColor = color_blue,
        [en] = "Language:",
        [ru] = "Язык:",
    },
}

backbtn = {
    [en] = "Back",
    [ru] = "Назад",
    scSinglePlay = {
        x = 51,
        y = 816,
    },
    scPlay = {
        x = 408,
        y = 663,
    },
    scCampaign = {
        x = 51,
        y = 816,
    },
}

keylines = {
    { -- line 3
        [en] = {"z", "x", "c", "v", "b", "n", "m", "#"},
        [ru] = {"я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "ъ", "#"},
    },
    { -- line 2
        [en] = {"a", "s", "d", "f", "g", "h", "j", "k", "l"},
        [ru] = {"ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"},
    },
    { -- line 1
        [en] = {"q", "w", "e", "r", "t", "y", "u", "i", "o", "p"},
        [ru] = {"й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"},
    },
}

function getText(value)
    local text = value[language];

    if (text == nil) then
        text = "WRONG";
    end

    return text;
end

function myLenght(str)
    str = "" .. str;

    str = string.gsub(str, string.char(208), "");
    str = string.gsub(str, string.char(209), "");

    return #str;
end

function mySub(str, begin, last)
    str = "" .. str;

    local result = "";

    local i, p1, p2, pos = 0, 0, 0, 0;
    local c1, c2 = "", "";
    while i <= #str do
        i = i + 1;
        pos = pos + 1;

        p1, p2 = i, i;
        c1 = str:sub(i,i);

        -- print("mySub_B", i, pos, begin, last, string.byte(c1))

        if string.byte(c1) == 208 or string.byte(c1) == 209 then
            p2 = i + 1; i = p2;
        end

        if pos >= begin and pos <= last then
            result = result .. str:sub(p1, p2);
        end

        -- print("mySub_A", i, pos, p1, p2, result, result:byte(1, #result))
    end

    -- print("mySub", begin, last, #str, str, "result " .. result:byte(1, #result));

    return result;
end

function myUpper(str)
    str = "" .. str;

    local result = "";

    for i=1, myLenght(str) do
        local cur = mySub(str, i, i);

        if #cur == 1 then
            result = result .. cur:upper();
        else
            local c1 = cur:sub(1,1):byte();
            local c2 = cur:sub(2,2):byte();

            if (c1 == 208 and c2 >= 176 and c2 <= 191)
                or (c1 == 209 and c2 >= 128 and c2 <= 143) then
                if c1 == 208 then
                    result = result .. string.char(208) .. string.char(c2 - 32);
                else
                    result = result .. string.char(208) .. string.char(c2 + 32);
                end
            else
                result = result .. cur;
            end
        end
    end

    return result;
end

function myLower(str)
    str = "" .. str;

    local result = "";

    for i=1, myLenght(str) do
        local cur = mySub(str, i, i);

        if #cur == 1 then
            result = result .. cur:lower();
        else
            local c1 = cur:sub(1,1):byte();
            local c2 = cur:sub(2,2):byte();

            if (c1 == 208 and c2 >= 144 and c2 <= 175) then
                if c2 > 159 then
                    result = result .. string.char(209) .. string.char(c2 - 32);
                else
                    result = result .. string.char(208) .. string.char(c2 + 32);
                end
            else
                result = result .. cur;
            end
        end
    end

    return result;
end

function getLetter(word, index)
    --[[
    if game_language == ru then
        local i, ri = 1, 0;
        while i <= #word do
            ri = ri + 1;

            if string.sub(word, i, i) ~= " " then
                if ri == index then
                    return string.sub(word, i, i + 1);
                end

                i = i + 2;
            else
                if ri == index then
                    return string.sub(word, i, i);
                end

                i = i + 1;
            end
        end
    else
        return string.sub(word, index, index);
    end
    ]]--

    -- return string.sub(word, index, index);
    return mySub(word, index, index);
end

function getWordLenght(word)
    --[[
    local lenght = 0;
    local subword = string.gsub(word, " ", "");

    if game_language == ru then
        lenght = #subword * 0.5 + #word - #subword;
    else
        lenght = #word;
    end

    -- print("getWordLenght", word, #word, #subword, lenght)

    return lenght;
    ]]--

    -- return #word;
    return myLenght(word);
end

function getImageSizes(image)
    image = display.newImage(image);

    local width = image.width * scale;
    local height = image.height * scale;

    image:removeSelf();
    image = nil;

    return width, height;
end

function getStars(steps, steps_min)
    local text = "*";

    if steps == 0
        or steps == nil
        or steps_min == nil then
        return "";
    end

    if steps < math.ceil(steps_min * 1.5) then
        text = "* *";
    end

    if steps < math.ceil(steps_min * 1.2) then
        text = "* * *";
    end

    return text;
end

function getLevel(params)
    print("start getting level");

    local start, finish = myLower(params.start), myLower(params.finish);
    --print(start)
    --os.setlocale("ru");
    --print(start)

    local db_words = sqlite.open(system.pathForFile(db_name[game_language], system.ResourceDirectory));

    local dict = {};

    local sql = "SELECT * FROM dict WHERE length=" .. myLenght(start) .. ";";
    -- sql = "SELECT * FROM dict;";

    local ds = 0;
    for row in db_words:nrows(sql) do
        ds = ds + 1;
        dict[row.word] = row.word:lower();
    end

    print("size of dictionary = " .. ds, start, myLenght(start), sql, db_name[game_language]);

    local vowels = vowels[game_language];
    local alphabet = alphabet[game_language];

    function mutate(population)
        print("mutate start", "ps = " .. #population, "st = " .. os.time());

        local result = {};
        -- print(#population);

        for p = 1, #population do
            local cur = population[p];
            local word = cur.name;

            -- print(p, cur, word);

            local lenght = myLenght(word);
            for i = 1, lenght do
                local b = mySub(word, 0, i-1);
                local e = mySub(word, i+1, lenght);

                -- print(word, b, e);

                for a = 1, #alphabet do
                    local newWord = (b .. alphabet[a] .. e):lower();
                    -- print(newWord, dict[newWord]);

                    if (dict[newWord] and word ~= newWord) then
                        result[#result + 1] = {name = newWord, parent = cur, parents = cur.parents + 1};
                    end
                end
            end
        end

        print("mutate finish", "rs = " .. #result, "st = " .. os.time());

        return result;
    end

    function select(population, index)
        print("select start", "ps = " .. #population, "step = " .. index, "st = " .. os.time());

        local result = {};
        local unique = {};

        for p = 1, #population do
            local cur = population[p];
            unique[cur.name] = cur;
        end

        -- get unique words
        for k,v in pairs(unique) do
            local cur = v;
            cur.fitness = fitness(cur);
            result[#result + 1] = cur;
        end

        print("select unique", "ps = " .. #result, "st = " .. os.time());

        --[[
        for k,v in pairs(result) do
            print(k);
        end
        ]]--

        function SortPartition(arr, bIndex, eIndex)
            local rIndex = math.random(bIndex, eIndex)
            arr[rIndex], arr[eIndex] = arr[eIndex], arr[rIndex]
            local i, j = bIndex-1, bIndex
            while j < eIndex do
                if arr[j].fitness > arr[eIndex].fitness then
                    i = i + 1
                    result[i], result[j] = result[j], result[i]
                end
                j = j + 1
            end
            result[i+1], result[eIndex] = result[eIndex], result[i+1]
            return i+1
        end

        function QuickSort(arr, bIndex, eIndex)
            local mid = SortPartition(arr, bIndex, eIndex)
            if bIndex < mid then
                QuickSort(arr, bIndex, mid-1)
            end
            if mid < eIndex then
                QuickSort(arr, mid+1, eIndex) end
        end

        local function sortTable(tbl)
            print("select sort start", "ts = " .. #tbl, "st = " .. os.time());

            function comp(a, b)
                local result = true;

                if (a == nil or b == nil) then
                    result = false;
                end

                if (a.fitness >= b.fitness) then
                    result = false;
                end

                return result;
            end

            repeat
                local _done = true

                for k = 1, #result - 1 do
                    if comp(result[k], result[k+1]) then
                        result[k], result[k+1] = result[k+1], result[k];
                        _done = false
                        break
                    end
                end
            until _done

            print("select sort finish", "ts = " .. #tbl, "st = " .. os.time());
        end

        print("quick sort finish", "ts = " .. #result, "s= " .. os.time());
        if #result > 1 then
            QuickSort(result, 1, #result);
        end
        print("quick sort finish", "ts = " .. #result, "f= " .. os.time());

        print("select cut", "rs = " .. #result, "st = " .. os.time());

        local result_cutted = {};
        if (#result > max_population) then
            for k = 1, max_population do
                result_cutted[k] = result[k];
            end
        else
            result_cutted = result;
        end

        print("select finish", "rs = " .. #result_cutted, "st = " .. os.time());

        return result_cutted;
    end

    function isVowel(letter)
        result = false;

        for k,v in pairs(vowels) do
            if (letter == v) then
                result = true;
                break;
            end
        end

        return result;
    end

    function fitness(cur)
        local result = 0;
        local word = cur.name;

        for l = 1, #word do
            local ch = mySub(word, l, l);
            local chF = mySub(finish, l, l);
            local chV = isVowel(ch);
            local chFV = isVowel(chF);

            if (ch == chF) then
                result = result + 3;
            elseif (chV and chFV) then
                result = result + 2;
            elseif (chFV) then
                result = result + 1;
            end
        end

        return result + cur.parents/(max_level);
    end

    function getParent(child)
        local word = child.name;
        local current = child.parent;

        while (current and current.parent) do
            local mis = 0;
            local parent_name = current.parent.name;

            for l = 1, #word do
                if mySub(word, l, l) ~= mySub(parent_name, l, l) then
                    mis = mis + 1;
                end
            end

            if (mis > 1) then
                break;
            else
                current = current.parent;
            end
        end

        return current;
    end

    local child = false;
    local index = 1;
    local population = select(mutate({[1] = {name = start, parent = nil, parents = 0}}), index);

    print("first population size is " .. #population)

    while (index <= max_level and #population > 0) do
        print("selection", index, population[1].name, finish)
        if (population[1].name == finish) then
            child = population[1];
            break;
        end

        index = index + 1;
        population = select(mutate(population), index);
    end

    local result = {};

    while (child) do
        result[#result + 1] = child.name;
        child = getParent(child);
    end

    for k,v in pairs(result) do
        print(k, v);
    end

    return #result - 1;
end
