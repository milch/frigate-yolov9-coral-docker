FROM ghcr.io/blakeblackshear/frigate:0.16.2

# Set working directory for plugin installation
WORKDIR /tmp

# Download the YOLOv9 EdgeTPU detector plugin from main branch
RUN wget -O /opt/frigate/frigate/detectors/plugins/edgetpu_tfl.py \
    https://raw.githubusercontent.com/dbro/frigate-detector-edgetpu-yolo9/main/edgetpu_tfl.py

# Download all 3 model variants from release 1.5
RUN wget -P /opt/frigate/models/ \
    https://github.com/dbro/frigate-detector-edgetpu-yolo9/releases/download/v1.5/yolov9-s-relu6-tpumax_320_int8_edgetpu.tflite && \
    wget -P /opt/frigate/models/ \
    https://github.com/dbro/frigate-detector-edgetpu-yolo9/releases/download/v1.5/yolov9-s-relu6-tpumax_512_int8_edgetpu.tflite && \
    wget -P /opt/frigate/models/ \
    https://github.com/dbro/frigate-detector-edgetpu-yolo9/releases/download/v1.5/yolov9-s-hardswish-tpumax_320_int8_edgetpu.tflite

# Download the COCO labels file
RUN wget -O /opt/frigate/models/labels-coco17.txt \
    https://raw.githubusercontent.com/dbro/frigate-detector-edgetpu-yolo9/main/labels-coco17.txt

# Reset working directory
WORKDIR /opt/frigate

# Labels for the image
LABEL org.opencontainers.image.title="Frigate with YOLOv9 EdgeTPU Detector"
LABEL org.opencontainers.image.description="Frigate NVR with YOLOv9 EdgeTPU detector plugin and all model variants"
LABEL org.opencontainers.image.source="https://github.com/milch/frigate-yolov9-coral-docker"
LABEL org.opencontainers.image.version="0.16.2-yolov9-1.5"
