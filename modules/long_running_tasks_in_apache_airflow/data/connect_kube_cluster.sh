

#!/bin/bash



# Step 1: Connect to the Kubernetes cluster

kubectl config use-context ${CONTEXT_NAME}



# Step 2: Identify the Airflow DAGs that have long running tasks

long_running_dags=$(kubectl get pods -n ${NAMESPACE} -l app=${AIRFLOW_APP_NAME} -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read pod_name; do kubectl logs $pod_name -n ${NAMESPACE} | grep 'Long running task'; done)



# Step 3: Split the tasks into smaller ones

for dag in $long_running_dags; do

    kubectl exec $pod_name -n ${NAMESPACE} -- bash -c "airflow list_tasks ${DAG_NAME} --tree | awk '{ print \$2 }' | grep -v '^$' | while read task_name; do airflow test ${DAG_NAME} $task_name $(date +%Y-%m-%d) ; done"

done