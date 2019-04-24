//
//  ViewController.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/19/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import UIKit
import SDWebImage

class RootViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var news = [News]()
    private let nwesDetailsPageID = "NewsDetailsViewControllerIdentifier"
    private var pullRefreshControl = UIRefreshControl()

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLoadNews()
        self.configPullRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SDWebImageDownloader.shared.cancelAllDownloads()
    }
    
    // MARK: - Private API
    private func firstLoadNews() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        RequestsManager.shared.getNews(successCompletion: { [weak self] (result) in
            if let weakSelf = self {
                weakSelf.loadingIndicator.stopAnimating()
                weakSelf.news += result
                weakSelf.reloadData()
            }
        }) {
            self.loadingIndicator.stopAnimating()
            print("fail to load")
            // show alert
        }
    }
    
    private func reloadData() {
        if Thread.current.isMainThread {
            tableView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func configPullRefresh() {
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullRefreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(pullRefreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        RequestsManager.shared.refreshNews(successCompletion: { [weak self] (result) in
            if let weakSelf = self {
                weakSelf.news = result
                SDWebImageDownloader.shared.cancelAllDownloads()
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                weakSelf.reloadData()
                weakSelf.pullRefreshControl.endRefreshing()
            }
        }) {
            self.pullRefreshControl.endRefreshing()
            print("refresh failed")
        }
    }
    
    private func getNextNews() {
        RequestsManager.shared.getNews(successCompletion: { [weak self] (result) in
            if let weakSelf = self {
                weakSelf.news += result
                weakSelf.reloadData()
            }
        }) {
            print("fail to load")
        }
    }

}

// MARK: - UITableView DataSource
extension RootViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(news[indexPath.row])
        return cell
    }
}

// MARK: - UITableView Delegate
extension RootViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! NewsTableViewCell
        cell.startLoading()
        
        if let stringURL = news[indexPath.row].fields.thumbnail {
            if let url = URL(string: stringURL) {
                cell.newsIconImageView.sd_setImage(with: url) { (image, error, cacheTaype, url) in
                    if image != nil {
                        cell.stopLoading()
                    }
                }
            } else {
                cell.stopLoading()
                cell.newsIconImageView.image = UIImage(named: "newsImage")
            }
        }
        
        if indexPath.row == news.count - 2 {
            self.getNextNews()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! NewsTableViewCell
        cell.newsIconImageView.sd_cancelCurrentImageLoad()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let newsDetailVC = self.storyboard?.instantiateViewController(withIdentifier: nwesDetailsPageID) as? NewsDetailsViewController {
            newsDetailVC.setNewsData(news[indexPath.row])
            self.navigationController!.pushViewController(newsDetailVC, animated: true)
        }
    }
}

