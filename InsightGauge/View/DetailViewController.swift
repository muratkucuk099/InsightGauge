//
//  DetailViewController.swift
//  InsightGauge
//
//  Created by Mac on 8.09.2023.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var voteProgressView: UIProgressView!
    @IBOutlet weak var secondVoteButton: UIButton!
    @IBOutlet weak var firstVoteButton: UIButton!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var secondTitle: UILabel!
    @IBOutlet weak var commentTextfield: UITextField!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var secondVoteLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstVoteLabel: UILabel!
    
    var choosenBattle = Battles(id: "", firstImage: "", firstTitle: "", secondImage: "", secondTitle: "", userEmail: "", userUID: "", comment: [""], votes: [["": 0]])
    
    let commentMV = CommentMV()
    let getBattlesMV = GetBattlesMV()
    var vote: Int?
    var dataArray = [Comments]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openScene()
    }
    
    func openScene() {
        firstImageView.sd_setImage(with: URL(string: choosenBattle.firstImage))
        secondImageView.sd_setImage(with: URL(string: choosenBattle.secondImage))
        firstTitle.text = choosenBattle.firstTitle
        secondTitle.text = choosenBattle.secondTitle
        
        let views = [firstImageView, secondImageView]
        
        for view in views {
            view!.layer.cornerRadius = 10
        }
        
        getBattlesMV.voteFunction(choosenBattle: choosenBattle) { voteTag in
            self.vote = voteTag
            if voteTag == 0 {
                self.firstVoteButton.tintColor = .systemBlue
            } else if voteTag == 1 {
                self.secondVoteButton.tintColor = .systemBlue
            }
        }
        
        getBattlesMV.getVotesCount(choosenBattle: choosenBattle) { results in
            self.firstVoteLabel.text = String(results[0])
            self.secondVoteLabel.text = String(results[1])
            self.voteProgressView.progress = Float(results[0]) / Float(results[0] + results[1])
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: K.commentCellId)
        firstVoteButton.tintColor = .darkGray
        secondVoteButton.tintColor = .darkGray
        commentMV.getComment(choosenBattle: choosenBattle) { results in
            self.dataArray = results
            self.tableView.reloadData()  // Başta boş veri gönderiliyor bunun önlenmesi lazım
        }
    }
    
    @IBAction func voteButtonPressed(_ sender: UIButton) {
//        firstVoteButton.tintColor = .darkGray
//        secondVoteButton.tintColor = .darkGray
        
        if sender.tintColor == .systemBlue {
            sender.tintColor = .darkGray
        } else {
            firstVoteButton.tintColor = .darkGray
            secondVoteButton.tintColor = .darkGray
            sender.tintColor = .systemBlue
        }
        vote = sender.tag
        getBattlesMV.uploadVotes(choosenBattle: choosenBattle, userVote: vote!) { results in
            self.firstVoteLabel.text = String(results[0])
            self.secondVoteLabel.text = String(results[1])
            self.voteProgressView.progress = Float(results[0]) / Float(results[0] + results[1])
        }
        
    }
    
    @IBAction func sendCommentButton(_ sender: UIButton) {
        if let commentText = commentTextfield.text?.trimmingCharacters(in: .whitespaces) {
            if let userVote = vote {
                if commentText != "" {
                    let comment = commentMV.createComment(battleId: choosenBattle.id, comment: commentText)
                    dataArray.append(comment)
                    print("Comment created succesfully")
                    commentTextfield.text = ""
                }
                tableView.reloadData()
            }
            else {
                print("Choose your vote!") // Kullanıcıya bildirim verilecek
            }
        }
    }
}

//MARK: - TableView Method
extension DetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.commentCellId, for: indexPath) as! CommentTableViewCell
        let commentInfo = self.dataArray[indexPath.row]
        getBattlesMV.getUserInfo(userEmail: commentInfo.userEmail, userUID: commentInfo.userUid) { results in
            cell.userNameLabel.text = results["userName"] as? String
            if commentInfo.comment == "" {
                cell.commentLabel.text = " "
            } else {
                cell.commentLabel.text = commentInfo.comment
            }
            cell.voteLabel.text = "Vote: "
        }
        return cell
    }
}
