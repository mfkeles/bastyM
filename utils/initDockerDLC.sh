 #!/bin/bash

docker run --gpus device=1 -v /home/grover/Desktop/LiquidFoodDLC-Mehmet-2020-03-23/:/mnt/dlcdata -it --rm dlc /bin/bash