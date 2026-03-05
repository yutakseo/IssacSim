FROM nvcr.io/nvidia/isaac-sim:5.1.0
WORKDIR /isaac-sim
COPY entrypoint.sh /isaac-sim/entrypoint.sh
COPY run_isaac.sh /isaac-sim/run_isaac_custom.sh
ENTRYPOINT ["bash", "/isaac-sim/entrypoint.sh"]
