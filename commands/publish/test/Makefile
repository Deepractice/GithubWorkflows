# Publish command tests using act
.PHONY: test test-npm test-docker test-auto help

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Act options for fast testing
# .actrc will be found automatically from project root
ACT_OPTS := --no-recurse --rm --quiet

help: ## Show this help message
	@echo "Publish Command Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

test: test-npm test-docker test-auto ## Run all tests
	@echo "$(GREEN)✅ All publish tests completed!$(NC)"

test-npm: ## Test npm publishing
	@echo "$(YELLOW)Testing npm publish$(NC)"
	@echo "Test 1: Publish to latest"
	@act issue_comment \
		-e fixtures/publish-npm.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "Test 2: Publish to beta tag"
	@act issue_comment \
		-e fixtures/publish-npm-beta.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-npm-dry: ## Test npm publish dry-run
	@echo "$(YELLOW)Testing npm publish (dry-run)$(NC)"
	@act issue_comment \
		-e fixtures/publish-npm-dryrun.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-docker: ## Test Docker publishing
	@echo "$(YELLOW)Testing Docker publish$(NC)"
	@echo "Test 1: Publish to Docker Hub"
	@act issue_comment \
		-e fixtures/publish-docker.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "Test 2: Publish to ghcr.io"
	@act issue_comment \
		-e fixtures/publish-docker-ghcr.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-docker-dry: ## Test Docker publish dry-run
	@echo "$(YELLOW)Testing Docker publish (dry-run)$(NC)"
	@act issue_comment \
		-e fixtures/publish-docker-dryrun.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-auto: ## Test auto-detection
	@echo "$(YELLOW)Testing auto-detection$(NC)"
	@act issue_comment \
		-e fixtures/publish-auto.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-no-permission: ## Test permission denied
	@echo "$(YELLOW)Testing permission denied$(NC)"
	@act issue_comment \
		-e fixtures/publish-no-permission.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

test-no-release: ## Test without release
	@echo "$(YELLOW)Testing publish without release$(NC)"
	@act issue_comment \
		-e fixtures/publish-no-release.json \
		-W ../ \
		-j handle-publish \
		$(ACT_OPTS) \
		--dryrun

check-act: ## Check if act is installed
	@which act > /dev/null || (echo "❌ act is not installed. Please install: https://github.com/nektos/act" && exit 1)
	@echo "$(GREEN)✅ act is installed$(NC)"

clean: ## Clean test artifacts
	@rm -rf .act
	@echo "$(GREEN)✅ Cleaned test artifacts$(NC)"