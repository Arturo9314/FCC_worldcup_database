#! /bin/bash
#Script to insert data from games.csv into worldcup database

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#So that we may rerun the file, start by clearing the rows from the database's tables.
echo $($PSQL "TRUNCATE games,teams")
echo $($PSQL "SELECT setval('games_game_id_seq', 1, True)")
echo $($PSQL "SELECT setval('teams_team_id_seq', 1, True)")

#Apply a while loop on the games.csv file to read rows at a time.
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" && $ROUND != "Round" && $WINNER != "Winner" && $OPPONENT != "Opponent" && $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]
  then
    # Data teams
    # get winner and team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
      # get new team_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      WINNER_NAME=$($PSQL "SELECT name FROM teams WHERE team_id='$WINNER_ID'")
      echo "Inserted into teams: ${WINNER_NAME}"
      fi
    fi
    # get opponent team_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        # get new team_id
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        OPPONENT_NAME=$($PSQL "SELECT name FROM teams WHERE team_id='$OPPONENT_ID'")
        echo "Inserted into teams: ${OPPONENT_NAME}"
      fi
    fi
    # Data games
    INSERT_GAMES=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAMES == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
    fi

  fi 
  
done
