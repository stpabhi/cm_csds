#!/bin/bash
. $(cd $(dirname $0) && pwd)/common.sh

case $1 in
    (start-mesos-master)
        start_mesos_master
        ;;

    (start-mesos-agent)
        start_mesos_agent
        ;;
    
    (stop-mesos-master)
        stop_mesos_master
        ;;

    (stop-mesos-agent)
        stop_mesos_agent
    ;;

    (stop)
     kill -9 `ps aux | grep [m]esos-master | awk '{print $2}'`
     kill -9 `ps aux | grep [m]esos-agent | awk '{print $2}'`
    ;;
    
    (*)
    log "Don't understand [$1]"
    exit 1
    ;;
esac