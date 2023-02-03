#!/bin/bash

# Check if jq and xclip packages are installed
if ! command -v jq > /dev/null 2>&1 || ! command -v xclip > /dev/null 2>&1; then
  echo "The packages Jq and/or XClip are not installed."
  read -p "Would you like to install them? (y/n) " yn
  if [[ $yn == "y" || $yn == "Y" ]]; then
    sudo apt-get update
    sudo apt-get install jq xclip -y
  else
    exit 1
  fi
fi

# Check API key
if [[ -z "$CHATGPT_TOKEN" ]]; then
  echo "Error: API key not set."
  exit 1
fi

# Read input
read -p $'\e[1;32m[+] Input: \e[0m' input

echo -e "\n\e[1;32m[+] Output:\e[0m"

# Perform the curl command
curl=`cat <<EOS
curl -s https://api.openai.com/v1/completions \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CHATGPT_TOKEN" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "$input",
  "max_tokens": 4000,
  "temperature": 1.0

}' \
--insecure | jq -r '.choices[0].text' | tee >(xclip -sel clip)
EOS`

response=$(eval ${curl})

# Check for jq error
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve response from the API. Please update your API key."
  exit 1
fi

if [ -z "$response" ]; then
  echo "Error: Response from API is null. Please reach out to raiin#9044 on Discord for support."
  exit 1
fi

echo $response

# Loop to ask user if they want to enter another input
while true; do
  read -p $'\e[1;32m[+] Do you want to enter another input (Y/n): \e[0m' yn
  case $yn in
    [Yy]* )
      read -p $'\e[1;32m[+] Input: \e[0m' input
      echo -e "\n\e[1;32m[+] Output:\e[0m"
      response=$(eval ${curl})
      if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve response from the API. Please update your API key."
        exit 1
      fi
      if [ -z "$response" ]; then
        echo "Error: Response from API is null. Please reach out to raiin#9044 on Discord for support."
        exit 1
      fi
      echo $response
      ;;
    [Nn]* )
      exit 0
      ;;
    * )
      echo "Please answer Y or n."
      ;;
  esac
done
