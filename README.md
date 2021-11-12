Intro
-----
dbt-github-workflow is a boilerplate
that contains all the necessary configurations
to set up a simple CI/CD pipeline for your
data modelling stack, making your life simpler
by adding back a few extra working hours / out of hours.

I will also add some more resources to this project,
feel free to star/follow.


What it does?
-------------
Each time you create a new PR or push to the main branch
the github continuous integration
at .github/workflows/continuous-integration.yml
will
- setup python
- configure a cache to speed up future python package installs
- install the python requirements specified in the requirements.txt
- instatiate the dbt profile by copying the project profiles.yml
  to the github runner home ~/.dbt/ folder
- instantiate the keyfile
- builds the project using `make build <changed.file.list>`
  - runs pre-commit through on changed files
  - runs sqlfluff on the changed files
    (not in pre-commit, for more readable output)
- authenticates on GCS
- deploys the dbt project to composer's dags/dbt folder


Contribute
----------
While this setup is using
- GCP
- BigQuery
- Airflow in GCP Composer

is not tied to it, you can easily amend it to your needs.
Feel free to create a public fork and share back the part
of your setup that can be shared.


Setup
-----
1. Private fork or copy the content of this repository to your project
2. Update the profiles.yml
3. Setup the following environment variables
   - KEYFILE_DIR - where your keyfile.json will get stored
   - GCLOUD_PROJECT - the name of your GCP project
4. Copy/Symlink/Instantiate your keyfile.json,
   it's content is a service account keyfile
   that has at least the following roles in GCP IAM
   - BigQuery Data Owner - for dbt so that it can make changes
   - BigQuery Job User - for dbt so it can run queries
   - BigQuery Read Session User - for dbt so it can create and read sessions
   - Storage Object Admin - in order to be able to upload the dbt project content to Airflow's Composer GCS bucket
5. Setup the following github secrets:
   - SERVICE_ACCOUNT_KEY - contains the actual value of your keyfile.json
   - COMPOSER_BUCKET - contains the bucket id as in gs://BUCKET_ID/dags/
     which belongs to the DAGs folder of your very environment setup in GCP Composer
6. Configure your github project in case you would like to protect the main branch
   at https://github.com/USER/PROJECT/settings/branches
   add a new branch protection rule and configure it to your needs
