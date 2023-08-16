#include <iostream>
#include <cstdlib>

int main(
    [[maybe_unused]] int argc, 
    [[maybe_unused]]char**argv
) 
{
    std::cout << "TEST CPP-101: C++ Object Oriented Programming!" << std::endl;
    std::cout << "Simple and obvious Unit test frameworks" << std::endl;
    std::cout << "Each Test module should be able to have many small test cases." << std::endl;

    return (EXIT_SUCCESS);
}
