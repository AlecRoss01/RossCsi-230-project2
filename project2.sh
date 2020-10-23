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
            temp=$(echo $(grep "${user}" /etc/passwd | cut -d ":" -f 1))
            if [[ ${temp} == ${user} ]]; then
                echo "${user} alread exists"
                echo "${pass} is new password"
                echo -e "${pass}\n${pass}" | passwd ${user}
                chage --lastday 0 ${user}
                usermod -a -G CSI230 ${user}
                usermod --shell /bin/bash ${user}
            else
                echo "${user} does not exist, creating new user"
                echo "Password is : ${pass}"
                useradd ${user}
                echo -e "${pass}\n${pass}" | passwd ${user}
                usermod -a -G CSI230 ${user}
                chage --lastday 0 ${user}
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
