local localPlayer = game.Players.LocalPlayer;
local HttpService = game:GetService("HttpService");

local Eurus = {};

Eurus.Commands = {};

Eurus.ScriptData = {
    FileName = "DATA_SCRIPT.json";
    Prefix = ",";
    ScriptName = "MyAdmin"
}

Eurus.Loops = {};

Eurus.RegisteredPlayers = {};

function Eurus:Notify(Text, Color, TagR)
    local Tag = Eurus.ScriptData.ScriptName;
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

function Eurus:WriteFile(FileName, Data)
	writefile(FileName, HttpService:JSONEncode(Data))
end

function Eurus:SetScriptData(Data)
    Eurus.ScriptData = Data;
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
        Eurus:Notify('An internal error has occured! Check console to see the error.',Color3.new(1,0,0))
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

function Eurus:RegisterPlayer(Player, Data)
    if not Player then return Eurus:Notify("An internal error has occured1 Check console to see the error.", Color3.new(1,0,0)) end;
    Eurus.RegisteredPlayers[Player.UserId] = Data;
end

function Eurus:Chat(Text, WhisperTo)
    if WhisperTo then
        return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..WhisperTo.Name.." "..Text, "All") -- sends your message to all players
    end
    return game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Text, "All") -- sends your message to all players
end

Eurus.Loops.ChatL = localPlayer.Chatted:Connect(function(Msg)
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
        Eurus:Notify("Invalid command!")
    end
end)

coroutine.wrap(function()
    while game:GetService("RunService").Heartbeat:Wait() do
        for i,Plr in pairs(game.Players:GetPlayers()) do
            if Eurus.RegisteredPlayers[Plr.UserId] ~= nil then
                if Eurus.Loops[Plr.UserId.."ChatL"] == nil then
                    Eurus.Loops[Plr.UserId.."ChatL"] = Plr.Chatted:Connect(function(Msg)
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
                                if Command.PermLevel then
                                    if Eurus.RegisteredPlayers[Plr.UserId].Rank >= Command.PermLevel then
                                        return Command.Run(Args)
                                    end
                                else
                                    return Command.Run(Args)
                                end
                            end
                    
                            for aNum,Alias in pairs(Command.Aliases) do
                                IsRan = CmdCheck(Alias)
                    
                                if IsRan and not Ran then
                                    Ran = true
                                    if Command.PermLevel then
                                        if Eurus.RegisteredPlayers[Plr.UserId].Rank >= Command.PermLevel then
                                            return Command.Run(Args)
                                        end
                                    else
                                        return Command.Run(Args)
                                    end
                                end
                            end
                        end
                    
                        if not Ran and string.sub(Msg,1,string.len(ScriptData.Prefix))==ScriptData.Prefix then
                            Eurus:Notify("Invalid command!")
                        end
                    end)
                end
            end
        end
    end
end)()

-- Don't edit below if you want the commands: unload, cmds, setprefix

Eurus:AddCommand("unload", {
    "quit",
    "stopadmin",
    "exit"
}, {
    Description = "Unload the admin."
}, function()
    Notify("Unloaded admin, goodbye!")
    for i,Loop in pairs(Eurus.Loops) do
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
