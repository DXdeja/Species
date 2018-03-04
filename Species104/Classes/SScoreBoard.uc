class SScoreBoard extends CBPScoreBoard;

function DrawContent(Canvas canvas)
{
	local byte myteam, oppteam;
	local int count;

	ResetHideProperties();

	myteam = PlayerPawn(Owner).PlayerReplicationInfo.Team;
	if (myteam == class'AnimVsHumDef'.default.ANIMAL_TEAM) oppteam = class'AnimVsHumDef'.default.HUMAN_TEAM;
	else oppteam = class'AnimVsHumDef'.default.ANIMAL_TEAM;

	// draw players of own team first
	Properties[1].DisplayName = class'AnimVsHumDef'.default.TeamNames[myteam];
	count = SortPlayerInfos(FillPlayerInfos(false, true, myteam));
	canvas.DrawColor = ColGreen;
	DrawPlayerGroupHeader(canvas, false, count);
	DrawPlayerInfos(canvas, count);

	CurrentYoff += LetterHeight;

	// draw opponent team
	Properties[1].DisplayName = class'AnimVsHumDef'.default.TeamNames[oppteam];
	count = SortPlayerInfos(FillPlayerInfos(false, true, oppteam));
	canvas.DrawColor = ColRed;
	DrawPlayerGroupHeader(canvas, false, count);
	DrawPlayerInfos(canvas, count);

	// draw spectators
	CurrentYoff += LetterHeight;
	SetShowSpectatorProperties();
	count = FillPlayerInfos(true, false);
	canvas.DrawColor = ColWhite;
	DrawPlayerGroupHeader(canvas, true, count);
	DrawPlayerInfos(canvas, count);
}

function FillPropertiesArray(out PlayerInfo pi)
{
	pi.Properties[0] = string(pi.PRI.PlayerID);
	pi.Properties[1] = pi.PRI.PlayerName;
	if (SPlayerReplicationInfo(pi.PRI) != none &&
		SPlayerReplicationInfo(pi.PRI).ClassIndex < ArrayCount(class'AnimVsHumDef'.default.PawnNames))
		pi.Properties[2] = class'AnimVsHumDef'.default.PawnNames[SPlayerReplicationInfo(pi.PRI).ClassIndex];
	else
		pi.Properties[2] = "";
	pi.Properties[3] = string(int(pi.PRI.Score));
	pi.Properties[4] = string(int(pi.PRI.Streak));
	pi.Properties[5] = string(pi.PRI.Ping);
}

function int GetTableYSize()
{
	// pheader1 + pheader_line1 + numplayers + pheader2 + pheader_line2 + space + sheader + sheader_line
	return (GetNumPlayers() + 4) * LetterHeight + 3 * 3;
}

function SetShowSpectatorProperties()
{
	HideProperties[2] = 1; // class
	HideProperties[3] = 1; // score
	HideProperties[4] = 1; // level
}

function string GetWinningString()
{
	local byte wteam;

	wteam = SGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).WonTeam;
	if (wteam == 0 || wteam == 1)
		return class'AnimVsHumDef'.default.TeamNames[wteam] $ " have won the game!";
	else return super.GetWinningString();
}

function DrawFooter(Canvas canvas)
{
	local string str;
	local float w, h;

	CurrentYoff += 2 * LetterHeight;
	str = "Mod: Species, Version: 104f";
	canvas.DrawColor = ColWhite;
	canvas.TextSize(str, w, h);
	canvas.SetPos((canvas.SizeX - w) / 2, CurrentYoff);
	canvas.DrawText(str);

	super.DrawFooter(canvas);
}

defaultproperties
{
     ObjText="Objective: Destroy enemy's object."
     Properties(2)=(Xoff=150,displayName="Class")
     Properties(3)=(Xoff=210,displayName="Score")
     Properties(4)=(Xoff=250,displayName="Level")
     Properties(5)=(Xoff=290,displayName="Ping")
     TableXSize=320
}
