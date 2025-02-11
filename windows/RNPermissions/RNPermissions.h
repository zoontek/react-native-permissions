#pragma once

#include "pch.h"
#include "resource.h"

#include "codegen/NativeRnPermissionsDataTypes.g.h"
#include "codegen/NativeRnPermissionsSpec.g.h"

#include "NativeModules.h"

namespace winrt::RNPermissions
{

REACT_MODULE(RNPermissions)
struct RNPermissions
{
  using ModuleSpec = RNPermissionsCodegen::RNPermissionsSpec;

    REACT_INIT(Initialize);
    void Initialize(React::ReactContext const& reactContext) noexcept;

    REACT_METHOD(OpenSettings);
    void OpenSettings(React::ReactPromise<void>&& promise) noexcept;

    REACT_METHOD(CheckNotifications);
    void CheckNotifications(React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(Check);
    void Check(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(Request);
    void Request(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

private:
  React::ReactContext m_context;
};

} // namespace winrt::RNPermissions