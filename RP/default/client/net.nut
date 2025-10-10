/////////////////////////////////////////
///	Network statistics class
/////////////////////////////////////////

NetStats <- {
	_title = Label(anx(5), any(5), "Network debug"),
	_ping = null,
	_fps = null,
	_receivedPackets = null,
	_lostPackets = null,
	_lostLastSec = null,
	_messageResend = null,
	_byteToResend = null,
	_messageSend = null,
	_byteToSend = null,

	visible = false
}

function NetStats::init()
{
	local x = anx(5)
	local y = any(7)
	local height = _title.heightPx

	_ping = Label(x, y + any(height), "")
	_fps = Label(x, y + any(height * 2), "")
	_receivedPackets = Label(x, y + any(height * 3), "")
	_lostPackets = Label(x, y + any(height * 4), "")
	_lostLastSec = Label(x, y + any(height * 5), "")
	_messageResend = Label(x, y + any(height * 6), "")
	_byteToResend = Label(x, y + any(height * 7), "")
	_messageSend = Label(x, y + any(height * 8), "")
	_byteToSend = Label(x, y + any(height * 9), "")

	setTimer(function()
	{
		if (visible)
			NetStats.update()
	}, 500, 0)
}

function NetStats::setVisible(visible)
{
	this.visible = visible

	if (visible)
		NetStats.update()

	_title.visible = visible
	_ping.visible = visible
	_fps.visible = visible
	_receivedPackets.visible = visible
	_lostPackets.visible = visible
	_lostLastSec.visible = visible
	_messageResend.visible = visible
	_byteToResend.visible = visible
	_messageSend.visible = visible
	_byteToSend.visible = visible
}

function NetStats::update()
{
	local stats = getNetworkStats()

	_ping.text = format("Ping: %i ms", getPlayerPing(heroId))
	_fps.text = format("FPS: %i", getFpsRate())
	_receivedPackets.text = format("Received packets: %i", stats.packetReceived)
	_lostPackets.text = format("Lost packets: %i", stats.packetlossTotal)
	_lostLastSec.text = format("Lost packet last second: %i", stats.packetlossLastSecond)
	_messageResend.text = format("Message to resend: %i", stats.messagesInResendBuffer)
	_byteToResend.text = format("Message to send: %i", stats.messageInSendBuffer)
	_messageSend.text = format("Bytes to resend: %i", stats.bytesInResendBuffer)
	_byteToSend.text = format("Bytes to send: %i", stats.bytesInSendBuffer)
}

/////////////////////////////////////////
///	Events
/////////////////////////////////////////

addEventHandler("onInit", function()
{
	NetStats.init()
})

addEventHandler("onKeyDown", function(key)
{	
	switch (key)
	{
		case KEY_F6:
			if (!isKeyToggled(key))
				return

			if (!chatInputIsOpen())
				NetStats.setVisible(!NetStats.visible)
			break
	}
})
