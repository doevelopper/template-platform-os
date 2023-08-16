
#ifndef PROJECT_OBJECT_MODEL_UTILS_POM_EXPORT_HPP
#define PROJECT_OBJECT_MODEL_UTILS_POM_EXPORT_HPP

#include <project/object/model/utils/CompilerDetection.hpp>
// #include <Poison.hpp>
// Generic helper definitions for shared library support
#if defined _WIN32 || defined __CYGWIN__
  #define POM_API_IMPORT __declspec(dllimport)
  #define POM_API_EXPORT __declspec(dllexport)
  #define POM_API_HIDDEN
#else
  #if __GNUC__ >= 4
    #define POM_API_IMPORT __attribute__ ((visibility ("default")))
    #define POM_API_EXPORT __attribute__ ((visibility ("default")))
    #define POM_API_HIDDEN  __attribute__ ((visibility ("hidden")))
  #else
    #define POM_API_IMPORT
    #define POM_API_EXPORT
    #define POM_API_HIDDEN
  #endif
#endif

// Now we use the generic helper definitions above to define POM_API and POM_LOCAL.
// POM_API is used for the public API symbols. It either DLL imports or DLL exports (or does nothing for static build)
// POM_LOCAL is used for non-api symbols.

#ifdef POM_DLL // defined if CFS is compiled as a DLL
  #ifdef POM_API_EXPORTS // defined if we are building the CFS DLL (instead of using it)
    #define POM_API POM_API_EXPORT
  #else
    #define POM_API POM_API_IMPORT
  #endif // POM_API_EXPORTS
  #define POM_LOCAL POM_API_HIDDEN
#else // POM_DLL is not defined: this means CFS is a static lib.
  #define POM_API
  #define POM_LOCAL
#endif // POM_DLL

#endif
