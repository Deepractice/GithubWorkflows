# Release command tests using act
.PHONY: test test-release test-prerelease test-preview test-graduate help

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Act options for fast testing
# .actrc will be found automatically from project root
ACT_OPTS := --no-recurse --rm --quiet

help: ## Show this help message
	@echo "Release Command Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

test: test-preview test-prerelease test-graduate test-release ## Run all tests
	@echo "$(GREEN)✅ All release tests completed!$(NC)"

test-preview: ## Test preview mode
	@echo "$(YELLOW)Testing preview mode$(NC)"
	@act issue_comment \
		-e fixtures/release-preview.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun

test-prerelease: ## Test prerelease creation
	@echo "$(YELLOW)Testing prerelease (beta)$(NC)"
	@act issue_comment \
		-e fixtures/release-beta.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(YELLOW)Testing prerelease (alpha)$(NC)"
	@act issue_comment \
		-e fixtures/release-alpha.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun

test-graduate: ## Test graduate to stable
	@echo "$(YELLOW)Testing graduate from prerelease to stable$(NC)"
	@act issue_comment \
		-e fixtures/release-graduate.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun

test-release: ## Test stable release
	@echo "$(YELLOW)Testing stable release$(NC)"
	@act issue_comment \
		-e fixtures/release-stable.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun

test-no-changesets: ## Test release without changesets
	@echo "$(YELLOW)Testing release without changesets$(NC)"
	@act issue_comment \
		-e fixtures/release-no-changesets.json \
		-W ../ \
		-j handle-release \
		$(ACT_OPTS) \
		--dryrun

check-act: ## Check if act is installed
	@which act > /dev/null || (echo "❌ act is not installed. Please install: https://github.com/nektos/act" && exit 1)
	@echo "$(GREEN)✅ act is installed$(NC)"

clean: ## Clean test artifacts
	@rm -rf .act
	@echo "$(GREEN)✅ Cleaned test artifacts$(NC)"