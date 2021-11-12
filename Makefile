SHELL = /bin/bash
.DEFAULT_GOAL := help

.PHONY: help build

# If the first argument is "run"...
ifeq (build,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

build: pre-commit-no-lint lint deploy-dev-db ## Run pre-commit and lint separately on files provided

.ONESHELL:
pre-commit: ## Run pre-commit on all files
	pre-commit run --all-files

pre-commit-no-lint: ## Run pre-commit on all files, skipping sqlfluff-lint
	SKIP=sqlfluff-lint pre-commit run --all-files

lint: ## Lint sql files
	for i in $(RUN_ARGS) ; \
		do echo echo $$i ; \
		echo sqlfluff lint $$i; \
	done | parallel -k -j 10 2>&1 | grep -v '^==='

lint-all: ## Lint all sql files
	for i in macros/*.sql models/**/*.sql ; \
		do echo echo $$i ; \
		echo sqlfluff lint $$i; \
	done | parallel -k -j 10 2>&1 | grep -v '^==='

deploy-dev-db: ## Deploys models to dev database
	# try it 3 times in case of new incremental model with self reference
	# use smart reruns later on when available
	# https://github.com/dbt-labs/dbt-core/pull/4017
	dbt run --target dev || dbt run --target dev || dbt run --target dev

deploy: ## Deploy models and manifests to Airflow GCS bucket
	dbt compile
	gsutil cp target/manifest.json gs://$$COMPOSER_BUCKET/dags/dbt/target/manifest.json
	gsutil -m rsync -r -d -x '.*\.pyc$$|.git/.*|.github/.*|^dbt_modules/|^target/.*|^logs/.*|README.md' . gs://$$COMPOSER_BUCKET/dags/dbt
	# gsutil -m rsync -r ./dbt_modules/dbt_utils/macros gs://$$COMPOSER_BUCKET/dags/dbt/dbt_modules/dbt_utils/macros
	# gsutil cp ./dbt_modules/dbt_utils/dbt_project.yml gs://$$COMPOSER_BUCKET/dags/dbt/dbt_modules/dbt_utils/dbt_project.yml

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
