#!/bin/bash
# SOF-ELK® Supporting script
# (C)2018 Lewes Technology Consulting, LLC
#
# This script is used to perform post-merge steps, eg after the git repository is updated

# reload all dashboards
/usr/local/sbin/load_all_dashboards.sh

# activate all "supported" Logstash configuration files
for file in $( ls -1 /usr/local/sof-elk/configfiles/* 2> /dev/null ) ; do
    if [ -h /etc/logstash/conf.d/$( basename $file ) ]; then
        rm -f /etc/logstash/conf.d/$( basename $file )
    fi

    ln -s $file /etc/logstash/conf.d/$( basename $file )
done
# reload logstash
for lspid in $( ps -u logstash | grep java | awk '{print $1}' ); do
    kill -s HUP $lspid
done

# activate all elastalert rules
for file in $( ls -1 /usr/local/sof-elk/lib/elastalert_rules/*.yaml 2> /dev/null ); do
	if [ -h /etc/elastalert_rules/$( basename $file ) ]; then
		rm -f /etc/elastalert_rules/$( basebame $file )
	fi

	ln -s $file /etc/elastalert_rules/$( basename $file )
done
# reload elastalert
/usr/bin/systemctl restart elastalert

# restart filebeat to account for any new config files and/or prospectors
/usr/bin/systemctl restart filebeat

# other housecleaning
LOGO_PATH="/usr/share/kibana/src/core_plugins/kibana/public/assets/sof-elk.svg"
if [ -a $LOGO_PATH ]; then
    rm -rf $LOGO_PATH
fi
ln -fs /usr/local/sof-elk/lib/sof-elk.svg $LOGO_PATH
