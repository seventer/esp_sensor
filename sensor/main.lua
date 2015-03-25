wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
-- wifi config start
wifi.sta.config("ESSID","passwd")
-- wifi config end--


tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
     print("Connecting to AP...")
   else
     print('IP: ',wifi.sta.getip())
     tmr.stop(0)
     print("Ready")
     tmr.delay(5000000)
     print("Start Domo")
      
     sf="settings.lua"
     sfh=file.open(sf,"r")
     print(sfh)
     if (sfh) then
          print(sf .. " exists")
          file.close(sf)
          print("loading " .. sf)
          dofile(sf)
     else
          print(sf .. " not found")
     end

      if (ip==nil) or (io==nil) or (port==nil) or (idx==nil) then
          print("Error in settings... abort")
      else
          print("loading domo.lua")
          dofile("domo.lua")
      end
   end
end)


