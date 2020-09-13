#include "tix_expert.h"
#include "tix_rsz.h"

void TiXRsz_Init()
{
    tix::init();
}

void* TiXRsz_New(const TIX_RSZ_ICLASS *iclass)
{
    return (void*)new tix::Processor(iclass);
}
void TiXRsz_Resize(const void* ptr, TIX_RSZ_OUTPUT *out)
{
    ((tix::Processor*)ptr)->resize(out);
}
void TiXRsz_Cancel(const void* ptr)
{
    ((tix::Processor*)ptr)->cancel();
}
void TiXRsz_Free(const void* ptr)
{
    delete (tix::Processor*)ptr;
}
