SELECT 
    pokemon_species.id,
    pokemon_species.identifier AS 'name', 
    pokemon_species.gender_rate, 
    pokemon_species.capture_rate, 
    growth_rates.identifier AS growth_rate,
    pokemon_habitats.identifier AS habitat,
    hp_stats.base_stat AS hp,
    atk_stats.base_stat AS atk,
    def_stats.base_stat AS def,
    sp_atk_stats.base_stat AS sp_atk,
    sp_def_stats.base_stat AS sp_def,
    spd_stats.base_stat AS spd,
    types1.identifier AS type1,
    types2.identifier AS type2,
    abilities1.identifier AS ability1_name,
    REPLACE(ability_prose1.effect, '
', ' ') AS ability1_text,
    abilities2.identifier AS ability2_name,
    REPLACE(ability_prose2.effect, '
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
    INNER JOIN pokemon_stats AS hp_stats
        ON hp_stats.pokemon_id = pokemon_species.id
            AND hp_stats.stat_id = 1 
    INNER JOIN pokemon_stats AS atk_stats
        ON atk_stats.pokemon_id = pokemon_species.id
            AND atk_stats.stat_id = 2
    INNER JOIN pokemon_stats AS def_stats
        ON def_stats.pokemon_id = pokemon_species.id
            AND def_stats.stat_id = 3
    INNER JOIN pokemon_stats AS sp_atk_stats
        ON sp_atk_stats.pokemon_id = pokemon_species.id
            AND sp_atk_stats.stat_id = 4
    INNER JOIN pokemon_stats AS sp_def_stats
        ON sp_def_stats.pokemon_id = pokemon_species.id
            AND sp_def_stats.stat_id = 5
    INNER JOIN pokemon_stats AS spd_stats
        ON spd_stats.pokemon_id = pokemon_species.id
            AND spd_stats.stat_id = 6
    -- types
    INNER JOIN pokemon_types AS pokemon_types1
        ON pokemon_types1.pokemon_id = pokemon_species.id
            AND pokemon_types1.slot = 1
    INNER JOIN types AS types1
        ON pokemon_types1.type_id = types1.id
    LEFT JOIN pokemon_types AS pokemon_types2
        ON pokemon_types2.pokemon_id = pokemon_species.id
            AND pokemon_types2.slot = 2
    LEFT JOIN types AS types2
        ON pokemon_types2.type_id = types2.id
    -- abilities
    INNER JOIN pokemon_abilities AS pokemon_abilities1
        ON pokemon_abilities1.pokemon_id = pokemon_species.id
            AND pokemon_abilities1.is_hidden = 0
            AND pokemon_abilities1.slot = 1
    INNER JOIN abilities AS abilities1
        ON pokemon_abilities1.ability_id = abilities1.id
    INNER JOIN ability_prose AS ability_prose1
        ON pokemon_abilities1.ability_id = ability_prose1.ability_id
            AND ability_prose1.local_language_id = 9
    LEFT JOIN pokemon_abilities AS pokemon_abilities2
        ON pokemon_abilities2.pokemon_id = pokemon_species.id
            AND pokemon_abilities2.is_hidden = 0
            AND pokemon_abilities2.slot = 2
    LEFT JOIN abilities AS abilities2
        ON pokemon_abilities2.ability_id = abilities2.id
            AND abilities2.generation_id <= 3
    LEFT JOIN ability_prose AS ability_prose2
        ON pokemon_abilities2.ability_id = ability_prose2.ability_id
            AND ability_prose2.local_language_id = 9

WHERE pokemon_species.generation_id <= 3
    AND pokemon_species.id >= ?
    AND pokemon_species.id <= ?
ORDER BY pokemon_species.id
