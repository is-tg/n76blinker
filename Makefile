# --- Configuration ---
CC = sdcc
MAKEBIN = makebin
CFLAGS = -mmcs51 --model-small --iram-size 256 --xram-size 768 --code-size 18432

# https://github.com/frank-zago/nvtispflash.git 🙏
ISP_TOOL = nvtispflash

BUILD_DIR = bin
TARGET = main

# --- Build Rules ---

# Default: Go straight to flashing
all: flash

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 1. Compile C to IHX
$(BUILD_DIR)/$(TARGET).ihx: main.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@

# 2. Convert IHX to Binary
$(BUILD_DIR)/aprom.bin: $(BUILD_DIR)/$(TARGET).ihx
	$(MAKEBIN) -p $< $@

# 3. Memory Usage Report
size: $(BUILD_DIR)/$(TARGET).ihx
	@echo "--- Memory Usage ---"
	@grep "ROM/EPROM/FLASH" $(BUILD_DIR)/$(TARGET).mem | awk '{printf "Used: %d bytes\nLeft: %d bytes\nUsage: %.1f%%\n", $$4, $$5-$$4, ($$4/$$5)*100}'

# --- Action Targets ---

# Flash the board (Depends on binary and size report)
flash: $(BUILD_DIR)/aprom.bin size
	@echo -n "Proceed with flash? [y/N] " && read ans && \
	if [ "$$ans" = "y" ]; then \
		$(ISP_TOOL) -a $(BUILD_DIR)/aprom.bin; \
	else \
		echo "Flash aborted."; \
	fi

clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned build files."

.PHONY: all flash clean size
