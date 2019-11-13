-- SELECT * FROM move_damage_classes;
-- id          identifier
-- ----------  ----------
-- 1           status
-- 2           physical
-- 3           special

SELECT 
    moves.identifier AS 'move',
    pokemon_move_methods.identifier AS method,
    pokemon_moves.level,
    moves.power + 
        IFNULL(atk_stats.base_stat, 0) + 
        IFNULL(sp_atk_stats.base_stat, 0) AS power,
    moves.pp,
    21 - CAST(ROUND(moves.accuracy / 5) AS INT) AS accuracy,
    moves.priority,
    move_targets.identifier AS 'target',
    21 - CAST(ROUND(moves.effect_chance / 5) AS INT) AS effect_chance,
    types.identifier AS element,
    move_damage_classes.identifier AS dmg_type,
    REPLACE(move_flavor_text.flavor_text, '
', ' ') AS 'description'
FROM pokemon_moves
    INNER JOIN moves    
        ON pokemon_moves.move_id = moves.id
    INNER JOIN pokemon_move_methods
        ON pokemon_moves.pokemon_move_method_id = pokemon_move_methods.id
    INNER JOIN move_targets
        ON  move_targets.id = moves.target_id
    INNER JOIN types
        ON  moves.type_id = types.id
    INNER JOIN move_damage_classes
        ON moves.damage_class_id = move_damage_classes.id
    LEFT JOIN move_flavor_text
        ON moves.id = move_flavor_text.move_id
        AND move_flavor_text.version_group_id = 7
        AND move_flavor_text.language_id = 9
    -- Select only if it's special
    LEFT JOIN pokemon_stats AS atk_stats
        ON pokemon_moves.pokemon_id = atk_stats.pokemon_id
        AND atk_stats.stat_id = 2
        AND move_damage_classes.id = 2
    -- Select only if it's physical
    LEFT JOIN pokemon_stats AS sp_atk_stats
        ON pokemon_moves.pokemon_id = sp_atk_stats.pokemon_id
        AND sp_atk_stats.stat_id = 4
        AND move_damage_classes.id = 3
-- Firered/Leafgreen
WHERE pokemon_moves.version_group_id = 7
    AND pokemon_moves.pokemon_id = ?
ORDER BY 
    pokemon_move_methods.identifier, 
    pokemon_moves.level