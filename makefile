# Set project dir one level above the makefile dir.
# $(CURDIR) is a GNU Make variable containing the path to the working dir.
PROJDIR := $(CURDIR)
SRCDIR := $(PROJDIR)/src
BUILDDIR := $(PROJDIR)/build

# Name of the final executable
TARGET = $(BUILDDIR)/ipd
C_VER = gnu11
CFLAGS = -pthread -I/usr/include
LDFLAGS = -lpthread -luv

# Decide whether the commands will be shown or not.
VERBOSE = TRUE

# Create the list of directories
DIRS = main rbtree cache
SRCDIRS = $(foreach dir, $(DIRS), $(addprefix $(SRCDIR)/, $(dir)))
TGTDIRS = $(foreach dir, $(DIRS), $(addprefix $(BUILDDIR)/, $(dir)))

# Generate the GCC includes pars by adding -I before each src dir
INCLUDES = $(foreach dir, $(SRCDIRS), $(addprefix -I, $(dir)))

# Add srcdirs list to VPATH (where make will look for source files).
VPATH = $(SRCDIRS)

# Create a list of *.c sources in DIRS
SRCS = $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))

# Define objects for all sources.
OBJS := $(subst $(SRCDIR),$(BUILDDIR),$(SRCS:.c=.o))

# Define dependencies files for all objects.
DEPS = $(OBJS:.o=.d)

# Name the compiler.
CC = gcc

# Linux-specific part.
RM = rm -rf
RMDIR = rm -rf
MKDIR = mkdir -p
ERRIGNORE = 2>/dev/null


# Hide or show calls depending on VERBOSE
ifeq ($(VERBOSE),TRUE)
	HIDE =
else
	HIDE = @
endif

# Function that will generate each rule.
define generateRules
$(1)/%.o: %.c
	@echo Building $$@
	$(HIDE)$(CC) -std=$(C_VER) -c $$(INCLUDES) $(CFLAGS) -o $$@ $$< -MMD 
endef

# Indicates to make which targets are not files
.PHONY: all clean directories

all: directories $(TARGET)

$(TARGET): $(OBJS)
	$(HIDE)echo Linking $@
	$(HIDE)$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET)

# Include dependencies
-include $(DEPS)

# Generate rules
$(foreach targetdir, $(TGTDIRS), $(eval $(call generateRules, $(targetdir))))

directories:
	$(HIDE)$(MKDIR) $(TGTDIRS) $(ERRIGNORE)

# Remove all objects, dependencies and exucutables generated during build
clean:
	$(HIDE)$(RMDIR) $(TGTDIRS) $(ERRIGNORE)
	$(HIDE)$(RM) $(TARGET) $(ERRIGNORE)
	@echo Cleaning done.

