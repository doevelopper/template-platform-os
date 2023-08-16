
#include <model/Dummy.hpp>

using namespace com::gitlab::cfs::platform;

log4cxx::LoggerPtr Dummy::logger = 
    log4cxx::Logger::getLogger ( std::string ( "com.gitlab.cfs.platform.Dummy" ) );

Dummy::Dummy ( ) noexcept
    : m_hello { }
    , m_world { }
    , m_speechless { true }
    , m_idx ( 0 )
{
    LOG4CXX_TRACE ( logger, __LOG4CXX_FUNC__ );
}

Dummy::~Dummy ( ) noexcept { LOG4CXX_TRACE ( logger, __LOG4CXX_FUNC__ ); }

std::string Dummy::speak ( ) const noexcept
{
    LOG4CXX_TRACE ( logger, __LOG4CXX_FUNC__ );
    return ( std::string ( "false" ) );
}

bool Dummy::speechless ( ) const noexcept
{
    LOG4CXX_TRACE ( logger, __LOG4CXX_FUNC__ );
    return ( false );
}

[[nodiscard]] constexpr bool Dummy::isValid ( ) const noexcept
{
    // LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    return ( false );
}