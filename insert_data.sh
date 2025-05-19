#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Truncate existing data
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# Read games.csv line by line
tail -n +2 games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  # Insert winner if not exists
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ -z $WINNER_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
  fi

  # Insert opponent if not exists
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ -z $OPPONENT_ID ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
  fi

  # Get updated IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # Insert game
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
  VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_GOALS, $OPP_GOALS)"
done
