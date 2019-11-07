redmine_queries_for_time_report
===============================

Redmine plugin that adds Queries to **Time Report** like **Time Entry Queries**,

It allows to add such saved queries to **My Page**
Be careful, because of the nature of Time Report, records count will **not be limited** to 10, unlike other My Page Blocks.

# How it works

## What it does

* Adds : ****

Blah.

* Tested with **Redmine V4.0.3**

## How it is implemented

- Adds new **TimeReportQuery** model

- 🔑 Extends My Helper by adding **render_timereportquery_block** method

- No migration ! uses Single table inheritance Redmine model.

- No new route !

# TODOs

* Add Tests
* Fix TODOS

# To test it

```console
# From plugin root, redmine_test mysql database must exist
scripts/test_it.sh
```

# Changelog

* **V1.0**  Initial version

Enjoy !

<kbd>![alt text](https://compteur-visites.ennder.fr/sites/36/token/githubtrq/image "Logo") <!-- .element height="10%" width="10%" --></kbd>
