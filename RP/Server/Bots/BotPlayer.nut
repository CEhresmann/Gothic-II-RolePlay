
class _BotPlayer 
{
    constructor()
    {
        bots = [];
        indexes = [];

        pid = -1;
        grid = -1;
    }

    function remove(botId)
    {
        local idIndex = isIn(botId);
        if(idIndex == null)
            return;
        
        bots.remove(idIndex);
        getBot(botId).unspawn(pid);
    }

    function add(botId)
    {
        if(isIn(botId) != null)
            return;
            
        bots.append(botId);
        getBot(botId).spawn(pid);
    }

    function isIn(id)
    {
        return bots.find(id);
    }

    pid = -1;
    grid = -1;

    bots = null;
    indexes = null;
}

BotPlayer <- [];

for(local i = 0; i<= getMaxSlots(); i++)
{
    BotPlayer.append(_BotPlayer());
    BotPlayer[i].pid = i;
}

addEventHandler("onPlayerDisconnect", function(pid, res) {
    foreach(_botId in BotPlayer[pid].bots)
    {
        local bot = getBot(_botId);
        if(!bot)
            continue;
        
        bot.onPlayerDisconnect(pid);
    }

    foreach(_chunk in BotPlayer[pid].indexes)
    {
        local idx = _chunk.players.find(pid)

        if (idx == null)
            continue;

        foreach(bot in _chunk.bots)
            BotPlayer[pid].remove(bot);

        _chunk.players.remove(idx);
    }

    BotPlayer[pid].grid = null;
    BotPlayer[pid].indexes.clear();
    BotPlayer[pid].bots.clear();
})

function getPlayersBot(botId)
{
    local idS = [];
    foreach(id, _bot in BotPlayer)
    {
        if(_bot.isIn(botId) != null)
        {
            idS.append(id);
        }
    }
    return idS;
}