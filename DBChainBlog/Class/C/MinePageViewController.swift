//
//  MinePageViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit
import SwiftLeePackage

class MinePageViewController: BaseViewController {

    lazy var contentView : MinePageView = {
        let view = MinePageView.init(frame: self.view.frame)
        return view
    }()

    var infoModel = userModel()

    override func setupUI() {
        super.setupUI()
        getCurrentUserInfo()
        view.addSubview(contentView)
    }

    override func setNavBar() {
        super.setNavBar()
        let navImgV = UIImageView.init(frame: CGRect(x: SCREEN_WIDTH * 0.5 - 90, y: kStatusBarHeight, width: 180, height: 40))
        navImgV.image = UIImage(named: "homepage_nav_image")
        self.navigationItem.titleView = navImgV

        let editBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        editBtn.setImage(UIImage(named: "homepage_edit"), for: .normal)
        editBtn.addTarget(self, action: #selector(settingPageClick), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: editBtn)
    }

    @objc func settingPageClick(){
        let vc = SettingMineViewController()
        vc.userInfoModel = self.infoModel
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func getCurrentUserInfo() {
        SwiftMBHUD.showLoading()
        let token = DBToken().createAccessToken(privateKey: UserDefault.getPrivateKeyUintArr() as! [UInt8], PublikeyData: UserDefault.getPublickey()!.hexaData)
        let url = QueryDataUrl + "\(token)/"
        Query().queryOneData(urlStr: url, tableName: DatabaseTableName.user.rawValue, appcode: APPCODE, fieldToValueDic: ["created_by":UserDefault.getAddress()!]) { [weak self] (responseData) in
            guard let mySelf = self else {return}
            let jsonStr = String(data: responseData, encoding: .utf8)
            if let userModel = BaseUserModel.deserialize(from: jsonStr) {
                if userModel.result?.count ?? 0 > 0  {
                    mySelf.infoModel = userModel.result!.last!
                    mySelf.contentView.model = mySelf.infoModel
                }
            }

            mySelf.getCurrentBlogText(urlStr: url)
        }
    }

    func getCurrentBlogText(urlStr: String) {
        Query().queryOneData(urlStr: urlStr, tableName: DatabaseTableName.blogs.rawValue, appcode: APPCODE, fieldToValueDic: ["created_by":UserDefault.getAddress()!]) {[weak self] (responeData) in
            guard let mySelf = self else {return}
            SwiftMBHUD.dismiss()
            let jsonStr = String(data: responeData, encoding: .utf8)
            if let blogModel = BaseBlogsModel.deserialize(from: jsonStr) {
                if blogModel.result?.count ?? 0 > 0 {
                    mySelf.contentView.logModelArr = blogModel.result!
                } else {
                    print("没有发布过博客")
                }
            }
        }
    }
}
