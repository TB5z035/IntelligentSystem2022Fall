docker run --rm -it --network host -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -e NO_AT_BRIDGE=1 -v /tmp/.X11-unix:/tmp/.X11-unix $1 $2