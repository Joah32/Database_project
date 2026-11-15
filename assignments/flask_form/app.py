#! /usr/bin/python3

from flask import Flask, request, render_template

app = Flask(__name__)

# Form fields, in table column order.
FIELDS = ['name', 'category', 'prep_time', 'bake_time', 'oven_temp']


@app.route('/')
def recipe_form():
    # Page 1: form that sends its values to /recipes with a GET request.
    return render_template('form.html')


@app.route('/recipes')
def recipe_table():
    # Page 2: the recipe table, plus one row built from the query string.
    # Jinja escapes every value, so input like <script> shows as text.
    new_recipe = {field: request.args.get(field, '').strip() for field in FIELDS}
    if not any(new_recipe.values()):
        new_recipe = None
    return render_template('recipes.html', new_recipe=new_recipe)


if __name__ == '__main__':
    app.run(port=8000, debug=True, host="0.0.0.0")
