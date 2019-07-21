pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()

--[[
    p0={
    x=20,
    y=100,
    }
    p1={
    x=80,
    y=100,
    }
    p2={
    x=20,
    y=60,
    }
    p3={
    x=80,
    y=60,
    }
    --]]
    t=0
   -- cp=2
      --{x,y,cp1.x,cp1.y,cp2.x,cp2.y}
     curvepoints={
         --[[
        {x=20,y=100,cp={{x=0,y=0},{x=0,y=0}}},
        { x=80,y=100,cp={{x=0,y=0},{x=0,y=0}}},
      
        {x=80,y=60,cp={{x=0,y=0},{x=0,y=0}}},
        { x=20,y=60,cp={{x=0,y=0},{x=0,y=0}}},
        --]]
    }
    trackpoints={}
    inittrail(curvepoints,trackpoints,5,10,20)
    
end
function inittrail(points,trackpoints,n1,n2,buffer)
    
    for i = 1,n1 do 
        if i == 1 then
        add(points,
            {x=rnd(128),y=rnd(128),cp={{x=0,y=0},{x=0,y=0}}}
        )
        elseif i >1 then
            local x = points[i-1].x+buffer/2+rnd(128-buffer)
            local y = points[i-1].y+buffer/2+rnd(128-buffer)
            x %= 128
            y %= 128
            add(points,
            {x=x,y=y,cp={{x=0,y=0},{x=0,y=0}}}
        )
        
        end 
    end

    


    for i,p in pairs(points) do
        
        if i == 1 then 
            p.cp[1].x = p.x +rnd(40)-20
            p.cp[1].y = p.y +rnd(40)-20
            p.cp[2].x = points[i+1].x +rnd(40)-20
            p.cp[2].y = points[i+1].y +rnd(40)-20
            makecbcpoints(p.x,p.y,points[i+1].x,points[i+1].y,
            p.cp[1].x,p.cp[1].y,p.cp[2].x,p.cp[2].y,n2,trackpoints)
        end
       if i >1 and i< #points then
      
          --  local ba = atan2(p.x-points[i-1].cp2.x,
            --p.y-points[i-1].cp2.x)
            local xdist = p.x-points[i-1].cp[2].x
            local ydist = p.y-points[i-1].cp[2].y

            p.cp[1].x = p.x + xdist
            p.cp[1].y = p.y + ydist
            p.cp[2].x = points[i+1].x +rnd(40)-20
            p.cp[2].y = points[i+1].y +rnd(40)-20
            makecbcpoints(p.x,p.y,points[i+1].x,points[i+1].y,
            p.cp[1].x,p.cp[1].y,p.cp[2].x,p.cp[2].y,n2,trackpoints)
        end
        if i == #points then
            local xdist = p.x-points[i-1].cp[2].x
            local ydist = p.y-points[i-1].cp[2].y
            local xdist2 = points[1].x-points[1].cp[1].x
            local ydist2 = points[1].y-points[1].cp[1].y
          
            p.cp[1].x = p.x + xdist
            p.cp[1].y = p.y + ydist
            p.cp[2].x =  points[1].x + xdist2
            p.cp[2].y =  points[1].y + ydist2
            makecbcpoints(p.x,p.y,points[1].x,points[1].y,
            p.cp[1].x,p.cp[1].y,p.cp[2].x,p.cp[2].y,n2,trackpoints)
        end

    end
end



function drawtrack(trackpoints)
    for i,p in pairs(trackpoints) do
        if i < #trackpoints then
            
            line(p.x,p.y,trackpoints[i+1].x,trackpoints[i+1].y,7)
            pset(p.x,p.y,11)
        else
            
            line(p.x,p.y,trackpoints[1].x,trackpoints[1].y,7)
            pset(p.x,p.y,11)
        end
        



    end
end

--draw bezier curve
function makecbcpoints(x1,y1,x2,y2,x3,y3,x4,y4,n,trackpoints)
    for i = 1,n do 
        local t = i/n
        local x=cbcvector(x1,x2,x3,x4,t)
        local y=cbcvector(y1,y2,y3,y4,t)
        
        add(trackpoints,
        {x=x,
        y=y} )
    end
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

-- cubic bezier curve vector
function cbcvector(v1,v2,v3,v4,t) 
    return  lv(qbcvector(v1,v2,v3,t), qbcvector(v1,v2,v4,t),t)
end

function _update()
    t %=1
    t+=0.01

end
function _draw()
    cls()
    print(t,11)
    drawtrack(trackpoints)
    
    
    
    
    --[[
    --curve
    --drawqbc(p0.x,p0.y,p1.x,p1.y,p2.x,p2.y,150,2)
    drawcbc(p0.x,p0.y,p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,150,2)
 

    --points
    pset(p0.x,p0.y,11)
    pset(p1.x,p1.y,11)
    pset(p2.x,p2.y,11)
    pset(p3.x,p3.y,11)
    --moving line
    line(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),12)
    
    line(lv(p3.x,p1.x,t),lv(p3.y,p1.y,t),lv(p0.x,p3.x,t),lv(p0.y,p3.y,t),12)
    line(qbcvector(p0.x,p1.x,p2.x,t),qbcvector(p0.y,p1.y,p2.y,t),qbcvector(p0.x,p1.x,p3.x,t),qbcvector(p0.y,p1.y,p3.y,t),12)
    --moving points
    pset(lv(p0.x,p1.x,t),lv(p0.y,p1.y,t),7)
    pset(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),7)
    pset(lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),7)
    --moving line
   --line(lv(p2.x,p1.x,t),lv(p2.y,p1.y,t),lv(p0.x,p2.x,t),lv(p0.y,p2.y,t),12)
    --moving curved point
    pset(qbcvector(p0.x,p1.x,p2.x,t),qbcvector(p0.y,p1.y,p2.y,t),7)
    pset(qbcvector(p0.x,p1.x,p3.x,t),qbcvector(p0.y,p1.y,p3.y,t),7)
    pset(cbcvector(p0.x,p1.x,p2.x,p3.x,t),cbcvector(p0.y,p1.y,p2.y,p3.y,t),7)
    --]]
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
