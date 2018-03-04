class SMenuChoice_Class_A extends SMenuChoice_Class;

event InitWindow()
{
	TeamNumber = class'AnimVsHumDef'.default.ANIMAL_TEAM;
	Super.InitWindow();
}

defaultproperties
{
}
