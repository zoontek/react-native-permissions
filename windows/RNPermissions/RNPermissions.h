#pragma once

#include "pch.h"
#include "resource.h"

#include <NativeModules.h>

#include "codegen/NativeRnPermissionsDataTypes.g.h"
#include "codegen/NativeRnPermissionsSpec.g.h"

using namespace RNPermissionsCodegen;
namespace winrt::RNPermissions
{

REACT_MODULE(RNPermissions)
struct RNPermissions
{
  using ModuleSpec = RNPermissionsCodegen::RNPermissionsSpec;

    REACT_INIT(Initialize);
    void Initialize(React::ReactContext const& reactContext) noexcept;

    REACT_METHOD(OpenSettings, L"openSettings");
    void OpenSettings(std::wstring type, React::ReactPromise<void>&& promise) noexcept;

    REACT_METHOD(CheckNotifications, L"checkNotifications");
    void CheckNotifications(React::ReactPromise<RNPermissionsSpec_NotificationsResponse>&& promise) noexcept;

    REACT_METHOD(Check, L"check");
    void Check(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(Request, L"request");
    void Request(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

private:
  React::ReactContext m_context;
};

} // namespace winrt::RNPermissions