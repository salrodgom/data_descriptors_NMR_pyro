#!/bin/bash -x
# temporally
if [ -f tmp1 ] ; then rm -rf tmp1 ; fi
if [ -f tmp2 ] ; then rm -rf tmp2 ; fi
if [ -f tmp3 ] ; then rm -rf tmp3 ; fi
# COLVARS
#n01_01 0.000000 6.000000 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
#n02_01 0.000000 6.000000 0.000000 0.000000 0.468565 0.193416 0.000000 0.193416 0.000000 0.468565 0.000000 0.193416 0.000000 0.468565
#n02_02 0.000000 6.000000 0.000000 0.000000 1.000000 1.000000 0.000000 1.000000 0.000000 1.000000 0.000000 1.000000 0.000000 1.000000
#n02_03 1.000000 5.000000 0.468565 1.000000 0.468565 1.000000 1.000000 1.000000 0.468565 0.468565 1.000000 1.000000 0.468565 0.468565
#
paste NAMES COLVAR | sed 's/\t/ /g' > tmp3
cat tmp3 | while read line ; do
 n1=$(echo $line | awk '{print $1}')
 n2=$(echo $line | awk '{print $2}')
 #
 globals=$(echo $line | awk '{for(i=4;i<=9;++i)print $i}')
 locals=$(echo $line | awk '{for(i=10;i<=NF;++i)print $i}')
 #
 if [[ $(echo "$n1 < 2" | bc -lq) == 1 ]] ; then
  echo $n1 $n2 $globals $locals >> tmp1
 else
  echo $locals | xargs -n4 | while read subline ; do
   echo $n1 $n2 $globals $subline >> tmp1
  done
 fi
done
# PEAKS:
cat PEAKS | while read line ; do
 echo $line | xargs -n1
done >> tmp2
# NAME:
paste tmp1 tmp2 | sed 's/\t/ /g' | tr -s ' ' > COLVAR.csv
exit 0
