 #!/bin/bash
#run docker
docker run --gpus device=1 -v /home/grover/Desktop/LiquidFoodDLC-Mehmet-2020-03-23/:/mnt/dlcdata -it --rm dlc /bin/bash

#mount the drive
sudo mount -t nfs 10.17.6.43:/volume1/Lab_Files /mnt/wunas


docker run --gpus device=0 -it tensorflow/tensorflow:latest-gpu bash

docker run --gpus device=1 -v /home/grover/Desktop/dockerdir/LiquidFoodDLC-Mehmet-2020-03-23/:/mnt/dlcdata -it --rm dlctf2 /bin/bash