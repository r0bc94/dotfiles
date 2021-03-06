RECEIVING_FILE="/tmp/polybar-conn-receiving-bytes"
SENDING_FILE="/tmp/polybar-conn-sending-bytes"

receiving () {
    current=`cat /sys/class/net/$1/statistics/rx_bytes`
    if [ ! -f $RECEIVING_FILE ]; then
        echo $current > $RECEIVING_FILE
        return 1
    fi

    last=`cat $RECEIVING_FILE`

    echo $current > $RECEIVING_FILE

    diff=`expr $current - $last`
    kb=`expr $diff / 1024`
    mb=$(echo $diff | awk '{printf "%.2f", $diff/1024/1024}')

    label=""
    color=""

    if [ $kb -gt "999" ]; then
        color="#ff3300"
        label="$mb"
    elif [ $kb -gt "500" ]; then
        color="#ffaa00"
        label="$mb"
    elif [ $kb -gt "100" ]; then
        color="#ffcc00"
        label="$mb"
    elif [ $kb -gt "100" ]; then
        color="#ffee00"
        label="$mb"
    elif [ $kb -gt "10" ]; then
        color="#657b83"
        label="$mb"
    fi

    if [ ! $label == "" ]; then
        echo "%{u$color}In: $label mB/s%{F-}"
    fi
}

sending () {
    current=`cat /sys/class/net/$1/statistics/tx_bytes`
    if [ ! -f $SENDING_FILE ]; then
        echo $current > $SENDING_FILE
        return 1
    fi

    last=`cat $SENDING_FILE`

    echo $current > $SENDING_FILE

    diff=`expr $current - $last`
    kb=`expr $diff / 1024`
    mb=$(echo $diff | awk '{printf "%.2f", $diff/1024/1024}')

    label=""
    color=""

    if [ $kb -gt "999" ]; then
        color="#993300"
        label="$mb"
    elif [ $kb -gt "500" ]; then
        color="#996600"
        label="$mb"
    elif [ $kb -gt "100" ]; then
        color="#998800"
        label="$mb"
    elif [ $kb -gt "100" ]; then
        color="#999900"
        label="$mb"
    elif [ $kb -gt "10" ]; then
        color="#657b83"
        label="$mb"
    fi

    if [ ! $label == "" ]; then
        echo "%{u$color}Out: $label mB/s%{F-}"
    fi
}

gateway=`ip r | grep default | cut -d ' ' -f 3`
if [ -z "$gateway" -a "$gateway" != " " ]; then
    echo "Offline"
    exit 0
fi

test=$(ping -q -w 1 -c 1 $gateway> /dev/null && echo 1 || echo 0)
interface=$(route | grep '^default' | grep -o '[^ ]*$')
receiving=$(receiving $interface)
sending=$(sending $interface)
network="$receiving"

if [[ -n "${network// }" ]]; then
    network="$receiving $sending"
else
    network="$sending"
fi

if [ ! -z "$network" -a "$network" != " " ]; then
    echo "$network"
    exit 0
elif [ $test -eq 1 ]; then
  label="Online"
  color="#008899"
else
  label="Offline"
  color="#aa3300"
fi

echo "%{u$color}$label%{F-}"
