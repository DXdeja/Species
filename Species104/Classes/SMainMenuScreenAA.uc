class SMainMenuScreenAA extends SMainMenuScreen;

var SMenuChoice_Class ClassChoice;
var MenuUISmallLabelWindow InfoLabel;
var MenuUIInfoButtonWindow btnDetails;


function CreateControls()
{
	Super.CreateControls();
	CreateClassChoice();
	CreateInfoLabel();
	CreateDetailsButton();
	UpdateText2();
}

function CreateDetailsButton()
{
	btnDetails = MenuUIInfoButtonWindow(NewChild(Class'MenuUIInfoButtonWindow'));
	btnDetails.SetSelectability(False);
	btnDetails.SetButtonText("View details");
	btnDetails.SetSize(100, 19);
	btnDetails.SetPos(100, 288);
}

function bool ButtonActivated(Window buttonPressed)
{
	if (buttonPressed == btnDetails)
	{
		root.InvokeMenuScreen(class'AnimVsHumDef'.default.DetailsScreen[ClassChoice.GetPawnOrderNum()]);
		return true;
	}
	else return super.ButtonActivated(buttonPressed);
}

function CreateInfoLabel()
{
	InfoLabel = MenuUISmallLabelWindow(winClient.NewChild(Class'MenuUISmallLabelWindow'));
	InfoLabel.SetPos(12, 270);
	InfoLabel.SetWidth(327);
	InfoLabel.SetWordWrap(true);
}

function CreateClassChoice()
{
	ClassChoice = SMenuChoice_Class(winClient.NewChild(class'AnimVsHumDef'.default.TeamMenuChoiceClasses[1]));
	ClassChoice.SetPos(12, 44);
	ClassChoice.SetSize(153, 213);
	ClassChoice.SMainScreen = self;
}

function SaveSettings()
{
	Super.SaveSettings();
	CBPPlayer(Player).PlayerSetPawnType(ClassChoice.GetPawnTypeString());
}

function UpdateText(string t)
{
	InfoLabel.SetText(t);
}

function UpdateText2()
{
	InfoLabel.SetText(ClassChoice.GetPawnInfo());
}

defaultproperties
{
     Title="Welcome to Animals Attack!"
}
