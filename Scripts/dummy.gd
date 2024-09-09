#save file

MainScene (Node2D)
├── Player (CharacterBody2D)
├── Bullets (Node2D or another appropriate type)
├── Muzzle (Node2D or another appropriate type)
├── Enemies (Node2D)
│   ├── Enemy1 (CharacterBody2D)
│   ├── Enemy2 (CharacterBody2D)
│   └── ...
├── Items (Node2D)
│   ├── Item1 (Node2D)
│   ├── Item2 (Node2D)
│   └── ...

extends CanvasLayer

var save_path = "user://game_data/variable.save"

func _on_upgrade_button_pressed():
    save()

func _on_close_button_pressed():
    load_data()

func save():
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    file.store_var(HealthManager.current_health)
    file.store_var(HealthManager.max_health)
    file.store_var(GameManager.damage_upgrade)
    file.store_var(GameManager.current_wave)
    file.store_var(CollectibleManager.total_award_amount)
    
    # Save player position
    var player = get_tree().get_root().get_node("Player")
    file.store_var(player.global_position)
    
    # Save bullets damage amount
    var bullets = get_tree().get_root().get_node("Bullets")
    file.store_var(bullets.damage_amount)
    
    # Save muzzle damage amount
    var muzzle = get_tree().get_root().get_node("Muzzle")
    file.store_var(muzzle.damage_amount)
    
    # Save enemies positions and states
    var enemies = get_tree().get_nodes_in_group("Enemy")
    var enemies_data = []
    for enemy in enemies:
        enemies_data.append({
            "position": enemy.global_position,
            "health": enemy.health,
            "state": enemy.state
        })
    file.store_var(enemies_data)
    
    # Save items positions and states
    var items = get_tree().get_nodes_in_group("Items")
    var items_data = []
    for item in items:
        items_data.append({
            "position": item.global_position,
            "condition": item.condition
        })
    file.store_var(items_data)

func load_data():
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        HealthManager.current_health = file.get_var()
        HealthManager.max_health = file.get_var()
        GameManager.damage_upgrade = file.get_var()
        GameManager.current_wave = file.get_var()
        CollectibleManager.total_award_amount = file.get_var()
        
        # Load player position
        var player = get_tree().get_root().get_node("Player")
        player.global_position = file.get_var()
        
        # Load bullets damage amount
        var bullets = get_tree().get_root().get_node("Bullets")
        bullets.damage_amount = file.get_var()
        
        # Load muzzle damage amount
        var muzzle = get_tree().get_root().get_node("Muzzle")
        muzzle.damage_amount = file.get_var()
        
        # Load enemies positions and states
        var enemies_data = file.get_var()
        var enemies = get_tree().get_nodes_in_group("Enemy")
        for i in range(len(enemies)):
            enemies[i].global_position = enemies_data[i]["position"]
            enemies[i].health = enemies_data[i]["health"]
            enemies[i].state = enemies_data[i]["state"]
        
        # Load items positions and states
        var items_data = file.get_var()
        var items = get_tree().get_nodes_in_group("Items")
        for i in range(len(items)):
            items[i].global_position = items_data[i]["position"]
            items[i].condition = items_data[i]["condition"]
    else:
        print("No save file found.")
        HealthManager.current_health = 3
        HealthManager.max_health = 3
        GameManager.damage_upgrade = 0
        GameManager.current_wave = 0
        CollectibleManager.total_award_amount = 0
        bullets.damage_amount = 1
        muzzle.damage_amount = 1