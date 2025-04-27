
/*
 * This file is auto-generated from a NativeModule spec file in js.
 *
 * This is a C++ Spec class that should be used with MakeTurboModuleProvider to register native modules
 * in a way that also verifies at compile time that the native module matches the interface required
 * by the TurboModule JS spec.
 */
#pragma once
// clang-format off

// #include "NativeRNPermissionsDataTypes.g.h" before this file to use the generated type definition
#include <NativeModules.h>
#include <tuple>

namespace RNPermissionsCodegen {

inline winrt::Microsoft::ReactNative::FieldMap GetStructInfo(RNPermissionsSpec_NotificationsResponse*) noexcept {
    winrt::Microsoft::ReactNative::FieldMap fieldMap {
        {L"status", &RNPermissionsSpec_NotificationsResponse::status},
        {L"settings", &RNPermissionsSpec_NotificationsResponse::settings},
    };
    return fieldMap;
}

struct RNPermissionsSpec : winrt::Microsoft::ReactNative::TurboModuleSpec {
  static constexpr auto methods = std::tuple{
      Method<void(Promise<bool>) noexcept>{0, L"canScheduleExactAlarms"},
      Method<void(Promise<bool>) noexcept>{0, L"canUseFullScreenIntent"},
      Method<void(std::string, Promise<std::string>) noexcept>{1, L"check"},
      Method<void(Promise<std::string>) noexcept>{2, L"checkLocationAccuracy"},
      Method<void(std::vector<std::string>, Promise<::React::JSValue>) noexcept>{3, L"checkMultiple"},
      Method<void(Promise<RNPermissionsSpec_NotificationsResponse>) noexcept>{4, L"checkNotifications"},
      Method<void(Promise<bool>) noexcept>{5, L"openPhotoPicker"},
      Method<void(std::string, Promise<void>) noexcept>{6, L"openSettings"},
      Method<void(std::string, Promise<std::string>) noexcept>{7, L"request"},
      Method<void(std::string, Promise<std::string>) noexcept>{8, L"requestLocationAccuracy"},
      Method<void(std::vector<std::string>, Promise<::React::JSValue>) noexcept>{9, L"requestMultiple"},
      Method<void(std::vector<std::string>, Promise<RNPermissionsSpec_NotificationsResponse>) noexcept>{10, L"requestNotifications"},
      Method<void(std::string, Promise<bool>) noexcept>{11, L"shouldShowRequestRationale"},
  };

  template <class TModule>
  static constexpr void ValidateModule() noexcept {
    constexpr auto methodCheckResults = CheckMethods<TModule, RNPermissionsSpec>();

    REACT_SHOW_METHOD_SPEC_ERRORS(
          0,
          "canScheduleExactAlarms",
          "    REACT_METHOD(canScheduleExactAlarms) void canScheduleExactAlarms(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(canScheduleExactAlarms) static void canScheduleExactAlarms(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          0,
          "canUseFullScreenIntent",
          "    REACT_METHOD(canUseFullScreenIntent) void canUseFullScreenIntent(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(canUseFullScreenIntent) static void canUseFullScreenIntent(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          1,
          "check",
          "    REACT_METHOD(check) void check(std::string permission, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(check) static void check(std::string permission, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          2,
          "checkLocationAccuracy",
          "    REACT_METHOD(checkLocationAccuracy) void checkLocationAccuracy(::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(checkLocationAccuracy) static void checkLocationAccuracy(::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          3,
          "checkMultiple",
          "    REACT_METHOD(checkMultiple) void checkMultiple(std::vector<std::string> const & permissions, ::React::ReactPromise<::React::JSValue> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(checkMultiple) static void checkMultiple(std::vector<std::string> const & permissions, ::React::ReactPromise<::React::JSValue> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          4,
          "checkNotifications",
          "    REACT_METHOD(checkNotifications) void checkNotifications(::React::ReactPromise<RNPermissionsSpec_NotificationsResponse> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(checkNotifications) static void checkNotifications(::React::ReactPromise<RNPermissionsSpec_NotificationsResponse> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          5,
          "openPhotoPicker",
          "    REACT_METHOD(openPhotoPicker) void openPhotoPicker(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(openPhotoPicker) static void openPhotoPicker(::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          6,
          "openSettings",
          "    REACT_METHOD(openSettings) void openSettings(std::string type, ::React::ReactPromise<void> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(openSettings) static void openSettings(std::string type, ::React::ReactPromise<void> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          7,
          "request",
          "    REACT_METHOD(request) void request(std::string permission, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(request) static void request(std::string permission, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          8,
          "requestLocationAccuracy",
          "    REACT_METHOD(requestLocationAccuracy) void requestLocationAccuracy(std::string purposeKey, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(requestLocationAccuracy) static void requestLocationAccuracy(std::string purposeKey, ::React::ReactPromise<std::string> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          9,
          "requestMultiple",
          "    REACT_METHOD(requestMultiple) void requestMultiple(std::vector<std::string> const & permissions, ::React::ReactPromise<::React::JSValue> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(requestMultiple) static void requestMultiple(std::vector<std::string> const & permissions, ::React::ReactPromise<::React::JSValue> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          10,
          "requestNotifications",
          "    REACT_METHOD(requestNotifications) void requestNotifications(std::vector<std::string> const & options, ::React::ReactPromise<RNPermissionsSpec_NotificationsResponse> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(requestNotifications) static void requestNotifications(std::vector<std::string> const & options, ::React::ReactPromise<RNPermissionsSpec_NotificationsResponse> &&result) noexcept { /* implementation */ }\n");
    REACT_SHOW_METHOD_SPEC_ERRORS(
          11,
          "shouldShowRequestRationale",
          "    REACT_METHOD(shouldShowRequestRationale) void shouldShowRequestRationale(std::string permission, ::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n"
          "    REACT_METHOD(shouldShowRequestRationale) static void shouldShowRequestRationale(std::string permission, ::React::ReactPromise<bool> &&result) noexcept { /* implementation */ }\n");
  }
};

} // namespace RNPermissionsCodegen
