
#ifndef PROJECT_OBJECT_MODEL_LAUNCHER_PLUGIN_HPP
#define PROJECT_OBJECT_MODEL_LAUNCHER_PLUGIN_HPP

#include <boost/program_options.hpp>
#include <boost/preprocessor/seq/for_each.hpp>
#include <string>
#include <vector>
#include <map>

#include <project/object/model/launcher/PluginInterface.hpp>

#define PLUGIN_REQUIRES_VISIT( r, visitor, elem )                                                   \
    visitor( project::object::model::launcher::mainApplication().register_plugin<elem>() ); 

#define PLUGIN_REQUIRES( PLUGINS )                                                                  \
    template<typename Lambda>                                                                       \
    void plugin_requires( Lambda&& l )                                                              \
    {                                                                                               \
        BOOST_PP_SEQ_FOR_EACH( PLUGIN_REQUIRES_VISIT, l, PLUGINS )                          \
    }

namespace project::object::model::launcher
{
    template<typename I>
    class Plugin : public PluginInterface
    {
        LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        using OptionDesc = boost::program_options::options_description;
        using OptionMap = boost::program_options::variables_map;

        Plugin();
        virtual ~Plugin();

        virtual void initialize(const OptionMap & options) override;
        virtual void handleSignalHangUp() override;
        virtual const std::string & name() const override;
        virtual void startup() override;
        virtual void options( OptionDesc & cli, OptionDesc & cfg ) override;
        virtual void registerPlugings();
        virtual void shutdown() override;
        virtual State state() const override;

    protected:

        Plugin( const std::string& name );

    private:

        Q_DEFAULT_COPY_MOVE(Plugin)
        std::string m_pluginName;
        PluginInterface::State m_pluginState;
    };
}

#endif
