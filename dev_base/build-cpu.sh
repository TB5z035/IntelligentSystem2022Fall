# Needs torch-1.12.0+cpu-cp37-cp37m-linux_x86_64.whl
docker build . -t dev-cpu-runtime -f Dockerfile.cpu-runtime --network host