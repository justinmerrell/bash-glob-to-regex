#!/bin/bash

# Check for input arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <gitignore_file>"
    exit 1
fi

gitignore_file=$1

# Check if the gitignore file exists
if [ ! -f "$gitignore_file" ]; then
    echo "Gitignore file not found: $gitignore_file"
    exit 1
fi

# Generate the output file name by appending _regex
regex_file="${gitignore_file%.*}_regex.txt"

# Function to convert gitignore pattern to regex
convert_to_regex() {
    local pattern=$1

    # Escape special regex characters, except for *, ?, and []
    pattern=$(echo "$pattern" | sed 's/[][\/$^.|(){}+?*^]/\\&/g')

    # Convert gitignore wildcards to regex
    # **/ and /** becomes .*/
    # * becomes [^/]*
    # ? becomes .
    # Leading slash / is removed for anchoring at any directory level
    pattern=$(echo "$pattern" | sed -e 's/\*\*\//.*/g' -e 's/\/\*\*/.*/g' -e 's/\*/[^\/]*/g' -e 's/\?/./g' -e 's/^\///')

    echo "^$pattern$"
}

# Clear the regex file content
> "$regex_file"

while IFS= read -r line; do
    # Trim leading and trailing whitespace
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    # Convert the pattern and write to the regex file
    converted_pattern=$(convert_to_regex "$line")
    echo "$converted_pattern" >> "$regex_file"

done < "$gitignore_file"

echo "Conversion completed. Regex patterns are saved in $regex_file"
