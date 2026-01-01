/**
 * @file CraftController.nut
 * @description Entry point for the crafting module.
 */

include("CraftRepository.nut");
include("CraftService.nut");

CraftRepository <- CraftRepository();
CraftService <- CraftService(CraftRepository, PlayerService);


addEventHandler("onPacket", function(playerid, packet) {
    if (packet.readUInt8() != PacketId.Crafting) return;
    if (packet.readUInt8() != PacketCrafting.RequestCraft) return;

    local resultItemInstance = packet.readString();
    local amount = packet.readInt32();
    
    CraftService.attemptCraft(playerid, resultItemInstance, amount);
});
