#include "tix_rsz.h"
#include "tix_const.h"
#include "tix_expert.h"
#include "defer.h"

#include <algorithm>
#include <cmath>
#include <vector>

#include <vips/vips.h>
#include <vips/vips8>

using namespace tix;

void Processor::resizeGif(vips::VImage& vimg, vips::VTarget& vTarget, vips::VOption *vResizeOpt, size_t length, TIX_RSZ_OUTPUT *out)
{
    auto width  = vimg.width();
    auto height = vimg.height();
    auto frame_count = height / vimg.get_int("page-height");

    if (frame_count == 1)
    {
        // 프레임이 하나면 단순 이미지 파일로 변환 후 처리.
        out->out_error_code = TIX_ERROR_CODE::TIX_ERROR_CODE_PASSED;
        return;
    }

    #define overSize    (width > GifMaxWidth || height > GifMaxHeight)
    #define overFrames  (frame_count < GifMaxFrames)
    #define overPixels  (((double)width * height * frame_count) > GifMaxPixels)

    if (length < GifMaxSize && !overFrames && !overSize && !overPixels)
    {
        out->out_succeed = true;
        out->out_error_code = TIX_ERROR_CODE::TIX_ERROR_CODE_DONE;
        out->out_extension = TIX_EXTENSION::TIX_EXTENSION_GIF;
        out->out_ratio = 1;
        return;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // 이미지 자르기
    TIX_RETURN_CANCELED;

    std::vector<vips::VImage> frame_image;
    for (int i = 0; i < frame_count; i++)
    {
        try
        {
            frame_image.push_back(vimg.crop(0, height * i, width, height));
        }
        catch (...)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_CAN_NOT_OPEN_FILE);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // GIF 딜레이 얻어오기
    TIX_RETURN_CANCELED;

    std::vector<int> frame_delay;

    try
    {
        auto frame_delay_int = vimg.get_int("gif-delay");
        for (int i = 0; i < frame_count; i++)
            frame_delay.push_back(frame_delay_int);
    }
    catch (...)
    {
        try
        {
            frame_delay = vimg.get_array_int("delay");
        }
        catch (...)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_NOT_SUPPORTED_FILE);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // GIF 딜레이 얻어오기
    TIX_RETURN_CANCELED;

    out->out_ratio = ReductionRatio;

    if (overSize)
    {
        out->out_ratio = std::min(
            GifMaxWidth  / width,
            GifMaxHeight / height
        );
    }

    if (overFrames)
    {
        int delCount = frame_count - GifMaxFrames;
        int sep = frame_count / (delCount + 1);

        for (int i = 0; i < delCount; ++i)
        {
            frame_delay[sep * i - 1] += frame_delay[sep * i];
            frame_delay.erase(frame_delay.begin() + (sep * i));

            frame_image.erase(frame_image.begin() + (sep * i));
        }

        frame_count = GifMaxFrames;
    }

    // Max Pixels
    if (overPixels)
    {
        // w : h = x : y
        // w * x = h * y
        // x * y = P
        // x = sqrt(P * h / w)
        //                                         __P_______________________
        out->out_ratio = (int)std::floor(std::sqrt(GifMaxPixels / frame_count * height / width)) / width;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    TIX_RETURN_CANCELED;

    std::vector<vips::VImage> frame_image_new(frame_count);

    vips::VOption vDrawOpt;
    vDrawOpt.set("mode", VIPS_COMBINE_MODE_SET);

    while (true)
    {
        //////////////////////////////////////////////////
        TIX_RETURN_CANCELED;

        frame_image_new.clear();

        //////////////////////////////////////////////////
        // 이미지 리사이즈.
        TIX_RETURN_CANCELED;

        for (auto &&frame : frame_image)
        {
            TIX_RETURN_CANCELED;

            try
            {
                auto vimgNew = frame.resize(out->out_ratio, vResizeOpt);
                if (vimgNew.is_null())
                    TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_ERROR);

                frame_image_new.push_back(vimgNew);
            }
            catch (...)
            {
                TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_ERROR);
            }
        }

        //////////////////////////////////////////////////
        // 이미지를 세로로 연결
        TIX_RETURN_CANCELED;

        auto width_new  = frame_image_new[0].width();
        auto height_new = frame_image_new[0].height();

        vips::VImage vimgNew;
        try
        {
            TIX_RETURN_CANCELED;

            vimgNew = vips::VImage::new_matrix(width_new, height_new * frame_count);
            if (vimgNew.is_null())
                TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_JOIN_ERROR);

            for (int i = 0; i < frame_count; i++)
            {
                vimgNew.draw_image(frame_image_new[i], 0, height_new * i, &vDrawOpt);
            }
        }
        catch (...)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_RESIZE_JOIN_ERROR);
        }
        
        vimgNew.set("page-height", frame_count);
        vimgNew.set("delay", frame_delay);
        try
        {
            vimgNew.set("loop", vimg.get_int("loop"));
        }
        catch (...)
        {
        }

        //////////////////////////////////////////////////
        // 저장
        TIX_RETURN_CANCELED;

        this->m_iclass.f_trunc(this->m_iclass.userdata);
        this->m_iclass.f_seek(this->m_iclass.userdata, 0, TIX_SEEK_SET);

        if (vips_image_write_to_target(vimgNew.get_image(), ".gif", vTarget.get_target(), vTarget, NULL) != 0)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_SAVE_ERROR);
        }

        //////////////////////////////////////////////////
        // 확인
        TIX_RETURN_CANCELED;

        this->m_iclass.f_flush(this->m_iclass.userdata);
        if (length < ImgMaxSize)
            break;

        out->out_ratio *= ReductionRatio;
    }

    //////////////////////////////////////////////////
    TIX_RETURN_CANCELED;

    out->out_succeed    = true;
    out->out_error_code = TIX_ERROR_CODE::TIX_ERROR_CODE_DONE;
    out->out_extension  = TIX_EXTENSION::TIX_EXTENSION_GIF;
}
