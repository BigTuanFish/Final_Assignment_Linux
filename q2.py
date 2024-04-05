#!/bin/python3
# q2.py

from flask import Flask, request
import subprocess

app = Flask(__name__)

# Database name
database_name = "IMDB_Top_Movies"

# Sample filter query
filter_query = """
SELECT m.Genre, m.Movie_Name, m.IMDB_Rating
FROM imdb_top_2000_movies m
JOIN (
    SELECT Genre, MAX(IMDB_Rating) AS Max_Rating
    FROM imdb_top_2000_movies
    GROUP BY Genre
) max_ratings
ON m.Genre = max_ratings.Genre AND m.IMDB_Rating = max_ratings.Max_Rating
ORDER BY m.IMDB_Rating DESC
LIMIT 10;
"""

count_query = """
SELECT Director, COUNT(*) AS Movie_Count
FROM imdb_top_2000_movies
GROUP BY Director
ORDER BY Movie_Count DESC
LIMIT 10;
"""

aggregation_query = """
SELECT Release_Year, AVG(IMDB_Rating) AS Avg_Rating
FROM imdb_top_2000_movies
GROUP BY Release_Year
ORDER BY Release_Year DESC
LIMIT 20;
"""

query_c = """
WITH rated_directors AS (
    SELECT Director, COUNT(*) AS Num_Rated_Movies
    FROM imdb_top_2000_movies
    WHERE IMDB_Rating >= 7.5
    GROUP BY Director
),
popular_actors AS (
    SELECT
        CAST(SUBSTRING_INDEX(CAST(SUBSTRING_INDEX(Cast, ',', 1) AS CHAR), ' ', 1) AS CHAR) AS First_Name,
        CAST(SUBSTRING_INDEX(CAST(SUBSTRING_INDEX(Cast, ',', 2) AS CHAR), ' ', -1) AS CHAR) AS Last_Name,
        COUNT(*) AS Num_Movies
    FROM imdb_top_2000_movies
    GROUP BY First_Name, Last_Name
    HAVING Num_Movies >= 3
)
SELECT r.Director, CONCAT(p.First_Name, ' ', p.Last_Name) AS Actor, COUNT(*) AS Collaborations
FROM imdb_top_2000_movies m
JOIN rated_directors r ON m.Director = r.Director
JOIN popular_actors p ON m.Cast LIKE CONCAT('%', p.First_Name, '%', '%', p.Last_Name, '%')
GROUP BY r.Director, Actor
ORDER BY Collaborations DESC
LIMIT 10;
"""


@app.route('/', methods=['GET'])
def get():
    return str("\n1) Filter Query\n2)Count Query\n3)Aggregation Query \n\n")


@app.route('/', methods=['POST'])
def post():
    received_value = str(request.get_data(as_text=True))  # Gets the data from the POST request
    answer = calculate_answer(received_value)
    return str(answer)  # Returns the data to the user

def calculate_answer(received_value):
    # Determine the type of query and execute the appropriate one
    if "Filter Query" in received_value:
        result = subprocess.run(['mysql', '-u' 'daniel_talia', '-p' 'TD123456', '-D' 'IMDB_Top_Movies', '-e', filter_query], capture_output=True, text=True)
    elif "Count Query" in received_value:
        result = subprocess.run(['mysql', '-u' 'daniel_talia', '-p' 'TD123456', '-D' 'IMDB_Top_Movies', '-e', count_query], capture_output=True, text=True)
    elif "Aggregation Query" in received_value:
        result = subprocess.run(['mysql', '-u' 'daniel_talia', '-p' 'TD123456', '-D' 'IMDB_Top_Movies', '-e', aggregation_query], capture_output=True, text=True)
    elif "Interesting Query" in received_value:
        result = subprocess.run(['mysql', '-u' 'daniel_talia', '-p' 'TD123456', '-D' 'IMDB_Top_Movies', '-e', query_c], capture_output=True, text=True)
    else:
        return "Invalid query type"

    # Check the result return code and handle errors
    if result.returncode != 0:
        print("Error:", result.stderr)
        return result.stdout
    else:
        return result.stdout

if __name__ == "__main__":
    app.run(host='0.0.0.0')
