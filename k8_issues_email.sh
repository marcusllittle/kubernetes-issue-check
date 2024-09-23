#!/bin/bash

# Path to the clusters.txt file
CLUSTERS_FILE="/path/to/clusters.txt"

# Email recipient
EMAIL="you@example.com"

# Function to check for pod status in all namespaces
check_pods_status() {
  local cluster=$1
  local region=$2
  local project=$3

  echo "Checking cluster: $cluster"
  gcloud container clusters get-credentials $cluster --region $region --project $project

  # Get all namespaces
  NAMESPACES=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name")

  for ns in $NAMESPACES; do
    echo "Checking namespace: $ns in cluster: $cluster"
    
    # Search for problematic pod states
    kubectl get pods -n $ns --no-headers \
      | grep -E 'Terminating|Pending|Evicted|OOMKilled|CrashLoopBackOff|ImagePullBackOff|NodePressure|MemoryPressure|CPUThrottling|FailedScheduling|BackOff|Error'
  done
}

# Create a report file
REPORT_FILE="/tmp/k8s_pod_issues_report.txt"

# Loop through each cluster in clusters.txt and check pod status
while read -r cluster region project; do
  check_pods_status $cluster $region $project >> $REPORT_FILE
done < $CLUSTERS_FILE

# Send the report via email if there are any issues
if [[ -s $REPORT_FILE ]]; then
  mail -s "Kubernetes Pod Issues Report" $EMAIL < $REPORT_FILE
fi

# Cleanup
rm $REPORT_FILE

