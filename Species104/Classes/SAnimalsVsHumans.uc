class SAnimalsVsHumans extends SGame;

// empty name fix
// specs see objects health
// joining bug: cant find spawnpoint???
// melee protection shield bug???
// robot taunts
// limit number of characters
// underwater turrets?
// endgame state -> isspectator stays
// if ff off, do not poison screen
// todo: skill lvl0 start?
// todo: fix turret item appearance
// todo: robot walk sound after death?
// todo: spawn intervals?
// todo: taunt menu
// todo: msgs saying if someone healed, gave ammo etc
// todo: draw find ammo, bio, medicine @
// todo: spider aim correction (electricity lock on target)
// targeting % showing more than 100% if health is big...
// engineer better starting weapons
// throw decoration: when already on ground, cant cause damage
// ff burning off
// flame causes big damage on karks
// drawactor for choosing class

function FinishGame(optional int winner)
{
	SGameReplicationInfo(GameReplicationInfo).WonTeam = winner;
	super.FinishGame(winner);
}

function bool IsValidPawnType(class<PawnType> pt)
{
	local int i;
	for (i = 0; i < ArrayCount(class'AnimVsHumDef'.default.PawnTypes); i++)
		if (class'AnimVsHumDef'.default.PawnTypes[i] == pt) return true;
	return false;
}

function byte GetPawnTypeTeam(class<PawnType> pt)
{
	local int i;
	for (i = 0; i < ArrayCount(class'AnimVsHumDef'.default.PawnTypes); i++)
		if (class'AnimVsHumDef'.default.PawnTypes[i] == pt) return class'AnimVsHumDef'.default.PawnTeams[i];
	return 0;
}

event playerpawn Login(string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local SPlayer sp;

	sp = SPlayer(super.Login(Portal, Options, Error, SpawnClass));
	sp.PlayerReplicationInfo.Team = GetPawnTypeTeam(sp.NextPawnInfo);

	return sp;
}

defaultproperties
{
    bTeamBalancer=True
    DefaultPawnType=Class'Animal_Karkian'
    MainMenuClass=Class'SMainMenu'
    bTeamGame=True
    ScoreBoardType=Class'SScoreBoard'
}
