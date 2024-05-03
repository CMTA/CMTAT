#/bin/bash
cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/docOut/surya_report
if ! [ -d "$DIR_OUT" ]; then
    mkdir ./docOut/surya_report
fi
cd './contracts'
DIR=$(pwd)
for i in $(find $dir -type f);
do
    filename=${i##*/}
    ext=${i##*.}
    if [[ $ext == 'sol' ]]; then
        npx surya mdreport ../docOut/surya_report/surya_report_$filename.md $i;
    fi
done;