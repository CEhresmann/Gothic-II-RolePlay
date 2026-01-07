local vob = null

addEventHandler("onInit", function()
{
	// create instance of Vob class with visual set to skull
	vob = Vob("SKULL.3DS")

	// add vob to current world
	vob.addToWorld()
})

addEventHandler("onPacket", function(packet)
{
	// read unique packet id
	local packetId = packet.readUInt8()

	// if the packet id doesn't match => stop code execution
	if (packetId != PacketId.LERP)
		return

	// read lerp pos
	local x = packet.readFloat()
	local y = packet.readFloat()
	local z = packet.readFloat()

	// update vob position
	vob.setPosition(x, y, z)
})