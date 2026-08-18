# $(CURDIR) is a GNU Make variable containing the path to the working dir.
SRCDIR := $(CURDIR)/src
BUILDDIR := $(CURDIR)/build

# Name of the final executable
TARGET = $(BUILDDIR)/ipd
C_VER = gnu17
CFLAGS = -pthread -I/usr/include
LDFLAGS = -lpthread -luv

# Hide or show target name of current rule, depending on VERBOSE variable
VERBOSE = FALSE

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


# Hide or show target name of current rule, depending on VERBOSE variable
ifeq ($(VERBOSE),TRUE)
	HIDE =
else
	HIDE = @
endif

# Function that will generate each rule.
define generateRules
$(1)/%.o: %.c
	@echo Building $$@
	$(HIDE)gcc -std=$(C_VER) -c $$(INCLUDES) $(CFLAGS) -o $$@ $$< -MMD 
endef

# Indicates to make which targets are not files
.PHONY: all clean directories

all: directories $(TARGET)

$(TARGET): $(OBJS)
	$(HIDE)echo Linking $@
	$(HIDE)gcc  $(OBJS) $(LDFLAGS) -o $(TARGET)

# Include dependencies
-include $(DEPS)

# Generate rules
$(foreach targetdir, $(TGTDIRS), $(eval $(call generateRules, $(targetdir))))

directories:
	$(HIDE)mkdir -p  $(TGTDIRS) 2>/dev/null 

# Remove all objects, dependencies and exucutables generated during build
clean:
	$(HIDE)rm -rf $(TGTDIRS) 2>/dev/null 
	$(HIDE)rm -rf $(TARGET) 2>/dev/null 
	@echo Cleaning done.

