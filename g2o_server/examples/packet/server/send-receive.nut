addEventHandler("onPlayerCommand", function(pid, cmd, arg)
{
	if (cmd != "hello_from_server")
		return

	// create instance of Packet class
	local packet = Packet()

	// write packet unique id
	// This id comes from shared/packet-id.nut script
	// NOTE! the order in which data is being written/read inside packet matters
	packet.writeUInt8(PacketId.MESSAGE)

	// write example string
	packet.writeString("Hello message sent from server!")

	// send packet to the player that joined the server
	// RELIABLE constant passed as argument to the method call..
	// makes sure that packet will get eventually to the client,
	// and the order in which the packet will be received in onPacket event isn't guaranteed.
	packet.send(pid, RELIABLE)
})

addEventHandler("onPacket", function(pid, packet)
{
	// read unique packet id
	local packetId = packet.readUInt8()

	// if the packet id doesn't match => stop code execution
	if (packetId != PacketId.MESSAGE)
		return

	// read message
	local message = packet.readString()

	// print message in server console
	print(message)
})