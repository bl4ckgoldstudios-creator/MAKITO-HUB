local DataModule = {}

-- FILTRO DE MAR PARA EVITAR CRASHES POR DADOS INEXISTENTES
local function GetSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 or placeId == 4442272121 then return 2
    elseif placeId == 7449423635 then return 3
    end
    return 1
end

local CurrentSea = _G.MakitoSea or GetSea()

DataModule.SeaData = {}
DataModule.QuestData = {}

local FullSeaData = {
    [1] = {
        {Name = "Starter Island (Pirate)", Pos = CFrame.new(1059, 15, 1550)},
        {Name = "Starter Island (Marine)", Pos = CFrame.new(-2566, 7, 2975)},
        {Name = "Jungle", Pos = CFrame.new(-1612, 37, 149)},
        {Name = "Pirate Village", Pos = CFrame.new(-1181, 4, 3850)},
        {Name = "Desert", Pos = CFrame.new(1094, 6, 4195)},
        {Name = "Middle Town", Pos = CFrame.new(-690, 15, 1583)},
        {Name = "Frozen Village", Pos = CFrame.new(1147, 6, -1157)},
        {Name = "Marinefort", Pos = CFrame.new(-5032, 23, 4323)},
        {Name = "Skylands", Pos = CFrame.new(-4842, 718, -2621)},
        {Name = "Prison", Pos = CFrame.new(4875, 5, 749)},
        {Name = "Magma Village", Pos = CFrame.new(-5313, 12, 8515)},
        {Name = "Underwater City", Pos = CFrame.new(61122, 18, 1565)},
        {Name = "Colosseum", Pos = CFrame.new(-1580, 7, -2980)},
        {Name = "Fountain City", Pos = CFrame.new(5259, 38, 4050)}
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
        {Name = "Forgotten Island", Pos = CFrame.new(-3056, 235, -10142)},
        {Name = "Cafe", Pos = CFrame.new(-382, 73, 291)},
        {Name = "Bartilo", Pos = CFrame.new(-2840, 10, 5318)},
        {Name = "Don Swan's Room", Pos = CFrame.new(2288, 15, 808)}
    },
    [3] = {
        {Name = "Port Town", Pos = CFrame.new(-8053, 10, 5233)},
        {Name = "Hydra Island", Pos = CFrame.new(5259, 604, 346)},
        {Name = "Floating Turtle", Pos = CFrame.new(-13233, 532, -7594)},
        {Name = "Castle on the Sea", Pos = CFrame.new(-5400, 15, 1000)},
        {Name = "Haunted Castle", Pos = CFrame.new(-9515, 164, -5785)},
        {Name = "Sea of Treats", Pos = CFrame.new(-1147, 14, -11514)},
        {Name = "Tiki Outpost", Pos = CFrame.new(-16234, 12, 467)},
        {Name = "Submerged Outpost", Pos = CFrame.new(-18500, -550, -18500)},
        {Name = "Dragon Palace", Pos = CFrame.new(-21000, -800, -21000)},
        {Name = "Submerged Island", Pos = CFrame.new(-19500, -500, -18000)},
        {Name = "Mansion", Pos = CFrame.new(-12463, 332, -7548)},
        {Name = "Peanut Land", Pos = CFrame.new(-20631, 50, -9050)},
        {Name = "Candy Island", Pos = CFrame.new(-1151, 14, -11514)},
        {Name = "Cake Land", Pos = CFrame.new(-1147, 14, -11514)},
        {Name = "Beautiful Pirate Domain", Pos = CFrame.new(5319, 23, -93)}
    }
}

local FullQuestData = {
    [1] = {
        {Min = 0, Name = "BanditQuest1", NPC = "Bandit Recruiter", ID = 1, Enemy = "Bandit", Pos = CFrame.new(1059, 15, 1550), Spawn = CFrame.new(1145, 17, 1634)},
        {Min = 10, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 1, Enemy = "Monkey", Pos = CFrame.new(-1598, 37, 153), Spawn = CFrame.new(-1612, 37, 149)},
        {Min = 15, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 2, Enemy = "Gorilla", Pos = CFrame.new(-1598, 37, 153), Spawn = CFrame.new(-1204, 51, -452)},
        {Min = 20, Name = "MonkeyQuest1", NPC = "Monkey Quest Giver", ID = 3, Enemy = "Gorilla King", Pos = CFrame.new(-1598, 37, 153), Spawn = CFrame.new(-1204, 51, -452)},
        {Min = 30, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 1, Enemy = "Pirate", Pos = CFrame.new(-1140, 4, 3827), Spawn = CFrame.new(-1222, 25, 3911)},
        {Min = 40, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 2, Enemy = "Brute", Pos = CFrame.new(-1140, 4, 3827), Spawn = CFrame.new(-1362, 15, 4310)},
        {Min = 55, Name = "PirateQuest1", NPC = "Pirate Quest Giver", ID = 3, Enemy = "Bobby", Pos = CFrame.new(-1140, 4, 3827), Spawn = CFrame.new(-1140, 15, 4150)},
        {Min = 60, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 1, Enemy = "Desert Bandit", Pos = CFrame.new(894, 6, 4388), Spawn = CFrame.new(995, 6, 4425)},
        {Min = 75, Name = "DesertBanditQuest1", NPC = "Desert Quest Giver", ID = 2, Enemy = "Desert Officer", Pos = CFrame.new(894, 6, 4388), Spawn = CFrame.new(1540, 15, 4440)},
        {Min = 90, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 1, Enemy = "Snow Bandit", Pos = CFrame.new(1389, 105, -1298), Spawn = CFrame.new(1280, 150, -1340)},
        {Min = 100, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 2, Enemy = "Snowman", Pos = CFrame.new(1389, 105, -1298), Spawn = CFrame.new(1280, 150, -1340)},
        {Min = 105, Name = "SnowBanditQuest1", NPC = "Snow Quest Giver", ID = 3, Enemy = "Yeti", Pos = CFrame.new(1389, 105, -1298), Spawn = CFrame.new(1280, 150, -1340)},
        {Min = 120, Name = "MarineQuest2", NPC = "Marine Quest Giver", ID = 1, Enemy = "Chief Petty Officer", Pos = CFrame.new(-5039, 27, 4324), Spawn = CFrame.new(-4810, 23, 4335)},
        {Min = 130, Name = "MarineQuest2", NPC = "Marine Quest Giver", ID = 2, Enemy = "Vice Admiral", Pos = CFrame.new(-5039, 27, 4324), Spawn = CFrame.new(-4807, 23, 4335)},
        {Min = 150, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 1, Enemy = "Sky Bandit", Pos = CFrame.new(-4842, 718, -2621), Spawn = CFrame.new(-4950, 750, -2850)},
        {Min = 175, Name = "SkyQuest", NPC = "Sky Quest Giver", ID = 2, Enemy = "Dark Steward", Pos = CFrame.new(-4842, 718, -2621), Spawn = CFrame.new(-4950, 750, -2850)},
        {Min = 190, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 1, Enemy = "Prisoner", Pos = CFrame.new(4875, 5, 749), Spawn = CFrame.new(5400, 15, 650)},
        {Min = 210, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 2, Enemy = "Dangerous Prisoner", Pos = CFrame.new(4875, 5, 749), Spawn = CFrame.new(5400, 15, 650)},
        {Min = 225, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 3, Enemy = "Warden", Pos = CFrame.new(4875, 5, 749), Spawn = CFrame.new(5400, 15, 650)},
        {Min = 230, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 4, Enemy = "Chief Warden", Pos = CFrame.new(4875, 5, 749), Spawn = CFrame.new(5400, 15, 650)},
        {Min = 240, Name = "PrisonQuest1", NPC = "Prison Quest Giver", ID = 5, Enemy = "Swan", Pos = CFrame.new(4875, 5, 749), Spawn = CFrame.new(5400, 15, 650)},
        {Min = 250, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 1, Enemy = "Toga Warrior", Pos = CFrame.new(-1580, 7, -2980), Spawn = CFrame.new(-1800, 50, -2700)},
        {Min = 275, Name = "ColosseumQuest1", NPC = "Colosseum Quest Giver", ID = 2, Enemy = "Gladiator", Pos = CFrame.new(-1580, 7, -2980), Spawn = CFrame.new(-1800, 50, -2700)},
        {Min = 300, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 1, Enemy = "Military Soldier", Pos = CFrame.new(-5313, 12, 8515), Spawn = CFrame.new(-5400, 50, 8600)},
        {Min = 330, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 2, Enemy = "Military Spy", Pos = CFrame.new(-5313, 12, 8515), Spawn = CFrame.new(-5400, 50, 8600)},
        {Min = 350, Name = "MagmaQuest", NPC = "Magma Quest Giver", ID = 3, Enemy = "Magma Admiral", Pos = CFrame.new(-5313, 12, 8515), Spawn = CFrame.new(-5400, 50, 8600)},
        {Min = 375, Name = "FishmanQuest", NPC = "Underwater Quest Giver", ID = 1, Enemy = "Fishman Warrior", Pos = CFrame.new(61122, 18, 1565), Spawn = CFrame.new(61000, 15, 1500)},
        {Min = 400, Name = "FishmanQuest", NPC = "Underwater Quest Giver", ID = 2, Enemy = "Fishman Commando", Pos = CFrame.new(61122, 18, 1565), Spawn = CFrame.new(61000, 15, 1500)},
        {Min = 425, Name = "FishmanQuest", NPC = "Underwater Quest Giver", ID = 3, Enemy = "Fishman Lord", Pos = CFrame.new(61122, 18, 1565), Spawn = CFrame.new(61000, 15, 1500)},
        {Min = 450, Name = "SkyQuest2", NPC = "Sky Quest Giver", ID = 1, Enemy = "God's Guard", Pos = CFrame.new(-4721, 845, -1954), Spawn = CFrame.new(-4600, 850, -1900)},
        {Min = 475, Name = "SkyQuest2", NPC = "Sky Quest Giver", ID = 2, Enemy = "Shaman", Pos = CFrame.new(-4721, 845, -1954), Spawn = CFrame.new(-4600, 850, -1900)},
        {Min = 525, Name = "SkyQuest3", NPC = "Sky Quest Giver", ID = 1, Enemy = "Royal Squad", Pos = CFrame.new(-7906, 5545, -383), Spawn = CFrame.new(-7800, 5550, -400)},
        {Min = 550, Name = "SkyQuest3", NPC = "Sky Quest Giver", ID = 2, Enemy = "Royal Soldier", Pos = CFrame.new(-7906, 5545, -383), Spawn = CFrame.new(-7800, 5550, -400)},
        {Min = 575, Name = "SkyQuest3", NPC = "Sky Quest Giver", ID = 3, Enemy = "Wysper", Pos = CFrame.new(-7906, 5545, -383), Spawn = CFrame.new(-7800, 5550, -400)},
        {Min = 625, Name = "FountainQuest", NPC = "Fountain Quest Giver", ID = 1, Enemy = "Galley Pirate", Pos = CFrame.new(5259, 38, 4050), Spawn = CFrame.new(5500, 50, 4100)},
        {Min = 650, Name = "FountainQuest", NPC = "Fountain Quest Giver", ID = 2, Enemy = "Galley Captain", Pos = CFrame.new(5259, 38, 4050), Spawn = CFrame.new(5500, 50, 4100)},
        {Min = 700, Name = "FountainQuest", NPC = "Fountain Quest Giver", ID = 3, Enemy = "Cyborg", Pos = CFrame.new(5259, 38, 4050), Spawn = CFrame.new(5500, 50, 4100)}
    },
    [2] = {
        {Min = 700, Name = "Area1Quest", NPC = "Quest Giver", ID = 1, Enemy = "Raider", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-500, 72, 1900)},
        {Min = 725, Name = "Area1Quest", NPC = "Quest Giver", ID = 2, Enemy = "Mercenary", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-500, 72, 1900)},
        {Min = 750, Name = "Area2Quest", NPC = "Quest Giver", ID = 1, Enemy = "Swan Pirate", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-650, 72, 2100)},
        {Min = 775, Name = "Area2Quest", NPC = "Quest Giver", ID = 2, Enemy = "Factory Staff", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(400, 72, 2500)},
        {Min = 800, Name = "MarineQuest3", NPC = "Quest Giver", ID = 1, Enemy = "Marine Lieutenant", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-2440, 19, 3065)},
        {Min = 875, Name = "ZombieQuest", NPC = "Quest Giver", ID = 1, Enemy = "Zombie", Pos = CFrame.new(-5497, 47, -795), Spawn = CFrame.new(-5600, 47, -900)},
        {Min = 900, Name = "ZombieQuest", NPC = "Quest Giver", ID = 2, Enemy = "Vampire", Pos = CFrame.new(-5497, 47, -795), Spawn = CFrame.new(-5600, 47, -900)},
        {Min = 925, Name = "SnowMountainQuest", NPC = "Quest Giver", ID = 1, Enemy = "Snow Trooper", Pos = CFrame.new(609, 401, -5372), Spawn = CFrame.new(700, 401, -5500)},
        {Min = 950, Name = "SnowMountainQuest", NPC = "Quest Giver", ID = 2, Enemy = "Winter Warrior", Pos = CFrame.new(609, 401, -5372), Spawn = CFrame.new(700, 401, -5500)},
        {Min = 1000, Name = "IceCastleQuest", NPC = "Quest Giver", ID = 1, Enemy = "Reborn Skeleton", Pos = CFrame.new(6061, 26, -6370), Spawn = CFrame.new(6200, 26, -6500)},
        {Min = 1050, Name = "IceCastleQuest", NPC = "Quest Giver", ID = 2, Enemy = "Rengoku", Pos = CFrame.new(6061, 26, -6370), Spawn = CFrame.new(6200, 26, -6500)},
        {Min = 1100, Name = "FireSideQuest", NPC = "Quest Giver", ID = 1, Enemy = "Magma Ninja", Pos = CFrame.new(-541, 70, -12133), Spawn = CFrame.new(-600, 70, -12200)},
        {Min = 1125, Name = "FireSideQuest", NPC = "Quest Giver", ID = 2, Enemy = "Lava Pirate", Pos = CFrame.new(-541, 70, -12133), Spawn = CFrame.new(-600, 70, -12200)},
        {Min = 1150, Name = "ColdSideQuest", NPC = "Quest Giver", ID = 1, Enemy = "Lab Subordinate", Pos = CFrame.new(-541, 70, -12133), Spawn = CFrame.new(-400, 70, -12000)},
        {Min = 1175, Name = "ColdSideQuest", NPC = "Quest Giver", ID = 2, Enemy = "Horned Warrior", Pos = CFrame.new(-541, 70, -12133), Spawn = CFrame.new(-400, 70, -12000)},
        {Min = 1200, Name = "Area2Quest", NPC = "Quest Giver", ID = 3, Enemy = "Military Spy", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-650, 72, 2100)},
        {Min = 1250, Name = "ShipQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Ship Deckhand", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1275, Name = "ShipQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Ship Engineer", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1300, Name = "ShipQuest2", NPC = "Quest Giver", ID = 1, Enemy = "Ship Steward", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1325, Name = "ShipQuest2", NPC = "Quest Giver", ID = 2, Enemy = "Ship Officer", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1350, Name = "ShipQuest2", NPC = "Quest Giver", ID = 3, Enemy = "Ship Captain", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1375, Name = "ShipQuest3", NPC = "Quest Giver", ID = 1, Enemy = "Core", Pos = CFrame.new(1037, 125, 32911), Spawn = CFrame.new(1100, 125, 32950)},
        {Min = 1425, Name = "OrderQuest", NPC = "Quest Giver", ID = 1, Enemy = "Dangerous Agent", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-500, 72, 1900)},
        {Min = 1450, Name = "OrderQuest", NPC = "Quest Giver", ID = 2, Enemy = "Vice Admiral", Pos = CFrame.new(-425, 72, 1836), Spawn = CFrame.new(-2440, 19, 3065)}
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
        {Min = 2325, Name = "CandyQuest", NPC = "Quest Giver", ID = 1, Enemy = "Candy Rebel", Pos = CFrame.new(-1151, 14, -11514), Spawn = CFrame.new(-1100, 14, -11600)},
        {Min = 2350, Name = "CandyQuest", NPC = "Quest Giver", ID = 2, Enemy = "Sweet Thief", Pos = CFrame.new(-1151, 14, -11514), Spawn = CFrame.new(-1100, 14, -11600)},
        {Min = 2400, Name = "PeanutQuest", NPC = "Quest Giver", ID = 1, Enemy = "Peanut Scout", Pos = CFrame.new(-20631, 50, -9050), Spawn = CFrame.new(-20700, 50, -9100)},
        {Min = 2425, Name = "PeanutQuest", NPC = "Quest Giver", ID = 2, Enemy = "Peanut President", Pos = CFrame.new(-20631, 50, -9050), Spawn = CFrame.new(-20700, 50, -9100)},
        {Min = 2450, Name = "TikiQuest1", NPC = "Quest Giver", ID = 1, Enemy = "Sun-kissed Warrior", Pos = CFrame.new(-16234, 12, 467), Spawn = CFrame.new(-16300, 12, 500)},
        {Min = 2500, Name = "TikiQuest1", NPC = "Quest Giver", ID = 2, Enemy = "Isle Outlaw", Pos = CFrame.new(-16234, 12, 467), Spawn = CFrame.new(-16300, 12, 500)},
        {Min = 2550, Name = "TikiQuest2", NPC = "Quest Giver", ID = 1, Enemy = "Isle Champion", Pos = CFrame.new(-16234, 12, 467), Spawn = CFrame.new(-16300, 12, 500)},
        {Min = 2575, Name = "TikiQuest2", NPC = "Quest Giver", ID = 2, Enemy = "Serpent Hunter", Pos = CFrame.new(-16234, 12, 467), Spawn = CFrame.new(-16300, 12, 500)},
        {Min = 2600, Name = "SubmergedQuest1", NPC = "Submerged Quest Giver", ID = 1, Enemy = "Ancient Guardian", Pos = CFrame.new(-18500, -540, -18500), Spawn = CFrame.new(-18600, -540, -18600)},
        {Min = 2650, Name = "SubmergedQuest1", NPC = "Submerged Quest Giver", ID = 2, Enemy = "Abyssal Warrior", Pos = CFrame.new(-18500, -540, -18500), Spawn = CFrame.new(-18700, -540, -18700)},
        {Min = 2725, Name = "DragonPalaceQuest", NPC = "Palace Quest Giver", ID = 1, Enemy = "Tiki Overlord", Pos = CFrame.new(-21000, -790, -21000), Spawn = CFrame.new(-21100, -790, -21100)}
    }
}

-- Mantem o banco completo disponivel para consultas seguras da UI e dos modulos.
DataModule.SeaData = FullSeaData
DataModule.QuestData = FullQuestData
DataModule.CurrentSea = CurrentSea

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

function DataModule.GetSea()
    return _G.MakitoSea or GetSea()
end

function DataModule.GetIslands(sea)
    sea = sea or DataModule.GetSea()
    return DataModule.SeaData[sea] or {}
end

function DataModule.GetQuests(sea)
    sea = sea or DataModule.GetSea()
    return DataModule.QuestData[sea] or {}
end

function DataModule.GetIslandByName(name, sea)
    if not name or name == "" or name == "None" then return nil end

    for _, island in ipairs(DataModule.GetIslands(sea)) do
        if island.Name == name then
            return island
        end
    end

    return nil
end

function DataModule.GetBestQuest(level, sea)
    level = tonumber(level) or 0
    local bestQuest = nil

    for _, quest in ipairs(DataModule.GetQuests(sea)) do
        if level >= (quest.Min or 0) then
            bestQuest = quest
        end
    end

    return bestQuest
end

function DataModule.GetQuestEnemies(sea)
    local enemies = {}
    local seen = {}

    for _, quest in ipairs(DataModule.GetQuests(sea)) do
        if quest.Enemy and not seen[quest.Enemy] then
            seen[quest.Enemy] = true
            table.insert(enemies, quest.Enemy)
        end
    end

    table.sort(enemies)
    return enemies
end

function DataModule.Validate()
    local issues = {}

    for sea, islands in pairs(DataModule.SeaData) do
        if type(islands) ~= "table" or #islands == 0 then
            table.insert(issues, "SeaData[" .. tostring(sea) .. "] sem ilhas")
        else
            for index, island in ipairs(islands) do
                if not island.Name or island.Name == "" then
                    table.insert(issues, "SeaData[" .. tostring(sea) .. "][" .. index .. "] sem Name")
                end
                if not island.Pos then
                    table.insert(issues, "SeaData[" .. tostring(sea) .. "][" .. index .. "] sem Pos")
                end
            end
        end
    end

    for sea, quests in pairs(DataModule.QuestData) do
        if type(quests) ~= "table" or #quests == 0 then
            table.insert(issues, "QuestData[" .. tostring(sea) .. "] sem quests")
        else
            local lastLevel = -1
            for index, quest in ipairs(quests) do
                if type(quest.Min) ~= "number" then
                    table.insert(issues, "QuestData[" .. tostring(sea) .. "][" .. index .. "] sem Min numerico")
                elseif quest.Min < lastLevel then
                    table.insert(issues, "QuestData[" .. tostring(sea) .. "][" .. index .. "] fora de ordem por level")
                else
                    lastLevel = quest.Min
                end

                if not quest.Name or quest.Name == "" then
                    table.insert(issues, "QuestData[" .. tostring(sea) .. "][" .. index .. "] sem Name")
                end
                if not quest.Enemy or quest.Enemy == "" then
                    table.insert(issues, "QuestData[" .. tostring(sea) .. "][" .. index .. "] sem Enemy")
                end
                if not quest.Pos then
                    table.insert(issues, "QuestData[" .. tostring(sea) .. "][" .. index .. "] sem Pos")
                end
                if not quest.Spawn then
                    quest.Spawn = quest.Pos
                end
            end
        end
    end

    return issues
end

DataModule.ValidationIssues = DataModule.Validate()

return DataModule
