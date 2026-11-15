#!/usr/bin/python3
import json
import mysql.connector
from mysql.connector import errorcode
from flask import Flask, abort, render_template, request, redirect, url_for


def getConnection():
    with open(".secrets.json", "r") as secretFile:
        creds = json.load(secretFile)["mysqlCredentials"]
    return mysql.connector.connect(**creds)


def getIdArg(source, name):
    """Return an int id from request.args or request.form, or None if absent."""
    value = source.get(name)
    if value is None:
        return None
    if not value.isdigit():
        abort(400)
    return int(value)


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
            # Reload without the GET variables so a page refresh doesn't run it again
            return redirect(url_for("showIngredients"))
        elif request.args.get("delete") == "true":
            deleteId = request.args.get("id")
            cursor.execute("delete from Ingredient where ingredient_id=%s", (deleteId,))
            connection.commit()
            return redirect(url_for("showIngredients"))

        cursor.execute(
            "select ingredient_id, name, category, base_unit, contains_gluten "
            "from Ingredient order by ingredient_id"
        )
        rows = cursor.fetchall()

    return render_template("ingredient-list.html", collection=rows)


@app.route("/updateIngredient")
def updateIngredient():
    ingredientId = request.args.get("id")
    name = request.args.get("name")
    category = request.args.get("category")
    baseUnit = request.args.get("base_unit")
    containsGluten = 1 if request.args.get("contains_gluten") else 0
    if ingredientId is None:
        return "Error, id not specified"

    with getConnection() as connection:
        cursor = connection.cursor()

        if name is not None and category is not None and baseUnit is not None:
            cursor.execute(
                "update Ingredient set name=%s, category=%s, base_unit=%s, contains_gluten=%s "
                "where ingredient_id=%s",
                (name, category, baseUnit, containsGluten, ingredientId),
            )
            connection.commit()
            return redirect(url_for("showIngredients"))

        # No new values yet, so show the form filled with the current row
        cursor.execute(
            "select name, category, base_unit, contains_gluten "
            "from Ingredient where ingredient_id=%s",
            (ingredientId,),
        )
        existingName, existingCategory, existingUnit, existingGluten = cursor.fetchone()

    return render_template(
        "ingredient-update.html",
        id=ingredientId,
        existingName=existingName,
        existingCategory=existingCategory,
        existingUnit=existingUnit,
        existingGluten=existingGluten,
    )


# Many-to-many: Recipe <-> Ingredient through RecipeIngredient 


@app.route("/showRecipes", methods=["GET"])
def showRecipes():
    # With ?ingredient_id=N, show only the recipes that use that ingredient.
    ingredientId = getIdArg(request.args, "ingredient_id")

    with getConnection() as connection:
        cursor = connection.cursor()

        if ingredientId is None:
            cursor.execute(
                "select recipe_id, name, recipe_category from Recipe order by recipe_id"
            )
            return render_template(
                "recipe-list.html",
                pageTitle="Showing all recipes",
                collection=cursor.fetchall(),
                ingredient=None,
                otherRecipes=None,
            )

        cursor.execute(
            "select ingredient_id, name from Ingredient where ingredient_id=%s",
            (ingredientId,),
        )
        ingredient = cursor.fetchone()
        if ingredient is None:
            abort(404)

        cursor.execute(
            "select r.recipe_id, r.name, r.recipe_category "
            "from Recipe r join RecipeIngredient ri on r.recipe_id=ri.recipe_id "
            "where ri.ingredient_id=%s order by r.recipe_id",
            (ingredientId,),
        )
        recipes = cursor.fetchall()

        # Recipes that do not use this ingredient yet, for the insert form
        cursor.execute(
            "select recipe_id, name from Recipe "
            "where recipe_id not in "
            "(select recipe_id from RecipeIngredient where ingredient_id=%s) "
            "order by name",
            (ingredientId,),
        )
        otherRecipes = cursor.fetchall()

        return render_template(
            "recipe-list.html",
            pageTitle=f"Showing all recipes that use {ingredient[1]}",
            collection=recipes,
            ingredient=ingredient,
            otherRecipes=otherRecipes,
        )


@app.route("/recipeIngredients", methods=["GET"])
def recipeIngredients():
    recipeId = getIdArg(request.args, "recipe_id")
    if recipeId is None:
        abort(400)

    with getConnection() as connection:
        cursor = connection.cursor()

        cursor.execute(
            "select recipe_id, name from Recipe where recipe_id=%s", (recipeId,)
        )
        recipe = cursor.fetchone()
        if recipe is None:
            abort(404)

        cursor.execute(
            "select i.ingredient_id, i.name, i.category, i.base_unit, i.contains_gluten "
            "from Ingredient i join RecipeIngredient ri on i.ingredient_id=ri.ingredient_id "
            "where ri.recipe_id=%s order by i.ingredient_id",
            (recipeId,),
        )
        ingredients = cursor.fetchall()

        # Ingredients this recipe does not list yet, for the insert form
        cursor.execute(
            "select ingredient_id, name from Ingredient "
            "where ingredient_id not in "
            "(select ingredient_id from RecipeIngredient where recipe_id=%s) "
            "order by name",
            (recipeId,),
        )
        otherIngredients = cursor.fetchall()

    return render_template(
        "recipe-ingredients.html",
        pageTitle=f"Showing all ingredients in {recipe[1]}",
        collection=ingredients,
        recipe=recipe,
        otherIngredients=otherIngredients,
    )


@app.route("/addLink", methods=["POST"])
def addLink():
    # Insert one row into the bridge table, then go back to the page the form came from.
    recipeId = getIdArg(request.form, "recipe_id")
    ingredientId = getIdArg(request.form, "ingredient_id")
    if recipeId is None or ingredientId is None:
        abort(400)

    with getConnection() as connection:
        cursor = connection.cursor()

        cursor.execute("select 1 from Recipe where recipe_id=%s", (recipeId,))
        if cursor.fetchone() is None:
            abort(404)
        cursor.execute(
            "select 1 from Ingredient where ingredient_id=%s", (ingredientId,)
        )
        if cursor.fetchone() is None:
            abort(404)

        try:
            cursor.execute(
                "insert into RecipeIngredient (recipe_id, ingredient_id) values (%s, %s)",
                (recipeId, ingredientId),
            )
            connection.commit()
        except mysql.connector.IntegrityError as err:
            connection.rollback()
            # A double submit or a stale page: the link already exists, so there is nothing to add
            if err.errno != errorcode.ER_DUP_ENTRY:
                raise

    if request.form.get("from") == "ingredient":
        return redirect(url_for("showRecipes", ingredient_id=ingredientId))
    return redirect(url_for("recipeIngredients", recipe_id=recipeId))


if __name__ == "__main__":
    app.run(port=8000, debug=True, host="0.0.0.0")
