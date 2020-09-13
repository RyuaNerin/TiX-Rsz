#pragma once

#include <cstdint>
#include <cmath>

#if defined TIX_TEST
    #define DLL_PUBLIC
    #define DLL_LOCAL
#else
    #if defined _WIN32 || defined __CYGWIN__
        #ifdef __GNUC__
            #define DLL_PUBLIC __attribute__ ((dllexport))
        #else
            #define DLL_PUBLIC __declspec(dllexport)
        #endif

        #define DLL_LOCAL
    #else
        #if __GNUC__ >= 4
            #define DLL_PUBLIC __attribute__ ((visibility ("default")))
            #define DLL_LOCAL  __attribute__ ((visibility ("hidden")))
        #else
            #define DLL_PUBLIC
            #define DLL_LOCAL
        #endif
    #endif
#endif

#ifdef __cplusplus
extern "C"
{
#endif

enum TIX_WRENCE : int32_t
{
    TIX_SEEK_SET = 0,
    TIX_SEEK_CUR = 1,
    TIX_SEEK_END = 2,
};

enum TIX_EXTENSION : int32_t
{
    TIX_EXTENSION_UNKNOWN = 1,
    TIX_EXTENSION_WEBP    = 2,
    TIX_EXTENSION_PNG     = 3,
    TIX_EXTENSION_JPEG    = 4,
    TIX_EXTENSION_GIF     = 5,
};

enum TIX_ERROR_CODE : int32_t
{
    TIX_ERROR_CODE_PASSED              = -1,

    TIX_ERROR_CODE_DONE                = 0,
    TIX_ERROR_CODE_CANCELED            = 1,
    TIX_ERROR_CODE_WEBP_HAS_ANIMATION  = 2,

    TIX_ERROR_CODE_UNKNOWN_ERROR       = 3,
    TIX_ERROR_CODE_CAN_NOT_OPEN_FILE   = 4,
    TIX_ERROR_CODE_NOT_SUPPORTED_FILE  = 5,
    TIX_ERROR_CODE_RESIZE_ERROR        = 6,
    TIX_ERROR_CODE_RESIZE_JOIN_ERROR   = 7,
    TIX_ERROR_CODE_SAVE_ERROR          = 8,
};

typedef struct _TIX_RSZ_ICLASS {
    const void* userdata;

    size_t (*f_write)(const void* userdata, const uint8_t *data, size_t length);
    size_t (*f_read )(const void* userdata,       uint8_t *data, size_t length);
    void   (*f_flush)(const void* userdata);
    void   (*f_trunc)(const void* userdata);

    size_t (*f_seek )(const void* userdata, size_t offset, TIX_WRENCE whence);

    size_t (*f_get_position)(const void* userdata);
    size_t (*f_get_length  )(const void* userdata);
} TIX_RSZ_ICLASS;

typedef struct _TIX_RSZ_RESULT {
    TIX_EXTENSION   in_extension;

    bool            out_succeed;
    TIX_ERROR_CODE  out_error_code;
    TIX_EXTENSION   out_extension;
    float_t         out_ratio;
} TIX_RSZ_OUTPUT;

DLL_PUBLIC void  TiXRsz_Init();
DLL_PUBLIC void* TiXRsz_New(const TIX_RSZ_ICLASS *iclass);
DLL_PUBLIC void  TiXRsz_Resize(const void* ptr, TIX_RSZ_OUTPUT *out);
DLL_PUBLIC void  TiXRsz_Cancel(const void* ptr);
DLL_PUBLIC void  TiXRsz_Free  (const void* ptr);

#ifdef __cplusplus
}
#endif
