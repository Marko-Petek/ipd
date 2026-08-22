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

# Create the list of directories where sources reside
DIRS = main rbtree cache db

# ipd/src --> ipd/src/main
#         --> ipd/src/rbtree
#
SRCDIRS = $(foreach dir, $(DIRS), $(addprefix $(SRCDIR)/, $(dir)))

# ipd/build --> ipd/build/main
# 			--> ipd/build/rbtree
#
TGTDIRS = $(foreach dir, $(DIRS), $(addprefix $(BUILDDIR)/, $(dir)))

# Generate the GCC includes pars by adding -I before each src dir.
#
# (...)ipd/src/main   --> -I(...)ipd/src/main
# (...)ipd/src/rbtree --> -I(...)ipd/src/rbtree
#
INCLUDES = $(foreach dir, $(SRCDIRS), $(addprefix -I, $(dir)))

# Where GNU Make will look for source files.
VPATH = $(SRCDIRS)

# Create a list of *.c sources in DIRS.
# wildcard part --> look into each dir for .c files --> congregate a list of all .c files from all dirs. E.g.:
#
#  ipd/src/main/main.c
#  ipd/src/rbtree/rbtree.c
#
SRCS = $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))

# Generate objects list situated in ./build for all sources in ./src
# subst( from, to, inputText ), i.e.:
#
# ipd/src/main/main.c      -->  ipd/build/main/main.o
# ipd/src/rbTree/rbTree.c  -->  ipd/build/rbTree/rbTree.o
#
OBJS := $(subst $(SRCDIR),$(BUILDDIR),$(SRCS:.c=.o))

# Define "header dependency files" that will be generated in preprocessing stage.
# .c --> .d --> .o --> .elf
# see -MMD compile option
#
DEPS = $(OBJS:.o=.d)


# Hide or show target name of current rule, depending on VERBOSE variable
ifeq ($(VERBOSE),TRUE)
	HIDE =
else
	HIDE = @
endif

# Function that will generate each rule.
# -MMD  -->  track the headers during preprocessing and generate header dependency files.
#  See DEPS above.
#
# $(1) is a reference to the first argument of a user call-ed function,
# in this case, it will be a target dir, e.g., ipd/build/main
#
# $@ is the target of the current rule
# $< is the first prerequisite of the current rule
# $^ are all the prerequisites of the current rule

define generateRules
$(1)/%.o: %.c
	@echo Building $$@
	$(HIDE)gcc -std=$(C_VER) -c $$(INCLUDES) $(CFLAGS) -o $$@ $$< -MMD 
endef

# Indicates to make which targets are not files
.PHONY: all clean directories

all: directories $(TARGET)

# Link rule
# ipd (elf) <-- ipd/build/main/main.o, ipd/build/rbTree/rbTree.o, ...
#
$(TARGET): $(OBJS)
	$(HIDE)echo Linking $@
	$(HIDE)gcc  $(OBJS) $(LDFLAGS) -o $(TARGET)

# Include dependencies
-include $(DEPS)

# Generate compile rules
$(foreach targetdir, $(TGTDIRS), $(eval $(call generateRules, $(targetdir))))

directories:
	$(HIDE)mkdir -p  $(TGTDIRS) 2>/dev/null 

# Remove all objects, dependencies and exucutables generated during build
clean:
	$(HIDE)rm -rf $(TGTDIRS) 2>/dev/null 
	$(HIDE)rm -rf $(TARGET) 2>/dev/null 
	@echo Cleaning done.

