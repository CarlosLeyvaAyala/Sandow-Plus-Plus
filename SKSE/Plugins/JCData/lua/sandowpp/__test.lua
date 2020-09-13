-- Testing code
--===================================================
-- This unit is for testing how are algorithms working.
-- Modify `sandowpp.generateDataTree()` at your leisure and then run this file.

local s = require 'init'
local serpent = require("serpent")
local luna = require 'lunajson'


local _test = {}

local t = s.runTest()
print(serpent.block(t))
local dataTree = luna.encode(t)
local ft = io.open("C:/Users/Osrail/Documents/My Games/Skyrim Special Edition/JCUser/test.json", "w")
ft:write(dataTree)
ft:close()

return _test
