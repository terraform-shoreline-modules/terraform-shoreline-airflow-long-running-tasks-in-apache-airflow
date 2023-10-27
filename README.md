
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Long running tasks in Apache Airflow
---

This incident type refers to a situation where tasks in Apache Airflow take longer to execute than expected, causing delays and potentially impacting the system's performance. This can happen due to various reasons such as a large volume of data, inefficient code, or resource constraints, among others. Identifying and addressing the root cause of this issue is crucial to ensure the smooth functioning of the system and timely completion of tasks.

### Parameters
```shell
export WORKER_POD_NAME="PLACEHOLDER"

export FAILED_TASK_POD_NAME="PLACEHOLDER"

export SCHEDULER_POD_NAME="PLACEHOLDER"

export WEBSERVER_POD_NAME="PLACEHOLDER"

export DAG_NAME="PLACEHOLDER"

export AIRFLOW_APP_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export CONTEXT_NAME="PLACEHOLDER"
```

## Debug

### Check if Airflow workers are running
```shell
kubectl get pods -l component=worker
```

### Check the logs of a worker pod
```shell
kubectl logs ${WORKER_POD_NAME}
```

### Check if the worker pod has enough resources
```shell
kubectl describe pod ${WORKER_POD_NAME}
```

### Check if there are any failed tasks
```shell
kubectl get pods -l component=worker | grep -v Running | grep -v Completed
```

### Check the logs of a failed task
```shell
kubectl logs ${FAILED_TASK_POD_NAME}
```

### Check if there are any pending tasks
```shell
kubectl get pods -l component=worker | grep Pending
```

### Check if there are any issues with the Airflow scheduler
```shell
kubectl get pods -l component=scheduler
```

### Check the logs of the Airflow scheduler
```shell
kubectl logs ${SCHEDULER_POD_NAME}
```

### Check if there are any issues with the Airflow webserver
```shell
kubectl get pods -l component=webserver
```

### Check the logs of the Airflow webserver
```shell
kubectl logs ${WEBSERVER_POD_NAME}
```

## Repair

### Optimize the Airflow DAGs by splitting larger tasks into smaller ones, to reduce the time taken for execution of individual tasks.
```shell


#!/bin/bash



# Step 1: Connect to the Kubernetes cluster

kubectl config use-context ${CONTEXT_NAME}



# Step 2: Identify the Airflow DAGs that have long running tasks

long_running_dags=$(kubectl get pods -n ${NAMESPACE} -l app=${AIRFLOW_APP_NAME} -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read pod_name; do kubectl logs $pod_name -n ${NAMESPACE} | grep 'Long running task'; done)



# Step 3: Split the tasks into smaller ones

for dag in $long_running_dags; do

    kubectl exec $pod_name -n ${NAMESPACE} -- bash -c "airflow list_tasks ${DAG_NAME} --tree | awk '{ print \$2 }' | grep -v '^$' | while read task_name; do airflow test ${DAG_NAME} $task_name $(date +%Y-%m-%d) ; done"

done


```