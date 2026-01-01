
addEventHandler("onInit", function(){
	createMonster("WOLF", 8254.36, 599.846, -10783.9, 217.302); 
	createMonster("MOLERAT", 8046.71, 499.561, -9009.37, 19.2374); 
	
	createMonster("ORCWARRIOR_REST", -1163.88, -63.8426, -4550.74, 19.2374); 
	createMonster("ORCWARRIOR_HARAD", -2805.72, -101.88, -4291.96, 19.2374); 
	createMonster("ORCELITE_REST", -4546.91, -51.8948, -4434.67, 19.2374); 



	createHuman(8960.55, 368.261, -2766.44, 60, {
		name = "Strażnik Miejski",
		can_fight_back = true,
		can_wander = false,
		idle_speech = true,
		weapon_mode = WEAPONMODE_1HS,
		attack_distance = 200,
		visual = {
			body = "Hum_Body_Naked0",
			bodyTex = 0,
			head = "HUM_HEAD_PONY", 
			headTex = 52
		}
	}, 
	function(npc) {
		setPlayerStrength(npc.id, 50);
		setPlayerHealth(npc.id, 200);
        giveItem(npc.id, "ITMW_1H_SLD_SWORD", 1);
        equipItem(npc.id, "ITMW_1H_SLD_SWORD", 0);
        giveItem(npc.id, "ItAr_Mil_L", 1);
        equipItem(npc.id, "ItAr_Mil_L", 0);
	});

	createHuman(9577.5, 368.278, -1596.78, 30, {
		name = "Mieszczanin",
		can_fight_back = false,
		can_wander = false,
		idle_speech = true,
		weapon_mode = WEAPONMODE_NONE,
		wander_chance = 10,
		idle_chance = 5,
		visual = {
			body = "Hum_Body_Naked0",
			bodyTex = 0,
			head = "HUM_HEAD_PONY", 
			headTex = 52
		}
	}, 
	function(npc) {
		setPlayerStrength(npc.id, 20);
		setPlayerHealth(npc.id, 100);
	});

	createHuman(9408.71, 368.254, -728.756, -100, {
		name = "Mag Wody",
		can_fight_back = true,
		weapon_warning = false,
		can_wander = false,
		idle_speech = true,
		weapon_mode = WEAPONMODE_FIST,
		attack_distance = 200,
		visual = {
			body = "Hum_Body_Naked0",
			bodyTex = 0,
			head = "HUM_HEAD_BALD", 
			headTex = 32
		}
	}, 
	function(npc) {
		setPlayerStrength(npc.id, 50);
		setPlayerHealth(npc.id, 200);
        giveItem(npc.id, "ItAr_KdW_H", 1);
        equipItem(npc.id, "ItAr_KdW_H", 0);
	});
	
	createHuman(9408.71, 368.254, -728.756, 30, {
		name = "Mieszczanin",
		can_fight_back = false,
		can_wander = false,
		idle_speech = true,
		weapon_mode = WEAPONMODE_NONE,
		visual = {
			body = "Hum_Body_Naked0",
			bodyTex = 0,
			head = "HUM_HEAD_BALD", 
			headTex = 47
		}
	}, function(npc) {
		setPlayerStrength(npc.id, 20);
		setPlayerHealth(npc.id, 100);
        giveItem(npc.id, "ItAr_Vlk_M", 1);
        equipItem(npc.id, "ItAr_Vlk_M", 0);
	});
});

