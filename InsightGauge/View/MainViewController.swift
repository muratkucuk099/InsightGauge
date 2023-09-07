//
//  MainViewController.swift
//  InsightGauge
//
//  Created by Mac on 24.08.2023.
//

import UIKit
import FirebaseAuth
import SDWebImage

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let getBattles = GetBattlesMV()
    var battleArray = [Battles]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openScene()
    }
    
    func openScene() {
        getBattles.getBattles { battles in
            DispatchQueue.main.async {
                // Elde edilen veriyi battleArray'e aktar
                self.battleArray = battles
                // TableView'i güncelle
                self.mainTableView.reloadData()
            }
        }
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: K.cellId)
    }
}

//MARK: - TableView Method
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return battleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let choosenRow = battleArray[indexPath.row]
        let cell = mainTableView.dequeueReusableCell(withIdentifier: K.cellId, for: indexPath) as! FeedTableViewCell
        cell.firstImageView.layer.cornerRadius = 10
        cell.secondImageView.layer.cornerRadius = 10
        cell.firstImageView.sd_setImage(with: URL(string: choosenRow.firstImage))
        cell.secondImageView.sd_setImage(with: URL(string: choosenRow.secondImage))
        cell.firstLabel.text = choosenRow.firstTitle
        cell.secondLabel.text = choosenRow.secondTitle
        getBattles.getUserInfo(userEmail: choosenRow.userEmail, userUID: choosenRow.userUID)
        return cell
    }
}
