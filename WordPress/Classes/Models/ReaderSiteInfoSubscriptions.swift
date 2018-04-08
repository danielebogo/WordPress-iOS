import Foundation
import CoreData


@objc public class ReaderSiteInfoSubscriptionPost: NSManagedObject {
    @NSManaged open var sendPosts: Bool
}


@objc public class ReaderSiteInfoSubscriptionEmail: ReaderSiteInfoSubscriptionPost {
    @NSManaged open var sendComments: Bool
    @NSManaged open var postDeliveryFrequency: String
}
