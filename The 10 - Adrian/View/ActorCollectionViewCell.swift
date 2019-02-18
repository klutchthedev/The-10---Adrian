//
//  ActorCollectionViewCell.swift
//  The 10 - Adrian
//
//  Created by Adrian Navarro on 2/17/19.
//  Copyright © 2019 Adrian Navarro. All rights reserved.
//

import UIKit

class ActorCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(actorImageView)
        self.addSubview(actorNameLabel)
        actorImageView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 0))
        actorNameLabel.anchor(top: actorImageView.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let actorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let actorNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.659, green: 0.659, blue: 0.659, alpha: 1.00)
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
   
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actorImageView.image = nil
    }
}
