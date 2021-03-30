extends Node

signal click
signal add_money

# Customer signals
signal patience_cloud
signal customer_leaving
signal customer_entering
signal new_rating

# Emote signals
signal good_review
signal bad_review
signal very_bad_review

# Cat signals
signal occupy_object
signal leave_object
signal cat_cuddled
signal cuddles_stopped
signal play_started
signal play_ended

# Toy signals
signal toy_released
signal toy_destroyed
signal toy_bounced_on_body

# HUD signals 
signal new_game
signal new_day

# Options signals
signal restart

# Laundry signals
signal laundry_folded

# Misc
signal day_over # spawner and clock
signal game_over # only by stars right now
