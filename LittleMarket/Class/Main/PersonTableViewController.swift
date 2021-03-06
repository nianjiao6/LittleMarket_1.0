//
//  PersonTableViewController.swift
//  LittleMarket
//
//  Created by J on 16/9/21.
//  Copyright © 2016年 J. All rights reserved.
//

import UIKit
import Alamofire

class PersonTableViewController: UITableViewController {
//  MARK: - 变量
    // 用户信息
    var userinfo:UserInfo = UserInfo.shareUserInfo
    @IBOutlet weak var lbUserName: UILabel!
    @IBOutlet weak var tbName: UITextField!
    @IBOutlet weak var tbPhone: UITextField!
    @IBOutlet weak var tbAdress: UITextField!
    @IBOutlet weak var tbNote: UITextField!
    // 编辑
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    // 记录修改前的值
    var lastName:String = ""
    var lastPhone:String = ""
    var lastAdress:String = ""
    var lastNote:String = ""
    
//  MARK: - 初始化
    func loadInfo()  {
        
        //            测试
        switch Judge {
        case .test:
            lbUserName.text = "用户名"
            tbName.text = "昵称"
            tbPhone.text = "电话"
            
            tbAdress.text = "地址"
            tbNote.text = "备注"
        case .debug:
            lbUserName.text = userinfo.username
            tbName.text = userinfo.name
            tbPhone.text = userinfo.phone
            
            tbAdress.text = userinfo.adress
            tbNote.text = userinfo.note
        case .run:
            break
            
        }

        
        
    }
//  MARK: - 编辑
    @IBAction func editClick(_ sender: UIBarButtonItem) {
        self.tbCancel()
        if btnEdit.tag == 0 {
            
            btnCancel.title = "取消"
            // 保存原有内容
            lastName = tbName.text!
            lastPhone = tbPhone.text!
            
            lastAdress = tbAdress.text!
            lastNote = tbNote.text!
            
            btnEdit.tag = 1
            btnEdit.title = "保存"
            // 在单元格点击方法中修改数据
            tbName.textColor = UIColor.lightGray
            tbPhone.textColor = UIColor.lightGray
            tbAdress.textColor = UIColor.lightGray
            tbNote.textColor = UIColor.lightGray
        }
        else {
            // 数据验证
            let newName:String = tbName.text!
            let newPhone:String = tbPhone.text!
            var newAdress:String = tbAdress.text!
            var newNote:String = tbNote.text!
            
            if newName.isEmpty || newPhone.isEmpty {
                // HUD提示
                self.HUDtext(text: "请确认信息")
                return
            }
            if newAdress.isEmpty {
                newAdress = "- -"
                tbAdress.text = newAdress
            }
            if newNote.isEmpty {
                newNote = "- -"
                tbNote.text = newNote
            }
            
            if !Validate.nickname(newName).isRight {
                self.HUDtext(text: "请确认姓名格式")
                return
            }
            if !Validate.phoneNum(newPhone).isRight {
                self.HUDtext(text: "请确认电话格式")
                return
            }
            
            // 数据上传
            // 验证用户名是否存在
            self.userNameisFind(newName: newName, newPhone: newPhone, newAdress: newAdress, newNote: newNote)
            
        }
    }
    func userNameisFind(newName:String , newPhone:String , newAdress:String , newNote:String){
        let parameter:Dictionary = ["username":userinfo.username];
        
        hud = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        hud?.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
        hud?.contentColor = UIColor.init(colorLiteralRed: 0, green: 0.6, blue: 0.7, alpha: 1)
        hud?.label.text = NSLocalizedString("Check", comment: "HUD loading title")
        
        // 框架进行网络请求
        Alamofire.request(API.CheckUserAPI, method: .get, parameters: parameter).responseJSON { (response) in
            switch response.result{
            case .success(_):
                print("请求成功")
                let response = response.result.value as! [String:AnyObject]
                if response["isuse"] as! String == "0"
                {
                    DispatchQueue.main.async(execute: {
                        self.HUDHide()
                        self.HUDtext(text: "无法找到用户")
                        return
                    })
                    
                }
                // 存入数据库
                self.updateLoad(newName: newName, newPhone: newPhone, newAdress: newAdress, newNote: newNote)
                
            case .failure(let error):
                print(error)
                
                // HUD提示
                DispatchQueue.main.async(execute: {
                    self.HUDHide()
                    self.HUDtext(text: "请求失败")
                })
                
            }
        }

    }
    
    
    
    
    func updateLoad(newName:String , newPhone:String , newAdress:String , newNote:String)  {
        
        let parameter:Dictionary = ["userid":userinfo.userid,
                                    "name":newName,
                                    "phone":newPhone,
                                    "adress":newAdress,
                                    "note":newNote];
        // 上传
        self.HUDHide()
        hud = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        hud?.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
        hud?.contentColor = UIColor.init(colorLiteralRed: 0, green: 0.6, blue: 0.7, alpha: 1)
        
        // 框架进行网络请求
        Alamofire.request(API.EditUserAPI, method: .post, parameters: parameter).responseJSON { (response) in
            switch response.result{
            case .success(_):
                print("请求成功")
                print(response.result.value!)
                let response = response.result.value as! [String:AnyObject]
                if response["code"] as! String == "200"
                {
                    // HUD提示
                    DispatchQueue.main.async(execute: {
                        self.HUDHide()
                        self.HUDtext(text: "保存成功")
                        
                        self.btnEdit.tag = 0
                        self.btnEdit.title = "编辑"
                        self.btnCancel.title = "注销"
                        // 改回颜色，退出编辑
                        self.tbName.textColor = UIColor.black
                        self.tbPhone.textColor = UIColor.black
                        self.tbAdress.textColor = UIColor.black
                        self.tbNote.textColor = UIColor.black
                    })
                    
                }
                
                
            case .failure(let error):
                print(error)
                
                // HUD提示
                DispatchQueue.main.async(execute: {
                    self.HUDHide()
                    self.HUDtext(text: "请求失败")
                })
                
            }
        }
        
    }
    
    // 取消所有按键可用
    func tbCancel()  {
        let tb:Array = [tbName,tbPhone,tbAdress,tbNote]
        for textbox in tb{
            textbox?.isEnabled = false
        }
    }
//  MARK: - 退出
    
    @IBAction func loginOut(_ sender: AnyObject) {
        if btnEdit.tag == 0 {
            // 修改信息
            userinfo.loginStatus = false
            userinfo.saveUserInfoToSandbox()
            
            // 如有推送，修改推送信息
            
            // 跳转到登录界面
            self.enterLoginPage()
        }
        
        if btnEdit.tag == 1 {
            // 修改信息
            tbName.text = lastName
            tbPhone.text = lastPhone
            
            tbAdress.text = lastAdress
            tbNote.text = lastNote
            self.tbCancel()
            self.btnEdit.tag = 0
            self.btnEdit.title = "编辑"
            self.btnCancel.title = "注销"
            
            // 改回颜色，退出编辑
            self.tbName.textColor = UIColor.black
            self.tbPhone.textColor = UIColor.black
            self.tbAdress.textColor = UIColor.black
            self.tbNote.textColor = UIColor.black
        }
        
        
    }
//    MARK: - 跳转
    // 跳转至Login
    func enterLoginPage()  {
        self.dismiss(animated: false, completion: nil)
        // 获取登录的故事版
        let storyboard:UIStoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        self.view.window?.rootViewController = storyboard.instantiateInitialViewController()
        
    }
//  MRAK: - 清理缓存
    @IBAction func Clean(_ sender: UIButton) {
        // 取出cache文件夹路径
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        // 打印路径,需要测试的可以往这个路径下放东西
        print(cachePath ?? "0")
        // 取出文件夹下所有文件数组
        let files = FileManager.default.subpaths(atPath: cachePath!)
        // 用于统计文件夹内所有文件大小
        var big = Int();
        
        
        // 快速枚举取出所有文件名
        for p in files!{
            // 把文件名拼接到路径中
            let path = cachePath!.appendingFormat("/\(p)")
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            // 用元组取出文件大小属性
            for (abc,bcd) in floder {
                // 只去出文件大小进行拼接
                if abc == FileAttributeKey.size{
                    big += (bcd as AnyObject).integerValue
                }
            }
        }
        
        // 提示框
        let message = "\(big/(1024*1024))M缓存"
        let alert = UIAlertController(title: "清除缓存", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let alertConfirm = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (alertConfirm) -> Void in
            // 点击确定时开始删除
            for p in files!{
                // 拼接路径
                let path = cachePath!.appendingFormat("/\(p)")
                // 判断是否可以删除
                if(FileManager.default.fileExists(atPath: path)){
                    // 删除
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch let error as NSError {
                        print(error)
                    }
                    
                }
            }
        }
        alert.addAction(alertConfirm)
        let cancle = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (cancle) -> Void in
            
        }
        alert.addAction(cancle)
        // 提示框弹出
        present(alert, animated: true) { () -> Void in
            
        }
    }
    
    
//  MARK: - 系统
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnEdit.title = "编辑"
        
        self.loadInfo() // 可以去除，主页加载时会重新登录验证并写入缓存
        
        // All three of these calls are equivalent
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func loadView() {
        super.loadView()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    点击单元格触发事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        // 取消所有按键可用
        self.tbCancel()
        // 定位
        if btnEdit.tag == 1{
            switch indexPath {
            case [0,1]:
                tbName.isEnabled = true
            case [1,0]:
                tbPhone.isEnabled = true
            case [1,1]:
                tbAdress.isEnabled = true
            case [1,2]:
                tbNote.isEnabled = true
            default:
                break
            }
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//         无法触发
        self.tbCancel()
        // 退出编辑模式
        self.view.endEditing(true)
    }
   
    /*
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//     MRAK: - HUDTEXT
    var hud:MBProgressHUD?
    
    func HUDtext(text:String)  {
        
        hud = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        
        hud?.mode = MBProgressHUDMode.text
        hud?.label.text = NSLocalizedString(text, comment: "HUD message title")
        hud?.offset = CGPoint.init(x: 0, y: MBProgressMaxOffset)
        hud?.hide(animated: true, afterDelay: 2)
    }
    func HUDHide()  {
        hud?.hide(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 取消键盘
        self.tbCancel()
        // 清空提示框
        self.HUDHide()
        
    }

}
