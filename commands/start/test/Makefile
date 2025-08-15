# Start Command Test Makefile

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Act common options
ACT_OPTS := --env GITHUB_TOKEN=fake-token \
           --no-recurse \
           --rm \
           --quiet

.PHONY: test test-basic test-from-branch test-chinese test-bug test-exists help check-act clean

help: ## Show this help
	@echo "Start Command Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

check-act:
	@if ! command -v act &> /dev/null; then \
		echo "$(RED)act is not installed. Please install it first:$(NC)"; \
		echo "brew install act"; \
		exit 1; \
	fi

test: test-all ## Run all tests (alias for test-all)

test-all: check-act ## Run all workflow tests
	@echo "$(YELLOW)Testing /start commands$(NC)"
	@echo ""
	@echo "$(GREEN)=== Development Mode Tests ===$(NC)"
	@$(MAKE) test-dev-basic
	@echo ""
	@$(MAKE) test-dev-with-issue
	@echo ""
	@$(MAKE) test-dev-from-branch
	@echo ""
	@echo "$(GREEN)=== Release Mode Tests ===$(NC)"
	@$(MAKE) test-release-basic
	@echo ""
	@$(MAKE) test-release-with-version
	@echo ""
	@$(MAKE) test-release-no-changesets
	@echo ""
	@echo "$(GREEN)=== Legacy Tests (Backward Compatibility) ===$(NC)"
	@$(MAKE) test-basic
	@echo ""
	@$(MAKE) test-exists
	@echo ""
	@echo "$(GREEN)✅ All tests completed!$(NC)"

test-basic: check-act ## Test basic /start issue command
	@echo "$(YELLOW)Testing: /start issue 123$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-basic.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

test-from-branch: check-act ## Test with --from-branch parameter
	@echo "$(YELLOW)Testing: /start issue 456 --from-branch develop$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-from-branch.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

test-chinese: check-act ## Test with Chinese title
	@echo "$(YELLOW)Testing: Chinese title handling$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-chinese.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

test-bug: check-act ## Test bug type issue
	@echo "$(YELLOW)Testing: Bug type with fix prefix$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-bug.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

test-exists: check-act ## Test when branch already exists
	@echo "$(YELLOW)Testing: Branch already exists scenario$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-exists.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

test-invalid: check-act ## Test invalid command format
	@echo "$(YELLOW)Testing: Invalid command format$(NC)"
	@act issue_comment \
		-e fixtures/start-issue-invalid.json \
		-W ../start.yml \
		-j start-issue \
		$(ACT_OPTS) \
		--dryrun

# Development mode tests
test-dev-basic: check-act ## Test basic /start development
	@echo "$(YELLOW)Testing: /start development$(NC)"
	@act issue_comment \
		-e fixtures/start-dev-basic.json \
		-W ../start.yml \
		-j start-development \
		$(ACT_OPTS) \
		--dryrun

test-dev-with-issue: check-act ## Test /start development with issue number
	@echo "$(YELLOW)Testing: /start development #123$(NC)"
	@act issue_comment \
		-e fixtures/start-dev-with-issue.json \
		-W ../start.yml \
		-j start-development \
		$(ACT_OPTS) \
		--dryrun

test-dev-from-branch: check-act ## Test /start development with custom branch
	@echo "$(YELLOW)Testing: /start development --from-branch main$(NC)"
	@act issue_comment \
		-e fixtures/start-dev-from-branch.json \
		-W ../start.yml \
		-j start-development \
		$(ACT_OPTS) \
		--dryrun

# Release mode tests  
test-release-basic: check-act ## Test basic /start release
	@echo "$(YELLOW)Testing: /start release$(NC)"
	@act issue_comment \
		-e fixtures/start-release-basic.json \
		-W ../start.yml \
		-j start-release \
		$(ACT_OPTS) \
		--dryrun

test-release-with-version: check-act ## Test /start release with version
	@echo "$(YELLOW)Testing: /start release 1.2.0$(NC)"
	@act issue_comment \
		-e fixtures/start-release-with-version.json \
		-W ../start.yml \
		-j start-release \
		$(ACT_OPTS) \
		--dryrun

test-release-no-changesets: check-act ## Test /start release without changesets
	@echo "$(YELLOW)Testing: /start release (no changesets)$(NC)"
	@act issue_comment \
		-e fixtures/start-release-no-changesets.json \
		-W ../start.yml \
		-j start-release \
		$(ACT_OPTS) \
		--dryrun

clean: ## Clean test artifacts
	@echo "Cleaning test artifacts..."
	@rm -f fixtures/*.log
	@rm -f *.log
	@rm -rf .act

install: ## Install act for testing
	@echo "Installing test dependencies..."
	@if ! command -v act >/dev/null 2>&1; then \
		echo "Installing act..."; \
		brew install act; \
	else \
		echo "✓ act is already installed"; \
	fi