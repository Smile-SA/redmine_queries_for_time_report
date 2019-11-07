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

- 🔑 Rewrites the **report** **TimelogController** method

- 🔑 Rewrites the following **views**

  - To add icons to the query block title

    - /my/blocks/_calendar.html.erb
    - /my/blocks/_documents.html.erb
    - /my/blocks/_issues.erb
    - /my/blocks/_news.html.erb

  - To add the project to the query block title

    - /my/blocks/_issue_query_selection.html.erb

- Adds the following **views**
    - /my/blocks/_timelog.html.erb
    - /my/blocks/_timelog_query_selection.html.erb
    - /my/blocks/_timelogs.erb
    - /my/blocks/_timereport.html.erb
    - /my/blocks/_timereport_query_selection.html.erb

- Adds new **TimeReportQuery** model

- 🔑 Extends **My Helper** by adding the methods :

  - **render_timelogquery_block**

  - **render_timereportquery_block**

- 🔑 Extends **Timelog Helper** by adding the methods :

  - **prepare_report_object**

  - **time_entry_scope**

- 🔑 Extends **Redmine::MyPage** to add values in the **CORE_BLOCKS** hash :

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
