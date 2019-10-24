import sqlite3
import pystache
from math import ceil

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


def __load_pokemon__(conn, start_id, end_id):

    pokedex = __query__(conn, "sql/pokemon.sql", (start_id, end_id))
    for mon in pokedex:
        mon["gender_rate"] = GENDER[mon["gender_rate"]]
        # Ensures hp will be between 5-100
        mon["hp"] = int(ceil(((19.0 / 49.0) * mon["hp"]) + (55.0 / 49.0)))
        mon["atk"] = int(ceil(mon["atk"] / 10.0))
        mon["def"] = int(ceil(mon["def"] / 10.0))
        mon["sp_atk"] = int(ceil(mon["sp_atk"] / 10.0))
        mon["sp_def"] = int(ceil(mon["sp_def"] / 10.0))
        mon["spd"] = int(ceil(mon["spd"] / 10.0))
        mon["capture_rate"] = __d20_chance__(mon["capture_rate"],  255.0)
        mon["moves"] = __query__(conn, "sql/pokemon_moves.sql", (mon["id"],))

    return {"pokemon": pokedex}


def __render__(template_data, template_path, out_path):
    template = __load_file__(template_path)

    with open(out_path, "w") as f:
        f.write(pystache.render(template, template_data))

    print "Created", out_path


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

    __render__(
        __load_pokedex__(conn),
        "templates/pokedex.html",
        "out/pokedex.html"
    )

    # __render__(
    #     __load_moves__(conn),
    #     "templates/moves.html",
    #     "out/moves.html"
    # )

    # __render__(
    #     __load_pokemon__(conn, 1, 151),
    #     "templates/pokedex.html",
    #     "out/pokedex1.html"
    # )

    # __render__(
    #     __load_pokemon__(conn, 152, 251),
    #     "templates/pokedex.html",
    #     "out/pokedex2.html"
    # )

    # __render__(
    #     __load_pokemon__(conn, 252, 386),
    #     "templates/pokedex.html",
    #     "out/pokedex3.html"
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
