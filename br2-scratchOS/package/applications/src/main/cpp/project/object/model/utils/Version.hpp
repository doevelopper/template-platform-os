
#ifndef PROJECT_OBJECT_MODEL_UTILS_VERSION_HPP
#define PROJECT_OBJECT_MODEL_UTILS_VERSION_HPP

#include <cassert>
#include <map>
#include <memory>
#include <type_traits>
#include <cstdint>
#include <sstream>
#include <string>
#include <regex>
#include <cstdint>
#include <cstddef>
#include <limits>
#include <iosfwd>
#include <optional>
#include <string_view>
#include <system_error>

#include <project/object/model/utils/POM_Export.hpp>
#include <project/object/model/utils/GitRevision.hpp>
#include <project/object/model/log/LoggingService.hpp>

#define RELEASE_INFO   RELEASE_LEVEL
#define RELEASE_SERIAL  0

/*!
 * @brief  True if the current version is newer than the given one.
 */
#define VERSION_GT( MAJOR, MINOR, PATCH )                              \
    (                                                                  \
        (VERSION_MAJOR > MAJOR) ||                                     \
        (VERSION_MAJOR == MAJOR &&                                     \
         (VERSION_MINOR > MINOR ||                                     \
          (VERSION_MINOR == MINOR &&                                   \
           VERSION_PATCH > PATCH)))                                    \
    )

/*!
 * @brief True if the current version is equal or newer to the given.
 */
#define VERSION_GE( MAJOR, MINOR, PATCH )                              \
    (                                                                  \
        (VERSION_MAJOR > MAJOR) ||                                     \
        (VERSION_MAJOR == MAJOR &&                                     \
         (VERSION_MINOR > MINOR ||                                     \
          (VERSION_MINOR == MINOR &&                                   \
           VERSION_PATCH >= PATCH)))                                   \
    )

/*!
 * @brief  True if the current version is older than the given one.
 */
#define VERSION_LT( MAJOR, MINOR, PATCH )                              \
    (                                                                  \
        (VERSION_MAJOR < MAJOR) ||                                     \
        (VERSION_MAJOR == MAJOR &&                                     \
         (VERSION_MINOR < MINOR  ||                                    \
          (VERSION_MINOR == MINOR &&                                   \
           VERSION_PATCH < PATCH)))                                    \
    )

/*!
 * @brief  True if the current version is older or equal to the given.
 */
#define VERSION_LE( MAJOR, MINOR, PATCH )                              \
    (                                                                  \
        (VERSION_MAJOR < MAJOR) ||                                     \
        (VERSION_MAJOR == MAJOR &&                                     \
         (VERSION_MINOR < MINOR  ||                                    \
          (VERSION_MINOR == MINOR &&                                   \
           VERSION_PATCH <= PATCH)))                                   \
    )


/*
 * These helper macros generate a numerical and alphanumerical (see http://www.semver.org) representation of the library version number, i.e
 *
 * | SemVer      | Numerical   | Comments
 * |-------------|-------------|------------------
 * | 2.1.0       | 0x020100FF  | final
 * | 2.1.1-beta  | 0x02010100  | first pre-release
 * | 2.1.1       | 0x020101FF  | final
 * | 2.2.0-beta.1 | 0x02020000  | 2nd pre-release
 * | 2.2.0-rc.1  | 0x02020001  |
 * | 2.2.0-rc.2  | 0x02020002  |
 * | 2.2.0       | 0x020200FF  | final
 * | 2.2.0-rc.1-rc1-7de458254[-dirty]`
 */
namespace project::object::model::utils
{

    constexpr int lSl = -1;
    constexpr int eSl = 0;
    constexpr int uSl = 1;

    /*!
     * @brief ReleaseLevel indicates the release level of this API
     *          This enum follows the release level convention used by python.
     * @ref https://docs.python.org/3/c-api/apiabiversion.html
     * @ref https://docs.python.org/3.7/c-api/apiabiversion.html
     * @ref https://hg.python.org/cpython/file/3.6/Include/patchlevel.h
     */

    enum
    class ReleaseLevel : std::uint8_t
    {
        SNAPSHOOT    = 0xD,  /**< API is not tested, work in progress. */
        ALPHA        = 0xA,  /**< API is in alpha state, i.e. work in progress. */
        BETA         = 0xB,  /**< API is in beta state, i.e. close to be finished. */
        CANDIDATE    = 0xC,  /**< API is in release candidate state. */
        FINAL        = 0xF,  /**< API is in final state, i.e. officially approved. */
    };

    const std::regex pieces_regex("([a-z]+)\\.([a-z]+)");
    const std::string nid = R"(0|[1-9]\d*)";

    class POM_API_EXPORT Version
    {
    LOG4CXX_DECLARE_STATIC_LOGGER

    public:

        Version();
        Version(const Version&) = delete;
        Version(Version&&) = delete;
        Version& operator=(const Version & rhs)
        {
            //if ((*this) != rhs)
            {
                //m_major = rhs.getMajor();
                //m_minor = rhs.getMinor();
                //m_patch = rhs.getPatch();
                //          m_releaseType = rhs.prerelease();
                //          m_extra = rhs.build();
                //          m_version = rhs.getRevString();
            }
            return *this;
        }
        Version& operator=(Version&&) = delete;
        virtual ~Version();
        explicit Version(const std::string& version);
        explicit Version(int major, int minor = 0, int patch = 0, std::string prerelease = "", std::string build = "");
        explicit operator bool() const
        {
            return m_major || m_minor || m_patch; // anything but 0.0.0
        }
        std::string to_string() const noexcept;

        [[nodiscard]]
        auto major() const &->const std::uint8_t &
        {
            return m_major;
        }
        [[nodiscard]]
        auto major() &&->std::uint8_t &&
        {
            return std::move(m_major);
        }
    //auto major() const -> const std::uint8_t & { return m_major; }
    //auto major() &      -> std::uint8_t &       { return m_major; }

    protected:

    private:

        void buildVersion(const std::smatch& sm);
        /*
           std::string _version_client() {
           if( version_major == "unknown" || version_major.empty() || version_minor == "unknown" || version_minor.empty()) {
             return "unknown";
           } else {
             std::string version{'v' + version_major + '.' + version_minor};
             if( !version_patch.empty() )  version += '.' + version_patch;
             if( !version_suffix.empty() ) version += '-' + version_suffix;
             return version;
           }
           }
           std::string _version_full()
           {
            if( m_major == "unknown"
         || m_major.empty()
         || m_minor == "unknown"
         || m_minor.empty())
              {
                return "unknown";
            }
            else
            {
                std::string version{'v' + m_major + '.' + m_minor};
                if( !m_patch.empty() )  version += '.' + m_patch;
                if( !version_suffix.empty() ) version += '-' + version_suffix;
                if( !version_hash.empty() )   version += '-' + version_hash;
                if( version_dirty )           version += "-dirty";
                return version;
              }
           }*/
        std::uint8_t m_major;                   ///< Major version, change only on incompatible API modifications.
        std::uint8_t m_minor;                   ///< Minor version, change on backwards-compatible API modifications.
        std::uint8_t m_patch;                   ///< Patch version, change only on bugfixes.
        ReleaseLevel m_releaseType;                 ///< Release identification.
        std::uint8_t m_tweak;                  ///< CI Build Identification.
        std::string m_extra;                   ///< GI sha1
        std::string m_version;
        std::ostringstream oss;

        /*!
         * @brief Regex to capture semantic version
         * @note The regex matches case insensitive
         *       (1) major version 0 or unlimited number
         *       (2) . minor version (0 or unlimited number)
         *       (3) . patch version (0 or unlimited number)
         *       (4) optional pre-release following a dash consisting of a alphanumeric letters
         *           and hyphens using a non-capture subclause to exclude the dash from the
         *           pre-release string
         *       (5) optional build following a plus consisting of alphanumeric letters and
         *           hyphens using a non-capture subclause to exclude the plus from the build string
         *           Metadata (build time, number, etc.)
         *     @see https://regex101.com/r/Ly7O1x/196
         */

        //	std::regex validVersionString(
        //      "^(0|[1-9][0-9]*)"                   // (1)
        //      "\\.(0|[1-9][0-9]*)"                 // (2)
        //			"\\.(0|[1-9][0-9]*)"                 // (3)
        //			"(?:\\-([0-9a-z-]+[\\.0-9a-z-]*))?"  // (4)
        //			"(?:\\+([0-9a-z-]+[\\.0-9a-z-]*))?"  // (5)
        //			, std::regex_constants::ECMAScript | std::regex_constants::icase);
        // ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[a-zA-Z\d][-a-zA-Z.\d]*)?(\+[a-zA-Z\d][-a-zA-Z.\d]*)?$
        //(?<Major>0|(?:[1-9]\d*))(?:\.(?<Minor>0|(?:[1-9]\d*))(?:\.(?<Patch>0|(?:[1-9]\d*)))?(?:\-(?<PreRelease>[0-9A-Z\.-]+))?(?:\+(?<Meta>[0-9A-Z\.-]+))?)?

        constexpr int compare (const Version &rhs) const noexcept;
        int compareVersion (const Version &rhs) const;
        auto to_string(Version const&) -> std::string;
    };

    /*
       auto operator<(Version const& lhs, Version const& rhs) noexcept -> bool;
       auto operator==(Version const & lhs, Version const & rhs) noexcept -> bool
       {
       return lhs.compareVersion(rhs) == eSl;
       }
       auto operator<=(Version const& lhs, Version const& rhs) noexcept -> bool
       {

       }
       auto operator!=(Version const& lhs, Version const& rhs) noexcept -> bool
       {

       }
       auto operator<<(std::ostream& lhs, Version const& rhs) -> std::ostream&
       {

       }
     */
}
#endif
