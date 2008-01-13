SRC_DIR=src
EXEC=$(SRC_DIR)/src

all: $(EXEC) install

$(EXEC):
	@(cd $(SRC_DIR) && $(MAKE))
	
install:
	mv -v src/*.o ./
