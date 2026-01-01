choiceAnimation <- false;

gridAnim <- GUI.GridList({
	positionPx = {x = 0.10 * Resolution.x, y = 0.30 * Resolution.y}
    sizePx = {width = 0.20 * Resolution.x, height = 0.50 * Resolution.y}
	marginPx = {top = 35, left = 25, right = 30}
	rowHeightPx = letterHeightPx()
	rowSpacingPx = 5
	file = "MENU_INGAME.TGA"
	scrollbar = {
		range = {
			file = "MENU_INGAME.TGA"
			indicator = {file = "BAR_MISC.TGA"}
		}
		increaseButton = {file = "U.TGA"}
		decreaseButton = {file = "O.TGA"}
	}
})


animNameColumn <- gridAnim.addColumn({
	widthPx = anx(200)
	align = Align.Center
	file = "Menu_Choice_Back.TGA"
	label = {text = "test"}
})


function animationPanel(toggle){
    if(toggle && Player.gui != -1)
        return;

    choiceAnimation = toggle;

    gridAnim.clear();

    if(toggle) {
        foreach(anim in CFG.Anims) {
            gridAnim.addRow({
                text = _L(anim.name),
                file = "Menu_Choice_Back.TGA"
            });
        }
    }

    Interface.baseInterface(toggle,toggle ? PLAYER_GUI.ANIMATION : -1);
    gridAnim.setVisible(toggle);
}

addEventHandler("GUI.onClick", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListVisibleCell))
		return

	playAni(heroId, CFG.Anims[self.parent.id].inst);
});


addEventHandler("GUI.onMouseIn", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListVisibleCell))
		return

  	self.setColor({r = 255, g = 0, b = 0});
});

addEventHandler("GUI.onMouseOut", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListVisibleCell))
		return

	self.setColor({r = 255, g = 255, b = 255});
});

addEventHandler("onKeyDown", function(key){
	if(key == KEY_F10)
		animationPanel(!choiceAnimation)
});
