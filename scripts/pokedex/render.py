import sqlite3
import pystache
import json

DEBUG = True
MAX_ATK = 385
MIN_ATK = 20
MAX_HP = 255
MIN_HP = 1
MAX_DEF = 230
MIN_DEF = 5
MAX_SPD = 160
MIN_SPD = 5


# def __d20_chance__(value, max_value):
#     return 20 - int(round((19 * value / max_value)))


# def __load_json__(path):
#     with open(path, "r") as f:
#         return json.load(f)


# def __load_habitat__(conn):

#     habitats = __query__(conn, "sql/habitats.sql")
#     for habitat in habitats:

#         pokemon = __query__(
#             conn, "sql/habitat_info.sql", (habitat["id"],))

#         habitat["pokemon"] = pokemon

#         for mon in pokemon:
#             mon["appear"] = __d20_chance__(mon["appear"], 255.0)

#     return {"habitats": habitats}


# def __load_items__(conn):

#     items = __query__(conn, "sql/items.sql")

#     return {"items": items}


# def __load_evolutions__(conn):
#     evolutions = __query__(conn, "sql/evolutions.sql")

#     for evo in evolutions:

#         if evo["needs_overworld_rain"] == 0:
#             del evo["needs_overworld_rain"]

#         if evo["turn_upside_down"] == 0:
#             del evo["turn_upside_down"]

#     return {"evolutions": evolutions}


class Renderer(object):

    DB_LOCATION = "/Users/chadhartman/Documents/external/games/pokemon/veekun-pokedex.sqlite"

    def __init__(self):
        self.conn = sqlite3.connect(self.DB_LOCATION)
        self.conn.row_factory = sqlite3.Row
        self.pokedex = None
        self.gender_rate_male = None
        self.gender_rate_female = None
        self.move_methods = None
        self.rolls = None

    def __load_file__(self, path):
        with open(path, "r") as f:
            return f.read()

    def __load_gender_rate_male__(self):

        if self.gender_rate_male is None:
            with open("data/gender_rate_male.json", "r") as f:
                self.gender_rate_male = json.load(f)

        return self.gender_rate_male

    def __load_gender_rate_female__(self):

        if self.gender_rate_female is None:
            with open("data/gender_rate_female.json", "r") as f:
                self.gender_rate_female = json.load(f)

        return self.gender_rate_female

    def __load_move_methods__(self):

        if self.move_methods is None:
            with open("data/move_learn_methods.json", "r") as f:
                self.move_methods = json.load(f)

        return self.move_methods

    def __load_rolls__(self):
        if self.rolls is None:
            with open("data/rolls.json", "r") as f:
                self.rolls = json.load(f)

        return self.rolls

    def __query__(self, query_path, args=None):

        c = self.conn.cursor()
        if args is None:
            c.execute(self.__load_file__(query_path))
        else:
            c.execute(self.__load_file__(query_path), args)

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

    def __render__(self, template_data, template_path, out_path):

        outfile = pystache.render(out_path, template_data)

        template = self.__load_file__(template_path)

        with open(outfile, "w") as f:
            f.write(pystache.render(template, template_data))

        print "Created", outfile

    def __lookup_roll__(self, min_value, value, max_value):
        adj_max = max_value - min_value
        adj_val = value - min_value
        rolls = self.__load_rolls__()
        max_index = len(rolls) - 1
        index = int(round(max_index * adj_val / adj_max))
        return rolls[index]

    def __load_pokedex__(self):

        if self.pokedex is None:
            data = self.__query__("sql/pokedex.sql")
            self.pokedex = {"pokedex": data}

        return self.pokedex

    def __load_pokemon__(self, mon):

        if "loaded" in mon:
            return mon

        mon["roll_def"] = self.__lookup_roll__(MIN_DEF, mon["def"], MAX_DEF)
        mon["roll_sp_def"] = self.__lookup_roll__(
            MIN_DEF, mon["sp_def"], MAX_DEF)
        mon["roll_spd"] = self.__lookup_roll__(MIN_SPD, mon["spd"], MAX_SPD)

        # Gender
        gender_rate = str(mon["gender_rate"])

        mon["gender_rate_male"] =  \
            self.__load_gender_rate_male__()[gender_rate]
        mon["gender_rate_female"] = \
            self.__load_gender_rate_female__()[gender_rate]

        # Moves
        mon["moves"] = self.__query__(
            "sql/pokemon_moves.sql",
            (mon["id"],))

        for move in mon["moves"]:
            if "power" in move:
                power = self.__lookup_roll__(MIN_ATK, move["power"], MAX_ATK)
                move["power"] = power

            method = move["method"]

            if method in self.__load_move_methods__():
                move["method"] = self.move_methods[method]

            if move["level"] == 0:
                del move["level"]

        # Flag
        mon["loaded"] = True

        return mon

    def render_pokedex(self):
        self.__render__(
            self.__load_pokedex__(),
            "templates/pokedex.html",
            "out/pokedex.html"
        )

    def render_pokemon(self):

        count = 0
        for mon in self.__load_pokedex__()["pokedex"]:
            self.__render__(
                self.__load_pokemon__(mon),
                "templates/pokemon-{{id}}.html",
                "out/pokemon-{{id}}.html"
            )
            count += 1
            if count >= 4:
                break


if __name__ == "__main__":
    renderer = Renderer()
    # renderer.render_pokedex()
    renderer.render_pokemon()
