
#include <project/object/model/launcher/PluginInterface.hpp>

using namespace project::object::model::launcher;
using namespace project::object::model::utils;

log4cxx::LoggerPtr PluginInterface::logger =
    log4cxx::Logger::getLogger(std::string("project.object.model.launcher.PluginInterface"));

PluginInterface::PluginInterface()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

PluginInterface::~PluginInterface()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}
