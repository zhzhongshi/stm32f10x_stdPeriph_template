PROJECT = LEDBlink
# MCU
MCU = cortex-m3
DBG = -g3
# Optimisation level
OPT = #-Os

#####BEGIN MODIFY#####
# Linker script file
LINKER = stm32f1x_64KB_flash.ld
# Startup assembly source file
STARTUP = startup_stm32f10x_md.s
# C definations
DEFINES = \
STM32F10X_MD \
USE_STDPERIPH_DRIVER

# Include directories
INCDIR = \
inc \
Driver/inc


# Add all source files from src/ directory
SRC_FILES = $(wildcard Driver/src/*.c) \
$(wildcard src/*.c)

#####END MODIFY#####
#####################################################################
#                              TOOLS                                #
#####################################################################
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
GDB = $(PREFIX)gdb
CP = $(PREFIX)objcopy
AS = $(PREFIX)gcc -x assembler-with-cpp
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S


#####################################################################
#                      DEFAULT DIRECTORIES                          #
#####################################################################
# Object Files
OBJ_DIR = obj
BUILD_DIR = build
LIBDIR = lib


DEFS = $(patsubst %,-D%, $(DEFINES))
# Header file
INC = $(patsubst %,-I%, $(INCDIR))
# Library files
LIB = $(patsubst %,-L%, $(LIBDIR))

#####################################################################
#                  User/Aplication Source Files                     #
#####################################################################

# Driver Source Files

OBJ_FILES = $(addprefix $(OBJ_DIR)/,$(notdir $(SRC_FILES:.c=.o)))
vpath %.c $(sort $(dir $(SRC_FILES)))
# list of ASM program objects
OBJ_FILES += $(addprefix $(OBJ_DIR)/,$(notdir $(STARTUP:.s=.o)))
vpath %.s $(sort $(dir $(STARTUP)))

#####################################################################
#                          Flags                                    #
#####################################################################

COMFLAGS = -mcpu=$(MCU) -mthumb -mfloat-abi=soft
ASFLAGS = $(COMFLAGS) $(DBG)
CPFLAGS = $(COMFLAGS) $(OPT) $(DEFS) $(DBG)   -Wall -fmessage-length=0 -ffunction-sections
LDFLAGS = $(COMFLAGS) -T$(LINKER) -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map -Wl,--gc-sections $(LIB)

#####################################################################
#                        Makefile Rules                             #
#####################################################################

all: $(OBJ_FILES) $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).hex $(BUILD_DIR)/$(PROJECT).bin
	$(PREFIX)size $(BUILD_DIR)/$(PROJECT).elf

$(OBJ_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CPFLAGS) -I . $(INC) $< -o $@

$(OBJ_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(CC) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(PROJECT).elf: $(OBJ_FILES) Makefile | $(BUILD_DIR)
	$(CC) $(OBJ_FILES) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
	mkdir $(OBJ_DIR)

#####FLASH#####
flash: $(BUILD_DIR)/$(PROJECT).hex
	openocd -f target/STM32F1x.cfg -f interface/stlink.cfg -c "program $(BUILD_DIR)/$(PROJECT).hex verify reset exit"
#####CLEAN#####
clean:
	rm -fR $(BUILD_DIR) $(OBJ_DIR)
