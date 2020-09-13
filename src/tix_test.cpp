#include <experimental/filesystem>
#include <fstream>
#include <iostream>
#include <string>

#include "tix_expert.h"

bool test(const char* path, const char* path_out);

int main()
{
    return test("test.png", "test-out.data") ? 0 : 1;
}

typedef struct _DATA
{
    const char     *path;
    std::fstream    fs;
    std::streambuf *fs_buf;
} DATA;

size_t f_write(const void* userdata, const uint8_t* data, size_t length)
{
    ((DATA*)userdata)->fs_buf->sputn((const char*)data, length);
}
size_t f_read(const void* userdata, uint8_t* data, size_t length)
{
    ((DATA*)userdata)->fs_buf->sgetn((char*)data, length);
}
void f_flush(const void* userdata)
{
}
void f_trunc(const void* userdata)
{
    std::experimental::filesystem::resize_file(((DATA*)userdata)->path, 0);
}

size_t f_seek(const const void* userdata, size_t offset, TIX_WRENCE whence)
{
    const auto d = ((DATA*)userdata);

    switch (whence)
    {
    case TIX_WRENCE::TIX_SEEK_CUR:
        d->fs.seekg(offset, std::ios::beg);
        break;

    case TIX_WRENCE::TIX_SEEK_END:
        d->fs.seekg(offset, std::ios::cur);
        break;

    case TIX_WRENCE::TIX_SEEK_SET:
        d->fs.seekg(offset, std::ios::end);
        break;
    }

    return d->fs.tellg();
}

size_t f_get_position(const void* userdata)
{
    return ((DATA*)userdata)->fs.tellg();
}
size_t f_get_length(const void* userdata)
{
    const auto d = ((DATA*)userdata);

    auto pos = d->fs.tellg();

    d->fs.seekg(0, std::ios::end);
    auto length = d->fs.tellg();

    d->fs.seekg(pos, std::ios::beg);

    return length;
}

std::string get_file_size_by_eic(const char* path);
bool test(const char* path, const char* path_out)
{
    std::experimental::filesystem::copy(path, path_out);

    DATA data;
    data.path = path_out;
    data.fs = std::fstream(path_out, std::ios::binary | std::ios::in | std::ios::out);
    data.fs_buf = data.fs.rdbuf();

    TIX_RSZ_ICLASS iclass = { };
    iclass.userdata = &data;

    iclass.f_write = f_write;
    iclass.f_read = f_read;
    iclass.f_flush = f_flush;
    iclass.f_trunc = f_trunc;

    iclass.f_seek = f_seek;

    iclass.f_get_position = f_get_position;
    iclass.f_get_length = f_get_length;

    TIX_RSZ_OUTPUT out = { };
    out.in_extension = TIX_EXTENSION::TIX_EXTENSION_PNG;

    TiXRsz_Init();
    auto r = TiXRsz_New(&iclass);
    TiXRsz_Resize(r, &out);
    TiXRsz_Free(r);

    std::cout << path << std::endl;
    std::cout << "succeed    : " << out.out_succeed << std::endl;
    std::cout << "ratio      : " << out.out_ratio << std::endl;
    std::cout << "error_code : " << out.out_error_code << std::endl;
    std::cout << "extension  : " << out.out_extension << std::endl;
    std::cout << "file-size  : " << get_file_size_by_eic(path) << " -> " << get_file_size_by_eic(path_out) << std::endl;
}

std::string get_file_size_by_eic(const char* path)
{
    uint64_t size = std::experimental::filesystem::file_size(path);

    char result[30] = { 0, };
    if (size < 1000)
        std::sprintf(result, "%llu Bytes", size);
    else if (size < 1000 * 1024)
        std::sprintf(result, "%.2d KiB", (double)size / 1024);
    else
        std::sprintf(result, "%.2d MiB", (double)size / 1024 / 1024);

    return result;
}
