#!/bin/bash
set -e

case "$1" in
-h | --help | ?)
  echo "Usage: <algorithm type> <data structure> <dataset name> <api name>"
  echo "1st argument: type of algorithm: [classification/regression]"
  echo "2nd argument: type of data structure: [dataframe/rdd]"
  echo "3rd argument: name of dataset: e.g. epsilon"
  echo "4th argument: name of API: e.g. fit"
  exit 0
  ;;
esac

if [ $# -ne 4 ]; then
  echo "please input 3 arguments: <algorithm type> <data structure> <dataset name> <api name>"
  echo "1st argument: type of algorithm: [classification/regression]"
  echo "2nd argument: type of data structure: [dataframe/rdd]"
  echo "3rd argument: name of dataset: e.g. epsilon"
  echo "4th argument: name of API: e.g. fit"
  exit 0
fi


source conf/ml/gbdt/gbdt_spark.properties

algorithm_type=$1
data_structure=$2
dataset_name=$3
api_name=$4
cpu_name=$(lscpu | grep Architecture | awk '{print $2}')

model_conf=${algorithm_type}-${data_structure}-${dataset_name}-${api_name}-${cpu_name}

# concatnate strings as a new variable
num_executors="numExectuors"
executor_cores=${dataset_name}"_executorCores_"${cpu_name}
executor_memory="executorMemory"
extra_java_options="extraJavaOptions"
driver_cores="driverCores"
driver_memory="driverMemory"
master_="master"
deploy_mode="deployMode"

num_executors_val=${!num_executors}
executor_cores_val=${!executor_cores}
executor_memory_val=${!executor_memory}
extra_java_options_val=${!extra_java_options}
driver_cores_val=${!driver_cores}
driver_memory_val=${!driver_memory}
master_val=${!master_}
deploy_mode_val=${!deploy_mode}

echo ${cpu_name}
echo "${master_} : ${master_val}"
echo "${deploy_mode} : ${deploy_mode_val}"
echo "${driver_cores} : ${driver_cores_val}"
echo "${driver_memory} : ${driver_memory_val}"
echo "${num_executors} : ${num_executors_val}"
echo "${executor_cores}: ${executor_cores_val}"
echo "${executor_memory} : ${executor_memory_val}"
echo "${extra_java_options} : ${extra_java_options_val}"

if [ ! ${num_executors_val} ] \
    || [ ! ${executor_cores_val} ] \
    || [ ! ${executor_memory_val} ] \
    || [ ! ${extra_java_options_val} ] \
    || [ ! ${driver_cores_val} ] \
    || [ ! ${driver_memory_val} ] \
    || [ ! ${master_val} ]; then
  echo "Some values are NULL, please confirm with the property files"
  exit 0
fi


source conf/ml/ml_datasets.properties
spark_version=sparkVersion
spark_version_val=${!spark_version}
data_path=${!dataset_name}

echo "${dataset_name} : ${data_path}"
echo "start to submit spark jobs"

echo "start to clean cache and sleep 30s"
ssh server1 "echo 3 > /proc/sys/vm/drop_caches"
ssh agent1 "echo 3 > /proc/sys/vm/drop_caches"
ssh agent2 "echo 3 > /proc/sys/vm/drop_caches"
ssh agent3 "echo 3 > /proc/sys/vm/drop_caches"
sleep 30

mkdir -p log
spark-submit \
--class com.bigdata.ml.GBDTRunner \
--deploy-mode ${deploy_mode_val} \
--driver-cores ${driver_cores_val} \
--driver-memory ${driver_memory_val} \
--num-executors ${num_executors_val} \
--executor-cores ${executor_cores_val} \
--executor-memory ${executor_memory_val} \
--master ${master_val} \
--conf "spark.executor.extraJavaOptions=${extra_java_options_val}" \
--conf "spark.driver.maxResultSize=256G" \
--jars "lib/fastutil-8.3.1.jar,lib/boostkit-ml-acc_2.11-1.3.0-${spark_version_val}.jar,lib/boostkit-ml-core_2.11-1.3.0-${spark_version_val}.jar,lib/boostkit-ml-kernel-2.11-1.3.0-${spark_version_val}-${cpu_name}.jar" \
--driver-class-path "lib/kal-test_2.11-0.1.jar:lib/fastutil-8.3.1.jar:lib/snakeyaml-1.19.jar:lib/boostkit-ml-acc_2.11-1.3.0-${spark_version_val}.jar:lib/boostkit-ml-core_2.11-1.3.0-${spark_version_val}.jar:lib/boostkit-ml-kernel-2.11-1.3.0-${spark_version_val}-${cpu_name}.jar" \
--conf "spark.executor.extraClassPath=fastutil-8.3.1.jar:boostkit-ml-acc_2.11-1.3.0-${spark_version_val}.jar:boostkit-ml-core_2.11-1.3.0-${spark_version_val}.jar:boostkit-ml-kernel-2.11-1.3.0-${spark_version_val}-${cpu_name}.jar" \
./lib/kal-test_2.11-0.1.jar ${model_conf} ${data_path} | tee ./log/log
