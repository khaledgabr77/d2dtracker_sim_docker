# D2DTracker Docker Image
A Docker development environment for the D2DTracker framework
What is included in the Docker image is
* Ubuntu 22.04 (jammy)
* ROS 2 Humble
* Gazebo Garden
* Development tools required by PX4 firmware + PX4-Autopilot source code
* D2DTracker simulation packages

# Build Docker Image
Docker should be installed before proceeding with the next steps
You can follow [this link](https://docs.docker.com/engine/install/ubuntu/) for docker setup on Ubuntu

* Clone this package `git clone https://github.com/mzahana/px4_ros2_humble`
* Build the docker image
    ```bash 
    cd d2dtracker_sim_docker/docker
    make px4-dev-simulation-ubuntu22
    ```

This builds a Docker image that has the required PX4 development environment, and ROS 2 Humble Desktop. It does not container the PX4 source code or any ROS 2 workspaces. This is covered in the following sections.

The Gazebo version in the provided Docker image is Gazebo Garden.

# Run
If you have NVIDIA GPU, run
```bash
./docker_run_nvidia.sh
```
Otherwise, run
```bash
./docker_run.sh
```

**NOTE**

* Source files and workspaces should be saved inside a shared volume. The path to the shared volume inside the container is `/home/user/shared_volume`. The path to the shared volume in the host is `$HOME/d2dtracker_shared_volume`.
* When you login inside the container, the username is `user` and the passwrod is `user`. `user` is part of the `sudo` group and can install pckages using `sudo apt install`

# Build docker image
* Clone this repo and execute
    ```bash
    ./docker_run_nvidia.sh
    ```
    This should build the docker image which has all the required software
* Once the above script is executed successfully, you should be in the docker container terminal. The docker defualt name is `d2dtracker`. The username inside the docker and its password is `user`

# PX4 Autopilot & ROS 2 Wrokspace
* You can find the `ros2_ws` and the `PX4-Autopilot` inside the shared volume. The path of shared volume inside the container is `/home/user/shared_volume`. The path of the shared volume outside the container is `$HOME/d2dtracker_shared_volume`

# Run simulation
* To run the simulation execute
    ```bash
    ros2 launch d2dtracker_sim run_sim.launch`
    ```
* You can re-enter the docker container by executing the `docker_run_nvidia.sh` in a new terminal.