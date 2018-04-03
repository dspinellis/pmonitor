# pmonitor
The _pmonitor_ command allows you to monitor a job's progress by specifying
the name of the corresponding command, its process id, or the file being processed.

See the examples below.

### Progress of uncompressing a file
```
$ pmonitor --command=gzip
/home/dds/data/mysql-2015-04-01.sql.gz 58.06%
```

### Progress of resolving IP addresses in a web server log file
```
$ pmonitor -c logresolve -i 20
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 4.02%
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 12.05% ETA 0:03:38
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 16.06% ETA 0:04:38
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 20.08% ETA 0:04:58
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 24.10% ETA 0:05:02
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 28.11% ETA 0:04:58
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 36.14% ETA 0:03:58
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 44.18% ETA 0:03:14
/var/log/apache2/www.balab.aueb.gr_access_ssl.log.1 52.21% ETA 0:02:38
```

### Progress of a MariaDB file import
```
$ pmonitor -u -c mysql
/home/dds/data/mysql-2018-01-01/project_commits.csv 96.50%
```

### Progress of a MariaDB primary key index generation
```
$ sudo pmonitor -u -c mysqld -i 10 -f /home/mysql/ghtorrent/project_commits.MYD
/home/mysql/ghtorrent/project_commits.MYD 7.88%
/home/mysql/ghtorrent/project_commits.MYD 7.92% ETA 6:32:27
/home/mysql/ghtorrent/project_commits.MYD 7.96% ETA 6:26:32
/home/mysql/ghtorrent/project_commits.MYD 8.00% ETA 6:29:27
/home/mysql/ghtorrent/project_commits.MYD 8.04% ETA 6:24:26
/home/mysql/ghtorrent/project_commits.MYD 8.08% ETA 6:23:24

```
### Progress of a MariaDB index generation
```
$ sudo pmonitor -u -c mysqld -i 10 -f /home/mysql/ghtorrent/\#sql-62f0_14.MYD
/home/mysql/ghtorrent/#sql-62f0_14.MYD 9.44%
/home/mysql/ghtorrent/#sql-62f0_14.MYD 9.44% ETA 552:52:34
```

## Installation
Run `make install` or simply copy the file `pmonitor.sh` as `pmonitor` in
your path.

The _pmonitor_ program requires a working version of _lsof_.

## Manual page
You can find the command's manual page [here](http://htmlpreview.github.io/?https://github.com/dspinellis/pmonitor/blob/master/pmonitor.html).

## See also
* [pv](http://www.ivarch.com/programs/pv.shtml)
* [progress](https://github.com/Xfennec/progress)
