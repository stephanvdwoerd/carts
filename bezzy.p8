pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 p0={
 x=20,
 y=100,
 }
 p1={
 x=80,
 y=100,
 }
 p2={
 x=60,
 y=60,
 }
 t=0
end






function lv(v1,v2,t)
    return (1-t)*v1+t*v2
end

--Quadratic Bezier Curve Vector
function qbcvector(v1,v2,v3,t) 
    return  lv(lv(v1,v3,t), lv(v3,v2,t),t)
end


--draw bezier curve

--x1,y1 = starting point 
--x2,y2 = end point
--x3,y3 = 3rd manipulating point 
--n = "smoothness"
--c = color
function drawqbc(x1,y1,x2,y2,x3,y3,n,c)
    for i = 1,n do 
        local t = i/n
       pset(qbcvector(x1,x2,x3,t),qbcvector(y1,y2,y3,t),c)
    end
end

function _update()
    t %=1
    t+=0.01
    if btn(➡️) then
        p2.x+=1
    end
    if btn(⬅️) then
        p2.x-=1
    end
    if btn(⬇️) then
        p2.y+=1
    end
    if btn(⬆️) then
        p2.y-=1
    end
end
function _draw()
    cls()
    print(t,11)
    
    --curve
    drawqbc(p0.x,p0.y,p1.x,p1.y,p2.x,p2.y,150,2)


    --points
    pset(p0.x,p0.y,11)
    pset(p1.x,p1.y,11)
    pset(p2.x,p2.y,11)
    --moving line
    line(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),12)
    --moving points
    pset(lv(p0.x,p1.x,t),lv(p0.y,p1.y,t),7)
    pset(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),7)
    pset(lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),7)
    --moving line
    line(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),12)
    --moving curved point
    pset(qbcvector(p0.x,p1.x,p2.x,t),qbcvector(p0.y,p1.y,p2.y,t),7)
   
    
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
