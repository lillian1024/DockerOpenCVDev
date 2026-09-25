# OpenCV Builder & Docker Toolset

A minimal, flexible toolset designed to simplify building custom builds of [OpenCV](https://opencv.org/) with precise dependency management. It provides both a standalone bash configuration script and a Dockerfile to generate lightweight or full-featured OpenCV Docker images with modular support for video processing frameworks and GPU acceleration.

Official pre-built images are published on Docker Hub at [**lilian1024/opencv**](https://hub.docker.com/r/lilian1024/opencv).

---

## Key Features

- **Modular Module Selection:** Easily enable or disable dependencies such as **FFmpeg**, **GStreamer**, **CUDA**, and **cuDNN**.
- **Automated CMake Verification:** The configuration script parses and verifies OpenCV's CMake output to guarantee that every requested module was successfully detected and included in the build flags.
- **Dual Usage:** Run the configuration script directly on your host system or build containerized environments using the provided `Dockerfile`.
- **Pre-built Images:** Ready-to-use Docker images maintained on Docker Hub.

---

## Project Structure

This project is kept lightweight and minimal:

```text
.
├── Dockerfile          # Multi-stage Docker build file
├── config_opencv.sh    # Main configuration and build script
├── Makefile            # Example of Dockerfile usage
├── LICENSE             # Project license
└── README.md           # Documentation
```

---

## Supported Build Modules

| Module | CMake Flag / Variable | Description |
| :--- | :--- | :--- |
| **FFmpeg** | `WITH_FFMPEG` | Video decoding/encoding backend |
| **GStreamer** | `WITH_GSTREAMER` | Pipeline-based multimedia framework |
| **CUDA** | `WITH_CUDA` | NVIDIA GPU acceleration |
| **cuDNN** | `WITH_CUDNN` | NVIDIA Deep Neural Network library for CUDA |

---

## Getting Started

### 1. Using Official Docker Images

You can pull ready-to-use images directly from Docker Hub:

```bash
docker pull lilian1024/opencv:4.x
```

### 2. Building Custom Images with Docker

You can pass build arguments to customize the OpenCV version and enabled modules:

```bash
# Build OpenCV with CUDA and FFmpeg support
docker build \
  --build-arg OPENCV_VERSION=4.10.0 \
  --build-arg USE_FFMPEG=on \
  --build-arg USE_CUDA=on \
  --build-arg USE_CUDNN=on \
  -t my-custom-opencv .
```

### 3. Standalone Script Usage

If you prefer building OpenCV natively on your Linux host without Docker, you can configure the OpenCV CMake project using the script:

```bash
# Make the script executable
chmod +x config_opencv.sh

# Run the script with desired options
./config_opencv.sh \
  --opencv_version=4.x \
  --ffmpeg=on \
  --gstreamer=on \
  --cuda=on \
  --cudnn=on
```

The script will:
1. Run CMake with the corresponding build flags.
2. **Verify** that CMake output explicitly reflects the inclusion of enabled modules.

---

## Guidelines for Adding Modules & Contributing

Contributions are very welcome! Whether you want to add support for additional modules (e.g., OpenCL, VTK, Python bindings), optimize the Docker build layers, or report issues, feel free to open an issue or submit a pull request.

### Adding a New Module

When contributing a new module to `build_opencv.sh`, please maintain the existing project standard:

1. **Add CLI/Build Arguments:** Expose explicit parameters for both `Dockerfile` (`ARG USE_MODULE`) and `build_opencv.sh`.
2. **Define CMake Flags:** Append the required `-D WITH_<MODULE>=ON/OFF` flags to the CMake invocation.
3. **Include Sanity Check Verification:** Add a check after the CMake configuration step to parse the CMake summary and confirm the module status is enabled.

---

## License

This project is open-source. For details regarding licensing terms, please refer to the [LICENSE](LICENSE) file in the root directory.
