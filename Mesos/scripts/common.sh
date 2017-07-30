#!/bin/bash
set -ex

function log {
  timestamp=$(date)
  echo "$timestamp: $1"       #stdout
  echo "$timestamp: $1" 1>&2; #stderr
}

# Time marker for both stderr and stdout
log "Running Mesos CSD control script..."
log "Detected CDH_VERSION of [$CDH_VERSION]"

HOST_IP=(`hostname -I`)

export MESOS_HOME=/opt/cloudera/parcels/MESOS

echo ""
echo "Date: `date`"
echo "Host: $HOST"
echo "Pwd: `pwd`"
echo "CONF_DIR: $CONF_DIR"
echo "MESOS_HOME: $MESOS_HOME"
echo "Zookeeper Quorum: $ZK_QUORUM"
echo "Zookeeper Chroot: $CHROOT"
echo "PORT: $PORT"
echo "Work Dir: $WORK_DIR"
echo "Log Dir: $LOG_DIR"

if [[ -z ${ZK_PRINCIPAL_NAME} ]]; then
    ZK_PRINCIPAL_NAME="zookeeper"
fi
echo "ZK_PRINCIPAL_NAME: ${ZK_PRINCIPAL_NAME}"

# Generating Zookeeper quorum
QUORUM=$ZK_QUORUM
if [[ -n $CHROOT ]]; then
	QUORUM="${QUORUM}${CHROOT}"
fi
echo "Final Zookeeper Quorum is $QUORUM"

function start_mesos_master {
    log "Starting Mesos Master"
    exec $MESOS_HOME/sbin/mesos-master --zk=zk://$QUORUM --work_dir=$WORK_DIR --log_dir=$LOG_DIR --port=$PORT --ip=$HOST_IP --hostname=$HOST_IP --quorum=1
}

function stop_mesos_master {
    log "Stopping Mesos Master"
    exec kill -9 `ps aux | grep [m]esos-master | awk '{print $2}'`
}

function start_mesos_agent {
    log "Starting Mesos Agent"
    exec $MESOS_HOME/sbin/mesos-agent --master=zk://$QUORUM --work_dir=$WORK_DIR --ip=$HOST_IP \
    --launcher_dir=$MESOS_HOME/libexec/mesos --log_dir=$MESOS_HOME/log/slave \
    --logging_level=ERROR --containerizers=mesos \
    --executor_registration_timeout=5mins
}
function stop_mesos_agent {
    log "Stopping Mesos Agent"
    exec kill -9 `ps aux | grep [m]esos-agent | awk '{print $2}'`
}
