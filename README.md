# pmonitor
The _pmonitor_ command allows you to monitor a job's progress by specifying
the name of the corresponding command, its process id, or the file being processed.

See the examples below.

### Progress of a simple gzip operation
```
$ pmonitor --command=gzip
/home/dds/data/mysql-2015-04-01.sql.gz 58.06%
```

### Progress of a MySQL index generation query
```
$ sudo pmonitor --pid=12612 >a
$ sudo pmonitor --pid=12612 >b
$ diff a b
39c39
< /var/lib/mysql/ghtorrent/#sql-3144_30.MYD 33.98%
---
> /var/lib/mysql/ghtorrent/#sql-3144_30.MYD 34.93%

$ sudo pmonitor --file='/var/lib/mysql/ghtorrent/#sql-3144_30.MYD' --interval=1
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 78.36%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 78.63%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 78.90%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 79.21%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 79.49%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 79.77%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 80.04%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 80.31%
/var/lib/mysql/ghtorrent/#sql-3144_30.MYD 80.58%
```

## Installation
Run `make install` or simply copy the file `pmonitor.sh` as `pmonitor` in
your path.

The _pmonitor_ program requires a working version of _lsof_.

## Manual page
You can find the command's manual page [here](http://htmlpreview.github.io/?https://github.com/dspinellis/pmonitor/blob/master/pmonitor.html).

## See also
* [pv](http://www.ivarch.com/programs/pv.shtml)
