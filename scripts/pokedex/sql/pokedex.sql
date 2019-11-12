SELECT 
    pokemon_species.id, 
    pokemon_species.identifier AS 'name',
    type1.identifier AS type1,
    type2.identifier AS type2,
    pokemon_species.gender_rate,
    CAST(ROUND(((-19 * pokemon_species.capture_rate) + 5099) / 254) AS INT) AS capture_rate,
    pokemon_habitats.identifier AS habitat,
    -- 1 -> 1; 255 -> 100
    CAST(ROUND((155 + (99 * hp_stats.base_stat)) / 254) AS INT) AS hp,
    atk_stats.base_stat AS atk,
    def_stats.base_stat AS def,
    sp_atk_stats.base_stat AS sp_atk,
    sp_def_stats.base_stat AS sp_def,
    spd_stats.base_stat AS spd,
    CAST(ROUND((spd_stats.base_stat + sp_atk_stats.base_stat) / 20.0) AS INT) AS 'int',
    CAST(ROUND((
            hp_stats.base_stat +
            atk_stats.base_stat +
            def_stats.base_stat +
            sp_atk_stats.base_stat +
            sp_def_stats.base_stat +
            spd_stats.base_stat
        ) / 6.0) AS INT) AS pwr,
    previous_pkmn.id AS prev_id,
    previous_pkmn.identifier AS prev_name,
    next_pkmn.id AS next_id,
    next_pkmn.identifier AS next_name
FROM pokemon_species 
    INNER JOIN pokemon_habitats
        ON pokemon_species.habitat_id = pokemon_habitats.id
    INNER JOIN pokemon_stats AS hp_stats
        ON  pokemon_species.id = hp_stats.pokemon_id
        AND hp_stats.stat_id = 1
    INNER JOIN pokemon_stats AS atk_stats
        ON  pokemon_species.id = atk_stats.pokemon_id
        AND atk_stats.stat_id = 2
    INNER JOIN pokemon_stats AS def_stats
        ON  pokemon_species.id = def_stats.pokemon_id
        AND def_stats.stat_id = 3
    INNER JOIN pokemon_stats AS sp_atk_stats
        ON  pokemon_species.id = sp_atk_stats.pokemon_id
        AND sp_atk_stats.stat_id = 4
    INNER JOIN pokemon_stats AS sp_def_stats
        ON  pokemon_species.id = sp_def_stats.pokemon_id
        AND sp_def_stats.stat_id = 5
    INNER JOIN pokemon_stats AS spd_stats
        ON  pokemon_species.id = spd_stats.pokemon_id
        AND spd_stats.stat_id = 6
    INNER JOIN pokemon_types AS pkmn_type1
        ON pokemon_species.id = pkmn_type1.pokemon_id 
        AND pkmn_type1.slot = 1
    INNER JOIN types AS type1
        ON pkmn_type1.type_id = type1.id
    LEFT JOIN pokemon_types AS pkmn_type2
        ON pokemon_species.id = pkmn_type2.pokemon_id 
        AND pkmn_type2.slot = 2
    LEFT JOIN types AS type2
        ON pkmn_type2.type_id = type2.id
    LEFT JOIN pokemon AS previous_pkmn
        ON (pokemon_species.id - 1) = previous_pkmn.id
    LEFT JOIN pokemon AS next_pkmn
        ON (pokemon_species.id + 1) = next_pkmn.id
WHERE pokemon_species.generation_id <= 3