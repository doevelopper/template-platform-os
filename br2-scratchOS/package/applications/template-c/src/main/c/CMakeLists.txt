project(template-c
#<major>.<minor>.<micro>.<patch>[.<tweak>][-rc<n>][-<date>][-<id>]
    VERSION 0.0.0.0
    DESCRIPTION "DEMO!"
    HOMEPAGE_URL "https://exemple.com"
    LANGUAGES CXX
)

target_compile_options(template-c
    PUBLIC
        $<$<CONFIG:Release>:-g0 -O2>
        $<$<COMPILE_LANGUAGE:CXX>:-DNDEBUG -O3 -pipe -W -Wall -Wextra -Weffc++ -Wpedantic -fmax-errors=5 -Werror=shadow -fdiagnostics-parseable-fixits>
        $<$<CONFIG:Debug>: -O0 -g -D_DEBUG -D_FORTIFY_SOURCE=2 -fno-strict-aliasing -fno-omit-frame-pointer>
        $<$<CONFIG:Release>:-g0 -O2>
        $<$<CONFIG:Coverage>:-O0  -fprofile-arcs -ftest-coverage --coverage>
        $<$<CONFIG:Profile>:-fsanitize=memory -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer>
)

target_compile_features(cfs.com.main
    PUBLIC
        cxx_std_17
)

target_include_directories(cfs.com.main
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cfs/com>
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/cfs/com/interface>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/cfs/com/internals>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/cfs/com/private>
        $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}>
        $<INSTALL_INTERFACE:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/cfs/com>
)