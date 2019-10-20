SELECT 
    pokemon_habitats.identifier AS habitat,
    pokemon_species.identifier AS pokemon,
    pokemon_species.capture_rate AS appear
FROM pokemon_species 
    INNER JOIN pokemon_habitats
        ON pokemon_species.habitat_id = pokemon_habitats.id
WHERE pokemon_habitats.id = ?
ORDER BY habitat, capture_rate DESC
