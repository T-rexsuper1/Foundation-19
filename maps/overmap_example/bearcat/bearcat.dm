#include "bearcat_areas.dm"
#include "bearcat_jobs.dm"
#include "bearcat_loadouts.dm"
#include "bearcat-1.dmm"
#include "bearcat-2.dmm"

/obj/effect/overmap/ship/bearcat
	name = "FTV Bearcat"
	color = "#00ffff"
	start_x = 4
	start_y = 4
	base = 1
	vessel_mass = 60
	default_delay = 3 MINUTES
	speed_mod = 0.1 MINUTE
	burn_delay = 10 SECONDS

	generic_waypoints = list("nav_bearcat_below_bow", "nav_bearcat_below_starboardastern", "nav_bearcat_port_dock_shuttle")
	restricted_waypoints = list(
		"Exploration Pod" = list("nav_bearcat_starboard_dock_pod"), //pod can only dock starboard-side, b/c there's only one door.
	)

/obj/machinery/computer/shuttle_control/explore/bearcat
	name = "exploration shuttle console"
	shuttle_tag = "Exploration Shuttle"

/datum/shuttle/autodock/overmap/exploration
	name = "Exploration Shuttle"
	shuttle_area = /area/ship/scrap/shuttle/outgoing
	dock_target = "bearcat_shuttle"
	current_location = "nav_bearcat_port_dock_shuttle"

/datum/shuttle/autodock/ferry/lift
	name = "Cargo Lift"
	shuttle_area = /area/ship/scrap/shuttle/lift
	warmup_time = 3	//give those below some time to get out of the way
	waypoint_station = "nav_bearcat_lift_bottom"
	waypoint_offsite = "nav_bearcat_lift_top"
	sound_takeoff = 'sound/effects/lift_heavy_start.ogg'
	sound_landing = 'sound/effects/lift_heavy_stop.ogg'
	ceiling_type = null
	knockdown = 0

/obj/machinery/computer/shuttle_control/lift
	name = "cargo lift controls"
	shuttle_tag = "Cargo Lift"
	ui_template = "shuttle_control_console_lift.tmpl"
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = 0

//In case multiple shuttles can dock at a location,
//subtypes can be used to hold the shuttle-specific data
/obj/effect/shuttle_landmark/docking_arm_starboard
	name = "Bearcat Starboard-side Docking Arm"
	docking_controller = "bearcat_starboard_dock"

/obj/effect/shuttle_landmark/docking_arm_starboard/pod
	landmark_tag = "nav_bearcat_starboard_dock_pod"

/obj/effect/shuttle_landmark/docking_arm_port
	name = "Bearcat Port-side Docking Arm"
	docking_controller = "bearcat_dock_port"

/obj/effect/shuttle_landmark/docking_arm_port/shuttle
	landmark_tag = "nav_bearcat_port_dock_shuttle"

/obj/effect/shuttle_landmark/lift/top
	name = "Top Deck"
	landmark_tag = "nav_bearcat_lift_top"
	autoset = 1

/obj/effect/shuttle_landmark/lift/bottom
	name = "Lower Deck"
	landmark_tag = "nav_bearcat_lift_bottom"
	base_area = /area/ship/scrap/cargo/lower
	base_turf = /turf/simulated/floor

/obj/effect/shuttle_landmark/below_deck_bow
	name = "Near CSV Bearcat Bow"
	landmark_tag = "nav_bearcat_below_bow"

/obj/effect/shuttle_landmark/below_deck_starboardastern
	name = "Near CSV Bearcat Starboard Astern"
	landmark_tag = "nav_bearcat_below_starboardastern"

/turf/simulated/wall //landlubbers go home
	name = "bulkhead"

/turf/simulated/floor
	name = "bare deck"

/turf/simulated/floor/tiled
	name = "deck"

/decl/flooring/tiling
	name = "deck"

/obj/machinery/door/airlock/autoname/command
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/autoname/engineering
	req_access = list(access_engine)

//wild capitalism
/datum/computer_file/program/merchant
	required_access = null
