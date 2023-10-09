#!/bin/sh

CMD=$1

if [ $1 = "sync" ]
    then
        echo Syncing
        ionic cap sync android && ionic cap open android
    else
        echo SYNC, BUILD AND SIGN
        ionic cap sync android && cd android && ./gradlew assembleRelease && cd ../android/app/build/outputs/apk/release && jarsigner -keystore /home/tonni/Desktop/Keys/ionic-key.jks -storepass Baseline@072 app-release-unsigned.apk key0 && zipalign 4 app-release-unsigned.apk app-release.apk
        xdg-open .
        echo DONE!
fi
#