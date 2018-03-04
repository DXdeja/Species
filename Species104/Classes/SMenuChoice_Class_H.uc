class SMenuChoice_Class_H extends SMenuChoice_Class;

event InitWindow()
{
	TeamNumber = class'AnimVsHumDef'.default.HUMAN_TEAM;
	Super.InitWindow();
}

defaultproperties
{
}
