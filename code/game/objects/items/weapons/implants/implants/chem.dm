/obj/item/implant/chem
	name = "chemical implant"
	desc = "Injects things."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2)
	known = 1

/obj/item/implant/chem/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
	<b>Life:</b> Deactivates upon death but remains within the body.<BR>
	<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
	will suffer from an increased appetite.</B><BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
	the implant releases the chemicals directly into the blood stream.<BR>
	<b>Special Features:</b>
	<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units.<BR>
	Can only be loaded while still in its original case.<BR>
	<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from prolonged malnutrition,<BR>
	nine or more days without nutrients, the implant may become unstable and either pre-maturely inject the subject or simply break."}

/obj/item/implant/chem/New()
	..()
	create_reagents(50)

/obj/item/implant/chem/activate(var/amount)
	if(malfunction || (!iscarbon(imp_in)))	return 0
	if(!amount)
		amount = rand(1,25)
	var/mob/living/carbon/R = imp_in
	reagents.trans_to_mob(R, amount, CHEM_BLOOD)
	to_chat(R, "<span class='notice'>You hear a faint *beep*.</span>")

/obj/item/implant/chem/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/syringe))
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		else
			if(do_after(user,5,src))
				I.reagents.trans_to_obj(src, 5)
				to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")
	else
		..()

/obj/item/implantcase/chem
	name = "glass case - 'chem'"
	imp = /obj/item/implant/chem
