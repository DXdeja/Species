class SMenuChoice_Class extends MenuUIChoiceEnum;

var byte TeamNumber;
var int enumNum[40];

//Portrait variables
var ButtonWindow btnPortrait;

var SMainMenuScreen SMainScreen;

event InitWindow()
{
	PopulateClassChoices();
	CreatePortraitButton();

	Super.InitWindow();

	SetInitialClass();

	SetActionButtonWidth(153);
	btnInfo.SetPos(0,195);
}

function PopulateClassChoices()
{
	local int typeIndex;
	local int enumIndex;

	enumIndex = 0;
	for (typeIndex = 0; typeIndex < arrayCount(class'AnimVsHumDef'.default.PawnNames); typeIndex++)
	{
		if (class'AnimVsHumDef'.default.PawnTeams[typeIndex] == TeamNumber)
		{
			enumText[enumIndex] = class'AnimVsHumDef'.default.PawnNames[typeIndex];
			enumNum[enumIndex] = typeIndex;
			enumIndex++;
		}
	}
}

function SetInitialClass()
{
	local int typeIndex;
	local SPlayer locplayer;
	local int enumIndex;

	locplayer = SPlayer(Player);
	if (locplayer != none)
	{
		enumIndex = 0;
		for (typeIndex = 0; typeIndex < arrayCount(class'AnimVsHumDef'.default.PawnNames); typeIndex++)
		{
			if (class'AnimVsHumDef'.default.PawnTeams[typeIndex] == TeamNumber)
			{
				if (locplayer.NextPawnInfo == class'AnimVsHumDef'.default.PawnTypes[typeIndex])
				{
					SetValue(enumIndex);
					return;
				}
				enumIndex++;
			}
		}
	}
	SetValue(0);
}

function SetValue(int newValue)
{
   Super.SetValue(newValue);
   UpdatePortrait();
   if (SMainScreen != none) SMainScreen.UpdateText(class'AnimVsHumDef'.default.PawnText[enumNum[currentValue]]);
}

function LoadSetting()
{
   UpdatePortrait();
}

function CreatePortraitButton()
{
	btnPortrait = ButtonWindow(NewChild(Class'ButtonWindow'));

	btnPortrait.SetSize(116, 163);
	btnPortrait.SetPos(19, 27);

	btnPortrait.SetBackgroundStyle(DSTY_Masked);
}

function UpdatePortrait()
{
   btnPortrait.SetBackground(class'AnimVsHumDef'.default.PawnPortraits[enumNum[CurrentValue]]);
}

function SetWSens(bool sens)
{
	btnPortrait.SetSensitivity(sens);
	btnAction.SetSensitivity(sens);
	btnInfo.SetSensitivity(sens);
	if (sens) btnPortrait.SetTileColorRGB(255, 255, 255);
	else btnPortrait.SetTileColorRGB(40, 40, 40);
	SetSensitivity(sens);
}

function string GetPawnTypeString()
{
	return string(class'AnimVsHumDef'.default.PawnTypes[enumNum[currentValue]]);
}

function string GetPawnInfo()
{
	return class'AnimVsHumDef'.default.PawnText[enumNum[currentValue]];
}

function int GetPawnOrderNum()
{
	return enumNum[currentValue];
}

defaultproperties
{
    defaultInfoWidth=153
    defaultInfoPosX=170
    actionText="Choose character"
}
