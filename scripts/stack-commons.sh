#!/bin/bash

function test_stack {
    typeset var local STACK_NAME=$1
    aws cloudformation describe-stacks --stack-name $STACK_NAME >/dev/null 2>&1
    exitSts=$?
    if [ $exitSts -eq 0 ] ; then
        echo 0
    else
        echo 1
    fi
}

function stack_exists {
    typeset var local STACK_NAME=$1
    [ $(test_stack "$STACK_NAME") -eq 0 ]
}

function create_stack {
    typeset var local STACK_NAME=$1
    typeset var local STACK_BODY=$2
    if ! stack_exists $STACK_NAME ; then
        aws cloudformation create-stack \
        --template-body file://${STACK_BODY}  \
        --stack-name ${STACK_NAME}

        aws cloudformation wait stack-create-complete \
        --stack-name ${STACK_NAME}
    fi
    aws cloudformation describe-stacks --stack-name $STACK_NAME
}

function create_or_update_stack {
    typeset var local STACK_NAME=$1
    typeset var local STACK_BODY=$2
    typeset var local STACK_PARAMETERS=
    if [ $# -gt 2 ] ; then
        STACK_PARAMETERS="$3"
    fi
    typeset var local exitSts=0
    if stack_exists $STACK_NAME ; then
        echo "updating stack $STACK_NAME"
        aws cloudformation update-stack \
        --template-body file://${STACK_BODY}  \
        --stack-name ${STACK_NAME} \
        $STACK_PARAMETERS \
         2>/dev/null
        exitSts=$?
        #No update needed
        if [ $exitSts -eq 0 ] ; then
            aws cloudformation wait stack-update-complete \
            --stack-name ${STACK_NAME}
        else
            echo "No updates needed for stack $STACK_NAME"
        fi
    else
        echo "creating stack $STACK_NAME"
        aws cloudformation create-stack \
        --template-body file://${STACK_BODY}  \
        --stack-name ${STACK_NAME} \
        $STACK_PARAMETERS

        aws cloudformation wait stack-create-complete \
        --stack-name ${STACK_NAME}
    fi
    aws cloudformation describe-stacks --stack-name $STACK_NAME

}

function getTaskOutputs {
    typeset var local STACK_NAME=$1
    typeset var local FILE_NAME=
    if [ $# -gt 1 ] ; then
        FILE_NAME=$2
    fi
    if [ ! -z $FILE_NAME ] ; then
        if [ ! -f $FILE_NAME ] ; then
            aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '[.Stacks[0].Outputs[] | {key: .OutputKey, value: .OutputValue}] | from_entries' > $FILE_NAME
        fi
        cat $FILE_NAME
    else
        aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '[.Stacks[0].Outputs[] | {key: .OutputKey, value: .OutputValue}] | from_entries'
    fi
}

function getTaskOutputsValue {
    typeset var local STACK_NAME=$1
    typeset var local VALUE=$2
    typeset var local JSON_FILE=
    if [ $# -gt 2 ] ; then
        JSON_FILE=$3
    fi
    getTaskOutputs $STACK_NAME $JSON_FILE | jq ". | .$VALUE" | sed 's/.*"\([^"]*\)".*/\1/'
}
