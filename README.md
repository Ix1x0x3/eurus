# Eurus
A Simple command lib that I made for myself, but decided to release it.

# Getting Started

First, import the lib.

```lua
local Eurus = loadstring(
  game:HttpGet"https://raw.githubusercontent.com/Ix1x0x3/eurus/main/src/index.lua"
)();
```

Second, set your script data! <optional>

```lua
local Eurus = loadstring(
  game:HttpGet"https://raw.githubusercontent.com/Ix1x0x3/eurus/main/src/index.lua"
)();
  
Eurus:SetScriptData({
  Prefix = ";";
  ScriptName = "Eurus Admin";
});
```

  Lastly, make a command, with the availible functions!
  
  ```lua
  Eurus:AddCommand("ping", {
    --// Aliases
    "pong"
  }, {
    --// Command metadata
    Description = "Ping!"
  }, function(Self, Args)
    Eurus:Notify"Pong! Hi, "..Self.Name.."!";
  end)
  ```
  
 Cheers
