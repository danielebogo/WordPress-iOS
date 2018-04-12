import Foundation


extension ReaderTopicServiceRemote: ReaderTopicServiceSubscriptable {
    @nonobjc public func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, true, success, failure)
    }
    
    @nonobjc public func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, false, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func toggleSiteNotifications(with siteId: NSNumber, _ subscribe: Bool, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        let urlPath = baseUrlPath(with: siteId) + (subscribe ? "/new/" : "/delete/")
        guard let urlRequest = path(forEndpoint: urlPath, withVersion: ._2_0) else {
            let error = NSError(domain: "ReaderTopicServiceRemote", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid url request"])
            failure(error)
            return
        }
        
        DDLogInfo("URL: \(urlRequest)")
        
        wordPressComRestApi.POST(urlRequest, parameters: nil, success: { (_, _) in
            DDLogInfo("Success")
            success()
        }) { (error, _) in
            DDLogError("error: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    private func baseUrlPath(with siteId: NSNumber) -> String {
        return "read/sites/\(siteId.stringValue)/notification-subscriptions"
    }
}
