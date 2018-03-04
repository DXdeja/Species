class SMainMenuScreenAvsH extends SMainMenuScreen;

var SMenuChoice_Class ClassChoices[2];
var SMenuChoice_Team TeamChoice;
var MenuUISmallLabelWindow InfoLabel;
var MenuUIInfoButtonWindow btnDetails;

function LockToTeam(int team)
{
	TeamChoice.SetValue(team);
	TeamChoice.SetSensitivity(false);
	if (!CBPPlayer(root.parentPawn).bIsAlive) SaveSettings(); // this will force player to have selected team class even if he cancels the procedure
}

function CreateControls()
{
	Super.CreateControls();
	CreateTeamChoice();
	CreateClassChoices();
	CreateInfoLabel();
	UpdateTeams();
	CreateDetailsButton();
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
		root.InvokeMenuScreen(class'AnimVsHumDef'.default.DetailsScreen[ClassChoices[TeamChoice.currentValue].GetPawnOrderNum()]);
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

function CreateTeamChoice()
{
	TeamChoice = SMenuChoice_Team(winClient.NewChild(Class'SMenuChoice_Team'));
	TeamChoice.SetPos(12, 12);
	TeamChoice.SMainScreen = self;
}

function CreateClassChoices()
{
	local int i;

	for (i = 0; i < ArrayCount(ClassChoices); i++)
	{
		ClassChoices[i] = SMenuChoice_Class(winClient.NewChild(class'AnimVsHumDef'.default.TeamMenuChoiceClasses[i]));
		ClassChoices[i].SetPos(12 + i * 170, 44);
		ClassChoices[i].SetSize(153, 213);
		ClassChoices[i].SMainScreen = self;
	}
}

function SaveSettings()
{
	Super.SaveSettings();
	CBPPlayer(Player).PlayerSetPawnType(ClassChoices[TeamChoice.currentValue].GetPawnTypeString());
}

function UpdateTeams()
{
	local int i;

	for (i = 0; i < ArrayCount(ClassChoices); i++)
	{
		if (TeamChoice.currentValue == i)
		{
			ClassChoices[i].SetWSens(true);
		}
		else
			ClassChoices[i].SetWSens(false);
	}

	UpdateText2();
}

function UpdateText(string t)
{
	//InfoLabel.SetText(ClassChoices[TeamChoice.currentValue].GetPawnInfo());
	InfoLabel.SetText(t);
}

function UpdateText2()
{
	InfoLabel.SetText(ClassChoices[TeamChoice.currentValue].GetPawnInfo());
}

defaultproperties
{
     Title="Welcome to Animals Versus Humans!"
}
