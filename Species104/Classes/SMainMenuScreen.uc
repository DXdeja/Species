class SMainMenuScreen extends MenuUIScreenWindow
	abstract;

event InitWindow()
{
	Super.InitWindow();
	CBPPlayer(root.parentPawn).bShowDeadHUD = false;
}

function CreateActionButtons()
{
	if (CBPPlayer(root.parentPawn).bIsPlaying) actionButtons[1].text = "Spectate";
	super.CreateActionButtons();
}

function ProcessAction(String actionKey)
{
	if (actionKey == "DISCONNECT")
	{
		Player.ConsoleCommand("disconnect");
	}
	else if (actionKey == "PLAYSPEC")
	{
		if (!CBPPlayer(root.parentPawn).bIsPlaying)
		{
			SaveSettings();
			Player.ConsoleCommand("spectatorplay");
		}
		else
		{
			Player.ConsoleCommand("playerspectate");
			SaveSettings();
		}
		root.PopWindow();
	}
	else if (actionKey == "HELP")
	{
		root.InvokeMenuScreen(class'SHelpScreen');
	}
}

function DestroyWindow()
{
	super.DestroyWindow();
	CBPPlayer(root.parentPawn).bShowDeadHUD = true;
}

function UpdateText(string t)
{
	//InfoLabel.SetText(ClassChoices[TeamChoice.currentValue].GetPawnInfo());
}

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="Play",Key="PLAYSPEC")
     actionButtons(2)=(Action=AB_Other,Text="Disconnect",Key="DISCONNECT")
     actionButtons(3)=(Action=AB_Other,Text="Help",Key="HELP")
     Title="Missing"
     ClientWidth=350
     ClientHeight=405
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     ScreenType=ST_Menu
}
