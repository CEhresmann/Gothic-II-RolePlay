
local FLY_FORWARD_DISTANCE = 650.0;
local FLY_UP_DISTANCE = 250.0;
local PHASE_FORWARD_DISTANCE = 200.0;

addEventHandler("onPacket", function(pid, packet)
{
    if (packet.bytesUsed < 2) return;
    local mainPacketId = packet.readUInt8();

    if (mainPacketId == PacketId.Admin)
    {
        local adminActionId = packet.readUInt8();
        if (adminActionId == PacketAdmin.Fly)
        {
            handleAdminFly(pid);
        }
        else if (adminActionId == PacketAdmin.Phase)
        {
            handleAdminPhase(pid);
        }
    }
});

function handleAdminFly(pid)
{
    if (!checkPermission(pid, LEVEL.MOD))
    {
        return;
    }
    local playerPos = getPlayerPosition(pid);

    if (playerPos == null)
    {
        return;
    }

    local angle = getPlayerAngle(pid);

    local angleInRadians = angle * (PI / 180.0);
    local newX = playerPos.x + (sin(angleInRadians) * FLY_FORWARD_DISTANCE);
    local newZ = playerPos.z + (cos(angleInRadians) * FLY_FORWARD_DISTANCE);
    local newY = playerPos.y + FLY_UP_DISTANCE;

    setPlayerPosition(pid, newX, newY, newZ);
}


function handleAdminPhase(pid)
{
    if (!checkPermission(pid, LEVEL.MOD))
    {
        return;
    }

    local playerPos = getPlayerPosition(pid);


    if (playerPos == null)
    {
        return;
    }

    local angle = getPlayerAngle(pid);


    local angleInRadians = angle * (PI / 180.0);
    local newX = playerPos.x + (sin(angleInRadians) * PHASE_FORWARD_DISTANCE);
    local newZ = playerPos.z + (cos(angleInRadians) * PHASE_FORWARD_DISTANCE);

    setPlayerPosition(pid, newX, playerPos.y, newZ);
}

