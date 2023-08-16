
#include <project/object/model/extra/GTestEventListener.hpp>

using namespace project::object::model::extra;
using namespace project::object::model::extra::test;
using namespace project::object::models::log;

log4cxx::LoggerPtr GTestEventListener::logger =
    log4cxx::Logger::getLogger(std::string("project.object.model.extra.GTestEventListener"));

GTestEventListener::GTestEventListener()
    :  m_currentTestCaseName("UKN")
    ,  m_currentTestName("UKN")
    ,  m_testCount(0)
    ,  m_failedTestCount(0)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );

    // const ::testing::TestInfo * const testInfo = ::testing::UnitTest::GetInstance()->current_test_info();
    // LOG4CXX_DEBUG(logger , ">>>>>>>>!!!!Test " << testInfo->name() << "!!!!>>>>>>>>");
    // LOG4CXX_DEBUG(logger , ">>>>>>>>!!!! Test Case" << testInfo->test_case_name() << " !!!!>>>>>>>>");
    // LOG4CXX_DEBUG(logger , ">>>>>>>>!!!!Star running unit test " << ::testing::UnitTest::GetInstance()->test_case_to_run_count() <<" !!!!>>>>>>>>");
    // LOG4CXX_DEBUG(logger , "Running unit test " <<  ::testing::UnitTest::GetInstance()->current_test_info());

}

GTestEventListener::~GTestEventListener()
{
    // LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnEnvironmentsSetUpStart(const testing::UnitTest & /*unit_test*/)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnEnvironmentsSetUpEnd(const testing::UnitTest & /*unit_test*/)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnTestSuiteStart(const testing::TestSuite & /*test_suite*/)
{
    LOG4CXX_INFO(logger, ">>>>>>>>!!!! Test Suite "<< m_currentTestName << " start !!!!>>>>>>>>");
}

void GTestEventListener::OnTestSuiteEnd(const testing::TestSuite & /*test_suite*/)
{
    LOG4CXX_INFO(logger, "<<<<<<<<!!!! Test Suite "<< m_currentTestName << " end !!!!<<<<<<<<");
}

void GTestEventListener::OnTestProgramStart(const testing::UnitTest& /*unit_test*/)
{
    // LOG4CXX_TRACE(logger, "unit test started" );
    LOG4CXX_INFO(logger, "UT to run: " << ::testing::UnitTest::GetInstance()->test_case_to_run_count());
}

void GTestEventListener::OnTestProgramEnd(const testing::UnitTest& unit_test)
{
    LOG4CXX_INFO(logger, "Test case finished: Pass(" << m_testCount
                                                     << "), Failed(" << m_failedTestCount << ")"
                                                     << " for elapsed time: (" << unit_test.elapsed_time() << " )");
}

void GTestEventListener::OnTestStart(const testing::TestInfo& test_info)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    ++m_testCount;
    m_currentTestCaseName = test_info.test_case_name();
    m_currentTestName =  test_info.name();

    //std::string tcn = std::string(test_info.name()) + "." + std::string(test_info.test_case_name());

    // LOG4CXX_TRACE(logger, "Test case: " << m_currentTestCaseName << " Test suite: (" << m_currentTestName << ")");
    LOG4CXX_INFO(logger, "Test suite: [" << m_currentTestName << "] of test case [" << m_currentTestCaseName << "]");
}

void GTestEventListener::OnTestEnd(const testing::TestInfo& test_info)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    if (test_info.result()->Failed())
    {
        LOG4CXX_WARN(logger,
                "Test case [" << m_currentTestCaseName << "] finished: " <<
                    " Test suite: " << m_currentTestName <<
                    " FAILED: " << !test_info.result()->Failed());
    }
    else
    {
        LOG4CXX_INFO(logger,
                "Test case [" << m_currentTestCaseName << "] finished: " <<
                    " Test suite: " << m_currentTestName <<
                    " GOOD: " << !test_info.result()->Failed());
    }

    if (test_info.result()->Failed())
        ++m_failedTestCount;
    m_currentTestCaseName.clear();
    m_currentTestName.clear();
}

void GTestEventListener::OnTestPartResult( const testing::TestPartResult& test_part_result)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    if (test_part_result.failed())
    {
        LOG4CXX_WARN(logger,
                "Test case failed : [" << m_currentTestCaseName << "] " <<
                    " Test suite: " << m_currentTestName <<
                    " File: " << test_part_result.file_name() <<
                    " Line: " << test_part_result.line_number() <<
                    " Summary: " << test_part_result.summary());

    }
}

void GTestEventListener::OnTestIterationEnd(const testing::UnitTest& unit_test, int iteration)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnTestIterationStart(const testing::UnitTest& /*unit_test*/, int /*iteration*/)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnEnvironmentsTearDownStart(const testing::UnitTest& /*unit_test*/)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void GTestEventListener::OnEnvironmentsTearDownEnd(const testing::UnitTest& /*unit_test*/)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}
