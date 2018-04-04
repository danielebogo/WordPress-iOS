//
//  RemoteReaderSiteInfoSubscription.swift
//  WordPressKit
//
//  Created by Daniele Bogo on 03/04/2018.
//  Copyright © 2018 Automattic Inc. All rights reserved.
//

import Foundation


/// Mapping keys
private struct CodingKeys {
    static let sendPost = "send_posts"
    static let sendComments = "send_comments"
    static let postDeliveryFrequency = "post_delivery_frequency"
}


/// Common interface for Site Info Subscription models
@objc public protocol RemoteReaderSiteInfoSubscriptionProtocol: class {
    var sendPosts: Bool { get set }
    
    init(dictionary: [String: Any])
}


/// Site Info Post Subscription model
@objc public class RemoteReaderSiteInfoSubscriptionPost: NSObject, RemoteReaderSiteInfoSubscriptionProtocol {
    @objc public var sendPosts: Bool
    
    
    @objc required public init(dictionary: [String: Any]) {
        self.sendPosts = (dictionary[CodingKeys.sendPost] as? Bool) ?? false
        super.init()
    }
}


/// Site Info Email Subscription model
@objc public class RemoteReaderSiteInfoSubscriptionEmail: NSObject, RemoteReaderSiteInfoSubscriptionProtocol {
    @objc public var sendPosts: Bool
    @objc public var sendComments: Bool
    @objc public var postDeliveryFrequency: String

    
    @objc required public init(dictionary: [String: Any]) {
        self.sendPosts = (dictionary[CodingKeys.sendPost] as? Bool) ?? false
        self.sendComments = (dictionary[CodingKeys.sendComments] as? Bool) ?? false
        self.postDeliveryFrequency = (dictionary[CodingKeys.postDeliveryFrequency] as? String) ?? ""
        super.init()
    }
}
