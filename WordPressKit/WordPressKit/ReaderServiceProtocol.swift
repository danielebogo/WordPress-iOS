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
    func subscribePostsEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribePostsEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func updateFrequencyPostsEmail(with siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}


public protocol SiteCommentsSubscriptable: ReaderServiceSubscriptable {
    func subscribeSiteComments(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribeSiteComments(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}
