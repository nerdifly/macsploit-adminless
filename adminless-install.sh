#!/bin/bash

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version 2.3"

    echo -ne "Checking License..."
    curl -s "https://git.abyssdigital.xyz/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    
    curl -s "https://git.abyssdigital.xyz/sellix/hwid" -o "./hwid"
    chmod +x ./hwid
    
    local user_hwid=$(./hwid)
    local hwid_resp=$(curl -s "https://git.abyssdigital.xyz/api/whitelist?hwid=$user_hwid" | ./jq -r ".success")
    rm ./hwid
    
    if [ "$hwid_resp" != "true" ]
    then
        echo -ne "\rEnter License Key:       \b\b\b\b\b\b"
        read input_key

        echo -n "Contacting Secure Api... "
        
        local resp=$(curl -s "https://git.abyssdigital.xyz/api/sellix?key=$input_key&hwid=$user_hwid")
        echo -e "Done.\n$resp"
        
        if [ "$resp" != 'Key Activation Complete!' ]
        then
            rm ./jq
            exit
            return
        fi
    else
        echo -e " Done.\nWhitelist Status Verified."
    fi

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local version=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer" | ./jq -r ".clientVersionUpload")
    curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    rm ./jq

    echo -n "Installing Latest Roblox... "
    [ -d "./m-sploit/Roblox.app" ] && rm -rf "./m-sploit/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app ./m-sploit/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    curl "https://git.abyssdigital.xyz/main/macsploit.zip" -o "./MacSploit.zip"

    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip"
    echo -e "Done."

    echo -n "Updating Dylib..."
    if [ "$version" == "version-3d35fae7df43441f" ]
    then
        curl -Os "https://git.abyssdigital.xyz/preview/macsploit.dylib"
    else
        curl -Os "https://git.abyssdigital.xyz/main/macsploit.dylib"
    fi
    
    echo -e " Done."
    echo -e "Patching Roblox..."
    mv ./macsploit.dylib "./m-sploit/Roblox.app/Contents/MacOS/macsploit.dylib"
    mv ./libdiscord-rpc.dylib "./m-sploit/Roblox.app/Contents/MacOS/libdiscord-rpc.dylib"
    ./insert_dylib "./m-sploit/Roblox.app/Contents/MacOS/macsploit.dylib" "./m-sploit/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "./m-sploit/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "./m-sploit/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "./m-sploit/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    echo -n "Installing MacSploit App... "
    [ -d "./m-sploit/MacSploit.app" ] && rm -rf "./m-sploit/MacSploit.app"
    mv ./MacSploit.app ~/m-sploit/MacSploit.app
    rm ./MacSploit.zip
    echo -e "Done."

    echo -e "Install Complete! Developed by Nexus42!"
    exit
}

main
