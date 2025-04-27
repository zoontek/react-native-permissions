#include "pch.h"

#include "RNPermissions.h"

using namespace winrt::Windows::System;
using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::UI::Core;
using namespace winrt::Windows::UI::Notifications;
using namespace winrt::Windows::Security::Authorization::AppCapabilityAccess;
using namespace std::literals;
using namespace RNPermissionsCodegen;

namespace winrt::RNPermissions
{

void RNPermissions::Initialize(React::ReactContext const &reactContext) noexcept {
  m_context = reactContext;
}

inline void RNPermissions::RNPermissions::OpenSettings(std::wstring type, React::ReactPromise<void>&& promise) noexcept {
  m_context.UIDispatcher().Post([promise]() {
    Launcher::LaunchUriAsync(Uri(L"ms-settings:appsfeatures-app"))
      .Completed([promise](const auto&, const auto& status) {
        if (status == AsyncStatus::Completed) {
          promise.Resolve();
        }
        else {
          promise.Reject("Failure");
        }
      });
    });
}

void RNPermissions::RNPermissions::OpenPhotoPicker(React::ReactPromise<bool>&& promise) noexcept {
  // no-op - iOS 14+ only
  promise.Resolve(false);
}

void RNPermissions::RNPermissions::CanScheduleExactAlarms(React::ReactPromise<bool>&& promise) noexcept {
  // no-op - Android only
  promise.Resolve(false);
}

void RNPermissions::RNPermissions::CanUseFullScreenIntent(React::ReactPromise<bool>&& promise) noexcept {
  // no-op - Android only
  promise.Resolve(false);
}

void RNPermissions::RNPermissions::CheckLocationAccuracy(React::ReactPromise<std::string>&& promise) noexcept {
  // no-op - iOS 14+ only
  promise.Resolve("N/A");
}

void RNPermissions::RNPermissions::CheckNotifications(React::ReactPromise<RNPermissionsSpec_NotificationsResponse>&& promise) noexcept {
  try {
    auto notifier = ToastNotificationManager::CreateToastNotifier();
    auto setting = notifier.Setting();
    RNPermissionsSpec_NotificationsResponse response;
    switch (setting) {
    case NotificationSetting::Enabled:
      response.status = "granted";
      break;
    case NotificationSetting::DisabledForApplication:
    case NotificationSetting::DisabledForUser:
    case NotificationSetting::DisabledByGroupPolicy:
    case NotificationSetting::DisabledByManifest:
      response.status = "blocked";
      break;
    default:
      response.status = "unavailable";
      break;
    }
    promise.Resolve(response);
  }
  catch (...) {
    RNPermissionsSpec_NotificationsResponse response;
    response.status = "unavailable";
    promise.Resolve(response);
  }
}

std::wstring_view trimmPermission(std::wstring_view permission) {
  auto prefix = L"windows.permission."sv;
  if (permission.size() >= prefix.size() &&
      permission.substr(0, prefix.size()).compare(prefix) == 0)
    permission.remove_prefix(prefix.size());
  return permission;
}

void RNPermissions::RNPermissions::Check(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept {
  try {
    auto capability = AppCapability::Create(trimmPermission(permission));
    switch (capability.CheckAccess()) {
    case AppCapabilityAccessStatus::Allowed:
      promise.Resolve("granted");
      break;
    case AppCapabilityAccessStatus::UserPromptRequired:
      promise.Resolve("denied");
      break;
    case AppCapabilityAccessStatus::DeniedByUser:
    case AppCapabilityAccessStatus::DeniedBySystem:
      promise.Resolve("blocked");
      break;
    case AppCapabilityAccessStatus::NotDeclaredByApp:
    default:
      promise.Resolve("unavailable");
      break;
    }
  }
  catch (...) {
    promise.Resolve("unavailable");
  }
}

void RNPermissions::RNPermissions::CheckMultiple(std::vector<std::string> permissions, React::ReactPromise<::React::JSValue>&& promise) noexcept {
  auto result = ::React::JSValueArray();
  for (auto& permission : permissions) {
    std::wstring wpermission(permission.begin(), permission.end());
    auto capability = AppCapability::Create(trimmPermission(wpermission));
    ::React::JSValueObject permissionStatus;
    permissionStatus["permission"] = permission;
    switch (capability.CheckAccess()) {
      case AppCapabilityAccessStatus::Allowed:
      permissionStatus["status"] = "granted";
      result.push_back(::React::JSValue(std::move(permissionStatus)));
    case AppCapabilityAccessStatus::UserPromptRequired:
      permissionStatus["status"] = "denied";
      result.push_back(::React::JSValue(std::move(permissionStatus)));
    case AppCapabilityAccessStatus::DeniedByUser:
    case AppCapabilityAccessStatus::DeniedBySystem:
      permissionStatus["status"] = "blocked";
      result.push_back(::React::JSValue(std::move(permissionStatus)));
    case AppCapabilityAccessStatus::NotDeclaredByApp:
    default:
      permissionStatus["status"] = "unavailable";
      result.push_back(::React::JSValue(std::move(permissionStatus)));
    }
  }
  promise.Resolve(::React::JSValue(std::move(result)));
}

void RNPermissions::RNPermissions::Request(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept {
  try {
    auto capability = AppCapability::Create(trimmPermission(permission));
    switch (capability.CheckAccess()) {
    case AppCapabilityAccessStatus::Allowed:
      promise.Resolve("granted");
      break;
    case AppCapabilityAccessStatus::UserPromptRequired:
      capability.RequestAccessAsync()
        .Completed([promise](const auto& async, const auto& status) {
          if (status == AsyncStatus::Completed) {
            if (async.GetResults() == AppCapabilityAccessStatus::Allowed) {
              promise.Resolve("granted");
            } else {
              promise.Resolve("denied");
            }
          }
          else {
            promise.Reject("Failure");
          }
        });
      break;
    case AppCapabilityAccessStatus::DeniedByUser:
    case AppCapabilityAccessStatus::DeniedBySystem:
      promise.Resolve("blocked");
      break;
    case AppCapabilityAccessStatus::NotDeclaredByApp:
    default:
      promise.Resolve("unavailable");
      break;
    }
  }
  catch (...) {
    promise.Resolve("unavailable");
  }
}

void RNPermissions::RNPermissions::RequestMultiple(std::vector<std::string> permissions, React::ReactPromise<::React::JSValue>&& promise) noexcept {
  auto result = ::React::JSValueArray();
  for (auto& permission : permissions) {
    std::wstring wpermission(permission.begin(), permission.end());
    auto capability = AppCapability::Create(trimmPermission(wpermission));
    ::React::JSValueObject permissionStatus;
    permissionStatus["permission"] = permission;
    switch (capability.CheckAccess()) {
      case AppCapabilityAccessStatus::Allowed:
      permissionStatus["status"] = "granted";
      result.push_back(::React::JSValue(std::move(permissionStatus)));
      case AppCapabilityAccessStatus::UserPromptRequired:
        capability.RequestAccessAsync()
          .Completed([&result, &permissionStatus, &promise](const auto& async, const auto& status) {
            if (status == AsyncStatus::Completed) {
              if (async.GetResults() == AppCapabilityAccessStatus::Allowed) {
                permissionStatus["status"] = "granted";
              } else {
                permissionStatus["status"] = "denied";
              }
            }
            else {
              permissionStatus["status"] = "Failure";
            }
            result.push_back(::React::JSValue(std::move(permissionStatus)));          });
      case AppCapabilityAccessStatus::DeniedByUser:
      case AppCapabilityAccessStatus::DeniedBySystem:
        permissionStatus["status"] = "blocked";
        result.push_back(::React::JSValue(std::move(permissionStatus)));
      case AppCapabilityAccessStatus::NotDeclaredByApp:
      default:
        permissionStatus["status"] = "unavailable";
        result.push_back(::React::JSValue(std::move(permissionStatus)));
    }
  }
  promise.Resolve(::React::JSValue(std::move(result)));
}

void RNPermissions::RNPermissions::RequestNotifications(std::vector<std::string> options, React::ReactPromise<RNPermissionsSpec_NotificationsResponse>&& promise) noexcept {
  // no-op - not available on Windows
  RNPermissionsSpec_NotificationsResponse response;
  response.status = "N/A";
  response.settings = ::React::JSValue::JSValue();
  promise.Resolve(response);
}

void RNPermissions::RNPermissions::RequestLocationAccuracy(std::wstring purposeKey, React::ReactPromise<std::string>&& promise) noexcept {
  // no-op - iOS 14+ only
  promise.Resolve("N/A");
}

void RNPermissions::RNPermissions::ShouldShowRequestRationale(std::wstring permission, React::ReactPromise<bool>&& promise) noexcept {
  // no-op - Android only
  promise.Resolve(false);
}

} // namespace winrt::RNPermissions
