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

#include <com/gitlab/cfs/platform/DummyTest.hpp>

using namespace com::gitlab::cfs::platform;
using namespace com::gitlab::cfs::platform::test;

log4cxx::LoggerPtr DummyTest::logger =
    log4cxx::Logger::getLogger(std::string("com.gitlab.cfs.platform.test.DummyTest"));

DummyTest::DummyTest()
    :  m_targetUnderTest()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

DummyTest::~DummyTest()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    if(m_targetUnderTest)
        delete m_targetUnderTest;
    m_targetUnderTest = nullptr;
}

void DummyTest::SetUp()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    m_targetUnderTest = new Dummy();
}

void DummyTest::TearDown()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

TEST_F(DummyTest, Test_Not_Yet_Implemented)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__);
}
