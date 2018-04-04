//
//  AccountSettingsService.swift
//  WordPressAuth
//
//  Created by Jorge Leandro Perez on 3/14/18.
//  Copyright © 2018 Automattic. All rights reserved.
//

import Foundation
import WordPressKit


class AccountSettingsService {

    func suggestUsernames(base: String, completion: @escaping ([String]) -> ()) {
        let dotcomAPI = WordPressComRestApi()
        let remote = AccountSettingsRemote.remoteWithApi(dotcomAPI)
        remote.suggestUsernames(base: base, finished: completion)
    }
}
