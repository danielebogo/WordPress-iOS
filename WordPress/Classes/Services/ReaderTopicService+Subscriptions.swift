import Foundation
import WordPressKit


private enum SubscriptionAction {
    case notifications(siteId: NSNumber)
    case postsEmail(siteId: NSNumber)
    case updatePostsEmail(siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency)
    case comments(siteId: NSNumber)
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
    
    private func remoteAction(for action: SubscriptionAction, _ subscribe: Bool, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        let service = ReaderTopicServiceRemote(wordPressComRestApi: apiRequest())
        
        let successBlock: SuccessBlock = {
            ContextManager.sharedInstance().save(self.managedObjectContext, withCompletionBlock: success)
        }
        
        switch action {
        case .notifications(let siteId):
            if subscribe {
                service?.subscribeSiteNotifications(with: siteId, successBlock, failure)
            } else {
                service?.unsubscribeSiteNotifications(with: siteId, successBlock, failure)
            }
        
        case .postsEmail(let siteId):
            if subscribe {
                service?.subscribePostsEmail(with: siteId, successBlock, failure)
            } else {
                service?.unsubscribePostsEmail(with: siteId, successBlock, failure)
            }
            
        case .updatePostsEmail(let siteId, let frequency):
            service?.updateFrequencyPostsEmail(with: siteId, frequency: frequency, successBlock, failure)
            
        case .comments(let siteId):
            if subscribe {
                service?.subscribeSiteComments(with: siteId, successBlock, failure)
            } else {
                service?.unsubscribeSiteComments(with: siteId, successBlock, failure)
            }
        }
    }
}


extension ReaderTopicService: SiteNotificationsSubscriptable {
    @nonobjc public func subscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, subscribe: true, success, failure)
    }
    
    @nonobjc public func unsubscribeSiteNotifications(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteNotifications(with: siteId, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func toggleSiteNotifications(with siteId: NSNumber, subscribe: Bool = false, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
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
        
        remoteAction(for: .notifications(siteId: siteId), subscribe, success, failureBlock)
    }
}


extension ReaderTopicService: SiteCommentsSubscriptable {
    @nonobjc public func subscribeSiteComments(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteComments(with: siteId, subscribe: true, success, failure)
    }
    
    @nonobjc public func unsubscribeSiteComments(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        toggleSiteComments(with: siteId, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func toggleSiteComments(with siteId: NSNumber, subscribe: Bool = false, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        guard let siteTopic = fetchSiteTopic(with: siteId, failure) else {
            return
        }
        
        let oldValue = !subscribe
        siteTopic.emailSubscription?.sendComments = subscribe
        
        let failureBlock: FailureBlock = { (error: NSError?) in
            guard let siteTopic = self.findSiteTopic(withSiteID: siteId) else {
                failure(nil)
                return
            }
            siteTopic.emailSubscription?.sendComments = oldValue
            ContextManager.sharedInstance().save(self.managedObjectContext){
                failure(error)
            }
        }
        
        remoteAction(for: .comments(siteId: siteId), subscribe, success, failureBlock)
    }
}


extension ReaderTopicService: SitePostsSubscriptable {
    @nonobjc public func subscribePostsEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        togglePostsEmail(with: siteId, subscribe: true, success, failure)
    }
    
    @nonobjc public func unsubscribePostsEmail(with siteId: NSNumber, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        togglePostsEmail(with: siteId, success, failure)
    }
    
    @nonobjc public func updateFrequencyPostsEmail(with siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        updatePostsEmail(with: siteId, frequency: frequency, success, failure)
    }
    
    
    //MARK: Private methods
    
    private func togglePostsEmail(with siteId: NSNumber, subscribe: Bool = false, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        guard let siteTopic = fetchSiteTopic(with: siteId, failure) else {
            return
        }
        
        let oldValue = !subscribe
        siteTopic.emailSubscription?.sendPosts = subscribe
        
        let failureBlock: FailureBlock = { (error: NSError?) in
            guard let siteTopic = self.findSiteTopic(withSiteID: siteId) else {
                failure(nil)
                return
            }
            siteTopic.emailSubscription?.sendPosts = oldValue
            ContextManager.sharedInstance().save(self.managedObjectContext){
                failure(error)
            }
        }
        
        remoteAction(for: .postsEmail(siteId: siteId), subscribe, success, failureBlock)
    }
    
    private func updatePostsEmail(with siteId: NSNumber, frequency: ReaderServiceDeliveryFrequency, _ success: @escaping SuccessBlock, _ failure: @escaping FailureBlock) {
        guard let siteTopic = fetchSiteTopic(with: siteId, failure),
            let emailSubscription = siteTopic.emailSubscription else {
            return
        }
        
        let oldValue = emailSubscription.postDeliveryFrequency
        emailSubscription.postDeliveryFrequency = frequency.rawValue
        
        let failureBlock: FailureBlock = { (error: NSError?) in
            guard let siteTopic = self.findSiteTopic(withSiteID: siteId) else {
                failure(nil)
                return
            }
            siteTopic.emailSubscription?.postDeliveryFrequency = oldValue
            ContextManager.sharedInstance().save(self.managedObjectContext){
                failure(error)
            }
        }
        
        remoteAction(for: .updatePostsEmail(siteId: siteId, frequency: frequency), false, success, failureBlock)
    }
}
