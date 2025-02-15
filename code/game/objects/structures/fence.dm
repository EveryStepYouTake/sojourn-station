#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define DESTROY_HOLE 3 //time to remove that fence

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/fence.dmi'
	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE
	var/hole_visuals = TRUE //Whether the fence piece has visuals for being cut. Used in update_cut_status()

/obj/structure/fence/Initialize()
	. = ..()

	update_cut_status()

/obj/structure/fence/handrail_end
	name = "handrail"
	desc = "A waist high handrail, perhaps you could climb over it."
	icon_state = "y_handrail_end"
	cuttable = FALSE

/obj/structure/fence/handrail_corner
	name = "handrail"
	desc = "A waist high handrail, perhaps you could climb over it."
	icon_state = "y_handrail_corner"
	cuttable = FALSE
	climbable = TRUE

/obj/structure/fence/handrail
	name = "handrail"
	desc = "A waist high handrail, perhaps you could climb over it."
	icon_state = "y_handrail"
	cuttable= FALSE
	climbable = TRUE

/obj/structure/fence/handrail_end/non_dense
	name = "handrail"
	desc = "A waist high handrail, perhaps you could climb over it."
	icon_state = "y_handrail_end"
	cuttable = FALSE
	density = FALSE
	layer = ABOVE_MOB_LAYER

/obj/structure/fence/examine(mob/user)
	. = ..()
	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/small
	name = "fence"
	desc = "A small metal safety fence."
	icon_state = "small"
	cuttable= FALSE
	climbable = TRUE

/obj/structure/fence/pipe
	name = "pipe"
	desc = "A large rusted pipe."
	icon_state = "pipe"
	cuttable= FALSE
	climbable = TRUE
	density = 1

/obj/structure/fence/end
	icon_state = "end"
	cuttable = TRUE
	hole_visuals = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = TRUE
	hole_visuals = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tool/wirecutters))
		if(!cuttable)
			to_chat(user, SPAN_NOTICE("This section of the fence can't be cut."))
			return
		if(invulnerable)
			to_chat(user, SPAN_NOTICE("This fence is too strong to cut through."))
			return
		var/current_stage = hole_size

		user.visible_message(SPAN_DANGER("\The [user] starts cutting through \the [src] with \the [W]."),\
		SPAN_DANGER("You start cutting through \the [src] with \the [W]."))

		if(do_after(user, src, WORKTIME_LONG, QUALITY_CUTTING))
			if(current_stage == hole_size)
				switch(++hole_size)
					if(MEDIUM_HOLE)
						visible_message(SPAN_NOTICE("\The [user] cuts into \the [src] some more."))
						to_chat(user, "<span class='info'>You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger.</span>")
						climbable = TRUE
					if(LARGE_HOLE)
						visible_message(SPAN_NOTICE("\The [user] completely cuts through \the [src]."))
						to_chat(user, "<span class='info'>The hole in \the [src] is now big enough to walk through.</span>")
						climbable = FALSE
					if(DESTROY_HOLE)
						visible_message(SPAN_NOTICE("\The [user] removes \the [src]."))
						to_chat(user, "<span class='info'>\The [src] is removed.</span>")
						qdel(src)
						new /obj/item/stack/rods(get_turf(src), 4)

				update_cut_status()

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = W
		switch(hole_size)
			if(NO_HOLE)
				to_chat(user, SPAN_WARNING("You cannot repair \the [src] any further!"))
				return
			if(MEDIUM_HOLE)
				if(rods.get_amount() < 2)
					to_chat(user, SPAN_WARNING("You need at least two rods to repair \the [src]!"))
					return
				to_chat(user, SPAN_NOTICE("You start repairing \the [src]..."))
				if(do_after(user, 20, target = src))
					if(rods.get_amount() < 2)
						return
					rods.use(2)
					to_chat(user, SPAN_NOTICE("You completely repair the hole in \the [src]."))
					hole_size = NO_HOLE
			if(LARGE_HOLE)
				if(rods.get_amount() < 2)
					to_chat(user, SPAN_WARNING("You need at least two rods to repair \the [src]!"))
					return
				to_chat(user, SPAN_NOTICE("You start repairing \the [src]..."))
				if(do_after(user, 20, target = src))
					if(rods.get_amount() < 2)
						return
					rods.use(2)
					to_chat(user, SPAN_NOTICE("You repair a bit of the hole in \the [src]."))
					hole_size = MEDIUM_HOLE

		update_cut_status()


	return TRUE

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			if(!hole_visuals) //This is omega-stupid, fix this idiot
				return
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			if(!hole_visuals)
				return
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			if(!hole_visuals)
				return
			icon_state = "straight_cut3"
			density = FALSE

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize()
	. = ..()

	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE
	density = TRUE

/obj/structure/fence/door/attackby(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(can_open(user))
		toggle(user)

	return TRUE

/obj/structure/fence/door/proc/toggle(mob/user)
	switch(open)
		if(FALSE)
			visible_message(SPAN_NOTICE("\The [user] opens \the [src]."))
			open = TRUE
		if(TRUE)
			visible_message(SPAN_NOTICE("\The [user] closes \the [src]."))
			open = FALSE

	update_door_status()
	playsound(src, 'sound/machines/click.ogg', 100, 1)

/obj/structure/fence/door/proc/update_door_status()
	switch(open)
		if(FALSE)
			density = TRUE
			icon_state = "door_closed"
		if(TRUE)
			density = FALSE
			icon_state = "door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

/obj/machinery/door/unpowered/simple/fence
	name = "fence gate"
	desc = "A gate for a fence."
	icon_state = "fence"
	var/opaque = 0
	icon = 'icons/obj/fence.dmi'

#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef DESTROY_HOLE

/obj/structure/fence/wooden
	name = "wooden fence"
	desc = "A fence fashioned out of wood planks. Designed to keep animals in and vagrants out."
	icon = 'icons/obj/fence.dmi'
	icon_state = "straight_wood"
	cuttable = FALSE
	climbable = TRUE

/obj/structure/fence/end/wooden
	icon_state = "end_wood"
	cuttable = FALSE

/obj/structure/fence/corner/wooden
	icon_state = "corner_wood"
	cuttable = FALSE

/obj/machinery/door/unpowered/simple/fence/wooden
	name = "wood fence gate"
	desc = "A wooden gate for a wood fence."
	icon_state = "fence_wood"
	icon = 'icons/obj/fence.dmi'