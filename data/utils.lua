local sqrt, sin, cos = math.sqrt, math.sin, math.cos
local r1, r2 =  0          ,  1.0
local g1, g2 = -sqrt( 3 )/2, -0.5
local b1, b2 =  sqrt( 3 )/2, -0.5


function HSVToRGB( h, s, v, a )
  h=h+math.pi/2--because the r vector is up
  local r, g, b = 1, 1, 1
  local h1, h2 = cos( h ), sin( h )

  --hue
  r = h1*r1 + h2*r2
  g = h1*g1 + h2*g2
  b = h1*b1 + h2*b2
  --saturation
  r = r + (1-r)*s
  g = g + (1-g)*s
  b = b + (1-b)*s

  r,g,b = r*v, g*v, b*v

  return r*255, g*255, b*255, (a or 1) * 255
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function lerp(v0, v1, t)
   return v0 + t * (v1 - v0);
 end
