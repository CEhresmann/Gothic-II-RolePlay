function getSkillUpgradeCost(pid, skillType) {
    local currentVal;
    local thresholds;

    switch (skillType) {
        case SkillType.Strength:
            currentVal = getPlayerStrength(pid);
            thresholds = SKILL_CONFIG.Development.Attributes.Thresholds;
            break;
        case SkillType.Dexterity:
            currentVal = getPlayerDexterity(pid);
            thresholds = SKILL_CONFIG.Development.Attributes.Thresholds;
            break;
        case SkillType.OneHanded:
            currentVal = getPlayerSkillWeapon(pid, WEAPON_1H);
            thresholds = SKILL_CONFIG.Development.WeaponSkills.Thresholds;
            break;
        case SkillType.TwoHanded:
            currentVal = getPlayerSkillWeapon(pid, WEAPON_2H);
            thresholds = SKILL_CONFIG.Development.WeaponSkills.Thresholds;
            break;
        case SkillType.Bow:
            currentVal = getPlayerSkillWeapon(pid, WEAPON_BOW);
            thresholds = SKILL_CONFIG.Development.WeaponSkills.Thresholds;
            break;
        case SkillType.Crossbow:
            currentVal = getPlayerSkillWeapon(pid, WEAPON_CBOW);
            thresholds = SKILL_CONFIG.Development.WeaponSkills.Thresholds;
            break;
        case SkillType.Health:
            currentVal = getPlayerMaxHealth(pid);
            thresholds = SKILL_CONFIG.Development.Vitals.Thresholds;
            break;
        case SkillType.Mana:
            currentVal = getPlayerMaxMana(pid);
            thresholds = SKILL_CONFIG.Development.Vitals.Thresholds;
            break;
        case SkillType.MagicCircle:
            local nextCircle = rawstring((getPlayerTalent(pid, TALENT_MAGE) + 1));
            if (nextCircle in SKILL_CONFIG.Development.Magic.CircleCosts) {
                return SKILL_CONFIG.Development.Magic.CircleCosts[nextCircle];
            }
    }

    if (thresholds != null) {
        foreach (th in thresholds) {
            if (currentVal < th.threshold) {
                return th.cost;
            }
        }
    }

    return 1;
}

function isValidSkillUpgrade(pid, skillType) {
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local cost = getSkillUpgradeCost(pid, skillType);
        if (getPlayerLearningPoints(pid) < cost) {
            addNotification(pid, "Nie masz wystarczaj¹co punktów nauki! Potrzeba " + cost + "PN.");
            return false;
        }

        switch (skillType) {
            case SkillType.Health:
                if (getPlayerMaxHealth(pid) >= SKILL_CONFIG.Limits.Health) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom zdrowia!");
                    return false;
                }
                break;
            case SkillType.Mana:
                if (getPlayerMaxMana(pid) >= SKILL_CONFIG.Limits.Mana) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom many!");
                    return false;
                }
                break;
            case SkillType.Strength:
                if (getPlayerStrength(pid) >= SKILL_CONFIG.Limits.Strength) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom si³y!");
                    return false;
                }
                break;
            case SkillType.Dexterity:
                if (getPlayerDexterity(pid) >= SKILL_CONFIG.Limits.Dexterity) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom zrêcznoœci!");
                    return false;
                }
                break;
            case SkillType.OneHanded:
            case SkillType.TwoHanded:
            case SkillType.Bow:
            case SkillType.Crossbow:
                local weaponMap = {
                    [SkillType.OneHanded] = WEAPON_1H,
                    [SkillType.TwoHanded] = WEAPON_2H,
                    [SkillType.Bow] = WEAPON_BOW,
                    [SkillType.Crossbow] = WEAPON_CBOW
                };
                if (getPlayerSkillWeapon(pid, weaponMap[skillType]) >= SKILL_CONFIG.Limits.WeaponSkill) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom tej umiejêtnoœci!");
                    return false;
                }
                break;
            case SkillType.MagicCircle:
                 local currentMagic = getPlayerTalent(pid, TALENT_MAGE);
                 if (currentMagic == 0) {
                    addNotification(pid, "Musisz najpierw nauczyæ siê podstaw magii!");
                    return false;
                 }
                 if (currentMagic >= SKILL_CONFIG.Limits.MagicCircle) {
                    addNotification(pid, "Osi¹gn¹³eœ maksymalny kr¹g magiczny!");
                    return false;
                 }
                break;
            default:
                addNotification(pid, "Nieznany typ umiejêtnoœci!");
                return false;
        }
        return true;
    }
    return false;
}

function upgradePlayerSkill(pid, skillType) {
    if (!isValidSkillUpgrade(pid, skillType)) {
        return false;
    }

    local cost = getSkillUpgradeCost(pid, skillType);
    addPlayerLearningPoints(pid, -cost);

    switch (skillType) {
        case SkillType.Health:
            setPlayerMaxHealth(pid, getPlayerMaxHealth(pid) + SKILL_CONFIG.Development.Vitals.Value);
            addNotification(pid, "Zdrowie zwiêkszone!");
            break;
        case SkillType.Mana:
            setPlayerMaxMana(pid, getPlayerMaxMana(pid) + SKILL_CONFIG.Development.Vitals.Value);
            addNotification(pid, "Mana zwiêkszona!");
            break;
        case SkillType.Strength:
            setPlayerStrength(pid, getPlayerStrength(pid) + 1);
            addNotification(pid, "Si³a zwiêkszona!");
            break;
        case SkillType.Dexterity:
            setPlayerDexterity(pid, getPlayerDexterity(pid) + 1);
            addNotification(pid, "Zrêcznoœæ zwiêkszona!");
            break;
        case SkillType.OneHanded:
            setPlayerSkillWeapon(pid, WEAPON_1H, getPlayerSkillWeapon(pid, WEAPON_1H) + 1);
            addNotification(pid, "Zwiêkszono umiejêtnoœæ walki broni¹ jednorêczn¹!");
            break;
        case SkillType.TwoHanded:
            setPlayerSkillWeapon(pid, WEAPON_2H, getPlayerSkillWeapon(pid, WEAPON_2H) + 1);
            addNotification(pid, "Zwiêkszono umiejêtnoœæ walki broni¹ dwurêczn¹!");
            break;
        case SkillType.Bow:
            setPlayerSkillWeapon(pid, WEAPON_BOW, getPlayerSkillWeapon(pid, WEAPON_BOW) + 1);
            addNotification(pid, "Zwiêkszono umiejêtnoœæ walki ³ukiem!");
            break;
        case SkillType.Crossbow:
            setPlayerSkillWeapon(pid, WEAPON_CBOW, getPlayerSkillWeapon(pid, WEAPON_CBOW) + 1);
            addNotification(pid, "Zwiêkszono umiejêtnoœæ walki kusz¹!");
            break;
        case SkillType.MagicCircle:
            setPlayerTalent(pid, TALENT_MAGE, getPlayerTalent(pid, TALENT_MAGE) + 1);
            addNotification(pid, "Opanowa³eœ nowy kr¹g magii!");
            break;
    }
    return true;
}

function syncProfessionsWithClient(pid) {
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UpdateProfessions);
        for (local i = 0; i < ProfessionType.COUNT; i++) {
            packet.writeInt32(getPlayerProfessionLevel(pid, i));
        }
        packet.send(pid, RELIABLE_ORDERED);
    }
}

function sendPlayerStatsUpdate(pid) {
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UpdateStats);

        packet.writeInt32(getPlayerHealth(pid));
        packet.writeInt32(getPlayerMaxHealth(pid));
        packet.writeInt32(getPlayerMana(pid));
        packet.writeInt32(getPlayerMaxMana(pid));
        packet.writeInt32(getPlayerStrength(pid));
        packet.writeInt32(getPlayerDexterity(pid));
        packet.writeInt32(getPlayerSkillWeapon(pid, WEAPON_1H));
        packet.writeInt32(getPlayerSkillWeapon(pid, WEAPON_2H));
        packet.writeInt32(getPlayerSkillWeapon(pid, WEAPON_BOW));
        packet.writeInt32(getPlayerSkillWeapon(pid, WEAPON_CBOW));
        packet.writeInt32(getPlayerTalent(pid, TALENT_MAGE));
        packet.writeInt32(getPlayerLearningPoints(pid));

        packet.send(pid, RELIABLE_ORDERED);
        syncProfessionsWithClient(pid);
    }
}

function getProfessionUpgradeCost(pid, professionType) {
    local currentLevel = getPlayerProfessionLevel(pid, professionType);
    if (currentLevel >= PROFESSION_CONFIG.MaxLevel) {
        return -1;
    }

    if (professionType in PROFESSION_CONFIG.UpgradeCosts && currentLevel < PROFESSION_CONFIG.UpgradeCosts[professionType].len()) {
        return PROFESSION_CONFIG.UpgradeCosts[professionType][currentLevel];
    }

    return 20;
}

function isValidProfessionUpgrade(pid, professionType) {
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local currentLevel = getPlayerProfessionLevel(pid, professionType);

        if (currentLevel >= PROFESSION_CONFIG.MaxLevel) {
            addNotification(pid, "Osi¹gn¹³eœ maksymalny poziom tej profesji!");
            return false;
        }

        local cost = getProfessionUpgradeCost(pid, professionType);
        if (getPlayerLearningPoints(pid) < cost) {
            addNotification(pid, "Nie masz wystarczaj¹co punktów nauki! Potrzeba " + cost + " PN.");
            return false;
        }

        return true;
    }
    return false;
}

function upgradePlayerProfession(pid, professionType) {
    if (!isValidProfessionUpgrade(pid, professionType)) {
        return false;
    }

    local cost = getProfessionUpgradeCost(pid, professionType);
    local currentLevel = getPlayerProfessionLevel(pid, professionType);

    addPlayerLearningPoints(pid, -cost);
    setPlayerProfessionLevel(pid, professionType, currentLevel + 1);

    local professionName = PROFESSION_CONFIG.Names[professionType];
    addNotification(pid, "Profesja " + professionName + " ulepszona do poziomu " + (currentLevel + 1) + "!");

    return true;
}

addEventHandler("onPacket", function(playerid, packet) {
    local packetId = packet.readUInt8();

    if (packetId == PacketId.Player) {
        local playerPacketType = packet.readUInt8();

        switch(playerPacketType) {
            case PacketPlayer.RequestStatsUpdate:
                sendPlayerStatsUpdate(playerid);
                break;

            case PacketPlayer.RequestSkillCost:
                local skillType = packet.readUInt8();
                local cost = getSkillUpgradeCost(playerid, skillType);

                local response = Packet();
                response.writeUInt8(PacketId.Player);
                response.writeUInt8(PacketPlayer.UpdateSkillCost);
                response.writeUInt8(skillType);
                response.writeInt32(cost);
                response.send(playerid, RELIABLE_ORDERED);
                break;

            case PacketPlayer.UpgradeSkill:
                local skillType = packet.readUInt8();
                if (upgradePlayerSkill(playerid, skillType)) {
                    sendPlayerStatsUpdate(playerid);
                }
                break;

            case PacketPlayer.RequestProfessionCost:
                local profType = packet.readUInt8();
                local profCost = getProfessionUpgradeCost(playerid, profType);

                local profResponse = Packet();
                profResponse.writeUInt8(PacketId.Player);
                profResponse.writeUInt8(PacketPlayer.UpdateProfessionCost);
                profResponse.writeUInt8(profType);
                profResponse.writeInt32(profCost);
                profResponse.send(playerid, RELIABLE_ORDERED);
                break;

            case PacketPlayer.UpgradeProfession:
                local professionType = packet.readUInt8();
                if (upgradePlayerProfession(playerid, professionType)) {
                    sendPlayerStatsUpdate(playerid);
                }
                break;
        }
    }
});
