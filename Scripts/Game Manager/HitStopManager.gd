extends Node

# Define constants for common durations
const SHORT_DURATION = 0.15
const MEDIUM_DURATION = 0.3
const LONG_DURATION = 1.0
const SLOW_MOTION_DURATION = 0.5
const SLOW_MOTION_SCALE = 0.5

func hit_stop(duration: float, time_scale: float = 0):
    Engine.time_scale = time_scale
    await get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1

func hit_stop_short():
    await hit_stop(SHORT_DURATION)

func hit_stop_medium():
    await hit_stop(MEDIUM_DURATION)

func hit_stop_long():
    await hit_stop(LONG_DURATION)

func slow_motion():
    await hit_stop(SLOW_MOTION_DURATION, SLOW_MOTION_SCALE)
    await get_tree().create_timer(SLOW_MOTION_DURATION, true, false, true).timeout
    Engine.time_scale = 1