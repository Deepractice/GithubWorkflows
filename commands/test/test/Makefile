# Test Command Test Suite

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Act options
ACT_OPTS := --env GITHUB_TOKEN=fake-token \
           --no-recurse \
           --rm \
           --quiet

.PHONY: test test-all test-unit test-integration test-e2e test-coverage help check-act clean

help: ## Show this help
	@echo "Test Command Test Suite"
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

test: test-commands ## Run all tests

test-commands: check-act ## Test all test command types
	@echo "$(YELLOW)Testing /test command variations$(NC)"
	@echo ""
	@echo "$(GREEN)=== Default (all) Test ===$(NC)"
	@$(MAKE) test-all
	@echo ""
	@echo "$(GREEN)=== Unit Test ===$(NC)"
	@$(MAKE) test-unit
	@echo ""
	@echo "$(GREEN)=== Integration Test ===$(NC)"
	@$(MAKE) test-integration
	@echo ""
	@echo "$(GREEN)=== E2E Test ===$(NC)"
	@$(MAKE) test-e2e
	@echo ""
	@echo "$(GREEN)=== Coverage Test ===$(NC)"
	@$(MAKE) test-coverage
	@echo ""
	@echo "$(GREEN)✅ All test command tests completed!$(NC)"

test-all: check-act ## Test /test (default all)
	@echo "$(YELLOW)Testing: /test$(NC)"
	@act issue_comment \
		-e fixtures/test-all.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun

test-unit: check-act ## Test /test unit
	@echo "$(YELLOW)Testing: /test unit$(NC)"
	@act issue_comment \
		-e fixtures/test-unit.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun

test-integration: check-act ## Test /test integration
	@echo "$(YELLOW)Testing: /test integration$(NC)"
	@act issue_comment \
		-e fixtures/test-integration.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun

test-e2e: check-act ## Test /test e2e
	@echo "$(YELLOW)Testing: /test e2e$(NC)"
	@act issue_comment \
		-e fixtures/test-e2e.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun

test-coverage: check-act ## Test /test coverage
	@echo "$(YELLOW)Testing: /test coverage$(NC)"
	@act issue_comment \
		-e fixtures/test-coverage.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun

test-frameworks: check-act ## Test different framework detection
	@echo "$(YELLOW)Testing framework detection$(NC)"
	@echo ""
	@echo "$(GREEN)=== Node.js Project ===$(NC)"
	@act issue_comment \
		-e fixtures/test-node.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(GREEN)=== Python Project ===$(NC)"
	@act issue_comment \
		-e fixtures/test-python.json \
		-W ../test.yml \
		-j run-tests \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(GREEN)=== Go Project ===$(NC)"
	@act issue_comment \
		-e fixtures/test-go.json \
		-W ../test.yml \
		-j run-tests \
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