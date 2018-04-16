//
//  ServiceRequest.swift
//  WordPressKit
//
//  Created by Daniele Bogo on 16/04/2018.
//  Copyright © 2018 Automattic Inc. All rights reserved.
//

import Foundation


enum ServiceRequestAction: String {
    case subscribe = "new"
    case unsubscribe = "delete"
    case update = "update"
}

protocol ServiceRequest {
    var path: String { get }
    var apiVersion: ServiceRemoteWordPressComRESTApiVersion { get }
}


enum ReaderServiceSubscriptionsRequest: ServiceRequest {
    case notifications(siteId: NSNumber, action: ServiceRequestAction)
    case postsEmail(siteId: NSNumber, action: ServiceRequestAction)
    case comments(siteId: NSNumber, action: ServiceRequestAction)

    var apiVersion: ServiceRemoteWordPressComRESTApiVersion {
        switch self {
        case .notifications: return ._2_0
        case .postsEmail: return ._1_2
        case .comments: return ._1_2
        }
    }
    
    var path: String {
        switch self {
        case .notifications(let siteId, let action):
            return baseUrlPath(with: siteId) + "notification-subscriptions/\(action.rawValue)/"
            
        case .postsEmail(let siteId, let action):
            return baseUrlPath(with: siteId) + "post_email_subscriptions/\(action.rawValue)/"
            
        case .comments(let siteId, let action):
            return baseUrlPath(with: siteId) + "comment_email_subscriptions/\(action.rawValue)/"

        }
    }
    
    
    //MARK: Private methods
    
    private func baseUrlPath(with siteId: NSNumber) -> String {
        return "read/sites/\(siteId.stringValue)/"
    }
}
