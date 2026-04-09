#!/bin/sh

Include 'lib/functions.sh'

Describe 'get_original_swap_size_file_name function'

  It 'should the output the name of the file which contains the original swap file size to stdout.'
    When call get_original_swap_size_file_name
    The output should equal "original_swap_size"
  End
End