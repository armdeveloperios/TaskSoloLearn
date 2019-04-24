//
//  NewsTableViewCell.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/20/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak var newsIconImageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    static let reuseIdentifier = "newsTableViewCellIdentifier"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.newsIconImageView.image = nil;
    }

    // MARK: - Public API
    func configureCell(_ data: News) {
        self.titleLabel.text = data.webTitle
    }
    
    func stopLoading() {
        self.loadingIndicator.stopAnimating()
    }
    func startLoading() {
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.hidesWhenStopped = true
    }
}
