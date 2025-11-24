#!/bin/sh

Include 'lib/functions.sh'

Describe 'print_parametsave_original_swap_sizeers function'
  # Mock of write_stream() function 
  write_stream() {
    STREAM="$1"        
    FILENAME="$2"
      return 0; 
  }

  # Mock of free command
  free() {
    echo "              total        used        free      shared  buff/cache   available"
    echo "Mem:          15926        2345       11234         123        2345       13245"
    echo "Swap:         15892           0       15892"
  }

  It 'should give the original swap size and backup file name to stdn in and parameter, respectively'
    When call save_original_swap_size
    The variable FILENAME should equal "backup/original_swap_size"
    The variable STREAM should equal "15892"
  End
End