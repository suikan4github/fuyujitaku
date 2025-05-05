# Fuyujitaku
Enabling hibernation of Ubuntu and its flavors. 

## Description
This script enables hibernation on Ubuntu and its flavors. 
It extends the swap file to the RAM's size times 2 and registers it as the resume area to the kernel parameter.

It also configure the suspend-then-hibernate delay. And finally, configure system to allow hibernation from the menu.

This script supports only systems with a swap file. The system with swap partition is not supported.

## Test environment and results
| OS                | Platform                      | Note       |
|--                 |--                             |--          |
| Ubuntu 24.04.2    | VirtualBox 7.1.8              | (#1)(#2)       |
| Ubuntu Mate 25.04 | VirtualBox 7.1.8              | (#1)(#3)   |
| Kubuntu 25.04    | VirtualBox 7.1.8               | (#1)       |
| Kubuntu 25.04    | Fujitsu FMV Lifebook U939 (#4) | Works fine |

- (#1) Success to hibernate and resume, but after resuming, the system gets stuck during the shutdown process. The workaround is reboot-then-shutdown.
- (#2) "Hibernation" is not shown in the menu. 
- (#3) The mouse cursor is rendered incorrectly after resuming. The workaround is to reboot the system.
- (#4) Intel Core i5-8365U, 8GB RAM, 256GB SSD.


## How to use
1. Download the latest release from [here](https://github.com/suikan4github/fuyujitaku).
2. Extract the downloaded archive.
3. Open a terminal and navigate to the extracted folder.
4. Run the following command to install the package:
```bash
. ./fuyujitaku.sh
```
5. Then reboot your system.

By default the swap size will be set to 2 times the RAM size. If you want to set a different swap size, you can specify it as an environment variable TARGET_SWAP_SIZE before running the script. For example, to set the swap size to 12GB , run the following command:
```bash
TARGET_SWAP_SIZE=12G . ./fuyujitaku.sh
```

## How to revert
The revert.sh script is provided to revert the changes made by fuyujitaku.sh script.

To revert the changes, run the following command:

```bash
. ./revert.sh
```

Note that the revert.sh script works only if the fuyujitaku.sh script was run without any errors. If you have modified the system manually, the revert.sh script may not work as expected.

## Troubleshooting
If you encounter any issues while using this script, please check the following:
- Ensure that you have a swap file and not a swap partition. This script does not support systems with swap partitions.
- Ensure that you have enough disk space to extend the swap file. The script will attempt to double the size of the swap file.
- Check the system logs for any error messages related to hibernation or swap file.

Generally, the script should work on Ubuntu and its flavors. However, if you encounter any issues, please feel free to open an issue on the [GitHub repository](https://github.com/suikan4github/fuyujitaku/wiki)

> [!IMPORTANT]
> Please note that this script is provided as-is and may not work on all systems. Use it at your own risk. Each system is different, and the script may not work as expected on your system. It is recommended to back up your data before running the script.

## Wiki
For more information, please refer to the [Wiki](https://github.com/suikan4github/fuyujitaku/wiki).

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author
This project is developed and maintained by [Seiichi Horie](https://github.com/suikan4github).