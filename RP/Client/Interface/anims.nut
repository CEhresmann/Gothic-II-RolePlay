choiceAnimation <- false;

gridAnim <- /*GUI.Table(0,2440,1800,4800, "MENU_INGAME.TGA", letterHeightPx(), "INV_SLOT.TGA", "INV_TITEL.TGA", "O.TGA", "U.TGA")*/ GUI.Table({
	positionPx = {x = 0, y = 2440}
	sizePx = {width = 1800, height = 4800}
	marginPx = {top = 35, left = 35}
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
	//collection = window
})
//gridAnim.setMarginPx(35,35,35,35)

animNameColumn <- /*gridAnim.addColumn("***", anx(280), Align.Center)*/ gridAnim.addColumn({
	widthPx = anx(280)
	align = Align.Center
	file = "MENU_INGAME.TGA"
	draw = {text = "***"}
})
animNameColumn.draw.setColor({r = 145, g = 175, b = 205})

function animationPanel(toggle){
    if(toggle && Player.gui != -1)
        return;

	choiceAnimation = toggle;

	if(toggle) 
		foreach(anim in CFG.Anims) gridAnim.addRow(_L(anim.name));
	else
		for (local i = 0;i <= gridAnim.rows.len(); i ++) gridAnim.removeRow(i);

	if(!toggle)
		try { for (local i = 0;i <= gridAnim.rows.len(); i ++) gridAnim.removeRow(i); } catch (error) {};

    Interface.baseInterface(toggle,toggle ? PLAYER_GUI.ANIMATION : -1);
	gridAnim.setVisible(toggle);
}

addEventHandler("GUI.onClick", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListCell))
		return

	playAni(heroId, CFG.Anims[self.parent.id].inst);
});

addEventHandler("GUI.onMouseIn", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListCell))
		return

  	self.setColor({r = 255, g = 0, b = 0});
  	self.setFile("Menu_Choice_Back.TGA");
});

addEventHandler("GUI.onMouseOut", function(self){
	if(!choiceAnimation)
		return

	if (!(self instanceof GUI.GridListCell))
		return

	self.setColor({r = 255, g = 255, b = 255});
	self.setFile("");
});

addEventHandler("onKeyDown", function(key){
	if(key == KEY_F10)
		animationPanel(!choiceAnimation)
});

