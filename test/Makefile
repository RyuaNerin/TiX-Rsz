TARGET_DIR  := /data/bin
TARGET_NAME := TiXRsz_test.exe

SRCS := \
	tix_test.cpp

OBJS := $(patsubst %,%.o,$(basename $(SRCS)))

CXX := x86_64-w64-mingw32-g++-posix
LD  := x86_64-w64-mingw32-g++-posix

COMMON_FLAGS := \
	-O2 \
	-Wall \
	-m64 \
	-std=c++17

LIBRARY_INC := $(shell x86_64-w64-mingw32-pkg-config --static --cflags vips vips-cpp)
LIBRARY_LIB := $(shell x86_64-w64-mingw32-pkg-config --static --libs   vips vips-cpp)

CXXFLAGS := \
	$(COMMON_FLAGS) \
	$(LIBRARY_INC)

LDFLAGS := \
	$(COMMON_FLAGS) \
	-static-libgcc \
	$(LIBRARY_LIB) \
	-L"$(TARGET_DIR)" \
	-l"TiXRsz" \
	-Wl,--subsystem,console

RM = rm -f

all: $(TARGET_NAME)

$(TARGET_NAME): $(OBJS)
	mkdir -p $(TARGET_DIR)
	$(LD) -o "$(TARGET_DIR)/$@" $^ $(LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: test
test:
	wine "$(TARGET_DIR)/$(TARGET_NAME)"

.PHONY: clean
clean:
	$(RM) -r $(OBJS) "$(TARGET_DIR)/$(TARGET_NAME)"
