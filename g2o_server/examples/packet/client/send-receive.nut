addEventHandler("onCommand", function(cmd, arg)
{
	if (cmd != "hello_from_client")
		return

	// create instance of Packet class
	local packet = Packet()

	// write packet unique id
	// This id comes from shared/packet-id.nut script
	// NOTE! the order in which data is being written/read inside packet matters
	packet.writeUInt8(PacketId.MESSAGE)

	// write example string
	packet.writeString("Hello message sent from client!")

	// send packet to the server
	// RELIABLE constant passed as argument to the method call..
	// makes sure that packet will get eventually to the server,
	// and the order in which the packet will be received in onPacket event isn't guaranteed.
	packet.send(RELIABLE)
})

addEventHandler("onPacket", function(packet)
{
	// read unique packet id
	local packetId = packet.readUInt8()

	// if the packet id doesn't match => stop code execution
	if (packetId != PacketId.MESSAGE)
		return

	// read message
	local message = packet.readString()

	// print message in client console
	print(message)
})