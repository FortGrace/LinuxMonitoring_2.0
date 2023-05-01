#!/bin/bash
cd `dirname $0`
PATH_TO_SCRIPT=`pwd`
#date parametr fo name
DATE_NAME=$(date +%D | awk -F / '{print $2$1$3}')

function name_generator {
    local NAME=
    local ALPHABET=
    local ALPHABET=$1
    local LENGTH_ALPHABET=
    local LENGTH_ALPHABET=`expr length $ALPHABET 2> /dev/null`
    for (( i=1; i<=$LENGTH_ALPHABET; i++ ))
    do
        local arr[$i]=
        local arr[$i]=`expr substr $ALPHABET $i 1 2> /dev/null`
        local NAME+="${arr[$i]}"
    done
    echo $NAME
}

function add_Sign {
    local NAME=
    local NAME=$1
    local ALPHABET=
    local ALPHABET=$2
    local SYMBOL=
    local SYMBOL=$3
    local LENGTH_ALPHABET=`expr length $ALPHABET 2> /dev/null`
    for (( i=1; i<=$LENGTH_ALPHABET; i++ ))
    do
        local arr[$i]=
        local arr[$i]=`expr substr $ALPHABET $i 1 2> /dev/null`
    done
    local INDEX_SIGN=`expr index $NAME ${arr[$SYMBOL]} 2> /dev/null`
    local TMP_NAME=
    local TMP_NAME=$(expr substr $NAME 1 $INDEX_SIGN 2> /dev/null)${arr[$SYMBOL]}$(echo ${NAME:$INDEX_SIGN})
    local NAME=$TMP_NAME
    echo $NAME
}

for ((j=0; j<$COUNT_DIR; j++))
do
    cd $ABS_PATH
    if ! [[ $? -eq 0 ]];
    then exit 1
    fi
    FREE_SPACE_MB=$(df / |  head -2 | tail +2 | awk '{printf("%d", $4)}')
    if [[ $FREE_SPACE_MB -le 1048576 ]]
    then
        break
    else
        :
    fi
    #CREATE FOLDER
    NAME_DIR=$(name_generator $ALPHABET_DIR)
    TMP_NAME_DIR=$NAME_DIR"_"$DATE_NAME
    CHAR=0
    while [ -e "$TMP_NAME_DIR" ] || [[ `expr length $NAME_DIR` -lt 4 ]];
    do
        if [[ CHAR -ge `expr length $ALPHABET_DIR` ]] || [[ `expr length $ALPHABET_DIR` -eq 1 ]]
        then
            CHAR=1
        else
            CHAR=$(($CHAR+1))
        fi
        NAME_DIR=$(add_Sign $NAME_DIR $ALPHABET_DIR $CHAR)
        TMP_NAME_DIR=$NAME_DIR"_$DATE_NAME"
    done
    sudo mkdir $TMP_NAME_DIR 2>/dev/null
    if ! [ -d  $TMP_NAME_DIR ]; then
        exit 1
    fi
    echo $(pwd)"/$TMP_NAME_DIR/" `date +%F" "%H":"%M` >> $PATH_TO_SCRIPT/logs_file.txt
    #CREATE FILES
    for ((f=0;f<$COUNT_FILES; f++))
    do
        CHAR_FILE=0
        NAME_FILE=$(name_generator $ALPHABET_FILE)
        FILE=$TMP_NAME_DIR"/$NAME_FILE.$ALPHABET_EXT"
        while [ -e $FILE ] || [[ `expr length $NAME_FILE` -lt 4 ]];
        do
            if [[ CHAR_FILE -ge `expr length $ALPHABET_DIR` ]] || [[ `expr length $ALPHABET_FILE` -eq 1 ]]
            then
                CHAR_FILE=1
            else
                CHAR_FILE=$(($CHAR_FILE+1))
            fi
            NAME_FILE=$(add_Sign $NAME_FILE $ALPHABET_FILE $CHAR_FILE)
            FILE=$TMP_NAME_DIR"/$NAME_FILE.$ALPHABET_EXT"
        done
        sudo touch $FILE 2> /dev/null
        if ! [ -e  $FILE ]; then
        exit 1
        fi
        sudo fallocate -l $SIZE_FILE"MB" $FILE 2> /dev/null
        echo $(pwd)"/$FILE" `date +%F" "%H":"%M` `ls -lh $FILE 2> /dev/null | awk '{print $5}'` >>  $PATH_TO_SCRIPT/logs_file.txt
        FREE_SPACE_MB=$(df / |  head -2 | tail +2 | awk '{printf("%d", $4)}')
        if [[ $FREE_SPACE_MB -le $((1048576+$(($SIZE_FILE*1024)))) ]]
        then
            exit 1
        fi
    done
done
