
#ifndef PROJECT_OBJECT_MODEL_LAUNCHER_PLUGININTERFACE_HPP
#define PROJECT_OBJECT_MODEL_LAUNCHER_PLUGININTERFACE_HPP

#include <boost/program_options.hpp>
#include <boost/preprocessor/seq/for_each.hpp>

#include <map>
#include <string>
#include <vector>

#include <project/object/model/log/LoggingService.hpp>
#include <project/object/model/utils/Version.hpp>

namespace project::object::model::launcher
{
    using OptionDesc = boost::program_options::options_description;
    using OptionMap = boost::program_options::variables_map;

    class PluginInterface
    {
    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        enum class State : std::uint8_t
        {
            REGISTERED,         ///< the plugin is constructed but doesn't do anything
            INITIALIZED,        ///< the plugin has initialized any state required but is idle
            STARTED,            ///< the plugin is actively running
            STOPPED,            ///< the plugin is no longer running
            DISABLED,
        };

        PluginInterface();
        virtual ~PluginInterface();

        virtual State state() const = 0;
        virtual const std::string & name() const = 0;
        virtual const project::object::model::utils::Version & version () const = 0;
        virtual void options( OptionDesc & cli, OptionDesc & cfg ) = 0;
        virtual void initialize(const OptionMap & options) = 0;
        virtual void handleSignalHangUp() = 0;
        virtual void startup() = 0;
        virtual void shutdown() = 0;

    protected:

    private:

        Q_DEFAULT_COPY_MOVE(PluginInterface)
    };

}

#endif
