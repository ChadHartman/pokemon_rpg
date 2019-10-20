
SELECT 
    pokemon_species.id,
    pokemon_species.identifier AS pokemon,
    pokemon_evolution.minimum_level,
    evolution_triggers.identifier AS trigger,
    trigger_items.identifier AS held_item,
    pokemon_evolution.gender_id,
    pokemon_evolution.location_id,
    held_items.identifier AS held_item,
    pokemon_evolution.time_of_day,
    moves.identifier AS known_move,
    move_types.identifier AS known_move_type,
    minimum_happiness,
    minimum_beauty,
    minimum_affection,
    relative_physical_stats,
    party_species.identifier AS party_species,
    party_types.identifier AS party_type,
    trade_species.identifier AS trade_species,
    pokemon_evolution.needs_overworld_rain,
    pokemon_evolution.turn_upside_down
FROM pokemon_evolution
    INNER JOIN pokemon_species
        ON pokemon_evolution.evolved_species_id = pokemon_species.id
            AND pokemon_species.generation_id <= 3
    INNER JOIN evolution_triggers
        ON pokemon_evolution.evolution_trigger_id = evolution_triggers.id
    LEFT JOIN moves
        ON pokemon_evolution.known_move_id = moves.id
    LEFT JOIN types AS move_types
        ON pokemon_evolution.known_move_type_id = move_types.id
    LEFT JOIN items AS trigger_items
        ON pokemon_evolution.trigger_item_id = trigger_items.id
    LEFT JOIN items AS held_items
        ON pokemon_evolution.held_item_id = held_items.id
    LEFT JOIN pokemon_species AS party_species
        ON pokemon_evolution.party_species_id = party_species.id
    LEFT JOIN types AS party_types
        ON pokemon_evolution.party_type_id = party_types.id
    LEFT JOIN pokemon_species AS trade_species
        ON pokemon_evolution.trade_species_id = trade_species.id
ORDER BY pokemon_species.id