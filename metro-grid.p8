pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include utils.p8

cam = {
    x = 0,
    y = 0,
    tx = 0,
    ty = 0,
    spd = 2,
    margin = 0
}

mouse = {
    x = 0,
    y = 0,
    lastx = 0,
    lasty = 0,
    drag_start_square = nil,
    pressed = false
}

samples={
    {name="CLCK",c=10},
    {name="KICK",c=9},
    {name="SNRE",c=12},
    {name="HHAT",c=11},
    {name="MEL1",c=14},
    {name="MEL2",c=13},
}

sequencers = {}
current_sequencer = nil
grid = {}
squaresize = 10

function _init()
    init_grid()
    poke(0x5F2D, 1) -- mouse active
end


function _update60()
    update_mouse()
    update_cam()

    for s in all(sequencers) do
        s:update_controls()
        s:tick()
    end
end

function _draw()
    cls()
    draw_grid()

    for s in all(sequencers) do
        s:draw()
    end

    draw_mouse()
end



-- grid
function init_grid()
    for x=0,20 do
        for y=0,20 do
            add(grid, {
                x = x * squaresize,
                y = y * squaresize,
                x_index = x,
                y_index = y
            })
        end
    end
end

function hovering_over_sequencer()
    for s in all(sequencers) do
        if mouse.x >= s.x  and mouse.x < s.endx
        and mouse.y >= s.y  and mouse.y < s.endy
        then
            return true
        end
    end

    return false
end


function draw_grid()
    for point in all(grid) do
        -- in rect, using >= to include the first pixel as well
        local hover = mouse_in_square(point) and not hovering_over_sequencer()

        if hover then 
            mouse.hovering_square = point
            rectfill(point.x,point.y,point.x+squaresize,point.y+squaresize,1)
        else 
            pset(point.x,point.y, 1)
        end
    end

    -- border of grid
    rect(grid[1].x,grid[1].y, grid[#grid -1].x + squaresize, grid[#grid-1].y + squaresize,1)

    -- new sequencer
    if mouse.drag_start_square then
        rect(mouse.drag_start_square.x,mouse.drag_start_square.y,
             mouse.hovering_square.x + squaresize, mouse.hovering_square.y + squaresize, 6)
        
    end
end


function mouse_in_square(square)
    return mouse.x >= square.x and mouse.x < square.x + squaresize
           and mouse.y >= square.y and mouse.y < square.y + squaresize
end


-- mouse
function update_mouse()
    mouse.lastx = mouse.x
    mouse.lasty = mouse.y
    mouse.x = stat(32) + cam.x
    mouse.y = stat(33) + cam.y
    mouse.just_pressed = (not mouse.pressed) and (stat(34) == 1)
    mouse.just_released = (stat(34) == 0) and mouse.pressed
    mouse.pressed = stat(34) == 1

    if mouse.just_pressed and not hovering_over_sequencer() then
        for square in all(grid) do
            if mouse_in_square(square) then
                mouse.drag_start_square = square
            end
        end
    end

    if mouse.just_released and not hovering_over_sequencer() then
        add_sequencer()
    end

    if not mouse.pressed then
        mouse.drag_start_square = nil
    end
end


function draw_mouse()
    local s = cam.panning and 1 or 0
    spr(s,mouse.x,mouse.y)
end



-- pan
function update_cam()
    mouse.x = stat(32) + cam.x
    mouse.y = stat(33) + cam.y
   
    if mouse.x >= 128 - cam.margin + cam.x then
     cam.tx += cam.spd
    elseif mouse.x <= cam.margin + cam.x then
     cam.tx -= cam.spd
    end
   
    if mouse.y >= 128 - cam.margin + cam.y then
     cam.ty += cam.spd
    elseif mouse.y <= cam.margin + cam.y then
     cam.ty -= cam.spd
    end
   
    cam.x = lerp(cam.tx, cam.x, 0.9)
    cam.y = lerp(cam.ty, cam.y, 0.9)
   
    camera(cam.x, cam.y)
end


-- sequencers
function draw_sequencers()
    for s in all(sequencers) do
     

    end
end

function add_sequencer()
    local pads_x = mouse.hovering_square.x_index - mouse.drag_start_square.x_index
    local pads_y = mouse.hovering_square.y_index - mouse.drag_start_square.y_index - 1
    local sequencer = {
        x = mouse.drag_start_square.x,
        y = mouse.drag_start_square.y,
        endx = mouse.hovering_square.x + squaresize,
        endy = mouse.hovering_square.y + squaresize,
        pads_x = pads_x,
        pads_y = pads_y,

        notes = {},

        current_x = 1,
        current_y = 1,
        beat = 0,
        paused = true,
        finished = false,
        next_sequencer = 2,

        tick = function (self) 
            if not self.finished and not self.paused then
                self.beat += 1

                if self.beat == 16 then
                    self.beat = 1
                    if self.current_x <= self.pads_x then
                        self.current_x += 1
                    elseif self.current_x >= self.pads_x then
                        if self.current_y <= self.pads_y then
                            self.current_x = 1
                            self.current_y += 1
                        else
                            self.finished = true -- next
                            sequencers[self.next_sequencer].paused = false
                            sequencers[self.next_sequencer].finished = false
                            sequencers[self.next_sequencer].current_x = 1
                            sequencers[self.next_sequencer].current_y = 1
                            sequencers[self.next_sequencer].beat = 0
                        end
                    end

                    for fx in all(self.notes[self.current_x][self.current_y]) do
                        sfx(fx)
                    end
                end
            end
        end,    

        
        update_controls = function(self)
            if self:hovering_over_play_pause() and mouse.just_pressed then
                self.paused = not self.paused
            end
        end,


        hovering_over_play_pause = function(s)
            return mouse.x >= s.x + 2  and mouse.x < s.x + 16
                and mouse.y >= s.endy - 10 and mouse.y < s.endy
        end,


        draw = function (s) 
          

            -- background
            rectfill(s.x, s.y, s.endx, s.endy, 1)

            -- the actual pads
            local padding_x = 0
            local padding_y = 0

            for pad_x=0,s.pads_x do
                for pad_y=0,s.pads_y do
                    local c =  (pad_x == s.current_x - 1 and pad_y == s.current_y - 1) and 7 or 13
                    local startx = s.x+padding_x+pad_x*squaresize
                    local starty = s.y+padding_y+pad_y*squaresize
                    local endx = s.x-padding_x+pad_x*squaresize+squaresize
                    local endy = s.y+padding_y+pad_y*squaresize+squaresize
                    rect(startx + 2, starty + 2, endx - 2, endy - 2, c)
                    
                    for i, note in pairs(s.notes[pad_x + 1][pad_y + 1]) do
                        pset(startx + 3 + (i - 1) * 2, starty + 3, samples[note].c)
                    end
                end
            end

            -- control bar
            -- rectfill(s.x, s.y, s.endx, s.y+10, 14)
            -- line(s.x, s.y + 8, s.endx, s.y+8, 2)

            -- play/pause button
            if (s:hovering_over_play_pause()) pal(6, 2)
            spr(s.paused and 3 or 4, s.x + 4, s.endy - 6)
            pal()
            

            -- connection line
            if s.next_sequencer and sequencers[s.next_sequencer] then 
                line(s.endx - 2, s.endy - 4, 
                    sequencers[s.next_sequencer].x, 
                    sequencers[s.next_sequencer].y, 7)
            end
        

            -- connection point
            spr(2,s.endx - 7, s.endy - 7)


            -- underline / shadow
            -- line(s.x, s.y+squaresize, s.endx, s.y+squaresize)
            line(s.x, s.endy, s.endx, s.endy, 1)

            -- print(s.beat, cam.x, cam.y, 7)
            -- print(s.current_x, cam.x, cam.y + 10, 7)
            -- print(s.current_y, cam.x, cam.y + 20, 7)
            -- print(samples[2].c, cam.x, cam.y + 30, 7)
            -- print(hovering_over_sequencer(), cam.x, cam.y + 40, 7)

            -- side lines
            -- line(s.x, s.endy, s.endx, s.endy, 1)
        end
    }

    -- initialize sequencer with
    -- a single note
    for x=0,pads_x do
        local row = {}
        for y=0,pads_y do
            add(row, {ceil(rnd(5)), ceil(rnd(5))})
        end
        add(sequencer.notes, row)
    end

    add(sequencers, sequencer)
end


__gfx__
11000000005500001111100060000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000555500001111110066000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000555500001166110060000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1777100000000000116d110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16611100000000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000003055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001825500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002465500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001861500200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180551b0551f0552205526055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180501b0501d0502105027050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
