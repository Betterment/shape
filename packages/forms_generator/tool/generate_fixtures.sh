#!/bin/sh

# This script generates the fixtures used in the form body tests.
#
# To run:
#   $ ./tool/generate_fixtures.sh
function generate_fixtures() {
  echo "Generating fixture files..."
  (cd test/fixtures/ && rm *.g.dart && flutter pub run build_runner build --delete-conflicting-outputs) > /dev/null 2>&1
  echo "Done."
}

generate_fixtures
