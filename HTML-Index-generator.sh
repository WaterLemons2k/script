#!/bin/bash
#http://nginx.org/en/docs/http/ngx_http_autoindex_module.html
#https://stackoverflow.com/questions/21395159
#https://serverfault.com/questions/354403

echo HTML Index generator version 1.0.0
pwd=$(pwd) #Set the current directory as the root directory

for cd in $(find -type d | sed 's|^./||'); do #For loop all directories under the current directory
    echo Generating Index of /$cd
    cd $cd
    
    if [[ $cd != "." ]]; then #If current directory not equal . (Not the root directory)
        echo -e "<html>\n<head><title>Index of /$cd</title></head>\n<body>\n<h1>Index of /$cd</h1><hr><pre><a href=\"../\">../</a>" > index.html
    else #Else is the root directory
        echo -e "<html>\n<head><title>Index of /</title></head>\n<body>\n<h1>Index of /</h1><hr><pre>" > index.html
    fi

    for directory in $(find -maxdepth 1 -type d ! -name "."); do #Output all directories to index.html
        directory=$(basename $directory)
        echo "<a href=\"$directory/\">$directory/</a>" >> index.html
    done

    for file in $(find -maxdepth 1 -type f ! -name "index.html"); do #Output all files to index.html (Except index.html)
        file=$(basename $file)
        echo "<a href=\"$file\">$file</a>" >> index.html
    done

    echo -e "</pre><hr></body>\n</html>" >> index.html
    cd $pwd #Back to the root directory
done