#!/bin/sh

Include 'lib/functions.sh'

Describe 'set_default_target_swap_size function'

  Before 'free()
  {
      echo "Mem:            1234        6157         340        1073        3078        1789"
      return 0
  }'

  It "should set TARGET_SWAP_SIZE=2468M"
    When call set_default_target_swap_size
    The variable TARGET_SWAP_SIZE should equal '2468M'
  End

End