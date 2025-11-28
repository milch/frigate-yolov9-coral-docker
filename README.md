# Frigate with YOLOv9 EdgeTPU Detector

This Docker image extends [Frigate NVR](https://frigate.video/) (version 0.16.2) with the [YOLOv9 EdgeTPU detector plugin](https://github.com/dbro/frigate-detector-edgetpu-yolo9) for improved object detection using Coral EdgeTPU devices.

## What's Included

- **Base Image**: `ghcr.io/blakeblackshear/frigate:0.16.2`
- **Plugin**: YOLOv9 EdgeTPU detector plugin (v1.5)
- **Models**: All 3 model variants from release 1.5:
  - `yolov9-s-relu6-tpumax_320_int8_edgetpu.tflite` (320x320, 10ms inference, mAP 50% of 40.6%)
  - `yolov9-s-relu6-tpumax_512_int8_edgetpu.tflite` (512x512, 21ms inference, mAP 50% of 44.3%)
  - `yolov9-s-hardswish-tpumax_320_int8_edgetpu.tflite` (320x320, higher accuracy - 75 mAP vs 72 mAP)
- **Labels**: COCO dataset labels (labels-coco17.txt)

## Usage

### Docker Compose

```yaml
version: "3.9"
services:
  frigate:
    image: ghcr.io/milch/frigate-yolov9-coral-docker:latest
    container_name: frigate
    restart: unless-stopped
    privileged: true
    devices:
      - /dev/bus/usb:/dev/bus/usb  # For Coral USB
      - /dev/apex_0:/dev/apex_0    # For PCIe/M.2 Coral
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./config:/config
      - ./storage:/media/frigate
      - type: tmpfs
        target: /tmp/cache
        tmpfs:
          size: 1000000000
    ports:
      - "5000:5000"
      - "8554:8554"  # RTSP feeds
      - "8555:8555/tcp"  # WebRTC over tcp
      - "8555:8555/udp"  # WebRTC over udp
    environment:
      FRIGATE_RTSP_PASSWORD: "password"
```

### Frigate Configuration

Update your `config.yml` to use the YOLOv9 detector:

```yaml
detectors:
  coral:
    type: edgetpu
    device: usb  # or 'pci' for PCIe/M.2
    model:
      path: /opt/frigate/models/yolov9-s-relu6-tpumax_320_int8_edgetpu.tflite
      # Alternative models:
      # path: /opt/frigate/models/yolov9-s-relu6-tpumax_512_int8_edgetpu.tflite
      # path: /opt/frigate/models/yolov9-s-hardswish-tpumax_320_int8_edgetpu.tflite
      width: 320  # Use 512 if using the 512x512 model
      height: 320  # Use 512 if using the 512x512 model
      type: yolo-generic
      labelmap_path: /opt/frigate/models/labels-coco17.txt

model:
  width: 320  # Use 512 if using the 512x512 model
  height: 320  # Use 512 if using the 512x512 model

cameras:
  # Your camera configuration here
```

## Model Selection Guide

- **yolov9-s-relu6-tpumax_320_int8_edgetpu.tflite**: Recommended for most use cases. Fast inference (10ms) with good accuracy.
- **yolov9-s-relu6-tpumax_512_int8_edgetpu.tflite**: Better for detecting smaller or distant objects. Slower inference (21ms) but higher mAP.
- **yolov9-s-hardswish-tpumax_320_int8_edgetpu.tflite**: Higher accuracy (75 mAP vs 72 mAP) compared to the relu6 320x320 model.

## Building Locally

```bash
docker build -t frigate-yolov9-coral:local .
```

## GitHub Actions

This repository includes a GitHub Actions workflow that automatically builds and pushes the Docker image to GitHub Container Registry (GHCR) on:
- Pushes to the `main` branch (tagged as `latest`)
- Version tags (e.g., `v1.0.0`)
- Manual workflow dispatch

The image will be available at: `ghcr.io/milch/frigate-yolov9-coral-docker:latest`

## Credits

- [Frigate NVR](https://github.com/blakeblackshear/frigate) by Blake Blackshear
- [YOLOv9 EdgeTPU Detector Plugin](https://github.com/dbro/frigate-detector-edgetpu-yolo9) by David Brown

## License

This project follows the same license as the upstream projects it depends on.
