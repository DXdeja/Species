class SMainMenuAA extends CBPMainMenu;

function ShowMenu(byte forceteam)
{
	SMainMenuScreen(RootWindow.PushWindow(MenuClass, true));
}

defaultproperties
{
    MenuClass=Class'SMainMenuScreenAA'
}
