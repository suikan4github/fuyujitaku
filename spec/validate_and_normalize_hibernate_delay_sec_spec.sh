#!/bin/sh

Include 'lib/functions.sh'

Describe 'validate_and_normalize_hibernate_delay_sec function'
  Context 'When HIBERNATE_DELAY_SEC is 32s'
    Before 'HIBERNATE_DELAY_SEC=32s'

    It "should set HIBERNATE_DELAY_SEC to 32 and return 0" 
      When call validate_and_normalize_hibernate_delay_sec
      The variable HIBERNATE_DELAY_SEC should equal '32'
      The status should be success
    End
  End

  Context 'When HIBERNATE_DELAY_SEC is 5m'
    Before 'HIBERNATE_DELAY_SEC=5m'

    It "should set HIBERNATE_DELAY_SEC to 300 and return 0" 
      When call validate_and_normalize_hibernate_delay_sec
      The variable HIBERNATE_DELAY_SEC should equal '300'
      The status should be success
    End
  End

  Context 'When HIBERNATE_DELAY_SEC is 52sec'
    Before 'HIBERNATE_DELAY_SEC=52sec'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_hibernate_delay_sec
      The output should include "!!!!! HIBERNATE_DELAY_SEC format is invalid."

      The status should be failure
    End
  End

  Context 'When HIBERNATE_DELAY_SEC is 18s2'
    Before 'HIBERNATE_DELAY_SEC=18s2'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_hibernate_delay_sec
      The output should include "!!!!! HIBERNATE_DELAY_SEC format is invalid."

      The status should be failure
    End
  End

  Context 'When HIBERNATE_DELAY_SEC is 64'
    Before 'HIBERNATE_DELAY_SEC=64'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_hibernate_delay_sec
      The output should include "!!!!! HIBERNATE_DELAY_SEC format is invalid."

      The status should be failure
    End
  End

  Context 'When HIBERNATE_DELAY_SEC is s'
    Before 'HIBERNATE_DELAY_SEC=s'

    It "should should print error message and  return 1" 
      When call validate_and_normalize_hibernate_delay_sec
      The output should include "!!!!! HIBERNATE_DELAY_SEC format is invalid."

      The status should be failure
    End
  End


End