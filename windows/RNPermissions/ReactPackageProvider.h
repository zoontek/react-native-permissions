#pragma once

#include "ReactPackageProvider.g.h"

using namespace winrt::Microsoft::ReactNative;

namespace winrt::RNPermissions::implementation
{
  struct ReactPackageProvider : ReactPackageProviderT<ReactPackageProvider>
  {
    ReactPackageProvider() = default;

    void CreatePackage(IReactPackageBuilder const& packageBuilder) noexcept;
  };
}

namespace winrt::RNPermissions::factory_implementation
{
  struct ReactPackageProvider : ReactPackageProviderT<ReactPackageProvider, implementation::ReactPackageProvider> {};
}
