import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let imageListService = ImageListService.shared
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func updateDateLabel(withText text: String) {
        dateLabel.text = text
    }
    
    func configure(with photo: Photo) {
        let placeholder = UIImage(named: "stub")
        cellImage.kf.indicatorType = .activity
        let url = URL(string: photo.thumbImageURL)
        cellImage.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.1)),
                .cacheOriginalImage])
        if photo.isLiked {
            likeButton.setImage(UIImage.likeOn, for: .normal)
        } else {
            likeButton.setImage(UIImage.likeOff, for: .normal)
        }
    }
}
