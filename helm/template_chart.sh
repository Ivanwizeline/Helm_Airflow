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
echo "deploying ariflow_2 production"
# source ../environment/production/set-env.sh
export VALUES_FILE='../environment/production/values.production.yml'
export SECRET_FILE='../secrets/production/secret.yml'
export SECRET_FILE_LOGGING='../secrets/production/log-aws-secret.yml'
elif [[ $env_to_deploy == 'staging' ]]
then
echo "deploying ariflow_2 staging"
# source ../environment/staging/set-env.sh
export VALUES_FILE='../environment/staging/values.staging.yml'
export SECRET_FILE='../secrets/staging/secret.yml'
export SECRET_FILE_LOGGING='../secrets/staging/log-aws-secret.yml'
else
echo "deploying ariflow_2 development"
# source ../environment/development/set-env.sh
export VALUES_FILE='../environment/development/values.development.yml'
export SECRET_FILE='../secrets/development/secret.yml'
export SECRET_FILE_LOGGING='../secrets/development/log-aws-secret.yml'
fi


#spins up airflow cluster!

if [[ $env_to_deploy == 'development' ]]
then
export AWS_LOG_CONN="
{   airflow:
    {
        connections: [
                            {
                                id: airflow_aws_logging,
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
helm template $RELEASE_NAME ../charts/airflow/ --namespace $NAMESPACE --version $CHART_VERSION \
--set "airflow.config.AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
--values <(echo $AWS_LOG_CONN ) \
--values $VALUES_FILE >> install.yaml
else
#spins up airflow cluster staging and prod!
helm template $RELEASE_NAME ../charts/airflow/ --namespace $NAMESPACE --version $CHART_VERSION --values $VALUES_FILE >> install.yaml
fi

#echo pods status (started/init)
# kubectl get pods -o wide  --namespace $NAMESPACE
#| grep data-airflow-2-web


#kubectl create secret generic airflow-ssh-git-secret --from-file=id_rsa=$HOME/.ssh/id_ed25519 --namespace $NAMESPACE
