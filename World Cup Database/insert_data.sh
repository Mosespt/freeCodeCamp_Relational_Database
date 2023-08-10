#! /bin/bash

# Make the file executable by typing `'chmod +x ./<file_name>'` in the terminal

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Emptying the rows in the tables of the database
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then

    # INSERT TEAMS TABLE DATA

    # get team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if team is not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team name into the the database
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
      then
        echo "Inserted $WINNER into teams"
      fi
    fi

    # get team_id again
    TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if team is not found
    if [[ -z $TEAM2_ID ]]
    then
      #insert team name into the database
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
      then
        echo "Inserted $OPPONENT into teams"
      fi
    fi


    # INSERT GAMES TABLE DATA

    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # insert game details into the database
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo Football match added: $YEAR $ROUND - $WINNER vs $OPPONENT - scores $WINNER_GOALS : $OPPONENT_GOALS
    fi

  fi
done
