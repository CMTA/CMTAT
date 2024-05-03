#/bin/bash
cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/docOut/inheritance
if ! [ -d "$DIR_OUT" ]; then
    mkdir -p ./docOut/surya_inheritance
fi
cd './contracts'
DIR=$(pwd)
for i in $(find $dir -type f);
do
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya inheritance $i | dot -Tpng > ../docOut/surya_inheritance/surya_inheritance_$filename.png;
    fi
done;