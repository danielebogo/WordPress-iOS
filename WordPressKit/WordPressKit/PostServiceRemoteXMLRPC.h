#import <Foundation/Foundation.h>
#import "PostServiceRemote.h"
#import "ServiceRemoteWordPressXMLRPC.h"


extern NSString * const WordPressAppErrorDomain;

@interface PostServiceRemoteXMLRPC : ServiceRemoteWordPressXMLRPC <PostServiceRemote>

@end
