import Foundation
import WordPressKit


private enum SubscriptionAction {
    case notifications
    case postsEmail
    case comments
}

extension ReaderTopicService {
    private func apiRequest() -> WordPressComRestApi {
        let accountService = AccountService(managedObjectContext: managedObjectContext)
        let defaultAccount = accountService.defaultWordPressComAccount()
        if let api = defaultAccount?.wordPressComRestApi, api.hasCredentials() {
            return api
        }
        
        return WordPressComRestApi(oAuthToken: nil, userAgent: WPUserAgent.wordPress())
    }
    
    private func fetchSiteTopic(with siteId: NSNumber, _ failure: @escaping FailureBlock) -> ReaderSiteTopic? {
        guard let siteTopic = findSiteTopic(withSiteID: siteId) else {
            let error = NSError(domain: "ReaderTopicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No topic found"])
            failure(error)
            return nil
        }
        
        if siteTopic.postSubscription == nil {
            siteTopic.postSubscription = NSEntityDescription.insertNewObject(forEntityName: ReaderSiteInfoSubscriptionPost.classNameWithoutNamespaces(),
                                                                             into: managedObjectContext) as? ReaderSiteInfoSubscriptionPost
        }
        
        if siteTopic.emailSubscription == nil {
            siteTopic.emailSubscription = NSEntityDescription.insertNewObject(forEntityName: ReaderSiteInfoSubscriptionEmail.classNameWithoutNamespaces(),
                                                                              into: managedObjectContext) as? ReaderSiteInfoSubscriptionEmail
        }
        
        ContextManager.sharedInstance().saveContextAndWait(managedObjectContext)
        
        return siteTopic
    }
    
    private func remoteAction(for action: SubscriptionAction, siteId: NSNumber, _ subscribe: Bool, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        let service = ReaderTopicServiceRemote(wordPressComRestApi: apiRequest())
        
        let successBlock: SuccessBlock = {
            ContextManager.sharedInstance().save(self.managedObjectContext, withCompletionBlock: success)
        }
        
        switch action {
        case .notifications:
            if subscribe {
                service?.subscribeSiteNotifications(with: siteId, successBlock, failure)
            } else {
                service?.unsubscribeSiteNotifications(with: siteId, successBlock, failure)
            }
        
        case .postsEmail:
            print("Email")
            
        case .comments:
            print("Comments")
        }
    }
}

extension ReaderTopicService: SiteNotificationsSubscriptable {
    @nonobjc public func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, true, success, failure)
    }
    
    @nonobjc public func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, false, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func toggleSiteNotifications(with siteId: NSNumber, _ subscribe: Bool, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        guard let siteTopic = fetchSiteTopic(with: siteId, failure) else {
            return
        }
        
        let oldValue = !subscribe
        siteTopic.postSubscription?.sendPosts = subscribe
        
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
        
        remoteAction(for: .notifications, siteId: siteId, subscribe, success, failureBlock)
    }
}
