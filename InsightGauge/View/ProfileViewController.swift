//
//  ProfileViewController.swift
//  InsightGauge
//
//  Created by Mac on 7.10.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let userAuthMV = UserAuthMV()
    let getBattles = GetBattlesMV()
    let uploadBattlesMV = UploadBattlesMV()
    var mainUser: UserAuth?
    var battleArray = [Battles]()
    var choosenBattle = Battles(id: "", firstImage: "", firstTitle: "", secondImage: "", secondTitle: "", userEmail: "", userUID: "", comment: [""], votes: [["": 0]])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        openScene()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: K.cellId)
        tableView.register(UINib(nibName: "UserInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "userInfo")
    }
    
    func openScene() {
        userAuthMV.getUserInfo { [self] user in
            mainUser = user
            title = user.userName
            getBattles.getPrivateBattles(privateBattles: user.battles) { battles in
                DispatchQueue.main.async {
                    self.battleArray = battles
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: - TableView Method
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return battleArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let firstCell = tableView.dequeueReusableCell(withIdentifier: "userInfo", for: indexPath) as! UserInfoTableViewCell
            DispatchQueue.main.async {
                if let user = self.mainUser {
                    firstCell.emailLabel.text = user.email
                    firstCell.nameLabel.text = user.userName
                    firstCell.battlesCountLabel.text = String(user.battles.count ?? 0)
                }
            }
            return firstCell
            
        } else {
            let choosenRow = battleArray[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellId, for: indexPath) as! FeedTableViewCell
            cell.firstImageView.layer.cornerRadius = 10
            cell.secondImageView.layer.cornerRadius = 10
            cell.firstImageView.sd_setImage(with: URL(string: choosenRow.firstImage))
            cell.secondImageView.sd_setImage(with: URL(string: choosenRow.secondImage))
            cell.firstLabel.text = choosenRow.firstTitle
            print("first title \(choosenRow.firstTitle)")
            cell.secondLabel.text = choosenRow.secondTitle
            
            getBattles.getVotesCount(choosenBattle: choosenRow) { results in
                cell.progressView.progress = Float(results[0]) / Float(results[0] + results[1])
            }
            
            getBattles.getUserInfo(userEmail: choosenRow.userEmail, userUID: choosenRow.userUID) { userInfo in
                cell.userNameLabel.text = userInfo["userName"] as? String
            }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToDetail" {
            let detailsVC = segue.destination as! DetailViewController
            detailsVC.choosenBattle = choosenBattle
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenBattle = battleArray[indexPath.row - 1]
        performSegue(withIdentifier: "ProfileToDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            uploadBattlesMV.deleteBattle(choosenBattle: battleArray[indexPath.row - 1])
            battleArray.remove(at: indexPath.row - 1)
        }
        tableView.reloadData()
    }
}
