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


function draw_grid()
    for point in all(grid) do
        -- in rect, using >= to include the first pixel as well
        local hover = mouse_in_square(point)

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

    if mouse.just_pressed then
        for square in all(grid) do
            if mouse_in_square(square) then
                mouse.drag_start_square = square
            end
        end
    end

    if mouse.just_released then
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
        finished = false, 


        tick = function (self) 
            if not self.finished then
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
                        end
                    end

                    sfx(self.notes[self.current_x][self.current_y][1])
                end
            end
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
                    rect(s.x+padding_x+pad_x*squaresize + 2 , s.y+padding_y+pad_y*squaresize + 2 ,
                        s.x-padding_x+pad_x*squaresize+squaresize - 2, s.y+padding_y+pad_y*squaresize+squaresize - 2, c)
                    
                end
            end

            -- control bar
            -- rectfill(s.x, s.y, s.endx, s.y+10, 14)
            -- line(s.x, s.y + 8, s.endx, s.y+8, 2)
        
            -- connection point
            spr(2,s.endx - 6, s.endy-6)
            


            -- underline / shadow
            -- line(s.x, s.y+squaresize, s.endx, s.y+squaresize)
            line(s.x, s.endy, s.endx, s.endy, 1)

            print(s.beat, cam.x, cam.y, 7)
            print(s.current_x, cam.x, cam.y + 10, 7)
            print(s.current_y, cam.x, cam.y + 20, 7)
            print(s.notes[s.current_x][s.current_y][1], cam.x, cam.y + 30, 7)

            -- side lines
            -- line(s.x, s.endy, s.endx, s.endy, 1)
        end
    }

    -- initialize sequencer with
    -- a single note
    for x=0,pads_x do
        local row = {}
        for y=0,pads_y do
            add(row, {flr(rnd(3))})
        end
        add(sequencer.notes, row)
    end

    add(sequencers, sequencer)
end


__gfx__
11000000005500001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000555500001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1771000055550000112d110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
177710000000000011d2110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16611100000000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002305000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000010176100a0100e01013010180100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
