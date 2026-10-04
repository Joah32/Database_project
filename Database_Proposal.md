# Database Description

I want to make a database that I can use to keep track of what ingredients I have for various recipes I like to bake. I've chosen to go with baking specifically, as I want to keep the scope for this project at a manageable level.

A couple of choices I made to keep things focused: I'm measuring everything in grams, including eggs, so every quantity in the database uses the same unit.

The database is built in MySQL and has six tables: one for each of the five entities below, plus RecipeIngredient for the many-to-many relationship.

## Entities and Descriptions

**Ingredient** - a type of baking ingredient

- ingredient_id (primary key)
- name
- category (flour / sweetener / dairy / leavening / chocolate / seasoning)
- base_unit (g)
- contains_gluten (yes/no)

Sample instances: All-purpose flour, Unsalted butter

**Recipe** - a baking recipe

- recipe_id (primary key)
- equipment_id (foreign key to Equipment)
- name
- recipe_category (cookie / bread / cake)
- prep_time_min
- bake_time_min
- bake_temp_F

Sample instances: Chocolate chip cookies, Sandwich bread, Vanilla pound cake

**PantryStock** - how much of an ingredient I have in a given place

- stock_id (primary key)
- ingredient_id (foreign key to Ingredient)
- quantity_on_hand
- storage_location (pantry / fridge / freezer)
- reorder_threshold (minimum amount in that location before I need to restock)

**Equipment** - tools and bakeware I own

- equipment_id (primary key)
- name
- equipment_type (pan / mixer / scale / rack)
- size_or_capacity

**Batch** (weak entity) - a record of one time I actually made a recipe

- recipe_id (part of the primary key, from Recipe)
- batch_number (partial key - only unique within a recipe)
- batch_date
- scale_factor (0.5 for a half batch, 2 for a double batch, etc.)
- outcome

A Batch has no identity of its own. The date and an ~~~~outcome mean nothing without knowing which recipe they belong to so Recipe identifies it. Its primary key is (recipe_id, batch_number). I used a batch number rather than the date as the partial key so I can make the same recipe twice in one day.

## Relationships

- **Requires** (many-to-many): a Recipe requires many Ingredients, and an Ingredient can be used in many recipes. It is stored in the RecipeIngredient table, keyed on (recipe_id, ingredient_id), and carries a `quantity_needed` attribute. Every recipe should have at least one ingredient (total participation); an ingredient doesn't have to appear in any recipe yet.
- **Tracks** (one-to-many): an Ingredient can have several PantryStock records, one per storage location - bulk flour in the freezer and working flour in the pantry are tracked separately. Every stock record belongs to exactly one ingredient.
- **BakedIn** (one-to-many): each Recipe bakes in one primary piece of Equipment, and a given pan gets reused across many recipes. Every recipe must name its pan; a piece of equipment doesn't have to be used by any recipe. I chose this over a many-to-many on purpose: most recipes have one defining vessel, and modeling every tool a recipe touches would add complexity I don't need yet.
- **Records** (one-to-many, identifying): a Recipe can have many Batches. Every Batch must belong to a recipe; a recipe doesn't have to have been baked yet.

## Use Cases / Questions

1. Which recipes can I make right now with what's in my pantry?
2. For a recipe I want to make, which ingredients am I short on, and how much do I need to buy?
3. Which stock locations are below their reorder threshold, so I know what to add to my shopping list?
4. How much do I need of each ingredient to make a batch of increased size, and how did that scale of batch turn out last time?
