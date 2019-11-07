#!/bin/bash

Echo 'What module would you like to check? (input the system name of the module)'
read modulename

DC_INSTALLED="$(drupal-check --version)"

if [ ${DC_INSTALLED:0:6} != "Drupal" ]; then
  Echo "Installing drupal check"
  sh ./install_drupal_check.sh
fi

DC_INSTALLED="$(drupal-check --version)"

Echo $DC_INSTALLED installed

# we need the script to be executed from current dir.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ~/

composer create-project drupal-composer/drupal-project:8.x-dev clean-drupal --no-interaction --stability=dev

cd clean-drupal

composer config prefer-stable false
composer require drupal/$modulename

cd $DIR

drupal-check ~/clean-drupal/web/modules/contrib/$modulename/
