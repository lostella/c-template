# Generic Makefile for C projects (cargo-like)

ifndef RELEASE
	RELEASE := 0
endif

ifneq ($(RELEASE),0)
	RELEASE := 1
else
	RELEASE := 0
endif

# Project structure
SRC_DIR := src
BIN_DIR := $(SRC_DIR)/bin
TEST_DIR := tests
INCLUDE_DIR := include

# Build locations
ifeq ($(RELEASE),1)
	BUILD_DIR := build/release
else
	BUILD_DIR := build/debug
endif
OBJ_DIR := $(BUILD_DIR)/obj
BIN_OUTPUT_DIR := $(BUILD_DIR)/bin
TEST_OUTPUT_DIR := $(BUILD_DIR)/tests

# Compiler settings
CC := gcc
CFLAGS := -Wall -Wextra -std=c11 -I$(INCLUDE_DIR) -I$(SRC_DIR)
LDFLAGS := 
LIBS := 

# Release/debug flags
ifeq ($(RELEASE), 1)
    CFLAGS += -O2 -DNDEBUG
else
    CFLAGS += -g -O0 -DDEBUG
endif

# Auto-discover source files
LIB_SOURCES := $(filter-out $(wildcard $(BIN_DIR)/*.c), $(wildcard $(SRC_DIR)/*.c))
BIN_SOURCES := $(wildcard $(BIN_DIR)/*.c)
TEST_SOURCES := $(wildcard $(TEST_DIR)/*.c)

# Generate object files
LIB_OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(LIB_SOURCES))
BIN_OBJECTS := $(patsubst $(BIN_DIR)/%.c,$(OBJ_DIR)/bin/%.o,$(BIN_SOURCES))
TEST_OBJECTS := $(patsubst $(TEST_DIR)/%.c,$(OBJ_DIR)/tests/%.o,$(TEST_SOURCES))

# Generate binary targets
BINARIES := $(patsubst $(BIN_DIR)/%.c,$(BIN_OUTPUT_DIR)/%,$(BIN_SOURCES))
TESTS := $(patsubst $(TEST_DIR)/%.c,$(TEST_OUTPUT_DIR)/%,$(TEST_SOURCES))

.PHONY: all build run test clean help

# Default target
all: build

# Build all targets
build: $(BINARIES) $(TESTS)
	@echo "Build ($(BUILD_DIR)) complete!"
	@echo "Binaries: $(notdir $(BINARIES))"
	@echo "Tests: $(notdir $(TESTS))"

# Compile library objects
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@echo "Compiling $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# Compile binary objects
$(OBJ_DIR)/bin/%.o: $(BIN_DIR)/%.c | $(OBJ_DIR)/bin
	@echo "Compiling $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# Compile test objects
$(OBJ_DIR)/tests/%.o: $(TEST_DIR)/%.c | $(OBJ_DIR)/tests
	@echo "Compiling $<"
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# Link binaries
$(BIN_OUTPUT_DIR)/%: $(OBJ_DIR)/bin/%.o $(LIB_OBJECTS) | $(BIN_OUTPUT_DIR)
	@echo "Linking $@"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

# Link tests
$(TEST_OUTPUT_DIR)/%: $(OBJ_DIR)/tests/%.o $(LIB_OBJECTS) | $(TEST_OUTPUT_DIR)
	@echo "Linking $@"
	@$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

# Run all tests
test: $(TESTS)
	@echo "Running tests..."
	@for test in $(TESTS); do \
		echo "Running $$(basename $$test)"; \
		./$$test || exit 1; \
	done
	@echo "All tests passed!"

# Create necessary directories
$(OBJ_DIR) $(OBJ_DIR)/bin $(OBJ_DIR)/tests $(BIN_OUTPUT_DIR) $(TEST_OUTPUT_DIR):
	@mkdir -p $@

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Help target
help:
	@echo "Available targets:"
	@echo "  make build          - Build all binaries and tests"
	@echo "  make test           - Run all tests"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Available binaries: $(notdir $(BINARIES))"
	@echo "Available tests: $(notdir $(TESTS))"
