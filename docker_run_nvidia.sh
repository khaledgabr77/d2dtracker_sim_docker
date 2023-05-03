#! /bin/bash
# Runs a docker container for PX4 + ROS 2 Humble dev environment
# Requires:
#   - docker
#   - nvidia-docker
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Mohammed Abdelkader, mohamedashraf123@gmail.com

# if [ -z "$GIT_USER" ]; then
# 	echo && echo "ERROR: Environment variable GIT_USER is not defined. Kindly export your GIT_USER" && echo
# 	exit 10
# fi

# # GIT_TOKEN must be exported (e.g. in .bashrc)
# if [ -z "$GIT_TOKEN" ]; then
# 	echo && echo "ERROR: GIT_TOKEN of the Github pkgs is not exported. Contact your Github admin to obtain it." && echo
# 	exit 10
# fi


# DOCKER_REPO="mzahana/px4-dev-ros2-humble:latest"
DOCKER_REPO="mzahana/px4-dev-simulation-ubuntu22"
# DOCKER_REPO="osrf/ros:humble-desktop"
CONTAINER_NAME="d2dtracker"
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
CMD=""
DOCKER_OPTS=""

# Get the current version of docker-ce
# Strip leading stuff before the version number so it can be compared
DOCKER_VER=$(dpkg-query -f='${Version}' --show docker-ce | sed 's/[0-9]://')
if dpkg --compare-versions 19.03 gt "$DOCKER_VER"
then
    echo "Docker version is less than 19.03, using nvidia-docker2 runtime"
    if ! dpkg --list | grep nvidia-docker2
    then
        echo "Please either update docker-ce to a version greater than 19.03 or install nvidia-docker2"
	exit 1
    fi
    DOCKER_OPTS="$DOCKER_OPTS --runtime=nvidia"
else
    DOCKER_OPTS="$DOCKER_OPTS --gpus all"
fi
echo "GPU arguments: $DOCKER_OPTS"

# This will enable running containers with different names
# It will create a local workspace and link it to the image's catkin_ws
if [ "$1" != "" ]; then
    CONTAINER_NAME=$1
fi
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
if [ ! -d $WORKSPACE_DIR ]; then
    mkdir -p $WORKSPACE_DIR
fi
echo "Container name:$CONTAINER_NAME WORSPACE DIR:$WORKSPACE_DIR" 


if [ "$2" != "" ]; then
    CMD=$2
fi

XAUTH=/tmp/.docker.xauth
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]
then
    echo XAUTH file does not exist. Creating one...
    touch $XAUTH
    chmod a+r $XAUTH
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    fi
fi

# Prevent executing "docker run" when xauth failed.
if [ ! -f $XAUTH ]
then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi


echo "Shared WORKSPACE_DIR: $WORKSPACE_DIR";

#not-recommended - check this: http://wiki.ros.org/docker/Tutorials/GUI
xhost +local:root
 
echo "Starting Container: ${CONTAINER_NAME} with REPO: $DOCKER_REPO"

CMD="export DEV_DIR=/home/user/shared_volume && \
    export PX4_DIR=\$DEV_DIR/PX4-Autopilot &&\
        source /home/user/shared_volume/ros2_ws/install/setup.bash && \
         /bin/bash"
if [[ -n "$GIT_TOKEN" ]] && [[ -n "$GIT_USER" ]]; then
    CMD="export GIT_USER=$GIT_USER && export GIT_TOKEN=$GIT_TOKEN && $CMD"
fi

if [[ -n "$SUDO_PASSWORD" ]]; then
    CMD="export SUDO_PASSWORD=$SUDO_PASSWORD && $CMD"
fi

# echo $CMD

if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        echo "Restarting the container..."
        docker start ${CONTAINER_NAME}
    fi

    docker exec --user user -it ${CONTAINER_NAME} env TERM=xterm-256color bash -c "${CMD}"

else


    # The following command clones drone_hunter_sim. It gets executed the first time the container is run
    # CMD="source /opt/ros/noetic/setup.bash  && source /root/.bashrc &&\
    # 	export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:$PX4_ROOT/PX4-Autopilot &&\
    #     export GIT_TOKEN=${GIT_TOKEN} && export GIT_USER=${GIT_USER} && \
    #     export CATKIN_WS=$CATKIN_WS && \
    #     export PX4_ROOT=$PX4_ROOT && \
    #     export OSQP_SRC=/root/shared_volume/src &&\
    #     if [ ! -d "$CATKIN_WS/src" ]; then
    #     mkdir -p $CATKIN_WS/src
    #     fi && \
    #     if [ ! -d "$CATKIN_WS/src/drone_hunter_sim" ]; then
    #     cd $CATKIN_WS/src
    #     git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/mzahana/drone_hunter_sim.git
    #     fi && \
    #     cd $CATKIN_WS/src/drone_hunter_sim && git checkout noetic && \
    #     cd scripts && ./setup.sh && \
    #     cd \${HOME} && source .bashrc && \
    #     /bin/bash"

    CMD="export DEV_DIR=/home/user/shared_volume &&\
        export PX4_DIR=\$DEV_DIR/PX4-Autopilot &&\
        if [ ! -d "/home/user/shared_volume/ros2_ws" ]; then
            mkdir -p /home/user/shared_volume/ros2_ws/src
        fi &&\
        if [ ! -d "/home/user/shared_volume/ros2_ws/src/d2dtracker_sim" ]; then
            cd /home/user/shared_volume/ros2_ws/src
            git clone https://github.com/mzahana/d2dtracker_sim.git
        fi &&\
        cd /home/user/shared_volume/ros2_ws/src/d2dtracker_sim &&\
        ./install.sh && cd \$HOME &&\
        source /home/user/shared_volume/ros2_ws/install/setup.bash &&\
        /bin/bash"

    if [[ -n "$GIT_TOKEN" ]] && [[ -n "$GIT_USER" ]]; then
    CMD="export GIT_USER=$GIT_USER && export GIT_TOKEN=$GIT_TOKEN && $CMD"
    fi

    if [[ -n "$SUDO_PASSWORD" ]]; then
        CMD="export SUDO_PASSWORD=$SUDO_PASSWORD && $CMD"
    fi

    echo "Running container ${CONTAINER_NAME}..."
    #-v /dev/video0:/dev/video0 \
    
    # --publish 14556:14556/udp \
    # --env="QT_X11_NO_MITSHM=1" \
        # --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        # --volume="$XAUTH:$XAUTH" \
        # -env="XAUTHORITY=$XAUTH" \
    docker run -it \
        --network host \
        --env="DISPLAY=${DISPLAY}" \
        -e NVIDIA_DRIVER_CAPABILITIES=all \
        -e LOCAL_USER_ID="$(id -u)" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix" \
        --volume="/etc/localtime:/etc/localtime:ro" \
        --volume="$WORKSPACE_DIR:/home/user/shared_volume:rw" \
        --volume="/dev:/dev" \
        --name=${CONTAINER_NAME} \
        --privileged \
        $DOCKER_OPTS \
        ${DOCKER_REPO} \
        bash -c "${CMD}"
fi

