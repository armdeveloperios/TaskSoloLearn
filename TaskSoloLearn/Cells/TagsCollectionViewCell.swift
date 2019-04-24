//
//  TagsCollectionViewCell.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/21/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak private var tagLabel: UILabel!
    
    // MARK: - Propertyes
    static let reuseIdentifier = "tagsCollectionViewCellIdentifier"
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
    }
    
    // MARK: - Public API
    func configureCell(_ text: String) {
        self.tagLabel.text = text
    }
    
    
}
