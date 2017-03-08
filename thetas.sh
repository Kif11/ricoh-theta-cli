#!/usr/bin/env bash

# Author: Kirill Kovalevskiy
# Email: kovalewskiy@gmail.com

# Command line interface for RICON Theta S API
# https://developers.theta360.com/en/docs/v2.1/api_reference/
# You should have latest firmware that support API 2.1

# Camera API routes
cam_addr="192.168.1.1:80"
execute_addr="${cam_addr}/osc/commands/execute"


function  printb {
  # Print text bold
  BOLD='\e[1m'
  NORM='\e[0m'
  printf ${BOLD}"$@"${NORM}
  return 0
}


function print_help {
  # Display help for the tool
  printf "\n"
  printb "NAME\n"
  printf "\n"
  printf "  thetas - Command line interface for RICON Theta S camera\n"
  printf "\n"
  printb "COMMANDS\n"
  printf "\n"
  printf "  init         run it first to configure canera api\n"
  printf "  state        print camera status\n"
  printf "  snap         take a single still picture\n"
  printf "  getlast      download last captured image\n"
  printf "  list         list files on the device\n"


  printb "\nEXAMPLES\n"
  printf "\n"
  printf "  Take a single picture\n"
  printf "    thetas pic\n"

  printf "\n"
}


function set_api_version {
  # By default you camera might have API 2.0 active
  # This command will switch it to 2.1

  # Start camera session since a session should be started before executing commands in API v2.0
  session=$( curl -s --data '{"name": "camera.startSession", "parameters": {}}' ${execute_addr} )
  session_id=`echo ${session} | jq .results.sessionId`

  version=$1

  if [[ -z ${version} ]]; then
    version=2
  fi

  data="{
    \"name\": \"camera.setOptions\",
    \"parameters\": {
      \"sessionId\": ${session_id},
      \"options\": {
        \"clientVersion\": ${version}
      }
    }
  }"
  curl -s --data "${data}" ${execute_addr}

  # end_session ${session_id}
}


function end_session {
  # Close camera session by its id
  session_id=$1
  data="{
    \"name\": \"camera.closeSession\",
    \"parameters\": {
      \"sessionId\": ${session_id}
    }
  }"
  echo $data
  curl -s --data "${data}" ${execute_addr}
}


function get_state {
  # Show camera state info
  curl -s -X POST ${cam_addr}/osc/state
}


function take_picture {
  # Take a single picture
  # Camera should be in photo mode

  data="{\"name\": \"camera.takePicture\"}"
  curl -s --data "${data}" ${execute_addr}
}


function list_files {
  count=$1

  if [[ -z $count ]]; then
    count=-1  # Default to list all available files
  fi

  data="{
    \"name\": \"camera.listFiles\",
    \"parameters\": {
      \"fileType\": \"all\",
      \"entryCount\": ${count},
      \"maxThumbSize\": 0
    }
  }"
  curl -s --data "${data}" ${execute_addr}
}


function download_latest {
  img_path="latest.jpg"
  url=$(get_state | jq -r .state._latestFileUrl)
  curl -o ${img_path} ${url}
  open ${img_path}
}


# Process commands
cmd=$1

case $cmd in
  "init")
    shift
    set_api_version 2
    ;;
  "state")
    shift
    get_state | jq
    ;;
  "snap")
    shift
    take_picture "$@" | jq
    ;;
  "getlast")
    shift
    download_latest "$@" | jq
    ;;
  "list")
    shift
    list_files "$@" | jq
    ;;
  "test")
    shift
    # echo "Hello this is me!"
    list_files "$@"
    ;;
  *)
    print_help
esac
