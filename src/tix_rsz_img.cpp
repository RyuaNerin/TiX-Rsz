#include "tix_rsz.h"
#include "tix_const.h"
#include "tix_expert.h"
#include "defer.h"

#include <algorithm>
#include <cstdint>
#include <memory>

#include <vips/vips.h>
#include <vips/vips8>

#include <webp/decode.h>

using namespace tix;

void Processor::resizeImg(vips::VImage& vimg, vips::VTarget& vTarget, vips::VOption *vResizeOpt, size_t length, TIX_RSZ_OUTPUT *out)
{
    bool has_alpha = vimg.has_alpha();
    /*
    if (has_alpha)
    {
        auto width  = vimg.width();
        auto height = vimg.height();

        try
        {
            double alpha;
            {
                auto p = vimg.getpoint(0, 0);
                alpha = p.back();
            }

            bool has_alpha_value = false;

            for (int y = 0; y < height && !has_alpha_value; y++)
            {
                for (int x = 0; x < width && !has_alpha_value; x++)
                {
                    auto pp = vimg.getpoint(x, y);
                    if (pp.back() != alpha)
                    {
                        has_alpha_value = true;
                        break;
                    }
                }
            }

            has_alpha = has_alpha_value;
        }
        catch (...)
        {
        }
    }
    */

    out->out_ratio = 1;
    while (true)
    {
        //////////////////////////////////////////////////
        // 리사이즈
        TIX_RETURN_CANCELED;

        vips::VImage vimgNew;
        try
        {
            vimgNew = vimg.resize(out->out_ratio, vResizeOpt);
            if (vimgNew.is_null())
                TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_ERROR);
        }
        catch (...)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_ERROR);
        }

        //////////////////////////////////////////////////
        // 저장
        TIX_RETURN_CANCELED;

        this->m_iclass.f_trunc(this->m_iclass.userdata);
        this->m_iclass.f_seek(this->m_iclass.userdata, 0, TIX_SEEK_SET);

        /*
        Q                : gint, quality factor
        lossless         : gboolean, enables lossless compression
        preset           : VipsForeignWebpPreset, choose lossy compression preset
        smart_subsample  : gboolean, enables high quality chroma subsampling
        near_lossless    : gboolean, preprocess in lossless mode (controlled by Q)
        alpha_q          : gint, set alpha quality in lossless mode
        reduction_effort : gint, level of CPU effort to reduce file size
        min_size         : gboolean, minimise size
        kmin             : gint, minimum number of frames between keyframes
        kmax             : gint, maximum number of frames between keyframes
        strip            : gboolean, remove all metadata from image
        profile          : gchararray, filename of ICC profile to attach
        */
        if (vips_webpsave_target(
                vimgNew.get_image(),
                vTarget.get_target(),
                "loseless", has_alpha ? TRUE : FALSE,
                "strip"   , TRUE,
                NULL) != 0)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_SAVE_ERROR);
        }

        //////////////////////////////////////////////////
        // 확인
        TIX_RETURN_CANCELED;

        this->m_iclass.f_flush(this->m_iclass.userdata);
        length = this->m_iclass.f_get_length(this->m_iclass.userdata);

        if (length < ImgMaxSize)
            break;

        out->out_ratio *= ReductionRatio;
    }

    //////////////////////////////////////////////////
    TIX_RETURN_CANCELED;

    out->out_succeed    = true;
    out->out_error_code = TIX_ERROR_CODE::TIX_ERROR_CODE_DONE;
    out->out_extension  = TIX_EXTENSION::TIX_EXTENSION_WEBP;
}
