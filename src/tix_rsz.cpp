#include "tix_rsz.h"
#include "tix_const.h"
#include "tix_expert.h"
#include "defer.h"

#include <algorithm>
#include <cstdint>
#include <memory>
#include <mutex>

#include <vips/vips.h>
#include <vips/vips8>

#include <webp/decode.h>

using namespace tix;

void tix::init()
{
    vips_init("TiXRsz");
}

Processor::Processor(const TIX_RSZ_ICLASS *iclass) : m_iclass(*iclass)
{
}

Processor::~Processor()
{
    this->cancel();
    this->m_mutex.lock();
}

void Processor::cancel()
{
    this->m_cancelled.store(true);
}

static gint64 tix_vips_read(VipsSourceCustom *src, void *buf, gint64 length, Processor* p);
static gint64 tix_vips_write(VipsTargetCustom *src, const void *buf, gint64 length, Processor* p);
static gint64 tix_vips_seek(VipsSourceCustom *src, gint64 offset, int whence, Processor* p);
static void tix_vips_finish(VipsTargetCustom *src, Processor* p);

void Processor::resize(TIX_RSZ_OUTPUT *out)
{
    const std::lock_guard<std::mutex> lock(this->m_mutex);

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    auto length = this->m_iclass.f_get_length(this->m_iclass.userdata);

    if (out->in_extension == TIX_EXTENSION::TIX_EXTENSION_WEBP)
    {
        // 애니메이션 Webp 파일 지원 안함.
        try
        {
            auto buffer = std::make_unique<uint8_t[]>(length);
            auto ptr = reinterpret_cast<uint8_t*>(&buffer);

            this->m_iclass.f_seek(this->m_iclass.userdata, 0, TIX_SEEK_SET);

            size_t read;
            while ((read = this->m_iclass.f_read(this->m_iclass.userdata, ptr, BufferSize)) > 0)
            {
                TIX_RETURN_CANCELED;
                ptr += read;
            }

            WebPBitstreamFeatures features;
            if (WebPGetFeatures(buffer.get(), length, &features) == VP8_STATUS_OK && features.has_animation)
            {
                TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_CAN_NOT_OPEN_FILE);
            }
        }
        catch(...)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE::TIX_ERROR_CODE_UNKNOWN_ERROR);
        }
    }

    if (length <= ImgMaxSize)
    {
        switch (out->in_extension)
        {
        case TIX_EXTENSION::TIX_EXTENSION_WEBP:
        case TIX_EXTENSION::TIX_EXTENSION_PNG:
        case TIX_EXTENSION::TIX_EXTENSION_JPEG:
            out->out_succeed = true;
            out->out_extension = out->in_extension;
            out->out_ratio = 1;
            return;
        default:
            break;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // 이미지 불러오기
    TIX_RETURN_CANCELED
    
    vips::VImage vimg;
    {
        auto vSourceRaw = vips_source_custom_new();
        if (vSourceRaw == nullptr)
        {
            TIX_RETURN_ERROR(TIX_ERROR_CODE_UNKNOWN_ERROR);
        }

        g_signal_connect(vSourceRaw, "read", G_CALLBACK(tix_vips_read), this);
        g_signal_connect(vSourceRaw, "seek", G_CALLBACK(tix_vips_seek), this);

        vips::VSource vSource(&vSourceRaw->parent_object);

        this->m_iclass.f_seek(this->m_iclass.userdata, 0, TIX_SEEK_SET);
        vimg = vips::VImage::new_from_source(vSource, NULL);
    }
    if (vimg.is_null())
    {
        TIX_RETURN_ERROR(TIX_ERROR_CODE_NOT_SUPPORTED_FILE);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // 저장을 위한 vips_target 설정
    TIX_RETURN_CANCELED

    auto vTargetRaw = vips_target_custom_new();
    if (vTargetRaw == nullptr)
    {
        TIX_RETURN_ERROR(TIX_ERROR_CODE_UNKNOWN_ERROR);
    }

    g_signal_connect(vTargetRaw, "write" , G_CALLBACK(tix_vips_write ), this);
    g_signal_connect(vTargetRaw, "finish", G_CALLBACK(tix_vips_finish), this);

    vips::VTarget vTarget(&vTargetRaw->parent_object, vips::VSteal::STEAL);

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // 리사이징 옵션
    TIX_RETURN_CANCELED

    vips::VOption vResizeOpt;
    vResizeOpt.set("kernel", VIPS_KERNEL_CUBIC);

    ////////////////////////////////////////////////////////////////////////////////////////////////////

    if (out->in_extension == TIX_EXTENSION_GIF)
    {
        this->resizeGif(vimg, vTarget, &vResizeOpt, length, out);
        if (out->out_error_code != TIX_ERROR_CODE::TIX_ERROR_CODE_PASSED)
            return;
    }

    this->resizeImg(vimg, vTarget, &vResizeOpt, length, out);
}

static gint64 tix_vips_read(VipsSourceCustom *src, void *buf, gint64 length, Processor* p)
{
    return p->m_iclass.f_read(p->m_iclass.userdata, (uint8_t*)buf, length);
}

static gint64 tix_vips_write(VipsTargetCustom *src, const void *buf, gint64 length, Processor* p)
{
    return p->m_iclass.f_write(p->m_iclass.userdata, (const uint8_t*)buf, length);
}

static gint64 tix_vips_seek(VipsSourceCustom *src, gint64 offset, int whence, Processor* p)
{
	switch (whence)
    {
	case SEEK_SET:
        p->m_iclass.f_seek(p->m_iclass.userdata, offset, TIX_SEEK_SET);
		break;

	case SEEK_CUR:
        p->m_iclass.f_seek(p->m_iclass.userdata, offset, TIX_SEEK_CUR);
		break;

	case SEEK_END:
        p->m_iclass.f_seek(p->m_iclass.userdata, offset, TIX_SEEK_END);
		break;

	default:
        return -1;
	}

	return p->m_iclass.f_get_position(p->m_iclass.userdata);
}

static void tix_vips_finish(VipsTargetCustom *src, Processor* p)
{
    p->m_iclass.f_flush(p->m_iclass.userdata);
}
