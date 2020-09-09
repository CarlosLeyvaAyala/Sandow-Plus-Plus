function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

-- get "script path"
script_path = get_script_path()

-- Lua implementation of PHP scandir function
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('dir "'..directory..'" /b'):lines() do
        i = i + 1
        if string.find(filename, ".lua") and (not string.find(filename, "debug.lua")) then
          t[i] = filename
        end
    end
    return t
end

file_table = scandir(script_path)

function fileop(files)
  return function (callback)
    for i, f in ipairs(files) do
      callback(script_path .. f)
    end
  end
end

operate = fileop(file_table)

function processFile(processing)
  return function(ff)
    print("==========================================")
    print(ff)
    print("Before")
    print("==========================================")
    --  Read the file
    local f = io.open(ff, "r")
    local content = f:read("*all")
    f:close()
    print(content)

      print("==========================================")
      print("After")
      print("==========================================")

    -- Edit the string
    content = processing(content)
    -- content = string.gsub(content, "package.path = ", "-- package.path = ")
    -- content = string.gsub(content, " = require ", " = jrequire ")
    print(content)
  end
end

function makeRelease(content)
  content = string.gsub(content, "package.path = ", "-- package.path = ")
  content = string.gsub(content, " = require ", " = jrequire ")
  return content
end

function makeDebug(content)
  content = string.gsub(content, "-- package.path = ", "package.path = ")
  content = string.gsub(content, " = jrequire ", " = require ")
  return content
end

operate(processFile(makeDebug))
