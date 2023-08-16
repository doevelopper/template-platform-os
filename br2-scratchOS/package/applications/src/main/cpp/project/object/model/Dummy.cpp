
#include <project/object/model/Dummy.hpp>

using namespace project::object::model;
  
log4cxx::LoggerPtr Dummy::logger =
    log4cxx::Logger::getLogger(std::string("project.object.model.Dummy"));

Dummy::Dummy()
    :  m_hello{}
    ,  m_world{}
    ,  m_speechless {true}
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

Dummy::~Dummy() 
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

std::string Dummy::speak() const
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    return(std::string("Hi"));
}

bool Dummy::speechless() const
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    return(true);
}

[[nodiscard]] constexpr bool Dummy::isValid() const noexcept
{
    // LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    return(true);
}

