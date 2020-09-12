--- Tree generator
--===================================================
--- Pre-generate the data tree used by this mod.
---
--- Since it seems we need to use
--- `JOject` (from `JContainers`) to add nested tables to their data structures, we
--- just generate a `bare tree.json` using this function and let the game load
--- it at run time.
---
--- ***You need to run this function whenever you change the data tree structrue***.
---
--- Should I use JObject? Maybe, but I don't feel like learning yet another API.

local s = require 'init'
local luna = require 'lunajson'

local _treeGen = {}

local t = s.generateDataTree()
local dataTree = luna.encode(t)
print(dataTree)
-- Your file is saved here
local ft = io.open("../../../Sandow Plus Plus/config/bare tree.json", "w")
ft:write(dataTree)
ft:close()
return _treeGen
