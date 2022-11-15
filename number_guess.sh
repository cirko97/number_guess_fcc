#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Welcome to Number Guessing Game ~~\n"

SECRET_NUM=$[$RANDOM % 1000 + 1]
echo "$SECRET_NUM"

echo -e "Enter your username:"
read USERNAME

USERS_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
NUMBER_OF_GUESSES=$($PSQL "SELECT best_guesses FROM users WHERE username = '$USERNAME'")

if [[ -z $USERS_USERNAME ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 1)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $NUMBER_OF_GUESSES guesses."
  COUNT_GAMES_PLAYED=$[$GAMES_PLAYED + 1]
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $COUNT_GAMES_PLAYED WHERE username = '$USERNAME'")
fi

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $USERS_GUESS != $SECRET_NUM ]]
do
  read USERS_GUESS
  COUNTER=$[$COUNTER + 1]
  if [[ ! $USERS_GUESS =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  else
    if [[ $USERS_GUESS < $SECRET_NUM ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
done

if [[ -z $NUMBER_OF_GUESSES ]]
then
  INSERT_GUESSES_RESULT=$($PSQL "UPDATE users SET best_guesses = $COUNTER WHERE username = '$USERNAME'")
else
  if [[ $NUMBER_OF_GUESSES > $COUNTER ]]
  then
    INSERT_GUESSES_RESULT=$($PSQL "UPDATE users SET best_guesses = $COUNTER WHERE username = '$USERNAME'")
  fi
fi

echo -e "\nYou guessed it in $COUNTER tries. The secret number was $SECRET_NUM. Nice job!"
