## esp_sensor
Temperature and switch sensor based on esp8266 running [nodemcu] (https://github.com/nodemcu/nodemcu-firmware) firmware.

This setup is an autonomous IOT device which monitors temperature using a 1-Wire DS1820 sensor. Also the status of a switch is monitored.
Data is pushed to the domotica system [Domoticz](http://www.domoticz.com) by calling the [json] (http://www.domoticz.com/wiki/Domoticz_API/JSON_URL%27s) uri.

####Issues
In case of reprogramming stop the running program first otherwise file corruption might occur due to insufficient memory.
Stop the program by issueing  ``` GO=0 ``` or ``` tmr.stop(0) ``` via the serial connection.
