#!/bin/bash
EXT=.min
# set MKOUT to generate .out files, i.e.: MKOUT=1 ./run
TEST=*$EXT
if [ $# -ge 1 ]; then TEST=$1; fi
cnt=0
tot=0
for i in $TEST; do
	base=`basename $i $EXT`
	RUN=1
	for i in 1 2 3 4 5 6 7 8 9; do
		IN=null.in
		ARG=null.arg
		if [ -f $base$i.arg ]; then ARG=$base$i.arg; RUN=1; fi
		if [ -f $base$i.in ]; then IN=$base$i.in; RUN=1; fi
		if [ $RUN -eq 1 ]; then
			OUT=$base$i.out
			args=`cat $ARG`
			if [ "$MKOUT" != "" ]; then
				./$base $args < $IN > $OUT
			else
				if [ ! -f $OUT ]; then continue; fi
				./$base $args < $IN | diff - $OUT
			fi
			ok=$?
			if [ $ok -eq 0 ]; then cnt=`expr $cnt + 1`; fi
			tot=`expr $tot + 1`
			echo "./$base $args < $IN ($ok)"
		fi
		RUN=0
	done
done
echo OK: $cnt in $tot
