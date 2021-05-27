#!/bin/bash
# Author: Ray Marken 11/3/21
# Description: Find the working dealer based on dates and times specified in the Roulette Losses file. 
# Usage: ./Dealers_working_during_losses.sh > Dealers_working_during_losses

# Define working directories and input file relative to the script execution path.
thisdir=$(dirname $(readlink -f "$0"))
dealerdir="$thisdir/Dealer_Analysis"
roulette_losses="$thisdir/Roulette_Losses"

while read line;
do
  # for each line in roulette losses file, look up which dealer was working based on date and time.
  loss_date=$(echo "$line" | cut -b 1-4)
  loss_time=$(echo "$line" | cut -b 27-37)
  dealer_name=$(grep "^$loss_time" "${dealerdir}/${loss_date}_Dealer_schedule" | awk '{print $5" "$6}')

  # Print the date, time, and dealer name.
  echo "$loss_date $loss_time - $dealer_name"  

done < "$roulette_losses"
