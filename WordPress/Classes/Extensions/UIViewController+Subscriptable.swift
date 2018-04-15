import Foundation
import WordPressFlux


protocol Subscriptable { }

extension Subscriptable where Self: UIViewController {
    func dispatchNoticeWith(siteTitle: String?, siteID: NSNumber?) {
        guard let siteTitle = siteTitle, let siteID = siteID else {
            return
        }
        
        let localizedTitle = NSLocalizedString("Following %@", comment: "Localized title for the Notice to prompt")
        let title = String(format: localizedTitle, siteTitle)
        let message = NSLocalizedString("Enable site notifications?", comment: "Notice message text")
        let buttonTitle = NSLocalizedString("Enable", comment: "Notice button title text")
        
        let notice = Notice(title: title,
                            message: message,
                            feedbackType: .success,
                            notificationInfo: nil,
                            actionTitle: buttonTitle) { [weak self] in
                                self?.toggleSubscribingNotificationsFor(siteID: siteID, subscribe: true)
        }
        ActionDispatcher.dispatch(NoticeAction.post(notice))
    }
    
    func toggleSubscribingNotificationsFor(siteID: NSNumber?, subscribe: Bool, displayContext: NSManagedObjectContext = ContextManager.sharedInstance().newMainContextChildContext()) {
        guard let siteID = siteID else {
            return
        }
        
        let service = ReaderTopicService(managedObjectContext: displayContext)
        
        let success = {
            DDLogInfo("Success turn on notifications")
        }
        
        let failure = { (error: NSError?) in
            DDLogError("Error turn on notifications: \(error?.localizedDescription ?? "unknown error")")
        }
        
        if subscribe {
            service.subscribeSiteNotifications(with: siteID, success, failure)
        } else {
            service.unsubscribeSiteNotifications(with: siteID, success, failure)
        }
    }
}
