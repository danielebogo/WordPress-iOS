import Foundation
import WordPressFlux


protocol Subscriptable {
    func managedObjectContext() -> NSManagedObjectContext
}

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
    
    func toggleSubscribingNotificationsFor(siteID: NSNumber?, subscribe: Bool) {
        guard let siteID = siteID else {
            return
        }
        
        let service = ReaderTopicService(managedObjectContext: managedObjectContext())
        
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
    
    /// Retrieves an existing object for the specified object ID from the display context.
    ///
    /// - Parameters:
    ///     - objectID: The object ID of the post.
    ///
    /// - Return: The matching post or nil if there is no match.
    ///
    func existingObjectFor<T>(objectID: NSManagedObjectID?) -> T? {
        guard let objectID = objectID else {
            return nil
        }
        
        do {
            return (try managedObjectContext().existingObject(with: objectID)) as? T
        } catch let error as NSError {
            DDLogError(error.localizedDescription)
            return nil
        }
    }
}
