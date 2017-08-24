#!/bin/bash

#About:     Web authentication for i-nuist, specially in NUIST.
#Version:   1.0
#Date:      20170317
#Author:    Blacate <i#blacate.me>
#Refer:     Web authentication for Dr.com <King's Way>


time=$(date +%s%N | cut -b1-13)
if [ "${#time}" = "13" ];then
    timestamp=${time}
else
    timestamp=${time}000
fi
url_init="http://10.255.255.13/index.php/index/init?_=$timestamp"
url_login="http://10.255.255.13/index.php/index/login"
url_logout="http://10.255.255.13/index.php/index/logout"

fun_help()
{
    echo "-------------------------------------------------------------------"
	echo "Usage:"
	echo "    [Interactive Mode]"
	echo "        ./web_auth.sh      # Yeah,just run me directly"
	echo 
	echo "    [Automatic Mode]"
	echo "        ./web_auth.sh login -u [username] -p [password] -d [domain]"
	echo "        ./web_auth.sh logout"
    echo "        ./web_auth.sh status"
    echo "Notes: The domain should be CMCC Unicom NUIST or ChinaNet "
	echo "-------------------------------------------------------------------"
}

fun_auto_mode()
{
    while getopts "u:p:d:" option;
    do
        case $option in
            u)  username=$OPTARG;;
            p)  password=$OPTARG;;
            d)  domain=$OPTARG;;
        esac
    done
    fun_login
}

fun_interact_mode()
{
    fun_help

    read -p "Want to login(I) or logout(o) or status(s)? [I/o/s]" choice

    if [ "$choice" = "o" ] || [ "$choice" = "O" ];then
            fun_logout
    elif [ "$choice" = "s" ] || [ "$choice" = "S" ];then
            fun_status
    else
            read -p "Domain: CMCC Unicom NUIST or ChinaNet" domain
            stty echo
            read -p "Username: " username
            stty -echo
            read -p "Password: " password
            stty echo
            echo "/n"
            fun_login
    fi
}

fun_init()
{
    init_data=$(wget -q $url_init -O -)
    state=$(echo $init_data |tr -s "," "\012" | grep status | cut -b 10)
    #state:0 Not Login
    #state:1 Already Login
}

fun_status()
{
    fun_init
    if [ "$state" = "0" ];then
            echo "Not Login"
    else
            login_username=$(echo $init_data |tr -s "," "\012" | grep logout_username | cut -d \" -f4|awk '{print $1}')
            echo "Already Login"
            echo "Username: $login_username"
    fi
}

fun_login()
{
    fun_init
    if [ "$username" = "" ] || [ "$password" = "" ] || [ "$domain" = "" ];then
			echo "Please specify the username domain and password!"
			exit -1
	fi

    if [ "$state" = "1" ];then
            echo "You have already Login"
            exit -1
    fi
    
    if [ "$domain" != "CMCC" ] && [ "$domain" != "NUIST" ] && [ "$domain" != "ChinaNet" ] && [ "$domain" != "Unicom" ];then
            echo "The domain should be CMCC Unicom NUIST or ChinaNet"
            exit -1
    fi

    encrypt=$(echo -n $password | base64)
    login_data=$(wget $url_login -q --post-data "username=$username&domain=$domain&password=$encrypt&enablemacauth=0" -O -)
    login_state=$(echo $login_data |tr -s "," "\012" | grep status | cut -b 10)
    login_info=$(echo $login_data |tr -s "," "\012" | grep info | cut -d \: -f2)
    if [ "$login_state" = "1" ];then
            echo "Login Successful"
            echo "username:$username"
    else
            echo "Failed"
            echo -e "Info:$login_info"
    fi
}

fun_logout()
{
    fun_init

    if [ "$state" = "0" ];then
            echo "Not Login"
            exit -1
    fi

    logout_data=$(wget --method post -q $url_logout -q -O -)
    logout_state=$(echo $logout_data |tr -s "," "\012" | grep status | cut -b 10)
    logout_info=$(echo $logout_data |tr -s "," "\012" | grep info | cut -d \: -f2)
    if [ "$logout_state" = "1" ];then
            echo "Logout Successful"
    else
            echo "Failed"
            echo -e "Info: $logout_info"
    fi

}

if [ $# -eq 0 ];then
    fun_interact_mode
elif [ "$1" = "login" ];then
    fun_auto_mode $2 $3 $4 $5 $6 $7
elif [ "$1" = "logout" ];then
    fun_logout
elif [ "$1" = "status" ];then
    fun_status
fi