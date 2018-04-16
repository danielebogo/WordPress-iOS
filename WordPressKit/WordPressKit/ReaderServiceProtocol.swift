import Foundation


public protocol ReaderServiceSubscriptable {
    typealias SuccessBlock = () -> Void
    typealias FailureBlock = (NSError?) -> Void
}


public protocol SiteNotificationsSubscriptable: ReaderServiceSubscriptable {
    func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}


public protocol SitePostsSubscriptable: ReaderServiceSubscriptable {
    func subscribePostEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribePostEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func updateFrequencyPostEmail(with siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}


public protocol SiteCommentsSubscriptable: ReaderServiceSubscriptable {
    func subscribeSiteComment(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribeSiteComment(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}
