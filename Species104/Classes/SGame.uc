class SGame extends CBPGame
	abstract;

function bool IsValidPawnType(class<PawnType> pt)
{
	return true;
}

function byte GetPawnTypeTeam(class<PawnType> pt)
{
	return 0;
}

function Killed( pawn Killer, pawn Other, name damageType )
{
	local SPlayer otherPlayer;
	local Pawn CurPawn;

	if (bGameEnded) return; // just return

	// Record the death no matter what, and reset the streak counter
	if ( Other.bIsPlayer )
	{
		otherPlayer = SPlayer(Other);

		Other.PlayerReplicationInfo.Deaths += 1;
		Other.PlayerReplicationInfo.Streak = 0;
		// Penalize the player that commits suicide by losing a kill, but don't take them below zero
		if ((Killer == Other) || (Killer == None))
		{
			if ( Other.PlayerReplicationInfo.Score > 0 )
			{
				if (( DeusExProjectile(otherPlayer.myProjKiller) != None ) && DeusExProjectile(otherPlayer.myProjKiller).bAggressiveExploded )
				{
					// Don't dock them if it nano exploded in their face
				}
				else
					Other.PlayerReplicationInfo.Score -= 1;
			}
		}
	}

	if (Killer == none)
    {
        // deadly fall
        Killer = Other;
    }

   //both players...
   if ((Killer.bIsPlayer) && (Other.bIsPlayer))
   {
 	    //Add to console log as well (with pri id) so that kick/kickban can work better
 	    log(Killer.PlayerReplicationInfo.PlayerName$"("$Killer.PlayerReplicationInfo.PlayerID$") killed "$Other.PlayerReplicationInfo.PlayerName $ otherPlayer.killProfile.methodStr);
		for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
		{
			if ((CurPawn.IsA('DeusExPlayer')) && (DeusExPlayer(CurPawn).bAdmin))
				DeusExPlayer(CurPawn).LocalLog(Killer.PlayerReplicationInfo.PlayerName$"("$Killer.PlayerReplicationInfo.PlayerID$") killed "$Other.PlayerReplicationInfo.PlayerName $ otherPlayer.killProfile.methodStr);
		}

		if ( otherPlayer.KilledMethod ~= "None" )
			BroadcastMessage(Killer.PlayerReplicationInfo.PlayerName$" killed "$Other.PlayerReplicationInfo.PlayerName$".",false,'DeathMessage');
		else
			BroadcastMessage(Killer.PlayerReplicationInfo.PlayerName$" killed "$Other.PlayerReplicationInfo.PlayerName $ otherPlayer.KilledMethod, false, 'DeathMessage');

		if (Killer != Other)
		{
			// Penalize for killing your teammates
			if (class'CBPGame'.static.ArePlayersAllied(DeusExPlayer(Other),DeusExPlayer(Killer)))
			{
				if ( Killer.PlayerReplicationInfo.Score > 0 )
					Killer.PlayerReplicationInfo.Score -= 1;
				DeusExPlayer(Killer).MultiplayerNotifyMsg( DeusExPlayer(Killer).MPMSG_KilledTeammate, 0, "" );
			}
			else
			{
				GestureReward(SPlayer(Killer), SPlayer(Other), 'Kill', SPlayer(Killer).PawnInfo.default.KillReward);
				// Grant the kill to the killer, and increase his streak
				//Killer.PlayerReplicationInfo.Score += ScorePerKill;

				//KillReward(CBPPlayer(Killer), CBPPlayer(Other));
				//Killer.PlayerReplicationInfo.Streak = SPlayer(Killer).XPLevel;
			}
		}
   }
   else
   {
   		super(DeusExGameInfo).Killed(Killer,Other,damageType);
   }

   BaseMutator.ScoreKill(Killer, Other);
}

//function KillReward(CBPPlayer player, CBPPlayer other)
//{
//	class'PT_Shared'.static.KillReward(SPlayer(player), SPlayer(other));
//}

function GestureReward(SPlayer performer, SPlayer affected, name gesture_type, float amount)
{
	//super.GestureReward(performer, affected, gesture_type, amount);
	//Log("GESTURE REWARD: " $ performer $ ", " $ affected $ ", " $ gesture_type $ ", " $ amount);
	class'PT_Shared'.static.GestureReward(performer, affected, gesture_type, amount);
}

static function SEF_ObjectExplode(Actor owner, Vector HitLocation)
{
	local SPlayer curplayer;

	foreach owner.AllActors(class'SPlayer', curplayer)
	{
		if (curplayer.LineOfSightTo(owner, true) || 
			(Pawn(curplayer.ViewTarget) != none && Pawn(curplayer.ViewTarget).LineOfSightTo(owner, true))) 
			curplayer.SEF_ObjectExplode(owner, HitLocation);
	}
}

function float EvaluatePlayerStart(Pawn Player, PlayerStart PointToEvaluate, optional byte InTeam)
{
   local bool bTooClose;
   local Pawn OtherPawn;
   local Pawn CurPawn;
   local float Dist;
   local float Cost;
   local float CumulativeDist;

   bTooClose = False;

   //DEUS_EX AMSD Small random factor.
   CumulativeDist = FRand();

   for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
   {
      OtherPawn = CurPawn;
      if ((OtherPawn != None) && (OtherPawn != Player))
      {
         //Get Dist
         Dist = VSize(OtherPawn.Location - PointToEvaluate.Location);

         //Do a quick distance check
         if (Dist < 110.0)
         {
            bTooClose = TRUE;
         }

         //Make it non zero
         Dist = Dist + 0.1;
         Cost = 0;

         if (dist < 200)
            cost = 300;
         else if (dist < 400)
            cost = 250;
         else if (dist < 800)
            cost = 175;
         else if (dist < 1600)
            cost = 100;
         else if (dist < 3200)
            cost = 25;
         else
            cost = 0;

		 CumulativeDist = CumulativeDist - Cost;
      }
   }

   if (bTooClose)
   {
      return -100000;
   }
   else
   {
      return CumulativeDist;
   }
}

function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest;
   local PlayerStart BestDest;
   local float BestWeight;
   local float CurWeight;

   BestWeight = -100001;
   BestDest = None;

   foreach AllActors( class 'PlayerStart', Dest )
   {
	  if (Dest.TeamNumber == InTeam ||
	  	(Player != none && Dest.TeamNumber == Player.PlayerReplicationInfo.Team))
	  {
		 if (BestDest == none) BestDest = Dest;
		 CurWeight = EvaluatePlayerStart(Player, Dest, InTeam);
         if (CurWeight > BestWeight)
         {
            BestDest = Dest;
            BestWeight = CurWeight;
         }
      }
   }

   return BestDest;
}

function NavigationPoint FindStartingPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest;

	foreach AllActors( class 'PlayerStart', Dest )
	{
	  if (Dest.TeamNumber == 2) return Dest;
	}

	log("Warning: Map has no spectator starting point set!");

	if (InTeam != 0 && InTeam != 1) InTeam = 0;

    return FindPlayerStart(Player, InTeam, incomingName);
}

defaultproperties
{
    DefaultPlayerClass=Class'SPlayer'
    GameReplicationInfoClass=Class'SGameReplicationInfo'
}
