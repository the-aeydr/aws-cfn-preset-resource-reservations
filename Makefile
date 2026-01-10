# Sane defaults
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Default params
STACK_NAME ?= aws-cfn-preset-resource-reservations
PARAMETERS ?= 
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# ---------------------- Includes ---------------------------
include $(wildcard $(SELF_DIR)/build/*.mk)

# ---------------------- COMMANDS ---------------------------

.PHONY: cfn-init
cfn-init: # Initialize a CloudFormation Stack with no resources 
	@aws cloudformation deploy \
		--template-file cloudformation/01-empty/stack.yaml.template \
		--stack-name $(STACK_NAME)

.PHONY: cfn-describe
cfn-describe: # Describe the CloudFormation stack
	@aws cloudformation describe-stacks \
		--query 'Stacks[0].[StackName, Outputs]' \
		--stack-name $(STACK_NAME) \
		--output table

.PHONY: cfn-destroy
cfn-destroy: # Teardown the CloudFormation stack 
	@aws cloudformation delete-stack \
		--stack-name $(STACK_NAME)

.PHONY: cfn-mapping
cfn-mapping: # Provision a CloudFormation Stack with Presets
	@time=$$(date +'%Y%m%d%H%M%S')
	@tmpfile=$$(mktemp)
	@cp cloudformation/02-paths/stack.yaml.template $$tmpfile
	@sed -i.bak "s/WaitHandle/WaitHandle$${time}/" $$tmpfile

	$(if $(PARAMETERS),$(info Deploying with parameter overrides: $(PARAMETERS)),)
	aws cloudformation deploy $(if $(PARAMETERS),--parameter-overrides $(PARAMETERS),) \
		--template-file $$tmpfile \
		--stack-name $(STACK_NAME)

	@sleep 5

	aws cloudformation describe-stacks \
		--query 'Stacks[0].Outputs' \
		--stack-name $(STACK_NAME)

.PHONY: cfn-overrides
cfn-overrides: # Enable overrides for the presets of the CloudFormation Stack
	@template="cloudformation/03-overrides/stack.yaml.template"
	@time=$$(date +'%Y%m%d%H%M%S')
	@tmpfile=$$(mktemp)
	@cp $$template $$tmpfile
	@sed -i.bak "s/WaitHandle/WaitHandle$${time}/" $$tmpfile

	$(if $(PARAMETERS),$(info Deploying with parameter overrides: $(PARAMETERS)),)
	aws cloudformation deploy $(if $(PARAMETERS),--parameter-overrides $(PARAMETERS),) \
		--template-file $$tmpfile \
		--stack-name $(STACK_NAME)

	@sleep 5

	aws cloudformation describe-stacks \
		--query 'Stacks[0].Outputs' \
		--stack-name $(STACK_NAME)
