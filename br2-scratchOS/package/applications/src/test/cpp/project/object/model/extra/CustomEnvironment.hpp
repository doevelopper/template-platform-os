
#ifndef  PROJECT_OBJECT_MODEL_EXTRA_CUSTOMENVIRONMENT_HPP
#define  PROJECT_OBJECT_MODEL_EXTRA_CUSTOMENVIRONMENT_HPP

#include <gtest/gtest.h>
#include <project/object/model/log/LoggingService.hpp>

namespace project::object::model::extra::test
{

    class CustomEnvironment
        : public ::testing::Environment
    {
    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        CustomEnvironment();
        CustomEnvironment(const CustomEnvironment&) = delete;
        CustomEnvironment(CustomEnvironment&&) = delete;
        CustomEnvironment& operator=(const CustomEnvironment&) = delete;
        CustomEnvironment& operator=(CustomEnvironment&&) = delete;
        virtual ~CustomEnvironment();

        virtual void SetUp() override;
        virtual void TearDown() override;

    protected:

    private:
    };
}

#endif
