class SAutoTurret extends CBPAutoTurret;

function SetSafeTarget( Pawn newSafeTarget )
{
	super.SetSafeTarget(newSafeTarget);
	team = CBPPlayer(newSafeTarget).PlayerReplicationInfo.Team;
	bActive = true;
	bDisabled = false;
}

function Tick(float deltaTime)
{
	// if player quits or go to another team or spec mode, kill us
	if (CBPPlayer(Owner) == none || CBPPlayer(Owner).PlayerReplicationInfo.bIsSpectator || (team != -1 && CBPPlayer(Owner).PlayerReplicationInfo.Team != team))
	{
		Destroy();
	}
	else super.Tick(deltaTime);
}

function PreBeginPlay()
{
	local Vector v1, v2;
	local class<AutoTurretGun> gunClass;
	local Rotator rot;

	Super(DeusExDecoration).PreBeginPlay();

	if (gun == none)
	{
		gunClass = class'SAutoTurretGun';
		rot = Rotation;
		rot.Pitch = 0;
		rot.Roll = 0;
		origRot = rot;
		gun = Spawn(gunClass, self,, Location, rot);
		if (gun != None)
		{
			v1.X = 0;
			v1.Y = 0;
			v1.Z = CollisionHeight + gun.Default.CollisionHeight;
			v2 = v1 >> Rotation;
			v2 += Location;
			gun.SetLocation(v2);
			gun.SetBase(Self);
			gun.DesiredRotation = rot;
		}
	}

	bDisabled = !bActive;
}

function ResetScaleGlow()
{
	ScaleGlow = float(HitPoints) / float(Default.HitPoints) * 0.9 + 0.1;
	if (gun != none) gun.ScaleGlow = ScaleGlow;
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float mindmg;

		if (DamageType == 'EMP')
		{
			// duration is based on daamge
			// 10 seconds min to 30 seconds max
			mindmg = Max(Damage - 15.0, 0.0);
			confusionDuration += mindmg / 5.0;
			confusionDuration = FClamp(confusionDuration,10.0,30.0);
			confusionTimer = 0;
			if (!bConfused)
			{
				bConfused = True;
				PlaySound(sound'EMPZap', SLOT_None,,, 1280);
			}
			return;
		}

		TakeDamageX(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}

	function TakeDamageX(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float actdmg;

		if ((DamageType == 'TearGas') || (DamageType == 'PoisonGas') || (DamageType == 'Poison'))
			return;

		if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
			return;

		if (EventInstigator.PlayerReplicationInfo.Team == team)
		{
			actdmg = CBPGame(Level.Game).FriendlyFireMult * Damage;
		}
		else actdmg = Damage;

		HitPoints -= actdmg;

		if (HitPoints > 0)		// darken it to show damage (from 1.0 to 0.1 - don't go completely black)
		{
			ResetScaleGlow();
		}
		else	// destroy it!
		{
			// clear the event to keep Destroyed() from triggering the event
			//Event = '';
			//avg = (CollisionRadius + CollisionHeight) / 2;
			//Frag(fragType, Momentum / 10, avg/20.0, avg/5 + 1);
			Instigator = EventInstigator;

			// if we have been blown up, then destroy our contents
			Contents = None;
			Content2 = None;
			Content3 = None;
			// reward killer with 0.5 points
			SGame(Level.Game).GestureReward(SPlayer(EventInstigator), none, 'TurretKill', 0.5);
			class'SGame'.static.SEF_ObjectExplode(self, HitLocation);
			Destroy();
		}
	}
}

defaultproperties
{
    maxRange=768
    gunDamage=4
    HitPoints=150
    CollisionRadius=12.00
    CollisionHeight=15.00
}
