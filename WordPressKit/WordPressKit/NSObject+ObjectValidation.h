//
//  NSObject+ObjectValidation.h
//  WordPressKit
//
//  Created by Daniele Bogo on 04/04/2018.
//  Copyright © 2018 Automattic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (ObjectValidation)
- (BOOL)wp_isValidObject;
- (BOOL)wp_isValidString;
@end
