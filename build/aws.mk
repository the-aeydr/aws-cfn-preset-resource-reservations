AWS_SSO_URL ?= ""
AWS_SSO_REGION ?= ""
AWS_SSO_ACCOUNT_ID ?= ""
AWS_SSO_ROLE_NAME ?= ""
AWS_REGION ?= ""

# ----------------- SSO Environment variables  --------------------------

.PHONY: aws
aws: # Login to AWS using AWS SSO
	@aws sso login --no-browser

.PHONY: aws-setup
aws-setup: env-AWS_SSO_URL env-AWS_SSO_REGION env-AWS_SSO_ACCOUNT_ID env-AWS_SSO_ROLE_NAME env-AWS_REGION # Setup the AWS SSO Configuration file by environment variables
	@echo Copying ~/.aws/config to backup file as ~/.aws/config.bak if exists
	@mv ~/.aws/config ~/.aws/config.bak 2>/dev/null || true

	@mkdir -p ~/.aws/
	@touch ~/.aws/config
	@echo "[default]" >> ~/.aws/config
	@echo "sso_start_url = $(AWS_SSO_URL)" >> ~/.aws/config
	@echo "sso_region = $(AWS_SSO_REGION)" >> ~/.aws/config
	@echo "sso_account_id = $(AWS_SSO_ACCOUNT_ID)" >> ~/.aws/config
	@echo "sso_role_name = $(AWS_SSO_ROLE_NAME)" >> ~/.aws/config
	@echo "region = $(AWS_REGION)" >> ~/.aws/config
	@echo "output = json" >> ~/.aws/config

	aws sso login --no-browser

# ----------------- SSO Environment variables  --------------------------
env-AWS_SSO_URL: # [CHECK] Checks for the env variable AWS_SSO_URL
	@if test -z ${AWS_SSO_URL}; then echo -e "${ERR}$(ERR_MISSING_AWS_SSO_URL)${NC}"; exit 240; fi

env-AWS_SSO_REGION: # [CHECK] Checks for the env variable AWS_SSO_REGION
	@if test -z ${AWS_SSO_REGION}; then echo -e "${ERR}$(ERR_MISSING_AWS_SSO_REGION)${NC}"; exit 241; fi

env-AWS_SSO_ACCOUNT_ID: # [CHECK] Checks for the env variable AWS_SSO_ACCOUNT_ID
	@if test -z ${AWS_SSO_ACCOUNT_ID}; then echo -e "${ERR}$(ERR_MISSING_AWS_SSO_ACCOUNT_ID)${NC}"; exit 242; fi

env-AWS_SSO_ROLE_NAME: # [CHECK] Checks for the env variable AWS_SSO_ROLE_NAME
	@if test -z ${AWS_SSO_ROLE_NAME}; then echo -e "${ERR}$(ERR_MISSING_AWS_SSO_ROLE_NAME)${NC}"; exit 243; fi

env-AWS_REGION: # [CHECK] Checks for the env variable AWS_REGION
	@if test -z ${AWS_REGION}; then echo -e "${ERR}$(ERR_MISSING_AWS_REGION)${NC}"; exit 244; fi

# ----------------- Error Messages --------------------------
define ERR_MISSING_AWS_SSO_URL
The environment variable 'AWS_SSO_URL' must be defined.

This is the URL that points to the organization's AWS access portal.
The AWS CLI uses this URL to establish a session with the IAM Identity Center service to authenticate its users.
endef
define ERR_MISSING_AWS_SSO_REGION
The environment variable 'AWS_SSO_REGION' must be defined.

Specifies the AWS Region that contains the AWS access portal host.
This is separate from, and can be a different Region than the default CLI region parameter.
endef
define ERR_MISSING_AWS_SSO_ACCOUNT_ID
The environment variable 'AWS_SSO_ACCOUNT_ID' must be defined.

Specifies the AWS account ID that contains the IAM role with the permission that
you want to grant to the associated IAM Identity Center user.
endef
define ERR_MISSING_AWS_SSO_ROLE_NAME
The environment variable 'AWS_SSO_ROLE_NAME' must be defined.

Specifies the friendly name of the IAM role that defines the user's permissions when using this profile.
endef
define ERR_MISSING_AWS_REGION
The environment variable 'AWS_REGION' must be defined.

Specifies the AWS Region to send requests to for commands requested using this profile.
endef