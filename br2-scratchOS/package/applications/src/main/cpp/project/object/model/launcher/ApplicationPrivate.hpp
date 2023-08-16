
#ifndef PROJECT_OBJECT_MODEL_LAUNCHER_APPLICATIONPRIVATE_HPP
#define PROJECT_OBJECT_MODEL_LAUNCHER_APPLICATIONPRIVATE_HPP

#include <boost/algorithm/string.hpp>
#include <boost/asio/signal_set.hpp>
#include <filesystem>
#include <future>
#include <fstream>
#include <iostream>
#include <typeindex>
#include <unordered_map>

#include <project/object/model/launcher/PluginInterface.hpp>
#include <project/object/model/log/LoggingService.hpp>
#include <project/object/model/utils/Version.hpp>


namespace project::object::model::launcher
{
    namespace fs = std::filesystem;
    using AnyTypeCmpMap = std::unordered_map<std::type_index, std::function<bool (const boost::any& a,
                                                                                  const boost::any& b)> >;

    class ApplicationPrivate
    {
    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        ApplicationPrivate();
        virtual ~ApplicationPrivate();

        std::string version() const;
        std::string fullVersionInfo() const;
        fs::path dataDirectory() const;
        void dataDirectory(const fs::path dir = "data") const;
        fs::path configDirectory() const;
        void configDirectory(const fs::path & dir = "conf");

        ApplicationPrivate(int &argc, char **argv);

    protected:

    private:

        Q_DISABLE_COPY_MOVE(ApplicationPrivate)

        OptionDesc m_appplicationOptions;
        OptionDesc m_appplicationConfigOptions;
        OptionMap m_optionMap;
        fs::path m_data_dir{"data"};
        fs::path m_config_dir{"conf"};
        fs::path m_logging_conf{"logging.json"};
        fs::path m_config_file_name;
        std::atomic_bool m_is_quiting{false};
        AnyTypeCmpMap m_anyCompareMap;
    };

}

#endif
