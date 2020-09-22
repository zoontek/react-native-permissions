#include "pch.h"
#include "ReactPackageProvider.h"
#include "ReactPackageProvider.g.cpp"

#include <ModuleRegistration.h>

#include "RNPermissions.h"

namespace winrt::RNPermissions::implementation
{
  void ReactPackageProvider::CreatePackage(IReactPackageBuilder const& packageBuilder) noexcept
  {
    AddAttributedModules(packageBuilder);
  }
}
