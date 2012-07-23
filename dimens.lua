--
-- Created by IntelliJ IDEA.
-- User: fydogadin
-- Date: 27.06.12
-- Time: 23:53
-- To change this template use File | Settings | File Templates.
--

module(..., package.seeall);

scale = 1;
color = {0, 0, 255};
color_blue = {76, 70, 149};
color_grey = {128, 128, 128};

main_dimens = {
    cell = 51,
    height = 1024,
}

word_block = {
    x = 51,
    y = 153,
    finish = 11,
}

btn_play = {
    x = 344,
    y = 748,
    fontSize = 40,
    default = "images/btn_border_1.png",
    over = "images/btn_border_1_pressed.png"
}

btn_random = {
    x = 296,
    y = 452,
    fontSize = 40,
    default = "images/o_3.png",
    over = "images/o_3_selected.png"
}

txt_startfinish = {
    x = 51,
    y = 10,
    fontSize = 30,
    textColor = {0, 0, 0},
}

txt_notindict = {
    x = 51,
    y = 102,
    fontSize = 36,
    textColor = {255, 0, 0},
}

txt_know = {
    x = 357,
    y = 51,
    fontSize = 32,
    textColor = {0, 255, 0},
}

function setScale(params)
    scale = params.scale;
end