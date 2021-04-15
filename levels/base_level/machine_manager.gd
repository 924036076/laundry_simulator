extends YSort


class MachineSorter:
  static func sort_descending_levels(a, b):
    return a["params"]["level"] > b["params"]["level"]


func copy_dict(d: Dictionary) -> Dictionary:
  var copy := {}
  for k in d:
    copy[k] = d[k]
  return copy


func sort_machines(owned:Dictionary) -> Array:
  var items := []
  for key in owned:
    var item := copy_dict(owned[key])
    item["id"] = key
    item.erase("amount")
    for _i in range(owned[key]["amount"]):
      items.append(item)
  items.sort_custom(MachineSorter, "sort_descending_levels")
  return items


func _ready() -> void:
  _refresh_machines()
  EventHub.connect("inventory_updated", self, "_on_inventory_updated")


func _refresh_machines() -> void:
  var owned_machines := GameLogic.get_player_machines()
  var groups := ["washers", "dryers", "counters", "linters"]
  for g in groups:
    var machines := get_tree().get_nodes_in_group(g)
    var sorted_owned := sort_machines(owned_machines[g])
    var num_machines_to_slot = min(len(machines), len(sorted_owned))
    for i in range(num_machines_to_slot):
      machines[i].show()
      machines[i].load_state(sorted_owned[i])
    for i in range(num_machines_to_slot, len(machines)):
      machines[i].hide()


func _on_inventory_updated() -> void:
  # TODO: check if the change affects us before trying to refresh the machines
  _refresh_machines()


