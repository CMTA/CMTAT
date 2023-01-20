#/bin/bash
cd '../../contracts'
dir=$(pwd)
for i in $(find $dir -type f);
do
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya inheritance $i | dot -Tpng > surya_inheritance_$filename.png;
    fi
done;