#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SHEEHS SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you today?"

MAIN_MENU() {
  if [[ $1 ]]
  then
   echo -e "\n$1"
  fi

  # available services
  SERVICES_LIST=$($PSQL "SELECT * FROM services")
  # if there is no available service
  if [[ -z $SERVICES_LIST ]]
  then
    echo "Sorry, we don't any available service at the moment."

  else
    # show available services
    echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    # get customer's choice
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Sorry, that is not a valid number! Please, enter a valid option."

    else
      # check if number is a valid and available service number
      VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      # if number is not valid
      if [[ -z $VALID_SERVICE ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"

      else
        # get customer's phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # check if customer exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # if customer does not exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get customer's name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          # insert the new customer's name and phone number
          ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi

        # get the service time
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME

        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # insert the salon appointment schedule
        NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

        # appointment scheduled
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
  fi
}

MAIN_MENU
