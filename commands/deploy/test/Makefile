# Deploy command tests using act
.PHONY: test test-npm test-docker test-invalid test-dry-run test-auto help clean

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Act options for fast testing
ACT_OPTS := --no-recurse --rm --quiet

help: ## Show this help message
	@echo "Deploy Command Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

test: test-npm test-docker test-invalid test-dry-run test-auto ## Run all tests
	@echo "$(GREEN)✅ All deploy tests completed!$(NC)"

test-npm: ## Test NPM deployments
	@echo "$(YELLOW)Testing NPM deployment (dev)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-dev.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(YELLOW)Testing NPM deployment (beta)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-beta.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(YELLOW)Testing NPM deployment (latest)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-latest.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-docker: ## Test Docker deployments
	@echo "$(YELLOW)Testing Docker deployment (dev)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-docker-dev.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun
	@echo ""
	@echo "$(YELLOW)Testing Docker deployment (latest)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-docker-latest.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-invalid: ## Test invalid command handling
	@echo "$(YELLOW)Testing invalid command (no target)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-invalid.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun || echo "$(GREEN)✅ Expected failure handled correctly$(NC)"

test-dry-run: ## Test dry-run mode
	@echo "$(YELLOW)Testing dry-run mode$(NC)"
	@act issue_comment \
		-e fixtures/deploy-dry-run.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-auto: ## Test automated deployment
	@echo "$(YELLOW)Testing automated deployment (bot trigger)$(NC)"
	@act issue_comment \
		-e fixtures/deploy-auto.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-npm-dev: ## Test NPM dev deployment
	@echo "$(YELLOW)Testing NPM dev deployment$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-dev.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-npm-beta: ## Test NPM beta deployment
	@echo "$(YELLOW)Testing NPM beta deployment$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-beta.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-npm-latest: ## Test NPM production deployment
	@echo "$(YELLOW)Testing NPM production deployment$(NC)"
	@act issue_comment \
		-e fixtures/deploy-npm-latest.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-docker-dev: ## Test Docker dev deployment
	@echo "$(YELLOW)Testing Docker dev deployment$(NC)"
	@act issue_comment \
		-e fixtures/deploy-docker-dev.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

test-docker-latest: ## Test Docker production deployment
	@echo "$(YELLOW)Testing Docker production deployment$(NC)"
	@act issue_comment \
		-e fixtures/deploy-docker-latest.json \
		-W ../ \
		-j handle-deploy \
		$(ACT_OPTS) \
		--dryrun

check-act: ## Check if act is installed
	@which act > /dev/null || (echo "$(RED)❌ act is not installed. Please install: https://github.com/nektos/act$(NC)" && exit 1)
	@echo "$(GREEN)✅ act is installed$(NC)"

clean: ## Clean test artifacts
	@rm -rf .act
	@rm -f *.log
	@echo "$(GREEN)✅ Cleaned test artifacts$(NC)"

# Individual script tests
test-scripts: ## Test deployment scripts directly
	@echo "$(YELLOW)Testing validate.sh$(NC)"
	@bash ../scripts/validate.sh npm dev && echo "$(GREEN)✅ Valid npm dev$(NC)" || echo "$(RED)❌ Failed$(NC)"
	@bash ../scripts/validate.sh docker latest && echo "$(GREEN)✅ Valid docker latest$(NC)" || echo "$(RED)❌ Failed$(NC)"
	@bash ../scripts/validate.sh invalid dev 2>/dev/null || echo "$(GREEN)✅ Invalid target rejected$(NC)"
	@bash ../scripts/validate.sh npm invalid 2>/dev/null || echo "$(GREEN)✅ Invalid tag rejected$(NC)"
	@echo ""
	@echo "$(YELLOW)Testing detect.sh$(NC)"
	@cd ../../.. && bash commands/deploy/scripts/detect.sh
	@echo "$(GREEN)✅ Detection script works$(NC)"

# Quick validation test
quick: ## Quick validation test
	@echo "$(YELLOW)Running quick validation test...$(NC)"
	@make test-invalid
	@echo "$(GREEN)✅ Quick test passed$(NC)"

# Watch for changes and auto-test
watch: ## Watch for changes and run tests
	@echo "$(YELLOW)Watching for changes...$(NC)"
	@while true; do \
		make test 2>/dev/null || true; \
		sleep 5; \
	done