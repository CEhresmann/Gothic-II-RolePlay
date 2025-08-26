local noneFraction = addFraction(0, "Brak");


PlayerClass(0, "Nieznajomy", function(pid) {
    setPlayerHealth(pid, 100);
    setPlayerMaxHealth(pid, 100);

    setPlayerDexterity(pid, 10);
    setPlayerStrength(pid, 10);

    setPlayerTalent(pid, TALENT_1H, 10); 
    setPlayerTalent(pid, TALENT_2H, 10);
    setPlayerTalent(pid, TALENT_BOW, 10);
    setPlayerTalent(pid, TALENT_CROSSBOW, 10);

    giveItem(pid, "ITAR_PRISONER", 1);
    equipItem(pid, "ITAR_PRISONER");
}, noneFraction)

local townFraction = addFraction(1, "Miasto");


PlayerClass(1, "Obywatel", function(pid) {
    setPlayerHealth(pid, 130);
    setPlayerMaxHealth(pid, 130);

    setPlayerDexterity(pid, 10);
    setPlayerStrength(pid, 10);

    setPlayerTalent(pid, TALENT_1H, 10);
    setPlayerTalent(pid, TALENT_2H, 10);
    setPlayerTalent(pid, TALENT_BOW, 10);
    setPlayerTalent(pid, TALENT_CROSSBOW, 10);

    giveItem(pid, "ITAR_VLK_L", 1);
    equipItem(pid, "ITAR_VLK_L");
}, townFraction)


PlayerClass(2, "Stra¿nik", function(pid) {
    setPlayerHealth(pid, 250);
    setPlayerMaxHealth(pid, 250);

    setPlayerDexterity(pid, 40);
    setPlayerStrength(pid, 40);

    setPlayerTalent(pid, TALENT_1H, 30);
    setPlayerTalent(pid, TALENT_2H, 30);
    setPlayerTalent(pid, TALENT_BOW, 30);
    setPlayerTalent(pid, TALENT_CROSSBOW, 30);

    giveItem(pid, "ITMW_1H_SLD_SWORD", 1);
    giveItem(pid, "ITAR_VLK_L", 1);
    equipItem(pid, "ITAR_VLK_L");
    equipItem(pid, "ITMW_1H_SLD_SWORD");
}, townFraction)