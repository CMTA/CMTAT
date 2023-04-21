#/bin/bash
cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/out/surya_graph
if ! [ -d "$DIR_OUT" ]; then
    mkdir -p ./out/surya_graph
fi
cd './contracts'
DIR=$(pwd)
for i in $(find $DIR -type f);
do
    #echo $i
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya graph $i | dot -Tpng > ../out/surya_graph/surya_graph_$filename.png;
    fi
done;