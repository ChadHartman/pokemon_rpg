SELECT 
    pokemon_species.id,

    pokemon_species.identifier AS 'name', 

    pokemon_species.gender_rate, 

    pokemon_species.capture_rate, 

    growth_rates.identifier AS growth_rate,

    pokemon_habitats.identifier AS habitat,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 1 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS hp,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 2 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS atk,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 3 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS def,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 4 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS sp_atk,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 5 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS sp_def,

    (SELECT pokemon_stats.base_stat 
    FROM pokemon_stats 
    WHERE pokemon_stats.stat_id = 6 
        AND pokemon_stats.pokemon_id = pokemon_species.id) AS spd,

    (SELECT types.identifier
    FROM pokemon_types
        INNER JOIN types
            ON pokemon_types.type_id = types.id
    WHERE pokemon_types.pokemon_id = pokemon_species.id
        AND pokemon_types.slot = 1) AS type1,

    (SELECT types.identifier
    FROM pokemon_types
        INNER JOIN types
            ON pokemon_types.type_id = types.id
    WHERE pokemon_types.pokemon_id = pokemon_species.id
        AND pokemon_types.slot = 2) AS type2,

    (SELECT abilities.identifier 
    FROM pokemon_abilities
        INNER JOIN abilities
            ON pokemon_abilities.ability_id = abilities.id
                AND abilities.generation_id <= 3
                AND pokemon_abilities.is_hidden = 0
                AND pokemon_abilities.slot = 1
    WHERE pokemon_abilities.pokemon_id = pokemon_species.id) AS ability1_name,

    REPLACE((SELECT ability_prose.effect
    FROM pokemon_abilities
        INNER JOIN abilities
            ON pokemon_abilities.ability_id = abilities.id
                AND abilities.generation_id <= 3
                AND pokemon_abilities.is_hidden = 0
                AND pokemon_abilities.slot = 1
        INNER JOIN ability_prose
            ON pokemon_abilities.ability_id = ability_prose.ability_id
                AND ability_prose.local_language_id = 9
    WHERE pokemon_abilities.pokemon_id = pokemon_species.id), '
', ' ') AS ability1_text,

    (SELECT abilities.identifier
    FROM pokemon_abilities
        INNER JOIN abilities
            ON pokemon_abilities.ability_id = abilities.id
                AND abilities.generation_id <= 3
                AND pokemon_abilities.is_hidden = 0
                AND pokemon_abilities.slot = 2
    WHERE pokemon_abilities.pokemon_id = pokemon_species.id) AS ability2_name,

    REPLACE((SELECT ability_prose.effect
    FROM pokemon_abilities
        INNER JOIN abilities
            ON pokemon_abilities.ability_id = abilities.id
                AND abilities.generation_id <= 3
                AND pokemon_abilities.is_hidden = 0
                AND pokemon_abilities.slot = 2
        INNER JOIN ability_prose
            ON pokemon_abilities.ability_id = ability_prose.ability_id
                AND ability_prose.local_language_id = 9
    WHERE pokemon_abilities.pokemon_id = pokemon_species.id), '
', ' ') AS ability2_text,

    REPLACE(pokemon_species_flavor_text.flavor_text, '
', ' ') AS 'description'

FROM pokemon_species 
    INNER JOIN growth_rates 
        ON pokemon_species.growth_rate_id = growth_rates.id
    INNER JOIN pokemon_habitats
        ON pokemon_species.habitat_id = pokemon_habitats.id
    INNER JOIN pokemon_species_flavor_text
        ON pokemon_species.id = pokemon_species_flavor_text.species_id
            AND pokemon_species_flavor_text.version_id = 7
            AND pokemon_species_flavor_text.language_id = 9
WHERE pokemon_species.generation_id <= 3
    AND pokemon_species.id >= ? 
    AND pokemon_species.id <= ? 
ORDER BY pokemon_species.id
