//
//  ViewController.swift
//  tableDrag
//
//  Created by Ruben Mimoun on 31/03/2021.
//

import UIKit

let CELL_ID = "cellIDENTIFIER"
let NOTIFICATION_NAME = "com.moondev.postTableNotification"

enum ImageName  {
    
    case Bob(String) , Patricia(String) , Makoumba(String)
    
    var value : String {
        switch self {
        case .Bob:
            return "Bob"
        case .Patricia:
            return "Patricia"
        case .Makoumba:
            return "Makoumba"
        }
    }
    
    var imageName : UIImage {
        switch self {
        case .Bob(let name):
            print(name)
            return UIImage(systemName:  name)!
        case .Patricia(let name):
            return UIImage(systemName: name)!
        case .Makoumba(let name):
            return UIImage(systemName: name)!
        }
    }
    
}

protocol ImageValueListener  {
    func addImage(with image : UIImage, _ index : Int)
    func cleanImage(_ index : Int)
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var draggableImageView: UIImageView!
    
    @IBOutlet weak var container: UIStackView!
    
    var imageValueDelegate : ImageValueListener!
    
    var tableData : [String : String] = ["Bob" : "paperplane", "Patricia" : "person.fill", "Makoumba" : "pencil.circle"]
    
    var imageViewArr : [UIImageView]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageValueDelegate = self
        imageViewArr = [imageOne, imageTwo, imageThree]
        initObserver()
        initTableViewCells()
        initDraggableImageView()

    }
    
    func initTableViewCells(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.delegate =  self
        tableView.dataSource =  self
    }
    
    func initDraggableImageView(){
        let dragGesture =  UIPanGestureRecognizer(target: self, action: #selector(dragMe(_:)))
        draggableImageView.addGestureRecognizer(dragGesture)
    }
    
    
    func initObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(passDataThroughObservers(_:)), name: Notification.Name(NOTIFICATION_NAME), object: nil)
    }

    @objc func passDataThroughObservers(_ notification : Notification){
        if let object = notification.userInfo {
            let dict =  object as? [String : String]
            guard let key = dict?.first?.key else {return}
            guard let value = dict?.first?.value else {return}
            updateImages(index: 0, image: ImageName.Bob(value).imageName)
                switch key {
                case ImageName.Bob(key).value:
                    return updateImages(index: 0, image: ImageName.Bob(value).imageName)
                case ImageName.Patricia(key).value:
                    return updateImages(index: 1, image: ImageName.Patricia(value).imageName)
                case ImageName.Makoumba(key).value:
                    return updateImages(index: 2, image: ImageName.Makoumba(value).imageName)

                default:
                    print("count")

                    print(container.subviews.count - 1)
                        updateImages(index: container.subviews.count - 1 , image: UIImage(systemName: value)!)
                    
                }
            
        }
    }
    
    @objc func dragMe(_ gesture : UIPanGestureRecognizer){
         let location = gesture.location(in: self.view)
        if let dragged =  gesture.view {
            dragged.center = location
        }
        
        if gesture.state == UIGestureRecognizer.State.ended{
            checkIfIntableFrame()
        }
        
    }
    
    
    func checkIfIntableFrame(){
        if !tableView.frame.intersects(draggableImageView.frame) {return}
        tableData["Mario"] = "scribble"
        container.addArrangedSubview(UIImageView())
        container.distribution = .fillEqually
            if let last =  container.subviews.last as? UIImageView{
                imageViewArr?.append(last)
            }
        draggableImageView.removeFromSuperview()
        tableView.reloadData()
    }
    
    func updateImages(index : Int, image : UIImage){
        imageValueDelegate.addImage(with: image,index)
        imageValueDelegate.cleanImage(index)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(Notification.Name(rawValue: NOTIFICATION_NAME))
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        cell.textLabel?.text = tableData.keys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newDict : [String : String] = [tableData.keys[indexPath.row] : tableData.values[indexPath.row]]
            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_NAME), object: nil, userInfo: newDict )
        
  
    }
    
}


extension Dictionary where Key == String, Value == String {
    
    var keys : [String] {
        return self.map{$0.key}
    }
    
    var values : [String]{
        return self.map{$0.value}
    }
    
}

extension ViewController : ImageValueListener {
    
    func addImage(with image: UIImage, _ index : Int) {
        print(index)
        if let imageview =  imageViewArr?[index]{
            imageview.image = image
        }
    }
    
    func cleanImage(_ index : Int) {
        if let arr =  imageViewArr {
            for i in  0...arr.count-1 {
                if (i != index){
                    arr[i].image = nil
                }
            }
        }
    }
    
    
}

