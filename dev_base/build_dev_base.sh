# Needs torch-1.12.0+cu116-cp37-cp37m-linux_x86_64.whl
docker build . -t dev-sim -f Dockerfile.sim --network host