import Foundation


public protocol ReaderServiceProtocol {
    typealias SuccessBlock = () -> Void
    typealias FailureBlock = (NSError?) -> Void
}

public protocol ReaderTopicServiceSubscriptable: ReaderServiceProtocol {
    func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
    func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock)
}
