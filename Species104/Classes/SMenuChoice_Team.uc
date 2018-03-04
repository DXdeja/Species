class SMenuChoice_Team extends MenuUIChoiceEnum;

var SMainMenuScreen SMainScreen;

event InitWindow()
{
	PopulateTeams();
	Super.InitWindow();
	SetInitialTeam();
	SetActionButtonWidth(153);
}

function PopulateTeams()
{
	local int typeIndex;

	for (typeIndex = 0; typeIndex < arrayCount(class'AnimVsHumDef'.default.TeamNames); typeIndex++)
	{
		enumText[typeIndex] = class'AnimVsHumDef'.default.TeamNames[typeIndex];
	}
}

function SetInitialTeam()
{
	SetValue(Player.PlayerReplicationInfo.Team);
}

function LoadSetting()
{
	SetInitialTeam();
}

function SetValue(int newval)
{
	super.SetValue(newval);
	if (SMainMenuScreenAvsH(SMainScreen) != none) SMainMenuScreenAvsH(SMainScreen).UpdateTeams();
}

defaultproperties
{
    defaultInfoWidth=153
    defaultInfoPosX=170
    actionText="Selected team: "
}
