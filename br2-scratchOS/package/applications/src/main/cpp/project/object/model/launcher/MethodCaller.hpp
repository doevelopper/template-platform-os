
#ifndef PROJECT_OBJECT_MODEL_LAUNCHER_METHODCALLER_HPP
#define PROJECT_OBJECT_MODEL_LAUNCHER_METHODCALLER_HPP

#include <boost/signals2.hpp>
#include <boost/exception/diagnostic_information.hpp>
#include <project/object/model/log/LoggingService.hpp>

namespace project::object::model::launcher
{
    template<typename FunctionSig, typename DispatchPolicy>

    class MethodCaller;

    template<typename Ret, typename ... Args, typename DispatchPolicy>
    class MethodCaller<Ret(Args...), DispatchPolicy>
    {
    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        using signal_type = boost::signals2::signal<Ret(Args...), DispatchPolicy>;
        using result_type = Ret;

        MethodCaller();

        Ret operator()(Args&&... args)
        {
            return m_signal(std::forward<Args>(args)...);
        }
        signal_type m_signal;
    };

    template<typename ... Args, typename DispatchPolicy>
    class MethodCaller<void(Args...), DispatchPolicy>
    {
        LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        using signal_type = boost::signals2::signal<void (Args...), DispatchPolicy>;
        using result_type = void;

        MethodCaller()
        {
        }
        void operator()(Args&&... args)
        {
            m_signal(std::forward<Args>(args)...);
        }
        signal_type m_signal;
    };

}

#endif
