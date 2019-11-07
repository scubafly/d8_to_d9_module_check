#!/bin/bash

function usage() {
cat << EOF
usage: $0 options

OPTIONS:
  -h    Show this message (optional)
  -m    Give the module machine name as parameter input (optional)
  -c    Copy results to clipboard
  -o    Open an issue on drupal.org if errors found
  -u    Update existing module

EOF
}

while getopts "hm:cou" OPTION
  do
    case "$OPTION" in
      h)
        usage
        exit 1;
        ;;
      m)
        modulename="$OPTARG"
        ;;
      c)
        copy_flag=1
        ;;
      o)
        open_flag=1
        ;;
      u)
        update_flag=1
        ;;
      ?)
        usage
        exit 1;
        ;;
    esac
done

# we need the script to be executed from current dir.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# if the module name is not set, ask for a module name.
if [ -z ${modulename+x} ]; then
  Echo 'What module would you like to check? (input the system name of the module)'
  read modulename
fi

DC_INSTALLED="$(drupal-check --version)"

if [ ${DC_INSTALLED:0:6} != "Drupal" ]; then
  Echo "Installing drupal check"
  sh ./install_drupal_check.sh
fi

DC_INSTALLED="$(drupal-check --version)"

Echo $DC_INSTALLED installed

# Install drupal.
cd ~/
composer create-project drupal-composer/drupal-project:8.x-dev clean-drupal --no-interaction --stability=dev
cd clean-drupal
composer config prefer-stable false

if ls ~/clean-drupal/web/modules/contrib | grep -q "$modulename"; then
  if [[ "$update_flag" -eq "1" ]]; then
    # Update module
    echo "reinstalling module"
    composer require drupal/$modulename -o
  fi
else
  echo "installing module"
  # Instal module
  composer require drupal/$modulename -o
fi

cd $DIR

drupal-check ~/clean-drupal/web/modules/contrib/$modulename/ | tee ~/drupal-checked/$modulename.txt

Echo results should also be available in ~/drupal-checked/$modulename.txt

if [[ "$copy_flag" -eq "1" ]]; then
  cat ~/drupal-checked/$modulename.txt | pbcopy
fi

if [[ "$open_flag" -eq "1" ]]; then
  if cat ~/drupal-checked/$modulename.txt | grep -q '\[ERROR\]'; then
     open https://www.drupal.org/node/add/project-issue/$modulename?title=Drupal%209%20Deprecated%20Code%20Report&tags=Drupal%209%20compatibility
  fi
fi
