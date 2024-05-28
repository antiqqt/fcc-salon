#!/bin/bash

PSQL=("psql --username=freecodecamp --dbname=salon -X --tuples-only -c")

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]; then
    # send to main menu
    MAIN_MENU
  else
    echo -e "\nHere are the services we have available:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ [0-9]+ ]]; then
      echo -e "\nHere are the services we have available:"
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done
    fi

    SELECTED_SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SELECTED_SERVICE_EXISTS ]]; then
      echo -e "\nHere are the services we have available:"
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done
    fi

    echo -e "\nPlease, enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]; then
      echo -e "\nPlease, enter your name"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    echo -e "\nPlease, enter the time for the appointment"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED) ")

    SERVICE_NAME=$($PSQL "SELECT s.name FROM appointments as a JOIN services as s ON a.service_id = s.service_id WHERE time = '$SERVICE_TIME' AND a.customer_id = $CUSTOMER_ID AND a.service_id = $SERVICE_ID_SELECTED ")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r "s/^ *| *$//g")

    echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

MAIN_MENU
