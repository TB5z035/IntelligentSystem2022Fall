docker build . --network host -f Dockerfiles/Dockerfile.habitat-sim-cpu -t habitat-sim-cpu
docker build . --network host -f Dockerfiles/Dockerfile.habitat-lab-cpu -t habitat-lab-cpu
docker build . --network host -f Dockerfiles/Dockerfile.ros-cpu -t dev-ros-cpu
docker build . --network host -f Dockerfiles/Dockerfile.ros_x_habitat-cpu -t sim-headless-cpu