#/bin/bash
cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/out/inheritance
if ! [ -d "$DIR_OUT" ]; then
    mkdir -p ./out/surya_inheritance
fi
cd './contracts'
DIR=$(pwd)
for i in $(find $dir -type f);
do
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya inheritance $i | dot -Tpng > ../out/surya_inheritance/surya_inheritance_$filename.png;
    fi
done;