/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 10
	damage_type = BRUTE
	damage_flags = DAM_BULLET | DAM_SHARP
	embed = TRUE
	penetration_modifier = 1.0
	var/mob_passthrough_check = 0
	var/is_pellet = FALSE

	muzzle_type = /obj/effect/projectile/bullet/muzzle
	miss_sounds = list('sound/weapons/guns/miss1.ogg','sound/weapons/guns/miss2.ogg','sound/weapons/guns/miss3.ogg','sound/weapons/guns/miss4.ogg')
	ricochet_sounds = list('sound/weapons/guns/ricochet1.ogg', 'sound/weapons/guns/ricochet2.ogg',
							'sound/weapons/guns/ricochet3.ogg', 'sound/weapons/guns/ricochet4.ogg')
	impact_sounds = list(BULLET_IMPACT_MEAT = SOUNDS_BULLET_MEAT, BULLET_IMPACT_METAL = SOUNDS_BULLET_METAL)

/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/projectile/bullet/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier)
	if(penetrating > 0 && damage > 20 && prob(damage))
		mob_passthrough_check = 1
	else
		mob_passthrough_check = 0
	. = ..()

	if(. == 1 && iscarbon(target_mob) && !is_pellet)
		damage *= 0.7 //squishy mobs absorb KE

/obj/item/projectile/bullet/can_embed()
	//prevent embedding if the projectile is passing through the mob
	if(mob_passthrough_check)
		return 0
	return ..()

/obj/item/projectile/bullet/check_penetrate(var/atom/A)
	if(QDELETED(A) || !A.density) return 1 //if whatever it was got destroyed when we hit it, then I guess we can just keep going

	if(ismob(A))
		if(!mob_passthrough_check)
			return 0
		return 1

	var/chance = damage
	if(has_extension(A, /datum/extension/penetration))
		var/datum/extension/penetration/P = get_extension(A, /datum/extension/penetration)
		chance = P.PenetrationProbability(chance, damage, damage_type)

	if(prob(chance))
		if(A.opacity)
			//display a message so that people on the other side aren't so confused
			A.visible_message("<span class='warning'>\The [src] pierces through \the [A]!</span>")
		return 1

	return 0

//For projectiles that actually represent clouds of projectiles
/obj/item/projectile/bullet/pellet
	name = "shrapnel" //'shrapnel' sounds more dangerous (i.e. cooler) than 'pellet'
	damage = 37.5
	//icon_state = "bullet" //TODO: would be nice to have it's own icon state
	var/pellets = 4			//number of pellets
	var/range_step = 2		//projectile will lose a fragment each time it travels this distance. Can be a non-integer.
	var/base_spread = 90	//lower means the pellets spread more across body parts. If zero then this is considered a shrapnel explosion instead of a shrapnel cone
	var/spread_step = 10	//higher means the pellets spread more across body parts with distance
	is_pellet = TRUE

/obj/item/projectile/bullet/pellet/Bumped()
	. = ..()
	bumped = 0 //can hit all mobs in a tile. pellets is decremented inside attack_mob so this should be fine.

/obj/item/projectile/bullet/pellet/proc/get_pellets(var/distance)
	/// pellets lost due to distance
	var/pellet_loss = round(max(distance - 1, 0)/range_step)
	return max(pellets - pellet_loss, 1)

/obj/item/projectile/bullet/pellet/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier)
	if (pellets < 0) return 1

	var/total_pellets = get_pellets(distance)
	var/spread = max(base_spread - (spread_step*distance), 0)

	//shrapnel explosions miss prone mobs with a chance that increases with distance
	var/prone_chance = 0
	if(!base_spread)
		prone_chance = max(spread_step*(distance - 2), 0)

	var/hits = 0
	for (var/i in 1 to total_pellets)
		if(target_mob.lying && target_mob != original && prob(prone_chance))
			continue

		//pellet hits spread out across different zones, but 'aim at' the targeted zone with higher probability
		//whether the pellet actually hits the def_zone or a different zone should still be determined by the parent using get_zone_with_miss_chance().
		var/old_zone = def_zone
		def_zone = ran_zone(def_zone, spread)
		if (..()) hits++
		def_zone = old_zone //restore the original zone the projectile was aimed at

	pellets -= hits //each hit reduces the number of pellets left
	if (hits >= total_pellets || pellets <= 0)
		return 1
	return 0

/obj/item/projectile/bullet/pellet/get_structure_damage()
	var/distance = get_dist(loc, starting)
	return ..() * get_pellets(distance)

/obj/item/projectile/bullet/pellet/Move()
	. = ..()

	//If this is a shrapnel explosion, allow mobs that are prone to get hit, too
	if(. && !base_spread && isturf(loc))
		for(var/mob/living/M in loc)
			if(M.lying || !M.CanPass(src, loc, 0.5, 0)) //Bump if lying or if we would normally Bump.
				if(Bump(M)) //Bump will make sure we don't hit a mob multiple times
					return

/* short-casing projectiles, like the kind used in pistols or SMGs */

/obj/item/projectile/bullet/pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	damage = 20 //9mm, .38, etc
	armor_penetration = 5
	agony = 8
	embed = 0

/obj/item/projectile/bullet/pistol/holdout
	damage = 15
	penetration_modifier = 1.2
	distance_falloff = 4

/obj/item/projectile/bullet/pistol/holdout/rubber
	agony = 20

/obj/item/projectile/bullet/pistol/medium
	damage = 25 //.45
	armor_penetration = 8
	agony = 16
	embed = 0

/obj/item/projectile/bullet/pistol/rubber //"rubber" bullets
	name = "rubber bullet"
	damage = 2
	armor_penetration = 2
	agony = 35
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/pistol/medium/smg
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	damage = 25 //10mm/5.7x28
	armor_penetration = 30
	agony = 10
	embed = 0

/obj/item/projectile/bullet/pistol/medium/smg/rubber
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	damage = 0.4 //10mm rubber
	armor_penetration = 8
	agony = 35
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/pistol/medium/smg/hollowpoint
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	damage = 25 //10mm hollowpoint
	armor_penetration = 5
	agony = 20
	embed = 1

/obj/item/projectile/bullet/pistol/medium/smg/ap
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	damage = 20 //10mm AP
	armor_penetration = 70
	agony = 10
	embed = 0

/obj/item/projectile/bullet/pistol/medium/smg/silver
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	damage = 25 //10mm but i have no idea what bimmer wanted for classifaction, so i made it just better normal ammo
	armor_penetration = 30
	agony = 10
	embed = 0

/obj/item/projectile/bullet/pistol/medium/revolver
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 55 //.44 magnum or something
	armor_penetration = 15
	agony = 25
	embed = 0

/obj/item/projectile/bullet/pistol/strong //matebas
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 65 //.50AE
	armor_penetration = 15
	agony = 35
	embed = 1

/obj/item/projectile/bullet/pistol/vstrong //tacrevolver
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 70 //.500 S&W Magnum
	armor_penetration = 40
	agony = 50
	embed = 1

/obj/item/projectile/bullet/pistol/strong/revolver //revolvers
	damage = 50 //Revolvers get snowflake bullets, to keep them relevant
	armor_penetration = 30
	agony = 40
	embed = 0

/obj/item/projectile/bullet/flechette
	fire_sound = 'sound/weapons/gunshot/gunshot_4mm.ogg'
	damage = 23
	penetrating = 1
	armor_penetration = 70
	embed = FALSE
	distance_falloff = 2

/* shotgun projectiles */

/obj/item/projectile/bullet/shotgun
	name = "slug"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 60
	armor_penetration = 24
	agony = 40
	embed = 0

/obj/item/projectile/bullet/shotgun/beanbag		//because beanbags are not bullets
	name = "beanbag"
	damage = 25
	agony = 60
	embed = 0
	sharp = 0

//Should do about 80 damage at 1 tile distance (adjacent), and 50 damage at 3 tiles distance.
//Overall less damage than slugs in exchange for more damage at very close range and more embedding
/obj/item/projectile/bullet/pellet/shotgun
	name = "shrapnel"
	icon_state = "pellet"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 30
	pellets = 6
	range_step = 1
	spread_step = 50

/obj/item/projectile/bullet/pellet/shotgun/flechette
	name = "flechette"
	icon_state = "flechette"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 30
	armor_penetration = 25
	pellets = 3
	range_step = 3
	base_spread = 99
	spread_step = 2
	penetration_modifier = 0.5
	hitchance_mod = 5

/* "Rifle" rounds */

/obj/item/projectile/bullet/rifle
	armor_penetration = 25
	penetrating = 1
	agony = 35
	embed = 0

/obj/item/projectile/bullet/rifle/military
	fire_sound = 'sound/weapons/gunshot/gunshot2.ogg'
	damage = 40
	armor_penetration = 35
	penetration_modifier = 1

/obj/item/projectile/bullet/rifle/shell
	fire_sound = 'sound/weapons/gunshot/sniper.ogg'
	damage = 80
	stun = 3
	weaken = 3
	penetrating = 3
	armor_penetration = 70
	penetration_modifier = 1.2
	distance_falloff = 0.5

/obj/item/projectile/bullet/rifle/shell/apds
	damage = 70
	penetrating = 5
	armor_penetration = 80
	penetration_modifier = 1.5

/obj/item/projectile/bullet/rifle/a556
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'
	damage = 50
	armor_penetration = 35
	agony = 25
	embed = 0

/obj/item/projectile/bullet/rifle/a762
	fire_sound = 'sound/weapons/gunshot/gunshot2.ogg'
	damage = 60
	armor_penetration = 40
	agony = 35
	embed = 0

/obj/item/projectile/bullet/rifle/a145
	fire_sound = 'sound/weapons/gunshot/sniper.ogg'
	damage = 120
	stun = 3
	weaken = 3
	penetrating = 5
	armor_penetration = 100
	hitscan = 1 //so the PTR isn't useless as a sniper weapon
	penetration_modifier = 1.25
	embed = 0

/obj/item/projectile/bullet/rifle/a145/apds
	damage = 100
	penetrating = 6
	armor_penetration = 120
	penetration_modifier = 1.5
	agony = 100
	embed = 0


/* Miscellaneous */

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 25
	damage_type = OXY
	agony = 20
	embed = 0

/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 45
	damage_type = TOX
	agony = 20
	embed = 0

/obj/item/projectile/bullet/burstbullet
	name = "exploding bullet"
	damage = 25
	embed = 0
	edge = 1
	agony = 20

/obj/item/projectile/bullet/gyro
	fire_sound = 'sound/effects/Explosion1.ogg'

/obj/item/projectile/bullet/gyro/on_hit(var/atom/target, var/blocked = 0)
	if(isturf(target))
		explosion(target, -1, 0, 2)
	..()

/obj/item/projectile/bullet/blank
	invisibility = 101
	damage = 1
	embed = 0

/* Practice */

/obj/item/projectile/bullet/pistol/practice
	damage = 5

/obj/item/projectile/bullet/rifle/military/practice
	damage = 5

/obj/item/projectile/bullet/rifle/a762/practice
	damage = 5

/obj/item/projectile/bullet/shotgun/practice
	name = "practice"
	damage = 5

/obj/item/projectile/bullet/pistol/cap
	name = "cap"
	invisibility = 101
	fire_sound = null
	damage_type = PAIN
	damage = 0
	nodamage = 1
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/pistol/cap/Process()
	loc = null
	qdel(src)

/obj/item/projectile/bullet/rock //spess dust
	name = "micrometeor"
	icon_state = "rock"
	damage = 40
	armor_penetration = 25

/obj/item/projectile/bullet/rock/New()
	icon_state = "rock[rand(1,3)]"
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	..()
