#!/bin/bash -x
# b1_hana_inst.sh - is a script used to list available HANA DBs for SAP Business One installations.
#   SAP Business One, version for SAP HANA
#   SAP Business One analytics powered by SAP HANA
#
# Copyright (c) 2013 SAP AG
#
# This program is free software; you can redistribute it and/or 
# modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation only version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
# for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, see <http://www.gnu.org/licenses/>.

PRODDIR=$1
DATADIR=$2
if [ ! -e /etc/sysconfig/sap-installation-wizard ]; then
    INSTDIR="/data/SAP_INST"
else
    . /etc/sysconfig/sap-installation-wizard
fi
for i in ${INSTDIR}/*
do
  if [ -e $i/product.data ]; then
    grep product_id  $i/product.data | grep -q HANA
    if [ $? = 0 -a -e $i/ay_q_masterPwd ]; then
      cp $i/ay_q_masterPwd ${PRODDIR}/ay_q_masterPwd
      inst_nr=$( cat $i/ay_q_sapinstnr )
      sid=$( cat $i/ay_q_sid )
      echo "${sid}:${inst_nr}" > ${PRODDIR}/ay_q_sid
      NOASK=1
      break
    fi
  fi
done

if [ -z "${NOASK}" -a -d /hana/data ]
then
  # get a list of installed HANA DBs
  SID='<selection config:type="list">'
  all_sid_arr=(`ls -1 /hana/data/`)

  # checking which one is running
  for i in "${all_sid_arr[@]}"
  do
    ps aux | grep -v grep | grep -i "/usr/sap/${i}/...../exe/sapstartsrv" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      inst_nr=`ls -1 /usr/sap/$i/ | grep HDB | cut -c 4-`
      SID="${SID}<entry><value>$i:$inst_nr</value><label>$i:$inst_nr</label></entry>"
      break
    fi
  done
fi

if [ "${NOASK}" ]; then
  cp ${PRODUCT_XML_PATH}/B1.noask.xml ${PRODUCT_XML_PATH}/B1.xml
else
  SID="${SID}</selection>"
  sed "s#<default>___SAPSID___</default>#${SID}#g" ${PRODUCT_XML_PATH}/B1.templ.xml > ${PRODUCT_XML_PATH}/B1.xml
fi
