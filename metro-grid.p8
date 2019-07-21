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
grid = {}
squaresize = 10

function _init()
    init_grid()
    poke(0x5F2D, 1) -- mouse active
end


function _update60()
    update_mouse()
    update_cam()
end

function _draw()
    cls()
    draw_grid()
    draw_sequencers()
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
        -- background
        rectfill(s.x, s.y, s.endx, s.endy, 6)

        -- the actual pads
        local padding_x = 0
        local padding_y = squaresize

        for pad_x=0,s.pads_x do
            for pad_y=0,s.pads_y-1 do
                rect(s.x+padding_x+pad_x*squaresize, s.y+padding_y+pad_y*squaresize,
                     s.x+padding_x+pad_x*squaresize+squaresize, s.y+padding_y+pad_y*squaresize+squaresize, 5)
                
            end
        end
        

        -- control bar
        rectfill(s.x, s.y, s.endx, s.y+10, 14)
        line(s.x, s.y + 10, s.endx, s.y+10, 2)
    
        -- connection point
        rect(s.endx - 6, s.y + 3, s.endx - 3, s.y + 6, 2)
        rectfill(s.endx - 5, s.y + 4, s.endx - 4, s.y + 5, 1)
        pset(s.endx - 5, s.y + 4, 0)


        -- underline / shadow
        -- line(s.x, s.y+squaresize, s.endx, s.y+squaresize)
        line(s.x, s.endy, s.endx, s.endy, 1)

        -- side lines
        -- line(s.x, s.endy, s.endx, s.endy, 1)


    end
end

function add_sequencer()
    local sequencer = {
        x = mouse.drag_start_square.x,
        y = mouse.drag_start_square.y,
        endx = mouse.hovering_square.x + squaresize,
        endy = mouse.hovering_square.y + squaresize,
        pads_x = mouse.hovering_square.x_index - mouse.drag_start_square.x_index,
        pads_y = mouse.hovering_square.y_index - mouse.drag_start_square.y_index
    }

    add(sequencers, sequencer)
end


__gfx__
11000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16611100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
