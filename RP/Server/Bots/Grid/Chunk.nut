
class Chunk
{
    constructor()
    {
        bots = [];
        players = [];
    }

    function addPlayer(id) {
        local idx = players.find(id)
        if (idx != null)
            return;

        BotPlayer[id].indexes.append(this);

        foreach(bot in bots)
            BotPlayer[id].add(bot);

        players.append(id);
    }

    function removePlayer(id) {
        local idx = players.find(id)

        if (idx == null)
            return;

        BotPlayer[id].indexes.remove(BotPlayer[id].indexes.find(this));

        foreach(bot in bots)
            BotPlayer[id].remove(bot);

        players.remove(idx);
    }

    function addBot(id)
    {
        local idx = bots.find(id)

        if (idx != null)
            return

        bots.append(id);
    }

    function removeBot(id)
    {
        local idx = bots.find(id)

        if (idx == null)
            return

        bots.remove(idx);
    }

    bots = null;
    players = null;
}