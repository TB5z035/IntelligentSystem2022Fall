# Needs torch-1.12.0+cu116-cp37-cp37m-linux_x86_64.whl
docker build . -t dev-cuda-runtime -f Dockerfile.cuda-runtime --network host
docker build . -t dev-cuda-toolkit -f Dockerfile.cuda-toolkit --network host