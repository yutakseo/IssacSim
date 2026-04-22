FROM ros:jazzy-ros-base

WORKDIR /ros2_ws

ENV DEBIAN_FRONTEND=noninteractive
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ENV ROS_DOMAIN_ID=0
ENV ROS_LOCALHOST_ONLY=0

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    iputils-ping \
    net-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true
RUN rosdep update

CMD ["bash"]