# Fuyujitaku
Enabling hibernation of Ubuntu and its flavors. 

## Description
This script enables hibernation on Ubuntu and its flavors. 
It extends the swap file to the RAM's size times 2 and registers it as the resume area to the kernel parameter.

It also configure the suspend-then-hibernate delay. And finally, configure system to allow hibernation from the menu.

This script supports only systems with a swap file on ext4 file system. The system with swap partition is not supported.

> [!Caution]
> This script is tested with the actual machine. So, I believe that it works on most systems which users recent Ubuntu flavors. However, there is a possibility that it may not work on some systems. Please use this script at your own risk. It is recommended to back up your data before running the script. 


## Requirements
- Ubuntu 24.04(#1) or its flavors (e.g., Kubuntu, Ubuntu Mate, etc.)
- ext4 file system
- swap file (not swap partition)
- sudo privileges

---
- (#1) Ubuntu updated the the Polkit major version from Ubuntu 24.04. So, this script may not work on Ubuntu versions prior to 24.04.

## Test environment and results
### Version 1.x.x
The following table shows the test environment and results for version 1.x.x of this script.
| OS                | Platform                      | Note       |
|--                 |--                             |--          |
| Ubuntu 24.04.2    | VirtualBox 7.1.8              | (#1)(#2)       |
| Ubuntu Mate 25.04 | VirtualBox 7.1.8              | (#1)(#3)   |
| Kubuntu 25.04    | VirtualBox 7.1.8               | (#1)       |
| Kubuntu 25.04    | Fujitsu FMV Lifebook U939 (#4) | Works fine |

---
- (#1) Success to hibernate and resume, but after resuming, the system gets stuck during the shutdown process. The workaround is reboot-then-shutdown.
- (#2) To show "Hibernation" button in the menu, you need to install the [Hibernate Status Button](https://extensions.gnome.org/extension/755/hibernate-status-button/). 
- (#3) The mouse cursor is rendered incorrectly after resuming. The workaround is to reboot the system.
- (#4) Intel Core i5-8365U, 8GB RAM, 256GB SSD.

### Version 2.0
The following table shows the test environment and results for version 1.x.x of this script.
| OS                | Platform                       | Note       |
| ----------------- | ------------------------------ | ---------- |
| Kubuntu 25.10     | Fujitsu FMV Lifebook U939      | Works fine |


## How to use
1. Download the latest release from [here](https://github.com/suikan4github/fuyujitaku).
2. Extract the downloaded archive.
3. Open a terminal and navigate to the extracted folder.
4. Run the following command to modify your system:
`
./fuyujitaku.sh
`
5. Then reboot your system.

By default the swap size will be set to 2 times the RAM size. Also, the delay from entering sleep to entering hibernation is set to 900 seconds (15 minutes).

If you want to set a different swap size, you can specify it by `-s` option. 
For example, to set the swap size to 12GB , run the following command:
```bash
./fuyujitaku.sh -s 12G
```

You can also specify the swapsize by mega byte format. For example: `-s 512M`.

> [!NOTE]
> If the avairable disk space - specified swap size < 1GB, 
> Fuyujitaku terminates immediately. 

Also, you can specify a parameter to specify the time delay from the entering sleep to the entering hibernaiton. This parameter is set by `-d` optoin. 
To change it to 600[sec], run the following command : 

```bash
./fuyujitaku.sh -d 600s
```

You can also specify the delay by minutes format. For example: `-d 10m`

Finally, you can specify both parameter at once. 

```bash
./fuyujitaku.sh -s 12G -d 600s
```

## How to revert
The revert.sh script is provided to revert the changes made by fuyujitaku.sh script.

To revert the changes, run the following command:

```bash
. ./revert.sh
```

Note that the revert.sh script works only if the fuyujitaku.sh script was run without any errors. 

## Troubleshooting
If you encounter any issues while using this script, please check the following:
- Ensure that you have a swap file and not a swap partition. This script does not support systems with swap partitions.
- Ensure that you have enough disk space to extend the swap file. The script will attempt to double the size of the swap file, by default.
- Check the system logs for any error messages related to hibernation or swap file.

Generally, the script should work on Ubuntu and its flavors. However, if you encounter any issues, please feel free to open an issue on the [GitHub repository](https://github.com/suikan4github/fuyujitaku/wiki)

> [!IMPORTANT]
> Please note that this script is provided as-is and may not work on some systems. Use this script at your own risk. Each system is different. The script may not work as expected on your system by some reason. It is recommended to back up your data before running the script.

## Wiki
For more information, please refer to the [Wiki](https://github.com/suikan4github/fuyujitaku/wiki).

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author
This project is developed and maintained by [Seiichi Horie](https://github.com/suikan4github).