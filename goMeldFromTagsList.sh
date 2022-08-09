#!/bin/bash

# Use: $0 kernel/printk/printk.c mytaglist
if [ $# -lt 2 ] ; then
    echo "$0 kernel/printk/printk.c mytaglist"
    exit -1
fi

# File we want to examine; eg kernel/printk/printk.c
FILENAME=$1 


# List of tags showing when changes happened
# Format:
# "  PATH: v5.10..v5.99.99" ->output-> "v5.10"
TAGFILE=$2
if [ "x$TAGFILE" == "x" ] ; then
    echo "Need to supply a kernel tag list filename as param0 in format:"
    echo "  PATCH: v5.10..v5.99.99"
    exit -1
fi

if [ ! -f $TAGFILE ] ; then
    echo "Specified file ($TAGFILE) is not found"
    exit -1 
fi

# Strip the "start" tag so we can check it, create a tag list and show changes in a ui
grep "PATCH" $TAGFILE | sed 's/^* PATCH: \(v[0-9.]*\)\.\.v.*$/\1/' >/tmp/startTags
TAGFILE=/tmp/startTags

# A/B versions
A=""
B=""

for vers in $(cat $TAGFILE)
do
	if [ "x$A" == "x" ] ; then
        git show $vers:$FILENAME >/dev/null
        ERR=$?
        if [ $ERR -eq 128 ] ; then
    		echo "#ERROR: File is missing for $vers"
            continue
        fi

        A=$vers
        continue
    fi

    B=$vers

    echo "Comparing: $A..$B"

    git show $A:$FILENAME >/tmp/fileA
	ERR=$?
    if [ $ERR -eq 128 ] ; then
		echo "#ERROR: File is missing"
        continue
    fi

    git show $B:$FILENAME >/tmp/fileB
	ERR=$?
    if [ $ERR -eq 128 ] ; then
		echo "#ERROR: File is missing"
        continue
    fi

    # Display A/B in diff tool like MELD
    meld /tmp/fileA /tmp/fileB
    exit
done
