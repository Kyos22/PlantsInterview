--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
---->> Library


--// Constants & Enums

--// Types

export type Profile = {
	Version: number,
	
	Player: {
		UserId: number,
	},
	Balance: {
		Money: number,
	},
	Inventory: {
		Seeds : {
			[string]: {
				Quantity: number,
			},
		},
		Plants: {
			[string] : {
				Quantity: number,
			}
		}
	},
	Garden : {
		Slot: {
			[string]: {
				PlantType: string,
				Startime : number,
			}
		}
	}
}


--------------------------------------------------------------

local function cloneTable(t: { any }?): { any }?
	if not t then
		return nil
	end
	local newT = {}
	for key, value in pairs(t) do
		if typeof(value) == "table" then
			newT[key] = cloneTable(value)
		else
			newT[key] = value
		end
	end
	return newT
end

--constants
local DATASTORE_PREFIX = "DATA_TEST" --change this value will change all players database
local DATASTORE_VERSION = 28 --change this value will change all players database
local VERSION = 2

--------------------------------------------------------------

local Template: Profile = {
	Version = VERSION,
	Player = {
		
		UserId = 0,
		
	},
	Balance = {
		Money = 1000,
	},
	Inventory = {
		Seeds = {
			["Corn"] = {
				Quantity = 100,
			},
			["Tomato"] = {
				Quantity = 100,
			}
		},
		Plants = {
			["Corn"] = {
				Quantity = 50,
			},
		},
	},
	Garden = {
		Slot = {}
	},
}

local module = {}

module.Template = Template
module.VERSION = VERSION
module.DATASTORE_VERSION = DATASTORE_VERSION
module.DATASTORE_PREFIX = DATASTORE_PREFIX

return module
