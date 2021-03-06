//
//  LoginController.swift
//  babySample
//
//  Created by 蔡鈞 on 2016/6/9.
//  Copyright © 2016年 蔡鈞. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var idText: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var pwdText: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginFbBtn: UIButton!
    
    
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
//    let overcastBlueColor = UIColor(red: 241, green: 169/255, blue: 160/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTextTheme()
        self.idText.becomeFirstResponder()
    }

    func setTextTheme(){
        
        self.loginBtn.layer.borderColor = lightGreyColor.CGColor
        self.loginBtn.layer.borderWidth = 1
        self.loginBtn.setTitleColor(overcastBlueColor, forState: .Highlighted)
        
        self.loginFbBtn.layer.borderColor = lightGreyColor.CGColor
        self.loginFbBtn.layer.borderWidth = 1
        self.loginFbBtn.setTitleColor(overcastBlueColor, forState: .Highlighted)
        
        self.applySkyscannerThemeWithIcon(self.idText)
        self.idText.iconText = "\u{f007}"
        self.idText.placeholder = NSLocalizedString("Email", tableName: "SkyFloatingLabelTextField", comment: "placeholder for the departure city field")
        self.idText.selectedTitle = NSLocalizedString("Email", tableName: "SkyFloatingLabelTextField", comment: "title for the departure city field")
        self.idText.title = NSLocalizedString("Email", tableName: "SkyFloatingLabelTextField", comment: "title for the departure city field")
        
        self.applySkyscannerThemeWithIcon(self.pwdText)
        self.pwdText.iconText = "\u{f084}"
        self.pwdText.placeholder = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "placeholder for the arrival city field")
        self.pwdText.selectedTitle = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "title for the arrival city field")
        self.pwdText.title = NSLocalizedString("Password", tableName: "SkyFloatingLabelTextField", comment: "title for the arrival city field")
        
        self.idText.delegate = self
        self.pwdText.delegate = self
        
    }
    // MARK: - Styling the text fields to the Skyscanner theme
    func applySkyscannerThemeWithIcon(textField: SkyFloatingLabelTextFieldWithIcon) {
        self.applySkyscannerTheme(textField)
        
        textField.iconColor = lightGreyColor
        textField.selectedIconColor = overcastBlueColor
        textField.iconFont = UIFont(name: "FontAwesome", size: 15)
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = overcastBlueColor
        
        textField.textColor = darkGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = overcastBlueColor
        textField.selectedLineColor = overcastBlueColor
        
        // Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 18)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
    }
    
    // MARK: - loginBtn pressed 登入
    var isLoginBtnPressed = false
    var showingTitleInProgress = false
    
    @IBAction func loginBtndDown(sender:AnyObject){
        
        self.isLoginBtnPressed = true
        
        if !self.idText.hasText(){
            self.showingTitleInProgress = true
            self.idText.setTitleVisible(true, animated: true, animationCompletion: self.showingTitleInAnimationComplete)
            self.idText.highlighted = true
        }
        if !self.pwdText.hasText(){
            self.showingTitleInProgress = true
            self.pwdText.setTitleVisible(true, animated: true, animationCompletion: self.showingTitleInAnimationComplete)
            self.pwdText.highlighted = true
        }
        
        
        
        
    }
    
    @IBAction func loginBtndUpInside(sender:AnyObject){
        self.isLoginBtnPressed = false
        if(!self.showingTitleInProgress) {
            self.hideTitleVisibleFromFields()
        }
        
        guard let id = idText.text else {return}
        guard let pwd = pwdText.text else {return}
        
        print("\(id)\n\(pwd)  ")
        
        // 使用 Alamofire 呼叫 API 登入後取得 Token
        let logininfo = ["email":id,"password":pwd]
        Alamofire.request(.POST, "http://140.136.155.143/api/auth/login", parameters:logininfo)
            .validate()
            .responseJSON{ response in
                
               
                switch response.result{
                  
                    
                // 登入成功做的事情
                case .Success:
                    let json = JSON(response.result.value!)
                    print(json)
                    
                    if  let accessToken = json["token"].string {
                        
                         print ("成功取得token,並存取")
                        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "AccessToken")
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                //登入失敗做的事情
                case .Failure(let error):
                    
                    
                    if error.code == -1004 {
                        
                        let alert = UIAlertController(title: "連線失敗", message: nil, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(OKAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                    
                else {
                    let statusCode = response.response!.statusCode
                    
                    switch(statusCode){
                        
                        
                    case 401: let alert = UIAlertController(title: "帳號或密碼錯誤", message: nil, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(OKAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                        
                    default: let alert = UIAlertController(title: "伺服器可能出現問題", message: nil, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(OKAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    
                }
                    
                }
                
        }
        
        
        
        
    }
    
    func showingTitleInAnimationComplete() {
        // If a field is not filled out, display the highlighted title for 0.3 seco
        let displayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(displayTime, dispatch_get_main_queue(), {
            self.showingTitleInProgress = false
            if(!self.isLoginBtnPressed) {
                self.hideTitleVisibleFromFields()
            }
        })
    }
    func hideTitleVisibleFromFields() {
        self.idText.setTitleVisible(false, animated: true)
        self.pwdText.setTitleVisible(false, animated: true)
        
        self.idText.highlighted = false
        self.pwdText.highlighted = false
    }
    
    // MARK: - Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == self.idText) {
            self.validateEmailTextFieldWithText(textField.text)
        }
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder! {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //        if(textField == self.idText) {
        //            self.validateEmailTextFieldWithText(string)
        //        }
        //        return true
        if(textField == self.idText) {
            
            var txtAfterUpdate:NSString = idText.text! as NSString
            txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
            self.validateEmailTextFieldWithText(txtAfterUpdate as String)
            
        }
        return true
        
    }
    
    func validateEmailTextFieldWithText(email: String?) {
        if let email = email {
            if(email.characters.count == 0) {
                self.idText.errorMessage = nil
            }
            else if(!isValidEmail(email)) {
                self.idText.errorMessage = NSLocalizedString("Email not valid", tableName: "SkyFloatingLabelTextField", comment: " ")
                
            } else {
                self.idText.errorMessage = nil
            }
        } else {
            self.idText.errorMessage = nil
        }
    }
    
    func isValidEmail(str:String?) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(str)
        
    }
}


