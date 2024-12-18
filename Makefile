.PHONY: all docker_image

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BOARD_REPO := $(ROOT_DIR)/boards

PYNQ_ROOT := $(ROOT_DIR)/PYNQ
PYNQ_PREBUILT := $(PYNQ_ROOT)/sdbuild/prebuilt
PYNQ_VERSION := 2.7.0
PYNQ_ARCH := pynq_aarch64_2_7
PYNQ_ARCH_URL := https://bit.ly/$(PYNQ_ARCH)
PYNQ_ARCH_PATH := $(PYNQ_PREBUILT)/$(PYNQ_ARCH)
PYNQ_SDIST := pynq-2.7.0.tar.gz
PYNQ_SDIST_URL := https://github.com/Xilinx/PYNQ/releases/download/v2.7.0/$(PYNQ_SDIST)
PYNQ_SDIST_PATH := $(PYNQ_PREBUILT)/$(PYNQ_SDIST)

all: $(PYNQ_ROOT)/sdbuild/output/$(BOARD)-$(PYNQ_VERSION).img

$(PYNQ_ROOT):
	git clone \
		--single-branch \
		--branch v$(PYNQ_VERSION) \
		https://github.com/Xilinx/PYNQ.git \
		$(PYNQ_ROOT)

$(PYNQ_PREBUILT): $(PYNQ_ROOT)
	mkdir -p $@

$(PYNQ_ARCH_PATH): $(PYNQ_PREBUILT)
	if [ ! -f $(PYNQ_ARCH_PATH) ]; then \
		cd $(PYNQ_PREBUILT) && wget --no-check-certificate $(PYNQ_ARCH_URL); \
	fi

$(PYNQ_SDIST_PATH): $(PYNQ_PREBUILT)
	if [ ! -f $(PYNQ_SDIST_PATH) ]; then \
		cd $(PYNQ_PREBUILT) && wget $(PYNQ_SDIST_URL); \
	fi

$(PYNQ_ROOT)/sdbuild/output/$(BOARD)-$(PYNQ_VERSION).img: $(PYNQ_ROOT) $(PYNQ_ARCH_PATH) $(PYNQ_SDIST_PATH)
	@echo "PYNQ image generation for board $(BOARD) started"
	cd $(PYNQ_ROOT)/sdbuild && \
	make BOARDDIR=$(BOARD_REPO) PREBUILT=$(PYNQ_ARCH_PATH) PYNQ_SDIST=$(PYNQ_SDIST_PATH) BOARDS=$(BOARD)

docker_image:
	docker build -t pynq:v2.7.0 $(ROOT_DIR)