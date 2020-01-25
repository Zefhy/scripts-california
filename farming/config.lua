Config = {}

Config.Locale = 'fr'

Config.MarkerType = 1
Config.MarkerColor = {r = 255, g = 119, b = 0}
Config.MarkerSize = vector3(0.75, 0.75, 2.0)
Config.DrawDistance = 50.0
Config.DrawTextDistance = 15.0

Config.TimeToFarm = 3 * 1000
--Config.TimeToProcess = 1 * 1000
Config.TimeToSell = 1 * 1000

Config.Zones = {
	FarmOrange = {
		Pos = {
			vector3(321.70, 6530.69, 29.17),
			vector3(330.51, 6530.95, 28.53),
			vector3(339.12, 6531.15, 28.57),
			vector3(353.95, 6529.98, 28.43),
			vector3(362.41, 6531.47, 28.35),
			vector3(369.90, 6531.77, 28.38),
			vector3(377.57, 6517.71, 28.38),
			vector3(369.25, 6517.36, 28.37),
			vector3(361.77, 6517.65, 28.26),
			vector3(354.33, 6517.44, 28.28),
			vector3(347.15, 6517.50, 28.83),
			vector3(337.85, 6517.03, 28.94),
			vector3(329.40, 6517.76, 28.97),
			vector3(321.13, 6517.52, 29.15),
			vector3(321.36, 6505.35, 29.25),
			vector3(330.00, 6505.56, 28.60),
			vector3(339.18, 6505.57, 28.65),
			vector3(347.26, 6505.30, 28.82),
			vector3(354.94, 6505.01, 28.50),
			vector3(362.49, 6505.84, 28.52),
			vector3(369.69, 6505.84, 28.47),
			vector3(377.23, 6506.02, 28.01)
		},
		blipPos = vector3(344.64, 6530.87, 28.69),
		showTheBlip = true,
		name = "Champ d'Oranges",
		size = 1.0,
		sprite = 514,
		color = 47,
		heading = 178.57,
		activePos = {},
		pnj = false,
		pnjmodel = nil
	},
	SellOrange = {
		blipPos = vector3(350.64, 6530.87, 28.69),
		showTheBlip = true,
		name = "Vente d'Oranges",
		size = 1.0,
		sprite = 515,
		color = 47,
		heading = 178.57,
		activePos = vector3(350.64, 6530.87, 28.69),
		pnj = true,
		pnjmodel = "a_m_m_farmer_01"
	}
}

Config.Zones.FarmOrange.activePos = Config.Zones.FarmOrange.Pos[math.random(1, #Config.Zones.FarmOrange.Pos)]