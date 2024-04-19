#!/bin/bash
clear
echo "---------------------------------------------------------------"

# Define arrays for cell and Kel names or ip
cells=("cell1" "cell2")
kels=("kel1" "kel2" "kel3")

get_node_info() {
    local node="$1"
    local net="$2"
    local chain="$3"

    echo "$node"
    ssh "$node" systemctl status cellframe-node | grep active
    ssh "$node" /opt/cellframe-node/bin/cellframe-node-cli block autocollect status -net "$net" -chain "$chain" | grep "Autocollect status "
    ssh "$node" /opt/cellframe-node/bin/cellframe-node-cli net get status -net "$net" | grep "current"
    ssh "$node" /opt/cellframe-node/bin/cellframe-node-cli net get status -net "$net" | grep "percent"
    cert_name=$(ssh "$node" cat /opt/cellframe-node/etc/network/"$net".cfg | grep "blocks-sign-cert=" | sed 's/^.................//')
    output=$(ssh "$node" /opt/cellframe-node/bin/cellframe-node-cli block list signed -net "$net" -chain "$chain" -cert "$cert_name" | tail -n 3 | head -n 1  | rev | cut -c 6-14 | rev)
    epoch_time=$(ssh "$node" date -d "$output" +"%s")
    current_epoch_time=$(ssh "$node" date +"%s")
    difference=$(( (current_epoch_time - epoch_time) / 60 ))
    echo "Last block time : $difference"
    echo "---------------------------------------------------------------"
}

# Loop through cells
for cell in "${cells[@]}"; do
    get_node_info "$cell" "Backbone" "main"
done

# Loop through kels
for kel in "${kels[@]}"; do
    get_node_info "$kel" "KelVPN" "main"
done
