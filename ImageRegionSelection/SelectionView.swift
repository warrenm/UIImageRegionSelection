
import UIKit

class SelectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
