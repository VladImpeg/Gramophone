//
//  ViewController.swift
//  Gramophone
//
//  Created by admin on 1/21/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import LinkedinSwift
import SwiftKeychainWrapper


class ViewController: UIViewController {
    
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
   
    
    private let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "77ux2jr1atsjwm", clientSecret: "RWRr3wEQr02npso8", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://www.linkedin.com/in/vlad-kovryzhenko-366530155/"))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        consoleTextView.layer.cornerRadius = 10.0
        consoleTextView.layer.borderColor = UIColor.orange.cgColor
        consoleTextView.layer.borderWidth = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Login with Linkedin
     */
    @IBAction func login() {
        
        /**
         *  Yeah, Just this simple, try with Linkedin installed and without installed
         *
         *   Check installed if you want to do different UI: linkedinHelper.isLinkedinAppInstalled()
         *   Access token later after login: linkedinHelper.lsAccessToken
         */
        
        linkedinHelper.authorizeSuccess({ [unowned self] (lsToken) -> Void in
            
            self.writeConsoleLine("Login success lsToken: \(lsToken)")
            }, error: { [unowned self] (error) -> Void in
                
                self.writeConsoleLine("Encounter error: \(error.localizedDescription)")
            }, cancel: { [unowned self] () -> Void in
                
                self.writeConsoleLine("User Cancelled!")
        })
    }
    
    @IBAction func logout() {
        
        /**
         logout current linkedin user
         */
        
        linkedinHelper.logout()
    }
    
    /**
     Request profile for your just logged in account
     */
    @IBAction func requestProfile() {
        
        linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            
            self.writeConsoleLine("Request success with response: \(response)")
            
        }) { [unowned self] (error) -> Void in
            
            self.writeConsoleLine("Encounter error: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func fetchFeed(_ sender: Any) {
        
        linkedinHelper.requestURL("https://api.linkedin.com/v2/activityFeeds?q=networkShares&count=2", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            
            print(response)
            self.writeConsoleLine("Request success with response: \(response)")
            
        }) { [unowned self] (error) -> Void in
            
            self.writeConsoleLine("Encounter error: \(error.localizedDescription)")
        }
        
    }
 
    
    fileprivate func writeConsoleLine(_ log: String, funcName: String = #function) {
        
        DispatchQueue.main.async { () -> Void in
            self.consoleTextView.insertText("\n")
            self.consoleTextView.insertText("-----------\(funcName) start:-------------")
            self.consoleTextView.insertText("\n")
            self.consoleTextView.insertText(log)
            self.consoleTextView.insertText("\n")
            self.consoleTextView.insertText("-----------\(funcName) end.----------------")
            self.consoleTextView.insertText("\n")
            
            let rect = CGRect(x: self.consoleTextView.contentOffset.x, y: self.consoleTextView.contentOffset.y, width: self.consoleTextView.contentSize.width, height: self.consoleTextView.contentSize.height)
            
            self.consoleTextView.scrollRectToVisible(rect, animated: true)
        }
    }
}
