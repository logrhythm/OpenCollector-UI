#!/bin/bash -e

#######################################
# Sign_OCHelper_sh.sh
#
# Goal: Sign the OCHelper.sh script
#######################################

return_code=0
calculated_signature="" # Signature calculated from the script file
signature_line="" # the last line of the script
output_result="Failed to test"

# Check the Signature line is there
signature_line=$(tail -1 OCHelper.sh | grep --only-matching '^#### DO NOT MODIFY THIS LINE - MD5SIGNATURE - 4c6f6752687974686d2d4f4348656c706572 - md5:[a-z0-9]*:5dm' 2>/dev/null) || return_code=$?
if [ $return_code -eq 0 ]; then
  echo -e "Signature line found"
  # Now calculate the signature from the file itself (minus the last line)
  calculated_signature=$(head --lines=-1 OCHelper.sh | md5sum | grep --only-matching '^[a-z0-9]*' 2>/dev/null) || return_code=$?
  if [ $return_code -eq 0 ]; then
    # All good, let's carry on
    echo -e "New signature: $calculated_signature"
    head --lines=-1 OCHelper.sh > OCHelper.sh_tmp
    echo -ne "#### DO NOT MODIFY THIS LINE - MD5SIGNATURE - 4c6f6752687974686d2d4f4348656c706572 - md5:$calculated_signature:5dm" >> OCHelper.sh_tmp
    cat OCHelper.sh > OCHelper.sh.old
    cat OCHelper.sh_tmp > OCHelper.sh
    rm OCHelper.sh_tmp
    exit 0
  fi
fi

echo -e "Failed to sign OCHelper.sh."
exit 1
