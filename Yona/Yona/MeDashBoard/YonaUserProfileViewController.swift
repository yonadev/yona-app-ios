//
//  ProfileViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

enum validateError {
    case firstname
    case lastname
    case nickname
    case phone
    case none
}

class YonaUserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, YonaUserHeaderTabProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightSideButton : UIBarButtonItem!

    var topCell : YonaUserHeaderWithTwoTabTableViewCell?
    fileprivate let nederlandPhonePrefix = "+31 (0) "
    var aUser : Users?
    var isShowingProfile = true
    var rightSideButtonItems : [UIBarButtonItem]?
    var currentImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        registreTableViewCells()
        dataLoading()
        currentImage = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaUserProfileViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }

    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserDisplayTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserDisplayTableViewCell")
        nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func dataLoading () {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            //success so get the user?
            if success {
                self.aUser = user
                if let img = self.currentImage {
                    self.aUser?.avatarImg = img
                }
                //success so get the user
              //  self.setData()
                self.tableView.reloadData()
            } else {
                //response from request failed
                
            }
        }

    
    }
    
    // MARK: - Actions

    func didSelectProfileTab() {
        isShowingProfile = true
        if let itmes = rightSideButtonItems {
            self.navigationItem.rightBarButtonItems = itmes
        }
        tableView.reloadData()
    }

    func didSelectBadgesTab() {
        isShowingProfile = false
        rightSideButtonItems = self.navigationItem.rightBarButtonItems
        self.navigationItem.rightBarButtonItems = nil
        tableView.reloadData()
    }

    @IBAction func userDidSelectEdit(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "userDidSelectEditUserProfile", label: "Edit user profile button selected", value: nil).build() as! [AnyHashable: Any])

        if tableView.isEditing {
            self.navigationItem.title = ""
            let result = isUserDataValid()
            if  result == .none {
                rightSideButton.image = UIImage.init(named: "icnEdit")
                tableView.setEditing(false, animated: true)
                topCell?.setTopViewInNormalMode()
                updateUser()
            } else {
                switch result {
                case .firstname:
                    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .lastname:
                    let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .nickname:
                    let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .phone:
                    let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                default:
                    return
                }
            
            }
        } else {
            self.navigationItem.title = NSLocalizedString("profile.tab.editaccounttitle", comment: "")
            rightSideButton.image = UIImage.init(named: "icnCreate")
            tableView.setEditing(true, animated: true)
            topCell?.setTopViewInEditMode()
            
        }
    }

    func userDidStartEdit() {
        rightSideButtonItems = self.navigationItem.rightBarButtonItems
        self.navigationItem.rightBarButtonItems = nil
        
    }
    
    func userDidEndEdit() {

        self.navigationItem.rightBarButtonItems = rightSideButtonItems
    }
    
    // MARK: - tableView methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if isShowingProfile {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if topCell == nil {
                topCell = (tableView.dequeueReusableCell(withIdentifier: "YonaUserHeaderWithTwoTabTableViewCell", for: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell)
                topCell?.delegate = self
            }
            if let theUser = aUser {
                topCell!.avatarImageView.image = currentImage
                topCell!.setUser(theUser)
            }
            return topCell!

        }
        
        if isShowingProfile {
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserDisplayTableViewCell", for: indexPath) as! YonaUserDisplayTableViewCell
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
        } else {
        // must be changed to show badges
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserDisplayTableViewCell", for: indexPath) as! YonaUserDisplayTableViewCell
            
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 221
        }
        return 87
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    
    // MARK: - server call
    
    func updateUser() {
        
        if isUserDataValid() != .none {
            return
        }
        Loader.Show()
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
            if success {
                //self.aUser = user
                if self.currentImage != nil {
                    self.uploadImg()
                } else {
                    self.uploadUserData()
                }
            }}
        

    
    }
    func uploadImg(){
        
        guard let img = currentImage,
            let editlink = aUser?.editUserAvatar else {
        return
        }

            APIServiceManager.sharedInstance.uploadPhoto(img, path: editlink, httpMethod: httpMethods.put, onCompletion: {(success, imgdata, code) in
                
                self.uploadUserData()
            })
        
    }
    
    func uploadUserData() {
         UserRequestManager.sharedInstance.updateUser((aUser?.userDataDictionaryForServer())!, onCompletion: {(success, message, code, user) in
            //success so get the user?
                if success {
                    Loader.Hide()
                    self.aUser = user
                    if let _ = user?.confirmMobileLink {
                        if let controller : ConfirmMobileValidationVC = R.storyboard.login.confirmPinValidationViewController(()) {
                            controller.isFromUserProfile = true
                        
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    self.tableView.reloadData()
                } else {
//                    NSLog("----------------------- YONA")
//                    NSLog("----------------------- uploadUserData")
//                    NSLog(" ")
//                    NSLog("           ")
//                    NSLog("message %@",message!)

                    Loader.Hide()
                    if let alertMessage = message,
                        let code = code {
                        self.displayAlertMessage(code, alertDescription: alertMessage)
                    }
                }
            })
     }
    
    func isUserDataValid() -> validateError {
        if aUser?.firstName.count == 0 {
            self.displayAlertMessage("", alertDescription:NSLocalizedString("enter-first-name-validation", comment: ""))
            return .firstname
        } else if aUser?.lastName.count == 0 {
            self.displayAlertMessage("", alertDescription: NSLocalizedString("enter-last-name-validation", comment: ""))
            return .lastname
        } else if aUser?.mobileNumber.count == 0 {
            self.displayAlertMessage("", alertDescription:NSLocalizedString("enter-number-validation", comment: ""))
            return .phone
        } else if aUser?.nickname.count == 0 {
            self.displayAlertMessage("", alertDescription: NSLocalizedString("enter-nickname-validation", comment: ""))
            return .nickname
        } else {
            if let mobilenum = aUser?.mobileNumber {
                if mobilenum.removeWhitespace().removeBrackets().validateMobileNumber() == false {
                    self.displayAlertMessage("", alertDescription: NSLocalizedString("enter-number-validation", comment: ""))
                    return .phone
                }
            }
        }
        return .none
    }
    
    func didAskToAddProfileImage() {
        chooseImage(self)
    }
    
    
    func chooseImage(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.navigationBar.isTranslucent = false
        imagePickerController.navigationBar.barTintColor = .yiGrapeTwoColor() // Background color
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        let act = UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
            
            
        })
        actionSheet.addAction(act)
        
        
        let act1 = UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })
        
        actionSheet.addAction(act1)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image : UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            image = img
            
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            image = img
        }
        currentImage =  resizeImage(image, targetSize: CGSize(width:200, height: 200))
        topCell!.avatarImageView.image = currentImage
        topCell!.avatraInitialsLabel.text = ""
        picker.dismiss( animated: true, completion: nil)
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [kCTForegroundColorAttributeName as NSAttributedStringKey : UIColor.white,
                                                            kCTFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!] as? [NSAttributedStringKey : Any]
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss( animated: true, completion: nil)
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white,
                                                            NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
