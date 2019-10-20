SELECT 
    moves.identifier AS 'move',
    pokemon_move_methods.identifier AS method,
    pokemon_moves.level
FROM pokemon_moves
    INNER JOIN moves    
        ON pokemon_moves.move_id = moves.id
    INNER JOIN pokemon_move_methods
        ON pokemon_moves.pokemon_move_method_id = pokemon_move_methods.id
-- Firered/Leafgreen
WHERE pokemon_moves.version_group_id = 7
    AND pokemon_moves.pokemon_id = ?
ORDER BY 
    pokemon_move_methods.identifier, 
    pokemon_moves.level




