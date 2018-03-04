class SHelpScreen extends MenuUIScreenWindow;

var MenuUISmallLabelWindow InfoLabel;

function CreateControls()
{
	Super.CreateControls();
	CreateHelpLabel();
}

function CreateHelpLabel()
{
	InfoLabel = MenuUISmallLabelWindow(winClient.NewChild(Class'MenuUISmallLabelWindow'));
	InfoLabel.SetPos(12, 12);
	InfoLabel.SetSize(326, 381);
	InfoLabel.SetWordWrap(true);
	InfoLabel.SetText(class'AnimVsHumDef'.default.HelpText);
}

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     Title="Help"
     ClientWidth=350
     ClientHeight=405
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     ScreenType=ST_Menu
}
