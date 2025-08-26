
enum PacketId
{
    Language,
    Player,
    Bot,
    WorldBuilder,
    Object,
    Admin,
    Other
}

enum PacketPlayer
{
    LoggIn,
    Register,
    Description,
    SetClass,
    Animation,
    Visual,
    Walk,
    Trade,
    UseItem,
	WalkString
}

enum PacketBot
{
	Start,
    Init,
	Spawn,
	Unspawn,
	Respawn,
	AttackPlayer,
	PlayAnimation,
	SynchronizePlayer,
	SynchronizePosition,
	SynchronizeAngle,
    SynchronizeWeaponMode,
	SynchronizeHealth,
	SynchronizeStreamer,
	SynchronizeAll,
}

enum PacketWorldBuilder
{
    Player,
    Vob,
}

enum PacketObject
{
    Call,
}

enum PacketOther
{
    Notification,
    Draw3D,
    Draw3DRemove,
}

enum PacketAdmin
{
    Grid,
    Path,
    PathWay,
}