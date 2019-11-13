SELECT 
    items.id,
    items.identifier AS 'name',
    items.cost,
    item_categories.identifier AS category,
    REPLACE(item_flavor_text.flavor_text, '
', ' ') AS 'description',
    item_prose.effect
FROM items
    INNER JOIN item_categories
        ON items.category_id = item_categories.id
    INNER JOIN item_flavor_text
        ON items.id = item_flavor_text.item_id
            AND item_flavor_text.version_group_id = 7
            AND item_flavor_text.language_id = 9
    INNER JOIN item_game_indices
        ON  items.id = item_game_indices.item_id
            AND item_game_indices.generation_id <= 3
    INNER JOIN item_prose
        ON items.id = item_prose.item_id
            AND local_language_id = 9
WHERE items.category_id NOT IN (
    2, 4, 6, 8, 9, 13, 14, 17, 20, 21, 22, 23, 25, 26, 32, 36, 41, 42, 43, 44, 45, 46
)
ORDER BY item_categories.identifier, items.cost
-- items.identifier