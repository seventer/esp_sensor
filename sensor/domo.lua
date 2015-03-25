--
-- domo
--

uri = "/json.htm?type=command&param=udevice&idx="..idx.."&nvalue=0&svalue="
degrees = 0

gpio.mode(io_sw,gpio.INPUT, gpio.PULLUP)
deur=0
sDeur="Closed"
last_deur=deur
alert_deur=1

uriDeur   = "/json.htm?type=command&param=udevice&idx=" ..idx_sw.."&"

--
-- Read 1-wire temperature
--
function ReadDS()
   ds=require("ds18b20")
   ds.setup(io)
   degrees=ds.read()
   -- release module
   ds=nil
   package.loaded["ds18b20"]=nil
end

--
-- Read door sensor
--
function ReadDeur()
     deur = gpio.read(io_sw)
     if (deur==sw_inverted) then
          sDeur="nvalue=1&svalue=Closed"
     else
          sDeur="nvalue=4&svalue=Open"
     end

     if (deur == nil) then
          print("Oops: Deur is nill")
          deur=0
          sDeur="nvalue=0&svalue=Unknown"
     end
     if (deur ~= last_deur) then
          -- Deur status gewijzigd
          alert_deur=1
          last_deur=deur
          --print("Deur status is gewijzigd naar: " .. sDeur)
      end
end

--
-- Update json devices in Domoticz 
--
function updateDomo(sUri,sVal)
     conn = nil
     conn = net.createConnection(net.TCP, 0)
     --conn:on("receive", function(conn, payload)success = true print(payload)end)
     conn:on("connection",
          function(conn, payload)
               --print("Connected")
               conn:send("GET ".. sUri ..sVal .. " HTTP/1.1\r\n"
                    .."Host: ".. ip .. "\r\n"
                    .."Connection: close\r\n"
                    .."User-Agent: Mozilla/4.0 (compatible; esp8266 GvS; Windows NT 5.1)\r\n"
                    .."Accept: */*\r\n\r\n") 
           end)
          
         -- conn:on("disconnection", function(conn, payload) print('Disconnected') end)
          conn:connect(port,ip)
end

-- 1st readout is always 85C, so skip this
ReadDS()
if (degrees == nil) then
     print("Error reading temperature at startup")
else
     print('Startup DS1820. Dummy temp:'..degrees)
end

--
-- Main loop
--
tmr.alarm(0, 15000, 1, function()
     if (go==0) then 
          print("Timer loop aborted bu GO parameter")
          tmr.stop(0)
     end
     ReadDS()
     ReadDeur()
     print('heap=',node.heap())
     if (degrees == nil) then
          print("Error reading temperature")
     else
          temp = string.format("%.1f", degrees)
          collectgarbage()
          if (alert_deur==0) then
               updateDomo(uri,temp)
               print("Temperatuur gelogd")
          else
               updateDomo(uriDeur,sDeur)
               alert_deur=0
               print("Deur gelogd")
          end
     end
end)
