#!/bin/bash

read -p $'\e[1;32m[+] Input: \e[0m' input

echo -e "\n\e[1;32m[+] Output:\e[0m"

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

eval ${curl}

while true; do
  read -p $'\e[1;32m[+] Do you want to enter another input (Y/n): \e[0m' yn
  case $yn in
    [Yy]* ) 
      read -p $'\e[1;32m[+] Input: \e[0m' input
      echo -e "\n\e[1;32m[+] Output:\e[0m"
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
      eval ${curl}
      ;;
    [Nn]* ) 
      exit 0 
      ;;
    * ) 
      echo "Please answer Y or n." 
      ;;
  esac
done
