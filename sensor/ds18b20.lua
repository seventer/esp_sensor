--------------------------------------------------------------------------------
-- DS18B20 one wire module for NODEMCU
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com>
--------------------------------------------------------------------------------

-- Set module name as parameter of require
local modname = ...
local M = {}
_G[modname] = M
--------------------------------------------------------------------------------
-- Local used variables
--------------------------------------------------------------------------------
-- DS18B20 dq pin
local pin = nil
-- DS18B20 default pin
local defaultPin = 4
--------------------------------------------------------------------------------
-- Local used modules
--------------------------------------------------------------------------------
-- Table module
local table = table
-- String module
local string = string
-- One wire module
local ow = ow
-- Timer module
local tmr = tmr
-- Limited to local environment
setfenv(1,M)
--------------------------------------------------------------------------------
-- Implementation
--------------------------------------------------------------------------------
C = 0
F = 1
K = 2

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

function setup(dq)
  pin = dq
  if(pin == nil) then
    pin = defaultPin
  end
  ow.setup(pin)
end

function addrs()
  setup(pin)
  tbl = {}
  ow.reset_search(pin)
  repeat
    addr = ow.search(pin)
    if(addr ~= nil) then
      table.insert(tbl, addr)
    end
    tmr.wdclr()
  until (addr == nil)
  ow.reset_search(pin)
  return tbl
end

function readNumber(addr, unit)
  result = nil
  setup(pin)
  flag = false
  if(addr == nil) then
    ow.reset_search(pin)
    count = 0
    repeat
      count = count + 1
      addr = ow.search(pin)
      tmr.wdclr()
    until((addr ~= nil) or (count > 100))
    ow.reset_search(pin)
  end
  if(addr == nil) then
    return result
  end
  crc = ow.crc8(string.sub(addr,1,7))
  if (crc == addr:byte(8)) then
    if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
      --print("Device is a DS18S20 family device.")
      ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin, 0x44, 1)
      -- tmr.delay(1000000)
      present = ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin,0xBE,1)
      -- print("P="..present)
      data = nil
      data = string.char(ow.read(pin))
      for i = 1, 8 do
        data = data .. string.char(ow.read(pin))
      end
      -- print(data:byte(1,9))
      crc = ow.crc8(string.sub(data,1,8))
      -- print("CRC="..crc)
      if (crc == data:byte(9)) then
        if(unit == nil or unit == C) then
          t = (data:byte(1) + data:byte(2) * 256)
           if (t > 32768) then
                 t = (bxor(t, 0xffff)) + 1
                 t = (-1) * t
           end
          t = t * 625
          if(addr:byte(1) == 0x10) then
              -- we have DS18S20, the measurement must change
              t = t * 8;  -- compensating for the 9-bit resolution only
              t = t - 2500 + ((10000 * (data:byte(8) - data:byte(7))) / data:byte(8))
          end
          
        elseif(unit == F) then
          t = (data:byte(1) + data:byte(2) * 256) * 1125 + 320000
        elseif(unit == K) then
          t = (data:byte(1) + data:byte(2) * 256) * 625 + 2731500
        else
          return nil
        end
        t = t / 10000
        -- print("Temperature="..t1.."."..t2.." Centigrade")
        -- result = t1.."."..t2
        return t
      end
      tmr.wdclr()
    else
    -- print("Device family is not recognized.")
    end
  else
  -- print("CRC is not valid!")
  end
  return result
end

function read(addr, unit)
  t = readNumber(addr, unit)
  if (t == nil) then
    return nil
  else
    return t
  end
end

-- Return module table
return M
