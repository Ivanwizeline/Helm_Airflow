# AIRFLOW 2

Helm chart base on: https://github.com/airflow-helm/charts
Quick guide: https://artifacthub.io/packages/helm/airflow-helm/airflow/8.1.3

## HOW TO SPIN UP AIRFLOW CLUSTER. DEVELOPMENT
### 1) Pull earnest's latest airflow_2 image on your local
    docker pull earnest/airflow_2:2.2.5.3-24ed9a4-linux-amd64
### 2) Install helm
    brew install helm
### 4) make sure K8S is running and kubectl available (use docker kubernetes if possible)
    kubectl version
### 5) Create Environment variables for AWS, Snowflake and DAGSPATH
### 5.1) Create AWS credentials
    saml2aws login -a dev (use the alias you created for authentification, leave '-a default' for default alias)
### 5.2) Export AWS credential to target enviroment variables
    export AWS_PROFILE='default'
    export AWS_ACCESS_KEY_ID=$(aws configure get $AWS_PROFILE.aws_access_key_id)
    export AWS_SECRET_ACCESS_KEY=$(aws configure get $AWS_PROFILE.aws_secret_access_key)
    export AWS_SESSION_TOKEN=$(aws configure get $AWS_PROFILE.aws_session_token)
### 5.3) Export Snowflake Credentials
    export OKTA_USERNAME=''
    export OKTA_PASSWORD=''
    export SNOWFLAKE_ROLE='dna_data_engineer' (Use your assigned role- ask  engineer data team)
### 5.3) Export Dags repo Path, (dags folder path of the repository clone)
    export DAGS_PATH="/Users/ivan.pachon/Documents/Earnest/Airflow_1_10/data-airflow-dags/dags" (Use your own local path)
### 6) in pwd: ./helm
### 6.1) Run start script and select development
    $ ./start_chart.sh
    input --> development
### 6.2) Wait until all pods are running
    if anny errors appear please go to the debugging section or contact data engineer team.
### 7) re-check pods status, all pods should be running:
    kubectl get pods -o wide  --namespace airflow-2
### 8) Expose port 8080 to connect to webserver
    kubectl port-forward svc/data-airflow-2-web 8080:8080 --namespace airflow-2

## HOW TO SPIN UP AIRFLOW CLUSTER. PRODUCTION/STAGING
### 1) Pull earnest's latest airflow_2 image on your local
    docker pull earnest/airflow_2:2.2.5.3-24ed9a4-linux-amd64
### 2) Install helm
    brew install helm
### 4) make sure K8S is running and kubectl available (use docker kubernetes if possible)
    kubectl version
### 5) Create HTTP key and store it in token.txt at the base of the repo
    cat ./token.txt && ./username.txt
### 6) in pwd: ./helm
### 6.1) Run start script and select staging or production
    $ ./start_chart.sh
    input --> staging/production
### 6.2) Wait until all pods are running
    if anny errors appear please go to the debugging section or contact data engineer team.
### 7) re-check pods status, all pods should be running:
    kubectl get pods -o wide  --namespace airflow-2
### 8) Expose port 8080 to connect to webserver
    kubectl port-forward svc/data-airflow-2-web 8080:8080 --namespace airflow-2

## TAKE DOWN SERVICE
### run
    $ helm uninstall data-airflow-2 -n airflow-2

## DEBUGGING PODS
### run ./debug.sh to get info of your set up
    $ ./debug.sh
    input --> development/staging/production
### run and store yml file in the output errors folder
    kubectl get pod $data-airflow-2-"POD-NAME" --output=yaml --namespace $NAMESPACE > ./output_errors/output_error_$POD_NAME.yml
## ex:
    kubectl get pod data-airflow-2-sync-users-844f485476-tbp5c  --output=yaml --namespace $NAMESPACE > ./output_errors/output_error_data-airflow-2-sync-users.yml
