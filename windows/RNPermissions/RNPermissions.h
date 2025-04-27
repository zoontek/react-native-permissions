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

    REACT_METHOD(OpenPhotoPicker, L"openPhotoPicker");
    void OpenPhotoPicker(React::ReactPromise<bool>&& promise) noexcept;

    REACT_METHOD(CanScheduleExactAlarms, L"canScheduleExactAlarms");
    void CanScheduleExactAlarms(React::ReactPromise<bool>&& promise) noexcept;

    REACT_METHOD(CanUseFullScreenIntent, L"canUseFullScreenIntent");
    void CanUseFullScreenIntent(React::ReactPromise<bool>&& promise) noexcept;

    REACT_METHOD(CheckLocationAccuracy, L"checkLocationAccuracy");
    void CheckLocationAccuracy(React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(CheckNotifications, L"checkNotifications");
    void CheckNotifications(React::ReactPromise<RNPermissionsSpec_NotificationsResponse>&& promise) noexcept;

    REACT_METHOD(Check, L"check");
    void Check(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(CheckMultiple, L"checkMultiple");
    void CheckMultiple(std::vector<std::string> permissions, React::ReactPromise<::React::JSValue>&& promise) noexcept;

    REACT_METHOD(Request, L"request");
    void Request(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(RequestMultiple, L"requestMultiple");
    void RequestMultiple(std::vector<std::string> permissions, React::ReactPromise<::React::JSValue>&& promise) noexcept;

    REACT_METHOD(RequestNotifications, L"requestNotifications");
    void RequestNotifications(std::vector<std::string> options, React::ReactPromise<RNPermissionsSpec_NotificationsResponse>&& promise) noexcept;

    REACT_METHOD(RequestLocationAccuracy, L"requestLocationAccuracy");
    void RequestLocationAccuracy(std::wstring purposeKey, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(ShouldShowRequestRationale, L"shouldShowRequestRationale");
    void ShouldShowRequestRationale(std::wstring permission, React::ReactPromise<bool>&& promise) noexcept;

private:
  React::ReactContext m_context;
};

} // namespace winrt::RNPermissions
