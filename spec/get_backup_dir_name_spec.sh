#!/bin/sh

Include 'lib/functions.sh'

Describe 'get_backup_dir_name function'

  It 'should the output the name of the backup directory to stdout.'
    When call get_backup_dir_name
    The output should equal "backup"
  End
End