import UIKit

extension UIButton {
    func fadeAnimation() {
        let fade = CASpringAnimation(keyPath: "transform.scale")
        fade.duration = 0.1
        fade.fromValue = 1.0
        fade.toValue = 0.95
        fade.autoreverses = true
        fade.repeatCount = 0
        
        layer.add(fade, forKey: nil)
    }
    
    func pressDownAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.8
        animation.duration = 0.1
        
        layer.add(animation, forKey: nil)
    }
    
}
