# 项目名称
PROJECT = LEDBlink

MCU = cortex-m3
DBG = -g3
OPT = #-Os


#####BEGIN MODIFY#####
# 链接文件
LINKER = stm32f1x_64KB_flash.ld
# 启动汇编文件
STARTUP = startup_stm32f10x_md.s
# 宏定义
DEFINES = \
STM32F10X_MD \
USE_STDPERIPH_DRIVER

# 包含目录
INCLUDE_DIR = \
Core/CMSIS/CM3/CoreSupport \
Core/CMSIS/CM3/DeviceSupport/ST/STM32F10x \
Driver/STM32F10x_StdPeriph_Driver \
Driver/STM32F10x_StdPeriph_Driver/inc \
User/inc \
$(wildcard System/*) \
$(wildcard Hardware/*)

# 源文件 使用$(wildcard *)作为通配符

SRC_FILES = \
$(wildcard Core/CMSIS/CM3/**/*.c) \
$(wildcard Core/CMSIS/CM3/DeviceSupport/ST/STM32F10x/*.c) \
$(wildcard Driver/STM32F10x_StdPeriph_Driver/*.c) \
$(wildcard Driver/STM32F10x_StdPeriph_Driver/**/*.c) \
$(wildcard User/**/*.c) \
$(wildcard System/*.c) $(wildcard System/**/*.c) \
$(wildcard Hardware/**/*.c)

#####END MODIFY#####


# 工具链
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

# 默认目录
#####################################################################
#                      DEFAULT DIRECTORIES                          #
#####################################################################
# Object Files
OBJ_DIR = obj
BUILD_DIR = build
LIBDIR = lib


DEFS = $(patsubst %,-D%, $(DEFINES))
# Header file
INC = $(patsubst %,-I%, $(INCLUDE_DIR))
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
#####CLEAN#####
clean:
	rm -fR $(BUILD_DIR) $(OBJ_DIR)

# 自定义脚本

#标签: 条件
#TAB缩进 命令行

##刷机
flash: $(BUILD_DIR)/$(PROJECT).hex
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $(BUILD_DIR)/$(PROJECT).hex verify reset exit"
