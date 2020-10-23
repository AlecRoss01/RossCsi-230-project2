#!/bin/bash



#https://stackoverflow.com/questions/14810684/check-whether-a-user-exists#:~:text=user%20infomation%20is%20stored%20in,%22no%20such%20user%22%20message.&text=Login%20to%20the%20server.
#used to figure out how to grep passwd

#main
file=${1}
if [ "$(id -u)" = "0" ]; then
    if [ -f ${file} ]; then
        echo "Valid File"
        while read line; do
            user=$(echo ${line} | cut -d "@" -f 1)
            pass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)
            #my original random didn't want to work with me, so I searched around and found one that was specifically characters, rather than openssl which i used originally
            #https://unix.stackexchange.com/questions/230673/how-to-generate-a-random-string
            temp=$(echo $(grep "${user}" /etc/passwd | cut -d ":" -f 1))
            if [[ ${temp} == ${user} ]]; then
                echo "${user} alread exists"
                echo "${pass} is new password"
                echo -e "${pass}\n${pass}" | passwd ${user}
                #had issues changing passwords for alread created users, then I used a trick I found here
                #https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
                chage --lastday 0 ${user}
                usermod -a -G CSI230 ${user}
                usermod --shell /bin/bash ${user}
            else
                echo "${user} does not exist, creating new user"
                #https://www.tecmint.com/add-users-in-linux/#:~:text=To%20add%2Fcreate%20a%20new,already%20exists%20on%20the%20system).
                #first iteration of adding users, didn't go so well, but I undesrtood how
                echo "Password is : ${pass}"
                useradd ${user}
                echo -e "${pass}\n${pass}" | passwd ${user}
                usermod -a -G CSI230 ${user}
                chage --lastday 0 ${user}
                #chage evaded me for a bit but eventually I came to undesrtand it after looking over the online man page equivilent of it
                #https://linux.die.net/man/1/chage
                usermod --shell /bin/bash ${user}
            fi
        done <${file}
    else
        echo "Invalid File"
        exit 2
    fi
else
    echo "please run as root"
    exit 1
fi 
