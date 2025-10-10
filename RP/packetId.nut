enum PacketId {
    Language,
    Player,
    Bot,
    WorldBuilder,
    Object,
    Admin,
    Crafting,
    Profession,
    Other
}

enum PacketPlayer {
    LoggIn,
    Register,
    Description,
    SetClass,
    Animation,
    Visual,
    Walk,
    Trade,
    UseItem,
    EquipUpdate,
    WalkString,
    Fatness,
    Scale,
    UpdateLP,
    UpgradeSkill,
    RequestStatsUpdate,
    UpdateStats,
    RequestSkillCost,
    UpdateSkillCost,
    UpgradeProfession,
    UpdateProfessions,
    RequestProfessionCost,
    UpdateProfessionCost
}

enum SkillType {
    Health,
    Mana,
    Strength,
    Dexterity,
    OneHanded,
    TwoHanded,
    Bow,
    Crossbow,
    MagicCircle
}

enum PacketBot {
    PlaySound,
}

enum PacketWorldBuilder {
    Player,
    Vob,
    VobRemove
}
enum PacketObject {
    Call,
}
enum PacketOther {
    Notification,
    Draw3D,
    Draw3DRemove,
    LootBody,
    TakeAllLoot,
    TakeLootItem,
    LootData,
    ChatMessage
}
enum TradePacketType {
    REQUEST,
    RESPONSE,
    DIRECT_RESPONSE
}
enum PacketAdmin {
    Grid,
    Path,
    PathWay,
    Fly,
    Phase,
    GodMode
}

enum VobType {
    Static,
    Interactive,
    Door
}

enum PacketCrafting {
    RequestCraft
}

enum ChatPacketType {
    ToggleChatModeRequest,
    UpdateChatModeResponse,
    DisplayMultiColorChatMessage,
    NewMessageNotify
}
function writeChatPacket(packet, p) {
    p.writeUInt8(packet.type);
    switch (packet.type) {
        case ChatPacketType.ToggleChatModeRequest:
            break;
        case ChatPacketType.UpdateChatModeResponse:
            p.writeString(packet.mode);
            break;
        case ChatPacketType.DisplayMultiColorChatMessage:
            p.writeString(packet.mode);
            p.writeString(packet.prefix);
            p.writeInt32(packet.prefixColor.r);
            p.writeInt32(packet.prefixColor.g);
            p.writeInt32(packet.prefixColor.b);
            p.writeString(packet.content);
            p.writeInt32(packet.contentColor.r);
            p.writeInt32(packet.contentColor.g);
            p.writeInt32(packet.contentColor.b);
            break;
        case ChatPacketType.NewMessageNotify:
            p.writeString(packet.mode);
            break;
    }
}
function readChatPacket(p) {
    local packetType = p.readUInt8();
    local packet = { type = packetType };
    switch (packetType) {
        case ChatPacketType.ToggleChatModeRequest:
            break;
        case ChatPacketType.UpdateChatModeResponse:
            packet.mode <- p.readString();
            break;
        case ChatPacketType.DisplayMultiColorChatMessage:
            packet.mode <- p.readString();
            packet.prefix <- p.readString();
            packet.prefixColor <- {
                r = p.readInt32(),
                g = p.readInt32(),
                b = p.readInt32()
            };
            packet.content <- p.readString();
            packet.contentColor <- {
                r = p.readInt32(),
                g = p.readInt32(),
                b = p.readInt32()
            };
            break;
        case ChatPacketType.NewMessageNotify:
            packet.mode <- p.readString();
            break;
        default:
            throw "Unknown chat packet type: " + packetType;
    }
    return packet;
}
function createToggleChatModeRequest() {
    return { type = ChatPacketType.ToggleChatModeRequest };
}
function createUpdateChatModeResponse(mode) {
    return {
        type = ChatPacketType.UpdateChatModeResponse,
        mode = mode
    };
}
function createDisplayMultiColorChatMessage(mode, prefix, prefixColor, content, contentColor) {
    return {
        type = ChatPacketType.DisplayMultiColorChatMessage,
        mode = mode,
        prefix = prefix,
        prefixColor = prefixColor,
        content = content,
        contentColor = contentColor
    };
}
function createNewMessageNotify(mode) {
    return {
        type = ChatPacketType.NewMessageNotify,
        mode = mode
    };
}