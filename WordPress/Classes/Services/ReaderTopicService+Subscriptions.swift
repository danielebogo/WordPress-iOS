import Foundation
import WordPressKit


extension ReaderTopicService: ReaderTopicServiceSubscriptable {
    @nonobjc public func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, true, success, failure)
    }
    
    @nonobjc public func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, false, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func toggleSiteNotifications(with siteId: NSNumber, _ subscribe: Bool, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        guard let siteTopic = findSiteTopic(withSiteID: siteId) else {
            let error = NSError(domain: "ReaderTopicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No topic found"])
            failure(error)
            return
        }
        
        if siteTopic.postSubscription == nil {
            siteTopic.postSubscription = NSEntityDescription.insertNewObject(forEntityName: ReaderSiteInfoSubscriptionPost.classNameWithoutNamespaces(),
                                                                             into: managedObjectContext) as? ReaderSiteInfoSubscriptionPost
            ContextManager.sharedInstance().saveContextAndWait(managedObjectContext)
        }
        
        let oldValue = !subscribe
        siteTopic.postSubscription?.sendPosts = subscribe
        
        let successBlock: SuccessBlock = {
            ContextManager.sharedInstance().save(self.managedObjectContext, withCompletionBlock: success)
        }
        
        let failureBlock: FailureBlock = { (error: NSError?) in
            guard let siteTopic = self.findSiteTopic(withSiteID: siteId) else {
                failure(nil)
                return
            }
            siteTopic.postSubscription?.sendPosts = oldValue
            ContextManager.sharedInstance().save(self.managedObjectContext){
                failure(error)
            }
        }
        
        let service = ReaderTopicServiceRemote(wordPressComRestApi: apiRequest())
        
        if subscribe {
            service?.subscribeSiteNotifications(with: siteId, successBlock, failureBlock)
        } else {
            service?.unsubscribeSiteNotifications(with: siteId, successBlock, failureBlock)
        }
    }
    
    private func apiRequest() -> WordPressComRestApi {
        let accountService = AccountService(managedObjectContext: managedObjectContext)
        let defaultAccount = accountService.defaultWordPressComAccount()
        if let api = defaultAccount?.wordPressComRestApi, api.hasCredentials() {
            return api
        }
        
        return WordPressComRestApi(oAuthToken: nil, userAgent: WPUserAgent.wordPress())
    }
}
