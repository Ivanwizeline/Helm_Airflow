#!/usr/bin/env bash

export CHART_VERSION='8.6.0'
export NAMESPACE='airflow-2'
export RELEASE_NAME='data-airflow-2'
export AIRFLOW_SECRET='airflow-dags-secrets'
export AIRFLOW_SECRET_LOGGING='log-aws-token'
export HTTP_SECRET='airflow-http-git-secret'
export MY_GIT_TOKEN=$(cat ../token.txt)
export MY_GIT_USERNAME=$(cat ../username.txt)
export DEV_DAGS_PVC='dags-pvc'
export checker=0

# Select_environment_to_deploy="USER INPUT"
read -p "Enter environment to debug (staging, production, development): " env_to_deploy
if [[ $env_to_deploy == 'production' ]]
then
echo "debugging airflow_2 production:"
# source ../environment/production/set-env.sh
export VALUES_FILE='../environment/production/values.production.yml'
export SECRET_FILE='../secrets/production/secret.yml'
export SECRET_FILE_LOGGING='../secrets/production/log-aws-secret.yml'
elif [[ $env_to_deploy == 'staging' ]]
then
echo "debugging airflow_2 staging:"
# source ../environment/staging/set-env.sh
export VALUES_FILE='../environment/staging/values.staging.yml'
export SECRET_FILE='../secrets/staging/secret.yml'
export SECRET_FILE_LOGGING='../secrets/staging/log-aws-secret.yml'
elif [[ $env_to_deploy == 'development' ]]
then
echo "debugging airflow_2 development:"
# source ../environment/development/set-env.sh
export VALUES_FILE='../environment/development/values.development.yml'
export SECRET_FILE='../secrets/development/secret.yml'
else
echo "No correct environment selected"
exit 1
fi

#Check Namespace if not exists!
namespace=$(kubectl get namespaces | grep $NAMESPACE)
if [ -z "$namespace" ]
then
echo "*** $NAMESPACE namespace is not created"
echo "execute - kubectl create ns $NAMESPACE"
checker=$((checker+1))
fi

#Check HTTP key if not exists!
secrets=$(kubectl get secrets -n $NAMESPACE | grep $HTTP_SECRET)
#echo $secrets
if [ -z "$secrets" ]
then
echo "*** $HTTP_SECRET secret is not created"
echo " execute - kubectl create secret generic airflow-http-git-secret --from-literal=username=$MY_GIT_USERNAME --from-literal=password=$MY_GIT_TOKEN --namespace $NAMESPACE "
checker=$((checker+1))
fi

#Check airflow-secrets if not exists!
air_secrets=$(kubectl get secrets -n $NAMESPACE | grep $AIRFLOW_SECRET)
#echo $air_secrets
if [ -z "$air_secrets" ]
then
echo "*** $AIRFLOW_SECRET secret is not created"
echo "execute - kubectl apply -f $SECRET_FILE"
checker=$((checker+1))
fi

#Check airflow-logging-secrets if not exists!
air_secrets=$(kubectl get secrets -n $NAMESPACE | grep $AIRFLOW_SECRET_LOGGING)
#echo $air_secrets
if [ -z "$air_secrets" ]
then
echo "*** $AIRFLOW_SECRET_LOGGING secret is not created"
echo "If development execute - envsubst < ../secrets/development/log-aws-secret.yml | kubectl apply -f -"
echo "If staging/prod execute - kubectl apply -f $SECRET_FILE_LOGGING"
checker=$((checker+1))
fi

#Check airflow-dags PV & PVC only needed in dev if not exists!
air_secrets=$(kubectl get persistentvolumeclaims -n $NAMESPACE | grep $DEV_DAGS_PVC)
#echo $air_secrets
if [ -z "$air_secrets" ] && [[ $env_to_deploy == 'development' ]]
then
echo "$DEV_DAGS_PVC PVC is not created"
echo "execute - envsubst < ../kubernetes/development/dags_pvc.yml | kubectl apply -f -"
checker=$((checker+1))
fi

if [ "$checker" -eq 0 ]
then
echo "Your set up is correct, if still having problems contact data engineer team"
fi
