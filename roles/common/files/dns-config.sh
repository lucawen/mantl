
#Make sure we use consul for dns 
# not tested with ipv6

local_search="service.consul"
local_nameservers="127.0.0.1 8.8.8.8 8.8.4.4"

rscf="$(mktemp ${TMPDIR:-/tmp}/XXXXXX)"

function header {
  echo "; created by /etc/dhcp/dhclient.d/dns-config.sh" > ${rscf}
}

function local_dns {
  echo "search ${local_search}" >> ${rscf}
  for nameserver in ${local_nameservers} ; do
    echo "nameserver ${nameserver}" >> ${rscf}
  done
} 

#inherits env values from dhcp-client
function dhclient_config {
  if [ -n "${search}" ]; then
    echo "search ${search}" >> $rscf
  fi

  if [ -n "${RES_OPTIONS}" ]; then
   echo "options ${RES_OPTIONS}" >> ${rscf}
  fi

  for nameserver in ${new_domain_name_servers} ; do
    echo "nameserver ${nameserver}" >> ${rscf}
  done
}

function update_resolv_conf {
  cp ${rscf} /etc/resolv.conf &&  rm -f ${rscf} 
}

header

#perfer local and hard-coded dns names
local_dns 

#next, pull in values from dhcp
dhclient_config

update_resolv_conf