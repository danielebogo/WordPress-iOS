import Foundation


class NSManagedObjectContext: NSObject {

}

class ContextManager {
    static func sharedInstance() -> ContextManager {
        return ContextManager()
    }

    let mainContext = NSManagedObjectContext()
}
