#!/bin/bash
# Inputs: POSCAR (VASP) "Sn*_*.POSCAR" files in the folder.
# Output: COLVAR file

# Dependencies: "plumed", "ase" software installed.

declare -A CV
function Evaluation {
 if [ $(echo "${n_atoms} < 16" | bc -lq) == 1 ] ; then 
 echo "# vim:ft=plumed
UNITS LENGTH=A TIME=ps ENERGY=eV
Zr_atoms:  GROUP NDX_FILE=index.ndx NDX_GROUP=Zr
Sn_atoms:  GROUP NDX_FILE=index.ndx NDX_GROUP=Sn
all: GROUP NDX_FILE=index.ndx NDX_GROUP=System
#
cn_SnSn: COORDINATIONNUMBER SPECIES=Sn_atoms SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN
cn_SnZr: COORDINATIONNUMBER SPECIESA=Sn_atoms SPECIESB=Zr_atoms SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN
#
q6a: Q6 SPECIESA=Sn_atoms SPECIESB=all SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 }  MEAN
w6a: LOCAL_Q6 SPECIES=q6a SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN LOWMEM 
#
q6b: Q6 SPECIESA=Sn_atoms SPECIESB=Sn_atoms SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 }
w6b: LOCAL_Q6 SPECIES=q6b SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN LOWMEM 
#
q6a_2: Q6 SPECIESA=Sn_atoms SPECIESB=all SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } 
w6a_2: LOCAL_Q6 SPECIES=q6a SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } MEAN LOWMEM 
#
q6b_2: Q6 SPECIESA=Sn_atoms SPECIESB=Sn_atoms SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 }
w6b_2: LOCAL_Q6 SPECIES=q6b_2 SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } MEAN LOWMEM 
#
PRINT STRIDE=1 ARG=* FILE=COLVAR
PRINT STRIDE=1 ARG=cn_SnSn.mean,cn_SnZr.mean,w6a.mean,w6b.mean,w6a_2.mean,w6b_2.mean FILE=COLVAR_cvs
FLUSH STRIDE=1
#
DUMPMULTICOLVAR DATA=w6a   FILE=lQ6.xyz
DUMPMULTICOLVAR DATA=w6b   FILE=lQ6_SnSn.xyz
DUMPMULTICOLVAR DATA=w6a_2 FILE=lQ6_2nd.xyz
DUMPMULTICOLVAR DATA=w6b_2 FILE=lQ6_SnSn_2nd.xyz
ENDPLUMED" > plumed.dat
 else
 echo "# vim:ft=plumed
UNITS LENGTH=A TIME=ps ENERGY=eV
Zr_atoms:  GROUP NDX_FILE=index.ndx NDX_GROUP=Zr
Sn_atoms:  GROUP NDX_FILE=index.ndx NDX_GROUP=Sn
all: GROUP NDX_FILE=index.ndx NDX_GROUP=System
#
cn_SnSn:    COORDINATIONNUMBER SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN
cn_SnZr:    COORDINATIONNUMBER SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN
#
q6a: Q6 SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 }  MEAN
w6a: LOCAL_Q6 SPECIES=q6a SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN LOWMEM 
#
q6b: Q6 SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 }
w6b: LOCAL_Q6 SPECIES=q6b SWITCH={GAUSSIAN R_0=0.1 D_0=4.9 D_MAX=5.0 } MEAN LOWMEM 
#
q6a_2: Q6 SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } 
w6a_2: LOCAL_Q6 SPECIES=q6a SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } MEAN LOWMEM 
#
q6b_2: Q6 SPECIES=all SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 }
w6b_2: LOCAL_Q6 SPECIES=q6b_2 SWITCH={GAUSSIAN R_0=0.1 D_0=9.9 D_MAX=10.0 } MEAN LOWMEM 
#
PRINT STRIDE=1 ARG=* FILE=COLVAR
PRINT STRIDE=1 ARG=cn_SnSn.mean,cn_SnZr.mean,w6a.mean,w6b.mean,w6a_2.mean,w6b_2.mean FILE=COLVAR_cvs
FLUSH STRIDE=1
#
DUMPMULTICOLVAR DATA=w6a   FILE=lQ6.xyz
DUMPMULTICOLVAR DATA=w6b   FILE=lQ6_SnSn.xyz
DUMPMULTICOLVAR DATA=w6a_2 FILE=lQ6_2nd.xyz
DUMPMULTICOLVAR DATA=w6b_2 FILE=lQ6_SnSn_2nd.xyz
ENDPLUMED" > plumed.dat
 fi
 ase convert -i vasp -o proteindatabank ${file} ${name}.pdb
 echo "[ Zr ]" > index.ndx
 grep 'Zr ' ${name}.pdb | awk '{print $2}' | xargs -n1000 >> index.ndx
 echo "[ Sn ]" >> index.ndx
 grep 'Sn ' ${name}.pdb | awk '{print $2}' | xargs -n1000 >> index.ndx
 echo "[ System ]" >> index.ndx
 grep -e 'Zr ' -e 'Sn ' ${name}.pdb | awk '{print $2}' | xargs -n1000 >> index.ndx
 #
 plumed driver --plumed plumed.dat --mf_pdb ${name}.pdb
 #
 rm -rf index.ndx ${name}.pdb plumed.dat
}
# Copy temporally the POSCAR files locally in the folder:
cp structures/*.POSCAR .
if [ -f COLVAR ] ; then rm -rf COLVAR ; echo "#!" > COLVAR ; fi
for n_atoms in $(seq 1 1 16 ) ; do
 i=$(printf "%02d" ${n_atoms})
 for file in Sn${i}_*.POSCAR ; do
  name=$(echo $file | sed 's/\.POSCAR//g')
  d=dir_$name
  if [ ! -d $d ] ; then mkdir $d ; fi
  cd $d
   cp -rf ../$file .
   Evaluation $name
   # -------------------------------------------------------------------------------------------------
   # Global (g1,g2,g3,g4,g5,g6)
   # g1: cn_SnSn.mean : Averaged coordination number Sn-Sn [0:5] A
   # g2: cn_SnZr.mean : Averaged coordination number Sn-Zr [0:5] A
   # g3: w6a.mean     : Averaged local-averaged Steinhardt Q6 parameters (Sn,Sn) [0.1:5.0] A.
   # g4: w6b.mean     : Averaged local-averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1:5.0] A.
   # g5: w6a_2.mean   : Averaged local-averaged Steinhardt Q6 parameters (Sn,Sn) [0.1:10.0] A.
   # g6: w6b_2.mean   : Averaged local-averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1:10.0] A.
   # -------------------------------------------------------------------------------------------------
   for file in tmp tmp2 tmp3 tmp4 ; do if [ -f $file ] ; then rm -rf $file ; fi ; done
   cat COLVAR_cvs | sed '/#/d' | awk -v n=$name '{print n,$2,$3,$4,$5,$6,$7,$8,$9}' > tmp
   # Locals (l1,l2,l3,l4)
   # l1: local-averaged Steinhardt Q6 parameters (Sn,Sn) [0.1:5.0] A.
   # l2: local-averaged Steinhardt Q6 parameters (Sn,Sn) [0.1:10.0] A.
   # l3: local-averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1:5.0] A.
   # l4: local-averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1:10.0] A.
   if [ $(echo "$n_atoms > 0" | bc -lq) == 1 ] ; then
    for j in $(seq 1 1 $n_atoms) ; do
     # l1 (local averaged Steinhardt Q6 parameters (Sn,Sn) [0.1 : 5.0] A.
     echo $(grep 'X' lQ6_SnSn.xyz | awk '{print $5}' | xargs -n100 | awk -v atom=$j '{print $atom}') >> tmp2     # Q6 Sn,Sn, 1st shell
     # l2 (local averaged Steinhardt Q6 parameters (Sn,Sn) [0.1 : 10.0] A.
     echo $(grep 'X' lQ6_SnSn_2nd.xyz | awk '{print $5}' | xargs -n100 | awk -v atom=$j '{print $atom}') >> tmp2 # Q6 Sn,Sn  2nd shell 
     # l3 (local averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1 : 5.0] A.
     echo $(grep 'X' lQ6.xyz | awk '{print $5}' | xargs -n100 | awk -v atom=$j '{print $atom}') >> tmp2          # Q6 Sn,X   1st shell
     # l4 (local averaged Steinhardt Q6 parameters (Sn,Sn or Zr) [0.1 : 10.0] A.
     echo $(grep 'X' lQ6_2nd.xyz | awk '{print $5}' | xargs -n100 | awk -v atom=$j '{print $atom}') >> tmp2      # Q6 Sn,X   2nd shell 
     #echo "}," >> tmp2
    done
   fi
   cat tmp2 | xargs -n100 > tmp3
   paste tmp tmp3 >> ../COLVAR
   cat   tmp3 >> ../only_local_COLVAR
  cd ..
 done
done
rm -rf dir_*
# Modify COLVAR file:
cat COLVAR | sed 's/\t/ /g' | sed '/#/d' | tr -s ' ' > tmp
mv tmp COLVAR
rm *.POSCAR
exit 0
