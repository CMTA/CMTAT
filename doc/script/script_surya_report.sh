#/bin/bash
cd '../../contracts'
dir=$(pwd)
for i in $(find $dir -type f);
do
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya mdreport surya_report_$filename.md $i;
    fi
done;