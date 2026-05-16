#!/bin/sh

Include 'lib/functions.sh'

Describe 'save_original_config function'


  # Mock of sudo command
  sudo() {
      # Simulate sudo by calling the command directly.
      "$@"
  }

  # Mock of write_stream() function 
  write_stream() {
    # shellcheck disable=SC2034
    STREAM="$1"        
    # shellcheck disable=SC2034
    FILENAME="$2"
      return 0; 
  }

  # Mock of free command
  free() {
    echo "              total        used        free      shared  buff/cache   available"
    echo "Mem:          15926        2345       11234         123        2345       13245"
    echo "Swap:         15892           0       15892"
  }

  # Mock of copy_grub() function
  copy_grub() {
        # shellcheck disable=SC2034
        COPY_GRUB_DESTINATION_FILENAME="$1";
    return 0
  }


  It 'should give the original swap size and backup file name to stdn in and parameter, respectively, if backup directory does not exist'
    # Mock of backup_dir_exists() function to simulate the case when the backup directory does not exist.
    # shellcheck disable=SC2329
    backup_dir_exists() {
      return 1
    }

    When call save_original_config
    The variable FILENAME should equal "backup/original_swap_size"
    The variable STREAM should equal "15892"
    The variable COPY_GRUB_DESTINATION_FILENAME should equal "backup/original_grub_config"
  End

  It 'should not give anything if backup directory already exists'
     # Mock of backup_dir_exists() function to simulate the case when the backup directory already exists.
    backup_dir_exists() {
      return 0
    }

    When call save_original_config
    The variable FILENAME should be undefined
    The variable COPY_GRUB_DESTINATION_FILENAME should be undefined
  End


End