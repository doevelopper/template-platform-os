
#ifndef PROJECT_OBJECT_MODEL_EXTRA_TEST_HPP
#define PROJECT_OBJECT_MODEL_EXTRA_TEST_HPP

#include <vector>
#include <gmock/gmock.h>

#include <project/object/model/log/LoggingService.hpp>

#define TEST_PV(testsuite, testname, ...) \
    class testsuite ## Parameterized \
        : public testsuite \
        ,public ::testing::WithParamInterface<decltype(GTEST_GET_FIRST_(__VA_ARGS__))> {}; \
    INSTANTIATE_TEST_SUITE_P(, testsuite ## Parameterized, ::testing::Values(__VA_ARGS__)); \
    TEST_P(testsuite ## Parameterized, testname)

namespace project::object::model::extra::test
{

    class Test
    {

    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        Test();
        Test(std::string & suite, unsigned int iteration = 1);
        Test(const Test & orig) = default;
        virtual
        ~Test();

        int run (int argc = 0, char * argv[] = nullptr);
        static void showUsage(std::string name);
        static void notYetImplemented();

    protected:

    private:

        std::string m_testSuites;
        unsigned int m_numberOfTestIteration;
        project::object::models::log::LoggingService *           m_loggerService;

        static const unsigned long LOGGER_WATCH_DELAY;
    };

}
#endif
