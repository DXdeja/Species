class SGameReplicationInfo extends CBPGameReplicationInfo;

var byte WonTeam;

replication
{
	reliable if ( Role == ROLE_Authority )
		WonTeam;
}

defaultproperties
{
    WonTeam=255
}
