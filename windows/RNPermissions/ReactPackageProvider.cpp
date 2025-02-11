#include "pch.h"

#include "ReactPackageProvider.h"
#if __has_include("ReactPackageProvider.g.cpp")
#include "ReactPackageProvider.g.cpp"
#endif

#include "RNPermissions.h"

using namespace winrt::Microsoft::ReactNative;

namespace winrt::RNPermissions::implementation
{

void ReactPackageProvider::CreatePackage(IReactPackageBuilder const &packageBuilder) noexcept
{
  #ifdef RnwNewArch      
    AddAttributedModules(packageBuilder, true);  
  #else      
    AddAttributedModules(packageBuilder);  
  #endif
}

} // namespace winrt::RNPermissions::implementation
