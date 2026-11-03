#!/usr/bin/python3
import json
import mysql.connector
from flask import Flask, render_template, request, redirect, url_for


def getConnection():
    with open(".secrets.json", "r") as secretFile:
        creds = json.load(secretFile)["mysqlCredentials"]
    return mysql.connector.connect(**creds)


app = Flask(__name__)


@app.route("/", methods=["GET"])
def showIngredients():
    name = request.args.get("name")
    category = request.args.get("category")
    baseUnit = request.args.get("base_unit")
    # An unchecked checkbox sends nothing, so a missing value means no gluten
    containsGluten = 1 if request.args.get("contains_gluten") else 0

    with getConnection() as connection:
        cursor = connection.cursor()

        # If the form sent its values, insert the new row. ingredient_id is left
        # out so MySQL assigns the next AUTO_INCREMENT value.
        if name is not None and category is not None and baseUnit is not None:
            cursor.execute(
                "insert into Ingredient (name, category, base_unit, contains_gluten) "
                "values (%s, %s, %s, %s)",
                (name, category, baseUnit, containsGluten),
            )
            connection.commit()
            # Reload without the GET variables so a page refresh doesn't insert again
            return redirect(url_for("showIngredients"))

        cursor.execute(
            "select ingredient_id, name, category, base_unit, contains_gluten "
            "from Ingredient order by ingredient_id"
        )
        rows = cursor.fetchall()

    return render_template("ingredient-list.html", collection=rows)


if __name__ == "__main__":
    app.run(port=8000, debug=True, host="0.0.0.0")
