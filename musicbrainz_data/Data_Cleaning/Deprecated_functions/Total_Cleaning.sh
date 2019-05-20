#! /bin/bash

cd ./Data_Cleaning/

read -p "Do you want to execute everything together? [Y,n] >" ans0

if [[ $ans0 == "y" || $ans0 == "Y" ]]; then
  python3 get_data.py
  ./PigCleaning.sh
  ./neo4j_import.sh
else
  echo "You chose not to execute everything together"

#Question 1
  read -p "Do you want to pre-process the raw data? [Y,n] >" ans1

  if [[ $ans1 == "y" || $ans1 == "Y" ]]; then
    python3 get_data.py
  else
    echo "You chose not to pre-process the raw data"
  fi

  #Question 2
  read -p "Do you want to process the data with PIG [Y,n] >" ans2

  if [[ $ans2 == "y" || $ans2 == "Y" ]]; then
    ./PigCleaning.sh
  else
    echo "You chose not to process the data with PIG"
  fi

  #Question 3
  read -p "Do you want to create a graph database [Y,n] >" ans3

  if [[ $ans3 == "y" || $ans3 == "Y" ]]; then
    ./neo4j_import.sh
  else
    echo "You chose not to create a graph database"
  fi
fi
