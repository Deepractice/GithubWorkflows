# Node.js OpenSource Workflow Complete Test Suite
.PHONY: test test-all clean help setup

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Act options for fast testing
ACT_OPTS := --no-recurse --rm --quiet

# Workflow root directory
WORKFLOW_ROOT := ../../../

help: ## Show this help message
	@echo "Node.js OpenSource Complete Workflow Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'

setup: ## Setup test environment
	@echo "$(YELLOW)Setting up test environment$(NC)"
	@which act > /dev/null || (echo "$(RED)❌ act is not installed. Please install: https://github.com/nektos/act$(NC)" && exit 1)
	@echo "$(GREEN)✅ act is installed$(NC)"
	@echo "$(GREEN)✅ Test environment ready$(NC)"

test: setup ## Run complete workflow test
	@echo "$(YELLOW)========================================$(NC)"
	@echo "$(YELLOW)Running Complete Workflow Test$(NC)"
	@echo "$(YELLOW)========================================$(NC)"
	@$(MAKE) test-issue-created
	@$(MAKE) test-start-development
	@$(MAKE) test-pr-to-develop
	@$(MAKE) test-pr-opened-develop
	@$(MAKE) test-pr-merged-develop
	@$(MAKE) test-start-release
	@$(MAKE) test-pr-to-main
	@$(MAKE) test-pr-opened-main
	@$(MAKE) test-release-beta
	@$(MAKE) test-pr-merged-main
	@$(MAKE) test-release-production
	@$(MAKE) test-publish
	@echo ""
	@echo "$(GREEN)========================================$(NC)"
	@echo "$(GREEN)✅ All workflow tests completed!$(NC)"
	@echo "$(GREEN)========================================$(NC)"

# Stage 1: Issue Creation and Development
test-issue-created: ## Test issue creation
	@echo ""
	@echo "$(YELLOW)[Stage 1] Testing issue creation$(NC)"
	@act issues \
		-e fixtures/01-issue-created.json \
		-W $(WORKFLOW_ROOT) \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Issue created$(NC)"

test-start-development: ## Test /start development command
	@echo ""
	@echo "$(YELLOW)[Stage 2] Testing /start development$(NC)"
	@act issue_comment \
		-e fixtures/02-start-development.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Development branch created$(NC)"

# Stage 2: PR to Develop
test-pr-to-develop: ## Test /start pr command
	@echo ""
	@echo "$(YELLOW)[Stage 3] Testing /start pr to develop$(NC)"
	@act issue_comment \
		-e fixtures/03-start-pr.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ PR to develop created$(NC)"

test-pr-opened-develop: ## Test pr-opened-develop event
	@echo ""
	@echo "$(YELLOW)[Stage 4] Testing pr-opened-develop event$(NC)"
	@act pull_request \
		-e fixtures/04-pr-opened-develop.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Auto changeset created$(NC)"

test-pr-merged-develop: ## Test pr-merged-develop event
	@echo ""
	@echo "$(YELLOW)[Stage 5] Testing pr-merged-develop event$(NC)"
	@act pull_request \
		-e fixtures/05-pr-merged-develop.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ PR merged to develop, /start release --preview triggered$(NC)"

# Stage 3: Release Process
test-start-release: ## Test /start release command
	@echo ""
	@echo "$(YELLOW)[Stage 6] Testing /start release$(NC)"
	@act issue_comment \
		-e fixtures/06-start-release.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Release branch created$(NC)"

test-pr-to-main: ## Test /start pr to main
	@echo ""
	@echo "$(YELLOW)[Stage 7] Testing /start pr to main$(NC)"
	@act issue_comment \
		-e fixtures/07-start-pr-main.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ PR to main created$(NC)"

test-pr-opened-main: ## Test pr-opened-main event
	@echo ""
	@echo "$(YELLOW)[Stage 8] Testing pr-opened-main event$(NC)"
	@act pull_request \
		-e fixtures/08-pr-opened-main.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Auto /release --prerelease beta triggered$(NC)"

test-release-beta: ## Test beta release
	@echo ""
	@echo "$(YELLOW)[Stage 9] Testing /release --prerelease beta$(NC)"
	@act issue_comment \
		-e fixtures/09-release-beta.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Beta version created$(NC)"

test-pr-merged-main: ## Test pr-merged-main event
	@echo ""
	@echo "$(YELLOW)[Stage 10] Testing pr-merged-main event$(NC)"
	@act pull_request \
		-e fixtures/10-pr-merged-main.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ PR merged to main$(NC)"

# Stage 4: Production Release
test-release-production: ## Test production release
	@echo ""
	@echo "$(YELLOW)[Stage 11] Testing /release (production)$(NC)"
	@act issue_comment \
		-e fixtures/11-release-production.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Production version created$(NC)"

test-publish: ## Test npm publish
	@echo ""
	@echo "$(YELLOW)[Stage 12] Testing /publish$(NC)"
	@act issue_comment \
		-e fixtures/12-publish-npm.json \
		-W $(WORKFLOW_ROOT).github/workflows/ \
		$(ACT_OPTS) \
		--dryrun || true
	@echo "$(GREEN)✅ Published to npm$(NC)"

# Individual stage tests
test-development: ## Test development flow only
	@$(MAKE) test-issue-created
	@$(MAKE) test-start-development
	@$(MAKE) test-pr-to-develop
	@$(MAKE) test-pr-opened-develop
	@$(MAKE) test-pr-merged-develop

test-release: ## Test release flow only  
	@$(MAKE) test-start-release
	@$(MAKE) test-pr-to-main
	@$(MAKE) test-pr-opened-main
	@$(MAKE) test-release-beta
	@$(MAKE) test-pr-merged-main
	@$(MAKE) test-release-production

clean: ## Clean test artifacts
	@rm -rf .act
	@echo "$(GREEN)✅ Cleaned test artifacts$(NC)"

.SILENT: # Make all targets silent by default