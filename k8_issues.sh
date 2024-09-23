#!/bin/bash

# Cluster list file (each line: cluster_name region project)
CLUSTER_FILE="clusters.txt"

# Function to switch cluster and check pod statuses
check_pods_in_cluster() {
  local cluster=$1
  local region=$2
  local project=$3

  echo "Switching context to cluster: $cluster in region: $region and project: $project"

  # Get cluster credentials
  gcloud container clusters get-credentials $cluster --region $region --project $project
  
  if [ $? -ne 0 ]; then
    echo "Failed to switch context to $cluster. Skipping to next cluster."
    return
  fi

  echo "Checking for problematic pods in cluster: $cluster"

  # List of namespaces to check
  NAMESPACES=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name")

  # Function to check for pod status
  check_pods_status() {
    local namespace=$1

    echo "Checking namespace: $namespace"

    # Search for pods in problematic states
    kubectl get pods -n $namespace --no-headers \
      | grep -E 'Terminating|Pending|Evicted|OOMKilled|CrashLoopBackOff|ImagePullBackOff|NodePressure|MemoryPressure|CPUThrottling|FailedScheduling|BackOff|Error'
  }

  # Loop through namespaces and check for issues
  for ns in $NAMESPACES; do
    check_pods_status $ns
  done
}

# Function to display menu and select a cluster from the list
select_cluster() {
  local clusters=($(awk '{print $1}' $CLUSTER_FILE))
  
  echo "Available Clusters:"
  PS3="Select a cluster to check: "
  
  select cluster in "${clusters[@]}" "Exit"; do
    if [[ "$cluster" == "Exit" ]]; then
      echo "Exiting."
      exit 0
    fi

    # Get cluster info from the file (name, region, project)
    cluster_info=$(grep "^$cluster" $CLUSTER_FILE)

    if [ -n "$cluster_info" ]; then
      cluster_name=$(echo $cluster_info | awk '{print $1}')
      cluster_region=$(echo $cluster_info | awk '{print $2}')
      cluster_project=$(echo $cluster_info | awk '{print $3}')
      
      check_pods_in_cluster $cluster_name $cluster_region $cluster_project
    else
      echo "Invalid selection."
    fi

    # Allow user to select again or exit
    echo
    echo "Do you want to check another cluster? (y/n)"
    read answer
    if [[ "$answer" == "n" ]]; then
      echo "Exiting."
      exit 0
    fi
  done
}

# Main function
main() {
  select_cluster
}

# Run the script
main

