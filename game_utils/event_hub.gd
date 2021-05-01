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
signal new_review

# Lawyer Cat signals
signal lawyer_cat_created
signal lawyer_cat_messaged

# Machine & counter signals
signal laundry_washed
signal laundry_dried
signal laundry_folded
signal laundry_delinted

# Cat signals
signal occupy_object
signal leave_object
signal cat_cuddled
signal cuddles_stopped
signal mauling_started
signal mauling_ended

# Toy signals
signal toy_released
signal toy_destroyed
signal toy_bounced_on_body

# HUD signals
signal new_game
signal new_day

# Laundry Times signals
signal laundry_times_closed
signal laundry_times_clicked # from interactable_laundry_times

# Options signals
signal restart

# Laundry signals
signal folding_anim_completed

# Player signals
signal player_picked_up_laundry
signal test_signal

# Card signals
signal customer_card_displayed
signal customer_card_removed

# Store / Store Item signals
signal item_purchased
signal new_item_viewed

# Consumable signals
signal consumable_used

# Game Logic signals
signal new_inventory
signal money_updated  # when money increases or decreases
signal money_reset # when money is reset; eg with new day / tutorial
signal inventory_updated
signal laundry_times_unlocked

# Misc
signal day_over # spawner and clock
signal game_over # only by stars right now
signal new_option # currently just in tutorial logic
signal laundromat_purchased # for upgrades
signal tutorial_started
