local DataModule = {}

DataModule.SeaData = {
    [1] = {
        {Name = "Starter Island (Pirate)", Pos = CFrame.new(1059, 15, 1550)},
        {Name = "Starter Island (Marine)", Pos = CFrame.new(-2566, 7, 2975)},
        {Name = "Jungle", Pos = CFrame.new(-1612, 37, 149)},
        {Name = "Pirate Village", Pos = CFrame.new(-1181, 4, 3850)},
        {Name = "Desert", Pos = CFrame.new(1094, 6, 4195)},
        {Name = "Middle Town", Pos = CFrame.new(-690, 15, 1583)},
        {Name = "Frozen Village", Pos = CFrame.new(1147, 6, -1157)},
        {Name = "Marinefort", Pos = CFrame.new(-2533, 6, 3110)},
        {Name = "Skylands", Pos = CFrame.new(-4842, 718, -2621)},
        {Name = "Prison", Pos = CFrame.new(4875, 5, 749)},
        {Name = "Magma Village", Pos = CFrame.new(-5313, 12, 8515)},
        {Name = "Underwater City", Pos = CFrame.new(61122, 18, 1565)}
    },
    [2] = {
        {Name = "Kingdom of Rose", Pos = CFrame.new(-425, 72, 1836)},
        {Name = "Ushi Island", Pos = CFrame.new(-2367, 72, -3054)},
        {Name = "Green Bit", Pos = CFrame.new(-2367, 72, -3054)},
        {Name = "Graveyard", Pos = CFrame.new(-5497, 47, -795)},
        {Name = "Snow Mountain", Pos = CFrame.new(609, 401, -5372)},
        {Name = "Hot and Cold", Pos = CFrame.new(-541, 70, -12133)},
        {Name = "Cursed Ship", Pos = CFrame.new(1037, 125, 32911)},
        {Name = "Ice Castle", Pos = CFrame.new(6061, 26, -6370)},
        {Name = "Forgotten Island", Pos = CFrame.new(-3056, 235, -10142)}
    },
    [3] = {
        {Name = "Port Town", Pos = CFrame.new(-8053, 10, 5233)},
        {Name = "Hydra Island", Pos = CFrame.new(5259, 604, 346)},
        {Name = "Floating Turtle", Pos = CFrame.new(-13233, 532, -7594)},
        {Name = "Castle on the Sea", Pos = CFrame.new(-5400, 15, 1000)},
        {Name = "Haunted Castle", Pos = CFrame.new(-9515, 164, -5785)},
        {Name = "Sea of Treats", Pos = CFrame.new(-1147, 14, -11514)},
        {Name = "Tiki Outpost", Pos = CFrame.new(-16234, 12, 467)},
        {Name = "Submerged Island", Pos = CFrame.new(-19500, -500, -18000)}
    }
}

DataModule.QuestData = {
    [1] = {
        {Min = 0, Name = "BanditQuest1", NPC = "Bandit Recruiter", ID = 1, Enemy = "Bandit", Pos = CFrame.new(1059, 15, 1550), Team = "Pirates"},
        {Min = 0, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 1, Enemy = "Trainee", Pos = CFrame.new(-2566, 7, 2975), Team = "Marines"},
        {Min = 15, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 1, Enemy = "Monkey", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 20, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 2, Enemy = "Gorilla", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 25, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 3, Enemy = "Gorilla King", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 30, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 1, Enemy = "Pirate", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 40, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 2, Enemy = "Brute", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 55, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 3, Enemy = "Bobby", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 60, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 1, Enemy = "Desert Bandit", Pos = CFrame.new(894, 6, 4388)},
        {Min = 75, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 2, Enemy = "Desert Officer", Pos = CFrame.new(894, 6, 4388)},
        {Min = 90, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 1, Enemy = "Snow Bandit", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 100, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 2, Enemy = "Snowman", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 105, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 3, Enemy = "Yeti", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 120, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 1, Enemy = "Chief Petty Officer", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 130, Name = "MarineQuest1", NPC = "Marine Quest Giver", ID = 2, Enemy = "Vice Admiral", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 150, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 1, Enemy = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 175, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 2, Enemy = "Dark Steward", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 190, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 1, Enemy = "Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 210, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 2, Enemy = "Dangerous Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 225, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 1, Enemy = "Toga Warrior", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 250, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 2, Enemy = "Gladiator", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 300, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 1, Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 330, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 2, Enemy = "Military Spy", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 350, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 3, Enemy = "Magma Admiral", Pos = CFrame.new(-5313, 12, 8515)}
    }
}

DataModule.MaterialData = {
    ["Dragon Scale"] = {Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
    ["Fish Tail"] = {Enemy = "Fishman Warrior", Pos = CFrame.new(61122, 18, 1565)}
}

DataModule.Combos = {
    ["Dough"] = {{Key = "V", Wait = 0.5}, {Key = "C", Wait = 0.4}, {Key = "X", Wait = 0.5}, {Key = "Z", Wait = 0.3}},
    ["Kitsune"] = {{Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.6}, {Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.4}}
    -- ... (Rest of combos)
}

return DataModule
