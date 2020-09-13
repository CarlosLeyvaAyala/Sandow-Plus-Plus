local f = require 'fun'
-- for _k, a in f.range(3) do print(a) end

-- Quick dirty script to make necessary substitutions before developing/releasing
local function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

-- get "script path"
local script_path = get_script_path()

-- Lua implementation of PHP scandir function
local function scandir(directory)
    local t, popen = {}, io.popen
    for filename in popen('dir "'..directory..'" /b'):lines() do
      table.insert(t, filename)
    end
    return t
end

-- Find all permited Lua files
local file_table, temp = {}, {}
f.each(
  function (k,_) table.insert(temp, k) end,
  f.filter(function (x) return
      string.find(x, ".lua") and
      -- Files with double underscores in their names are for developing. No need to convert them.
      not string.find(x, "__")
    end,
  scandir(script_path))
)
file_table, temp = temp, {}

local serpent = require("serpent")
print(serpent.block(file_table))

-- Generate operations on the files
local function fileop(files)
  return function (callback)
    for _, func in ipairs(files) do
      callback(script_path..func)
    end
  end
end

local operate = fileop(file_table)

local function processFile(processing)
  return function(ff)
    --  Read the file
    local ft = io.open(ff, "r")
    local content = ft:read("*all")
    ft:close()
    -- print("#############################################################")
    -- print(ff)
    -- print("Before")
    -- print("#############################################################")
    -- print(content)

    -- Edit the string
    content = processing(content)

    print("#############################################################")
    print(ff)
    print("After")
    print("#############################################################")
    print(content)

    -- Write it out
    ft = io.open(ff, "w")
    ft:write(content)
    ft:close()
  end
end

-- Reverts back libraries that need to stay as is
local function revertLibRequire(content, libName)
  return string.gsub(content, "require 'sandowpp.".. libName .."'", "require '" .. libName .. "'")
end

-- ;TODO: Modify these
local function makeRelease(content)
  content = string.gsub(content, "package.path = ", "-- package.path = ")
  content = string.gsub(content, " = require ", " = jrequire ")
  content = string.gsub(content, "require '", "require 'sandowpp.")

  content = revertLibRequire(content, "jc")
  content = revertLibRequire(content, "dmlib")
  return content
end

local function makeDebug(content)
  content = string.gsub(content, "-- package.path = ", "package.path = ")
  content = string.gsub(content, " = jrequire ", " = require ")
  content = string.gsub(content, "require 'sandowpp.", "require '")
  return content
end

-- operate(processFile(makeDebug))
 operate(processFile(makeRelease))
