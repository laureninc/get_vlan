#!/bin/bash

if [[ ! -n $1 ]];
then
	echo "Must enter IP address!"
	exit 1
fi
##############VARIABLES######################
#Не забываем поменять SNMP community
SNMP="snmp_community";
#############################################

OID_VLAN="iso.3.6.1.2.1.17.7.1.4.3.1";
OID_MODEL="iso.3.6.1.2.1.1.1.0";
OID_NAME="iso.3.6.1.2.1.1.5.0";

#Стягиваем модель свитча. Если модель есть в списке - работаем и пишем нужные перменные. Если модели нет - прерываем скрипт.
switch_name=$(snmpget -v 2c -c $SNMP $1 $OID_NAME |cut -d \" -f2);
switch_model=$(snmpget -v 2c -c $SNMP $1 $OID_MODEL  |cut -d \" -f2);

if [[ "$switch_model" == "GS2200-8" ]]
then
	sw_num_ports=10
	swmodel="ZyXEL GS2200-10"
elif [[ "$switch_model" == "GS2200-24" ]]
then
	sw_num_ports=28
	swmodel="ZyXEL GS2200-24"
elif [[ "$switch_model" == "GS2210-8" ]]
then
	sw_num_ports=10
	swmodel="ZyXEL GS2210-8"
elif [[ "$switch_model" == "GS2210-24" ]]
then
	sw_num_ports=28
	swmodel="ZyXEL GS2210-24"
elif [[ "$switch_model" == "GS2210-48" ]]
then
	sw_num_ports=50
	swmodel="ZyXEL GS2210-48"
elif [[ "$switch_model" == "D-Link DES-3200-10 Fast Ethernet Switch" ]]
then
	sw_num_ports=10
	swmodel="D-Link DES-3200-10"
elif [[ "$switch_model" == "DES-3200-10/C1 Fast Ethernet Switch" ]]
then
	sw_num_ports=10
	swmodel="D-Link DES-3200-10"
elif [[ "$switch_model" == "D-Link DES-3200-18 Fast Ethernet Switch" ]]
then
	sw_num_ports=18
	swmodel="D-Link DES-3200-18"
elif [[ "$switch_model" == "D-Link DES-3200-26 Fast Ethernet Switch" ]]
then
	sw_num_ports=26
	swmodel="D-Link DES-3200-26"
elif [[ "$switch_model" == "D-Link DES-3200-28 Fast Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="D-Link DES-3200-28"
elif [[ "$switch_model" == "DES-3200-28/C1 Fast Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="D-Link DES-3200-28"
elif [[ "$switch_model" == "DES-3200-52/C1 Fast Ethernet Switch" ]]
then
	sw_num_ports=52
	swmodel="D-Link DES-3200-52"
elif [[ "$switch_model" == "D-Link DES-3200-28F Fast Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="D-Link DES-3200-28F"
elif [[ "$switch_model" == "DES-3200-28F/C1 Fast Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="DES-3200-28F"
elif [[ "$switch_model" == "DGS-3120-24SC Gigabit Ethernet Switch" ]]
then
	sw_num_ports=26
	swmodel="DGS-3120-24SC"
elif [[ "$switch_model" == "DGS-3100-24TG  Gigabit stackable L2 Managed Switch" ]]
then
	sw_num_ports=25
	swmodel="DGS-3100-24TG "
elif [[ "$switch_model" == "DGS-3420-26SC Gigabit Ethernet Switch" ]]
then
	sw_num_ports=26
	swmodel="DGS-3420-26SC "
elif [[ "$switch_model" == "DGS-3420-28SC Gigabit Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="DGS-3420-28SC"
elif [[ "$switch_model" == "DES-3526 Fast-Ethernet Switch" ]]
then
	sw_num_ports=26
	swmodel="DES-3526 "
elif [[ "$switch_model" == "D-Link DES-3010G Fast Ethernet Switch" ]]
then
	sw_num_ports=10
	swmodel="D-Link DES-3010G Fast Ethernet Switch"
elif [[ "$switch_model" == "DGS-1510-28XS/ME Gigabit Ethernet Switch" ]]
then
	sw_num_ports=28
	swmodel="DGS-1510-28XS/ME"
elif [[ "$switch_model" == "24-port 10/100/1000 Ethernet Switch" ]]
then
	sw_num_ports=24
	swmodel="AT-8000GS/24"
	elif [[ "$switch_model" == "ATI AT-8000S" ]]
then
	sw_num_ports=50
	swmodel="AT-8000S-48 or AT-8000S-24"
else
	echo "Sorry, but device $switch_model is not supported right now! Come back later"
	exit 1
fi

#Стягиваем все вланы со свитча, обрезаем лишнее, пишем в перменную. 
VLANS=$(snmpwalk -c $SNMP -v2c $1 $OID_VLAN.1 | sed 's/'$OID_VLAN'.1.//g' | cut -d " " -f1)

#Открываем цикл
for i in $VLANS
do
	#Получаем информацию о присутствии тегированных вланов и нетегированных вланов в HEX. Обрезаем лишнее, создаем переменную.
	tagged_vlan_in_hex=$(snmpwalk -c $SNMP -v2c $1 $OID_VLAN.2.$i | awk '{print $4$5$6$7$8$9$10$11}' | head -n 1)
	untagged_vlan_in_hex=$(snmpwalk -c $SNMP -v2c $1 $OID_VLAN.4.$i | awk '{print $4$5$6$7$8$9$10$11}' | head -n 1)

	#Переводим из HEX в BIN. "FF" перед переменной это хак, для вывода бинарника, если впереди имеются нули
	tagged_vlan_in_bin=$(echo "obase=2; ibase=16; FF$tagged_vlan_in_hex" | bc | cut -c 9- | cut -c -$sw_num_ports)
	untagged_vlan_in_bin=$(echo "obase=2; ibase=16; FF$untagged_vlan_in_hex" | bc | cut -c 9- | cut -c -$sw_num_ports)

	#Создаем список тегированных вланов	
	tagged_count=1

	#Выводим полученный BIN построчно
	for tagged_port in $( echo $tagged_vlan_in_bin | sed -e 's/\(.\)/\1\n/g' )
	do
		#Сравниваем если порту соответствует единица - выводим
		if [[ $tagged_port -eq 1 ]]
		then
			in_tagged_port[$tagged_count]="${in_tagged_port[$tagged_count]} $i"
	fi
	((tagged_count++));
	done

	
	#Все тоже самое, но для нетегированных вланов
       untagged_count=1
	for untagged_port in $( echo $untagged_vlan_in_bin | sed -e 's/\(.\)/\1\n/g' )
	do
		if [[ $untagged_port -eq 1 ]]
		then
			#echo "VLAN ID $i Untagged on port: $untagged_count"
			in_untagged_port[$untagged_count]="${in_untagged_port[$untagged_count]} $i"
	fi
	((untagged_count++));
	done
done

#Рисуем таблицу
echo ""
echo "+---------------------------------------+"
echo "| $swmodel - $switch_name			|"
echo "+---------------------------------------+"
echo "| PORT NUM	|	PVID		|"
echo "+=======================================+"

qqq=$(`echo seq "$sw_num_ports"`)
for uf in $qqq
do
	if [[ "${#in_tagged_port[$uf]}" == "${#in_untagged_port[$uf]}" ]]
	then
		echo "|$uf 		| U: "${in_tagged_port[$uf]}"		|"
		echo "+---------------------------------------+"

	elif [[ -z "${#in_untagged_port[$uf]}" ]]
	then
		echo "|$uf 		| U: "${in_untagged_port[$uf]}"		|"
		echo "+---------------------------------------+"
	else [[ "${in_tagged_port[$uf]}" != "${in_untagged_port[$uf]}" ]]
		echo "|$uf 		| T: "${in_tagged_port[$uf]}"	|"
# | sed 's/'"${in_untagged_port[$uf]}"'/ /g' 
		echo "|		| U: "${in_untagged_port[$uf]}"			|"
		echo "+---------------------------------------+"
fi
done
