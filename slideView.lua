-- slideView.lua
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

module(..., package.seeall)

local values = require("values");

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local imgNum = nil
local images = nil
local touchListener, nextImage, prevImage, cancelMove, initImage
local background
local imageNumberText, imageNumberTextShadow

local receiveEvents = true;

function new( imageSet, screenH )
	local g = display.newGroup()

    images = {}
	for i = 1,#imageSet do
        local p = imageSet[i]
		g:insert(p);

        if (i > 1) then
            p.x = screenW -- all images offscreen except the first one
        else
            p.x = 0
        end

        p.y = 0;

		images[i] = p
	end

    g.background = display.newRect( 0, 0, screenW, screenH )
    g.background:setFillColor(0, 0, 0, 0)

    g:insert(1, g.background)

    background = g.background;

    imgNum = 1
	
	g.x = 0
	g.y = values.campaign_y * values.scale + display.screenOriginY

    function g:setTarget(target)
        self.level = target;
    end

    function g:setReceive(receive)
        if receive then
            timer.performWithDelay(200, function() self.background:addEventListener("touch", self.background) end);
        else
            self.background:removeEventListener("touch", self.background);
        end
    end
			
	function touchListener (self, touch)
        if receiveEvents == false then
            return false;
        end

		local phase = touch.phase
		-- print("slides", phase)
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

			startPos = touch.x
			prevPos = touch.x

        elseif( self.isFocus ) then
        
			if ( phase == "moved" ) then
			
				if tween then transition.cancel(tween) end
	
				-- print(imgNum)
				
				local delta = touch.x - prevPos
				prevPos = touch.x
				
				images[imgNum].x = images[imgNum].x + delta
				
				if (images[imgNum-1]) then
					images[imgNum-1].x = images[imgNum-1].x + delta
				end
				
				if (images[imgNum+1]) then
					images[imgNum+1].x = images[imgNum+1].x + delta
				end

			elseif ( phase == "ended" or phase == "cancelled" ) then
				
				dragDistance = touch.x - startPos
				-- print("dragDistance: " .. dragDistance)
				
				if (dragDistance < -40 and imgNum < #images) then
					nextImage()
				elseif (dragDistance > 40 and imgNum > 1) then
					prevImage()
                else
                    if math.abs(dragDistance) < 3
                        and self.parent.level ~= nil then
                        self.parent.level:onEnded();
                    end

					cancelMove()
				end
									
				if ( phase == "cancelled" ) then		
					cancelMove()
				end

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
														
			end
		end
					
		return true
		
	end

	function cancelTween()
		if prevTween then 
			transition.cancel(prevTween)
		end
		prevTween = tween 
	end
	
	function nextImage()
		tween = transition.to( images[imgNum], {time=400, x=-screenW, transition=easing.outExpo } )
		tween = transition.to( images[imgNum+1], {time=400, x=0, transition=easing.outExpo } )
		imgNum = imgNum + 1
		initImage(imgNum)
	end
	
	function prevImage()
		tween = transition.to( images[imgNum], {time=400, x=screenW, transition=easing.outExpo } )
		tween = transition.to( images[imgNum-1], {time=400, x=0, transition=easing.outExpo } )
		imgNum = imgNum - 1
		initImage(imgNum)
	end
	
	function cancelMove()
		tween = transition.to( images[imgNum], {time=400, x=0, transition=easing.outExpo } )
		tween = transition.to( images[imgNum-1], {time=400, x=-screenW, transition=easing.outExpo } )
		tween = transition.to( images[imgNum+1], {time=400, x=screenW, transition=easing.outExpo } )
	end
	
	function initImage(num)
		if (num < #images) then
			images[num+1].x = screenW
		end
		if (num > 1) then
			images[num-1].x = -screenW
		end
		-- setSlideNumber()
	end

	background.touch = touchListener
	background:addEventListener( "touch", background )

	------------------------
	-- Define public methods
	
	function g:jumpToImage(num)
		local i
		-- print("jumpToImage")
		-- print("#images", #images)
		for i = 1, #images do
			if i < num then
				images[i].x = -screenW;
			elseif i > num then
				images[i].x = screenW
			else
				images[i].x = 0
			end
		end
		imgNum = num
		initImage(imgNum)
	end

	function g:cleanUp()
		-- print("slides cleanUp")
		background:removeEventListener("touch", touchListener)
	end

	return g	
end

