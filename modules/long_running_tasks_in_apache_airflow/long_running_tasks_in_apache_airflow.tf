resource "shoreline_notebook" "long_running_tasks_in_apache_airflow" {
  name       = "long_running_tasks_in_apache_airflow"
  data       = file("${path.module}/data/long_running_tasks_in_apache_airflow.json")
  depends_on = [shoreline_action.invoke_connect_kube_cluster]
}

resource "shoreline_file" "connect_kube_cluster" {
  name             = "connect_kube_cluster"
  input_file       = "${path.module}/data/connect_kube_cluster.sh"
  md5              = filemd5("${path.module}/data/connect_kube_cluster.sh")
  description      = "Optimize the Airflow DAGs by splitting larger tasks into smaller ones, to reduce the time taken for execution of individual tasks."
  destination_path = "/tmp/connect_kube_cluster.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_connect_kube_cluster" {
  name        = "invoke_connect_kube_cluster"
  description = "Optimize the Airflow DAGs by splitting larger tasks into smaller ones, to reduce the time taken for execution of individual tasks."
  command     = "`chmod +x /tmp/connect_kube_cluster.sh && /tmp/connect_kube_cluster.sh`"
  params      = ["DAG_NAME","CONTEXT_NAME","AIRFLOW_APP_NAME","NAMESPACE"]
  file_deps   = ["connect_kube_cluster"]
  enabled     = true
  depends_on  = [shoreline_file.connect_kube_cluster]
}

