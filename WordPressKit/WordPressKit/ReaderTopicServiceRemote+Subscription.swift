import Foundation


extension ReaderTopicServiceRemote {
    private func POST(with request: ReaderServiceSubscriptionsRequest, parameters: [String: AnyObject]? = nil, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
        guard let urlRequest = path(forEndpoint: request.path, withVersion: request.apiVersion) else {
            let error = NSError(domain: "ReaderTopicServiceRemote", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid url request"])
            failure(error)
            return
        }
        
        DDLogInfo("URL: \(urlRequest)")
        
        wordPressComRestApi.POST(urlRequest, parameters: parameters, success: { (_, _) in
            DDLogInfo("Success")
            success()
        }) { (error, _) in
            DDLogError("error: \(error.localizedDescription)")
            failure(error)
        }
    }
}


extension ReaderTopicServiceRemote: SiteNotificationsSubscriptable {
    @nonobjc public func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .notifications(siteId: siteId, action: .subscribe), success: success, failure: failure)
    }
    
    @nonobjc public func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .notifications(siteId: siteId, action: .unsubscribe), success: success, failure: failure)
    }
}


extension ReaderTopicServiceRemote: SiteCommentsSubscriptable {
    @nonobjc public func subscribeSiteComment(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .comments(siteId: siteId, action: .subscribe), success: success, failure: failure)
    }
    
    @nonobjc public func unsubscribeSiteComment(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .comments(siteId: siteId, action: .unsubscribe), success: success, failure: failure)
    }
}


extension ReaderTopicServiceRemote: SitePostsSubscriptable {
    @nonobjc public func subscribePostEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .postsEmail(siteId: siteId, action: .subscribe), success: success, failure: failure)
    }
    
    @nonobjc public func unsubscribePostEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        POST(with: .postsEmail(siteId: siteId, action: .unsubscribe), success: success, failure: failure)
    }
    
    @nonobjc public func updateFrequencyPostEmail(with siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        let parameters = [WordPressKitConstants.SiteSubscription.Delivery.frequency: NSString(string: frequency.rawValue)]
        POST(with: .postsEmail(siteId: siteId, action: .update), parameters: parameters, success: success, failure: failure)
    }
}
