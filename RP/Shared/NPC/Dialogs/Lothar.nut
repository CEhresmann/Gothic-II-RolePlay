local openerDialog = DialogItem("LOTHARDIALOG");
openerDialog.addMenuDialog("No czeœæ", [
    ["Lothar", "Uciekaj.", "Deklkuuuuuu"],
    ["Ja", "Jak ciek?"],
]);
openerDialog.addMenuDialog("Co ty pierdolisz?", [
    ["Lothar", "Uciekaj.", "Deklkuuuuuu"],
    ["Ja", "Jak ciek?"],
]);

openerDialog = DialogManager.add(openerDialog);
DialogManager.addOpener("Lothar", openerDialog.id);

addEventHandler("onEndDialog", function(dialog, id, name) {
    if(dialog != openerDialog)
        return;

    local dialogsLen = openerDialog.items.len();

    switch(name)
    {
        case "No czeœæ":
            DialogManager.hide();
        break;
    }
})
