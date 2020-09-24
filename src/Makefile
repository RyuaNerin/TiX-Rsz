TARGET_DIR  := ../build
TARGET_NAME := TiXRsz.dll

SRCS := \
	tix_expert.cpp \
	tix_rsz.cpp \
	tix_rsz_gif.cpp \
	tix_rsz_img.cpp

OBJS := $(patsubst %,%.o,$(basename $(SRCS)))

CXX := /mingw64/bin/g++
LD  := /mingw64/bin/g++

COMMON_FLAGS := \
	-O2 \
	-Wall \
	-m64 \
	-std=c++17 \
	-fdata-sections -ffunction-sections

LIBRARY_INC := $(shell pkg-config --static --cflags vips vips-cpp)
LIBRARY_LIB := $(shell pkg-config --static --libs   vips vips-cpp) -lgif -lstdc++fs

CXXFLAGS := \
	$(COMMON_FLAGS) \
	$(LIBRARY_INC)

LDFLAGS := \
	$(COMMON_FLAGS) \
	-static \
	-Wl,--start-group \
	$(LIBRARY_LIB) \
	-Wl,--end-group \
	-Wl,-s,-x,--gc-sections,--allow-multiple-definition,--subsystem,windows,--out-implib,"$(TARGET_DIR)/$(subst .dll,.a,$(TARGET_NAME))"

RM = rm -f

all: $(TARGET_NAME)

$(TARGET_NAME): $(OBJS)
	mkdir -p $(TARGET_DIR)
	$(LD) -o "$(TARGET_DIR)/$@" $^ $(LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) -r $(OBJS) "$(TARGET_DIR)/$(TARGET_NAME)"
