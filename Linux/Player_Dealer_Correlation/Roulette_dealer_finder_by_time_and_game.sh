#!/bin/bash
# Author: Ray Marken
# Date: 15/03/2021

#------------------------------------------------------------------------------------------------#
# FUNCTIONS and GLOBAL VARIABLES
#------------------------------------------------------------------------------------------------#

# Define script name to use in usage functions
cmdname=$(echo "$0"|sed 's/\.\///')

# Define working directories relative to the script execution path,
thisdir=$(dirname $(readlink -f "$0"))
dealerdir="$thisdir/Dealer_Analysis"

# full usage help (--help)
usage-full()
{
  echo "Usage: $cmdname <DATE(MMDD)> <HOUR(HH[AM|PM])>"
  echo ""
  echo "Find which roulette dealer worked on a given date and time."
  echo ""
  echo "Examples:"
  echo "  $cmdname 0310 01AM   = 10th March, 1am"
  echo "  $cmdname 0310 12PM   = 10th March, 12pm"
  echo "  $cmdname 0310 13PM   = invalid"
  echo "  $cmdname 0310 00AM   = invalid"
  echo ""
  echo "Entries can be upper or lower case."
  echo ""
}

# usage hint (-h, no or wrong number of arguments)
usage-hint()
{
  echo "Usage: $cmdname <DATE(MMDD)> <HOUR(HH[AM|PM])>"
  echo "Try '$cmdname --help' for more information."
}

# validate input if the right number of arguments have been provided.
validate-args()
{

  # Set defaults.
  local message=""
  local validdate=true
  local validhour=true

  # Validate supplied arguments and update to false if invalid.

  # Validate that the first supplied argument is a valid date. Eg. 0131, 0229, and 0430 are valid dates, but 0031, 0230, and 0431 are not.
  if [[ ! "$mmdd" =~ ^((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((02)(0[1-9]|[12][0-9]))|((0[469]|11)(0[1-9]|[12][0-9]|30))$ ]]; then
      validdate=false
  fi

  # Validate that the second supplied argument meets the required format. Eg. 03AM, 12PM etc.
  if [[ ! "$hour" =~ ^(0[1-9]|1[0-2])[AP]M$ ]]; then
      validhour=false
  fi

  # If any of the above is invalid, return an appropriate message.
  if [ "$validdate" = false ] || [ "$validhour" = false ]; then
      message="Invalid input. Please review the following and try again."

      if [ "$validdate" = false ]; then
          message="${message}\n  - You have supplied an invalid date. The date must be in the format MMDD. For example, March 10th would be 0310."
      fi

      if [ "$validhour" = false ]; then
          message="${message}\n  - You have supplied an invalid hour. The hour must be in the format HH[AM|PM]. For example, 09AM and 10PM are two valid examples."
      fi

      message="${message}\nUsage: $cmdname <DATE(MMDD)> <HOUR(HH[AM|PM])>"
      message="${message}\nTry '$cmdname --help' for more information."
  fi

  echo "$message"
}


#------------------------------------------------------------------------------------------------#
# CHECK PARAMETERS AND HELP FLAGS
#------------------------------------------------------------------------------------------------#

# Print usage hint and exit if wrong number of parameters are used.
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    usage-hint
    exit 1
fi

# Print usage hint if -h flag is used
if [ "$1" == '-h' ]; then
    usage-hint
    exit 1
fi

# Print full help and exit if --help flag is used
if [ "$1" == '--help' ]; then
    usage-full
    exit 1
fi


#------------------------------------------------------------------------------------------------#
# MAIN
#------------------------------------------------------------------------------------------------#

# Give the supplied arguments meaningful names and convert the hour(am/pm) to uppercase.
mmdd="$1"
hour="${2^^}"

# Validate the supplied arguments
result=$(validate-args)

# Check if the input is valid
if [ "$result" != "" ]; then
  # Input is not valid. Print error and exit.
  echo -e "$result"
  exit 1

else
  # Supplied input is valid. Begin processing...

  # Define the dealer schedule file name and location
  dsfile="${dealerdir}/${mmdd}_Dealer_schedule"

  # Check if there is a dealer schedule file for the supplied date (MMDD).
  if [ ! -f "$dsfile" ]; then
    echo "No schedule file exists for the specified date ($mmdd)."
    echo "The files that are currently available are:"
    echo "$(ls $dealerdir)"
  else

    # The dealer schedule file exists. Find the related record..
    hh=$(echo "$hour" | cut -b 1-2)
    ampm=$(echo "$hour" | cut -b 3-4)
    grephour="$hh:00:00 $ampm"
    line=$(grep "$grephour" "$dsfile")

    # Request which game is of interest
    echo "For which game would you like the dealer name?"
    PS3="Select a game number and press <enter> : "
    games=("Black Jack" "Roulette" "Texas Hold Em")
    select game in "${games[@]}"
    do
      case "$game" in
        "Black Jack" ) break;;
        "Roulette" ) break;;
        "Texas Hold Em" ) break;;
        *) printf "\nInvalid option. Try again, or press <enter> to see the list of options.\n";;
      esac
    done

    # And display the formatted result.
    case "$REPLY" in
      "1" ) printf "$line" | awk -F'\t' '{printf "\n%s", $2 }';;
      "2" ) printf "$line" | awk -F'\t' '{printf "\n%s", $3 }';;
      "3" ) printf "$line" | awk -F'\t' '{printf "\n%s", $4 }';;
    esac
    printf " was the $game dealer who was working at "
    printf "$line" | awk -F'\t' '{printf "%s", $1 }'
    printf " on this day.\n\n"
  fi
fi
