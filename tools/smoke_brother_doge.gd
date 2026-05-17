extends SceneTree

func require(condition: bool, message: String) -> bool:
	if not condition:
		print("FAIL " + message)
		quit(1)
		return false
	print("PASS " + message)
	return true

func _initialize() -> void:
	print("BROTHER_DOGE_GODOT_SMOKE_START")
	var packed := load("res://scenes/BrotherDoge.tscn") as PackedScene
	if not require(packed != null, "load BrotherDoge scene"):
		return
	var game := packed.instantiate()
	get_root().add_child(game)
	await process_frame
	if not require(game.has_method("start_run"), "game exposes start_run()"):
		return
	if not require(game.has_method("select_breed"), "game exposes select_breed()"):
		return
	if not require(game.has_method("spawn_enemy"), "game exposes spawn_enemy()"):
		return
	if not require(game.has_method("spawn_boss"), "game exposes spawn_boss()"):
		return
	if not require(game.has_method("add_boss_telegraph"), "game exposes add_boss_telegraph()"):
		return
	if not require(game.has_method("defeat_enemy_kind"), "game exposes defeat_enemy_kind()"):
		return
	if not require(game.has_method("spawn_xp"), "game exposes spawn_xp()"):
		return
	if not require(game.has_method("choose_upgrade"), "game exposes choose_upgrade()"):
		return
	if not require(game.has_method("open_shop"), "game exposes open_shop()"):
		return
	if not require(game.has_method("choose_shop_option"), "game exposes choose_shop_option()"):
		return
	if not require(game.has_method("reroll_shop"), "game exposes reroll_shop()"):
		return
	if not require(game.has_method("save_progress"), "game exposes save_progress()"):
		return
	if not require(game.has_method("load_progress"), "game exposes load_progress()"):
		return
	if not require(game.has_method("reset_progress"), "game exposes reset_progress()"):
		return
	if not require(game.has_method("force_level_up"), "game exposes force_level_up()"):
		return
	if not require(game.has_method("get_debug_state"), "game exposes get_debug_state()"):
		return
	game.select_breed("brother")
	var breed_state: Dictionary = game.get_debug_state()
	if not require(breed_state.get("selected_breed") == "brother", "Brother Doge breed can be selected"):
		return
	if not require(breed_state.get("player_max_hp") >= 145.0, "Brother Doge breed applies HP stat"):
		return
	game.select_breed("zoomie")
	breed_state = game.get_debug_state()
	if not require(breed_state.get("player_speed") >= 330.0, "Zoomie Doge breed applies speed stat"):
		return
	game.start_run()
	await process_frame
	var state: Dictionary = game.get_debug_state()
	if not require(state.get("state") == "playing", "run starts in playing state"):
		return
	if not require(state.get("player_hp") > 0, "player has HP"):
		return
	game.spawn_enemy(Vector2(620, 270), "paper_hand")
	game.spawn_xp(Vector2(760, 450), 3)
	state = game.get_debug_state()
	if not require(state.get("enemies") >= 1, "enemy spawn works"):
		return
	if not require(state.get("xp_drops") >= 1, "XP drop spawn works"):
		return
	game.force_level_up()
	state = game.get_debug_state()
	if not require(state.get("state") == "upgrade", "level-up opens upgrade choice"):
		return
	game.choose_upgrade("rapid_bark")
	state = game.get_debug_state()
	if not require(state.get("state") == "playing", "upgrade returns to play"):
		return
	if not require(state.get("fire_rate") < 0.5, "rapid bark upgrade changes weapon"):
		return
	game.open_shop()
	state = game.get_debug_state()
	if not require(state.get("state") == "shop", "wave clear opens shop"):
		return
	if not require(state.get("shop_options", []).size() == 3, "shop offers three upgrade cards"):
		return
	var options_before: Array = state.get("shop_options", []).duplicate()
	game.reroll_shop()
	state = game.get_debug_state()
	if not require(state.get("shop_options", []).size() == 3, "shop reroll keeps three cards"):
		return
	var wave_before: int = state.get("wave")
	game.choose_shop_option(2)
	state = game.get_debug_state()
	if not require(state.get("state") == "playing", "shop choice resumes play"):
		return
	if not require(state.get("wave") == wave_before + 1, "shop advances to next wave"):
		return
	game.choose_upgrade("strong_bark")
	state = game.get_debug_state()
	if not require(state.get("damage") > 14.0, "strong bark upgrade applies damage stat"):
		return
	game.choose_upgrade("treat_magnet")
	state = game.get_debug_state()
	if not require(state.get("player_magnet") > 135.0, "new economy perk changes magnet stat"):
		return
	game.choose_upgrade("paper_resistance")
	state = game.get_debug_state()
	if not require(state.get("player_regen") > 0.0, "new defense perk changes regen stat"):
		return
	game.spawn_boss()
	game.add_boss_telegraph(Vector2(480, 270), 80.0, 1.0, 20.0)
	state = game.get_debug_state()
	if not require(state.get("bosses") >= 1, "boss spawn works"):
		return
	if not require(state.get("telegraphs") >= 1, "boss telegraph spawn works"):
		return
	game.spawn_enemy(Vector2(420, 270), "runner_hand")
	game.spawn_enemy(Vector2(440, 270), "tank_hand")
	game.spawn_enemy(Vector2(460, 270), "splitter_hand")
	state = game.get_debug_state()
	if not require(state.get("runner_hands") >= 1, "runner hand spawn works"):
		return
	if not require(state.get("tank_hands") >= 1, "tank hand spawn works"):
		return
	if not require(state.get("splitter_hands") >= 1, "splitter hand spawn works"):
		return
	var runners_before: int = state.get("runner_hands")
	game.defeat_enemy_kind("splitter_hand")
	state = game.get_debug_state()
	if not require(state.get("runner_hands") >= runners_before + 2, "splitter creates runner hands on defeat"):
		return
	game.reset_progress()
	game.start_run()
	game.open_shop()
	state = game.get_debug_state()
	if not require(state.get("best_wave") >= 1, "progress records best wave"):
		return
	if not require(state.get("runs") >= 1, "progress records run count"):
		return
	game.load_progress()
	state = game.get_debug_state()
	if not require(state.get("best_wave") >= 1, "progress reload preserves best wave"):
		return
	game.queue_free()
	await process_frame
	print("BROTHER_DOGE_GODOT_SMOKE_PASS")
	quit(0)
