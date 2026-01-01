
function packetHandler(packet)
{
    local id = packet.readUInt8();
    if(id != PacketId.Other)
        return;

    id = packet.readUInt8();
    switch(id)
    {
        case PacketOther.Notification:
            intimate(packet.readString());
        break;
    }
}
addEventHandler("onPacket", packetHandler)

local intimations = [];
local MAX_RANGE = 2000;
local START_Y = 6000;
local SPACE = 100;
local TICKS = 0;

class intStruct
{
  constructor(text) {
    _draw = Label(100, 6000, text);
    _draw.color = Color(250, 250, 250, 255);
    _ready = false;
    _y = START_Y;
    _opacity = 0;
    _draw.visible = false;
  }

  _opacity = null;
  _y = null;
  _draw = null;
  _ready = null;
}

function intimate(text)
{
  local inap = intStruct(text);
  intimations.append(inap);
}

local function renderHandler()
{
  if (TICKS < getTickCount()) {
    foreach(i, v in intimations) {
      if (intimations.len() > 1) {
        if (i > 0) {
          if ((v._draw.getPosition().y - intimations[i - 1]._draw.getPosition().y) > SPACE) {
            v._ready = true;
            v._draw.visible = true;
          }
        }
        else {
          v._ready = true;
          v._draw.visible = true;
        }
      } else {
        v._ready = true;
        v._draw.visible = true;
      }

      if (v._ready) {
        v._draw.setPosition(v._draw.getPosition().x, v._draw.getPosition().y - 10);

        if (v._draw.getPosition().y < START_Y - MAX_RANGE) {
          intimations.remove(i);
        }

        local calc = (START_Y - v._draw.getPosition().y) / 2;
        local calc1 = ( (v._draw.getPosition().y) - (START_Y - MAX_RANGE) ) / 2;
        if (calc < 255)
          v._draw.color = Color(250, 250, 250, calc);
        else if (calc1 < 255)
          v._draw.color = Color(250, 250, 250, calc1);
        else
          v._draw.color = Color(250, 250, 250, 255);
      }
    }

    TICKS = getTickCount() + 20;
  }
}

local function calcInputPosition()
{
  local dr = Label(0, 0, "X");
  SPACE += dr.height;
  dr = null;
}

addEventHandler("onInit", calcInputPosition);

addEventHandler("onRender", renderHandler);
