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
    -- Abilities
    ability1.identifier AS ability1_name,
    ability2.identifier AS ability2_name,
    ability_text1.flavor_text AS ability1_description,
    ability_text2.flavor_text AS ability2_description,
    -- Navigation
    previous_pkmn.id AS prev_id,
    previous_pkmn.identifier AS prev_name,
    next_pkmn.id AS next_id,
    next_pkmn.identifier AS next_name,
    -- Evolution
    pokemon_evolution.minimum_level AS ev_min_lvl,
    evolution_triggers.identifier AS ev_trigger,
    trigger_items.identifier AS ev_trigger_item,
    held_items.identifier AS ev_held_item,
    pokemon_evolution.time_of_day AS ev_time_of_day,
    pokemon_evolution.minimum_happiness AS ev_min_happy,
    pokemon_evolution.minimum_beauty AS ev_min_beauty,
    pokemon_evolution.relative_physical_stats AS ev_rel_phys_stats,
    ev_moves.identifier AS ev_known_move,
    party_species.id AS ev_party_species_id,
    party_species.identifier AS ev_party_species_name,
    -- Pokedex
    REPLACE(pokemon_species_flavor_text.flavor_text, '
', ' ') AS description
FROM pokemon_species 
    INNER JOIN pokemon_habitats
        ON pokemon_species.habitat_id = pokemon_habitats.id
    -- Stats
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
    -- Types
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
    -- Abilities
    INNER JOIN pokemon_abilities AS mob_ability1
        ON pokemon_species.id = mob_ability1.pokemon_id
        AND mob_ability1.is_hidden = 0
        AND mob_ability1.slot = 1
    INNER JOIN abilities AS ability1
        ON mob_ability1.ability_id = ability1.id
    INNER JOIN ability_flavor_text AS ability_text1
        ON ability1.id = ability_text1.ability_id
        AND ability_text1.version_group_id = 7
        AND ability_text1.language_id = 9
    LEFT JOIN pokemon_abilities AS mob_ability2
        ON pokemon_species.id = mob_ability2.pokemon_id
        AND mob_ability2.is_hidden = 0
        AND mob_ability2.slot = 2
    LEFT JOIN abilities AS ability2
        ON mob_ability2.ability_id = ability2.id
    LEFT JOIN ability_flavor_text AS ability_text2
        ON ability2.id = ability_text2.ability_id
        AND ability_text2.version_group_id = 7
        AND ability_text2.language_id = 9
    -- Navigation
    LEFT JOIN pokemon AS previous_pkmn
        ON (pokemon_species.id - 1) = previous_pkmn.id
    LEFT JOIN pokemon AS next_pkmn
        ON (pokemon_species.id + 1) = next_pkmn.id
    -- Pokedex entry
    INNER JOIN pokemon_species_flavor_text
        ON pokemon_species.id = pokemon_species_flavor_text.species_id
        AND pokemon_species_flavor_text.language_id = 9
        AND pokemon_species_flavor_text.version_id = 7
    -- Evolution
    LEFT JOIN pokemon_evolution
        ON pokemon_species.id = pokemon_evolution.evolved_species_id
    LEFT JOIN evolution_triggers
        ON pokemon_evolution.evolution_trigger_id = evolution_triggers.id
    LEFT JOIN items AS trigger_items
        ON pokemon_evolution.trigger_item_id = trigger_items.id
    LEFT JOIN items AS held_items
        ON pokemon_evolution.held_item_id = held_items.id
    LEFT JOIN moves AS ev_moves
        ON pokemon_evolution.known_move_id = ev_moves.id
    LEFT JOIN pokemon_species AS party_species
        ON pokemon_evolution.party_species_id = party_species.id
WHERE pokemon_species.generation_id <= 3