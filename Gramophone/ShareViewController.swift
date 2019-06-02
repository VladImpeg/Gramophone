//
//  ShareViewController.swift
//  Gramophone
//
//  Created by admin on 1/21/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import SnapKit
import LiquidFloatingActionButton

import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import SwiftKeychainWrapper


public class CustomCell : LiquidFloatingCell {
    var name: String = "sample"
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func setupView(_ view: UIView) {
//        super.setupView(view)
//        let label = UILabel()
//        label.text = name
//        label.textColor = UIColor.white
//        label.font = UIFont(name: "Helvetica-Neue", size: 12)
//        addSubview(label)
//        label.snp.makeConstraints { make in
//            make.left.equalTo(self).offset(-80)
//            make.width.equalTo(75)
//            make.top.height.equalTo(self)
//        }
//    }
}

public class CustomDrawingActionButton: LiquidFloatingActionButton {
    
    override public func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = CAShapeLayerLineCap.round
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let w = frame.width
        let h = frame.height
        
        let points = [
            (CGPoint(x: w * 0.25, y: h * 0.35), CGPoint(x: w * 0.75, y: h * 0.35)),
            (CGPoint(x: w * 0.25, y: h * 0.5), CGPoint(x: w * 0.75, y: h * 0.5)),
            (CGPoint(x: w * 0.25, y: h * 0.65), CGPoint(x: w * 0.75, y: h * 0.65))
        ]
        
        let path = UIBezierPath()
        for (start, end) in points {
            path.move(to: start)
            path.addLine(to: end)
        }
        
        plusLayer.path = path.cgPath
        
        return plusLayer
    }
}



class FeedViewController: UIViewController, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate{
 
    

    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
 var dict : [String : AnyObject]!
    
    @IBOutlet weak var polaroidView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        polaroidView.dropShadow()
        setShareButton()
        //creating button
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        
        //adding it to view
        view.addSubview(loginButton)
        
        //if the user is already logged in
        if FBSDKAccessToken.current() != nil{
            getFBUserData()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
    
    //when login button clicked
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile ], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserData()
                self.graphData()
            }
        }
    }
    
    
    
    func graphData() {
        FBSDKGraphRequest(graphPath: "/100003543731150/feed", parameters: ["message": "Here I am!Just Testing new app"], httpMethod: "POST").start { (connection, result, err) -> Void in
            if err != nil {
                print("failed to start graph request: \(String(describing: err))")
                return
            }
            print(result ?? "")
        }
        
    }
    //function is fetching the user data
    func getFBUserData(){
    
        if((FBSDKAccessToken.current()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                
                
                if (error == nil){
                    self.dict = result as? [String : AnyObject]
                    print(result!)
                    print(self.dict)
                }
            })
            
            
    
            
            
        }
    }
    
    func setShareButton(){
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = CustomDrawingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            let cell = LiquidFloatingCell(icon: UIImage(named: iconName)!)
            return cell
        }
        let customCellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            let cell = CustomCell(icon: UIImage(named: iconName)!, name: iconName)
            return cell
        }
        cells.append(cellFactory("ic_cloud"))
        cells.append(customCellFactory("ic_system"))
        cells.append(cellFactory("ic_place"))
        
     let floatingFrame = CGRect(x: self.view.frame.width / 2 - 28, y: self.view.frame.height - 150, width: 56, height: 56)
        let bottomRightButton = createButton(floatingFrame, .up)
        
        let image = UIImage(named: "megafon")
        bottomRightButton.image = image
        
     
        
        
        self.view.addSubview(bottomRightButton)

    }
    
    
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
      return cells.count
    }
    
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        print("did Tapped! \(index)")
        liquidFloatingActionButton.close()
    }

}
