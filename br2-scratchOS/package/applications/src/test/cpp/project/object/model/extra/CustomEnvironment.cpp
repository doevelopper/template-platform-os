
#include <project/object/model/extra/CustomEnvironment.hpp>

using namespace project::object::model::extra;
using namespace project::object::model::extra::test;
using namespace project::object::models::log;


log4cxx::LoggerPtr CustomEnvironment::logger =
    log4cxx::Logger::getLogger(std::string("project.object.model.extra.test.CustomEnvironment"));

CustomEnvironment::CustomEnvironment()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

CustomEnvironment::~CustomEnvironment()
{
    //FIXME: No appender could be found for logger
    //LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void CustomEnvironment::SetUp()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void CustomEnvironment::TearDown()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}
