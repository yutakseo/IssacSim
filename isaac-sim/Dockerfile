FROM nvcr.io/nvidia/isaac-sim:5.1.0
WORKDIR /isaac-sim
COPY --chmod=755 entrypoint.sh /isaac-sim/entrypoint.sh
COPY --chmod=755 run_isaac.sh /isaac-sim/run_isaac_custom.sh
ENTRYPOINT ["bash", "/isaac-sim/entrypoint.sh"]
