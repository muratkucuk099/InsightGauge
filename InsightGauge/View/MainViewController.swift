//
//  MainViewController.swift
//  InsightGauge
//
//  Created by Mac on 24.08.2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: K.cellId)
    }
}

//MARK: - TableView Method
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: K.cellId, for: indexPath) as! FeedTableViewCell
        return cell
    }
    
    
}
