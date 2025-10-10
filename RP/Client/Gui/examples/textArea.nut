local textArea = GUI.TextArea({
    file = "MENU_INGAME.TGA",
    text = "Hello world!",
    sizePx = { width = 250, height = 100 },
    positionPx = { x = 512, y = 512 },

    scrollbar = {
        range = {
            file = "MENU_INGAME.TGA",
            indicator = { file = "BAR_MISC.TGA" }
        }
    },
})


addEventHandler("onInit", function()
{
    textArea.setVisible(true)
    setFreeze(true)
    setCursorVisible(true)
})