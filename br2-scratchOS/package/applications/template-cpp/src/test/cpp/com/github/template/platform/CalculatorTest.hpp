#ifndef MSF_EMS_DHS_CALCULATORTEST_HPP
#define MSF_EMS_DHS_CALCULATORTEST_HPP

#include <msf/ems/dhs/Calculator.hpp>

namespace msf::ems:dhs
{
    class CalculatorTest : public ::testing::Test
    {
    LOG4CXX_DECLARE_STATIC_TEST_LOGGER

    public:

        CalculatorTest();
        CalculatorTest(const CalculatorTest&) = delete;
        CalculatorTest(CalculatorTest&&) = delete;
        CalculatorTest& operator=(const CalculatorTest&) = delete;
        CalculatorTest& operator=(CalculatorTest&&) = delete;
        virtual ~CalculatorTest();

        void SetUp() override;
        void TearDown() override;

    protected:

    private:

        msf::ems:dhs::Calculator * m_objectUnderTest;
    };
}
#endif