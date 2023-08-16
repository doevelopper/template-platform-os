
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

#ifndef COM_GITLAB_CFS_PLATFORM_DUMMY_HPP
#define COM_GITLAB_CFS_PLATFORM_DUMMY_HPP

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

#include <rules/sdlc/std/logging/LoggingService.hpp>

#include <forward_list>
#include <string>

namespace com::gitlab::cfs::platform
{
    /*!
    * @brief The Dummy class used as walking Skeleton class for the unit, spec and feature tests of the template
    */
    class Dummy
    {
        LOG4CXX_DECLARE_STATIC_LOGGER
        enum class AnEnum : std::uint8_t
        {
            A,
            B,
            C,
            D
        };

    public:
        /*constexp*/ Dummy ( ) noexcept;
        /*constexp*/ explicit Dummy ( const std::string & hello_string, const std::string & world_string );
        Dummy ( const Dummy & ) noexcept = default;
        Dummy ( Dummy && ) noexcept      = default;
        Dummy & operator= ( const Dummy & ) noexcept = default;
        Dummy & operator= ( Dummy && ) noexcept = default;
        virtual ~Dummy ( ) noexcept;

        std::string                  speak ( ) const noexcept;
        bool                         speechless ( ) const noexcept;
        [[nodiscard]] constexpr bool isValid ( ) const noexcept;

        auto isDataReady ( ) const noexcept -> bool;

        auto operator++ ( ) noexcept -> Dummy &
        {
            ++m_idx;
            return *this;
        }

        auto operator-- ( ) noexcept -> Dummy &
        {
            --m_idx;
            return *this;
        }

        [[nodiscard]] auto size ( ) const -> std::size_t { return m_idx; }

    private:
        static constexpr auto ms_active_bit_cx ( std::size_t num ) noexcept -> std::size_t
        {
            auto result = std::size_t ( );
            while ( ( num >>= 1U ) != 0U )
            {
                ++result;
            }
            return result;
        }

        std::string  m_hello { };
        std::string  m_world { };
        bool         m_speechless { true };
        std::uint8_t m_idx;
    };

}
#endif
