#!/bin/sh

Include 'lib/functions.sh'

Describe 'get_original_grub_file_name function'

  It 'should the output the name of the file which contains the original grub to stdout.'
    When call get_original_grub_file_name
    The output should equal "original_grub_config"
  End
End
