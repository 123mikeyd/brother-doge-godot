extends Node2D

const VERSION := "v0.1-smart-path"
const WIDTH := 960.0
const HEIGHT := 540.0
const HEADER_H := 54.0
const SAVE_PATH := "user://brother_doge_save.json"
const ARENA := Rect2(24, HEADER_H + 18, WIDTH - 48, HEIGHT - HEADER_H - 42)

var breed_data := {
	"classic": {"name": "Classic Doge", "hp": 120.0, "speed": 265.0, "fire_rate": 0.58, "damage": 18.0, "color": Color(0.95, 0.72, 0.28), "tagline": "Balanced bark, sturdy paws."},
	"brother": {"name": "Brother Doge", "hp": 145.0, "speed": 238.0, "fire_rate": 0.64, "damage": 22.0, "color": Color(1.0, 0.82, 0.32), "tagline": "Tankier HODL energy."},
	"zoomie": {"name": "Zoomie Doge", "hp": 90.0, "speed": 330.0, "fire_rate": 0.48, "damage": 14.0, "color": Color(0.50, 0.95, 1.0), "tagline": "Fast, fragile, lots of bark."},
}
var selected_breed := "classic"

var state := "title"
var player := {
	"pos": Vector2(480, 300),
	"vel": Vector2.ZERO,
	"hp": 120.0,
	"max_hp": 120.0,
	"speed": 265.0,
	"radius": 20.0,
	"regen": 0.0,
	"magnet": 135.0,
}
var enemies: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var xp_drops: Array[Dictionary] = []
var telegraphs: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var popups: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var fire_timer := 0.0
var fire_rate := 0.58
var projectile_damage := 18.0
var run_time := 0.0
var wave_time := 60.0
var spawn_timer := 0.0
var level := 1
var xp := 0
var xp_needed := 8
var coins := 0
var kills := 0
var wave := 1
var best_stats := {"best_wave": 0, "best_kills": 0, "best_coins": 0, "runs": 0, "last_breed": "classic", "discovered_upgrades": []}
var shop_options: Array[String] = []
var reroll_cost := 2
var message := "Press Space to start Brother Doge Godot v0.1. Q quits."
var upgrades := {
	"rapid_bark": {"name": "Rapid Bark", "desc": "Fire 28% faster.", "category": "weapon"},
	"strong_bark": {"name": "Strong Bark", "desc": "Projectiles hit harder.", "category": "weapon"},
	"zoomies": {"name": "Zoomies", "desc": "Move faster.", "category": "movement"},
	"thick_fur": {"name": "Thick Fur", "desc": "+25 max HP and heal 25.", "category": "defense"},
	"treat_magnet": {"name": "Treat Magnet", "desc": "XP pickups pull from farther away.", "category": "economy"},
	"paper_resistance": {"name": "Paper Resistance", "desc": "Regenerate HP slowly.", "category": "defense"},
}

func _ready() -> void:
	rng.seed = 42069
	load_progress()
	if breed_data.has(str(best_stats.get("last_breed", "classic"))):
		selected_breed = str(best_stats.get("last_breed", "classic"))
	_apply_breed_stats()
	queue_redraw()

func select_breed(breed_id: String) -> void:
	if not breed_data.has(breed_id):
		return
	selected_breed = breed_id
	_apply_breed_stats()
	message = "%s selected. %s" % [breed_data[selected_breed].name, breed_data[selected_breed].tagline]
	queue_redraw()

func _apply_breed_stats() -> void:
	var data: Dictionary = breed_data[selected_breed]
	player.max_hp = data.hp
	player.hp = min(player.hp, player.max_hp) if player.hp > 0 else player.max_hp
	player.speed = data.speed
	player.regen = 0.0
	player.magnet = 135.0
	fire_rate = data.fire_rate
	projectile_damage = data.damage

func start_run() -> void:
	state = "playing"
	best_stats.runs = int(best_stats.get("runs", 0)) + 1
	best_stats.last_breed = selected_breed
	save_progress()
	player.pos = Vector2(480, 300)
	player.vel = Vector2.ZERO
	player.hp = player.max_hp
	enemies.clear()
	projectiles.clear()
	xp_drops.clear()
	telegraphs.clear()
	particles.clear()
	popups.clear()
	_apply_breed_stats()
	fire_timer = 0.1
	run_time = 0.0
	spawn_timer = 0.6
	level = 1
	xp = 0
	xp_needed = 8
	coins = 0
	kills = 0
	wave = 1
	shop_options.clear()
	message = "Wave 1: survive the Wicked Paper Hands."
	queue_redraw()

func spawn_enemy(pos: Vector2, kind := "paper_hand") -> void:
	var hp := 34.0
	var speed := 78.0
	var radius := 18.0
	var color := Color(0.92, 0.92, 0.82)
	if kind == "diamond_hand":
		hp = 75.0; speed = 48.0; radius = 23.0; color = Color(0.45, 0.9, 1.0)
	elif kind == "runner_hand":
		hp = 18.0; speed = 142.0; radius = 15.0; color = Color(1.0, 0.95, 0.42)
	elif kind == "tank_hand":
		hp = 125.0; speed = 34.0; radius = 28.0; color = Color(0.65, 0.65, 0.75)
	elif kind == "splitter_hand":
		hp = 42.0; speed = 68.0; radius = 20.0; color = Color(0.90, 0.55, 1.0)
	elif kind == "paper_boss":
		hp = 420.0; speed = 34.0; radius = 42.0; color = Color(1.0, 0.42, 0.22)
	enemies.append({"pos": pos, "kind": kind, "hp": hp, "max_hp": hp, "speed": speed, "radius": radius, "color": color, "hit_flash": 0.0, "attack_timer": 2.0})

func spawn_boss() -> void:
	spawn_enemy(Vector2(ARENA.end.x - 90, ARENA.position.y + 95), "paper_boss")
	message = "Boss Hand incoming. Watch the red telegraphs."

func choose_enemy_kind() -> String:
	var roll := rng.randf()
	if wave >= 5 and roll < 0.12:
		return "splitter_hand"
	if wave >= 4 and roll < 0.22:
		return "tank_hand"
	if wave >= 2 and roll < 0.38:
		return "runner_hand"
	if run_time > 32 and roll < 0.56:
		return "diamond_hand"
	return "paper_hand"

func add_boss_telegraph(center: Vector2, radius := 70.0, delay := 1.1, damage := 28.0) -> void:
	telegraphs.append({"pos": center, "radius": radius, "delay": delay, "timer": delay, "damage": damage})

func defeat_enemy_kind(kind: String) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if enemies[i].kind == kind:
			var pos: Vector2 = enemies[i].pos
			enemies.remove_at(i)
			if kind == "splitter_hand":
				spawn_enemy(pos + Vector2(-18, -8), "runner_hand")
				spawn_enemy(pos + Vector2(18, 8), "runner_hand")
			return

func spawn_xp(pos: Vector2, amount := 1) -> void:
	xp_drops.append({"pos": pos, "amount": amount, "t": 0.0})

func force_level_up() -> void:
	state = "upgrade"
	message = "Choose an upgrade: 1 Rapid Bark, 2 Strong Bark, 3 Zoomies."
	queue_redraw()

func _apply_upgrade(kind: String) -> String:
	_mark_upgrade_discovered(kind)
	if kind == "rapid_bark":
		fire_rate *= 0.72
		return "Rapid Bark learned. Much bark."
	elif kind == "strong_bark":
		projectile_damage += 10.0
		return "Strong Bark learned. Paper fears you."
	elif kind == "zoomies":
		player.speed += 45.0
		return "Zoomies learned."
	elif kind == "thick_fur":
		player.max_hp += 25.0
		player.hp = min(player.max_hp, player.hp + 25.0)
		return "Thick Fur learned. More HODL."
	elif kind == "treat_magnet":
		player.magnet += 80.0
		return "Treat Magnet learned. XP comes closer."
	elif kind == "paper_resistance":
		player.regen += 1.2
		return "Paper Resistance learned. Slow regen online."
	return "No upgrade applied."

func _mark_upgrade_discovered(kind: String) -> void:
	var discovered: Array = best_stats.get("discovered_upgrades", [])
	if not discovered.has(kind):
		discovered.append(kind)
	best_stats.discovered_upgrades = discovered
	save_progress()

func choose_upgrade(kind: String) -> void:
	message = _apply_upgrade(kind)
	state = "playing"
	queue_redraw()

func open_shop() -> void:
	_record_progress()
	state = "shop"
	enemies.clear()
	projectiles.clear()
	xp_drops.clear()
	shop_options = _roll_shop_options()
	coins += max(1, int(kills / 6))
	message = "Wave %d clear. Choose a shop upgrade: 1/2/3." % wave
	queue_redraw()

func _roll_shop_options() -> Array[String]:
	var pool: Array = upgrades.keys()
	pool.shuffle()
	var result: Array[String] = []
	for id in pool:
		result.append(str(id))
		if result.size() >= 3:
			break
	return result

func reroll_shop() -> bool:
	if state != "shop":
		return false
	if coins < reroll_cost:
		message = "Need %d coins to reroll." % reroll_cost
		return false
	coins -= reroll_cost
	shop_options = _roll_shop_options()
	message = "Shop rerolled. Choose 1/2/3."
	queue_redraw()
	return true

func choose_shop_option(choice) -> void:
	var index := 0
	if typeof(choice) == TYPE_STRING:
		index = shop_options.find(choice)
	else:
		index = int(choice) - 1
	if index < 0 or index >= shop_options.size():
		return
	var picked := shop_options[index]
	message = _apply_upgrade(picked)
	wave += 1
	run_time = 0.0
	spawn_timer = 0.55
	shop_options.clear()
	state = "playing"
	message += " Wave %d begins." % wave
	queue_redraw()

func get_debug_state() -> Dictionary:
	return {
		"version": VERSION,
		"state": state,
		"selected_breed": selected_breed,
		"breed_name": breed_data[selected_breed].name,
		"player_hp": player.hp,
		"player_max_hp": player.max_hp,
		"player_speed": player.speed,
		"player_regen": player.regen,
		"player_magnet": player.magnet,
		"enemies": enemies.size(),
		"runner_hands": _count_enemies("runner_hand"),
		"tank_hands": _count_enemies("tank_hand"),
		"splitter_hands": _count_enemies("splitter_hand"),
		"bosses": _count_enemies("paper_boss"),
		"telegraphs": telegraphs.size(),
		"projectiles": projectiles.size(),
		"xp_drops": xp_drops.size(),
		"fire_rate": fire_rate,
		"damage": projectile_damage,
		"level": level,
		"xp": xp,
		"kills": kills,
		"coins": coins,
		"wave": wave,
		"shop_options": shop_options.duplicate(),
		"best_wave": int(best_stats.get("best_wave", 0)),
		"best_kills": int(best_stats.get("best_kills", 0)),
		"best_coins": int(best_stats.get("best_coins", 0)),
		"runs": int(best_stats.get("runs", 0)),
	}

func _count_enemies(kind: String) -> int:
	var count := 0
	for e in enemies:
		if e.kind == kind:
			count += 1
	return count

func _record_progress() -> void:
	best_stats.best_wave = max(int(best_stats.get("best_wave", 0)), wave)
	best_stats.best_kills = max(int(best_stats.get("best_kills", 0)), kills)
	best_stats.best_coins = max(int(best_stats.get("best_coins", 0)), coins)
	best_stats.last_breed = selected_breed
	save_progress()

func save_progress() -> void:
	var data := {
		"best_wave": int(best_stats.get("best_wave", 0)),
		"best_kills": int(best_stats.get("best_kills", 0)),
		"best_coins": int(best_stats.get("best_coins", 0)),
		"runs": int(best_stats.get("runs", 0)),
		"discovered_upgrades": best_stats.get("discovered_upgrades", []),
		"last_breed": str(best_stats.get("last_breed", selected_breed)),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))
		f.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		best_stats.best_wave = int(parsed.get("best_wave", 0))
		best_stats.best_kills = int(parsed.get("best_kills", 0))
		best_stats.best_coins = int(parsed.get("best_coins", 0))
		best_stats.runs = int(parsed.get("runs", 0))
		best_stats.discovered_upgrades = parsed.get("discovered_upgrades", [])
		best_stats.last_breed = str(parsed.get("last_breed", "classic"))

func reset_progress() -> void:
	best_stats = {"best_wave": 0, "best_kills": 0, "best_coins": 0, "runs": 0, "last_breed": selected_breed, "discovered_upgrades": []}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			get_tree().quit()
		elif event.keycode == KEY_R:
			start_run()
		elif state == "title" and event.keycode == KEY_1:
			select_breed("classic")
		elif state == "title" and event.keycode == KEY_2:
			select_breed("brother")
		elif state == "title" and event.keycode == KEY_3:
			select_breed("zoomie")
		elif event.keycode == KEY_SPACE and state != "playing":
			if state == "upgrade":
				choose_upgrade("rapid_bark")
			elif state == "shop":
				choose_shop_option(1)
			else:
				start_run()
		elif state == "shop":
			if event.keycode == KEY_1: choose_shop_option(1)
			elif event.keycode == KEY_2: choose_shop_option(2)
			elif event.keycode == KEY_3: choose_shop_option(3)
			elif event.keycode == KEY_E: reroll_shop()
		elif state == "upgrade":
			if event.keycode == KEY_1: choose_upgrade("rapid_bark")
			elif event.keycode == KEY_2: choose_upgrade("strong_bark")
			elif event.keycode == KEY_3: choose_upgrade("zoomies")

func _process(delta: float) -> void:
	_update_particles(delta)
	_update_popups(delta)
	if state != "playing":
		queue_redraw()
		return
	run_time += delta
	if player.regen > 0.0:
		player.hp = min(player.max_hp, player.hp + player.regen * delta)
	_update_player(delta)
	_update_weapon(delta)
	_update_projectiles(delta)
	_update_spawning(delta)
	_update_enemies(delta)
	_update_telegraphs(delta)
	_update_xp(delta)
	_check_collisions()
	if run_time >= wave_time:
		_record_progress()
		open_shop()
	if player.hp <= 0:
		_record_progress()
		state = "game_over"
		message = "Brother Doge got folded by paper hands. Press R."
	queue_redraw()

func _update_player(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target: Vector2 = input_vector * player.speed
	player.vel = player.vel.move_toward(target, 1100.0 * delta)
	player.pos += player.vel * delta
	player.pos.x = clamp(player.pos.x, ARENA.position.x + player.radius, ARENA.end.x - player.radius)
	player.pos.y = clamp(player.pos.y, ARENA.position.y + player.radius, ARENA.end.y - player.radius)

func _update_weapon(delta: float) -> void:
	fire_timer -= delta
	if fire_timer > 0:
		return
	fire_timer = fire_rate
	var target := _nearest_enemy()
	if target.is_empty():
		return
	var dir: Vector2 = (target.pos - player.pos).normalized()
	projectiles.append({"pos": player.pos + dir * 26.0, "vel": dir * 480.0, "damage": projectile_damage, "life": 1.4})
	_add_particles(player.pos + dir * 26.0, Color(1.0, 0.78, 0.2), 3)

func _nearest_enemy() -> Dictionary:
	var best := {}
	var best_d := INF
	for e in enemies:
		var d: float = player.pos.distance_squared_to(e.pos)
		if d < best_d:
			best_d = d
			best = e
	return best

func _update_projectiles(delta: float) -> void:
	for p in projectiles:
		p.pos += p.vel * delta
		p.life -= delta
	for i in range(projectiles.size() - 1, -1, -1):
		if projectiles[i].life <= 0 or not ARENA.grow(80).has_point(projectiles[i].pos):
			projectiles.remove_at(i)

func _update_spawning(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0:
		return
	spawn_timer = max(0.35, 1.1 - run_time * 0.012 - float(wave - 1) * 0.08)
	var side := rng.randi_range(0, 3)
	var pos := Vector2.ZERO
	if side == 0: pos = Vector2(ARENA.position.x, rng.randf_range(ARENA.position.y, ARENA.end.y))
	elif side == 1: pos = Vector2(ARENA.end.x, rng.randf_range(ARENA.position.y, ARENA.end.y))
	elif side == 2: pos = Vector2(rng.randf_range(ARENA.position.x, ARENA.end.x), ARENA.position.y)
	else: pos = Vector2(rng.randf_range(ARENA.position.x, ARENA.end.x), ARENA.end.y)
	if wave >= 3 and run_time > 18.0 and _count_enemies("paper_boss") == 0:
		spawn_boss()
		spawn_timer = 2.5
		return
	spawn_enemy(pos, choose_enemy_kind())

func _update_enemies(delta: float) -> void:
	for e in enemies:
		e.hit_flash = max(0.0, e.hit_flash - delta)
		if e.kind == "paper_boss":
			e.attack_timer -= delta
			if e.attack_timer <= 0.0:
				e.attack_timer = 2.4
				add_boss_telegraph(player.pos, 76.0, 1.05, 32.0)
			var anchor := Vector2(ARENA.end.x - 120, ARENA.position.y + 115)
			e.pos = e.pos.move_toward(anchor, e.speed * delta)
		else:
			var dir: Vector2 = (player.pos - e.pos).normalized()
			var wiggle := Vector2.ZERO
			if e.kind == "runner_hand":
				wiggle = Vector2(-dir.y, dir.x) * sin(Time.get_ticks_msec() / 90.0 + e.pos.x) * 28.0
			e.pos += (dir * e.speed + wiggle) * delta

func _update_telegraphs(delta: float) -> void:
	for t in telegraphs:
		t.timer -= delta
	for i in range(telegraphs.size() - 1, -1, -1):
		if telegraphs[i].timer <= 0.0:
			if player.pos.distance_to(telegraphs[i].pos) <= telegraphs[i].radius:
				player.hp -= telegraphs[i].damage
				_add_popup(player.pos + Vector2(-26, -40), "BOSS HIT", Color(1.0, 0.25, 0.12))
			_add_particles(telegraphs[i].pos, Color(1.0, 0.18, 0.08), 20)
			telegraphs.remove_at(i)

func _update_xp(delta: float) -> void:
	for drop in xp_drops:
		drop.t += delta
		if drop.pos.distance_to(player.pos) < player.magnet:
			drop.pos = drop.pos.move_toward(player.pos, 240.0 * delta)

func _check_collisions() -> void:
	for pi in range(projectiles.size() - 1, -1, -1):
		var hit := false
		for ei in range(enemies.size() - 1, -1, -1):
			if projectiles[pi].pos.distance_to(enemies[ei].pos) < enemies[ei].radius + 5:
				enemies[ei].hp -= projectiles[pi].damage
				enemies[ei].hit_flash = 0.08
				_add_particles(projectiles[pi].pos, enemies[ei].color, 5)
				if enemies[ei].hp <= 0:
					var killed_kind: String = enemies[ei].kind
					var death_pos: Vector2 = enemies[ei].pos
					kills += 1
					coins += 3 if killed_kind == "paper_boss" else 1
					var xp_amount := 8 if killed_kind == "paper_boss" else (2 if killed_kind == "diamond_hand" or killed_kind == "tank_hand" else 1)
					spawn_xp(death_pos, xp_amount)
					if killed_kind == "splitter_hand":
						spawn_enemy(death_pos + Vector2(-18, -8), "runner_hand")
						spawn_enemy(death_pos + Vector2(18, 8), "runner_hand")
					_add_popup(death_pos, "+1", Color(1.0, 0.78, 0.22))
					enemies.remove_at(ei)
				hit = true
				break
		if hit:
			projectiles.remove_at(pi)
	for e in enemies:
		if player.pos.distance_to(e.pos) < player.radius + e.radius:
			player.hp -= 18.0 / 60.0
	for xi in range(xp_drops.size() - 1, -1, -1):
		if player.pos.distance_to(xp_drops[xi].pos) < player.radius + 12:
			xp += xp_drops[xi].amount
			xp_drops.remove_at(xi)
			if xp >= xp_needed:
				xp -= xp_needed
				level += 1
				xp_needed += 5
				force_level_up()
				break

func _add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"pos": pos, "vel": Vector2(rng.randf_range(-80, 80), rng.randf_range(-80, 80)), "life": rng.randf_range(0.15, 0.35), "max_life": 0.35, "color": color})

func _update_particles(delta: float) -> void:
	for p in particles:
		p.pos += p.vel * delta
		p.life -= delta
	for i in range(particles.size() - 1, -1, -1):
		if particles[i].life <= 0:
			particles.remove_at(i)

func _add_popup(pos: Vector2, text: String, color: Color) -> void:
	popups.append({"pos": pos, "text": text, "color": color, "life": 0.9})

func _update_popups(delta: float) -> void:
	for p in popups:
		p.pos.y -= 25.0 * delta
		p.life -= delta
	for i in range(popups.size() - 1, -1, -1):
		if popups[i].life <= 0:
			popups.remove_at(i)

func _draw() -> void:
	_draw_background()
	_draw_entities()
	_draw_hud()
	if state == "title": _draw_title()
	elif state == "upgrade": _draw_upgrade()
	elif state == "shop": _draw_shop()
	elif state == "game_over" or state == "victory": _draw_end()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(WIDTH, HEIGHT)), Color(0.045, 0.035, 0.08))
	draw_rect(ARENA, Color(0.07, 0.065, 0.13), true)
	draw_rect(ARENA, Color(1.0, 0.78, 0.2, 0.65), false, 3)
	for x in range(int(ARENA.position.x), int(ARENA.end.x), 48):
		draw_line(Vector2(x, ARENA.position.y), Vector2(x, ARENA.end.y), Color(0.12, 0.10, 0.18), 1)
	for y in range(int(ARENA.position.y), int(ARENA.end.y), 48):
		draw_line(Vector2(ARENA.position.x, y), Vector2(ARENA.end.x, y), Color(0.12, 0.10, 0.18), 1)

func _draw_entities() -> void:
	for t in telegraphs:
		var progress: float = clamp(1.0 - (t.timer / t.delay), 0.0, 1.0)
		draw_circle(t.pos, t.radius, Color(1.0, 0.08, 0.04, 0.12 + 0.18 * progress))
		draw_arc(t.pos, t.radius, 0, TAU, 48, Color(1.0, 0.18, 0.08, 0.85), 4)
		draw_string(ThemeDB.fallback_font, t.pos + Vector2(-28, 6), "DANGER", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.35, 0.18))
	for drop in xp_drops:
		draw_circle(drop.pos, 8 + sin(drop.t * 6.0) * 2.0, Color(0.25, 0.85, 1.0))
	for p in projectiles:
		draw_circle(p.pos, 6, Color(1.0, 0.78, 0.22))
	for e in enemies:
		var c: Color = Color(1, 1, 1) if e.hit_flash > 0 else e.color
		if e.kind == "paper_boss":
			draw_circle(e.pos, e.radius, c)
			draw_rect(Rect2(e.pos + Vector2(-34, -10), Vector2(68, 20)), Color(0.36, 0.12, 0.07))
			draw_string(ThemeDB.fallback_font, e.pos + Vector2(-28, 6), "BOSS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.9, 0.7))
			var hp_w := 84.0 * float(e.hp) / float(e.max_hp)
			draw_rect(Rect2(e.pos.x - 42, e.pos.y - e.radius - 18, hp_w, 6), Color(1.0, 0.25, 0.12))
		elif e.kind == "diamond_hand":
			var pts := PackedVector2Array([e.pos + Vector2(0, -e.radius), e.pos + Vector2(e.radius, 0), e.pos + Vector2(0, e.radius), e.pos + Vector2(-e.radius, 0)])
			draw_colored_polygon(pts, c)
		elif e.kind == "runner_hand":
			var pts := PackedVector2Array([e.pos + Vector2(0, -e.radius), e.pos + Vector2(e.radius + 10, 0), e.pos + Vector2(0, e.radius), e.pos + Vector2(-e.radius, 0)])
			draw_colored_polygon(pts, c)
		elif e.kind == "tank_hand":
			draw_rect(Rect2(e.pos - Vector2(e.radius, e.radius), Vector2(e.radius * 2, e.radius * 2)), c, true)
			draw_rect(Rect2(e.pos - Vector2(e.radius, e.radius), Vector2(e.radius * 2, e.radius * 2)), Color(0.2, 0.2, 0.25), false, 3)
		elif e.kind == "splitter_hand":
			draw_circle(e.pos, e.radius, c)
			draw_line(e.pos + Vector2(-e.radius, -e.radius), e.pos + Vector2(e.radius, e.radius), Color(0.25, 0.05, 0.25), 3)
			draw_line(e.pos + Vector2(e.radius, -e.radius), e.pos + Vector2(-e.radius, e.radius), Color(0.25, 0.05, 0.25), 3)
		else:
			draw_circle(e.pos, e.radius, c)
			draw_rect(Rect2(e.pos + Vector2(-10, -4), Vector2(20, 8)), Color(0.25, 0.21, 0.18))
	for p in particles:
		var c: Color = p.color
		c.a = clamp(p.life / p.max_life, 0.0, 1.0)
		draw_circle(p.pos, 3, c)
	for p in popups:
		var c: Color = p.color
		c.a = clamp(p.life, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, p.pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, c)
	_draw_player()

func _draw_player() -> void:
	var body_color: Color = breed_data[selected_breed].color
	draw_circle(player.pos, player.radius, body_color)
	draw_circle(player.pos + Vector2(7, -8), 5, Color(1.0, 0.96, 0.78))
	draw_circle(player.pos + Vector2(-8, -14), 7, Color(0.55, 0.32, 0.12))
	draw_circle(player.pos + Vector2(8, -14), 7, Color(0.55, 0.32, 0.12))
	draw_string(ThemeDB.fallback_font, player.pos + Vector2(-18, 38), "DOGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.88, 0.35))

func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEADER_H), Color(0, 0, 0, 0.72))
	draw_string(ThemeDB.fallback_font, Vector2(18, 34), "HODL OR DIE: Brother Doge Godot v0.1", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.78, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(390, 34), "%s  HP %.0f  W%d  LV %d  XP %d/%d  Kills %d  %.0fs" % [breed_data[selected_breed].name, player.hp, wave, level, xp, xp_needed, kills, max(0, wave_time - run_time)], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.9, 0.95, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(18, HEIGHT - 16), message + "  WASD/Arrows move. Auto-bark. R restart. Q quit. Best W%d/K%d" % [int(best_stats.get("best_wave", 0)), int(best_stats.get("best_kills", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.85, 0.88, 1.0))

func _draw_title() -> void:
	draw_rect(Rect2(150, 120, 660, 300), Color(0.02, 0.015, 0.03, 0.92))
	draw_rect(Rect2(150, 120, 660, 300), Color(1.0, 0.78, 0.2), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(218, 184), "HODL OR DIE", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color(1.0, 0.78, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(235, 230), "Brother Doge Godot v0.1 — Layer 4 breeds", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.92, 0.94, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(205, 278), "1 Classic Doge   2 Brother Doge   3 Zoomie Doge", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.4, 1.0, 0.72))
	draw_string(ThemeDB.fallback_font, Vector2(245, 315), "Selected: %s — %s" % [breed_data[selected_breed].name, breed_data[selected_breed].tagline], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(1.0, 0.86, 0.3))
	draw_string(ThemeDB.fallback_font, Vector2(280, 342), "Best Wave %d   Best Kills %d   Runs %d" % [int(best_stats.get("best_wave", 0)), int(best_stats.get("best_kills", 0)), int(best_stats.get("runs", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.85, 0.9, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(315, 380), "Press Space to start", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.4, 1.0, 0.72))

func _draw_upgrade() -> void:
	draw_rect(Rect2(110, 135, 740, 270), Color(0.015, 0.02, 0.04, 0.94))
	draw_rect(Rect2(110, 135, 740, 270), Color(0.4, 1.0, 0.72), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(185, 195), "LEVEL UP — CHOOSE YOUR DOGE ENERGY", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.4, 1.0, 0.72))
	draw_string(ThemeDB.fallback_font, Vector2(180, 260), "1 Rapid Bark     2 Strong Bark     3 Zoomies", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1.0, 0.86, 0.3))
	draw_string(ThemeDB.fallback_font, Vector2(230, 322), "Space defaults to Rapid Bark", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.85, 0.9, 1.0))

func _draw_shop() -> void:
	draw_rect(Rect2(105, 118, 750, 315), Color(0.018, 0.018, 0.035, 0.95))
	draw_rect(Rect2(105, 118, 750, 315), Color(1.0, 0.78, 0.2), false, 3)
	draw_string(ThemeDB.fallback_font, Vector2(185, 176), "SHOP BETWEEN WAVES", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(1.0, 0.78, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(190, 214), "Coins: %d   Choose one upgrade to start Wave %d" % [coins, wave + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.9, 0.95, 1.0))
	var y := 262.0
	for i in range(shop_options.size()):
		var id := shop_options[i]
		var u: Dictionary = upgrades[id]
		draw_rect(Rect2(170, y - 28, 620, 54), Color(0.06, 0.05, 0.10, 0.95), true)
		draw_rect(Rect2(170, y - 28, 620, 54), Color(0.4, 1.0, 0.72, 0.65), false, 2)
		draw_string(ThemeDB.fallback_font, Vector2(190, y), "%d  %s — %s" % [i + 1, u.name, u.desc], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color(0.95, 0.98, 1.0))
		y += 66
		draw_string(ThemeDB.fallback_font, Vector2(250, 405), "Space chooses option 1. R restarts. Q quits.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.85, 0.88, 1.0))

func _draw_end() -> void:
	draw_rect(Rect2(190, 170, 580, 200), Color(0.02, 0.015, 0.03, 0.94))
	draw_rect(Rect2(190, 170, 580, 200), Color(1.0, 0.78, 0.2), false, 3)
	var title := "WAVE CLEAR" if state == "victory" else "PAPER HANDS WON"
	draw_string(ThemeDB.fallback_font, Vector2(300, 245), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color(1.0, 0.78, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(335, 300), "Kills %d   Coins %d" % [kills, coins], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.9, 0.95, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(330, 336), "Press R or Space to restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.4, 1.0, 0.72))
