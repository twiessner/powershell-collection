#!/bin/bash

read -p "What is the name of the delivery: " DELIVERY
if [ -z "$DELIVERY" ]; then
	echo "You have to enter a name for the delivery"
	exit 1
fi


PS3=$'\nSelect the security zones you like to add as workspace: '
options="alm dev qa prd"

# Array for storing the user's choices
choices=()

select choice in $options Finished Clear Cancel
do
  if [ $choice == "Clear" ]; then
  	choices=()
  	echo "All cleared"
  elif [ $choice == "Finished" ]; then
  	break
  elif [ $choice == "Cancel" ]; then
    	exit 1
  else
  	choices+=( "$choice" )
  	echo ""
  	echo "--------------------"
  	echo "--> I will create following workspaces: '${choices[@]}'"
  	echo "Enter '5' to finish, '6' to clear, '7' to cancel"
	fi
done

for choice in "${choices[@]}"
do
	terraform workspace new "${DELIVERY}_${choice}"
done
printf '\n'

exit 0
