class SAnimalsAttack extends SGame;

var int NumBots;

var class<SNPC> NPCClass;

function bool IsValidPawnType(class<PawnType> pt)
{
	local int i;
	for (i = 0; i < ArrayCount(class'AnimVsHumDef'.default.PawnTypes); i++)
		if (class'AnimVsHumDef'.default.PawnTypes[i] == pt && class'AnimVsHumDef'.default.PawnTeams[i] == 1) return true;
	return false;
}

function byte GetPawnTypeTeam(class<PawnType> pt)
{
	return 1;
}

event playerpawn Login(string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local SPlayer sp;

	sp = SPlayer(super.Login(Portal, Options, Error, SpawnClass));
	sp.PlayerReplicationInfo.Team = 1;

	return sp;
}

function bool ChangeTeam(Pawn PawnToChange, int NewTeam)
{
	return true;
}

function NavigationPoint FindStartingPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	return super.FindStartingPlayerStart(Player, 1, incomingName);
}

function Tick(float deltaTime)
{
	local SNPC npc;
	local NavigationPoint StartSpot;
	local SObjectHumans sobj;

	super.Tick(deltaTime);

	// manage bots here
	if (NumBots < 1)
	{
		// spawn new bot

		//StartSpot = FindPlayerStart(none, 0);

		//npc = Spawn(NPCClass, , , StartSpot.Location, StartSpot.Rotation);

		foreach AllActors(class'SObjectHumans', sobj)
		{
			npc = Spawn(NPCClass, , , sobj.Location + vect(0.0, 200.0, 0.0), sobj.Rotation);
			break;
		}

		log("npc spawned: " $ npc);

		npc.InstallPawnType(class'Animal_Greasel');

		NumBots++;
	}
}

DefaultProperties
{
    bTeamBalancer=False
    DefaultPawnType=Class'Human_Soldier'
    MainMenuClass=Class'SMainMenuAA'
    bTeamGame=True
    ScoreBoardType=Class'SScoreBoard'
	NPCClass=class'SNPC'
}
