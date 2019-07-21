pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include utils.p8

cam = {
    x = 0,
    y = 0,
    panning = false
}

mouse = {
    x = 0,
    y = 0,
    lastx = 0,
    lasty = 0,
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
    update_pan()
end

function _draw()
    cls()
    draw_grid()
    draw_mouse()
end



-- grid
function init_grid()
    for x=0,20 do
        for y=0,20 do
            add(grid, {
                x = x * squaresize,
                y = y * squaresize
            })
        end
    end
end


function draw_grid()
    for point in all(grid) do
        -- in rect, using >= to include the first pixel as well
        local hover =  mouse.x >= point.x and mouse.x < point.x + 10
                       and mouse.y >= point.y and mouse.y < point.y + 10

        if hover then 
            rectfill(point.x,point.y,point.x+squaresize,point.y+squaresize,1)
        else 
            pset(point.x,point.y, 1)
        end
    end

    -- border of grid
    rect(grid[1].x,grid[1].y, grid[#grid -1].x, grid[#grid-1].y,5)
end


-- mouse
function update_mouse()
    mouse.lastx = mouse.x
    mouse.lasty = mouse.y
    mouse.x = stat(32) + cam.x
    mouse.y = stat(33) + cam.y
    mouse.pressed = stat(34) == 1
end


function draw_mouse()
    local s = cam.panning and 1 or 0
    spr(s,mouse.x,mouse.y)
end



-- pan
function update_pan()
    cam.panning = btn(🅾️) and mouse.pressed
    if cam.panning then
        local diffx = mouse.x - mouse.lastx
        local diffy = mouse.y - mouse.lasty
        cam.x -= diffx
        cam.y -= diffy
    end


    camera(cam.x, cam.y)
end




__gfx__
77700000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
