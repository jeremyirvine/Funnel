import UIKit

class PushNoAnimationSegue: UIStoryboardSegue {
    
    override func perform() {
        self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
}
