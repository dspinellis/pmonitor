#!/bin/sh
#
# Monitor the progress of a specified job
#
# Copyright 2006-2015 Diomidis Spinellis
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# For each file or file associated with the specified process is reading,
# display the percentage associated with its seek pointer offset.  For
# files that are processed in a sequential fashion this can be translated
# to the percentage of the job that has been completed.
#
# This command is modelled after a similar facility
# available on Permin-Elmer/Concurrent OS32
#
# Requires:
# - lsof(8) with offset (-o) printing functionality
#
# Tested under FreeBSD 4.11 and FreeBSD 6.0
#

# Display the scanned percentage of lsof files.
# The OPT1 and OPT2 variables are passed to lsof as arguments.
display()
{
  # Obtain the offset and print it as a percentage
  lsof -o0 -o "$OPT1" "$OPT2" |
      awk '
    BEGIN { CONVFMT = "%.2f" }
    $4 ~ /^[0-9]+[ru]$/ && $7 ~ /^0t/ {
      offset = substr($7, 3)
      fname = $9
      "ls -l '\''" fname "'\'' 2>/dev/null" | getline
      len = $5
      if (len + 0 > 0)
        print fname, offset / len * 100 "%"
    }
  '
}

# Report program usage information
usage()
{
	cat <<\EOF 1>&2
Usage:

pmonitor [-c command] [-f file] [-i interval] [-p pid]
-c, --command=COMMAND	Monitor the progress of the specified running command
-f, --file=FILE		Monitor the progress of commands processing the
			specified file
-h, --help		Display this message and exit
-i, --interval=INTERVAL	Continuously display the progress every INTERVAL seconds
-p, --pid=PID		Monitor the progress of the process with the specified
			process id

Exactly one of the c, f, p options must be specified.

Terminating...
EOF
}

# Option processing; see /usr/share/doc/util-linux-ng-2.17.2/getopt-parse.bash
# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need TEMP as the `eval set --' would nuke the return value of getopt.

# Allowed short options
SHORTOPT=c:,f:,h,i:,p:

if getopt -l >/dev/null 2>&1 ; then
  # Simple (e.g. FreeBSD) getopt
  TEMP=$(getopt $SHORTOPT "$@")
else
  # Long options supported
  TEMP=$(getopt -o $SHORTOPT --long command:,file:,help,interval:,pid: -n 'pmonitor' -- "$@")
fi

if [ $? != 0 ] ; then
  usage
  exit 2
fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while : ; do
  case "$1" in
    -c|--command)
      OPT1=-c
      OPT2="$2"
      shift 2
      ;;
    -f|--file)
      OPT1=--
      OPT2="$2"
      shift 2
      ;;
    -i|--interval)
      INTERVAL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -p|--pid)
      OPT1=-p
      OPT2="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 3
      ;;
  esac
done

# No more arguments allowed and one option must be specified
if [ "$1" != '' -o ! -n "$OPT1" -o ! -n "$OPT2" ]
then
  usage
  exit 2
fi

if [ "$INTERVAL" ] ; then
  while : ; do
    display
    sleep $INTERVAL
  done
else
  display
fi
