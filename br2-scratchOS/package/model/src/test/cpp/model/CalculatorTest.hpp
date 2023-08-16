
TEST(TestCalc, TestPos) 
{
    Calc calculate;
    EXPECT_EQ(10.0, calculate.add(5.0, 5.0));
    EXPECT_EQ(9, calculate.mul(3, 3));
    EXPECT_EQ(9, calculate.div(27, 3));
    EXPECT_EQ(9, calculate.sub(12, 3));
}
TEST(TestCalc, TestNeg)
{
    Calc calculate;
    EXPECT_EQ(-1.0, calculate.add(5.0, -6.0));
    EXPECT_EQ(-9, calculate.mul(3, -3));
    EXPECT_EQ(-9, calculate.div(27, -3));
    EXPECT_EQ(15, calculate.sub(12, -3));
}

TEST(TestCalc, TestZero)
{
    Calc calculate;
    EXPECT_EQ(10.0, calculate.add(5.0, 0));
    EXPECT_EQ(9, calculate.mul(3, 0));
    EXPECT_EQ(, calculate.div(27,0));
    EXPECT_EQ(12, calculate.sub(12,0));
}

TEST(TestCalc, ExpectThrowsSpecificException) {
    try {
        calculate.div(27,0);
        FAIL() << "calculate.div(27,0) should throw an error, since a     division by zero is not valid\n";
    } catch (TestException& exception) {
        EXPECT_THAT(std::string(exception.what()), Eq("VALID_SETTING"));
        EXPECT_THAT(exception.errorCode, Eq(20));
    }
}