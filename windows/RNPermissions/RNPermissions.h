#pragma once

#include "pch.h"
#include "NativeModules.h"

namespace RNPermissions
{
  REACT_MODULE(RNPermissions);
  struct RNPermissions
  {
    React::ReactContext m_reactContext;
    REACT_INIT(Init);
    void Init(React::ReactContext const& reactContext) noexcept;

    REACT_METHOD(OpenSettings);
    void OpenSettings(React::ReactPromise<void>&& promise) noexcept;

    REACT_METHOD(CheckNotifications);
    void CheckNotifications(React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(Check);
    void Check(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;

    REACT_METHOD(Request);
    void Request(std::wstring permission, React::ReactPromise<std::string>&& promise) noexcept;
  };
}

