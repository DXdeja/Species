class SPlayerReplicationInfo extends CBPPlayerReplicationInfo;

var byte ClassIndex;

replication
{
	reliable if (Role == ROLE_Authority)
		ClassIndex;
}

defaultproperties
{
    ClassIndex=255
}
