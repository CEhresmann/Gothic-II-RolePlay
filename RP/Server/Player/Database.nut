Database <- {};

const TALENT_1H = 0;
const TALENT_2H = 1;
const TALENT_BOW = 2;
const TALENT_CROSSBOW = 3;
const TALENT_MAGE = 6;


class PlayerAccount extends ORM.Model </ table="player_accounts" /> {
    
    </ primary_key = true, auto_increment = true />
    id = -1

    </ type = "VARCHAR(32)", unique = true, not_null = true />
    name = ""

    </ type = "VARCHAR(255)", not_null = true />
    password = ""

    </ type = "INTEGER", not_null = true />
    class_id = 0

    </ type = "INTEGER", not_null = true />
    fraction_id = 0

    </ type = "VARCHAR(32)" />
    walk_style = "HUMANS"

    </ type = "INTEGER", not_null = true />
    strength = 10

    </ type = "INTEGER", not_null = true />
    dexterity = 10

    </ type = "INTEGER", not_null = true />
    hp_max = 100

    </ type = "INTEGER", not_null = true />
    mana_max = 0

    </ type = "INTEGER", not_null = true />
    magic_level = 0

    </ type = "TEXT" />
    description = ""

    </ type = "VARCHAR(64)" />
    body_model = ""

    </ type = "INTEGER" />
    body_texture = 0

    </ type = "VARCHAR(64)" />
    head_model = ""

    </ type = "INTEGER" />
    head_texture = 0
}

class PlayerPosition extends ORM.Model </ table="player_positions" /> {   
    </ primary_key = true />
    player_id = -1

    </ type = "FLOAT", not_null = true />
    pos_x = 0

    </ type = "FLOAT", not_null = true />
    pos_y = 0

    </ type = "FLOAT", not_null = true />
    pos_z = 0

    </ type = "FLOAT", not_null = true />
    angle = 0
}

class PlayerSkills extends ORM.Model </ table="player_skills" /> {  
    </ primary_key = true />
    player_id = -1

    </ type = "INTEGER", not_null = true />
    weapon_0 = 0

    </ type = "INTEGER", not_null = true/>
    weapon_1 = 0

    </ type = "INTEGER", not_null = true />
    weapon_2 = 0

    </ type = "INTEGER", not_null = true />
    weapon_3 = 0
}

class PlayerItems extends ORM.Model </ table="player_items" /> {
    
    </ primary_key = true />
    player_id = -1

    </ primary_key = true, type = "VARCHAR(64)" />
    item_instance = ""

    </ type = "INTEGER", not_null = true />
    amount = 1
}

function Database::getNextId()
{
    return -1;
}

function Database::checkExistPlayer(name)
{
    try {
        local account = PlayerAccount.findOne(@(q) q.where("name", "=", name));
        if (account != null) {
            return account.password;
        }
        return false;
    } catch (e) {
        return false;
    }
}

function Database::createPlayer(player)
{
    local account = PlayerAccount();
    account.name = getPlayerName(player.pid);
    account.password = player.password;
    account.class_id = player.classId;
    account.fraction_id = player.fractionId;
	account.walk_style = player.walkStyleString;
    account.strength = player.str;
    account.dexterity = player.dex;
    account.hp_max = player.hpMax;
    account.mana_max = player.manaMax;
    account.magic_level = player.magicLvl;
    account.description = player.description;
	
    local visual = getPlayerVisual(player.pid);
    account.body_model = visual.bodyModel;
    account.body_texture = visual.bodyTxt.tointeger();
    account.head_model = visual.headModel;
    account.head_texture = visual.headTxt.tointeger();
    
    account.insert();

    local pos = getPlayerPosition(player.pid);
    local position = PlayerPosition();
    position.player_id = account.id;
    position.pos_x = pos.x;
    position.pos_y = pos.y;
    position.pos_z = pos.z;
    position.angle = getPlayerAngle(player.pid);
    position.insert();

    local skills = PlayerSkills();
    skills.player_id = account.id;
    skills.weapon_0 = player.weapon[0];
    skills.weapon_1 = player.weapon[1];
    skills.weapon_2 = player.weapon[2];
    skills.weapon_3 = player.weapon[3];
    skills.insert();
}

function Database::loadItems(pid)
{
    try {
        local items = PlayerItems.find(@(q) q.where("player_id", "=", Player[pid].id));
        
        foreach (item in items) {
            giveItem(pid, item.item_instance, item.amount);
        }
    } catch (e) {
        print("[DB-ERROR] loadItems failed: " + e);
    }
}

function Database::saveItems(pid)
{
    try {
        ORM.engine.execute("DELETE FROM player_items WHERE player_id = " + Player[pid].id);
        
        foreach (instance, amount in Player[pid].items) {
            local item = PlayerItems();
            item.player_id = Player[pid].id;
            item.item_instance = instance;
            item.amount = amount;
            item.insert();
        }
    } catch (e) {
        print("[DB-ERROR] saveItems failed: " + e);
    }
}

function Database::updatePlayer(player)
{
    local account = PlayerAccount.findOne(@(q) q.where("name", "=", getPlayerName(player.pid)));
    if (!account) return false;

    account.password = player.password;
    account.class_id = player.classId;
    account.fraction_id = player.fractionId;
    //account.walk_style = player.walkStyleString;
    account.strength = player.str;
    account.dexterity = player.dex;
    account.hp_max = player.hpMax;
    account.mana_max = player.manaMax;
    account.magic_level = player.magicLvl;
    account.description = player.description;


    local pos = getPlayerPosition(player.pid);
    local position = PlayerPosition.findOne(@(q) q.where("player_id", "=", account.id));
    if (position) {
        position.pos_x = pos.x;
        position.pos_y = pos.y;
        position.pos_z = pos.z;
        position.angle = getPlayerAngle(player.pid);
        position.save();
    }


    local skills = PlayerSkills.findOne(@(q) q.where("player_id", "=", account.id));
    if (skills) {
        skills.weapon_0 = player.weapon[0];
        skills.weapon_1 = player.weapon[1];
        skills.weapon_2 = player.weapon[2];
        skills.weapon_3 = player.weapon[3];
        skills.save();
    }


    local visual = getPlayerVisual(player.pid);
    account.body_model = visual.bodyModel;
    account.body_texture = visual.bodyTxt.tointeger();
    account.head_model = visual.headModel;
    account.head_texture = visual.headTxt.tointeger();
	account.walk_style = Player[player.pid].walkStyleString;
    
    return account.save();
}

function Database::loadAccount(player)
{
    local account = PlayerAccount.findOne(@(q) q.where("name", "=", getPlayerName(player.pid)));
    if (!account) return;

    player.id = account.id;
    player.password = account.password;
    player.classId = account.class_id;
    player.fractionId = account.fraction_id;
    
    local position = PlayerPosition.findOne(@(q) q.where("player_id", "=", account.id));
    if (position) {
        setPlayerPosition(player.pid, position.pos_x, position.pos_y, position.pos_z);
        setPlayerAngle(player.pid, position.angle);
    }

    setPlayerStrength(player.pid, account.strength);
    setPlayerDexterity(player.pid, account.dexterity);
    setPlayerMaxHealth(player.pid, account.hp_max);
    setPlayerMaxMana(player.pid, account.mana_max);
    setPlayerTalent(player.pid, TALENT_MAGE, account.magic_level);
    setPlayerDescription(player.pid, account.description);
	setClassPlayer(player.pid, account.fraction_id, account.class_id)
	setPlayerWalkStyle(player.pid, account.walk_style);

    local skills = PlayerSkills.findOne(@(q) q.where("player_id", "=", account.id));
    if (skills) {
        setPlayerTalent(player.pid, TALENT_1H, skills.weapon_0);
        setPlayerTalent(player.pid, TALENT_2H, skills.weapon_1);
        setPlayerTalent(player.pid, TALENT_BOW, skills.weapon_2);
        setPlayerTalent(player.pid, TALENT_CROSSBOW, skills.weapon_3);
    }

    setPlayerVisual(player.pid, account.body_model, account.body_texture.tointeger(), 
                   account.head_model, account.head_texture.tointeger());
}