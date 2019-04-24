//
//  NewsDetailsViewController.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/20/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import UIKit

class NewsDetailsViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var categoryLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var topWordsTableView: UITableView!
    @IBOutlet weak private var tagsCollectionView: UICollectionView!
    @IBOutlet weak private var bottomContainerView: UIView!
    @IBOutlet weak private var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var topContainerViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Propertyes
    private var newsData: News?
    private let cellIdentifier = "cellReuseIdentifier"
    private var multipleStrings = [(name: String, value: Int)]()
    private var tags = [String]()
    private let tableCellHeighit = 30
    private let collectionViewCellHeight = CGFloat(30)
    private let cellLabelTextSize = CGFloat(14)
    private var selectedIndexPath : IndexPath?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configPage()
        tagsCollectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configBottomContainerView()
    }
    
    deinit {
        tagsCollectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    // MARK: - Public API
    func setNewsData(_ data: News) {
        newsData = data
        
        // get all multiple words from text
        if data.fields.bodyText.count > 1 {
            multipleStrings = data.fields.bodyText.multipleStringsAndCountsFromText()
        }
        // get tags from title
        if data.webTitle.count > 1 {
            tags = self.getTagsFromTitle()
            // remove words if character count is 1
            tags = tags.filter { $0.count > 1 }
        }
        
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
        topContainerViewHeightConstraint.constant = tagsCollectionView.contentSize.height
        }
    }
    
    
    // MARK: - Private API
    private func configPage() {
        guard let data = newsData else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.titleLabel.text = data.webTitle
        self.textLabel.text = data.fields.bodyText
        self.categoryLabel.text = data.sectionName
        self.dateLabel.text = data.webPublicationDate
    }
    
    private func configBottomContainerView() {
        if multipleStrings.count > 0 {
            self.bottomViewHeightConstraint.constant = CGFloat(multipleStrings.count * tableCellHeighit + 40)
            self.bottomContainerView.isHidden = false
        } else {
            self.bottomViewHeightConstraint.constant = 0
        }
    }

    private func changeAllSelectedWordsColorInText(_ word: String) {
        let ranges = newsData!.fields.bodyText.lowercased().ranges(word)
        
        let attributedText = NSMutableAttributedString.init(string: newsData!.fields.bodyText)
        let selectedColor = UIColor(red:0.24, green:0.43, blue:1.00, alpha:0.3)
        for range in ranges {
            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: selectedColor, range: range)
        }
        self.textLabel.attributedText = attributedText
    }
    
    private func resetTextLabel() {
        self.textLabel.attributedText = nil
        self.textLabel.text = newsData!.fields.bodyText
    }
    
    private func getTagsFromTitle() -> [String] {
        let correctedString = newsData!.webTitle.removeExtraSpacesAndNotAlphanumericCharacters()
        return correctedString.components(separatedBy: " ")
    }
}

// MARK: - UITableViewDataSource
extension NewsDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multipleStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.backgroundColor = .clear
        cell?.textLabel?.textColor = .darkGray
        let item = multipleStrings[indexPath.row]
        
        cell!.textLabel?.text = "\(item.name) (\(item.value))"
        
        return cell!
    }
}

// MARK: - UITableView Delegate
extension NewsDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableCellHeighit)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == selectedIndexPath {
            self.selectedIndexPath = nil
            tableView.deselectRow(at: indexPath, animated: false)
            self.resetTextLabel()
        } else {
            self.selectedIndexPath = indexPath
            self.changeAllSelectedWordsColorInText(multipleStrings[indexPath.row].name)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewsDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagsCollectionViewCell.reuseIdentifier, for: indexPath) as? TagsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(tags[indexPath.row])

        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewsDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentText = tags[indexPath.row]
        var textWidth = currentText.width(withConstantdHeight: collectionViewCellHeight, font: UIFont.systemFont(ofSize:cellLabelTextSize))
        
        //  text in label 10pt from left and 10pt from right
        textWidth += 20
        return CGSize(width: textWidth, height: collectionViewCellHeight)
    }
}
