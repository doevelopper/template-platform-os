
#include <project/object/model/log/CentralizedLogging.hpp>

using namespace project::object::models::log;

log4cxx::LoggerPtr CentralizedLogging::logger =
    log4cxx::Logger::getLogger(std::string("cfs.utils.log.CentralizedLogging"));

CentralizedLogging::CentralizedLogging()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

CentralizedLogging::~CentralizedLogging()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}
