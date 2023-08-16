#ifndef PROJECT_OBJECT_MODEL_DUMMY_HPP
#define PROJECT_OBJECT_MODEL_DUMMY_HPP

#include <forward_list>
#include <string>

#include <project/object/model/log/LoggingService.hpp>

namespace project::object::model
{
    class POM_API_EXPORT Dummy
    {
        LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        Dummy();
        Dummy(const std::string& hello_string, const std::string& world_string);
        Dummy(const Dummy&) = default;
        Dummy(Dummy&&) = default;
        Dummy& operator=(const Dummy&) = default;
        Dummy& operator=(Dummy&&) = default;
        virtual ~Dummy();

        std::string speak() const;
        bool speechless() const;
        [[nodiscard]] constexpr bool isValid() const noexcept;

    private:

        std::string m_hello;
        std::string m_world;
        bool m_speechless;
    };
}

#endif // PROJECT_OBJECT_MODEL_DUMMY_HPP