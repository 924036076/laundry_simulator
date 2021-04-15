extends Node

signal click
signal add_money

# InteractablePlus signals
signal interactable_broadcasted # sends flavor text from simple clicks

# Customer signals
signal patience_cloud
signal customer_leaving
signal customer_entering
signal new_rating
signal new_customer

# Machine & counter signals
signal laundry_washed
signal laundry_dried
signal laundry_folded
signal laundry_delinted

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
signal folding_anim_completed

# Player signals
signal player_picked_up_laundry

# Card signals
signal customer_card_displayed
signal customer_card_removed

# Store / Store Item signals
signal item_purchased

# Game Logic signals
signal new_inventory
signal money_updated  # when money increases or decreases
signal money_reset # when money is reset; eg with new day / tutorial
signal inventory_updated

# Misc
signal day_over # spawner and clock
signal game_over # only by stars right now
signal new_option # currently just in tutorial logic
signal laundromat_purchased # for upgrades
signal tutorial_started
