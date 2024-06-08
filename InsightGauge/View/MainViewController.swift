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
    var choosenBattle = Battles(id: "", firstImage: "", firstTitle: "", secondImage: "", secondTitle: "", userEmail: "", userUID: "", comment: [""], votes: [["": 0]])
    var isExistPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        openScene()
    }
    
    func openScene() {
        self.isExistPost = false
        getBattles.getBattles { battles in
            DispatchQueue.main.async {
                // Elde edilen veriyi battleArray'e aktar
                self.battleArray = battles
                // TableView'i güncelle
                self.mainTableView.reloadData()
                self.isExistPost = true
            }
        }
        if !isExistPost {
            self.battleArray.removeAll()
            self.mainTableView.reloadData()
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
        
        getBattles.getVotesCount(choosenBattle: choosenRow) { results in
            cell.progressView.progress = Float(results[0]) / Float(results[0] + results[1])
        }
        
        getBattles.getUserInfo(userEmail: choosenRow.userEmail, userUID: choosenRow.userUID) { userInfo in
            cell.userNameLabel.text = userInfo["userName"] as? String
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsVC" {
            let detailsVC = segue.destination as! DetailViewController
            detailsVC.choosenBattle = choosenBattle
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenBattle = battleArray[indexPath.row]
        performSegue(withIdentifier: "DetailsVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
