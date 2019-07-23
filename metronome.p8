pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	c4=1
	c16 = 1
	c64=1
	samples={
		{name="CLCK",c=10},
		{name="KICK",c=9},
		{name="SNRE",c=12},
		{name="HHAT",c=11},
		{name="MEL1",c=14},
		{name="MEL2",c=13},
	}
	notes={
	{{},{},{},{}},
	{{},{},{},{}},
	{{},{},{},{}},
	{{},{},{},{}}
	}
	
	mouse={
		x=0,
		y=0,
		ispressed = false,
		hasclicked= false
	}
	selectednote = 5
	poke(0x5F2D, 1)
	metroon=false
	delmode = false
end

function _update()
	mouse.x =stat(32)
	mouse.y=stat(33)
	if stat(34)== 1 then
		mouse.ispressed  = true
	else
		mouse.ispressed = false
		mouse.hasclicked = false
	end

	if c64 ==5 then	
		c64 =1
		c16+=1
	end
	if c16 ==5 then
		c16 = 1
		c4 +=1
	end
	if c4== 5 then
		c4 =1
	end

	if	c64 == 1 then
		for i,n in pairs(notes[c4][c16]) do
			sfx(notes[c4][c16][i])
		end	
		if c16==1 then
			
		
			---metronome sounds
			if c4 ==1 and metroon then
				sfx(0)
			elseif metroon then
				sfx(1)
			end
		end
	end

	c64+=1	
	if btnp(❎)   then
		metroon = not metroon
	end
	if btn(🅾️)   then
		delmode = true
	else
		delmode = false
	end



end


function _draw()
	cls(1)
	drawgrid(16,28,5,20,20)
	
	--print(mouse.ispressed)
	drawbuttons(4,3,5,26,7)
	spr(0,mouse.x-1,mouse.y-1)
	if delmode then
		rect(0,0,127,127,8)
	end
end

function drawbuttons(x,y,space,w,h)
	for i ,b in pairs(samples) do
		local x0 = 0
		local y0 = 0
		local x1 = 0
		local y1 = 0
		
		if   i == 1 then
			x0 = x
			y0 = y 
			x1 = x + w 
			y1 = y + h 	
		elseif i > 1 and i <4 then
			x0 = x + (w + space)*(i-1)
			y0 = y
			x1 = x + (w + space)*(i-1)+w 
			y1 = y + h 
		elseif i > 3 then
			x0 = x+ (w + space)*(i-1-3)
			y0 = y+ (h + space)
			x1 = x+ (w + space)*(i-1-3)+w 
			y1 = y+ (h + space)+h
		end
		local ishovering = false
		
		local bc=6
		local tc=6
		if i == selectednote then
			rectfill(x0,y0,x1,y1,0)
			tc=7
			bc=5
		end
		
		if mouse.x > x0 and mouse.x< x1 and mouse.y > y0 and mouse.y< y1 then
			ishovering= true
			--rectfill(x0,y0,x1,y1,5)
			bc=7
			tc=7
			if mouse.ispressed == true and mouse.hasclicked == false then
				selectednote = i
				mouse.hasclicked = true
				rectfill(x0,y0,x1,y1,7)
			end
		end	

		rect(x0,y0,x1,y1,bc)
		rectfill(x1-2,y0+2,x1-4,y0+4,samples[i].c)
		print(samples[i].name,x0+2,y0+1,tc)
	
	end

end


--w is with of each block
--h is height off each block
function drawgrid(x,y,space,w,h)
	for i ,n in pairs(notes) do
		for ii, s in pairs(notes[i]) do
			local c = 
			{6,0,0,0}
			local x0 = 0
			local y0 = 0
			local x1 = 0
			local y1 = 0
			if ii  == 1 then
				x0 = x
				y0 = y + (h + space)*(i-1)
				x1 = x + w 
				y1 = y + (h + space)*(i-1)+h
			
				
			elseif ii > 1 then
				
				x0 = x+ (w + space)*(ii-1)
				y0 = y+ (h + space)*(i-1)
				x1 = x+ (w + space)*(ii-1)+w 
				y1 = y+ (h + space)*(i-1)+h
				
			end
			local ishovering = false
			
			
			if mouse.x > x0 and mouse.x< x1 and mouse.y > y0 and mouse.y< y1 then
				ishovering= true
				rectfill(x0,y0,x1,y1,5)
				if mouse.ispressed == true and mouse.hasclicked == false   then
					if delmode == true then
						del(notes[i][ii],notes[i][ii][#notes[i][ii]])
					elseif #notes[i][ii]<4 then
					add(notes[i][ii],selectednote)
					
					rectfill(x0,y0,x1,y1,6)
					end
					mouse.hasclicked = true
				end
			end
			



			for iii, t in pairs(notes[i][ii]) do	
				if notes[i][ii][iii] != nil then
					
					c[iii]= samples[notes[i][ii][iii]].c
					--[[
					if notes[i][ii][iii] == 4 then
						c[iii] = 11
					elseif notes[i][ii][iii] == 2 then
						c[iii] =9
				
					elseif notes[i][ii][iii] == 3 then
						c[iii] =12
					elseif notes[i][ii][iii] == 4 then
						c[iii] = 11
					elseif notes[i][ii][iii] == 5 then
						c[iii] = 14
					end
					--]]
					rectfill(x0+3+3*(iii-1),y0+3,x0+4+3*(iii-1),y0+4,c[iii] )
				end
			end
			rect(x0,y0,x1,y1,7)
			if i == c4 and ii == c16 then	
			rect(x0-1,y0-1,x1+1,y1+1,c[1])
			rect(x0,y0,x1,y1,c[1])
			end
			



		end
		
	
	end
end

__gfx__
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17766100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16671100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000003055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001825500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002465500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001861500200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180551b0551f0552205526055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000180501b0501d0502105027050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 05060708

