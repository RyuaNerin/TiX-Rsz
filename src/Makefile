DLL_NAME := TiXRsz.dll
EXE_NAME := TiXRsz_test.exe

DLL_SRCS := \
	tix_expert.cpp \
	tix_rsz.cpp \
	tix_rsz_gif.cpp \
	tix_rsz_img.cpp

EXE_SRCS := \
	tix_test.cpp
	
DLL_OBJS := $(patsubst %,%.o,$(basename $(DLL_SRCS)))
EXE_SRCS := $(patsubst %,%.o,$(basename $(EXE_SRCS)))

CC  := x86_64-w64-mingw32-gcc-posix
CXX := x86_64-w64-mingw32-g++-posix
LD  := x86_64-w64-mingw32-g++-posix

COMMON_FLAGS := -O2 -Wall

CXXFLAGS := \
	$(COMMON_FLAGS) \
	-std=c++17 \
	-I"../vips-dev/include" \
	-I"../vips-dev/include/glib-2.0" \
	-I"../vips-dev/lib/glib-2.0/include"

DLL_LDFLAGS := \
	$(COMMON_FLAGS) \
	-std=c++17 \
	-shared \
	-static-libgcc \
	-L"../vips-dev/lib" \
	-l"webp" \
	-l"vips" \
	-l"vips-cpp" \
	-l"glib-2.0" \
	-l"gobject-2.0" \
	-Wl,-s,-x,--subsystem,windows,--out-implib,$(subst .dll,.a,$(subst .exe,.a,$(DLL_NAME)))

EXE_LDFLAGS := \
	$(COMMON_FLAGS) \
	-std=c++17 \
	-L"." \
	-l"TiXRsz" \
	-Wl,-s,-x,--subsystem,windows,--out-implib,$(subst .dll,.a,$(subst .exe,.a,$(EXE_NAME)))

RM = rm -f

all: $(DLL_NAME) $(EXE_NAME) test

$(DLL_NAME): $(OBJS)
	$(LD) -o $@ $^ $(DLL_LDFLAGS)

$(EXE_NAME): $(OBJS)
	$(LD) -o $@ $^ $(EXE_LDFLAGS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

test:
	wine $(EXE_NAME)

.PHONY: clean
clean:
	$(RM) -r $(OBJS) $(DLL_NAME) $(EXE_NAME)

#x86_64-w64-mingw32-g++-posix \
#    -o TiXRsz.o \
#    -c TiXRsz.cpp \
#    -O3 -Wall \
#    -std=c++17 \
#    -D ADD_EXPORTS \
#    -static-libgcc \
#    -I"${VIPS_DIR}/include" \
#    -I"${VIPS_DIR}/include/glib-2.0" \
#    -I"${VIPS_DIR}/lib/glib-2.0/include"
#x86_64-w64-mingw32-g++-posix \
#    -o TiXRsz.dll \
#    TiXRsz.o \
#    -O3 -Wall \
#    -std=c++17 \
#    -L"${VIPS_DIR}/lib" \
#    -l"webp" \
#    -l"vips" \
#    -l"vips-cpp" \
#    -l"glib-2.0" \
#    -l"gobject-2.0" \
#    -shared \
#    -static-libgcc \
#    -s \
#    -Wl,--subsystem,windows,--out-implib,TiXRsz.a
