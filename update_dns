#/bin/bash
if [[ -z $1 ]];
then
        echo "Please choose domain zone and provider ./update.sh <zone> <provider> or <provider1> <provider2>"
        echo "exmp. ./update.sh lv ISP1"
        echo "exmp. ./update.sh com ISP1 ISP2"
        exit 1
fi
SERIAL_DATA=$(cat template_soa.$1 | grep serial | awk '{print $1'}  | cut -c -8 );
SERIAL_NUM=$(cat template_soa.$1 | grep serial | awk '{print $1'}  | cut -c 9- );
SERIAL_NUMBER=$(cat template_soa.$1 | grep serial | awk '{print $1'} );

DATE=`date +%Y%m%d`
SERIAL=01
OLDSERIAL=$SERIAL_DATA$SERIAL_NUM
if [[ "$SERIAL_DATA" == "$DATE" ]]
then
        NEW_NUM=$((10#$SERIAL_NUM + 1))
        NEWSERIAL=$SERIAL_DATA$(printf "%02d" $NEW_NUM)
else
        NEWSERIAL=$DATE$SERIAL
fi
echo $OLDSERIAL
echo $NEWSERIAL
sed -i 's/'$OLDSERIAL'/'$NEWSERIAL'/' template_soa.$1
if [[ -z $3 ]];
then
        cat template_soa.$1 > /etc/bind/zones/example.$1 && egrep "$2" template_example.$1 >> /etc/bind/zones/example.$1
else
        cat template_soa.$1 > /etc/bind/zones/example.$1 && egrep "$2|$3" template_example.$1 >> /etc/bind/zones/example.$1
fi
