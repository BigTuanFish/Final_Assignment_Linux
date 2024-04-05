#!/bin/bash
#Q3

# Ask the user to write a 5-letter word
read -p "Write a 5-letter word: " input_word

# Check that the input word in 5 letters long and hold only alphabetical values
if [ "${#input_word}" -ne 5 ] || [[ ! "$input_word" =~ ^[a-zA-Z]*$ ]]; then
    echo "The word needs to be of 5 characters that are alphabetical"
    read -p "Press enter to exit"
    exit 1
fi

# Ask the user to pick the colors of each letter (s, y, g)
read -p "Pick the colors of each letter (s, y, g): " colors

#Check length and colors
if [ "${#colors}" -ne 5 ] || [[ ! "$colors" =~ ^[sygSYG]*$ ]]; then
    echo "The colors string need to be 5 characters long and consist only the following letters: s, y, g (case-insensitive)"
    read -p "Press enter to exit"
    exit 1
fi


#From words.txt- save only 5 letter words
reduced_words_txt=$(curl -s https://raw.githubusercontent.com/dwyl/english-words/master/words.txt | grep -xE '[[:alpha:]]{5}')

#Loop over the letters of the word and the assigned color and act accordingly
for (( i=0; i<5; i++ )) do

	# if silver (s): match words from the txt file that do not hold the current letter of the input_word in any position

	if [[ "${colors:i:1}" == [Ss] ]]; then
			matching_words=$(echo "$reduced_words_txt" | grep -i -E -v "${input_word:${i}:1}")
			reduced_words_txt="$matching_words"

	fi

	# if yellow (y): match words from the txt file that hold the current letter of the input_word in a different position

	if [[ "${colors:i:1}" == [Yy] ]]; then
		matching_words=$(echo "$reduced_words_txt" | grep -i -E "${input_word:${i}:1}" | grep -i -E -v "^[a-zA-Z]{${i}}${input_word:${i}:1}[a-zA-Z]*")
		reduced_words_txt="$matching_words"
	fi

	# if green (g): match words from the txt file that the current letter of the input_word is the same and in the same position

	if [[ "${colors:i:1}" == [Gg] ]]; then
			matching_words=$(echo "$reduced_words_txt" | grep -i -E "^[a-zA-Z]{${i}}${input_word:${i}:1}[a-zA-Z]*")
			reduced_words_txt="$matching_words"
	fi

	matching_words=""

done

echo "$reduced_words_txt"
