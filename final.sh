#!/bin/bash

while IFS= read -r line; do
    IFS=', ' read -r -a array <<< "$line"

checkout_git() {
    local url=${array[0]}
    local folder_name=$(basename "$url" .git)

    if [ -d "$folder_name" ]; then
        echo "Repository already exists. Skipping cloning."
    else
        echo "Cloning repository from $url"
        git clone "$url" "$folder_name"

        if [ $? -eq 0 ]; then
            echo "Repository cloned successfully."
        else
            echo "Failed to clone repository. Exiting..."
            exit 1
        fi
    fi
}

sonar_analysis() {
    if [ $# -ne 3 ]; then
        echo "Usage: sonar_analysis <project_key> <token> <branch>"
        return 1
    fi
    
    project_key=$1
    token=$2
    branch=$3
    
    /opt/sonarscanner/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner \
    -Dsonar.projectKey="$project_key" \
    -Dsonar.sources="." \
    -Dsonar.host.url="http://localhost:9000" \
    -Dsonar.login="$token" \
    #-Dsonar.branch.name="$branch"
    
    if [ $? -eq 0 ]; then
        echo "Sonar analysis completed successfully for branch $branch"
    else
        echo "Sonar analysis failed for branch $branch"
    fi
    echo "=================================================================================="
}

main(){
    checkout_git "${array[0]}"
    sonar_analysis "${array[1]}" "${array[2]}" "${array[3]}"
}
main

done < input.txt

