import Foundation

extension UIViewController {
    @objc func runtimeLinter(_ animated: Bool) {
        print("Subviews: ")
        print(self.view.subviews.count)
        if (self is UINavigationController || self is UITabBarController || self is UISplitViewController) {
            return
        }
        checkForSubviews(self.view)
    }

    private func checkForSubviews(_ view: UIView) {
        applyRules(to: view)

        if view is UIButton ||
            view is UISearchBar ||
            view is UITableViewCell {
            return
        }

        for subView in view.subviews {
            checkForSubviews(subView)
        }
    }

    private func applyRules(to view: UIView) {
        applyRuleAccessibilityLabel(to: view)
    }

    private func applyRuleAccessibilityLabel(to view: UIView) {
        if view is UILabel || view is UIButton {
            if view.accessibilityLabel == nil {
                let address = unsafeBitCast(view, to: Int.self)
                DDLogWarn("⚠️♿️ Accessibility label missing in <\(type(of: view)): \(String(format: "%p", address))>, in \(self)")
            }
        }
    }

    private func applyRuleNotAlignLeft(to view: UIView) {
        if let label = view as? UILabel {
            if label.textAlignment == .left {
                DDLogWarn("⚠️ :Runtime Check: Forced align left found \(type(of: label)): '\(label.text ?? "")', in \(self)")
            }
        }
    }

    private static let swizzleViewDidLoadImplementation: Void = {
        let aClass: AnyClass = UIViewController.self
        let originalMethod = class_getInstanceMethod(aClass, #selector(viewDidAppear(_:)))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(runtimeLinter(_:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @objc public static func swizzleViewDidLoad() {
        _ = self.swizzleViewDidLoadImplementation
    }
}
