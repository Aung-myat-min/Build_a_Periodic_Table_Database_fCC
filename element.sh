# Define the PSQL command with necessary options
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Main function to determine the atomic number
MAIN_FUNC(){
  # Check if the argument is a number (atomic number)
  if [[ $1 =~ ^[0-9]+$ ]]; then
    # Query the atomic number directly
    getID=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  else
    # Query the atomic number by symbol or name
    getID=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
  fi

  # If getID is empty, the element was not found
  if [[ -z $getID ]]; then
    echo -e "I could not find that element in the database."
  else
    # Call the function to find and display the element details
    FIND_ELE
  fi
}

# Function to find and display the element details
FIND_ELE(){
  # Query to get element details by atomic number
  ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number = $getID")

  # Set the Internal Field Separator to '|' to properly split the output
  IFS='|'

  # Read the result and format the output
  echo "$ELEMENT" | while read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
  do
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done
}

# Check if an argument was provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else
  # Call the main function with the provided argument
  MAIN_FUNC $1
fi