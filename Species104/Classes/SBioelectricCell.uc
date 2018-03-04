class SBioelectricCell extends CBPBioelectricCell;

state Activated
{
	function BeginState()
	{
		local SPlayer player, affected;
		local float edelta;

		Super(CBPPickup).BeginState();

		player = SPlayer(Owner);

		if (player != none && SPlayer(player.FrobTarget) != none &&
			class'CBPGame'.static.ArePlayersAllied(player, SPlayer(Player.FrobTarget)))
		{
			// refill teammates energy
			affected = SPlayer(Player.FrobTarget);
		}
		else affected = player;

		if (affected != none)
		{
			affected.ClientMessage(Sprintf(msgRecharged, rechargeAmount));
	
			affected.PlayLogSound(sound'BioElectricHiss');
			if (affected != player) player.PlayLogSound(sound'BioElectricHiss');

			edelta = affected.EnergyMax - affected.Energy;
			edelta = FClamp(edelta, 0.0, rechargeAmount);
			affected.Energy += rechargeAmount;
			if (affected.Energy > affected.EnergyMax)
				affected.Energy = affected.EnergyMax;

			if (edelta > 0.0 && player != affected)
			{
				if (SGame(Level.Game) != none)
					SGame(Level.Game).GestureReward(player, affected, 'Energy', FClamp(edelta / rechargeAmount, 0.0, 1.0));
			}
		}

		UseOnce();
	}
}

defaultproperties
{
    bCanDrop=False
    bOnlyOwnerSee=True
}
