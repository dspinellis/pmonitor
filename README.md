# pmonitor
The _pmonitor_ command allows you to monitor a job's progress by specifying
the name of the corresponding command, its process id, or the
the file being processed.

See the example below.
```
$ pmonitor -c gzip
/home/dds/data/mysql-2015-04-01.sql.gz 58.06%
```

## Installation
Run `make install` or simply copy the file `pmonitor.sh` as `pmonitor` in
your path.

The _pmonitor_ program requires a working version of _lsof_.

## Manual page
You can find the command's manual page [here](http://htmlpreview.github.io/?https://github.com/dspinellis/pmonitor/blob/master/pmonitor.html).

## See also
* [pv](http://www.ivarch.com/programs/pv.shtml)
