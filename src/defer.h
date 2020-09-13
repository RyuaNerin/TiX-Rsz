#pragma once

#include <utility>

template <typename Func>
class DeferHelper
{
private:
    Func m_func;

public:
    template <typename FuncF>
    DeferHelper(FuncF &&f)
    {
        this->m_func = std::forward<FuncF>(f);
    }
    ~DeferHelper()
    {
        this->m_func();
    }

    DeferHelper(      DeferHelper&&) = delete;
    DeferHelper(const DeferHelper& ) = delete;
    DeferHelper &operator=(const DeferHelper & ) = delete;
    DeferHelper &operator=(      DeferHelper &&) = delete;
};

template <typename Func>
DeferHelper<Func> make_defer(Func &&f)
{
    return { std::forward<Func>(f) };
}

#ifdef __COUNTER__
#define DEFER(__lambda__) const auto &_____defer_c_##__COUNTER__ = make_defer([&]() { __lambda__; })
#else
#define DEFER(__lambda__) const auto &_____defer_l_##__LINE__    = make_defer([&]() { __lambda__; })
#endif
