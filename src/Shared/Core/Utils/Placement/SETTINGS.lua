local SETTINGS = {
	DIRECTIONS = { { 0, 1 }, { -1, 0 }, { 0, -1 }, { 1, 0 } },
	BUILDING = true,
	FLOORS = true,

	MODEL = {
		TRANSPARENCY = 0,
		COLLISIONS = { -- Toggle allowed
			CHARACTER = false,
			MODELS = true,
		},
		HITBOX = {
			TRANSPARENCY = 0.5,
			COLORS = {
				DEFAULT = Color3.fromRGB(199, 255, 196),
				COLLIDED = Color3.fromRGB(254, 81, 81),
			},
		},
		SELECTION = {
			ENABLED = true,
			THICKNESS = 0.2,
			TRANSPARENCY = 0.5,
			COLORS = {
				DEFAULT = Color3.fromRGB(235, 255, 175),
				COLLIDED = Color3.fromRGB(254, 81, 81),
			},
		},
		HIGHLIGHT = {
			ENABLED = true,
			PLACEHOLDER = 0.1,
			COLORS = {
				DEFAULT = Color3.fromRGB(235, 255, 175),
				COLLIDED = Color3.fromRGB(254, 81, 81),
			},
		},
	},

	GRID = { -- Dictate grid behavior
		TEXTURE = "",
		ENABLED = true, -- Toggle grid snapping
		VISIBLE = true, -- Toggle grid display
		SIZE = 4,
		TRANSITION = true,
	},

	MOVEMENT = {
		SMART = true,
		FPS = 120,
		TITLT = {
			ENABLED = true,
			INVERTED = false,
			AMPLITUDE = 0.1,
		}, -- Tilting the model when moving
		LERP = 0.9, -- Speed of lerp (0 = no lerp | 1 = instant)
		ROTATION = 90,
		HEIGHT = 10,
		RANGE = 10,
		RAY = 10000,
	},

	PLACEMENT = {
		INSTANT = false, -- Toggle if the model instantly appear on placement
		AUDIO = {
			ENABLED = true,
			VOLUME = 0.1,
			SOUND = "",
		}, -- Sounds feedback on placement
	},

	HAPTIC = {
		ENABLED = true,
		VIBRATION = 1, -- 0 to 1
	},
}

table.freeze(SETTINGS)
return SETTINGS
