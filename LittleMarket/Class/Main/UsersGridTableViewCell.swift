//
//  UsersGridTableViewCell.swift
//  LittleMarket
//
//  Created by J on 2016/9/26.
//  Copyright © 2016年 J. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class UsersGridTableViewCell: UITableViewCell {

    // MARK: - 变量
    let sort:SortInfo = SortInfo.shareSortInfo
    @IBOutlet weak var imageGrid: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    @IBOutlet weak var lbClass: UILabel!
    
    //    MARK: - 方法
    func bindModel(model:UsersGridModel){
        //            测试
        switch Judge {
        case .test:
            lbName.text = "名称"
            lbInfo.text = "商品简介：用来简单介绍所出售的商品信息，以此确定是否进一步取得联系"
            lbClass.text = "分类"
            imageGrid.image = UIImage.init(imageLiteralResourceName: "default_img")
        case .debug:
            lbName.text = model.name
            lbInfo.text = model.note + "    价格:$" + model.price
            
            lbClass.text = " "
            for sortarr in sort.sortArray{
                if sortarr.sortid == model.sortid {
                    lbClass.text = sortarr.name
                }
            }
            
            Alamofire.request(model.pic).responseImage { response in
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    self.imageGrid.image = image
                }
            }
            
        case .run:
            break
            
        }
        
        
        
    }

}
