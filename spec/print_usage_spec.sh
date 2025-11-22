#!/bin/sh

# Test the print_usage function

Include 'lib/functions.sh'

Describe 'print_usage function'
  It "should print usage information" 
    When call print_usage
    The output should include "Usage:"
    The output should include "./fuyujitaku.sh [OPTIONS]"
    The output should include "OPTIONS: -s SIZE"
  End
End
