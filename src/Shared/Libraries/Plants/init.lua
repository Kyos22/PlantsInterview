local Plants = {}

export type PlantData = {
    Name: string,
    GrowthDuration: number,
    Exp: number,
    Coins: number,
    ImageId: string,
}

local Data = {
    ["Wheat"] = {
        Name = "Wheat",
        GrowthDuration = 5,
        Exp = 1,
        Coins = 10,
        ImageId = ""
    },
    ["Corn"] = {
        Name = "Corn",
        GrowthDuration = 10,
        Exp = 1,
        Coins = 10,
        ImageId = "rbxassetid://111573557056660"
    },
    ["Tomato"] = {
        Name = "Tomato",
        GrowthDuration = 20,
        Exp = 1,
        Coins = 15,
        ImageId = "rbxassetid://104370715295665",
    },
   
} :: {PlantData}

Plants.Data = Data

return Plants