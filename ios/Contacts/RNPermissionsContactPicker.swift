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
          // Defer to the next runloop so UIKit finishes dismissing the
          // (out-of-process) picker before we tear down its host controller.
          DispatchQueue.main.async {
            onDismiss()
          }
        }
      }
  }
}

@available(iOS 18.0, *)
@objc(RNPermissionsContactPicker)
public class RNPermissionsContactPicker: NSObject {
  @objc public static func present(
    from viewController: UIViewController,
    completion: @escaping () -> Void
  ) {
    weak var host: UIHostingController<ContactAccessPickerView>?

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
