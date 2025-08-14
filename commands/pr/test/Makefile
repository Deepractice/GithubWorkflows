# PR Command Test Makefile

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

.PHONY: test test-auto test-source test-target test-title test-draft test-exists test-no-commits help check-act clean

help: ## Show this help
	@echo "PR Command Test Suite"
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
	@echo "$(YELLOW)Testing /pr command$(NC)"
	@echo ""
	@echo "$(GREEN)=== Auto Detection Test ===$(NC)"
	@$(MAKE) test-auto
	@echo ""
	@echo "$(GREEN)=== Source Branch Test ===$(NC)"
	@$(MAKE) test-source
	@echo ""
	@echo "$(GREEN)=== Target Branch Test ===$(NC)"
	@$(MAKE) test-target
	@echo ""
	@echo "$(GREEN)=== Custom Title Test ===$(NC)"
	@$(MAKE) test-title
	@echo ""
	@echo "$(GREEN)=== Draft PR Test ===$(NC)"
	@$(MAKE) test-draft
	@echo ""
	@echo "$(GREEN)=== PR Exists Test ===$(NC)"
	@$(MAKE) test-exists
	@echo ""
	@echo "$(GREEN)=== No Commits Test ===$(NC)"
	@$(MAKE) test-no-commits
	@echo ""
	@echo "$(GREEN)✅ All tests completed!$(NC)"

test-auto: check-act ## Test auto-detection of source and target branches
	@echo "$(YELLOW)Testing: /pr (full auto)$(NC)"
	@act issue_comment \
		-e fixtures/pr-auto.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-source: check-act ## Test with specified source branch
	@echo "$(YELLOW)Testing: /pr --source feature/oauth$(NC)"
	@act issue_comment \
		-e fixtures/pr-source.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-target: check-act ## Test with specified target branch
	@echo "$(YELLOW)Testing: /pr --target main$(NC)"
	@act issue_comment \
		-e fixtures/pr-target.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-title: check-act ## Test with custom title
	@echo "$(YELLOW)Testing: /pr --title \"feat: custom title\"$(NC)"
	@act issue_comment \
		-e fixtures/pr-title.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-draft: check-act ## Test creating draft PR
	@echo "$(YELLOW)Testing: /pr --draft$(NC)"
	@act issue_comment \
		-e fixtures/pr-draft.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-exists: check-act ## Test when PR already exists
	@echo "$(YELLOW)Testing: PR already exists scenario$(NC)"
	@act issue_comment \
		-e fixtures/pr-exists.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-no-commits: check-act ## Test when no commits between branches
	@echo "$(YELLOW)Testing: No commits scenario$(NC)"
	@act issue_comment \
		-e fixtures/pr-no-commits.json \
		-W ../pr.yml \
		-j create-pr \
		$(ACT_OPTS) \
		--dryrun

test-complete: check-act ## Test with all parameters
	@echo "$(YELLOW)Testing: /pr --source feature/#7-issue --target develop --title \"feat: OAuth\" --content \"Custom content\" --draft$(NC)"
	@act issue_comment \
		-e fixtures/pr-complete.json \
		-W ../pr.yml \
		-j create-pr \
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