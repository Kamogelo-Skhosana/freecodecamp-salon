#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi
  # show numbered list of services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # customer selection
  read SERVICE_ID_SELECTED
  # if selection is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "Invalid selection, Enter a number!"
    else
      # if selection is not a valid number
      SELECTION=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SELECTION ]]
        then
          # send to main menu 
          MAIN_MENU "Invalid selection, enter one of the services available"
        else
          # customer phone number
          echo "Enter phone number:"
          read CUSTOMER_PHONE
          # check if customer exists
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          # if customer doesnt exist
          if [[ -z $CUSTOMER_NAME ]]
            then
              # get customer name
              echo -e "\nWe dont have your record, Enter your name:"
              read CUSTOMER_NAME
              # insert customer into database
              CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
              # get customer time
              echo -e "\nEnter your service time:"
              read SERVICE_TIME
              # customer id
              CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE PHONE = '$CUSTOMER_PHONE'")
              # service name
              SERVICES=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
              # insert into appointment database
              APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
              echo -e "\nI have put you down for a $(echo $SERVICES | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
            else
              # get customer time
              echo -e "\nEnter prefered time for your service"
              read SERVICE_TIME
              # customer id
              CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE PHONE = '$CUSTOMER_PHONE'")
              # service name
              SERVICES=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
              # insert into appointment database
              APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
              echo -e "\nI have put you down for a $(echo $SERVICES | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
          fi
      fi
  fi
}

MAIN_MENU