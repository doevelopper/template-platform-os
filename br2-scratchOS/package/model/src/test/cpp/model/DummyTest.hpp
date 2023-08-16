/*!
 *      Copyright {{ year }} {{ organization }}

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
    or implied. See the License for the specific language governing
    permissions and limitations under the License.
 */

#ifndef COM_GITLAB_CFS_PLATFORM_DUMMYTEST_HPP
#define COM_GITLAB_CFS_PLATFORM_DUMMYTEST_HPP

/*!
 * @file unitTest.cpp
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2021-06-24
 * 
 * @copyright Copyright (c) 2021
 * 
 */

// #include <model/Test.hpp>
#include <model/Dummy.hpp>

namespace model::Dummy::test
{

    class DummyTest : public ::testing::Test
    {
    LOG4CXX_DECLARE_STATIC_TEST_LOGGER

    public:

        DummyTest();
        DummyTest(const DummyTest&) = delete;
        DummyTest(DummyTest&&) = delete;
        DummyTest& operator=(const DummyTest&) = delete;
        DummyTest& operator=(DummyTest&&) = delete;
        virtual ~DummyTest();

        void SetUp() override;
        void TearDown() override;

    protected:

    private:

        com::gitlab::cfs::platform::Dummy * m_targetUnderTest;
    };
}
#endif
