
#include <project/object/model/utils/Version.hpp>

using namespace project::object::model::utils;


log4cxx::LoggerPtr Version::logger =
    log4cxx::Logger::getLogger(std::string("cfs.utils.sv.Version"));


Version::Version()
    : m_major()
    , m_minor()
    , m_patch()
    , m_releaseType(ReleaseLevel::SNAPSHOOT)
    , m_tweak()
    , m_extra()
    , m_version()

{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    oss << " written using "
        << " ("
#if defined(__INTEL_COMPILER)
        << "Intel "
        << __INTEL_COMPILER << " " << __INTEL_COMPILER_BUILD_DATE
#elif defined(__GNUC__)
        << "GNU "
        << __GNUC__ << "." << __GNUC_MINOR__ << "." << __GNUC_PATCHLEVEL__
#else
        << "unknown compiler"
#endif
        << ')';
}

Version::Version(const std::string& version)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
    std::smatch match;

    //if (std::regex_match(version, match, std::regex(FULL)))
    {
    }
}

Version::~Version()
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );
}

void Version::buildVersion(const std::smatch& strMatch)
{
    LOG4CXX_TRACE(logger, __LOG4CXX_FUNC__ );

    const auto isOk = [](const auto& m){
                          return m.matched;
                      };
    const auto cnt = std::count_if(strMatch.begin(), strMatch.end(), isOk);
/*
   <version core> ::= <major> "." <minor> "." <patch>
   <valid semver> ::= <version core>
 | <version core> "-" <pre-release>
 | <version core> "+" <build>
 | <version core> "-" <pre-release> "+" <build>
 */

    // major.minor.patch-pre-release1.pre-release2+build1.build2.build3
    switch (cnt)
    {
/*
                case 6: // build meta data ([P1, P2, P3])
                    build = split(sm[5].str(), '.');
                    [[fallthrough]];
                case 5: // pre-release version ([B1, B2])
                    pre = split(sm[4].str(), '.');
                    [[fallthrough]];
                case 4: // patch version (Z)
                    patch = std::stoull(sm[3].str());
                    [[fallthrough]];
                case 3: // minor version (Y)
                    minor = std::stoull(sm[2].str());
                    [[fallthrough]];
                case 2: // major version (X)
                    major = std::stoull(sm[1].str());
                    [[fallthrough]];
                default:
                    break;
 */
    }
}

//int Version::compare (const Version &rhs) const noexcept
//{

//}

int Version::compareVersion (const Version &rhs) const
{

    if (m_major != rhs.m_major)
        return m_major < rhs.m_major ? lSl : uSl;

    if (m_minor != rhs.m_minor)
        return m_minor < rhs.m_minor ? lSl : uSl;

    if (m_patch != rhs.m_patch)
        return m_patch < rhs.m_patch ? lSl : uSl;

    if (m_releaseType != rhs.m_releaseType)
        return m_releaseType < rhs.m_releaseType ? lSl : uSl;

    return(eSl);
}

std::string Version::to_string() const noexcept
{
    std::string v = std::to_string(m_major) + '.' +
                    std::to_string(m_minor) + '.' +
                    std::to_string(m_patch);
    switch (m_releaseType)
    {

        case ReleaseLevel::SNAPSHOOT:
            v.append("-SNAPSHOOT");
            break;

        case ReleaseLevel::ALPHA:
            v.append("-alpha");
            v.append(std::to_string(m_tweak));
            break;

        case ReleaseLevel::BETA:
            v.append("-beta");
            v.append(std::to_string(m_tweak));
            break;

        case ReleaseLevel::CANDIDATE:
            v.append("-rc");
            v.append(std::to_string(m_tweak));
            break;

        default:
            break;
    }

    //m_version = std::string(v);
    //m_version.assign(v, 0, v.length()-1);
    return (v);
}
