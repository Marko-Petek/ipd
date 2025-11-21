# ==== Config ====
TARGET	= ipd
SRC		= src/main.c
OBJ		= $(SRC:.c=.o)
CC		= gcc
CFLAGS	= -Wall -Wextra -std=c17 -g
LDFLAGS	=


# ==== Rules ====
.PHONY: all clean run

# Default target
all: $(TARGET)

# Link
$(TARGET):	$(OBJ)	
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

# Compile source to object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Auto dependencies (GCC generated)
%.d: %.c
	$(CC) $(CFLAGS) -MM -MT '$(@:.d=.o)' $< > $@

# Regenerate header dependencies
-include $(SRC:.c=.d)


# Clean up
clean:
	rm -f $(TARGET) src/*.o src/*.d

run: $(TARGET)
	./$(TARGET)

