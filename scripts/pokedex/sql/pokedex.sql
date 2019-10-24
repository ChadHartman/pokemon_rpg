SELECT 
    id, 
    identifier AS 'name'
FROM pokemon_species 
WHERE generation_id <= 3;