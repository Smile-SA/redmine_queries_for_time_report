redmine_queries_for_time_report
===============================

Redmine plugin that adds Queries to **Time Report** like **Time Entry Queries**,

&nbsp;&nbsp;It allows to add such saved queries to **My Page**

&nbsp;&nbsp;Be careful, because of the nature of Time Report, records count will **not be limited** to 10, unlike other My Page Blocks.

It also allows to add Time Entry queries to **My Page**

# How it works

## What it does

* Adds : specific configurations in the **Report tab** of the Timelog page

  To be able to configure and save Time Report Queries

  Enables features provided by **redmine_extended_queries** plugin

  Because these two plugins override the same views

* Tested with **Redmine V4.0.3**

## How it is implemented

- 🔑 Rewrites the **report** **TimelogController** method

- 🔑 Rewrites the following **views**

  - To add icons to the query block title

    - /my/blocks/_calendar.html.erb
    - /my/blocks/_documents.html.erb
    - /my/blocks/_issues.erb
    - /my/blocks/_news.html.erb
    - /my/blocks/_timelog.html.erb

  - To add the project in the query block title

    - /my/blocks/_issue_query_selection.html.erb

- Adds / Rewrites the following **My Page** block **views**

    - /my/blocks/partials/_timelogs.html.erb
    - /my/blocks/partials/_timereport.html.erb

- Adds **My Page** block **views** helper partials

    - /my/blocks/partials/_timelog_query_selection.html.erb
    - /my/blocks/partials/_timereport_query_selection.html.erb

- Adds new **TimeReportQuery** model

- 🔑 Extends **My Helper** by adding the methods :

  - **render_timelogquery_block**

  - **render_timereportquery_block**

- 🔑 Extends **Timelog Helper** by adding the methods :

  - **prepare_report_object**

  - **time_entry_scope**

- 🔑 Extends **Redmine::MyPage** to :

  - Add new My Page blocks in the **CORE_BLOCKS** hash
  - Override **additional_blocks** class method to manage partials overriden in plugins

- No migration ! uses Single table inheritance Redmine model.

- No new route !

# TODOs

* Add Tests
* Fix TODOS
* Complete the overriden / added files

# To test it

```console
# From plugin root, redmine_test mysql database must exist
scripts/test_it.sh
```

# Changelog

* **V1.0.5**  **criteria selection** at the beginning
* **V1.0.4**  **available_criteria_options** : sorted criteria + prefix by glyphs icons

  Time Report criteria list : criteria are now sorted by type (Tree, Custom Fields, Date)

* **V1.0.3**  Redmine V3.4.6 minimum, + UserCustomFields in TimeReport Criteria
* **V1.0.2**  Enabled optional features provided in redmine_extended_queries plugin
because these two plugins override the same views :
**app/views/queries/_query_form.html.erb** and **app/views/queries/_form.html.erb**
* **V1.0**  Initial version

Enjoy !

<kbd>![alt text](https://compteur-visites.ennder.fr/sites/37/token/githubtrq/image "Logo") <!-- .element height="10%" width="10%" --></kbd>
