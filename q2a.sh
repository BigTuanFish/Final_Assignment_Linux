#!/bin/bash
#q2.a

# /dev/null is used throughout the script to not show the following output:
# mysql: [Warning] Using a password on the command line interface can be insecure.


# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if MySQL is installed and install if not
if ! command -v mysql &> /dev/null; then
    echo "MySQL is not installed. Installing..."
    apt update
    apt install -y mysql-server
    systemctl start mysql
    systemctl enable mysql
    echo "MySQL has been installed and started."
fi

# Paths to csv and zip files
csv_file="imdb_top_2000_movies.csv"
zip_file="csv_data.tar.gz"

# Unzip file if not already unzipped
if [ -f "$zip_file" ]; then
    # Unzip the file
    tar -xzvf "$zip_file" > "$csv_file"
    echo "File unzipped successfully."
else
    echo "No zip file found."
fi

# Terminate all commas that are in the column values
awk -F '"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' "$csv_file" > temp.csv
mv temp.csv "$csv_file"


# Creating a new user for this task and for part b.
# Credentials:
User="daniel_talia"
Password="TD123456"
Root_Password="password"

# Check if the user exists, if not, create it
if ! mysql -u root -p"$Root_Password" -e "SELECT 1 FROM mysql.user WHERE user='$User'" 2>/dev/null  | grep -q 1; then
    echo "Creating MySQL user: $User"
    mysql -u root -p"$Root_Password" -e "CREATE USER '$User'@'localhost' IDENTIFIED BY '$Password';" 2>/dev/null
fi

# Grant all privileges to the created user: example usage- load data and access the HTTP server
echo "Granting all privileges to MySQL user: $User"
mysql -u root -p"$Root_Password" -e "GRANT ALL PRIVILEGES ON *.* TO '$User'@'localhost' WITH GRANT OPTION;" 2>/dev/null
mysql -u root -p"$Root_Password" -e "FLUSH PRIVILEGES;" 2>/dev/null
echo "MySQL user '$User' has been granted all privileges."


# Database name
Database_Name="IMDB_Top_Movies"

# Set global infile option in MySQL configuration
echo "Setting global infile option"
echo "SET GLOBAL local_infile = 1;" | mysql -u$User -p$Password 2>/dev/null

# Define the SQL data base creation query
CREATE_DATABASE="CREATE DATABASE IF NOT EXISTS $Database_Name;"

# Create MySQL database if not exists
echo "$CREATE_DATABASE" | mysql --local-infile=1 -u$User -p$Password 2>/dev/null

# Extract table name from copied CSV file name
table_name=$(basename "$csv_file" | cut -d. -f1)

# Define the SQL table creation query
CREATE_TABLE="DROP TABLE IF EXISTS $Database_Name.$table_name;
CREATE TABLE $Database_Name.$table_name (
    Movie_Name VARCHAR(200),
    Release_Year INT,
    Duration INT,
    IMDB_Rating FLOAT,
    Meta_Score FLOAT,
    Votes INT,
    Genre VARCHAR(200),
    Director VARCHAR(100),
    Cast VARCHAR(500),
    Gross VARCHAR(20)
);"

# Create the table
echo "$CREATE_TABLE" | mysql --local-infile=1 -u$User -p$Password $Database_Name 2>/dev/null

# Import data into the table from the CSV file using LOAD DATA LOCAL INFILE
IMPORT_DATA_SQL="LOAD DATA LOCAL INFILE '$csv_file' INTO TABLE $Database_Name.$table_name
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Movie_Name, Release_Year, Duration, IMDB_Rating, Meta_Score, Votes, Genre, Director, Cast, Gross);"

echo "$IMPORT_DATA_SQL" | mysql --local-infile=1 -u$User -p$Password $Database_Name 2>/dev/null

# Check the exit status
if [ $? -eq 0 ]; then
    echo "Script ran successfully. Table '$table_name' has been created and data from '$csv_file' has been inserted."
else
    echo "Error: Script encountered an issue."
fi
