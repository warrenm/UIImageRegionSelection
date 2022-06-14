
import UIKit

extension UIImageView {
    var imageTransform: CGAffineTransform {
        guard let image = image else { return CGAffineTransform.identity }
        switch contentMode {
        case .scaleAspectFit:
            let imageAspect = image.size.width / image.size.height
            let viewAspect = bounds.width / bounds.height
            let scale = (imageAspect > viewAspect) ? bounds.width / image.size.width :
                                                     bounds.height / image.size.height
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            let offset = CGPoint(x: (bounds.width - (image.size.width * scale)) * 0.5,
                                 y: (bounds.height - (image.size.height * scale)) * 0.5)
            let translationTransform = CGAffineTransform(translationX: offset.x, y: offset.y)
            return scaleTransform.concatenating(translationTransform)
        default:
            fatalError("Content modes other than aspect-fit are not currently supported")
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionImageView: UIImageView!
    private var activeSelectionView: SelectionView?
    private var touchDownPoint: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func beginSelection(with touch: UITouch) {
        touchDownPoint = touch.location(in: view)
        let selectionView = SelectionView(frame: CGRect(origin: touchDownPoint!, size: .zero))
        activeSelectionView = selectionView
        view.addSubview(selectionView)
    }

    private func endSelection() {
        activeSelectionView = nil
        touchDownPoint = nil
    }

    private func updateSelection(with touch: UITouch) {
        guard let selectionView = activeSelectionView else { return }
        guard let touchDownPoint = touchDownPoint else { return }

        let touchDragPoint = touch.location(in: view)
        let selectionRegion = CGRect(origin: touchDownPoint,
                                     size: CGSize(width: touchDragPoint.x - touchDownPoint.x,
                                                  height: touchDragPoint.y - touchDownPoint.y)).standardized
        selectionView.frame = selectionRegion

        // Uncomment this to enable real-time selection visualization.
        // This is much more computationally expensive.
        //updateSelectedImageRegion()
    }

    private func updateSelectedImageRegion() {
        guard let selectionView = activeSelectionView else { return }
        guard let image = imageView.image else { return }
        let selectionInImageView = imageView.convert(selectionView.frame, from: view)
        let aspectFitTransform = imageView.imageTransform
        let selectionInImage = selectionInImageView.applying(aspectFitTransform.inverted())
        let clippedSelection = selectionInImage.intersection(CGRect(origin: .zero, size: image.size))

        if clippedSelection.isNull { return }

        let imageScale = image.scale
        let selectionInPx = clippedSelection.applying(CGAffineTransform(scaleX: imageScale, y: imageScale))
        let integralSelectionInPx = selectionInPx.integral
        if let cgImage = image.cgImage {
            if let subimage = cgImage.cropping(to: integralSelectionInPx) {
                selectionImageView.image = UIImage(cgImage: subimage)
            }
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        beginSelection(with: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateSelection(with: touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateSelection(with: touch)
        updateSelectedImageRegion()
        endSelection()
    }
}
