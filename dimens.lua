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

main_dimens = {
    cell = 51,
    height = 1024,
}

word_block = {
    x = 102,
    y = 153,
    finish = 11,
}

btn_campaign = {
    x = 344,
    y = 182,
    fontSize = 40,
    default = "images/btn_border_1.png",
    over = "images/btn_border_1_pressed.png"
}

btn_singleplay = {
    x = 344,
    y = 333,
    fontSize = 40,
    default = "images/btn_border_2.png",
    over = "images/btn_border_2_pressed.png"
}

btn_singleplay2 = {
    x = 0,
    y = 0,
    fontSize = 40,
    default = "images/btn_border_2.png",
    over = "images/btn_border_2_pressed.png"
}

btn_play = {
    x = 344,
    y = 799,
    fontSize = 40,
    default = "images/btn_border_1.png",
    over = "images/btn_border_1_pressed.png"
}

btn_random = {
    x = 296,
    y = 452,
    fontSize = 40,
    default = "images/o_1.png",
    over = "images/o_1_selected.png"
}

txt_startfinish = {
    x = 102,
    y = 10,
    fontSize = 30,
    textColor = {0, 0, 0},
}

function setScale(params)
    scale = params.scale;
end