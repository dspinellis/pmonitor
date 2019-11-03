#!/bin/sh
#
# Monitor the progress of a specified job
#
# Copyright 2006-2018 Diomidis Spinellis
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
# Submit issues and pull requests as https://github.com/dspinellis/pmonitor
#

# Run lsof with the specified options
# The OPT1 and OPT2 variables are passed to lsof as arguments.
opt_lsof()
{
  lsof -w -o0 -o "$OPT1" "$OPT2"
}

# Display the scanned percentage of lsof files.
display()
{
  # Obtain the offset and print it as a percentage
  awk '
    # Return current time
    function time() {
	"date +%s" | getline t
	close("date +%s")
	return t
    }

    # Return length of specified file
    function file_length(fname) {
      if (!cached_length[fname]) {
        if (fname ~ /^\/dev\/[^/]*$/ && system("test -b " fname) == 0) {
          getline < ("/sys/block/" substr(fname, 6) "/size")
          cached_length[fname] = $1 * 512 # sector size is always 512 bytes
        } else {
          "ls -l '\''" fname "'\'' 2>/dev/null" | getline
          cached_length[fname] = $5 + 0
        }
      }
      return cached_length[fname]
    }

    BEGIN {
      CONVFMT = "%.2f"
      start = time()
    }

    $4 ~ /^[0-9]+[r'$UPDATE']$/ && $7 ~ /^0t/ {
      now = time()
      offset = substr($7, 3)
      fname = $9
      len = file_length(fname)
      if (len > 0) {
	if (!start_offset[fname])
	  start_offset[fname] = offset
	delta_t = now - start
	delta_o = offset - start_offset[fname]
	if (delta_t > 2 && delta_o > 0) {
	  bps = delta_o / delta_t
	  t = (len - offset) / bps
	  eta = ""
	  if (t > 0) {
	    eta_s = t % 60
	    t = int(t / 60)
	    eta_m = t % 60
	    t = int(t / 60)
	    eta_h = t
	    eta = sprintf(" ETA %d:%02d:%02d", eta_h, eta_m, eta_s)
	  }
	}
        out = fname "\t" offset / len * 100 "%"
	if (!'$ONLYDIFF' || !seen[out])
	  print out eta
	seen[out] = 1
      }
    }
  '
}

# Report program usage information
usage()
{
	cat <<\EOF 1>&2
Usage:

pmonitor [-c command] [-d] [-f file] [-i interval] [-p pid]
-c, --command=COMMAND	Monitor the progress of the specified running command
-d, --diff		During continuous display show only records that differ
-f, --file=FILE		Monitor the progress of commands processing the
			specified file
-h, --help		Display this message and exit
-i, --interval=INTERVAL	Continuously display the progress every INTERVAL seconds
-p, --pid=PID		Monitor the progress of the process with the specified
			process id
-u, --update		Also monitor files opened in update (rather than read
			mode)

Exactly one of the c, f, p options must be specified.

Terminating...
EOF
}

# Option processing; see /usr/share/doc/util-linux-ng-2.17.2/getopt-parse.bash
# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need TEMP as the `eval set --' would nuke the return value of getopt.

# Allowed short options
SHORTOPT=c:,d,f:,h,i:,p:,u

if getopt -l >/dev/null 2>&1 ; then
  # Simple (e.g. FreeBSD) getopt
  TEMP=$(getopt $SHORTOPT "$@")
else
  # Long options supported
  TEMP=$(getopt -o $SHORTOPT --long command:,diff,file:,help,interval:,pid:,update -n 'pmonitor' -- "$@")
fi

if [ $? != 0 ] ; then
  usage
  exit 2
fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

ONLYDIFF=0

while : ; do
  case "$1" in
    -c|--command)
      test -z "$OPT1" || usage
      OPT1=-c
      OPT2="$2"
      shift 2
      ;;
    -d|--diff)
      ONLYDIFF=1
      shift
      ;;
    -f|--file)
      test -z "$OPT1" || usage
      if ! [ -r "$2" ] ; then
	echo "Unable to read $2" 1>&2
	exit 1
      fi
      OPT1=--
      OPT2="$2"
      shift 2
      UPDATE=u
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
      test -z "$OPT1" || usage
      OPT1=-p
      OPT2="$2"
      shift 2
      ;;
    -u|--update)
      UPDATE=u
      shift
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
    opt_lsof
    sleep $INTERVAL
  done
else
  ONLYDIFF=0
  opt_lsof
fi |
display
