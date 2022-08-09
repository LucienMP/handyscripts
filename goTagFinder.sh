#!/bin/bash


# Use: $0 kernel/printk/printk.c >mytaglist
if [ $# -lt 1 ] ; then
    echo "$0 kernel/printk/printk.c"
    exit -1
fi

#echo "XXX: $1"

# File we want to examine; eg kernel/printk/printk.c
FILENAME=$1 
if [ "x$FILENAME" == "x" ] ; then
    echo "Need to supply a valid file name for to check git commits for"
    exit -1
fi

if [ ! -f $FILENAME ] ; then
    echo "Specified file ($FILENAME) is not found"
    exit -1 
fi

# If there is a function name then use it
# NOTE: we could imrpove this by allowing lots of partial words to help reduce the terms found
FUNC=${2:-}


IFS=$'\n'

# git tag --sort=taggerdate --contains d58ad10122e6f8f84b1ef60227233b7c5de2bc02 | grep -ve "-rc[0-9]*"


START=""
SHA=""
PROTOTYPE=""

# Itterate through all tags in Linux KErnel, ignoring v##.##-rc## releases
# NOTE: We could manually order but maybe not useful.
#
for vers in $(git tag --sort=v:refname | grep -ve "-rc*" )
do
	if [ "x$START" == "x" ] ; then
		# Skip until some version to start from
		if [ "x$vers" != "xv3.10.108" ] ; then
			continue
		fi

		#	echo $vers
		#	git show $vers:$FILENAME 2>/dev/null 1>/dev/null
		#	ERR=$?
		#	if [ $ERR -eq 128 ] ; then
		#	    echo "File not in current file location"
		#	    continue
		#	fi
	
		START="$vers"
		echo "First found this file at tag: $START"
		echo ""
	fi

	LAST=$END
	END="$vers"
    
    #echo "NEXT: $START..$END"
	git diff $START...$END --quiet $FILENAME
	ERR=$?

	# File doesnt exist, tag doesnt exist, something else fatal - keep moving start point
    if [ $ERR -eq 128 ] ; then
		echo "No tag...#ERROR"
		START="$vers"
    else
		# There is a difference returned by git-diff, last unchanged tag
		if [ $ERR -eq 1  ] ; then
		    echo "* PATCH: $START..$LAST"
		    echo "  PROTOTYPE: $PROTOTYPE"
			echo "  COMMIT SHA:"
		    echo "$SHA"

		    # Get commits in this tag range, and indent by tab
		    SHA=$(git log $START..$END --abbrev-commit --pretty=oneline $FILENAME | sed 's/^/\t/')

			# Find function definition we might be interested in, try to combine lines, and ignore prototype definitions
			if [ "x$FUNC" != "x" ] ; then
				PROTOTYPE=$(git show $END:$FILENAME | grep -A1 -e  "static.* $FUNC(.*[^;]$" | tr -d '\n' | tr -d '\t' |  sed -e 's/\t*/ /')
			else
				PROTOTYPE=""
			fi
		    LAST=$END
		    START=$END
		fi
    fi

done



