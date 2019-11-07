#!/bin/bash

cd ../..

RAILS_ENV=test rails redmine:plugins:test NAME=redmine_queries_for_time_report

