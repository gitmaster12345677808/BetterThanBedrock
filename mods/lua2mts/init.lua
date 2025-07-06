local S
if minetest.get_translator then
	S = minetest.get_translator("lua2mts")
else
	S = function(s) return s end
end

-- Directory separator
local DIR_DELIM = "/"
local export_path_full = table.concat({minetest.get_worldpath(), "schems"}, DIR_DELIM)

------------------------------------START LUA2MTS EXTRAS-----------------------------------------
-- Define a function to log the contents of a table
local function logTable(tableToLog)
    minetest.log("loggedTable", "Logging table contents:")
    
    -- Iterate over each key-value pair in the table
    for key, value in pairs(tableToLog) do
        -- Convert the value to a string for logging
        local valueString = tostring(value)
        
        -- Log the key-value pair
        minetest.log("loggedTable", key .. ": " .. valueString)
    end
    
    minetest.log("loggedTable", "End of table logging.")
end

local function logSchematicTable(schematic_table)
	-- Access the schematic data
	if schematic_table then
	  -- Print some information about the schematic
	  print("Schematic dimensions:")
	  print("Width:", schematic_table.size.x)
	  print("Height:", schematic_table.size.y)
	  print("Length:", schematic_table.size.z)
  
	  -- Access the nodes in the schematic
	  for z = 0, schematic_table.size.z - 1 do
		for y = 0, schematic_table.size.y - 1 do
		  for x = 0, schematic_table.size.x - 1 do
			local node = schematic_table.data[1 + x + y * schematic_table.size.x + z * schematic_table.size.x * schematic_table.size.y]
			-- Do something with the node data
			print("Node at (", x, ", ", y, ", ", z, "): ", node)
		  end
		end
	  end
	end
  end
------------------------------------START LUA2MTS MAIN-----------------------------------------
local function loadSchematicNEW(path)
    local env = {}
    local file = io.open(path)
    if not file then
        return nil, "File not found"
    end
    local code = file:read("*a")
    file:close()

    local func = load("return function() " .. code .. " end", nil, "t", env)
    if func then
        func = func()
    end

    return func and env.schematic
end

local function loadSchematic(path)
	local env, file = {}, io.open(path)
	if not file then
        return nil, "File not found"
    end
	local fileContents = file:read("*a")
	file:close()
	if not fileContents:match("^%s*schematic%s*=%s*") then
		minetest.log("error", "File is not a valid schematic file. Please use caution. " .. path)
		return nil, "File is not a valid schematic file. Please use caution."
	end
	minetest.log("Processing:", "Processing schematic file.")
	local func = loadstring(fileContents)
	setfenv(func, env)
	func()
	return env.schematic
end


local function replaceTextInFile(file_path, string_to_replace, replacement, modified_file_suffix)
	-- Read the file content
	local file = io.open(file_path, "r")
	if file then
	  local content = file:read("*all")
	  file:close()
  
	  -- Replace string_to_replace with replacement
	  local modified_content = content:gsub(string_to_replace, replacement)
  
	  -- Write the modified content back to the file
	  file = io.open(file_path..modified_file_suffix, "w")
	  if file then
		file:write(modified_content)
		file:close()
	  else
		minetest.log("error", "Failed to open the file for writing: " .. file_path)
	  end
	else
	  minetest.log("error", "Failed to open the file for reading: " .. file_path)
	end
  end
  


local mts_save = function(fname, schematic)
	local s = minetest.serialize_schematic(schematic, "mts", {})
	if not s then
		return false, S("Failed to serialize schematic.")
	end
	local mts_path = export_path_full .. DIR_DELIM .. fname .. ".mts"
	local file, err = io.open(mts_path, "wb")
	if not file then
		return false, S("Failed to create MTS file.")
	end
	if err == nil then
		file:write(s)
		file:flush()
		file:close()
	end
	print("Wrote: " .. mts_path)
end

-- [chatcommand] Convert .lua file to MTS schematic file
minetest.register_chatcommand("lua2mts", {
	description = S("Convert .lua file to .mts schematic file"),
	privs = {server = true},
	params = S("<lua file>"),
	func = function(name, param)
		local lua_file = param

		if not lua_file then
			return false, S("No Lua file specified.")
		end

		local lua_path = export_path_full .. DIR_DELIM .. lua_file .. ".lua"
		local schematic, err = loadSchematic(lua_path)
		if not schematic then
			return false, S(err or "Invalid schematic data in Lua file.")
		elseif type(schematic) ~= "table" then  --this is a bit of a safety check to make sure the lua file wasn't an executable but is just a table
			return false, S("Invalid schematic data in Lua file.")
		end
		
		--logTable(schematic2)
		local mts_path = lua_file:gsub("%.lua$", "")  -- Remove .lua extension
			mts_save(mts_path, schematic)
		return true, S("Exported schematic to " .. mts_path .. ".mts")
	end,
})

-- [chatcommand] Convert .lua file to MTS schematic file
--[[minetest.register_chatcommand("lua2mtsOLD", {
	description = S("Convert .lua file to .mts schematic file"),
	privs = {server = true},
	params = S("<lua file>"),
	func = function(name, param)
		local lua_file = param

		if not lua_file then
			return false, S("No Lua file specified.")
		end

		local lua_path = export_path_full .. DIR_DELIM .. lua_file .. ".lua"
		modified_file_suffix = "_return"
		replaceTextInFile(lua_path, "^schematic =", "return", modified_file_suffix )
		local load_func, err = loadfile(lua_path..modified_file_suffix)
		if not load_func then
			return false, S("Failed to load Lua file: ") .. err
		end

		local success, schematic = pcall(load_func)
		if not success or type(schematic) ~= "table" then
			return false, S("Invalid schematic data in Lua file.")
		end
		--logTable(schematic2)
		local mts_path = lua_file:gsub("%.lua$", "")  -- Remove .lua extension
		mts_save(mts_path, schematic)
		return true, S("Exported schematic to " .. mts_path .. ".mts")
	end,
})]]
