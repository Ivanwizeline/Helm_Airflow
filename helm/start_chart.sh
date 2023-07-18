#!/usr/bin/env bash

export CHART_VERSION='8.6.0'
export NAMESPACE='airflow-2'
export RELEASE_NAME='data-airflow-2'
export AIRFLOW_SECRET='airflow-dags-secrets'
export AIRFLOW_SECRET_LOGGING='log-aws-token'
export HTTP_SECRET='airflow-http-git-secret'
export MY_GIT_TOKEN=$(cat ../token.txt)
export MY_GIT_USERNAME=$(cat ../username.txt)

# Select_environment_to_deploy="USER INPUT"
read -p "Enter environment to deploy (staging, production, development): " env_to_deploy
if [[ $env_to_deploy == 'production' ]]
then
echo "deploying airflow_2 production"
# source ../environment/production/set-env.sh
export VALUES_FILE='../environment/production/values.production.yml'
export SECRET_FILE='../secrets/production/secret.yml'
export SECRET_FILE_LOGGING='../secrets/production/log-aws-secret.yml'
elif [[ $env_to_deploy == 'staging' ]]
then
echo "deploying airflow_2 staging"
# source ../environment/staging/set-env.sh
export VALUES_FILE='../environment/staging/values.staging.yml'
export SECRET_FILE='../secrets/staging/secret.yml'
export SECRET_FILE_LOGGING='../secrets/staging/log-aws-secret.yml'
elif [[ $env_to_deploy == 'development' ]]
then
echo "deploying airflow_2 development"
# source ../environment/development/set-env.sh
export VALUES_FILE='../environment/development/values.development.yml'
export SECRET_FILE='../secrets/development/secret.yml'
#ONLY DEV
#Re-create AWS secrets for logging and connections
echo "Creating dev AWS secret for logging and connections"
envsubst < ../secrets/development/log-aws-secret.yml | kubectl apply -f -
#Re-Create PVC with the Dags local path
echo "Creating PVC for local Dags"
envsubst < ../kubernetes/development/dags_pvc.yml | kubectl apply -f -
else
echo "No correct environment selected"
exit 1
fi

#Check Namespace if not exists create it!
namespace=$(kubectl get namespaces | grep $NAMESPACE)
if [ -z "$namespace" ]
then
echo "creating $NAMESPACE namespace"
kubectl create ns $NAMESPACE
else
echo "$NAMESPACE namespace already in place"
fi

#Check HTTP key if not exists create it!
secrets=$(kubectl get secrets -n $NAMESPACE | grep $HTTP_SECRET)
#echo $secrets
if [ -z "$secrets" ]
then
echo "creating $HTTP_SECRET secret"
kubectl create secret generic \
  airflow-http-git-secret \
  --from-literal=username=$MY_GIT_USERNAME \
  --from-literal=password=$MY_GIT_TOKEN \
  --namespace $NAMESPACE
else
echo "$HTTP_SECRET secret already in place"
fi

#Check airflow-secrets if not exists create it!
air_secrets=$(kubectl get secrets -n $NAMESPACE | grep $AIRFLOW_SECRET)
#echo $air_secrets
if [ -z "$air_secrets" ]
then
echo "creating $AIRFLOW_SECRET secret"
kubectl apply -f $SECRET_FILE
else
echo "$AIRFLOW_SECRET secret already in place re-creating it for $env_to_deploy"
kubectl apply -f $SECRET_FILE
fi

#Check airflow-logging-secrets if not exists create it!
air_secrets=$(kubectl get secrets -n $NAMESPACE | grep $AIRFLOW_SECRET_LOGGING)
#echo $air_secrets
if [[ $env_to_deploy != 'development' ]]
then
echo "creating $AIRFLOW_SECRET_LOGGING secret"
kubectl apply -f $SECRET_FILE_LOGGING
else
echo "$AIRFLOW_SECRET_LOGGING secret already in place"
fi


if [[ $env_to_deploy == 'development' ]]
then
export $AWS_SESSION_TOKEN envsubst
export AWS_LOG_CONN="
{   airflow:
    {
        connections: [
                            {
                                id: airflow_aws_logging,
                                type: aws,
                                extra:
                                    {
                                        aws_session_token: $AWS_SESSION_TOKEN ,
                                        region_name: us-east-1,
                                        profile=default
                                    }
                            }
                        ]
    }
}"

#spins up airflow cluster dev!
helm upgrade -i $RELEASE_NAME ../charts/airflow/ --namespace $NAMESPACE --version $CHART_VERSION \
--set "airflow.config.AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
--set "airflow.config.OKTA_USERNAME=${OKTA_USERNAME}" \
--set "airflow.config.OKTA_PASSWORD=${OKTA_PASSWORD}" \
--set "airflow.config.SNOWFLAKE_ROLE=${SNOWFLAKE_ROLE}" \
--values $VALUES_FILE \
--values <(echo $AWS_LOG_CONN )
else
#spins up airflow cluster staging and prod!
helm upgrade -i $RELEASE_NAME ../charts/airflow/ --namespace $NAMESPACE --version $CHART_VERSION --values $VALUES_FILE
fi
#helm install $RELEASE_NAME ../charts/airflow/ --namespace $NAMESPACE --version $CHART_VERSION --values $VALUES_FILE


#echo pods status (started/init)
kubectl get pods -o wide  --namespace $NAMESPACE -w
#| grep data-airflow-2-web


#kubectl create secret generic airflow-ssh-git-secret --from-file=id_rsa=$HOME/.ssh/id_ed25519 --namespace $NAMESPACE
