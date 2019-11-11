SELECT 
    moves.id,
    moves.identifier AS 'name',
    CAST(ROUND(moves.power / 10) AS INTEGER) AS power,
    moves.pp,
    moves.accuracy,
    moves.priority,
    move_targets.identifier AS 'target',
    moves.effect_chance,
    types.identifier AS element,
    move_damage_classes.identifier AS dmg_type,
    REPLACE(move_flavor_text.flavor_text, '
', ' ') AS 'description',
    move_effect_prose.effect
FROM pokemon_moves
    INNER JOIN moves
        ON pokemon_moves.move_id = moves.id
    INNER JOIN types
        ON moves.type_id = types.id
    INNER JOIN move_damage_classes
        ON moves.damage_class_id = move_damage_classes.id
    INNER JOIN move_targets
        ON moves.target_id = move_targets.id
    INNER JOIN move_flavor_text
        ON moves.id = move_flavor_text.move_id
    LEFT JOIN move_effect_prose
        ON move_effect_prose.move_effect_id = moves.effect_id
WHERE moves.generation_id <= 3
    AND move_flavor_text.version_group_id = 7
    AND move_flavor_text.language_id = 9
    AND pokemon_moves.pokemon_id = ?

