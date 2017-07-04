# Web-Authentication-for-iNuist

## Introduction
* A simple script for authentication with i-nuist using the web interface, specially in NUIST.

## Usage
    [Interactive Mode]
        ./web_auth.sh  

    [Automatic Mode]"
        ./web_auth.sh login -u [username] -p [password] -d [domain]
        ./web_auth.sh logout
        ./web_auth.sh status

## Note
    The domain should be CMCC Unicom NUIST or ChinaNet. 

## Notice
#### If the script need run on LEDE/OpenWrt,here the problems
* You need to install `coreutils-base64` on LEDE/OpenWrt.