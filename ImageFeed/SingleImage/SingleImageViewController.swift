import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var ScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        ScrollView.minimumZoomScale = 0.1
        ScrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func didTapSharingButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(activityItems: [image],
                                             applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = ScrollView.minimumZoomScale
        let maxZoomScale = ScrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = ScrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / image.size.width
        let vScale = visibleRectSize.height / image.size.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        ScrollView.setZoomScale(scale, animated: false)
        ScrollView.layoutIfNeeded()
        let newContentSize = ScrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width)
        let y = (newContentSize.height - visibleRectSize.height)
        ScrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
