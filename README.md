工具链设置  

本项目模板使用gcc工具链编译，需要安装以下工具：  

[arm-none-eabi-gcc](https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-win32.zip?rev=8f4a92e2ec2040f89912f372a55d8cf3&hash=8A9EAF77EF1957B779C59EADDBF2DAC118170BBF)  

[openocd](https://gnutoolchains.com/arm-eabi/openocd/)  

[mingw-w64](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z/download)  


安装工具链  

安装arm-none-eabi-gcc，将其解压到指定目录，如：C:\ToolChain\arm-gcc
安装mingw-w64，将其解压到指定目录，如：C:\Toolchain\mingw-w64\
安装openocd，将其解压到指定目录，如：C:\Toolchain\openocd


配置环境变量
在系统环境变量中添加以下路径：
C:\ToolChain\arm-gcc\bin
C:\Toolchain\mingw-w64\mingw32\bin
C:\Toolchain\openocd\bin

安装必要插件  
c/c++ Extension Pack  
Cortex-Debug   
Makefile Tools  

使用该模板
将本模板下载到本地，并解压到指定目录，如：C:\project\STM32\Template\STM32-STDLIB-Template
该模板需要修改Makefile文件，将其中的路径修改为自己的路径。
```Makefile
# 项目名称
PROJECT = LEDBlink

MCU = cortex-m3
DBG = -g3
OPT = #-Os


#####BEGIN MODIFY#####
# 链接文件
LINKER = stm32f1x_64KB_flash.ld
# 启动汇编文件
STARTUP = Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/TrueSTUDIO/startup_stm32f10x_md.s
# 宏定义
DEFINES = \
STM32F10X_MD \
USE_STDPERIPH_DRIVER

# 包含目录
INCLUDE_DIR = \
$(wildcard Libraries/CMSIS/CM3/CoreSupport) \
$(wildcard Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x) \
$(wildcard Libraries/STM32F10x_StdPeriph_Driver/inc) \
$(wildcard System/*) \
$(wildcard User)

# 源文件 使用$(wildcard *)作为通配符

SRC_FILES = \
$(wildcard Libraries/CMSIS/CM3/CoreSupport/*.c) \
$(wildcard Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/*.c) \
$(wildcard Libraries/STM32F10x_StdPeriph_Driver/src/*.c) \
$(wildcard System/**/*.c) \
$(wildcard User/*.c)

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


```

 修改core_cm3.c
```
uint32_t __STREXB(uint8_t value, uint8_t *addr)
{
   uint32_t result=0;
  
   //__ASM volatile ("strexb %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   __ASM volatile ("strexb %0, %2, [%1]" : "=&r" (result) : "r" (addr), "r" (value) );
   return(result);
}

uint32_t __STREXH(uint16_t value, uint16_t *addr)
{
   uint32_t result=0;
  
   //__ASM volatile ("strexh %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   __ASM volatile ("strexh %0, %2, [%1]" : "=&r" (result) : "r" (addr), "r" (value) );
   return(result);
}
```
调试配置
launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Cortex Debug",
            "cwd": "${workspaceFolder}",
            "executable": "build/LEDBlink.elf",
            "request": "launch",
            "type": "cortex-debug",
            "runToEntryPoint": "main",
            "servertype": "openocd",
            "configFiles": [
                "interface/stlink.cfg",
                "target/stm32f1x.cfg"
            ]
        }
    ]
}
```
编译
```bash
make
```
烧录
```bash
make flash
```
调试
在vscode中打开项目，点击调试按钮，选择Cortex Debug，点击启动按钮，即可开始调试。