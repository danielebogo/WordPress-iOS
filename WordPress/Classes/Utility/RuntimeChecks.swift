import Foundation

private let rules: [Rule] = [
    NoAlignLeftRule(),
    CellsAccessibilityLabelRule()
]

protocol Rule {
    var name: String { get }
    var description: String { get }

    func apply(on view: UIView) -> Bool
    func printError(for view: UIView, in viewController: UIViewController)
}

extension Rule {
    func printError(for view: UIView, in viewController: UIViewController) {
        let address = unsafeBitCast(view, to: Int.self)
        DDLogWarn("⚠️ Violation of rule '\(name)': \(description). \n<\(type(of: view)): \(String(format: "%p", address))>, in \(viewController)")
    }
}

struct NoAlignLeftRule: Rule {
    let name = "no_align_left"
    let description = "No label should set its alignment to `left` directly. Use alignment `natural` instead"

    func apply(on view: UIView) -> Bool {
        if let label = view as? UILabel {
            if label.textAlignment == .left {
                return false
            }
        }
        return true
    }
}

struct CellsAccessibilityLabelRule: Rule {
    let name = "cells_accessibility_label"
    let description = "Complex cells should have an accessibility label describing the content of them"

    func apply(on view: UIView) -> Bool {
        if let cell = view as? UITableViewCell,
            cell.contentView.subviews.count > 3,
            cell.isAccessibilityElement == false ||
            cell.accessibilityLabel == nil {

            return false
        }

        return true
    }
}

extension UIViewController {
    @objc func runtimeLinter(_ animated: Bool) {
        self.runtimeLinter(animated) // this calls the original viewDidAppear implementation.

        if (self is UINavigationController || self is UITabBarController || self is UISplitViewController) {
            return
        }
        checkForSubviews(self.view)
    }

    private func shouldInspectSubviews(_ view: UIView) -> Bool {
        if view is UIButton ||
            view is UISearchBar ||
            view is UITableViewCell {
            return false
        }

        return true
    }

    private func checkForSubviews(_ view: UIView) {
        applyRules(to: view)

        if shouldInspectSubviews(view) {
            for subView in view.subviews {
                checkForSubviews(subView)
            }
        }
    }

    private func applyRules(to view: UIView) {
        rules.forEach {
            if $0.apply(on: view) == false {
                $0.printError(for: view, in: self)
            }
        }
    }

    // MARK: - Swizzle Implementation

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
