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
- Ubuntu 24.04(#1) or newer.
  - The flavors (e.g., Kubuntu, Ubuntu Mate, etc.).
- ext4 file system.
- swap file (not swap partition).
- sudo privileges.
- Secure boot disabled in the BIOS/UEFI settings (#2).

---
- (#1) Ubuntu updated the the Polkit major version from Ubuntu 24.04. So, this script may not work on Ubuntu versions prior to 24.04.
- (#2) Linux kernel lockdown feature prevents the resume from hibernation during the secure boot. To use hibernation, you need to disable secure boot in the BIOS/UEFI settings. 

## Test environment and results

### Version 3.0.x
The following table shows the test environment and results for version 3.0.x of this script.
| OS                | Platform   | Note       |
| ----------------- | -----------| ---------- |
| Ubuntu 24.04      | Hyper-V    | Works fine|
| Ubuntu 26.04      | Hyper-V    | Need workaround (#1)|
| Kubuntu 26.04     | Hyper-V    | Works fine |
| Lubuntu 26.04     | Hyper-V    | Need Workaround (#1)|

---
- (#1) After executing the `fuyujitaku.sh` script, reboot the system and then, run `update-initramfs -u -k all` command. See [Workarounds for certain flavors of Ubuntu 26.04 LTS](#workarounds-for-certain-flavors-of-ubuntu-2604-lts) section for details.

### Version 2.0.x
The following table shows the test environment and results for version 2.0.x of this script.
| OS                | Platform                       | Note       |
| ----------------- | ------------------------------ | ---------- |
| Kubuntu 25.10     | Fujitsu FMV Lifebook U939      | Works fine |


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


## How to use
> [!Caution]
> For the certain flavors of Ubuntu 26.04 LTS, you need special workaround to avoid a problem. Read this section carefully before using the script.

1. Download the latest release from [here](https://github.com/suikan4github/fuyujitaku).
2. Extract the downloaded archive.
3. Open a terminal and navigate to the extracted folder.
4. Run the following command to modify your system:
`
./fuyujitaku.sh
`
5. Then reboot your system.

By default the swap size will be set to 2 times the RAM size. Also, the delay from entering sleep to entering hibernation is set to 1440 minutes (24 hours).

If you want to set a different swap size, you can specify it by `-s` option. 
For example, to set the swap size to 12GB , run the following command:
```bash
./fuyujitaku.sh -s 12G
```

You can also specify the swapsize by mega byte format. For example: `-s 512M`.

> [!NOTE]
> If the `avairable disk space after changing swap size` < 1GB, 
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

### Workarounds for certain flavors of Ubuntu 26.04 LTS
Certain flavors of Ubuntu 26.04 LTS (e.g., Ubuntu and Lubuntu) have a problem that prevent the execusion of `systemctl hibernate` command after running the `fuyujitaku.sh` script. 

Usually, the following command can configure the system hibernate possible. 

```sh
./fuyujitaku.sh
sudo reboot
```
But you may see the following error message when you run `systemctl hibernate` command after running the above commands, in some flavors of Ubuntu 26.04 LTS.

```
Call to Hibernate failed: Invalid resume config: resume= is not populated yet resume_offset= is
```
This is reported in the [issue #15](https://github.com/suikan4github/fuyujitaku/issues/15).

The workaround is to run the following command **after** rebooting the system. 

```bash
# Run these commands after rebooting the system.
sudo update-initramfs -u -k all
sudo reboot
```


## How to revert
The `revert.sh` script is provided to revert the changes made by `fuyujitaku.sh` script.

To revert the changes, run the following command:

```bash
./revert.sh
```

> [!Note]
> The revert.sh script works only if the fuyujitaku.sh script run without any errors. 

The `revert.sh` script will restore the original swap size and the original kernel parameters. It will also remove the backup files created by `fuyujitaku.sh` script.

## How to test
To run the auto tests, you need to install [shellspec](https://github.com/shellspec/shellspec).

> [!NOTE]
> In the case of using the devcontainer, shellspec is automatically added when the devcontainer is built, so you can run your tests in the container without installing shellspec on your local machine.

Then, run the following command in the root directory of this project:

```bash
shellspec
```
## Troubleshooting
If you encounter any issues while using this script, please check the following:
- Ensure that you have a swap file and not a swap partition. This script does not support systems with swap partitions.
- Ensure that you have enough disk space to extend the swap file. The script will attempt to double the size of the swap file, by default.
- Ensure that secure boot is disabled in the BIOS/UEFI settings. 
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