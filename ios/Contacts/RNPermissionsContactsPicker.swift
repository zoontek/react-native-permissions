#if os(iOS)
import ContactsUI
import SwiftUI
import UIKit

@available(iOS 18.0, *)
private struct ContactAccessPickerView: View {
  @State private var isPresented = false
  let onDismiss: () -> Void

  var body: some View {
    Color.clear
      .contactAccessPicker(isPresented: $isPresented) { _ in }
      .onAppear { isPresented = true }
      .onChange(of: isPresented) { _, visible in
        if !visible {
          onDismiss()
        }
      }
  }
}

@available(iOS 18.0, *)
@objc(RNPermissionsContactsPicker)
public class RNPermissionsContactsPicker: NSObject {
  @objc public static func present(
    from viewController: UIViewController,
    completion: @escaping () -> Void
  ) {
    var host: UIHostingController<ContactAccessPickerView>?

    let controller = UIHostingController(rootView: ContactAccessPickerView {
      host?.dismiss(animated: false, completion: completion)
    })

    controller.modalPresentationStyle = .overFullScreen
    controller.view.backgroundColor = .clear
    host = controller

    viewController.present(controller, animated: false)
  }
}
#endif
