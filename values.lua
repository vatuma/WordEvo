--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 10.07.12
-- Time: 23:23
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall);

local sqlite = require("sqlite3");

-- scaling
cell = 51;
scale = 1;
main_height = 1024;
wordmodule_x = 51;
wordmodule_y = 153;
wordmodule_width = 561 + 51;
wordmodule_height = 459;

-- localization
en = "en";
ru = "ru";
language = en;
game_language = en;
db_name = {
    [en] = "dict/dicten.sqlite",
    [ru] = "dict/dictrus.sqlite",
}

-- game types
tblcampaign = "wmcampaign";
tblsingleplay = "wmsingleplay";

-- genetic algorithm
max_level = 10;
max_population = 50;

alphabet = {
    [en] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "u", "v", "w", "t", "x", "y", "z"},
}

vowels = {
    [en] = {"a", "e", "i", "o", "u", "y"},
}

-- font and colors
font = "Vatuma Script slc";
color_blue =  {76,  70,  149};
color_red  =  {255, 0,   0};
color_green = {0,   255, 0};
color_grey =  {127, 134, 145};

buttons = {
    campaign = {
        x = 344,
        y = 182,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_1.png",
        over = "images/btn_border_1_pressed.png",
        [en] = "Campaign",
        [ru] = "Кампания",
    },
    single_play = {
        x = 344,
        y = 333,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_2.png",
        over = "images/btn_border_2_pressed.png",
        [en] = "Single\n play",
        [ru] = "Одиночная\n игра",
    },
    rules = {
        x = 344,
        y = 484,
        fontSize = 40,
        textColor = color_blue,
        default = "images/btn_border_4.png",
        over = "images/btn_border_4_pressed.png",
        [en] = "Rules",
        [ru] = "Правила",
    },
    type_random = {
        x = 142,
        y = 200,
        default = "images/type_random.png",
        over = "images/type_random_selected.png",
        [en] = "Случайная - случайный выбор слов",
        [ru] = "Случайная - случайный выбор слов",
    },
    type_interest = {
        x = 296,
        y = 200,
        default = "images/type_interest.png",
        over = "images/type_interest_selected.png",
        [en] = "Интересная - выбор из лучших пар",
        [ru] = "Интересная - выбор из лучших пар",
    },
    type_own = {
        x = 450,
        y = 200,
        default = "images/type_own.png",
        over = "images/type_own_selected.png",
        [en] = "Своя игра - ввод своих слов",
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
        [en] = "Своя игра - ввод своих слов",
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
        x = 102,
        y = 510,
        fontSize = 36,
        textColor = color_blue,
        [en] = "Start",
        [ru] = "Начальное",
    },
    selectpair_own_fl = {
        x = 102,
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
        x = 153,
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
    }
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

function getImageSizes(image)
    image = display.newImage(image);

    local width = image.width * scale;
    local height = image.height * scale;

    image:removeSelf();
    image = nil;

    return width, height;
end

function getLevel(params)
    print("start getting level");

    local start, finish = params.start:lower(), params.finish:lower();

    local db_words = sqlite.open(system.pathForFile(db_name[game_language], system.ResourceDirectory));

    local dict = {};

    local sql = "SELECT * FROM dict WHERE length=" .. #start .. ";";
    -- sql = "SELECT * FROM dict;";

    local ds = 0;
    for row in db_words:nrows(sql) do
        ds = ds + 1;
        dict[row.word] = row.word:lower();
    end

    print("size of dictionary = " .. ds, start, #start, sql, db_name[game_language]);

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

            for i = 1, #word do
                local b = word:sub(0, i-1);
                local e = word:sub(i+1);

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

        -- sort result by fitness
        sortTable(result);

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
            local ch = word:sub(l, l);
            local chF = finish:sub(l, l);
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
                if word:sub(l, l) ~= parent_name:sub(l, l) then
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

    return #result;
end
