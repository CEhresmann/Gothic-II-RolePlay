local desktopName = Label(0, 0, "");
local className = Label(0, 0, "");
local timeDraw = Label(0, 0, "");
local nextTick = getTickCount() + 500;

setHudMode(HUD_HEALTH_BAR, HUD_MODE_HIDDEN);
setHudMode(HUD_MANA_BAR, HUD_MODE_HIDDEN);

local barWidthPercent = 0.15;
local barHeightPercent = 0.02;
local barPosXPercent = 0.015;
local healthBarYPercent = 0.945;
local manaBarYPercent = 0.92;
local borderX = 10;
local borderY = 5;

function createBar(yPercent, fillTexture)
{
    local bgWidth = barWidthPercent * Resolution.x;
    local bgHeight = barHeightPercent * Resolution.y;
    local bgX = barPosXPercent * Resolution.x;
    local bgY = yPercent * Resolution.y;
    local fillWidth = bgWidth - (borderX * 2);
    local fillHeight = bgHeight - (borderY * 2);

    local bgSprite = GUI.Sprite({
        positionPx = { x = bgX, y = bgY },
        sizePx = { width = bgWidth, height = bgHeight },
        file = "BAR_BACK.TGA",
    });

    local fillSprite = GUI.Sprite({
        positionPx = { x = bgX + borderX, y = bgY + borderY },
        sizePx = { width = fillWidth, height = fillHeight },
        file = fillTexture,
    });

    return {
        bg = bgSprite,
        fill = fillSprite,
        fillWidth = fillWidth,
        fillHeight = fillHeight
    };
}

local healthBar = createBar(healthBarYPercent, "BAR_HEALTH.TGA");
local manaBar = createBar(manaBarYPercent, "BAR_MANA.TGA");

addEventHandler("onRender", function()
{
    if(!timeDraw.visible)
        return;

    local tick = getTickCount();
    if (tick >= nextTick)
    {
        desktopName.text = getPlayerName(heroId) + " (" + heroId + ") ";
        local timeDay = date();
        className.text = getPlayerClass(heroId);
        timeDraw.text = timeDay.hour+":"+timeDay.min;
        desktopName.setPositionPx(0.02 * Resolution.x, 0.87 * Resolution.y);
        className.setPositionPx(0.02 * Resolution.x, 0.89 * Resolution.y);
        timeDraw.setPositionPx(0.5 * Resolution.x - timeDraw.widthPx / 2, 0.005 * Resolution.y);	
        nextTick = getTickCount() + 1000;
    }

    if (healthBar.bg.visible)
    {
        local currentHealth = getPlayerHealth(heroId);
        local maxHealth = getPlayerMaxHealth(heroId);
        local currentMana = getPlayerMana(heroId);
        local maxMana = getPlayerMaxMana(heroId);

        local healthPercent = (maxHealth > 0) ? (currentHealth.tofloat() / maxHealth.tofloat()) : 0.0;
        local manaPercent = (maxMana > 0) ? (currentMana.tofloat() / maxMana.tofloat()) : 0.0;

        healthBar.fill.setSizePx(healthBar.fillWidth * healthPercent, healthBar.fillHeight);
        manaBar.fill.setSizePx(manaBar.fillWidth * manaPercent, manaBar.fillHeight);
    }
});

function setDesktopVisual(val)
{
    desktopName.visible = val;
    className.visible = val;
    timeDraw.visible = val;

    healthBar.bg.visible = val;
    healthBar.fill.visible = val;
    manaBar.bg.visible = val;
    manaBar.fill.visible = val;
}

addEventHandler("onGUIClose", function () { setDesktopVisual(true); });
addEventHandler("onGUIOpen", function() { setDesktopVisual(false); });