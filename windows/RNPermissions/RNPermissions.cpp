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

} // namespace winrt::RNPermissions