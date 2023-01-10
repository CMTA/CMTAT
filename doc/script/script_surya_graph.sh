#/bin/bash
cd '../../contracts'
dir=$(pwd)
for i in $(find $dir -type f);
do
    #echo $i
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya graph $i | dot -Tpng > surya_graph_$filename.png;
    fi
done;