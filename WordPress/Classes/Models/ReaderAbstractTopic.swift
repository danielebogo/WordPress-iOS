import Foundation
import CoreData

@objc open class ReaderAbstractTopic: NSManagedObject {
    // Relations
    @NSManaged open var posts: [ReaderPost]
    @NSManaged open var postSubscription: ReaderSiteInfoSubscriptionPost?
    @NSManaged open var emailSubscription: ReaderSiteInfoSubscriptionEmail?

    // Properties
    @NSManaged open var inUse: Bool
    @NSManaged open var algorithm: String?
    @NSManaged open var following: Bool
    @NSManaged open var lastSynced: Date?
    @NSManaged open var path: String
    @NSManaged open var showInMenu: Bool
    @NSManaged open var title: String
    @NSManaged open var type: String

    @objc open class var TopicType: String {
        assert(false, "Subclasses must override")
        return "abstract"
    }
    
    
    //MARK: - Public methods
    
    @objc public func blogNameToDisplay() -> String {
        return posts.first?.blogNameForDisplay() ?? title
    }
    
    @objc public func isSubscribedForPostNotifications() -> Bool {
        return postSubscription?.sendPosts ?? false
    }
}
