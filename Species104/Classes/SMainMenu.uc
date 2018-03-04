class SMainMenu extends CBPMainMenu;

function ShowMenu(byte forceteam)
{
	local SMainMenuScreenAvsH smain;

	PlayerOwner.ConsoleCommand("FLUSH");
	smain = SMainMenuScreenAvsH(RootWindow.PushWindow(MenuClass, true));
	if (forceteam == 0 || forceteam == 1) smain.LockToTeam(forceteam);
}

defaultproperties
{
    MenuClass=Class'SMainMenuScreenAvsH'
}
