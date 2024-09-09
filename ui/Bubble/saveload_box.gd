extends CanvasLayer

var game_data: GameDataResource
var config = ConfigFile.new()

const SAVE_DIR = "user://game_data/"
const SAVE_FILE_NAME = "game_data.tres"
const CONFIG_FILE_PATH = "user://game_config.ini"

func _ready():
    if not DirAccess.dir_exists_absolute(SAVE_DIR):
        DirAccess.make_dir_absolute(SAVE_DIR)
    
    if not FileAccess.file_exists(CONFIG_FILE_PATH):
        _create_default_config()
    else:
        config.load(CONFIG_FILE_PATH)
    
    load_game_data()

func _create_default_config():
    config.set_value("game", "current_wave", 0)
    config.set_value("game", "damage_upgrade", 0)
    config.set_value("collectibles", "total_award_amount", 0)
    config.save(CONFIG_FILE_PATH)

func load_game_data():
    if ResourceLoader.exists(SAVE_DIR + SAVE_FILE_NAME):
        game_data = ResourceLoader.load(SAVE_DIR + SAVE_FILE_NAME)
    
    if game_data == null:
        game_data = GameDataResource.new()
    
    # Load data from config
    GameManager.current_wave = config.get_value("game", "current_wave", 0)
    GameManager.damage_upgrade = config.get_value("game", "damage_upgrade", 0)
    CollectibleManager.total_award_amount = config.get_value("collectibles", "total_award_amount")
    
    # Load data from game_data resource
    HealthManager.current_health = game_data.current_health
    HealthManager.max_health = game_data.max_health

func save_game_data():
    print("Attempting to save game data")
    
    # Save data to config
    config.set_value("game", "current_wave", GameManager.current_wave)
    config.set_value("game", "damage_upgrade", GameManager.damage_upgrade)
    config.set_value("collectibles", "total_award_amount", CollectibleManager.total_award_amount)
    config.save(CONFIG_FILE_PATH)
    
    # Save data to game_data resource
    game_data.current_health = HealthManager.current_health
    game_data.max_health = HealthManager.max_health
    
    var save_result = ResourceSaver.save(game_data, SAVE_DIR + SAVE_FILE_NAME)
    if save_result == OK:
        print("Game data saved successfully")
    else:
        print("Failed to save game data")

func _on_upgrade_button_pressed():
    print("Upgrade button pressed")
    save_game_data()

func _on_close_button_pressed():
    print("Close button pressed")
    load_game_data()