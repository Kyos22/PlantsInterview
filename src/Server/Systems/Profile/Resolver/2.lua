--!strict
--// Modules
local Template = require(script.Parent.Parent.Template)
--// Type
type Profile = Template.Profile

do -- note
	-- add stats data 
	do -- previous version
		-- version 1
		type Profile = {
			Version: number,
			Restaurant: {
				Layout: {
					Id: string,
					Grid: {
						[number]: { -- Floor
							[number]: { -- Column
								number -- Row
								--[[
									<no value> - Data not found
									1 - Locked,
									2 - Unlocked - vacant,
									3 - Occupied
								]]
							},
						},
					},
				},
				Placement: {
					Furnitures: { [string]: PlacementItem }, --[uniqueId] = placementData
				},

				WallPlacements: { WallObject: { [string]: WallPlacementItem } },

				Storage: { [string]: Storage },
			},
			Player: {
				Level: number,
				UserId: number,
				IsFirstTime: boolean,
				Exp: number,
				Wages: { --earnings when you are hired
					Money: number?,
					Gold: number?,
				},
				Stats: {
					Health: number,
					Speed: number,
				},
				Role_Exp: {
					Chef: number,
					Waiter: number,
					Janitor: number,
					Bartender: number,
					Musician: number,
				},
				LevelQuest: {
					[string]: {
						[string]: number,
					},
				},
				QuestsList: {
					[string]: {
						[string]: boolean,
					},
					-- EarnBalance: {
					-- 	[string]: number,
					-- },
				},
				LevelRequireMent: {
					[string]: boolean,
				},
				StoredExp: number,
			},
			Balance: {
				Money: number,
				Gold: number,
				FamousPoint: number,
			},
			Progression: {
				Exp: number,
				Rating: number,
				Popularity: number,
				FurnitureScore: number,
			},
			Model: {
				Outside: {
					Restaurant: {
						Owned: { [string]: boolean },
						Equipped: string,
					},
				},
				Inside: {
					Restaurant: {
						Floor: {
							Size: string,
							Texture: string,
						},
						Wall: {
							Texture: string,
						},
					},
				},
			},
			Achievements: {
				Completed: { [string]: boolean },
				InProgress: { [string]: Achievement },
			},
			Ingredients: {
				Storage: {
					[string]: {
						Quantity: number,
					},
				},
			},
			Dishes: {
				Storage: {
					[string]: { --dish id
						Level: number, --current level
					},
				},
				Equipped: {
					Starter: { string },
					Main: { string },
					Side: { string },
					Dessert: { string },
					Drink: { string },
				},
			},
			Staffs: {
				Storage: {
					[string]: { --user id for avatar
						Level: number, --current level,
						Role_Exp: {
							[string]: number,
						},
						Timestamp: {
							InactiveTime: number, -- time when the staff was start inactive
							ActiveTime: number, -- time when the staff was start active
							ActiveEndTime: number, -- time when the staff will get exhausted
							InactiveEndTime: number, -- time when the staff will be replenished
							MasteryEndTime: number, -- time when the staff was mastery end
							LastMasteryChange: number, -- time when the staff was last mastery change (this for calculating the masteryEndTime)
						},
						BaseStats: {
							Health: number, -- Health of the staff (How much HP the staff has before it's exhausted)
							Speed: number, -- Speed of the staff	(How fast can the staff work)
						},
						TempStats: {
							PreviousRole: Enums.StaffRole, -- previous role of the staff --> for changing the calculation of the mastery (reset when change different role)
							CurrentMastery: number, -- current mastery of the staff (This for saving the mastery progress)
							CurrentExhaustion: number, -- current exhaustion of the staff (This for calculating the inactiveEndTime)
						},
					},
				},
				Equipped: {
					[string]: {
						CurrentRole: string,
						Mastery: number,
						ExhaustionRate: number,
						Health: number,
						Speed: number,
					},
				},
			},
			Market: {
				Slot: {
					{
						Id: string,
						Quantity: number,
						Cost: {
							Currency: string,
							Price: number,
						},
					}
				},
				Timestamp: number,
			},
		}
	end
	do -- current version
		-- version 2
		type Profile = {
			Version: number,
			Restaurant: {
				Layout: {
					Id: string,
					Grid: {
						[number]: { -- Floor
							[number]: { -- Column
								number -- Row
								--[[
									<no value> - Data not found
									1 - Locked,
									2 - Unlocked - vacant,
									3 - Occupied
								]]
							},
						},
					},
				},
				Placement: {
					Furnitures: { [string]: PlacementItem }, --[uniqueId] = placementData
				},

				WallPlacements: { WallObject: { [string]: WallPlacementItem } },

				Storage: { [string]: Storage },
			},
			Player: {
				Level: number,
				UserId: number,
				IsFirstTime: boolean,
				Exp: number,
				Wages: { --earnings when you are hired
					Money: number?,
					Gold: number?,
				},
				Stats: {
					Health: number,
					Speed: number,
				},
				Role_Exp: {
					Chef: number,
					Waiter: number,
					Janitor: number,
					Bartender: number,
					Musician: number,
				},
				LevelQuest: {
					[string]: {
						[string]: number,
					},
				},
				QuestsList: {
					[string]: {
						[string]: boolean,
					},
					-- EarnBalance: {
					-- 	[string]: number,
					-- },
				},
				LevelRequireMent: {
					[string]: boolean,
				},
				StoredExp: number,
			},
			Balance: {
				Money: number,
				Gold: number,
				FamousPoint: number,
			},
			Progression: {
				Exp: number,
				Rating: number,
				Popularity: number,
				FurnitureScore: number,
			},
			Model: {
				Outside: {
					Restaurant: {
						Owned: { [string]: boolean },
						Equipped: string,
					},
				},
				Inside: {
					Restaurant: {
						Floor: {
							Size: string,
							Texture: string,
						},
						Wall: {
							Texture: string,
						},
					},
				},
			},
			Achievements: {
				Completed: { [string]: boolean },
				InProgress: { [string]: Achievement },
			},
			Ingredients: {
				Storage: {
					[string]: {
						Quantity: number,
					},
				},
			},
			Dishes: {
				Storage: {
					[string]: { --dish id
						Level: number, --current level
					},
				},
				Equipped: {
					Starter: { string },
					Main: { string },
					Side: { string },
					Dessert: { string },
					Drink: { string },
				},
			},
			Staffs: {
				Storage: {
					[string]: { --user id for avatar
						Level: number, --current level,
						Role_Exp: {
							[string]: number,
						},
						Timestamp: {
							InactiveTime: number, -- time when the staff was start inactive
							ActiveTime: number, -- time when the staff was start active
							ActiveEndTime: number, -- time when the staff will get exhausted
							InactiveEndTime: number, -- time when the staff will be replenished
							MasteryEndTime: number, -- time when the staff was mastery end
							LastMasteryChange: number, -- time when the staff was last mastery change (this for calculating the masteryEndTime)
						},
						BaseStats: {
							Health: number, -- Health of the staff (How much HP the staff has before it's exhausted)
							Speed: number, -- Speed of the staff	(How fast can the staff work)
						},
						TempStats: {
							PreviousRole: Enums.StaffRole, -- previous role of the staff --> for changing the calculation of the mastery (reset when change different role)
							CurrentMastery: number, -- current mastery of the staff (This for saving the mastery progress)
							CurrentExhaustion: number, -- current exhaustion of the staff (This for calculating the inactiveEndTime)
						},
					},
				},
				Equipped: {
					[string]: {
						CurrentRole: string,
						Mastery: number,
						ExhaustionRate: number,
						Health: number,
						Speed: number,
					},
				},
			},
			Market: {
				Slot: {
					{
						Id: string,
						Quantity: number,
						Cost: {
							Currency: string,
							Price: number,
						},
					}
				},
				Timestamp: number,
			},
			Stats: {
				DishesServed: number
			},
		}
	end
end

local module = {}

module.Resolve = function(data: Profile)
	data.Stats = {
		DishesServed = 0
	}
	data.Version = 2
end

return module
