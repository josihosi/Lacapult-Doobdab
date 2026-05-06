extends Node


signal mod_installation_started
signal mod_installation_finished
signal mod_deletion_started
signal mod_deletion_finished

signal _done_installing_mod
signal _done_deleting_mod

# Stability rating mappings (in days)
const STABILITY_RATINGS = {
	-1: 7,      # 1 week
	0: 30,      # 1 month
	1: 90,      # 3 months
	2: 180,     # 6 months
	3: 270,     # 9 months
	4: 365,     # 1 year
	5: 730,     # 2 years
	100: -1     # supported forever (negative means no expiry)
}

var installed: Dictionary = {} setget , _get_installed
var available: Dictionary = {} setget , _get_available

# Cache for mod release dates to avoid repeated API calls
var _mod_release_date_cache: Dictionary = {}
var _pending_api_calls: Array = []

const CAOL_JSON_CATALOG_TARGET_IDS := ["magiclysm", "DinoMod"]

signal mod_compatibility_checked(compatible_count, incompatible_count)


func _get_installed() -> Dictionary:
	
	if len(installed) == 0:
		refresh_installed()
		
	return installed


func _get_available() -> Dictionary:
	
	if len(available) == 0:
		refresh_available()
	
	return available


func parse_mods_dir(mods_dir: String) -> Dictionary:
	
	if not Directory.new().dir_exists(mods_dir):
		return {}
		
	var result = {}
	
	for subdir in FS.list_dir(mods_dir):
		var f = File.new()
		var modinfo = mods_dir.plus_file(subdir).plus_file("modinfo.json")
		
		if f.file_exists(modinfo):
			
			f.open(modinfo, File.READ)
			var json = JSON.parse(f.get_as_text())
			if json.error != OK:
				Status.post(tr("msg_mod_json_parsing_failed") % modinfo, Enums.MSG_ERROR)
				continue
			
			var json_result = json.result
			if typeof(json_result) == TYPE_DICTIONARY:
				json_result = [json_result]
			
			for item in json_result:
				if ("type" in item) and (item["type"] == "MOD_INFO"):
					
					var info = item
					info["name"] = _strip_html_tags(info["name"])
					if "description" in info:
						info["description"] = _strip_html_tags(info["description"])
					if not "id" in info:  # Since not all mods have IDs, apparently!
						if "ident" in info:
							info["id"] = info["ident"]
						else:
							info["id"] = info["name"]
					
					result[info["id"]] = {
						"location": mods_dir.plus_file(subdir),
						"modinfo": info
					}
					break
					
			f.close()
	
	return result


func _strip_html_tags(text: String) -> String:
	
	var s = text
	var regex = RegEx.new()
	regex.compile("<[^<>]+>")
	
	var matches = regex.search_all(s)
	for match_ in matches:
		var m: RegExMatch = match_
		s = s.replace(m.get_string(), "")
		
	return s


func mod_status(id: String) -> int:
	
	# Returns mod installed status:
	# 0 - not installed;
	# 1 - installed;
	# 2 - stock mod;
	# 3 - stock mod but obsolete;
	# 4 - installed with modified ID.
	
	if id + "__" in installed:
		return 4
	elif id in installed:
		if installed[id]["is_stock"]:
			if installed[id]["is_obsolete"]:
				return 3
			else:
				return 2
		else:
			return 1
	else:
		return 0


func refresh_installed():
	
	installed = {}
	
	var non_stock := {}
	if Directory.new().dir_exists(Paths.mods_user):
		non_stock = parse_mods_dir(Paths.mods_user)
		for id in non_stock:
			non_stock[id]["is_stock"] = false
			
	var stock := parse_mods_dir(Paths.mods_stock)
	for id in stock:
		stock[id]["is_stock"] = true
		if ("obsolete" in stock[id]["modinfo"]) and (stock[id]["modinfo"]["obsolete"] == true):
			stock[id]["is_obsolete"] = true
		else:
			stock[id]["is_obsolete"] = false
			
	for id in non_stock:
		installed[id] = non_stock[id]
		installed[id]["is_stock"] = false
		installed[id]["is_obsolete"] = false
		
	for id in stock:
		installed[id] = stock[id]


func refresh_available():
	
	# Mods are not supported for TISH
	if Settings.read("game") == "tish":
		available = {}
		return
	
	# Mods are not supported for EOD
	if Settings.read("game") == "eod":
		available = {}
		return

	# C-AOL ships many useful JSON mods in data/mods. Seed the visible catalog
	# from the active install/user/catalog roots so the Mods page can surface the
	# first supported JSON-mod Summarizer footing without inventing downloads.
	if Settings.read("game") == "caol":
		available = _build_caol_json_mod_catalog()
		return
	
	# Custom mods for TLG (Cataclysm: The Last Generation)
	if Settings.read("game") == "tlg":
		available = {
			"MindOverMatter": {
				"location": "https://github.com/Vegetabs/MindOverMatter-CTLG",
				"modinfo": {
					"id": "mindovermatter",
					"name": "Mind Over Matter",
					"authors": ["StandingStorm"],
					"maintainers": ["Vegetabs"],
					"description": "Port of MoM from CDDA to CTLG. Adds nine separate psionic power paths to Cataclysm including Biokinesis, Clairsentience, Electrokinesis, Photokinesis, Pyrokinesis, Telekinesis, Telepathy, Teleportation, and Vitakinesis.",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"BionicsExpanded": {
				"location": "https://github.com/Vegetabs/BionicsExpanded-CTLG",
				"modinfo": {
					"id": "bionics_expanded",
					"name": "Bionics Expanded",
					"authors": ["Vegetabs"],
					"maintainers": [],
					"description": "Expanded bionics system for Cataclysm: The Last Generation.",
					"category": "content",
					"dependencies": [],
					"stability": 4
				}
			},
			"MythicalMartialArts": {
				"location": "https://github.com/Vegetabs/MythicalMartialArts-CTLG",
				"modinfo": {
					"id": "MMA",
					"name": "Mythical Martial Arts",
					"authors": ["Photoloss"],
					"maintainers": ["Vegetabs"],
					"description": "Mythical martial arts mod ported to Cataclysm: The Last Generation.",
					"category": "content",
					"dependencies": [],
					"stability": 2
				}
			}
		}
	# Custom mods for Bright Nights (BN)
	elif Settings.read("game") == "bn":
		available = {
			"CataclysmSecondChance": {
				"location": "https://github.com/Tefnut/Cataclysm-Second-Chance",
				"modinfo": {
					"id": "cataclysm_second_chance",
					"name": "Cataclysm: Second Chance",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A mod for Cataclysm: Bright Nights which adds my own custom content to it",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"BetterHolsters": {
				"location": "https://github.com/Tefnut/Better-Holsters",
				"modinfo": {
					"id": "better_holsters",
					"name": "Better Holsters",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A mod for Cataclysm: Bright Nights that improves the holster experience",
					"category": "items",
					"dependencies": [],
					"stability": 4
				}
			},
			"FalloutNewEnglandRemastered": {
				"location": "https://github.com/Tefnut/Fallout-New-England-Remastered",
				"modinfo": {
					"id": "fallout_new_england_remastered",
					"name": "Fallout: New England Remastered",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A remastering of my original Fallout mod for C:DDA. Should work with newest Bright Nights release for as long as I update and maintain it.",
					"category": "content",
					"dependencies": [],
					"stability": -1
				}
			},
			"ReallyDarkSkies": {
				"location": "https://github.com/Zlorthishen/Really_Dark_Skies",
				"modinfo": {
					"id": "realdarkskies",
					"name": "Really Dark Skies",
					"authors": ["Zlorthishen"],
					"maintainers": ["Zlorthishen"],
					"description": "Really Dark Skies. The community supported mod that enhances the Bright Nights experience by adding an inscrutable alien-humanoid paramilitary expeditionary force to your typical survival scenario.",
					"category": "content",
					"dependencies": [],
					"stability": 2
				}
			},
			"TheArcologyMod": {
				"location": "https://github.com/Zlorthishen/The_Arcology_Mod",
				"modinfo": {
					"id": "arcology",
					"name": "The Arcology Mod",
					"authors": ["Zlorthishen"],
					"maintainers": ["Zlorthishen"],
					"description": "The mod that adds Arcology-type buildings, very large, self-contained buildings with a Cyberpunk aesthetic to Bright Nights.",
					"category": "buildings",
					"dependencies": [],
					"stability": 4
				}
			},
			"ZombieHighMod": {
				"location": "https://github.com/Zlorthishen/ZombieHighMod",
				"modinfo": {
					"id": "Zhigh_Mod",
					"name": "Zombie High Mod",
					"authors": ["thhoney08"],
					"maintainers": ["Zlorthishen"],
					"description": "A mod for cataclysm: Bright Nights, which sets on a bunker-like school.",
					"category": "buildings",
					"dependencies": [],
					"stability": 1
				}
			},
			"GrowMoreDrugs": {
				"location": "https://github.com/Zlorthishen/grow_more_drugs",
				"modinfo": {
					"id": "grow_more_drugs",
					"name": "Grow More Drugs",
					"authors": ["jackledead"],
					"maintainers": ["Zlorthishen"],
					"description": "Cataclysm - Bright Nights mod, adding different drug crops that would not grow in New England. Plants/seeds: Coca, coffee, tea, poppy, tobacco. Includes recipes for cocaine.",
					"category": "content",
					"dependencies": [],
					"stability": 5
				}
			},
			"LonesTechAndWeapons": {
				"location": "https://github.com/Zlorthishen/Lones-Tech-and-Weapons-mod",
				"modinfo": {
					"id": "lonestweaks",
					"name": "Lones Tweaks",
					"authors": ["thelonestander"],
					"maintainers": ["Zlorthishen"],
					"description": "Weapons and tech for the game Bright Nights",
					"category": "items",
					"dependencies": [],
					"stability": 2
				}
			},
			"NoHopeAndDinos": {
				"location": "https://github.com/Zlorthishen/No-Hope-and-Dinos",
				"modinfo": {
					"id": "no_hope_and_dinos",
					"name": "No Hope and Dinos",
					"authors": ["jackledead"],
					"maintainers": ["Zlorthishen"],
					"description": "CDDA Mod. It's like No Hope, but replaces zombies with dinosaurs, and requires TropiCataclysm and Dinomod. Removes portals and portal storms. Only spawn Dinosaurs, Robots, Cyborgs, Mutants, Insects.",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"AddBanditsExpanded": {
				"location": "https://github.com/Zlorthishen/Compatible-Add-Bandits-Expanded",
				"modinfo": {
					"id": "GOV_BANDITS_KAI_R",
					"name": "Add Bandits Expanded+",
					"authors": ["Jolmar7"],
					"maintainers": ["Zlorthishen"],
					"description": "Adds a large amount of content to the Add Bandits mod, and a few NPCs as well",
					"category": "content",
					"dependencies": [],
					"stability": 3
				}
			},
			"ArcanaAndMagicItems": {
				"location": "https://github.com/Zlorthishen/cdda-arcana-mod",
				"modinfo": {
					"id": "Arcana",
					"name": "Arcana and Magic Items",
					"authors": ["chaosvolt"],
					"maintainers": ["Zlorthishen"],
					"description": "Arcana and Magic Items mod for Cataclysm: Bright Nights",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"SteampunkMod": {
				"location": "https://github.com/Zlorthishen/CDDA-BN-Steampunk-Mod",
				"modinfo": {
					"id": "steampunk_arcanum",
					"name": "Steampunk Mod",
					"authors": ["Jolmar7"],
					"maintainers": ["Zlorthishen"],
					"description": "A mod that adds several steampunk inspired items, recipes, locations and a small NPC town. Inspired by the Arcanum: Of Steamworks of Magick Obscure RPG.",
					"category": "content",
					"dependencies": [],
					"stability": 2
				}
			},
			"HackThePlanet": {
				"location": "https://github.com/Zlorthishen/hacktheplanet",
				"modinfo": {
					"id": "hacktheplanet",
					"name": "Hack The Planet",
					"authors": ["kettleswordfang"],
					"maintainers": ["Zlorthishen"],
					"description": "CDDA Hacker Gear",
					"category": "items",
					"dependencies": [],
					"stability": 3
				}
			}
		}
			# Custom mods for DDA (Dark Days Ahead)
	elif Settings.read("game") == "dda":
		available = {
			"ArcanaAndMagicItems": {
				"location": "https://github.com/Zlorthishen/cdda-arcana-mod",
				"modinfo": {
					"id": "Arcana",
					"name": "Arcana and Magic Items",
					"authors": ["chaosvolt"],
					"maintainers": ["Zlorthishen"],
					"description": "Arcana and Magic Items mod for Cataclysm: Dark Days Ahead",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"TefnutsExpansion": {
				"location": "https://github.com/Tefnut/Tefnuts-Expansion",
				"modinfo": {
					"id": "tefnuts_expansion",
					"name": "Cataclysm: Second Chance",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "An expansion for Cataclysm:DDA that intends to add a little of everything",
					"category": "content",
					"dependencies": [],
					"stability": 1
				}
			},
			"FalloutInCDDA": {
				"location": "https://github.com/Tefnut/Fallout-in-CDDA",
				"modinfo": {
					"id": "fallout_in_cdda",
					"name": "Fallout New England",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A WIP mod that adds fallout to CDDA",
					"category": "content",
					"dependencies": [],
					"stability": 0
				}
			},
			"CDDATameAnts": {
				"location": "https://github.com/Tefnut/CDDA-tame-ants",
				"modinfo": {
					"id": "tame_ants",
					"name": "Tame Bugs",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A mod for Cataclysm: Dark Days Ahead. Contains the ability to tame various insects.",
					"category": "creatures",
					"dependencies": [],
					"stability": 4
				}
			},
			"FalloutNewEnglandRemastered": {
				"location": "https://github.com/Tefnut/Fallout-New-England-Remastered",
				"modinfo": {
					"id": "fallout_new_england_remastered",
					"name": "Fallout: New England Remastered",
					"authors": ["Tefnut"],
					"maintainers": ["Tefnut"],
					"description": "A remastering of my original Fallout mod for C:DDA. Should work with newest Bright Nights release for as long as I update and maintain it.",
					"category": "content",
					"dependencies": [],
					"stability": -1
				}
			}
		}
	else:
		available = parse_mods_dir(Paths.mod_repo)


func _build_caol_json_mod_catalog() -> Dictionary:
	var result := {}
	var roots = [
		{"source": "stock", "mods": parse_mods_dir(Paths.mods_stock), "note": "built-in JSON mod; Summarizer can create a C-AOL companion pack"},
		{"source": "user", "mods": parse_mods_dir(Paths.mods_user), "note": "installed JSON mod; Summarizer can create a C-AOL companion pack"},
		{"source": "custom-catalog", "mods": parse_mods_dir(Paths.mod_repo), "note": "catalog JSON mod; install first, then Summarizer can create a C-AOL companion pack"},
	]
	for target_id in CAOL_JSON_CATALOG_TARGET_IDS:
		for root in roots:
			var mods = root.get("mods", {})
			if mods.has(target_id):
				var entry = mods[target_id].duplicate(true)
				entry["catalog_source"] = "caol-json-%s" % root.get("source", "unknown")
				entry["catalog_note"] = root.get("note", "JSON mod catalog entry")
				result[target_id] = entry
				break
	return result


func _delete_mod(mod_id: String) -> void:
	
	yield(get_tree().create_timer(0.05), "timeout")
	# Have to introduce an artificial delay, otherwise the engine becomes very
	# crash-happy when processing large numbers of mods.
	
	if mod_id in installed:
		var mod = installed[mod_id]
		FS.rm_dir(mod["location"])
		yield(FS, "rm_dir_done")
		Status.post(tr("msg_mod_deleted") % mod["modinfo"]["name"])
	else:
		Status.post(tr("msg_mod_not_found") % mod_id, Enums.MSG_ERROR)
	
	emit_signal("_done_deleting_mod")


func delete_mods(mod_ids: Array) -> void:
	
	if len(mod_ids) == 0:
		return
	
	if len(mod_ids) > 1:
		Status.post(tr("msg_deleting_n_mods") % len(mod_ids))
	
	emit_signal("mod_deletion_started")
	
	for id in mod_ids:
		if mod_status(id) == 4:
			_delete_mod(id + "__")
		else:
			_delete_mod(id)
		yield(self, "_done_deleting_mod")
	
	refresh_installed()
	emit_signal("mod_deletion_finished")


func _get_latest_release_url(github_url: String, mod_name: String) -> void:
	
	# Extract owner and repo from GitHub URL
	var url_parts = github_url.replace("https://github.com/", "").split("/")
	var owner = url_parts[0]
	var repo = url_parts[1]
	
	# GitHub API endpoint for latest release
	var api_url = "https://api.github.com/repos/%s/%s/releases/latest" % [owner, repo]
	
	# Create HTTP request for GitHub API
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Set up proxy if needed
	if Settings.read("proxy_option") == "on":
		var host = Settings.read("proxy_host")
		var port = Settings.read("proxy_port") as int
		http_request.set_http_proxy(host, port)
		http_request.set_https_proxy(host, port)
	
	# Connect signal and make request
	http_request.connect("request_completed", self, "_on_release_info_received", [http_request, mod_name])
	
	# Get authentication headers from the parent Catapult instance if available
	var headers = PoolStringArray()
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		headers = catapult._get_github_auth_headers()
	
	# Make the request with authentication if available
	var error = http_request.request(api_url, headers)
	
	if error != OK:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		remove_child(http_request)
		http_request.queue_free()
		emit_signal("_done_installing_mod")


func _on_release_info_received(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http_request: HTTPRequest, mod_name: String) -> void:
	
	# Clean up HTTP request
	remove_child(http_request)
	http_request.queue_free()
	
	# If no releases found (404), fall back to repository download
	if response_code == 404:
		Status.post("No releases found for %s, downloading repository directly..." % mod_name, Enums.MSG_INFO)
		_download_repository_directly(mod_name)
		return
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	# Parse JSON response
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	var release_data = json.result
	var download_url = ""
	
	# Look for ZIP asset in the release
	if "assets" in release_data and release_data["assets"] is Array:
		for asset in release_data["assets"]:
			if asset["name"].ends_with(".zip"):
				download_url = asset["browser_download_url"]
				break
	
	# If no ZIP asset found, fall back to tarball
	if download_url == "":
		if "zipball_url" in release_data:
			download_url = release_data["zipball_url"]
		else:
			Status.post("No download assets found in release for %s, downloading repository directly..." % mod_name, Enums.MSG_INFO)
			_download_repository_directly(mod_name)
			return
	
	# Continue with download using the release URL
	_download_and_install_mod(download_url, mod_name)


# Download repository directly when no releases are available
func _download_repository_directly(mod_name: String) -> void:
	
	var mod_id = ""
	var github_url = ""
	
	# Find the mod info from available mods
	for id in available:
		if available[id]["modinfo"]["name"] == mod_name:
			mod_id = id
			github_url = available[id]["location"]
			break
	
	if github_url == "":
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	# Extract owner and repo from GitHub URL
	var url_parts = github_url.replace("https://github.com/", "").split("/")
	if len(url_parts) < 2:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	var owner = url_parts[0]
	var repo = url_parts[1]
	
	# Use GitHub's archive download URL (downloads main branch as ZIP)
	var download_url = "https://github.com/%s/%s/archive/refs/heads/main.zip" % [owner, repo]
	
	Status.post("Downloading repository %s/%s directly from main branch..." % [owner, repo], Enums.MSG_INFO)
	
	# Try main branch first, if it fails we'll try master branch
	_download_and_install_mod_with_fallback(download_url, mod_name, owner, repo, "main")


# Download with fallback to different branch names
func _download_and_install_mod_with_fallback(download_url: String, mod_name: String, owner: String, repo: String, branch: String) -> void:
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Set up proxy if needed
	if Settings.read("proxy_option") == "on":
		var host = Settings.read("proxy_host")
		var port = Settings.read("proxy_port") as int
		http_request.set_http_proxy(host, port)
		http_request.set_https_proxy(host, port)
	
	# Connect signal with additional parameters for fallback
	http_request.connect("request_completed", self, "_on_repository_download_completed", [http_request, mod_name, owner, repo, branch])
	
	# Get authentication headers from the parent Catapult instance if available
	var headers = PoolStringArray()
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		headers = catapult._get_github_auth_headers()
	
	# Make the request
	var error = http_request.request(download_url, headers)
	
	if error != OK:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		remove_child(http_request)
		http_request.queue_free()
		emit_signal("_done_installing_mod")


# Handle repository download response with branch fallback
func _on_repository_download_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http_request: HTTPRequest, mod_name: String, owner: String, repo: String, branch: String) -> void:
	
	# Clean up HTTP request
	remove_child(http_request)
	http_request.queue_free()
	
	# If download failed and we were trying main branch, try master branch
	if (result != HTTPRequest.RESULT_SUCCESS or response_code != 200) and branch == "main":
		Status.post("Main branch not found for %s, trying master branch..." % mod_name, Enums.MSG_INFO)
		var master_url = "https://github.com/%s/%s/archive/refs/heads/master.zip" % [owner, repo]
		_download_and_install_mod_with_fallback(master_url, mod_name, owner, repo, "master")
		return
	
	# If still failed, or we already tried master, give up
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	# Success! Continue with normal mod installation process
	Status.post("Successfully downloaded repository for %s" % mod_name, Enums.MSG_INFO)
	_process_downloaded_mod(body, mod_name)


# Process downloaded mod data (common for both releases and repository downloads)
func _process_downloaded_mod(body: PoolByteArray, mod_name: String) -> void:
	
	var mod_id = ""
	var mod = {}
	
	# Find the mod info from available mods
	for id in available:
		if available[id]["modinfo"]["name"] == mod_name:
			mod_id = id
			mod = available[id]
			break
	
	if mod_id == "":
		Status.post(tr("msg_mod_not_found") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	var mods_dir = Paths.mods_user
	var filename = mod_id + ".zip"
	var archive = Paths.cache_dir.plus_file(filename)
	var tmp_dir = Paths.tmp_dir.plus_file(mod_id)
	
	# Ensure the mods directory exists with proper permissions on macOS
	var d = Directory.new()
	if not d.dir_exists(mods_dir):
		var err = d.make_dir_recursive(mods_dir)
		if err:
			Status.post("Failed to create mods directory: %s (error: %d)" % [mods_dir, err], Enums.MSG_ERROR)
			emit_signal("_done_installing_mod")
			return
		
		# On macOS, ensure the directory has proper permissions
		if OS.get_name() == "OSX":
			var chmod_result = OS.execute("chmod", ["755", mods_dir], true)
			if chmod_result != 0:
				Status.post("Warning: Could not set mods directory permissions", Enums.MSG_WARN)
	
	# Save the downloaded data to cache
	var file = File.new()
	if file.open(archive, File.WRITE) != OK:
		Status.post(tr("msg_mod_download_failed") % mod["modinfo"]["name"], Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	file.store_var(body, true)
	file.close()
	
	# On macOS, ensure the downloaded file has proper permissions
	if OS.get_name() == "OSX":
		var chmod_result = OS.execute("chmod", ["644", archive], true)
		if chmod_result != 0:
			Status.post("Warning: Could not set archive file permissions", Enums.MSG_WARN)
	
	# Extract the mod
	FS.extract(archive, tmp_dir)
	yield(FS, "extract_done")
	if not Settings.read("keep_cache"):
		Directory.new().remove(archive)
	
	if FS.last_extract_result == 0:
		# Find the extracted directory (GitHub releases can have various structures)
		var contents = FS.list_dir(tmp_dir)
		if contents.size() > 0:
			var extracted_dir = tmp_dir.plus_file(contents[0])
			
			# Special handling for Arcana mod - contains multiple mods for different game forks
			if mod_name == "Arcana and Magic Items":
				var arcana_mod_dir = _find_arcana_mod_directory(extracted_dir)
				if arcana_mod_dir != "":
					Status.post("Installing Arcana mod from: %s" % arcana_mod_dir)
					FS.move_dir(arcana_mod_dir, mods_dir.plus_file(mod_id))
					yield(FS, "move_dir_done")
					_fix_mod_permissions_macos(mods_dir.plus_file(mod_id))
					_store_mod_download_date(mod_id)
					Status.post(tr("msg_mod_installed") % mod["modinfo"]["name"])
				else:
					Status.post(tr("msg_mod_extraction_failed") % mod["modinfo"]["name"], Enums.MSG_ERROR)
			else:
				# Find the actual mod directory with modinfo.json
				var mod_dir = _find_mod_directory(extracted_dir)
				if mod_dir != "":
					FS.move_dir(mod_dir, mods_dir.plus_file(mod_id))
					yield(FS, "move_dir_done")
					_fix_mod_permissions_macos(mods_dir.plus_file(mod_id))
					_store_mod_download_date(mod_id)
					Status.post(tr("msg_mod_installed") % mod["modinfo"]["name"])
				else:
					# Fallback to installing the entire directory if no modinfo.json found
					FS.move_dir(extracted_dir, mods_dir.plus_file(mod_id))
					yield(FS, "move_dir_done")
					_fix_mod_permissions_macos(mods_dir.plus_file(mod_id))
					_store_mod_download_date(mod_id)
					Status.post(tr("msg_mod_installed") % mod["modinfo"]["name"])
		else:
			Status.post(tr("msg_mod_extraction_failed") % mod["modinfo"]["name"], Enums.MSG_ERROR)
			emit_signal("_done_installing_mod")
			return
	else:
		Status.post(tr("msg_mod_extraction_error") % [mod["modinfo"]["name"], FS.last_extract_result], Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
		
	# Clean up temporary directory
	FS.rm_dir(tmp_dir)
	yield(FS, "rm_dir_done")
	
	emit_signal("_done_installing_mod")


# Fix file permissions for installed mods on macOS
func _fix_mod_permissions_macos(mod_path: String) -> void:
	if OS.get_name() != "OSX":
		return
		
	# Set directory permissions recursively
	var chmod_result = OS.execute("chmod", ["-R", "755", mod_path], true)
	if chmod_result != 0:
		Status.post("Warning: Could not set mod directory permissions for %s" % mod_path, Enums.MSG_WARN)
	
	# Set file permissions recursively  
	var find_result = OS.execute("find", [mod_path, "-type", "f", "-exec", "chmod", "644", "{}", "+"], true)
	if find_result != 0:
		Status.post("Warning: Could not set mod file permissions for %s" % mod_path, Enums.MSG_WARN)


func _download_and_install_mod(download_url: String, mod_name: String) -> void:
	
	# Check if we have a cached version first
	var mod_id = ""
	for id in available:
		if available[id]["modinfo"]["name"] == mod_name:
			mod_id = id
			break
	
	if mod_id == "":
		Status.post(tr("msg_mod_not_found") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	var filename = mod_id + ".zip"
	var archive = Paths.cache_dir.plus_file(filename)
	
	# Use cached version if available and caching is enabled
	if not Settings.read("ignore_cache") and Directory.new().file_exists(archive):
		Status.post("Using cached version of %s" % mod_name, Enums.MSG_INFO)
		var file = File.new()
		if file.open(archive, File.READ) == OK:
			var body = file.get_buffer(file.get_len())
			file.close()
			_process_downloaded_mod(body, mod_name)
			return
	
	# Download using HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Set up proxy if needed
	if Settings.read("proxy_option") == "on":
		var host = Settings.read("proxy_host")
		var port = Settings.read("proxy_port") as int
		http_request.set_http_proxy(host, port)
		http_request.set_https_proxy(host, port)
	
	# Connect signal
	http_request.connect("request_completed", self, "_on_mod_download_completed", [http_request, mod_name])
	
	# Get authentication headers from the parent Catapult instance if available
	var headers = PoolStringArray()
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		headers = catapult._get_github_auth_headers()
	
	# Make the request
	Status.post("Downloading %s from %s..." % [mod_name, download_url], Enums.MSG_INFO)
	var error = http_request.request(download_url, headers)
	
	if error != OK:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		remove_child(http_request)
		http_request.queue_free()
		emit_signal("_done_installing_mod")


# Handle mod download completion
func _on_mod_download_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http_request: HTTPRequest, mod_name: String) -> void:
	
	# Clean up HTTP request
	remove_child(http_request)
	http_request.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Status.post(tr("msg_mod_download_failed") % mod_name, Enums.MSG_ERROR)
		emit_signal("_done_installing_mod")
		return
	
	# Success! Process the downloaded mod
	_process_downloaded_mod(body, mod_name)


func _install_mod(mod_id: String) -> void:
	
	yield(get_tree().create_timer(0.05), "timeout")
	# For stability; see above.

	var mods_dir = Paths.mods_user
	
	if mod_id in available:
		var mod = available[mod_id]
		
		# Check if this is a GitHub URL
		if mod["location"].begins_with("https://github.com/"):
			# Handle GitHub mod installation - get latest release
			_get_latest_release_url(mod["location"], mod["modinfo"]["name"])
			return
		else:
			# Handle local mod installation (existing code)
			FS.copy_dir(mod["location"], mods_dir)
			yield(FS, "copy_dir_done")
			
			if (mod_id in installed) and (installed[mod_id]["is_obsolete"] == true):
				Status.post(tr("msg_obsolete_mod_collision") % [mod_id, mod["modinfo"]["name"]])
				var modinfo = mod["modinfo"].duplicate()
				modinfo["id"] += "__"
				modinfo["name"] += "*"
				var f = File.new()
				f.open(mods_dir.plus_file(mod["location"].get_file()).plus_file("modinfo.json"), File.WRITE)
				f.store_string(JSON.print(modinfo, "    "))
			
			_store_mod_download_date(mod_id)
			Status.post(tr("msg_mod_installed") % mod["modinfo"]["name"])
	else:
		Status.post(tr("msg_mod_not_found") % mod_id, Enums.MSG_ERROR)
	
	emit_signal("_done_installing_mod")


func get_updatable_mod_ids() -> Array:
	# Returns available-list keys for installed GitHub mods that have a newer release than installed.
	var result := []
	var download_dates = Settings.read("mod_download_dates")
	if download_dates == null:
		download_dates = {}

	for mod_id in installed:
		if installed[mod_id]["is_stock"]:
			continue
		# Find the matching key in available
		var available_key := ""
		for key in available:
			if available[key]["modinfo"]["id"] == mod_id or key == mod_id:
				available_key = key
				break
		if available_key == "":
			continue
		var mod_location = available[available_key]["location"]
		if not mod_location.begins_with("https://github.com/"):
			continue
		if not mod_id in download_dates:
			continue
		var release_date = _get_mod_latest_release_date(available_key)
		if release_date != "" and release_date > download_dates[mod_id]:
			result.append(available_key)

	return result


func install_mods(mod_ids: Array) -> void:
	
	if len(mod_ids) == 0:
		return
	
	if len(mod_ids) > 1:
		Status.post(tr("msg_installing_n_mods") % len(mod_ids))
	
	emit_signal("mod_installation_started")
	
	for id in mod_ids:
		_install_mod(id)
		yield(self, "_done_installing_mod")
	
	refresh_installed()
	emit_signal("mod_installation_finished")


# Check if a mod is compatible based on its stability rating and the latest release date
func is_mod_compatible(mod_id: String) -> bool:
	
	# Apply stability checking to all channels (both stable and experimental)
	# This ensures mods are checked for compatibility regardless of the channel
	
	# Check if mod exists and has stability rating
	if not mod_id in available:
		return false
	
	var mod_info = available[mod_id]["modinfo"]
	if not "stability" in mod_info:
		return false
	
	var stability_rating = mod_info["stability"]
	if not stability_rating in STABILITY_RATINGS:
		return false
	
	var max_days = STABILITY_RATINGS[stability_rating]
	
	# If stability rating is 100 (forever), always compatible
	if max_days == -1:
		return true
	
	# Get the latest release date for this specific mod
	var mod_release_date = _get_mod_latest_release_date(mod_id)
	if mod_release_date == "":
		# If we can't get the mod's release date, assume incompatible
		return false
	
	# Calculate days difference since the mod's last release
	var days_since_mod_release = _calculate_days_since_release(mod_release_date)
	
	# Check if mod is still within its stability window
	return days_since_mod_release <= max_days


# Get the latest release date for a specific mod's GitHub repository
func _get_mod_latest_release_date(mod_id: String) -> String:
	
	if not mod_id in available:
		return ""
	
	# Check cache first
	if mod_id in _mod_release_date_cache:
		return _mod_release_date_cache[mod_id]
	
	var mod = available[mod_id]
	var location = mod["location"]
	
	# Check if this is a GitHub URL
	if not location.begins_with("https://github.com/"):
		# For non-GitHub mods, we can't determine release date
		return ""
	
	# Return empty string for now - real data will be fetched asynchronously
	return ""


# Fetch release dates for all mods asynchronously using batch API
func fetch_all_mod_release_dates() -> void:
	
	_pending_api_calls.clear()
	
	# Check if user is authenticated
	var is_authenticated = _check_github_authentication()
	
	# For unauthenticated users, use the fallback REST API method
	if not is_authenticated:
		_fetch_all_mod_release_dates_rest_api()
		return
	
	# For authenticated users, use the batch GraphQL API
	Status.post("GitHub authentication found, using GraphQL batch API", Enums.MSG_DEBUG)
	
	# Check if we have a GitHubBatchAPI node, if not create one
	var batch_api = get_node_or_null("GitHubBatchAPI")
	if batch_api == null:
		batch_api = load("res://scripts/GitHubBatchAPI.gd").new()
		batch_api.name = "GitHubBatchAPI"
		add_child(batch_api)
		batch_api.connect("batch_request_completed", self, "_on_batch_api_completed")
	
	# Clear any previous queue
	batch_api.clear_queue()
	
	# Queue all mods that need fetching
	var mods_to_fetch = 0
	for mod_id in available:
		var mod = available[mod_id]
		var location = mod["location"]
		
		# Only fetch for GitHub mods that aren't already cached
		if location.begins_with("https://github.com/") and not mod_id in _mod_release_date_cache:
			# Extract owner and repo from GitHub URL
			var url_parts = location.replace("https://github.com/", "").split("/")
			if len(url_parts) >= 2:
				var owner = url_parts[0]
				var repo = url_parts[1]
				batch_api.queue_mod(mod_id, owner, repo)
				_pending_api_calls.append(mod_id)
				mods_to_fetch += 1
	
	# If no API calls are needed (everything is cached), immediately check compatibility
	if mods_to_fetch == 0:
		_check_all_mod_compatibility()
	else:
		Status.post("Fetching release dates for %d mod(s) using batch API..." % mods_to_fetch, Enums.MSG_DEBUG)
		batch_api.execute_batches()


# Check if GitHub authentication is available
func _check_github_authentication() -> bool:
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		var auth_headers = catapult._get_github_auth_headers()
		# Check if there's an actual authorization header (not just default headers)
		for header in auth_headers:
			if header.begins_with("Authorization:") or header.begins_with("authorization:"):
				return true
	return false


# Fetch release dates for all mods using REST API (fallback for unauthenticated users)
func _fetch_all_mod_release_dates_rest_api() -> void:
	
	_pending_api_calls.clear()
	
	# Queue all mods that need fetching
	var mods_to_fetch = 0
	for mod_id in available:
		var mod = available[mod_id]
		var location = mod["location"]
		
		# Only fetch for GitHub mods that aren't already cached
		if location.begins_with("https://github.com/") and not mod_id in _mod_release_date_cache:
			_pending_api_calls.append(mod_id)
			mods_to_fetch += 1
	
	# If no API calls are needed (everything is cached), immediately check compatibility
	if mods_to_fetch == 0:
		_check_all_mod_compatibility()
		return
	
	Status.post("Fetching release dates for %d mod(s)..." % mods_to_fetch, Enums.MSG_DEBUG)
	
	# Fetch each mod's release date individually
	for mod_id in _pending_api_calls.duplicate():
		_fetch_mod_release_date_async(mod_id)


# Fetch the latest release date for a specific mod from GitHub API (async)
func _fetch_mod_release_date_async(mod_id: String) -> void:
	
	if not mod_id in available:
		_on_mod_release_date_received_internal(mod_id, "")
		return
	
	var mod = available[mod_id]
	var location = mod["location"]
	
	# Check if this is a GitHub URL
	if not location.begins_with("https://github.com/"):
		_on_mod_release_date_received_internal(mod_id, "")
		return
	
	# Extract owner and repo from GitHub URL
	var url_parts = location.replace("https://github.com/", "").split("/")
	if len(url_parts) < 2:
		_on_mod_release_date_received_internal(mod_id, "")
		return
	
	var owner = url_parts[0]
	var repo = url_parts[1]
	
	# GitHub API endpoint for latest release
	var api_url = "https://api.github.com/repos/%s/%s/releases/latest" % [owner, repo]
	
	# Create HTTP request for GitHub API
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Set up proxy if needed
	if Settings.read("proxy_option") == "on":
		var host = Settings.read("proxy_host")
		var port = Settings.read("proxy_port") as int
		http_request.set_http_proxy(host, port)
		http_request.set_https_proxy(host, port)
	
	# Connect signal and make request
	http_request.connect("request_completed", self, "_on_mod_release_date_received", [http_request, mod_id])
	
	# Get authentication headers from the parent Catapult instance if available
	var headers = PoolStringArray()
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		headers = catapult._get_github_auth_headers()
	
	# Make the request with authentication if available
	var error = http_request.request(api_url, headers)
	
	if error != OK:
		remove_child(http_request)
		http_request.queue_free()
		_on_mod_release_date_received_internal(mod_id, "")


# Handle response from GitHub API for mod release date
func _on_mod_release_date_received(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http_request: HTTPRequest, mod_id: String) -> void:
	
	# Clean up HTTP request
	remove_child(http_request)
	http_request.queue_free()
	
	var release_date = ""
	
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		# Parse JSON response
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			var release_data = json.result
			if "published_at" in release_data:
				# Parse the ISO 8601 date format from GitHub API (e.g., "2024-01-15T10:30:00Z")
				var date_str = release_data["published_at"]
				# Extract just the date part (YYYY-MM-DD)
				release_date = date_str.split("T")[0]
				Status.post("Retrieved release date for %s: %s" % [mod_id, release_date], Enums.MSG_DEBUG)
			else:
				Status.post("No published_at found for mod %s" % mod_id, Enums.MSG_DEBUG)
		else:
			Status.post("JSON parse error for mod %s" % mod_id, Enums.MSG_DEBUG)
	elif response_code == 404:
		# Repository has no releases, try to get last commit date instead
		Status.post("No releases found for %s, trying last commit date..." % mod_id, Enums.MSG_DEBUG)
		_fetch_mod_last_commit_date(mod_id)
		return
	else:
		Status.post("Failed to fetch release date for mod %s (HTTP %d)" % [mod_id, response_code], Enums.MSG_DEBUG)
	
	_on_mod_release_date_received_internal(mod_id, release_date)


# Fetch the last commit date as fallback when no releases exist
func _fetch_mod_last_commit_date(mod_id: String) -> void:
	
	if not mod_id in available:
		_on_mod_release_date_received_internal(mod_id, "")
		return
	
	var mod = available[mod_id]
	var location = mod["location"]
	
	# Extract owner and repo from GitHub URL
	var url_parts = location.replace("https://github.com/", "").split("/")
	if len(url_parts) < 2:
		_on_mod_release_date_received_internal(mod_id, "")
		return
	
	var owner = url_parts[0]
	var repo = url_parts[1]
	
	# GitHub API endpoint for commits (get latest commit)
	var api_url = "https://api.github.com/repos/%s/%s/commits?per_page=1" % [owner, repo]
	
	Status.post("Fetching last commit date for %s..." % mod_id, Enums.MSG_DEBUG)
	
	# Create HTTP request for GitHub API
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Set up proxy if needed
	if Settings.read("proxy_option") == "on":
		var host = Settings.read("proxy_host")
		var port = Settings.read("proxy_port") as int
		http_request.set_http_proxy(host, port)
		http_request.set_https_proxy(host, port)
	
	# Connect signal and make request
	http_request.connect("request_completed", self, "_on_mod_commit_date_received", [http_request, mod_id])
	
	# Get authentication headers from the parent Catapult instance if available
	var headers = PoolStringArray()
	var catapult = get_parent()
	if catapult and catapult.has_method("_get_github_auth_headers"):
		headers = catapult._get_github_auth_headers()
	
	# Make the request with authentication if available
	var error = http_request.request(api_url, headers)
	
	if error != OK:
		remove_child(http_request)
		http_request.queue_free()
		_on_mod_release_date_received_internal(mod_id, "")


# Handle response from GitHub API for mod commit date (fallback)
func _on_mod_commit_date_received(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray, http_request: HTTPRequest, mod_id: String) -> void:
	
	# Clean up HTTP request
	remove_child(http_request)
	http_request.queue_free()
	
	var commit_date = ""
	
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		# Parse JSON response (array of commits)
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			var commits_data = json.result
			if commits_data is Array and len(commits_data) > 0:
				var latest_commit = commits_data[0]
				if "commit" in latest_commit and "committer" in latest_commit["commit"] and "date" in latest_commit["commit"]["committer"]:
					# Parse the ISO 8601 date format from GitHub API (e.g., "2024-01-15T10:30:00Z")
					var date_str = latest_commit["commit"]["committer"]["date"]
					# Extract just the date part (YYYY-MM-DD)
					commit_date = date_str.split("T")[0]
					Status.post("Retrieved last commit date for %s: %s" % [mod_id, commit_date], Enums.MSG_DEBUG)
				else:
					Status.post("No commit date found for mod %s" % mod_id, Enums.MSG_DEBUG)
			else:
				Status.post("No commits found for mod %s" % mod_id, Enums.MSG_DEBUG)
		else:
			Status.post("JSON parse error for commit data of mod %s" % mod_id, Enums.MSG_DEBUG)
	else:
		Status.post("Failed to fetch commit date for mod %s (HTTP %d)" % [mod_id, response_code], Enums.MSG_DEBUG)
	
	_on_mod_release_date_received_internal(mod_id, commit_date)


# Handle batch API results
func _on_batch_api_completed(results: Dictionary) -> void:
	
	Status.post("Batch API completed with %d results" % len(results), Enums.MSG_DEBUG)
	
	# Process all results
	var processed_count = 0
	for mod_id in results:
		var release_date = results[mod_id]
		_mod_release_date_cache[mod_id] = release_date
		processed_count += 1
		
		# Remove from pending calls
		if mod_id in _pending_api_calls:
			_pending_api_calls.erase(mod_id)
	
	Status.post("Processed %d mod release dates" % processed_count, Enums.MSG_DEBUG)
	
	# Clear any remaining pending calls and proceed (in case some failed)
	if len(_pending_api_calls) > 0:
		Status.post("Warning: %d mods still pending, proceeding anyway" % len(_pending_api_calls), Enums.MSG_DEBUG)
		# Cache empty results for pending mods to unblock the UI
		for mod_id in _pending_api_calls:
			if not mod_id in _mod_release_date_cache:
				_mod_release_date_cache[mod_id] = ""
		_pending_api_calls.clear()
	
	# Always proceed to compatibility check
	_check_all_mod_compatibility()


# Internal handler for release date reception (both successful and failed)
# This is kept for backward compatibility with individual requests if needed
func _on_mod_release_date_received_internal(mod_id: String, release_date: String) -> void:
	
	# Cache the result (even if empty)
	_mod_release_date_cache[mod_id] = release_date
	
	# Remove from pending calls
	if mod_id in _pending_api_calls:
		_pending_api_calls.erase(mod_id)
	
	# If all API calls are complete, emit signal for UI update
	if len(_pending_api_calls) == 0:
		_check_all_mod_compatibility()


# Check compatibility for all mods and emit signal with results
func _check_all_mod_compatibility() -> void:
	
	var compatible_count = 0
	var incompatible_count = 0
	
	for mod_id in available:
		if is_mod_compatible(mod_id):
			compatible_count += 1
		else:
			incompatible_count += 1
	
	emit_signal("mod_compatibility_checked", compatible_count, incompatible_count)


# Calculate days between release date and current date
func _calculate_days_since_release(release_date: String) -> int:
	
	# Parse release date (format: YYYY-MM-DD)
	var parts = release_date.split("-")
	if len(parts) != 3:
		return 0
	
	var release_year = int(parts[0])
	var release_month = int(parts[1])
	var release_day = int(parts[2])
	
	# Get current date
	var current_date = OS.get_datetime()
	
	# Simple day calculation (approximate)
	var release_days = release_year * 365 + release_month * 30 + release_day
	var current_days = current_date.year * 365 + current_date.month * 30 + current_date.day
	
	return current_days - release_days


func _find_mod_directory(extracted_dir: String) -> String:
	
	Status.post("Searching for mod directory in: %s" % extracted_dir)
	
	# Check if the root directory contains modinfo.json
	var modinfo_path = extracted_dir.plus_file("modinfo.json")
	var file = File.new()
	if file.file_exists(modinfo_path):
		Status.post("Found modinfo.json in root directory")
		return extracted_dir
	
	# Search through subdirectories for modinfo.json
	var mod_candidates = []
	var contents = FS.list_dir(extracted_dir)
	
	Status.post("Found %d subdirectories to check: %s" % [len(contents), str(contents)])
	
	for subdir in contents:
		var subdir_path = extracted_dir.plus_file(subdir)
		
		# Skip non-directories
		if not Directory.new().dir_exists(subdir_path):
			continue
			
		var subdir_modinfo = subdir_path.plus_file("modinfo.json")
		Status.post("Checking for modinfo.json at: %s" % subdir_modinfo)
		
		if file.file_exists(subdir_modinfo):
			Status.post("Found modinfo.json in subdirectory: %s" % subdir)
			
			# Verify it's a valid mod by checking the modinfo content
			file.open(subdir_modinfo, File.READ)
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.parse(json_text)
			if json.error == OK:
				var json_result = json.result
				if typeof(json_result) == TYPE_DICTIONARY:
					json_result = [json_result]
				
				for item in json_result:
					if ("type" in item) and (item["type"] == "MOD_INFO"):
						mod_candidates.append(subdir_path)
						Status.post("Valid mod directory found: %s with mod ID: %s" % [subdir, item.get("id", "unknown")])
						break
			else:
				Status.post("Invalid JSON in modinfo.json at: %s" % subdir_modinfo)
		else:
			# Also check for deeper nested modinfo.json files (up to 2 levels deep)
			var nested_contents = FS.list_dir(subdir_path)
			for nested_subdir in nested_contents:
				var nested_path = subdir_path.plus_file(nested_subdir)
				if Directory.new().dir_exists(nested_path):
					var nested_modinfo = nested_path.plus_file("modinfo.json")
					if file.file_exists(nested_modinfo):
						Status.post("Found nested modinfo.json at: %s" % nested_modinfo)
						
						file.open(nested_modinfo, File.READ)
						var json_text = file.get_as_text()
						file.close()
						
						var json = JSON.parse(json_text)
						if json.error == OK:
							var json_result = json.result
							if typeof(json_result) == TYPE_DICTIONARY:
								json_result = [json_result]
							
							for item in json_result:
								if ("type" in item) and (item["type"] == "MOD_INFO"):
									mod_candidates.append(nested_path)
									Status.post("Valid nested mod directory found: %s/%s with mod ID: %s" % [subdir, nested_subdir, item.get("id", "unknown")])
									break
	
	# Return the first valid mod directory found
	if len(mod_candidates) > 0:
		Status.post("Selected mod directory: %s" % mod_candidates[0])
		return mod_candidates[0]
	
	# No valid mod directory found
	Status.post("No valid mod directory found, will install entire repository")
	return ""


func _find_arcana_mod_directory(extracted_dir: String) -> String:
	
	# Look for appropriate mod directory based on game fork
	var game = Settings.read("game")
	var mod_contents = FS.list_dir(extracted_dir)
	var target_mod_dir = ""
	
	Status.post("Arcana installation - searching for mod directory for game: %s" % game)
	
	# Find the appropriate mod directory
	for subdir in mod_contents:
		var subdir_path = extracted_dir.plus_file(subdir)
		var modinfo_path = subdir_path.plus_file("modinfo.json")
		
		# Check if this subdirectory contains a modinfo.json
		var file = File.new()
		if file.file_exists(modinfo_path):
			file.open(modinfo_path, File.READ)
			var json = JSON.parse(file.get_as_text())
			file.close()
			
			if json.error == OK:
				var json_result = json.result
				if typeof(json_result) == TYPE_DICTIONARY:
					json_result = [json_result]
				
				for item in json_result:
					if ("type" in item) and (item["type"] == "MOD_INFO"):
						var info = item
						
						# Check if this is the right mod for the current game fork
						if "id" in info and info["id"] == "Arcana":
							Status.post("Found Arcana mod directory: %s (for game: %s)" % [subdir, game])
							target_mod_dir = subdir_path
							
							# For DDA, prefer directories with "dda" or "dark" in the name
							if game == "dda" and (subdir.to_lower().find("dda") != -1 or subdir.to_lower().find("dark") != -1):
								Status.post("Using DDA-specific Arcana directory: %s" % subdir)
								break
							# For BN, prefer directories with "bn" or "bright" in the name  
							elif game == "bn" and (subdir.to_lower().find("bn") != -1 or subdir.to_lower().find("bright") != -1):
								Status.post("Using BN-specific Arcana directory: %s" % subdir)
								break
		
		# If we found a game-specific directory, use it immediately
		if target_mod_dir != "" and ((game == "dda" and (subdir.to_lower().find("dda") != -1 or subdir.to_lower().find("dark") != -1)) or 
		                             (game == "bn" and (subdir.to_lower().find("bn") != -1 or subdir.to_lower().find("bright") != -1))):
			break
	
	# If no specific directory found but we have a general Arcana directory, use it
	if target_mod_dir == "":
		# Fallback: look for any directory containing "Arcana" 
		for subdir in mod_contents:
			if subdir.to_lower().find("arcana") != -1:
				var subdir_path = extracted_dir.plus_file(subdir)
				var modinfo_path = subdir_path.plus_file("modinfo.json")
				var file = File.new()
				if file.file_exists(modinfo_path):
					target_mod_dir = subdir_path
					Status.post("Using fallback Arcana directory: %s" % subdir)
					break
	
	Status.post("Arcana mod directory selection result: %s" % target_mod_dir)
	return target_mod_dir


# Store the download date for a mod in settings
func _store_mod_download_date(mod_id: String) -> void:
	
	# Get current date
	var current_date = OS.get_datetime()
	var date_string = "%04d-%02d-%02d" % [current_date.year, current_date.month, current_date.day]
	
	# Read existing download dates
	var download_dates = Settings.read("mod_download_dates")
	if download_dates == null:
		download_dates = {}
	
	# Get the actual modinfo ID (mod_id might be the available key)
	var actual_mod_id = mod_id
	if mod_id in available:
		actual_mod_id = available[mod_id]["modinfo"]["id"]
	
	# Store the date for this mod using the modinfo ID
	download_dates[actual_mod_id] = date_string
	Settings.store("mod_download_dates", download_dates)
	
	Status.post("Stored download date for mod %s: %s" % [actual_mod_id, date_string], Enums.MSG_DEBUG)


func get_caol_mod_summarizer_status(world_name := "") -> Dictionary:
	# Slice 1+6 bridge for C-AOL mod/Summarizer status. The status model is
	# still non-mutating, but now carries the current backend generation gate so
	# real apply previews can be blocked/enabled by the same backend-good checks.
	if Settings.read("game") != "caol":
		return {"model": "caol_mod_summarizer_status", "version": 1, "read_only": true, "mods": [], "counts": {}, "world": {"errors": ["C-AOL status model only runs for game=caol"]}}
	var paths = get_node_or_null("/root/Paths")
	if paths == null:
		return {"model": "caol_mod_summarizer_status", "version": 1, "read_only": true, "mods": [], "counts": {}, "world": {"errors": ["Paths autoload is unavailable"]}}
	return CaolModStatus.build_status(paths.mods_stock, paths.mods_user, paths.mod_repo, paths.savegames, world_name, _current_backend_gate())


func get_caol_mod_summarizer_overview(world_name := "") -> Dictionary:
	# Slice 2 view model for Mods/Settings: concise counts, all-enabled state,
	# and dry-run candidate list. Still read-only/status-only.
	return CaolModStatus.build_ux_overview(get_caol_mod_summarizer_status(world_name))


func get_caol_summarizer_world_names() -> Array:
	# UI helper for Slice 6: list worlds that have a readable mods.json so the
	# player can choose the target world before preview/apply. Read-only.
	var worlds := []
	var paths = get_node_or_null("/root/Paths")
	if paths == null:
		return worlds
	var save_dir = str(paths.savegames)
	var d = Directory.new()
	if save_dir == "" or not d.dir_exists(save_dir):
		return worlds
	if d.open(save_dir) != OK:
		return worlds
	d.list_dir_begin(true, true)
	var name = d.get_next()
	while name != "":
		var world_path = save_dir.plus_file(name)
		if d.dir_exists(world_path) and d.file_exists(world_path.plus_file("mods.json")):
			worlds.append(name)
		name = d.get_next()
	d.list_dir_end()
	worlds.sort()
	return worlds


func get_caol_summarizer_apply_preview(world_name := "", selected_mod_id := "", confirmation_received := false) -> Dictionary:
	# Slice 6 preview/action plan. This builds a player-facing plan but does not
	# call a backend, generate files, apply packs, enable mods, or mutate saves.
	var mode = Settings.read("backend_mode")
	var backend_status = _current_backend_status(mode)
	return CaolModStatus.build_generation_apply_plan(get_caol_mod_summarizer_status(world_name), selected_mod_id, mode, backend_status, confirmation_received)


func apply_caol_summarizer_generated_pack(world_name := "", selected_mod_id := "", confirmation_received := false, generated_entries := []) -> Dictionary:
	# Slice 6 confirmed writer seam. This is the first real apply path: after an
	# explicit confirmation and a backend-good plan, it stages a C-AOL-native
	# companion summary pack, backs up replaceable state, writes the pack, and
	# updates the selected world's mods.json so the companion loads after the
	# source mod. Automated proofs call this only against sandboxed HOME/paths.
	var preview = get_caol_summarizer_apply_preview(world_name, selected_mod_id, confirmation_received)
	if preview.get("would_mutate", false) != true:
		return _caol_apply_result(false, preview, "Summarizer apply blocked; preview did not pass confirmation/backend/world gates.", {})

	var status = get_caol_mod_summarizer_status(world_name)
	var selected = _find_caol_status_record(status, preview.get("selected_mod_id", ""))
	if selected.empty():
		return _caol_apply_result(false, preview, "Summarizer apply blocked; selected source mod disappeared before write.", {})

	var write_plan = preview.get("write_plan", {})
	var companion_dir = str(preview.get("companion_pack_dir", ""))
	var mods_json_path = str(write_plan.get("mods_json", ""))
	if companion_dir == "" or mods_json_path == "":
		return _caol_apply_result(false, preview, "Summarizer apply blocked; companion pack path or world mods.json path is empty.", {})

	var timestamp = _caol_apply_timestamp()
	var backup_dir = Paths.save_backups.plus_file("lacapult_summary_apply_%s_%s" % [_safe_id_fragment(preview.get("selected_mod_id", "unknown")), timestamp])
	var staging_dir = Paths.tmp_dir.plus_file("lacapult_summary_stage_%s_%s" % [_safe_id_fragment(preview.get("selected_mod_id", "unknown")), timestamp])
	var d = Directory.new()
	var mkdir_err = d.make_dir_recursive(backup_dir)
	if mkdir_err != OK:
		return _caol_apply_result(false, preview, "Summarizer apply failed before writing: could not create backup directory (%s)." % mkdir_err, {"backup_dir": backup_dir})
	if d.dir_exists(staging_dir):
		_caol_remove_dir(staging_dir)
	mkdir_err = d.make_dir_recursive(staging_dir)
	if mkdir_err != OK:
		return _caol_apply_result(false, preview, "Summarizer apply failed before writing: could not create staging directory (%s)." % mkdir_err, {"staging_dir": staging_dir})

	var previous_mods_text = _read_text_file(mods_json_path)
	if previous_mods_text == null:
		return _caol_apply_result(false, preview, "Summarizer apply failed before writing: target world mods.json could not be read.", {"mods_json": mods_json_path})
	_write_text_file(backup_dir.plus_file("mods.json.before.exact"), previous_mods_text)
	Helpers.save_to_json_file(write_plan.get("previous_mod_order", []), backup_dir.plus_file("mods.json.before.json"))
	var pack_existed_before = d.dir_exists(companion_dir)
	var pack_backup = backup_dir.plus_file("summary_pack.before")
	if pack_existed_before:
		_caol_copy_dir(companion_dir, pack_backup)
	else:
		Helpers.save_to_json_file({"path": companion_dir, "state": "missing"}, backup_dir.plus_file("summary_pack.before.missing.json"))

	var entries = generated_entries
	if typeof(entries) != TYPE_ARRAY or entries.empty():
		entries = [_caol_default_generated_summary_entry(selected)]
	var manifest = preview.get("manifest_preview", {}).duplicate(true)
	manifest["generated_at"] = timestamp
	manifest["generation_mode"] = "lacapult-staged-v0"
	manifest["generated_paths"] = ["modinfo.json", "lacapult_summary_pack_manifest.json", "npcs/Backgrounds/Summaries_extra/generated_%s.json" % _safe_id_fragment(preview.get("selected_mod_id", ""))]
	manifest["apply"] = {
		"mode": "confirmed-user-companion-mod",
		"applied_at": timestamp,
		"target_user_mod_path": companion_dir,
		"world_mods_json": mods_json_path,
		"previous_mod_order": write_plan.get("previous_mod_order", []),
		"new_mod_order": write_plan.get("planned_mod_order", []),
		"backup_dir": backup_dir,
		"pack_existed_before_apply": pack_existed_before,
	}
	manifest["rollback"] = {
		"mode": "restore-previous-world-mods-json-and-summary-pack-dir",
		"restore_paths": [mods_json_path, companion_dir],
		"expected_mod_order_after_rollback": write_plan.get("previous_mod_order", []),
	}

	var modinfo = {
		"type": "MOD_INFO",
		"id": preview.get("companion_mod_id", ""),
		"name": "Catapult-Dabubu generated summaries for %s" % preview.get("selected_mod_name", preview.get("selected_mod_id", "")),
		"description": "Generated C-AOL NPC/context summaries staged by Catapult-Dabubu. Contains no gameplay content beyond summaries.",
		"category": "content",
		"dependencies": [preview.get("selected_mod_id", "")],
	}
	var summary_bundle = {"type": "npc_personality_summary_bundle", "version": 1, "entries": entries}
	Helpers.save_to_json_file(modinfo, staging_dir.plus_file("modinfo.json"))
	Helpers.save_to_json_file(manifest, staging_dir.plus_file("lacapult_summary_pack_manifest.json"))
	var summary_path = staging_dir.plus_file("npcs").plus_file("Backgrounds").plus_file("Summaries_extra").plus_file("generated_%s.json" % _safe_id_fragment(preview.get("selected_mod_id", "")))
	d.make_dir_recursive(summary_path.get_base_dir())
	Helpers.save_to_json_file(summary_bundle, summary_path)

	if d.dir_exists(companion_dir):
		_caol_remove_dir(companion_dir)
	_caol_copy_dir(staging_dir, companion_dir)
	var wrote_mods = Helpers.save_to_json_file(write_plan.get("planned_mod_order", []), mods_json_path)
	if not wrote_mods:
		return _caol_apply_result(false, preview, "Summarizer apply failed while updating world mods.json; backup is available for rollback.", {"backup_dir": backup_dir, "staging_dir": staging_dir})

	var result_details = {
		"companion_pack_dir": companion_dir,
		"mods_json": mods_json_path,
		"backup_dir": backup_dir,
		"staging_dir": staging_dir,
		"manifest_json": companion_dir.plus_file("lacapult_summary_pack_manifest.json"),
		"summaries_extra_json": companion_dir.plus_file("npcs").plus_file("Backgrounds").plus_file("Summaries_extra").plus_file("generated_%s.json" % _safe_id_fragment(preview.get("selected_mod_id", ""))),
		"planned_mod_order": write_plan.get("planned_mod_order", []),
		"pack_existed_before_apply": pack_existed_before,
	}
	return _caol_apply_result(true, preview, "C-AOL Summarizer companion pack applied after explicit confirmation. Backup/rollback manifest is available at %s." % backup_dir, result_details)


func generate_and_apply_caol_summarizer_pack(world_name := "", selected_mod_id := "", confirmation_received := false, allow_backend_call := false) -> Dictionary:
	# Slice 6 live-generation seam. This is stricter than the writer-only helper:
	# it requires explicit confirmation plus an explicit backend-call allowance, then
	# asks the selected backend for C-AOL-native summary entries before reusing the
	# same sandbox-proven apply/backup machinery. Automated proof can force the
	# fixture backend with LACAPULT_SUMMARIZER_FIXTURE_BACKEND=1; normal Ollama
	# generation talks only to the configured local Ollama endpoint/model and never
	# pulls models. API/OpenVINO return player-facing blocked errors until their
	# live runner path is explicitly implemented.
	var preview = get_caol_summarizer_apply_preview(world_name, selected_mod_id, confirmation_received)
	if preview.get("would_mutate", false) != true:
		return _caol_apply_result(false, preview, "Summarizer generation/apply blocked; preview did not pass confirmation/backend/world gates.", {})
	if allow_backend_call != true:
		return _caol_apply_result(false, preview, "Summarizer generation blocked before mutation: a separate explicit backend-call confirmation is required.", {"generation_blocked_before_backend_call": true})

	var status = get_caol_mod_summarizer_status(world_name)
	var selected = _find_caol_status_record(status, preview.get("selected_mod_id", ""))
	if selected.empty():
		return _caol_apply_result(false, preview, "Summarizer generation blocked; selected source mod disappeared before backend call.", {})

	var generated = _caol_generate_summary_entries(preview, selected)
	if generated.get("ok", false) != true:
		return _caol_apply_result(false, preview, "Summarizer generation failed before any pack write: %s" % generated.get("message", "unknown backend error"), {"generation": generated})

	var result = apply_caol_summarizer_generated_pack(world_name, preview.get("selected_mod_id", selected_mod_id), true, generated.get("entries", []))
	result["generation"] = generated
	if result.get("applied", false):
		result["message"] = "C-AOL Summarizer generated entries with %s and applied the companion pack after explicit confirmation. Backup/rollback manifest is available at %s." % [generated.get("backend_mode", "backend"), result.get("details", {}).get("backup_dir", "the backup folder")]
	return result


func get_caol_summarizer_dry_run(world_name := "") -> Dictionary:
	# Dry-run prompt/action state. This intentionally does not call a backend,
	# generate files, enable mods, apply packs, or mutate saves/userdata.
	var mode = Settings.read("backend_mode")
	var backend_status = _current_backend_status(mode)
	return CaolModStatus.build_dry_run_summarizer_prompt(get_caol_mod_summarizer_status(world_name), mode, backend_status)


func _current_backend_gate() -> Dictionary:
	var mode = Settings.read("backend_mode")
	return {"mode": mode, "status": _current_backend_status(mode)}


func _current_backend_status(mode: String) -> String:
	if get_node_or_null("/root/BackendConfig") == null:
		return "backend_config_unavailable"
	for backend in BackendConfig.get_supported_backends():
		if backend.get("id", "") == mode:
			return backend.get("status", "unknown")
	return "unknown_backend"

func _current_backend_model(mode: String) -> String:
	if mode == "ollama":
		return str(Settings.read("backend_ollama_model"))
	if mode == "api":
		return str(Settings.read("backend_api_model"))
	return ""


func _current_backend_endpoint(mode: String) -> String:
	if mode == "ollama":
		return str(Settings.read("backend_ollama_endpoint"))
	return ""


func _caol_generate_summary_entries(preview: Dictionary, selected: Dictionary) -> Dictionary:
	var mode = str(preview.get("backend_mode", Settings.read("backend_mode")))
	var request = {
		"mode": "fixture" if OS.get_environment("LACAPULT_SUMMARIZER_FIXTURE_BACKEND") == "1" else mode,
		"backend_mode": mode,
		"backend_status": str(preview.get("backend_status", "")),
		"endpoint": _current_backend_endpoint(mode),
		"model": _current_backend_model(mode),
		"source_mod_id": str(selected.get("id", preview.get("selected_mod_id", "unknown"))),
		"source_mod_name": str(selected.get("name", preview.get("selected_mod_name", "unknown"))),
		"source_type": str(selected.get("source_type", "unknown")),
		"content_flags": selected.get("json_content", {}).get("content_flags", {}),
		"summary_status": str(selected.get("summary_status", "summary-unknown")),
	}
	var d = Directory.new()
	if d.make_dir_recursive(Paths.tmp_dir) != OK:
		return {"ok": false, "message": "could not create Catapult-Dabubu temp directory for backend bridge"}
	var stamp = _caol_apply_timestamp()
	var request_path = Paths.tmp_dir.plus_file("lacapult_summarizer_backend_request_%s.json" % stamp)
	var output_path = Paths.tmp_dir.plus_file("lacapult_summarizer_backend_output_%s.json" % stamp)
	var script_path = Paths.tmp_dir.plus_file("lacapult_summarizer_backend_bridge_%s.py" % stamp)
	_write_text_file(request_path, JSON.print(request, "  "))
	_write_text_file(script_path, _caol_backend_bridge_script())
	var output = []
	var exit_code = OS.execute(_caol_python_command(), [script_path, request_path, output_path], true, output, true)
	if exit_code != 0:
		var failed_payload = Helpers.load_json_file(output_path)
		if typeof(failed_payload) == TYPE_DICTIONARY:
			failed_payload["request"] = request
			return failed_payload
		return {"ok": false, "message": "backend bridge exited %s: %s" % [exit_code, "\n".join(output).strip_edges()], "request": request}
	var parsed = Helpers.load_json_file(output_path)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "backend bridge did not return JSON", "request": request}
	return parsed


func _caol_python_command() -> String:
	var configured = str(Settings.read("backend_python_path")).strip_edges()
	if configured != "":
		return configured
	return "python" if OS.get_name() == "Windows" else "python3"


func _caol_backend_bridge_script() -> String:
	return """
import json, sys, urllib.request

def write(path, payload):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(payload, f, indent=2, sort_keys=True)

def fixture(req):
    source_id = req.get('source_mod_id') or 'unknown'
    source_name = req.get('source_mod_name') or source_id
    return {
        'ok': True,
        'backend_mode': 'fixture',
        'message': 'fixture backend generated deterministic C-AOL summary entries; no live backend was called',
        'entries': [{
            'type': 'npc_personality_summary',
            'selector': source_id + ':context',
            'topic': source_id + '_world_context',
            'your_background': 'You know the important contextual details from ' + source_name + ' because Catapult-Dabubu generated a C-AOL-native companion summary pack.',
            'your_expression': 'Treat ' + source_name + ' as active world context loaded from a generated companion mod.',
            'source_tag': 'lacapult-generated:' + source_id,
        }],
    }

def ollama(req):
    endpoint = (req.get('endpoint') or 'http://127.0.0.1:11434').rstrip('/')
    model = req.get('model') or ''
    source_id = req.get('source_mod_id') or 'unknown'
    source_name = req.get('source_mod_name') or source_id
    if not model:
        return {'ok': False, 'backend_mode': 'ollama', 'message': 'Ollama model is not selected; no model pull was attempted.'}
    prompt = ('Generate exactly one compact JSON object for a Cataclysm: Arsenic and Old Lace NPC personality summary. '
              'Return only JSON with keys selector, topic, your_background, your_expression, source_tag. '
              'Do not invent secrets or launcher metadata. Source mod id: %s. Source mod name: %s. Content flags: %s.'
              % (source_id, source_name, json.dumps(req.get('content_flags') or {}, sort_keys=True)))
    body = json.dumps({'model': model, 'prompt': prompt, 'stream': False, 'format': 'json', 'options': {'temperature': 0.2, 'num_predict': 240}}).encode('utf-8')
    http_req = urllib.request.Request(endpoint + '/api/generate', data=body, headers={'Content-Type': 'application/json'}, method='POST')
    try:
        with urllib.request.urlopen(http_req, timeout=45) as resp:
            raw = resp.read().decode('utf-8', 'replace')
    except Exception as exc:
        return {'ok': False, 'backend_mode': 'ollama', 'message': 'Ollama generation failed before any file write: ' + str(exc), 'endpoint': endpoint, 'model': model}
    try:
        response = json.loads(raw).get('response', '').strip()
    except Exception as exc:
        return {'ok': False, 'backend_mode': 'ollama', 'message': 'Ollama response was not valid JSON envelope: ' + str(exc), 'raw_sample': raw[:500]}
    if response.startswith('```'):
        response = response.strip('`').replace('json\\n', '', 1).strip()
    try:
        entry = json.loads(response)
    except Exception as exc:
        return {'ok': False, 'backend_mode': 'ollama', 'message': 'Ollama response was not a JSON summary object: ' + str(exc), 'raw_sample': response[:500]}
    if not isinstance(entry, dict):
        return {'ok': False, 'backend_mode': 'ollama', 'message': 'Ollama response was not a JSON object.'}
    entry.setdefault('type', 'npc_personality_summary')
    entry.setdefault('selector', source_id + ':context')
    entry.setdefault('topic', source_id + '_world_context')
    entry.setdefault('your_background', 'Generated summary for ' + source_name + '.')
    entry.setdefault('your_expression', 'Refer to generated context from ' + source_name + '.')
    entry.setdefault('source_tag', 'lacapult-generated:' + source_id)
    return {'ok': True, 'backend_mode': 'ollama', 'model': model, 'message': 'Ollama generated one C-AOL summary entry; no model pull or API secret was used.', 'entries': [entry]}

def main():
    req_path, out_path = sys.argv[1], sys.argv[2]
    with open(req_path, encoding='utf-8') as f:
        req = json.load(f)
    mode = req.get('mode')
    if mode == 'fixture':
        result = fixture(req)
    elif mode == 'ollama':
        result = ollama(req)
    elif mode in ('api', 'openvino'):
        result = {'ok': False, 'backend_mode': mode, 'message': mode + ' live summary generation is still gated; no API secret, package install, model conversion, or file write was attempted.'}
    else:
        result = {'ok': False, 'backend_mode': mode or 'unknown', 'message': 'Unsupported Summarizer backend mode.'}
    write(out_path, result)
    return 0 if result.get('ok') else 2

if __name__ == '__main__':
    raise SystemExit(main())
"""


func _find_caol_status_record(status: Dictionary, mod_id: String) -> Dictionary:
	for record in status.get("mods", []):
		if record.get("id", "") == mod_id:
			return record
	return {}


func _caol_apply_result(applied: bool, preview: Dictionary, message: String, details: Dictionary) -> Dictionary:
	return {
		"action": "caol_summarizer_confirmed_apply_v0",
		"version": 1,
		"applied": applied,
		"preview": preview,
		"message": message,
		"details": details,
		"would_use_backend": preview.get("would_call_backend", false),
		"mutated_paths": [details.get("companion_pack_dir", ""), details.get("mods_json", "")] if applied else [],
		"rollback_visible": applied and details.has("backup_dir"),
	}


func _caol_apply_timestamp() -> String:
	var dt = OS.get_datetime(true)
	return "%04d%02d%02dT%02d%02d%02dZ" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]


func _safe_id_fragment(value) -> String:
	var raw = str(value).to_lower()
	var out = ""
	for i in range(raw.length()):
		var c = raw[i]
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9") or c == "_" or c == "-":
			out += c
		else:
			out += "_"
	return out.strip_edges()


func _caol_default_generated_summary_entry(source: Dictionary) -> Dictionary:
	var source_id = source.get("id", "unknown")
	var source_name = source.get("name", source_id)
	return {
		"type": "npc_personality_summary",
		"selector": "%s:context" % source_id,
		"topic": "%s_world_context" % source_id,
		"your_background": "You remember the contextual details from %s; Catapult-Dabubu staged this C-AOL-native summary pack after player confirmation." % source_name,
		"your_expression": "Treat %s as active world context loaded from a generated companion mod." % source_name,
		"source_tag": "lacapult-generated:%s" % source_id,
	}


func _read_text_file(path: String):
	var f = File.new()
	if f.open(path, File.READ) != OK:
		return null
	var text = f.get_as_text()
	f.close()
	return text


func _write_text_file(path: String, text: String) -> bool:
	var d = Directory.new()
	d.make_dir_recursive(path.get_base_dir())
	var f = File.new()
	if f.open(path, File.WRITE) != OK:
		return false
	f.store_string(text)
	f.close()
	return true


func _caol_copy_dir(source: String, target: String) -> bool:
	var d = Directory.new()
	if not d.dir_exists(source):
		return false
	d.make_dir_recursive(target)
	for item in FS.list_dir(source):
		var src = source.plus_file(item)
		var dst = target.plus_file(item)
		if d.dir_exists(src):
			_caol_copy_dir(src, dst)
		elif d.file_exists(src):
			d.copy(src, dst)
	return true


func _caol_remove_dir(path: String) -> void:
	var d = Directory.new()
	if not d.dir_exists(path):
		return
	for item in FS.list_dir(path):
		var child = path.plus_file(item)
		if d.dir_exists(child):
			_caol_remove_dir(child)
		elif d.file_exists(child):
			d.remove(child)
	d.remove(path)

