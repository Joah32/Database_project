import json
import mysql.connector
from mysql.connector import errorcode


def getConnection():
    with open(".secrets.json", "r") as secretFile:
        creds = json.load(secretFile)["mysqlCredentials"]
    return mysql.connector.connect(**creds)


def askId(prompt):
    while True:
        answer = input(prompt).strip()
        if answer.isdigit():
            return int(answer)
        print("Please enter a whole number.")


def fetchName(cursor, table, idColumn, idValue):
    # table and idColumn come from this file!
    cursor.execute(f"select name from {table} where {idColumn}=%s", (idValue,))
    row = cursor.fetchone()
    return row[0] if row else None


def printRows(rows):
    print(f"\n{'id':>4}  {'name':<24} category")
    print("-" * 44)
    for rowId, name, category in rows:
        print(f"{rowId:>4}  {name:<24} {category or ''}")
    print(f"{len(rows)} row(s)\n")


def printRecipes():
    with getConnection() as connection:
        cursor = connection.cursor()
        cursor.execute(
            "select recipe_id, name, recipe_category "
            "from Recipe order by recipe_id"
        )
        rows = cursor.fetchall()
    printRows(rows)


def printIngredients():
    with getConnection() as connection:
        cursor = connection.cursor()
        cursor.execute(
            "select ingredient_id, name, category "
            "from Ingredient order by ingredient_id"
        )
        rows = cursor.fetchall()
    printRows(rows)


def printIngredientsForRecipe():
    recipeId = askId("For which recipe id would you like to view the ingredients? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        recipeName = fetchName(cursor, "Recipe", "recipe_id", recipeId)
        if recipeName is None:
            print(f"No recipe with id {recipeId}.\n")
            return
        cursor.execute(
            "select i.ingredient_id, i.name, i.category "
            "from Ingredient i join RecipeIngredient ri on i.ingredient_id=ri.ingredient_id "
            "where ri.recipe_id=%s order by i.ingredient_id",
            (recipeId,),
        )
        rows = cursor.fetchall()
    print(f"\nIngredients in {recipeName}:", end="")
    printRows(rows)


def printRecipesForIngredient():
    ingredientId = askId("For which ingredient id would you like to view the recipes? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        ingredientName = fetchName(cursor, "Ingredient", "ingredient_id", ingredientId)
        if ingredientName is None:
            print(f"No ingredient with id {ingredientId}.\n")
            return
        cursor.execute(
            "select r.recipe_id, r.name, r.recipe_category "
            "from Recipe r join RecipeIngredient ri on r.recipe_id=ri.recipe_id "
            "where ri.ingredient_id=%s order by r.recipe_id",
            (ingredientId,),
        )
        rows = cursor.fetchall()
    print(f"\nRecipes that use {ingredientName}:", end="")
    printRows(rows)


def addIngredientToRecipe():
    recipeId = askId("What is the id of the recipe? ")
    ingredientId = askId("What is the id of the ingredient to add? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        recipeName = fetchName(cursor, "Recipe", "recipe_id", recipeId)
        if recipeName is None:
            print(f"No recipe with id {recipeId}.\n")
            return
        ingredientName = fetchName(cursor, "Ingredient", "ingredient_id", ingredientId)
        if ingredientName is None:
            print(f"No ingredient with id {ingredientId}.\n")
            return

        try:
            cursor.execute(
                "insert into RecipeIngredient (recipe_id, ingredient_id) values (%s, %s)",
                (recipeId, ingredientId),
            )
            connection.commit()
            print(f"Added {ingredientName} to {recipeName}.\n")
        except mysql.connector.IntegrityError as err:
            connection.rollback()
            if err.errno == errorcode.ER_DUP_ENTRY:
                print(f"{recipeName} already lists {ingredientName}.\n")
            else:
                raise


def removeIngredientFromRecipe():
    recipeId = askId("What is the id of the recipe? ")
    ingredientId = askId("What is the id of the ingredient to remove? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        recipeName = fetchName(cursor, "Recipe", "recipe_id", recipeId)
        ingredientName = fetchName(cursor, "Ingredient", "ingredient_id", ingredientId)
        cursor.execute(
            "select 1 from RecipeIngredient where recipe_id=%s and ingredient_id=%s",
            (recipeId, ingredientId),
        )
        if cursor.fetchone() is None:
            print(f"Recipe {recipeId} doesn't list ingredient {ingredientId}.\n")
            return

        if input(f"Remove {ingredientName} from {recipeName}? (y/n): ").strip().lower() not in ("y", "yes"):
            print("Cancelled.\n")
            return

        try:
            cursor.execute(
                "delete from RecipeIngredient where recipe_id=%s and ingredient_id=%s",
                (recipeId, ingredientId),
            )
            connection.commit()
            print(f"Removed {ingredientName} from {recipeName}.\n")
        except mysql.connector.IntegrityError as err:
            connection.rollback()
            if err.errno == errorcode.ER_ROW_IS_REFERENCED_2:
                print(f"Can't remove: a step in {recipeName} uses {ingredientName}. "
                      "Remove it from that step first.\n")
            else:
                raise


menuText = """Please select one of the following options:
1) Print recipes
2) Print ingredients
3) Print ingredients in a recipe
4) Print recipes that use an ingredient
5) Add an ingredient to a recipe
6) Remove an ingredient from a recipe
q) Quit
> """

actions = {
    "1": printRecipes,
    "2": printIngredients,
    "3": printIngredientsForRecipe,
    "4": printRecipesForIngredient,
    "5": addIngredientToRecipe,
    "6": removeIngredientFromRecipe,
}

if __name__ == "__main__":
    while True:
        choice = input(menuText).strip().lower()
        if choice == "q":
            break
        action = actions.get(choice)
        if action is None:
            print("Unknown option.\n")
            continue
        try:
            action()
        except mysql.connector.Error as err:
            print(f"Database error: {err}\n")