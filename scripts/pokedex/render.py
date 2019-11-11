import sqlite3
import pystache

DB_LOCATION = "/Users/chadhartman/Documents/external/games/pokemon/veekun-pokedex.sqlite"
GENDER = {
    -1: "None",
    0: "100% &#9794; 0% &#9792; ",
    1: "87.5% &#9794; (1-17), 12.5% &#9792; (18-20)",
    2: "75% &#9794; (1-15), 25% &#9792; (16-20)",
    4: "50% &#9794; (1-10), 50% &#9792; (11-20)",
    6: "25% &#9794; (1-5), 75% &#9792; (6-20)",
    7: "12.5% &#9794; (1-3), 87.5% &#9792; (4-20)",
    8: "0% &#9794;, 100% &#9792;"
}


def __d20_chance__(value, max_value):
    return 20 - int(round((19 * value / max_value)))


def __load_file__(path):
    with open(path, "r") as f:
        return f.read()


def __query__(conn, query_path, args=None):

    c = conn.cursor()
    if args is None:
        c.execute(__load_file__(query_path))
    else:
        c.execute(__load_file__(query_path), args)

    records = []

    row_index = 0
    for row in c.fetchall():

        record = {"row_index": row_index}
        row_index += 1
        records.append(record)
        keys = row.keys()

        # Set columns
        for i in range(len(row)):

            value = row[i]
            if value is None:
                continue

            if isinstance(value, unicode):

                new_val = ""

                for char in value:
                    if ord(char) <= 128:
                        new_val += char

                value = new_val

            record[keys[i]] = value

    return records


def __load_pokedex__(conn):
    pokedex = __query__(conn, "sql/pokedex.sql")
    return {"pokedex": pokedex}


def __load_pokemon__(conn, pokemon_data):

    pokemon_data["moves"] = __query__(
        conn,
        "sql/pokemon_moves.sql",
        (pokemon_data["id"],))

    return pokemon_data


def __render__(template_data, template_path, out_path):

    outfile = pystache.render(out_path, template_data)

    template = __load_file__(template_path)

    with open(outfile, "w") as f:
        f.write(pystache.render(template, template_data))

    print "Created", outfile


def __load_habitat__(conn):

    habitats = __query__(conn, "sql/habitats.sql")
    for habitat in habitats:

        pokemon = __query__(
            conn, "sql/habitat_info.sql", (habitat["id"],))

        habitat["pokemon"] = pokemon

        for mon in pokemon:
            mon["appear"] = __d20_chance__(mon["appear"], 255.0)

    return {"habitats": habitats}


def __load_items__(conn):

    items = __query__(conn, "sql/items.sql")

    return {"items": items}


def __load_moves__(conn):

    moves = __query__(conn, "sql/moves.sql")

    for move in moves:

        if "accuracy" not in move:
            continue

        move["accuracy"] = __d20_chance__(move["accuracy"], 100.0)

    return {"moves": moves}


def __load_evolutions__(conn):
    evolutions = __query__(conn, "sql/evolutions.sql")

    for evo in evolutions:

        if evo["needs_overworld_rain"] == 0:
            del evo["needs_overworld_rain"]

        if evo["turn_upside_down"] == 0:
            del evo["turn_upside_down"]

    return {"evolutions": evolutions}


def main():

    conn = sqlite3.connect(DB_LOCATION)
    conn.row_factory = sqlite3.Row

    pokedex_data = __load_pokedex__(conn)

    # __render__(
    #     pokedex_data,
    #     "templates/pokedex.html",
    #     "out/pokedex.html"
    # )

    count = 0

    for pokemon in pokedex_data["pokedex"]:
        __render__(
            __load_pokemon__(conn, pokemon),
            "templates/pokemon-{{id}}.html",
            "out/pokemon-{{id}}.html"
        )
        count += 1
        if count >= 3:
            break

    # __render__(
    #     __load_moves__(conn),
    #     "templates/moves.html",
    #     "out/moves.html"
    # )

    # __render__(
    #     __load_habitat__(conn),
    #     "templates/habitat.html",
    #     "out/habitat.html"
    # )

    # __render__(
    #     __load_items__(conn),
    #     "templates/items.html",
    #     "out/items.html"
    # )

    # import json
    # print json.dumps(__load_evolutions__(conn), indent=4)


if __name__ == "__main__":
    main()
