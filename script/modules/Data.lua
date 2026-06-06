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
        {Min = 10, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 1, Enemy = "Monkey", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 15, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 2, Enemy = "Gorilla", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 20, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 3, Enemy = "Gorilla King", Pos = CFrame.new(-1598, 37, 153)},
        {Min = 30, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 1, Enemy = "Pirate", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 40, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 2, Enemy = "Brute", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 55, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 3, Enemy = "Bobby", Pos = CFrame.new(-1140, 4, 3827)},
        {Min = 60, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 1, Enemy = "Desert Bandit", Pos = CFrame.new(894, 6, 4388)},
        {Min = 75, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 2, Enemy = "Desert Officer", Pos = CFrame.new(894, 6, 4388)},
        {Min = 90, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 1, Enemy = "Snow Bandit", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 100, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 2, Enemy = "Snowman", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 105, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 3, Enemy = "Yeti", Pos = CFrame.new(1389, 105, -1298)},
        {Min = 120, Name = "MarineQuest2", NPC = "Marine Quest Giver", ID = 1, Enemy = "Chief Petty Officer", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 130, Name = "MarineQuest2", NPC = "Marine Quest Giver", ID = 2, Enemy = "Vice Admiral", Pos = CFrame.new(-2440, 19, 3065)},
        {Min = 150, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 1, Enemy = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 175, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 2, Enemy = "Dark Steward", Pos = CFrame.new(-4842, 718, -2621)},
        {Min = 190, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 1, Enemy = "Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 210, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 2, Enemy = "Dangerous Prisoner", Pos = CFrame.new(4875, 5, 749)},
        {Min = 225, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 1, Enemy = "Toga Warrior", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 250, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 2, Enemy = "Gladiator", Pos = CFrame.new(-1580, 7, -2980)},
        {Min = 300, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 1, Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 330, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 2, Enemy = "Military Spy", Pos = CFrame.new(-5313, 12, 8515)},
        {Min = 350, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 3, Enemy = "Magma Admiral", Pos = CFrame.new(-5313, 12, 8515)}
    },
    [2] = {
        {Min = 700, Name = "Area1Quest", NPC = "Quest Giver", ID = 1, Enemy = "Raider", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 725, Name = "Area1Quest", NPC = "Quest Giver", ID = 2, Enemy = "Mercenary", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 750, Name = "Area2Quest", NPC = "Quest Giver", ID = 1, Enemy = "Swan Pirate", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 775, Name = "Area2Quest", NPC = "Quest Giver", ID = 2, Enemy = "Factory Worker", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 800, Name = "FajitaQuest", NPC = "Quest Giver", ID = 1, Enemy = "Marine Lieutenant", Pos = CFrame.new(-425, 72, 1836)},
        {Min = 875, Name = "ZombieQuest", NPC = "Quest Giver", ID = 1, Enemy = "Zombie", Pos = CFrame.new(-5497, 47, -795)},
        {Min = 900, Name = "ZombieQuest", NPC = "Quest Giver", ID = 2, Enemy = "Vampire", Pos = CFrame.new(-5497, 47, -795)},
        {Min = 925, Name = "SnowMountainQuest", NPC = "Quest Giver", ID = 1, Enemy = "Snow Trooper", Pos = CFrame.new(609, 401, -5372)},
        {Min = 950, Name = "SnowMountainQuest", NPC = "Quest Giver", ID = 2, Enemy = "Winter Warrior", Pos = CFrame.new(609, 401, -5372)},
        {Min = 1000, Name = "IceCastleQuest", NPC = "Quest Giver", ID = 1, Enemy = "Reborn Skeleton", Pos = CFrame.new(6061, 26, -6370)},
        {Min = 1050, Name = "IceCastleQuest", NPC = "Quest Giver", ID = 2, Enemy = "Awakened Ice Admiral", Pos = CFrame.new(6061, 26, -6370)},
        {Min = 1100, Name = "FireSideQuest", NPC = "Quest Giver", ID = 1, Enemy = "Magma Ninja", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 1125, Name = "FireSideQuest", NPC = "Quest Giver", ID = 2, Enemy = "Lava Pirate", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 1150, Name = "ColdSideQuest", NPC = "Quest Giver", ID = 1, Enemy = "Lab Subordinate", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 1175, Name = "ColdSideQuest", NPC = "Quest Giver", ID = 2, Enemy = "Horned Warrior", Pos = CFrame.new(-541, 70, -12133)},
        {Min = 1250, Name = "ShipQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Ship Deckhand", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1275, Name = "ShipQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Ship Engineer", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1300, Name = "ShipQuest2", NPC = "Quest Giver", ID = 1, Enemy = "Ship Steward", Pos = CFrame.new(1037, 125, 32911)},
        {Min = 1325, Name = "ShipQuest2", NPC = "Quest Giver", ID = 2, Enemy = "Ship Officer", Pos = CFrame.new(1037, 125, 32911)}
    },
    [3] = {
        {Min = 1500, Name = "PortTownQuest", NPC = "Quest Giver", ID = 1, Enemy = "Pirate Millionaire", Pos = CFrame.new(-8053, 10, 5233)},
        {Min = 1525, Name = "PortTownQuest", NPC = "Quest Giver", ID = 2, Enemy = "Pistol Billionaire", Pos = CFrame.new(-8053, 10, 5233)},
        {Min = 1575, Name = "HydraIslandQuest", NPC = "Quest Giver", ID = 1, Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1600, Name = "HydraIslandQuest", NPC = "Quest Giver", ID = 2, Enemy = "Dragon Crew Archer", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1625, Name = "HydraIslandQuest", NPC = "Quest Giver", ID = 3, Enemy = "Female Island Pirate", Pos = CFrame.new(5259, 604, 346)},
        {Min = 1700, Name = "TurtleQuest", NPC = "Quest Giver", ID = 1, Enemy = "Fishman Raider", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1725, Name = "TurtleQuest", NPC = "Quest Giver", ID = 2, Enemy = "Fishman Captain", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1775, Name = "TurtleQuest", NPC = "Quest Giver", ID = 3, Enemy = "Forest Pirate", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1800, Name = "TurtleQuest", NPC = "Quest Giver", ID = 4, Enemy = "Mythical Pirate", Pos = CFrame.new(-13233, 532, -7594)},
        {Min = 1900, Name = "HauntedCastleQuest", NPC = "Quest Giver", ID = 1, Enemy = "Reborn Skeleton", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 1925, Name = "HauntedCastleQuest", NPC = "Quest Giver", ID = 2, Enemy = "Living Zombie", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 1975, Name = "HauntedCastleQuest", NPC = "Quest Giver", ID = 3, Enemy = "Demonic Soul", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 2000, Name = "HauntedCastleQuest", NPC = "Quest Giver", ID = 4, Enemy = "Posessed Mummy", Pos = CFrame.new(-9515, 164, -5785)},
        {Min = 2100, Name = "IceCreamQuest", NPC = "Quest Giver", ID = 1, Enemy = "Cookie Crafter", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2125, Name = "IceCreamQuest", NPC = "Quest Giver", ID = 2, Enemy = "Cake Guard", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2200, Name = "CakeQuest", NPC = "Quest Giver", ID = 1, Enemy = "Baking Staff", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2275, Name = "ChocolateQuest", NPC = "Quest Giver", ID = 1, Enemy = "Cocoa Warrior", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2300, Name = "ChocolateQuest", NPC = "Quest Giver", ID = 2, Enemy = "Chocolate Bar Battler", Pos = CFrame.new(-1147, 14, -11514)},
        {Min = 2450, Name = "TikiQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Sun-kissed Warrior", Pos = CFrame.new(-16234, 12, 467)},
        {Min = 2500, Name = "TikiQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Isle Outlaw", Pos = CFrame.new(-16234, 12, 467)}
    }
}

DataModule.MaterialData = {
    ["Dragon Scale"] = {Enemy = "Dragon Crew Warrior", Pos = CFrame.new(5259, 604, 346)},
    ["Fish Tail"] = {Enemy = "Fishman Warrior", Pos = CFrame.new(61122, 18, 1565)}
}

DataModule.Combos = {
    ["Dough"] = {{Key = "V", Wait = 0.5}, {Key = "C", Wait = 0.4}, {Key = "X", Wait = 0.5}, {Key = "Z", Wait = 0.3}},
    ["Kitsune"] = {{Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.6}, {Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.4}},
    ["Leopard"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Buddha"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.3}, {Key = "V", Wait = 0.4}},
    ["Dragon"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}, {Key = "Z", Wait = 0.3}},
    ["Venom"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Control"] = {{Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Spirit"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Shadow"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Portal"] = {{Key = "V", Wait = 0.5}, {Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}},
    ["Gravity"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Magma"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Rumble"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Light"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Ice"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Quake"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Dark"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Spider"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Love"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Sound"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Phoenix"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Blizzard"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Rocket"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Smoke"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Spin"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Spring"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Chop"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Diamond"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Rubber"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Barrier"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Ghost"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Soul"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Falcon"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Pain"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["T-Rex"] = {{Key = "Z", Wait = 0.3}, {Key = "X", Wait = 0.3}, {Key = "C", Wait = 0.4}, {Key = "V", Wait = 0.5}},
    ["Mammoth"] = {{Key = "X", Wait = 0.4}, {Key = "C", Wait = 0.4}, {Key = "Z", Wait = 0.3}, {Key = "V", Wait = 0.5}},
    ["Dough V2"] = {{Key = "V", Wait = 0.5}, {Key = "C", Wait = 0.4}, {Key = "X", Wait = 0.5}, {Key = "Z", Wait = 0.3}}
}

return DataModule
