#! /bin/sh

# Get the swap file name.
SWAPFILE=$(swapon --show=NAME --noheadings)


sudo swapoff $SWAPFILE
sudo fallocate -l 16G $SWAPFILE
sudo mkswap $SWAPFILE
sudo swapon $SWAPFILE

# Get the UUID of the root filesystem (where the swap file stays).
UUID=$(findmnt / -o UUID --noheadings)

# Get the offset of the swap file.
OFFSET=$(sudo filefrag -v /swapfile | awk '/ 0:/{print substr($4, 1, length($4)-2)}')

# Construct the resume option for kernel parameters.
OPTION="resume=UUID=${UUID} resume_offset=${OFFSET}"
