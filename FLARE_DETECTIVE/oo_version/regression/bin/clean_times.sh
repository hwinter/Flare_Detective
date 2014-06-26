#!/bin/ksh

# run this script on new xml files to clean out any time data that may exist

CleanTimes()
{
   \sed  -e "s/_[0-9]*_[0-9]*_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]/_X_X-XXXX-XX-XXTXX:XX/" \
         -e "s/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9]*.[0-9]*/XXXX-XX-XXTXX:XX:XX.XXX/" $1 > $1.cleaned
   mv  $1.cleaned $1
}

files=`ls`
for file in ${files[*]}; do
   CleanTimes $file
done
