.PHONY: help install uninstall test clean

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
RESET := \033[0m
BOLD := \033[1m

# Installation paths
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
INSTALL_PATH := $(BINDIR)/ipmgr

##@ General

help: ## Display this help message
	@echo ""
	@echo "$(BOLD)$(CYAN)ipmgr - IP Address Manager$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage:$(RESET)"
	@echo "  make $(GREEN)<target>$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Installation

install: ## Install ipmgr to /usr/local/bin (requires sudo)
	@echo "$(GREEN)Installing ipmgr...$(RESET)"
	@if [ ! -f ipmgr ]; then \
		echo "$(RED)Error: ipmgr script not found$(RESET)"; \
		exit 1; \
	fi
	@sudo install -m 755 ipmgr $(INSTALL_PATH)
	@echo "$(GREEN)✓$(RESET) ipmgr installed to $(CYAN)$(INSTALL_PATH)$(RESET)"
	@echo ""
	@echo "Run '$(BOLD)ipmgr$(RESET)' to get started!"

uninstall: ## Uninstall ipmgr from /usr/local/bin (requires sudo)
	@echo "$(YELLOW)Uninstalling ipmgr...$(RESET)"
	@if [ -f $(INSTALL_PATH) ]; then \
		sudo rm -f $(INSTALL_PATH); \
		echo "$(GREEN)✓$(RESET) ipmgr removed from $(CYAN)$(INSTALL_PATH)$(RESET)"; \
	else \
		echo "$(YELLOW)⚠$(RESET)  ipmgr not found at $(INSTALL_PATH)"; \
	fi

##@ Development

test: ## Run example tests
	@echo "$(CYAN)Running tests...$(RESET)"
	@if [ ! -x ipmgr ]; then chmod +x ipmgr; fi
	@cd example && ./full-demo.sh && ./cleanup-all.sh
	@echo "$(GREEN)✓$(RESET) All tests passed!"

clean: ## Clean up generated files in examples
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	@cd example && ./cleanup-all.sh 2>/dev/null || true
	@rm -f example/.env example/kind.env example/kind-config-generated.yml
	@echo "$(GREEN)✓$(RESET) Cleanup complete"

##@ Information

check: ## Check if ipmgr is installed and show version info
	@echo "$(CYAN)Checking ipmgr installation...$(RESET)"
	@if command -v ipmgr >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(RESET) ipmgr is installed at: $(CYAN)$$(command -v ipmgr)$(RESET)"; \
		echo ""; \
		echo "State file location: $(CYAN)$$HOME/.ipmgr_state$(RESET)"; \
		if [ -f "$$HOME/.ipmgr_state" ]; then \
			echo "State file exists: $(GREEN)Yes$(RESET)"; \
			echo "Current allocations: $$(wc -l < $$HOME/.ipmgr_state) IP(s)"; \
		else \
			echo "State file exists: $(YELLOW)No$(RESET)"; \
		fi; \
	else \
		echo "$(RED)✗$(RESET) ipmgr is not installed"; \
		echo ""; \
		echo "Run '$(BOLD)make install$(RESET)' to install it"; \
	fi

.PHONY: dev-setup
dev-setup: ## Setup development environment (make scripts executable)
	@echo "$(CYAN)Setting up development environment...$(RESET)"
	@chmod +x ipmgr
	@chmod +x example/*.sh
	@echo "$(GREEN)✓$(RESET) All scripts are now executable"
	@echo ""
	@echo "You can now run:"
	@echo "  $(CYAN)./ipmgr$(RESET)           - Run ipmgr locally"
	@echo "  $(CYAN)cd example$(RESET)        - Go to examples directory"
	@echo "  $(CYAN)make install$(RESET)      - Install system-wide"
