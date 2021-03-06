//
//  HomeViewController.swift
//  Instagram
//
//  Created by Chan Yama on 2020/09/30.
//  Copyright © 2020 moe.hatori2. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    // 投稿データを格納する配列
    var postArray: [PostData] = []

    // Firestoreのリスナー
    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のいいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)

       // ***セル内のsendボタンのアクションをソースコードで設定する***
        cell.sendButton.addTarget(self, action: #selector(sendehandleButton(_:forEvent:)), for: .touchUpInside)
        
        
        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
              //Firestoreの格納場所を指定して
            postRef.updateData(["likes": updateValue])
              //likesの内容を更新している
              //PostViewでも配列形式で格納している
        }
    }
        
    // ***セル内の投稿ボタンがタップされた時に呼ばれるメソッド***
    @objc func sendehandleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: 投稿ボタンがタップされました。")
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let cell = tableView.cellForRow(at: indexPath!) as! PostTableViewCell
        let comment = cell.commentTextFeild.text!
        
        let name = Auth.auth().currentUser?.displayName
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        if comment.count != 0 {
            //コメント欄にセットするコメント
            let setcomment = "\(name!) : \(comment)"
            
            // commentを更新する
               // 更新データを作成する
               //name+commentをセットしたい
            var updatecommentValue : FieldValue
            updatecommentValue = FieldValue.arrayUnion([setcomment])

            // commentに更新データを書き込む
            let postcommentRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postcommentRef.updateData(["comment": updatecommentValue])
            
            cell.commentTextFeild.text = ""
            
        }
        
        
        
        


      }
        
        
    
    
    
    
}
