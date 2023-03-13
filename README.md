# D2DTracker Docker Image
A Docker development environment for the D2DTracker framework
What is included in the Docker image is
* Ubuntu 22.04 (jammy)
* ROS 2 Humble
* Gazebo Garden
* Development tools required by PX4 firmware + PX4-Autopilot source code
* ROS 2 packages including D2DTracker simulation packags

# Build Docker Image
Docker should be installed before proceeding with the next steps
You can follow [this link](https://docs.docker.com/engine/install/ubuntu/) for docker setup on Ubuntu

* Clone this package `git clone https://github.com/mzahana/d2dtracker_sim_docker`
* Build the docker image
    ```bash 
    cd d2dtracker_sim_docker/docker
    make px4-dev-simulation-ubuntu22
    ```

This builds a Docker image that has the required PX4-Autopilot source code and the required dependencies, ROS 2 Humble Desktop, and `ros2_ws` that contains `d2dtracker_sim` and other ROS 2 packages.

The Gazebo version in the provided Docker image is Gazebo `garden`.

# Run Docker Container
* Run the following script to run and enter the docker container `d2dtracker` 
    ```bash
    cd d2dtracker_sim_docker
    ./docker_run_nvidia.sh
    ```
    This will run a docker container named `d2dtracker` and installs `PX4-Autopilot`, and create `ros2_ws` with the required ROS 2 packages, in the shared volume.
* Once the above script is executed successfully, you should be in the docker container terminal. The docker defualt name is `d2dtracker`. The username inside the docker and its password is `user`

# PX4 Autopilot & ROS 2 Wrokspace
* You can find the `ros2_ws` and the `PX4-Autopilot` inside the shared volume. The path of shared volume inside the container is `/home/user/shared_volume`. The path of the shared volume outside the container is `$HOME/d2dtracker_shared_volume`

# Run Simulation
* To run the simulation execute
    ```bash
    ros2 launch d2dtracker_sim run_sim.launch`
    ```
* You can re-enter the docker container by executing the `docker_run_nvidia.sh` in a new terminal.