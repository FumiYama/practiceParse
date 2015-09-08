//
//  ComposeViewController.swift
//  practiceParse
//
//  Created by Fumiya Yamanaka on 2015/09/08.
//  Copyright (c) 2015年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Parse

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var tweetTextView: UITextView! = UITextView()
    @IBOutlet weak var charRemainingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.layer.borderColor = UIColor.blackColor().CGColor
        tweetTextView.layer.borderWidth = 0.5
        tweetTextView.layer.cornerRadius = 10
    }
    
    @IBAction func sendTweet(sender: AnyObject) {
        
        // Tweetする内容を保存するclass(テーブル)の作成
        var tweet:PFObject = PFObject(className: "Tweets")
        
        // カラムの作成、ユーザとtweet内容
        tweet["content"] = tweetTextView.text
        tweet["tweeter"] = PFUser.currentUser()
        
        // Parseに送信
        tweet.saveInBackground()
        
        // Tweet一覧が表示されるTimeLineTableViewControllerに戻る
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func textView(textView: UITextView!,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String!) -> Bool {
            // 入力文字のカウント
            var newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
            var remainingChar: Int = 140 - newLength
            charRemainingLabel.text = "残り\(remainingChar)"
            return (newLength > 140) ? false : true
            
    }
    
    @IBAction func signOut(sender: UIButton) {
        
        PFUser .logOut() // ログアウト処理
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    

}
