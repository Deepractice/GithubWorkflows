# Changeset Command Test Makefile

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Act common options
# .actrc will be found automatically from project root
ACT_OPTS := --env GITHUB_TOKEN=fake-token \
           --no-recurse \
           --rm \
           --dryrun

.PHONY: test test-node test-python test-go test-invalid test-all clean help check-act

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

check-act:
	@if ! command -v act &> /dev/null; then \
		echo "$(RED)act is not installed. Please install it first:$(NC)"; \
		echo "brew install act"; \
		exit 1; \
	fi

test: test-all ## Run all tests (alias for test-all)

test-all: check-act ## Run all workflow tests for all project types
	@echo "$(YELLOW)Testing changeset command for multiple project types$(NC)"
	@echo ""
	@echo "$(GREEN)=== Auto Mode Tests ===$(NC)"
	@$(MAKE) test-auto-default
	@echo ""
	@$(MAKE) test-auto-explicit
	@echo ""
	@$(MAKE) test-auto-with-message
	@echo ""
	@echo "$(GREEN)=== Manual Mode Tests ===$(NC)"
	@$(MAKE) test-node
	@echo ""
	@$(MAKE) test-python
	@echo ""
	@$(MAKE) test-go
	@echo ""
	@echo "$(GREEN)=== Invalid Command Test ===$(NC)"
	@$(MAKE) test-invalid
	@echo ""
	@echo "$(GREEN)✅ All tests completed!$(NC)"

test-node: check-act ## Test Node.js changeset creation
	@echo "$(YELLOW)Testing Node.js changeset$(NC)"
	@echo "Test 1: /changeset patch (Node.js)"
	@act issue_comment -e fixtures/pr-comment-patch.json -W ../changeset.yml $(ACT_OPTS)
	@echo ""
	@echo "Test 2: /changeset minor with message (Node.js)"
	@act issue_comment -e fixtures/pr-comment-minor.json -W ../changeset.yml $(ACT_OPTS)

test-python: check-act ## Test Python changeset creation
	@echo "$(YELLOW)Testing Python changeset$(NC)"
	@echo "Test: /changeset minor (Python)"
	@act issue_comment -e fixtures/pr-comment-python.json -W ../changeset.yml $(ACT_OPTS)

test-go: check-act ## Test Go changeset creation
	@echo "$(YELLOW)Testing Go changeset$(NC)"
	@echo "Test: /changeset patch (Go)"
	@act issue_comment -e fixtures/pr-comment-go.json -W ../changeset.yml $(ACT_OPTS)

test-invalid: check-act ## Test invalid command handling
	@echo "$(YELLOW)Testing invalid command$(NC)"
	@act issue_comment -e fixtures/pr-comment-invalid.json -W ../changeset.yml $(ACT_OPTS)

# Auto mode tests
test-auto-default: check-act ## Test default auto mode (/changeset with no args)
	@echo "$(YELLOW)Testing: /changeset (default auto mode)$(NC)"
	@act issue_comment -e fixtures/pr-comment-auto-default.json -W ../changeset.yml $(ACT_OPTS)

test-auto-explicit: check-act ## Test explicit auto mode (/changeset --auto)
	@echo "$(YELLOW)Testing: /changeset --auto$(NC)"
	@act issue_comment -e fixtures/pr-comment-auto-explicit.json -W ../changeset.yml $(ACT_OPTS)

test-auto-with-message: check-act ## Test auto mode with custom message
	@echo "$(YELLOW)Testing: /changeset --auto Custom message$(NC)"
	@act issue_comment -e fixtures/pr-comment-auto-with-message.json -W ../changeset.yml $(ACT_OPTS)

test-patch: test-node ## Test patch command (alias for Node.js test)

test-minor: test-node ## Test minor command (alias for Node.js test)

clean: ## Clean test artifacts
	@echo "Cleaning test artifacts..."
	@rm -f fixtures/*.log
	@rm -f *.log

install: ## Install act for testing
	@echo "Installing test dependencies..."
	@if ! command -v act >/dev/null 2>&1; then \
		echo "Installing act..."; \
		brew install act; \
	else \
		echo "✓ act is already installed"; \
	fi

# Test specific project types with mock setup
test-with-setup: check-act ## Test with project setup
	@echo "$(YELLOW)Testing with mock project setups$(NC)"
	@echo "This would create temporary project structures for testing"
	@echo "TODO: Implement mock project creation for each language"