//
//  TimeLineTableViewController.swift
//  practiceParse
//
//  Created by Fumiya Yamanaka on 2015/09/08.
//  Copyright (c) 2015年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Parse

class TimeLineTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
//        self.tableView.estimatedRowHeight = 150
//        self.tableView.rowHeight = UITableViewAutomaticDimension

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // アプリを起動した時にログインアラートを表示する。viewDidLoadではないので注意
    override func viewDidAppear(animated: Bool) {
        
        self.loadData()
        
        if PFUser.currentUser() == nil {
            var loginAlert: UIAlertController = UIAlertController (
                title: "SignUp / Login",
                message: "Please sign up or login",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            
            //ユーザネームとパスワードの入力
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Name"
            })
            
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Password"
                textfield.secureTextEntry = true
            })
            
            loginAlert.addAction(UIAlertAction(
                title: "Login",
                style: UIAlertActionStyle.Default,
                handler: {
                    alertAction in
                    let textFields:NSArray = (loginAlert.textFields as? NSArray)!
                    let usernameTextField:UITextField = textFields.objectAtIndex(0) as! UITextField
                    let passwordTextField:UITextField = textFields.objectAtIndex(1) as! UITextField
                    
                    
                    // tweeterをユーザーの変数として作成
                    var tweeter:PFUser = PFUser()
                    // UITextFieldに入力された内容を代入する
                    tweeter.username = usernameTextField.text
                    tweeter.password = passwordTextField.text
                    
                    //Parseに送信
                    tweeter.signUpInBackgroundWithBlock {
                        (success:Bool, error:NSError?) -> Void in
                        if error == nil {
                            println("Sign up successful")
                        } else {
                            let errorString = error!.userInfo!["error"] as! NSString
                            println(errorString)
                        }
                    }
            }))
            
            self.presentViewController(loginAlert, animated: true, completion: nil)
        }
        
    }
    
    var timelineData:NSMutableArray = NSMutableArray()
    
    // initの前方にrequiredが必要
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    // Parseからデータ取得
    func loadData() {
        timelineData.removeAllObjects()
        
        var findTimelineData:PFQuery = PFQuery(className: "Tweets")
        
        findTimelineData.findObjectsInBackgroundWithBlock ({
            (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                if let myObjects = objects {  // ifでmyobjectをかませた 
                    for object in myObjects {
                        self.timelineData.addObject(object)
                    }
                }
                let array: NSArray! = self.timelineData.reverseObjectEnumerator().allObjects
                if let myArray: NSMutableArray = array as? NSMutableArray {
                    self.timelineData = myArray
                }
                self.tableView.reloadData()
            }
        })
    }
    
    //　セクション分けされたグループの数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    // cellの数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineData.count
    }
    
    //　Tweet内容とユーザをParseから取得
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:TweetTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TweetTableViewCell
        let tweet:PFObject = self.timelineData.objectAtIndex(indexPath.row) as! PFObject
        
        // デザイン部分なので無視してOK
        cell.tweetTextLabel.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        // Tweet内容をParse.comから取得
        cell.tweetTextLabel.text = tweet.objectForKey("content") as! String
        
        var dataFormatter:NSDateFormatter! = NSDateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.timestampLabel.text = dataFormatter.stringFromDate(tweet.createdAt!)
        
        // objectIDをforeignKeyとして、tweeterを取得
        var findTweeter:PFQuery = PFUser.query()!
        findTweeter.whereKey("objectId", equalTo: tweet.objectForKey("tweeter")!.objectId!!)
        
        findTweeter.findObjectsInBackgroundWithBlock ({
            (object:[AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let myObject = object {
                    let user:PFUser = (myObject as NSArray).lastObject as! PFUser
                    cell.usernameLabel.text = "\(user.username)"
                
                    // CELLの表示にDurationをつけて、ほわっと表示する
                    UIView.animateWithDuration(0.5, animations: {
                        cell.tweetTextLabel.alpha = 1
                        cell.timestampLabel.alpha = 1
                        cell.usernameLabel.alpha = 1
                    })
                }
            }
        })
        
        return cell
    }
}




