local registeredItemsGround = [];

class RegisterGroundItem
{
    item = null;
    timeLeft = -1;
    respawnTime = 180;
    position = null;
    world = null;

    constructor(x, y, z, worldName = CFG.BotsSpawnMap)
    {
        position = Vec3(x, y, z);
        world = worldName;

        respawn();
        registeredItemsGround.append(this);
    }

    function getAllCFGGroundCount()
    {
        local totalWeight = 0;
        foreach(itemConfig in CFG.GroundItems)
        {
            totalWeight += itemConfig[2];
        }
        return totalWeight;
    }

    function getRandomItem()
    {
        local totalWeight = getAllCFGGroundCount();
        if (totalWeight == 0) return false;

        local randomNumber = rand() % totalWeight;
        local currentWeight = 0;

        foreach(itemConfig in CFG.GroundItems)
        {
            if(randomNumber >= currentWeight && randomNumber < (currentWeight + itemConfig[2]))
            {
                return {
                    id = Daedalus.index(itemConfig[0]),
                    instanceName = itemConfig[0],
                    amount = itemConfig[1],
                    respawn = itemConfig[3]
                };
            }
            currentWeight += itemConfig[2];
        }
        return false;
    }

    function onTake()
    {
        timeLeft = respawnTime;
        item = null;
    }

    function respawn()
    {
        local itemData = getRandomItem();
        timeLeft = -1; 

        if(itemData)
        {
            item = ItemsGround.create({
                instance = itemData.instanceName,
                amount = itemData.amount,
                physicsEnabled = true,
                position = position,
                world = world
            });
            respawnTime = itemData.respawn;
        }
        else
        {
            timeLeft = 1;
        }
    }
}

addEventHandler("onPlayerTakeItem", function(pid, takenItem) {
    foreach(groundItemInstance in registeredItemsGround)
    {
        if(groundItemInstance.item == takenItem)
        {
            groundItemInstance.onTake();
            break;
        }
    }
});

addEventHandler("onTime", function (day, hour, min) {
    if (hour == 0 && min == 0) return;

    foreach(groundItemInstance in registeredItemsGround)
    {
        if(groundItemInstance.timeLeft == -1)
            continue;
        
        groundItemInstance.timeLeft -= 60;

        if(groundItemInstance.timeLeft <= 0)
            groundItemInstance.respawn();
    }
});

function getRegisteredGroundItems()
{
    return registeredItemsGround;
}