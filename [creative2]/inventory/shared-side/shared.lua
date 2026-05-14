-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
DistanceDrops = 5
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPRAYS
-----------------------------------------------------------------------------------------------------------------------------------------
Sprays = {
	spray_ballas = { "Ballas",50 },
	spray_vagos = { "Vagos",60 },
	spray_families = { "Families",69 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFTING
-----------------------------------------------------------------------------------------------------------------------------------------
Crafting = {
	bandage = {
		Amount = 1,
		Required = {
			gauze = 5
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MISSIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Missions = {
	{
		Xp = 100,
		Code = "MISSION01",
		Title = "Titulo da missão",
		Description = "Descrição da missão",
		Required = {
			blue_essence = 10
		},
		Rewards = {
			purple_essence = 10
		}
	},{
		Xp = 1000,
		Code = "MISSION02",
		Title = "Titulo da missão 2",
		Description = "Descrição da missão 2",
		Required = {
			purple_essence = 10
		},
		Rewards = {
			green_essence = 10
		}
	},{
		Xp = 10000,
		Code = "MISSION03",
		Title = "Titulo da missão 3",
		Description = "Descrição da missão 3",
		Required = {
			green_essence = 10
		},
		Rewards = {
			red_essence = 10
		}
	},{
		Xp = 50000,
		Code = "MISSION04",
		Title = "Titulo da missão 4",
		Description = "Descrição da missão 4",
		Required = {
			red_essence = 10
		},
		Rewards = {
			pink_essence = 10
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
Robbery = {
	{ Coords = vec3(253.01,-51.68,70.11), Mode = "Ammunation" },
	{ Coords = vec3(841.06,-1034.89,28.38), Mode = "Ammunation" },
	{ Coords = vec3(-330.38,6085.65,31.64), Mode = "Ammunation" },
	{ Coords = vec3(-660.93,-933.95,22.01), Mode = "Ammunation" },
	{ Coords = vec3(-1304.82,-395.86,36.88), Mode = "Ammunation" },
	{ Coords = vec3(-1117.72,2700.39,18.73), Mode = "Ammunation" },
	{ Coords = vec3(2566.59,292.98,108.92), Mode = "Ammunation" },
	{ Coords = vec3(2566.58,292.97,108.91), Mode = "Ammunation" },
	{ Coords = vec3(23.74,-1106.30,29.98), Mode = "Ammunation" },
	{ Coords = vec3(808.86,-2158.67,29.80), Mode = "Ammunation" },
	{ Coords = vec3(1693.45,3761.71,34.89), Mode = "Ammunation" },

	{ Coords = vec3(29.51,-1340.26,29.34), Mode = "Department" },
	{ Coords = vec3(2550.36,386.13,108.46), Mode = "Department" },
	{ Coords = vec3(1159.20,-315.37,69.04), Mode = "Department" },
	{ Coords = vec3(-710.25,-905.45,19.05), Mode = "Department" },
	{ Coords = vec3(-44.65,-1749.00,29.25), Mode = "Department" },
	{ Coords = vec3(379.19,332.03,103.41), Mode = "Department" },
	{ Coords = vec3(-3248.87,1005.61,12.67), Mode = "Department" },
	{ Coords = vec3(1735.52,6419.29,34.88), Mode = "Department" },
	{ Coords = vec3(544.97,2663.67,42.00), Mode = "Department" },
	{ Coords = vec3(1960.93,3748.64,32.18), Mode = "Department" },
	{ Coords = vec3(2674.34,3287.25,55.08), Mode = "Department" },
	{ Coords = vec3(1707.12,4921.63,41.90), Mode = "Department" },
	{ Coords = vec3(-1828.72,797.44,138.03), Mode = "Department" },
	{ Coords = vec3(-3047.24,587.20,7.75), Mode = "Department" },

	--
	{ Coords = vec3(1982.15,3053.59,47.49), Mode = "YellowJack" },
	{ Coords = vec3(2863.18,1509.22,25.07), Mode = "Mergulhador" },
	{ Coords = vec3(95.38,287.04,110.71), Mode = "MequiDunada" },
	{ Coords = vec3(-431.16,288.96,86.57), Mode = "Comedy" },
	{ Coords = vec3(-684.15,-1167.05,15.15), Mode = "Planet" },
	{ Coords = vec3(815.70,542.32,126.41), Mode = "Observatorio" },
	{ Coords = vec3(185.49,1214.06,226.08), Mode = "Auditorio" },
	{ Coords = vec3(1249.81,317.62,86.47), Mode = "Estabulo" },
	{ Coords = vec3(2475.76,-384.19,94.86), Mode = "Prefeitura" },
	{ Coords = vec3(-552.59,5348.53,75.26), Mode = "Madeireira" },


	{ Coords = vec3(-631.05,-230.62,38.01), Mode = "Joalheria" },
	{ Coords = vec3(-353.57,-55.52,49.14), Mode = "BancoFleeca" },
	{ Coords = vec3(311.49,-284.67,54.25), Mode = "BancoFleeca" },
	{ Coords = vec3(-1210.44,-336.52,37.86), Mode = "BancoFleeca" },
	{ Coords = vec3(-2956.42,482.03,15.79), Mode = "BancoFleeca" },

	{ Coords = vec3(-103.18,6478.57,31.68), Mode = "BancoPaleto" },
	{ Coords = vec3(990.00,-2149.98,30.40), Mode = "Acougue" },
	{ Coords = vec3(-78.51,6224.84,31.12), Mode = "Galinheiro" },

	{ Coords = vec3(252.96,228.59,101.98), Mode = "BancoCentral" },
	{ Coords = vec3(3536.08,3658.80,28.15), Mode = "Niobio" },
	{ Coords = vec3(3093.07,-4724.62,26.99), Mode = "PortaAviao" },

	{ Coords = vec3(25.30,-1347.85,29.70), Mode = "Register" },
	{ Coords = vec3(25.27,-1345.71,29.69), Mode = "Register" },
	{ Coords = vec3(2555.66,381.68,108.84), Mode = "Register" },
	{ Coords = vec3(2557.79,381.62,108.86), Mode = "Register" },
	{ Coords = vec3(1164.71,-324.82,69.33), Mode = "Register" },
	{ Coords = vec3(1164.37,-322.86,69.34), Mode = "Register" },
	{ Coords = vec3(-706.47,-915.60,19.36), Mode = "Register" },
	{ Coords = vec3(-706.47,-913.68,19.35), Mode = "Register" },
	{ Coords = vec3(-48.32,-1759.26,29.56), Mode = "Register" },
	{ Coords = vec3(-47.07,-1757.77,29.56), Mode = "Register" },
	{ Coords = vec3(373.23,325.69,103.78), Mode = "Register" },
	{ Coords = vec3(373.73,327.77,103.78), Mode = "Register" },
	{ Coords = vec3(-3241.66,1000.76,13.05), Mode = "Register" },
	{ Coords = vec3(-3243.79,1000.92,13.04), Mode = "Register" },
	{ Coords = vec3(1728.36,6414.37,35.28), Mode = "Register" },
	{ Coords = vec3(1729.29,6416.30,35.27), Mode = "Register" },
	{ Coords = vec3(548.17,2671.76,42.38), Mode = "Register" },
	{ Coords = vec3(548.48,2669.65,42.37), Mode = "Register" },
	{ Coords = vec3(1961.07,3739.97,32.57), Mode = "Register" },
	{ Coords = vec3(1959.99,3741.79,32.57), Mode = "Register" },
	{ Coords = vec3(2677.03,3280.89,55.46), Mode = "Register" },
	{ Coords = vec3(2678.91,3279.88,55.46), Mode = "Register" },
	{ Coords = vec3(1698.22,4923.23,42.23), Mode = "Register" },
	{ Coords = vec3(1696.63,4924.34,42.21), Mode = "Register" },
	{ Coords = vec3(-1820.35,793.93,138.26), Mode = "Register" },
	{ Coords = vec3(-1819.05,792.51,138.24), Mode = "Register" },
	{ Coords = vec3(-2966.86,390.89,15.17), Mode = "Register" },
	{ Coords = vec3(-3038.71,585.49,8.14), Mode = "Register" },
	{ Coords = vec3(-3040.72,584.81,8.13), Mode = "Register" },
	{ Coords = vec3(1134.65,-982.38,46.56), Mode = "Register" },
	{ Coords = vec3(1165.96,2710.36,38.30), Mode = "Register" },
	{ Coords = vec3(-1486.56,-378.35,40.29), Mode = "Register" },
	{ Coords = vec3(-1222.24,-907.96,12.45), Mode = "Register" },
	{ Coords = vec3(81.67,-1389.48,29.61), Mode = "Register" },
	{ Coords = vec3(78.28,-1389.39,29.61), Mode = "Register" },
	{ Coords = vec3(-706.77,-151.41,37.66), Mode = "Register" },
	{ Coords = vec3(-166.64,-301.56,39.97), Mode = "Register" },
	{ Coords = vec3(-816.27,-1077.32,11.57), Mode = "Register" },
	{ Coords = vec3(-817.92,-1074.30,11.57), Mode = "Register" },
	{ Coords = vec3(-1198.19,-779.15,17.63), Mode = "Register" },
	{ Coords = vec3(-1197.00,-778.27,17.63), Mode = "Register" },
	{ Coords = vec3(-1447.93,-240.00,50.05), Mode = "Register" },
	{ Coords = vec3(-1.95,6514.69,32.11), Mode = "Register" },
	{ Coords = vec3(0.29,6512.14,32.11), Mode = "Register" },
	{ Coords = vec3(1688.17,4818.62,42.31), Mode = "Register" },
	{ Coords = vec3(1691.52,4818.95,42.30), Mode = "Register" },
	{ Coords = vec3(123.82,-211.75,54.86), Mode = "Register" },
	{ Coords = vec3(123.34,-213.09,54.86), Mode = "Register" },
	{ Coords = vec3(620.91,2752.62,42.39), Mode = "Register" },
	{ Coords = vec3(620.81,2753.99,42.39), Mode = "Register" },
	{ Coords = vec3(1200.10,2703.67,38.49), Mode = "Register" },
	{ Coords = vec3(1200.18,2707.14,38.50), Mode = "Register" },
	{ Coords = vec3(-3171.76,1055.84,21.15), Mode = "Register" },
	{ Coords = vec3(-3172.32,1054.57,21.13), Mode = "Register" },
	{ Coords = vec3(422.49,-809.78,29.74), Mode = "Register" },
	{ Coords = vec3(419.02,-809.69,29.75), Mode = "Register" },
	{ Coords = vec3(-1094.52,2707.98,19.37), Mode = "Register" },
	{ Coords = vec3(-1096.77,2710.61,19.37), Mode = "Register" },
	
	{ Coords = vec3(-905.15,-2781.36,14.33), Mode = "Container" },
	{ Coords = vec3(1178.63,-3126.89,6.22), Mode = "Container" },
	{ Coords = vec3(1178.45,-2996.97,6.11), Mode = "Container" },
	{ Coords = vec3(852.38,-2990.8,6.1), Mode = "Container" },
	{ Coords = vec3(794.37,-3202.89,6.11), Mode = "Container" },
	{ Coords = vec3(496.67,-2968.93,6.23), Mode = "Container" },
	{ Coords = vec3(603.93,-2958.34,6.23), Mode = "Container" },
	{ Coords = vec3(573.04,-2625.16,6.33), Mode = "Container" },
	{ Coords = vec3(315.07,-2674.07,6.19), Mode = "Container" },
	{ Coords = vec3(307.34,-2939.34,6.23), Mode = "Container" },
	{ Coords = vec3(18.0,-2503.34,6.2), Mode = "Container" },
	{ Coords = vec3(-86.18,-2459.67,6.21), Mode = "Container" },
	{ Coords = vec3(-433.92,-2742.91,6.22), Mode = "Container" },
	{ Coords = vec3(-84.15,-2410.03,6.2), Mode = "Container" },
	{ Coords = vec3(208.01,2743.95,43.63), Mode = "Container" },
	{ Coords = vec3(309.92,2900.98,46.57), Mode = "Container" },
	{ Coords = vec3(1445.55,3615.58,34.94), Mode = "Container" },
	{ Coords = vec3(2848.14,4558.16,47.22), Mode = "Container" },
	{ Coords = vec3(2513.92,4995.55,45.23), Mode = "Container" },
	{ Coords = vec3(2358.19,4860.65,41.44), Mode = "Container" },
	{ Coords = vec3(964.3,-3248.86,6.89), Mode = "Container" },
	{ Coords = vec3(1002.17,-3253.41,7.01), Mode = "Container" },
	{ Coords = vec3(1021.95,-3267.5,6.99), Mode = "Container" },
	{ Coords = vec3(1098.74,-3306.02,6.89), Mode = "Container" },
	{ Coords = vec3(1151.78,-3248.26,6.12), Mode = "Container" },
	{ Coords = vec3(1052.38,-3045.11,6.11), Mode = "Container" },
	{ Coords = vec3(1228.79,-2972.04,12.05), Mode = "Container" },
	{ Coords = vec3(838.5,-2923.97,6.1), Mode = "Container" },
	{ Coords = vec3(541.69,-3000.09,6.25), Mode = "Container" },
	{ Coords = vec3(597.49,-2897.4,6.26), Mode = "Container" },
	{ Coords = vec3(631.97,-2958.08,6.27), Mode = "Container" },
	{ Coords = vec3(374.14,-2525.37,6.06), Mode = "Container" },
	{ Coords = vec3(324.61,-2674.36,6.29), Mode = "Container" },
	{ Coords = vec3(251.75,-2734.83,6.03), Mode = "Container" },
	{ Coords = vec3(108.15,-2895.12,6.24), Mode = "Container" },
	{ Coords = vec3(203.61,-2644.34,6.21), Mode = "Container" },
	{ Coords = vec3(-214.94,-2555.2,6.21), Mode = "Container" },
	{ Coords = vec3(-98.76,-2421.16,6.23), Mode = "Container" },
	{ Coords = vec3(74.67,-2496.03,6.22), Mode = "Container" },
	{ Coords = vec3(-44.5,-2240.93,8.02), Mode = "Container" },

	{ Coords = vec3 (147.51,-1036.03,29.33), Mode = "Eletronic" },
	{ Coords = vec3(145.86,-1035.43,29.34), Mode = "Eletronic" } ,
	{ Coords = vec3(24.56,-945.71,29.30), Mode = "Eletronic" },
	{ Coords = vec3(5.53,-919.90,29.43), Mode = "Eletronic" },
	{ Coords = vec3(-203.92,-861.14,30.21), Mode = "Eletronic" },
	{ Coords = vec3(-301.67,-829.75,32.36), Mode = "Eletronic" },
	{ Coords = vec3(-303.23,-829.48,32.36), Mode = "Eletronic" },
	{ Coords = vec3(-254.49,-692.72,33.54), Mode = "Eletronic" },
	{ Coords = vec3(-256.48,-715.92,33.74), Mode = "Eletronic" },
	{ Coords = vec3(-259.11,-723.29,33.66), Mode = "Eletronic" },
	{ Coords = vec3(111.37,-775.01,31.39), Mode = "Eletronic" },
	{ Coords = vec3(114.52,-776.14,31.39), Mode = "Eletronic" },
	{ Coords = vec3(112.50,-819.64,31.32), Mode = "Eletronic" },
	{ Coords = vec3(296.71,-894.30,29.23), Mode = "Eletronic" },
	{ Coords = vec3(296.01,-896.20,29.25), Mode = "Eletronic" },
	{ Coords = vec3(1077.73,-776.80,58.22), Mode = "Eletronic" },
	{ Coords = vec3(1137.98,-468.87,66.69), Mode = "Eletronic" },
	{ Coords = vec3(1167.05,-455.82,66.82), Mode = "Eletronic" },
	{ Coords = vec3(285.37,143.14,104.14), Mode = "Eletronic" },
	{ Coords = vec3(-165.42,232.72,94.91), Mode = "Eletronic" },
	{ Coords = vec3(-165.42,234.79,94.88), Mode = "Eletronic" },
	{ Coords = vec3(-846.52,-341.41,38.64), Mode = "Eletronic" },
	{ Coords = vec3(-847.07,-340.33,38.67), Mode = "Eletronic" },
	{ Coords = vec3(-2072.10,-317.30,13.37), Mode = "Eletronic" },
	{ Coords = vec3(-1315.53,-834.56,16.96), Mode = "Eletronic" },
	{ Coords = vec3(-1314.58,-835.82,16.92), Mode = "Eletronic" },
	{ Coords = vec3(-3043.90,594.32,7.70), Mode = "Eletronic" },
	{ Coords = vec3(-712.90,-818.65,23.73), Mode = "Eletronic" },
	{ Coords = vec3(-710.05,-818.64,23.75), Mode = "Eletronic" },
	{ Coords = vec3(-1410.03,-100.58,52.39), Mode = "Eletronic" },
	{ Coords = vec3(-1410.59,-98.85,52.38), Mode = "Eletronic" },
	{ Coords = vec3(-866.88,-187.90,37.90), Mode = "Eletronic" },
	{ Coords = vec3(-867.84,-186.24,37.84), Mode = "Eletronic" }
}