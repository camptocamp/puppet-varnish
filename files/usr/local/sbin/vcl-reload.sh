#!/bin/bash
# Reload a varnish config
# Author: Kristian Lyngstol

# Original version: 
# http://kly.no/posts/2009_02_18__Easy_reloading_of_varnish__VCL__.html

if [ $# -lt 1 -o $# -gt 2 ]; then
  echo "Usage: $0 vcl_file [secret_file]"
  exit 1
fi
FILE=$1

if [ $# -eq 2 ]; then
  SECRET_OPT="-S $2"
fi

# Hostname and management port
# (defined in /etc/default/varnish or on startup)
HOSTPORT="localhost:6082"
NOW=`date +%F_%H%M%S`
TMPDIR=`mktemp -d`

error()
{
    echo 1>&2 "Failed to reload $FILE."
    exit 1
}
echo "@@@ Checking VCL file syntax:"
varnishd -d -s malloc -n $TMPDIR -u root -f $FILE < /dev/null || error

echo -e "\n@@@ Loading new VCL file:"
varnishadm $SECRET_OPT -T $HOSTPORT vcl.load reload$NOW $FILE || error
varnishadm $SECRET_OPT -T $HOSTPORT vcl.use reload$NOW || error

rm -f "$TMPDIR/_.vsm" && rmdir "$TMPDIR"

echo -e "\n@@@ Currently available VCL configs:"
varnishadm $SECRET_OPT -T $HOSTPORT vcl.list

exit 0

