#!/bin/sh

Include 'lib/functions.sh'

Describe 'parse_arguments function'
  Context 'When -d passed with parameter 123s'
    It "should set HIBERNATE_DELAY_SEC to 123s and return 0" 
      When call parse_arguments -d 123s
      The variable HIBERNATE_DELAY_SEC should equal '123s'
      The status should be success
    End
  End

  Context 'When -s passed with parameter 321M'
    It "should set TARGET_SWAP_SIZE to 321M and return 0" 
      When call parse_arguments -s 321M
      The variable TARGET_SWAP_SIZE should equal '321M'
      The status should be success
    End
  End

  Context 'When -h passed'
    It "should output help text and return 1" 
      When call parse_arguments -h
      The output should include "./fuyujitaku.sh [OPTIONS]"
      The status should be failure
    End
  End

  Context 'When -help passed'
    It "should output help text and return 1" 
      When call parse_arguments -help
      The output should include "./fuyujitaku.sh [OPTIONS]"
      The status should be failure
    End
  End

  Context 'When unkown option passed'
    It "should output help text and return 1" 
      When call parse_arguments -H
      The output should include "./fuyujitaku.sh [OPTIONS]"
      The status should be failure
    End
  End

  Context 'When option -s 2G -d 6m passed'
    It "should set TARGET_SWAP_SIZE, est HIBERNATE_DELAY_SEC and return 0" 
      When call parse_arguments -s 2G -d 6m
      The variable TARGET_SWAP_SIZE should equal 2G
      The variable HIBERNATE_DELAY_SEC should equal 6m
      The status should be success
    End
  End

  Context 'When option -d 6m -s 2G passed'
    It "should set TARGET_SWAP_SIZE, est HIBERNATE_DELAY_SEC and return 0" 
      When call parse_arguments -d 6m -s 2G
      The variable TARGET_SWAP_SIZE should equal 2G
      The variable HIBERNATE_DELAY_SEC should equal 6m
      The status should be success
    End
  End
End