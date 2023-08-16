

#include <project/object/model/launcher/OptionDescription.hpp>
#include <project/object/model/log/LoggingService.hpp>

using namespace project::object::model::launcher;

OptionDescription::OptionDescription()
{

}

OptionDescription::OptionDescription(boost::shared_ptr<boost::program_options::option_description> option) noexcept
{

}

OptionDescription::~OptionDescription()
{

}

std::string OptionDescription::usage()
{

}

void OptionDescription::checkIfPositional(const boost::program_options::positional_options_description& positionalDesc)
{

}
