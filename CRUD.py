import os
import json
import mysql.connector
from mysql.connector import errorcode

TABLE = "Ingredient"
def getConnection():
    with open("secrets.json", "r") as secretFile:
        creds = json.load(secretFile)["mysqlCredentials"]
    return mysql.connector.connect(**creds)


def askId(prompt):
    while True:
        answer = input(prompt).strip()
        if answer.isdigit():
            return int(answer)
        print("Please enter a whole number.")


def askText(prompt, current=None):
    while True:
        label = f"{prompt} [{current}]: " if current is not None else f"{prompt}: "
        answer = input(label).strip()
        if answer:
            return answer
        if current is not None:
            return current
        print("This field can't be blank.")


def askGluten(current=None):
    while True:
        label = "Contains gluten? (y/n)"
        if current is not None:
            label += f" [{'y' if current else 'n'}]"
        answer = input(label + ": ").strip().lower()
        if answer == "" and current is not None:
            return current
        if answer in ("y", "yes"):
            return 1
        if answer in ("n", "no"):
            return 0
        print("Please answer y or n.")


def fetchRow(cursor, ingredientId):
    cursor.execute(
        f"select ingredient_id, name, category, base_unit, contains_gluten "
        f"from {TABLE} where ingredient_id=%s",
        (ingredientId,),
    )
    return cursor.fetchone()


def printTable():
    with getConnection() as connection:
        cursor = connection.cursor()
        cursor.execute(
            f"select ingredient_id, name, category, base_unit, contains_gluten "
            f"from {TABLE} order by ingredient_id"
        )
        rows = cursor.fetchall()

    print(f"\n{'id':>4}  {'name':<24} {'category':<16} {'unit':<6} gluten")
    print("-" * 60)
    for ingredientId, name, category, unit, gluten in rows:
        print(f"{ingredientId:>4}  {name:<24} {category or '':<16} {unit or '':<6} "
              f"{'yes' if gluten else 'no'}")
    print(f"{len(rows)} row(s)\n")


def insertIntoTable():
    name = askText("Name")
    category = askText("Category (e.g. flour, sugar, dairy)")
    unit = askText("Base unit (e.g. g, ml, each)")
    gluten = askGluten()

    with getConnection() as connection:
        cursor = connection.cursor()
        cursor.execute(
            f"insert into {TABLE} (name, category, base_unit, contains_gluten) "
            f"values (%s, %s, %s, %s)",
            (name, category, unit, gluten),
        )
        connection.commit()
        print(f"Inserted '{name}' with id {cursor.lastrowid}.\n")


def updateRow():
    ingredientId = askId("What is the id of the ingredient you want to update? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        row = fetchRow(cursor, ingredientId)
        if row is None:
            print(f"No ingredient with id {ingredientId}.\n")
            return

        print(f"Current row: {row}")
        print("Press Enter to keep a value unchanged.")
        _, name, category, unit, gluten = row
        name = askText("Name", name)
        category = askText("Category", category)
        unit = askText("Base unit", unit)
        gluten = askGluten(gluten)

        cursor.execute(
            f"update {TABLE} set name=%s, category=%s, base_unit=%s, contains_gluten=%s "
            f"where ingredient_id=%s",
            (name, category, unit, gluten, ingredientId),
        )
        connection.commit()
        print(f"Updated ingredient {ingredientId}.\n")


def deleteRowFromTable():
    ingredientId = askId("What is the id of the ingredient to delete? ")
    with getConnection() as connection:
        cursor = connection.cursor()
        row = fetchRow(cursor, ingredientId)
        if row is None:
            print(f"No ingredient with id {ingredientId}.\n")
            return

        if input(f"Delete {row}? (y/n): ").strip().lower() not in ("y", "yes"):
            print("Cancelled.\n")
            return

        try:
            cursor.execute(f"delete from {TABLE} where ingredient_id=%s", (ingredientId,))
            connection.commit()
            print(f"Deleted ingredient {ingredientId}.\n")
        except mysql.connector.IntegrityError as err:
            connection.rollback()
            if err.errno == errorcode.ER_ROW_IS_REFERENCED_2:
                print("Can't delete: this ingredient is still used in PantryStock "
                      "or RecipeIngredient. Remove those rows first.\n")
            else:
                raise


menuText = """Please select one of the following options:
1) Display contents of table
2) Insert new row to table
3) Update a row of the table
4) Delete a row of the table
q) Quit
> """

actions = {
    "1": printTable,
    "2": insertIntoTable,
    "3": updateRow,
    "4": deleteRowFromTable,
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
