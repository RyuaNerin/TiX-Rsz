#pragma once

#include "tix_expert.h"

#include <atomic>
#include <cstdint>
#include <mutex>
#include <tuple>

#include <vips/vips.h>
#include <vips/vips8>

namespace tix
{
    static void init();

    class Processor
    {
    private:
        std::atomic<bool> m_cancelled;
        std::mutex m_mutex;

    public:
        const TIX_RSZ_ICLASS m_iclass;

    public:
        Processor(const TIX_RSZ_ICLASS *iclass);
        ~Processor();
        void resize(TIX_RSZ_OUTPUT *out);
        void cancel();

    private:
        void resizeImg(vips::VImage& vimg, vips::VTarget& vTarget, vips::VOption *vResizeOpt, size_t length, TIX_RSZ_OUTPUT *out);
        void resizeGif(vips::VImage& vimg, vips::VTarget& vTarget, vips::VOption *vResizeOpt, size_t length, TIX_RSZ_OUTPUT *out);
    };

#define TIX_RETURN_ERROR(__error_code__)                                \
        {                                                               \
            out->out_succeed = false;                                   \
            out->out_error_code = __error_code__;                       \
            return;                                                     \
        }

#define TIX_RETURN_CANCELED \
        if (this->m_cancelled.load())                                   \
        {                                                               \
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_CANCELED)   \
        }
}
