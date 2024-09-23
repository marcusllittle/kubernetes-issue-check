
Memory updated
Here's a sample README.md that you can use for the GitHub repository:

Kubernetes Cluster Issues Checker
This repository contains two scripts to help monitor the status of Kubernetes pods across multiple clusters. The scripts can be used to check for pods in problematic states and, optionally, send email reports with the results.

Files
k8_issues.sh: Script to manually check for Kubernetes pod issues in multiple clusters.
k8_issues_email.sh: Script to check for Kubernetes pod issues in multiple clusters and send the results via email.
clusters.txt: A list of clusters and their details used by both scripts for switching contexts and running checks.
Prerequisites
Access to Kubernetes clusters and the kubectl CLI.
Access to gcloud for setting Kubernetes cluster contexts.
Email configuration (for k8_issues_email.sh).
A text file clusters.txt containing the necessary gcloud commands to authenticate and switch contexts for your clusters.
Sample clusters.txt
bash
Copy code
# Add Clusters in this format: cluster-name region project
Usage
1. Manual Run Script (k8_issues.sh)
This script checks for pods in problematic states across the clusters listed in clusters.txt. It looks for the following pod statuses:

Terminating
Pending
Evicted
OOMKilled
CrashLoopBackOff
ImagePullBackOff
NodePressure
MemoryPressure
CPUThrottling
FailedScheduling
BackOff
Error
How to Run
Ensure you have kubectl and gcloud configured.
Update the clusters.txt file with your cluster connection commands.
Run the script:
bash
Copy code
bash k8_issues.sh
The script will:

Switch contexts to each cluster in the clusters.txt file.
Check all namespaces for pods in problematic states.
Print the results to the console.
2. Email Run Script (k8_issues_email.sh)
This script works similarly to k8_issues.sh but also sends the results via email.

How to Run
Ensure you have configured the mail utility (or your preferred email service).
Update the clusters.txt file with your cluster connection commands.
Set up a cron job to run the script periodically (e.g., every 30 minutes):
bash
Copy code
*/30 * * * * /path/to/k8_issues_email.sh
The script will:

Switch contexts to each cluster in the clusters.txt file.
Check all namespaces for pods in problematic states.
Email the results to a specified email address.
Testing Cron Jobs
To manually test the cron job setup, you can run the following command to simulate a cron job run:

bash
Copy code
bash k8_issues_email.sh
License
This project is licensed under the MIT License - see the LICENSE file for details.