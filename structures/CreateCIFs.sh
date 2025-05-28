#!/bin/bahs
function Evaluation {
 ase convert -i vasp -o cif ${file} ${name}.cif
}

for n_atoms in $(seq 1 1 16 ) ; do
 i=$(printf "%02d" ${n_atoms})
 for file in Sn${i}_*.POSCAR ; do
  name=$(echo $file | sed 's/\.POSCAR//g')
  d=dir_$name
  if [ ! -d $d ] ; then mkdir $d ; fi
  cd $d
   cp -rf ../$file .
   Evaluation $name
  cd ..
 done
done
exit 0
