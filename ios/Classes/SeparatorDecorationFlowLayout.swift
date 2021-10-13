import UIKit

public final class SeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
    }
}
