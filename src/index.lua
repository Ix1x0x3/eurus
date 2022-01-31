local localPlayer = game.Players.LocalPlayer;
local HttpService = game:GetService("HttpService");

local Commands = {};

local ScriptData = {
    FileName = "DATA_SCRIPT.json";
    Prefix = ",";
    ScriptName = "MyAdmin"
}

local Loops = {};

local Eurus = {};

function Eurus:WriteFile(FileName, Data)
	writefile(FileName, HttpService:JSONEncode(Data))
end

function Eurus:SetScriptData(Data)
    ScriptData = Data;
end

function Eurus:ReadFile(FileName)
	return HttpService:JSONDecode(readfile(FileName))
end

function Eurus:AppendData(FileName, Name, Val)
    local ExistingData = ReadFile(FileName);
    if ExistingData[Name] ~= nil then
        ExistingData[Name] = Val
    end

    writefile(FileName, ExistingData);
end

function Eurus:WriteGenv(name, val)
    getgenv()[name] = val;
end

function Eurus:ReadGenv(name)
    if not getgenv()[name] then
        Notify('An internal error has occured! Check console to see the error.',Color3.new(1,0,0))
        return print("ReadGenv has failed: "..name.." does not exist in genv.")
    end

    return getgenv()[name];
end

function Eurus:AddCommand(Name, Aliases, Info, Code)
    Commands[Name] = {
        Aliases = Aliases;
        Info = Info;
        Run = Code;
    }
end

function Eurus:Notify(Text, Color, TagR)
    local Tag = ScriptData.ScriptName;
    if TagR then
        Tag = TagR;
        if TagR == false then Tag = false; end;
    end
    if TagR == false then
        return game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = Text,
            Color = Color or Color3.new(1,1,1),
            Font = Enum.Font.Code,
            FontSize = Enum.FontSize.Size14
        })
    end
    return game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "["..Tag.."]: "..Text,
        Color = Color or Color3.new(1,1,1),
        Font = Enum.Font.Code,
        FontSize = Enum.FontSize.Size14
    })
end

function Eurus:Chat(Text, WhisperTo)
    if WhisperTo then
        return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..WhisperTo.Name.." "..Text, "All") -- sends your message to all players
    end
    return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Text, "All") -- sends your message to all players
end

Loops.ChatL = localPlayer.Chatted:Connect(function(Msg)
    if not string.sub(Msg,1,string.len(ScriptData.Prefix))==ScriptData.Prefix then return end;
    local function CmdCheck(Name)
        local temp1 = Msg:split(" ");
        local temp2 = temp1[1]:gsub(ScriptData.Prefix, ""):lower()
        local CName = temp2;

        return Name == CName, CName;
    end

    local Ran = false;
    local Args = Msg:split(" ");
    table.remove(Args, 1);

    for i,Command in pairs(Commands) do
        local IsRan = CmdCheck(i);

        -- main name
        if IsRan then
            Ran = true
            return Command.Run(Args)
        end

        for aNum,Alias in pairs(Command.Aliases) do
            IsRan = CmdCheck(Alias)

            if IsRan and not Ran then
                Ran = true
                return Command.Run(Args)
            end
        end
    end

    if not Ran and string.sub(Msg,1,string.len(ScriptData.Prefix))==ScriptData.Prefix then
        Notify("Invalid command!")
    end
end)

--[[ 
    Your Code!

    Docs:
        AddCommand(Name, Aliases, Info, Code)
            - Name "Name of the command, e.x AddCommand("ping")
            The above will make a command named "ping".
            - Aliases "Table of the command aliases. e.x AddCommand("ping", {"pong"})
            The above will make a command named "ping" with aliases "pong".
            - Info "Extra info for the command. e.x AddCommand("ping", {"pong"}, {Args = 0})
            The above will make a command named "ping" with aliases "pong", and the required args are set to 0.
            - Code "CODE for the command to run. e.x AddCommand("ping", {"pong"}, {Args = 0}, function(Args)
                Notify("Pong!");
            end)
            The above will make a command named "ping" with aliases "pong", and the required args are set to 0.
            When the command is ran, the local player gets a notification saying "Pong!".

        Notify(Text, Color)
            - Text "Text of the notification. e.x Notify("I like bananas!");
            The above will notify "I like bananas!"
            - Color "Color of the notification. e.x Notify("I like bananas!", Color3.new(1,1,0))
            The above will notify "I like bananas!" in yellow.
        
        WriteGenv(Name, Value)
            - Name "The name of the data to set. e.x SetGenv("MadeBy",nil)
            - Value "The value of the data. e.x SetGenv("MadeBy","Ix1x0x2")
        ReadGenv(Name)
            - Name "The name of the value. e.x Notify( ReadGenv("MadeBy") );
            The above will notify the value of "MadeBy" in the genv.

        WriteFile(Name, Data)
            - Name "The filename to write to. e.x WriteFile("deez_nuts.json", {DeezNutz=true})
            The above will write to file "deez_nuts.json" and make it's data { DeezNuts: true };
            - Data "The data to write. e.x WriteFile("deez_nuts.json", {DeezNutz=true})
            The above will write to file "deez_nuts.json" and make it's data { DeezNuts: true };
        
        ReadFile(Name)
            - Name "The filename to read. e.x ReadFile("my_pass.txt")
            The above will return nil, cuz i aint showing you my password!

    More will be added. Happy coding!
]]

Eurus.Notify("EurusLib has loaded!", Color3.new(0, 1, 0.215686))

--[[
AddCommand("poopoo", {
    "peepee"
}, {
    Description = "check"
}, function(Args)
    Notify("poots poots cahts cahts cahts poots cahts *sniff* ahh");
end)
]]

-- Don't edit below if you want the commands: unload, cmds, setprefix
Eurus:AddCommand("unload", {
    "quit",
    "stopadmin",
    "exit"
}, {
    Description = "Unload the admin."
}, function()
    Notify("Unloaded admin, goodbye!")
    for i,Loop in pairs(Loops) do
        Loop:Disconnect()
        Loop = nil;
    end
end)

Eurus:AddCommand("help", {
    "cmds",
    "commands",
    "cmd",
    "command"
}, {
    Description = "Help command, default from EurusLib."
}, function(Args)
    local List = "";
    local temp = 1;
    for i,Command in pairs(Commands) do
        if Command.Info.Description ~= nil then
            Notify(ScriptData.Prefix..i.." --"..Command.Info.Description,Color3.new(math.random(0,1),1,1),false)
        else
            Notify(ScriptData.Prefix..i.." --No description provided.",Color3.new(math.random(0,1),1,1),false)
        end
    end
end)

Eurus:AddCommand("prefix", {
    "setprefix",
    "setp",
    "sprefix"
}, {
    Description = "Sets the command prefix. Default from EurusLib.";
    Args = 1;
}, function(Args)
    ScriptData.Prefix = Args[1]
    Notify("Set prefix to \""..Args[1].."\".", Color3.new(0,1,1), "Info")
end)
-- End of default commands.

return Eurus;
