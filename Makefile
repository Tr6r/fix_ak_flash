SOURCES   = ./ak_sources

AK_REPO1 = ak-base-kit-stm32l151
AK_URL1  = https://github.com/ak-embedded-software/ak-base-kit-stm32l151

AK_REPO2 = ak-flash
AK_URL2  = https://github.com/ak-embedded-software/ak-flash

all: init
	@echo "START"

init:
	@mkdir -p $(SOURCES)

	@if [ ! -d "$(SOURCES)/$(AK_REPO1)" ]; then \
		echo "Cloning $(AK_REPO1)..."; \
		git clone $(AK_URL1) $(SOURCES)/$(AK_REPO1); \
	fi

	@if [ ! -d "$(SOURCES)/$(AK_REPO2)" ]; then \
		echo "Cloning $(AK_REPO2)..."; \
		git clone $(AK_URL2) $(SOURCES)/$(AK_REPO2); \
	fi

apply: init
	@echo "Apply patch uart_boot"
	@cd $(SOURCES)/$(AK_REPO2)/boot && \
		git apply ../../../patchs/0001-FIX-host-uart-boot.patch
	@cd $(SOURCES)/$(AK_REPO1)/boot && \
		git apply ../../../patchs/0002-ADD-mcu-uart-boot-macro.patch
	@cd $(SOURCES)/$(AK_REPO1)/boot && \
		git apply ../../../patchs/0003-ADD-mcu-reset-fuction.patch
