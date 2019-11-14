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
        self.type_efficacy = None

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

    def __load_type_efficacy__(self):

        if self.type_efficacy is None:
            with open("data/type_efficacy.json", "r") as f:
                self.type_efficacy = json.load(f)

        return self.type_efficacy

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

            # record = {"row_index": row_index}
            record = {}
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
        # - Relative based -
        # adj_max = max_value - min_value
        # adj_val = value - min_value
        # rolls = self.__load_rolls__()
        # max_index = len(rolls) - 1
        # index = int(round(max_index * adj_val / adj_max))
        # return rolls[index]

        # - Numerical Base -
        rolls = self.__load_rolls__()
        # Highest values are under the rolls values
        #   This adjustment keeps them relatively consistent
        adj_value = value / 10.0

        for roll in rolls:
            # Returns a roll just above the max value
            if roll["value"] > adj_value:
                # print "Returning", roll["roll"], "value", roll["value"], "for", value, "adj", adj_value
                return roll["roll"]

    def __load_pokedex__(self):

        if self.pokedex is None:
            data = self.__query__("sql/pokedex.sql")
            self.pokedex = {"pokedex": data}

        return self.pokedex

    def __lookup_type_efficacy__(self, mon):

        type_efficacy = self.__load_type_efficacy__()

        # Load/Combine
        modifiers = self.type_efficacy[mon["type1"]].copy()
        if "type2" in mon:
            modifiers2 = type_efficacy[mon["type2"]]

            for key in modifiers2:
                if key in modifiers:
                    modifiers[key] = modifiers[key] * modifiers2[key]
                else:
                    modifiers[key] = modifiers2[key]

        weaknesses = []
        resistances = []

        # Sort
        for key in modifiers:
            val = modifiers[key]
            if val < 1:
                if val == 0:
                    val = "(immune)"
                elif val == ".25":
                    val = "+2d"
                else:
                    val = "+1d"

                resistances.append({
                    "name": key,
                    "value": val
                })
            elif val > 1:
                weaknesses.append({
                    "name": key,
                    "value": "+1d" if val == 2 else "+2d"
                })

        mon["weaknesses"] = weaknesses
        mon["resistances"] = resistances

    def __load_pokemon__(self, mon):

        if "loaded" in mon:
            return mon

        # Types
        self.__lookup_type_efficacy__(mon)

        # Rolls
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

    def render_items(self):

        categories = {}
        with open("data/item_categories.json", "r") as f:
            categories = json.load(f)

        categorized = {
            "machines": [],
            "key_items": [],
            "held_items": [],
            "consummables": [],
            "balls": []
        }

        for item in self.__query__("sql/items.sql"):
            category = categories[item["category"]]
            categorized[category].append(item)

        self.__render__(
            categorized,
            "templates/items.html",
            "out/items.html"
        )


if __name__ == "__main__":
    renderer = Renderer()
    # renderer.render_items()
    # renderer.render_pokedex()
    renderer.render_pokemon()

    # with open("out/pokedex.json", "w") as f:
    #     json.dump(renderer.pokedex, f, sort_keys=True)

    # print "Created out/pokedex.json"
