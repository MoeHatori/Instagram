//
//  PostData.swift
//  Instagram
//
//  Created by Chan Yama on 2020/10/07.
//  Copyright © 2020 moe.hatori2. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: [String] = [] //コメントを格納するための配列

    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID //投稿ID

        let postDic = document.data()

        self.name = postDic["name"] as? String

        self.caption = postDic["caption"] as? String

        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()

        //likesというキーで取り出した配列
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        
        //配列に自分のIDが入っているか確認
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
        //***コメント書き込み(コメント配列)***
        if let comment = postDic["comment"] as? [String] {
            self.comment = comment
        }
       
    }
}

