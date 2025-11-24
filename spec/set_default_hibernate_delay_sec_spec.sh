#!/bin/sh

Include 'lib/functions.sh'

Describe 'set_default_hibernate_delay_sec function'

  Before 'free()
  {
      echo "Mem:            1234        6157         340        1073        3078        1789"
      return 0
  }'

  It "should set HIBERNATE_DELAY_SEC=15m"
    When call set_default_hibernate_delay_sec
    The variable HIBERNATE_DELAY_SEC should equal '15m'
  End

End