pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function lerp(target,current,pct)
    return (1-pct)*target + pct*current
end

function dist(x1, y1, x2, y2)
    return abs(x1 - x2) + abs(y1 - y2)
end

function rnd_el(arr)
    return arr[ceil(rnd(#arr))]
end
   
function rnd_range(low, high)
    return low + rnd(high - low)
end

function constrain(v, low, high)
    if v > high then
        return high
    elseif v < low then
        return low
    else
        return v
    end
end
