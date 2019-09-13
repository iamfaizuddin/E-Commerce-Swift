//
//  ViewController.swift
//  Heady
//
//  Created by Faiz on 11/06/2018.
//  Copyright © 2018 iamfaizuddin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate, UIActionSheetDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoriestableView: UITableView!
    
    var searchActive = false

    var categoriesArr: [AnyObject] = []
    var rankingsArr: [AnyObject] = []
    var filteredcategoriesArr: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        getresultsfromApi();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Calling the APi and getting the results
    func getresultsfromApi(){
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: "http://stark-spire-93433.herokuapp.com/json")
            URLSession.shared.dataTask(with: url!, completionHandler: {
                (data, response, error) in
                if(error != nil){
                    print("error")
                }else{
                    do{
                        
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject

                        self.categoriesArr = parsedData["categories"] as! [AnyObject]
                        self.rankingsArr = parsedData["rankings"] as! [AnyObject]
                        
                        // Saving the data locally in User Defaults
//                        UserDefaults.standard.setValue(parsedData, forKey: "json")
                        
                        //                    guard let data = UserDefaults.standard.value(forKey: "json") as? Data else { return }
                        //                    let json = JSON(data)
                        
                        DispatchQueue.main.async {
                            self.categoriestableView.dataSource = self
                            self.categoriestableView.delegate = self
                            
                            self.categoriestableView.reloadData()
                        }
                        
                    }catch let error as NSError{
                        print(error)
                    }
                }
            }).resume()
        }
    }
    
    // Function for Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        if(searchActive){
            return filteredcategoriesArr.count
        }
        else{
            return categoriesArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(searchActive){
            let arr = self.filteredcategoriesArr[section] as! NSDictionary
            let nameStr = arr["name"] as? String
            return  nameStr
        }
        else{
            let arr = self.categoriesArr[section] as! NSDictionary
            let nameStr = arr["name"] as? String
            return  nameStr
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if(searchActive){
//            let arr = self.filteredcategoriesArr[section]
//            let products = arr["products"] as AnyObject
            return 1
        }
        else{
            let arr = self.categoriesArr[section] as! NSDictionary
            let products = arr["products"] as! NSArray
            return products.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: Product!
        cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as! Product
        
        if (cell == nil) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as! Product
        }else{
            cell.contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        
        if(searchActive){
            let arr = self.filteredcategoriesArr[indexPath.section] as! NSDictionary
            let products = arr["products"] as! NSDictionary
//            let products = productsArr[indexPath.row] as! NSDictionary
            
            let nameStr = products["name"] as? String
            let taxArr = products["tax"] as! NSDictionary
            let taxStr = taxArr["name"] as? String
            let valueStr = taxArr["value"] as? Double
            let b:String = String(format:"%f", valueStr!)
            
            var taxstr = "Tax : "
            taxstr += taxStr!
            taxstr += "  Value : "
            taxstr += b
            
            cell.nameLabel = UILabel(frame: CGRect(x: 10, y: 5 , width: cell.frame.size.width, height: 20))
            cell.nameLabel.textAlignment = NSTextAlignment.left
            cell.contentView.addSubview(cell.nameLabel)
            cell.nameLabel.text = nameStr
            
            cell.taxLabel = UILabel(frame: CGRect(x: 10, y: 30 , width: cell.frame.size.width, height: 20))
            cell.taxLabel.textAlignment = NSTextAlignment.left
            cell.contentView.addSubview(cell.taxLabel)
            cell.taxLabel.text = taxstr
            
            cell.colorLabel = UILabel(frame: CGRect(x: 10, y: 75 , width: cell.frame.size.width, height: 20))
            cell.colorLabel.textAlignment = NSTextAlignment.center
            cell.contentView.addSubview(cell.colorLabel)
            cell.colorLabel.text = "Avalable Colors & Sizes"
            
            var y = 100
            
            if let variantsArr = products["variants"] as? [[String : Any]] {
                for variants in variantsArr {
                    
                    y = y + 5
                    
                    if let colorStr = variants["color"] as? String {
                        var colorstr = "Color : "
                        colorstr += colorStr
                        
                        cell.colLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                        cell.colLabel.textAlignment = NSTextAlignment.left
                        cell.colLabel.font = cell.colLabel.font.withSize(12)
                        cell.colLabel.text = colorstr
                        cell.contentView.addSubview(cell.colLabel)
                        
                        y = y + 15
                    }
                    
                    if let sizeStr = variants["size"] as? Int {
                        let bsize:String = String(format:"%d", sizeStr)
                        var sizestr = "Size : "
                        sizestr += bsize
                        
                        cell.sizeLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                        cell.sizeLabel.textAlignment = NSTextAlignment.left
                        cell.sizeLabel.font = cell.sizeLabel.font.withSize(12)
                        cell.contentView.addSubview(cell.sizeLabel)
                        cell.sizeLabel.text = sizestr
                        
                        y = y + 15
                    }
                    
                    if let priceStr = variants["price"] as? Int {
                        let bprice:String = String(format:"%d", priceStr)
                        var pricestr = "Price : "
                        pricestr += bprice
                        
                        cell.priceLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                        cell.priceLabel.textAlignment = NSTextAlignment.left
                        cell.priceLabel.font = cell.priceLabel.font.withSize(12)
                        cell.contentView.addSubview(cell.priceLabel)
                        cell.priceLabel.text = pricestr
                        
                        y = y + 25
                    }
                }
            }
        }
        else{
            let arr = self.categoriesArr[indexPath.section] as! NSDictionary
            let productsArr = arr["products"] as! NSArray
            let products = productsArr[indexPath.row] as! NSDictionary
            
            let nameStr = products["name"] as? String
            let taxArr = products["tax"] as! NSDictionary
            let taxStr = taxArr["name"] as? String
            let valueStr = taxArr["value"] as? Double
            let b:String = String(format:"%f", valueStr!)

            var taxstr = "Tax : "
            taxstr += taxStr!
            taxstr += "  Value : "
            taxstr += b

            cell.nameLabel = UILabel(frame: CGRect(x: 10, y: 5 , width: cell.frame.size.width, height: 20))
            cell.nameLabel.textAlignment = NSTextAlignment.left
            cell.contentView.addSubview(cell.nameLabel)
            cell.nameLabel.text = nameStr
            
            cell.taxLabel = UILabel(frame: CGRect(x: 10, y: 30 , width: cell.frame.size.width, height: 20))
            cell.taxLabel.textAlignment = NSTextAlignment.left
            cell.contentView.addSubview(cell.taxLabel)
            cell.taxLabel.text = taxstr
            
            cell.colorLabel = UILabel(frame: CGRect(x: 10, y: 75 , width: cell.frame.size.width, height: 20))
            cell.colorLabel.textAlignment = NSTextAlignment.center
            cell.contentView.addSubview(cell.colorLabel)
            cell.colorLabel.text = "Avalable Colors & Sizes"
            
            var y = 100

            if let variantsArr = products["variants"] as? [[String : Any]] {
                for variants in variantsArr {
                    
                    y = y + 5

                    let colorStr = variants["color"] as? String
                    var colorstr = "Color : "
                    colorstr += colorStr!

                    cell.colLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                    cell.colLabel.textAlignment = NSTextAlignment.left
                    cell.colLabel.font = cell.colLabel.font.withSize(12)
                    cell.colLabel.text = colorstr
                    cell.contentView.addSubview(cell.colLabel)
                    
                    y = y + 15

                    let sizeStr = variants["size"] as! Int
                    let bsize:String = String(format:"%d", sizeStr)
                    var sizestr = "Size : "
                    sizestr += bsize

                    cell.sizeLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                    cell.sizeLabel.textAlignment = NSTextAlignment.left
                    cell.sizeLabel.font = cell.sizeLabel.font.withSize(12)
                    cell.contentView.addSubview(cell.sizeLabel)
                    cell.sizeLabel.text = sizestr

                    y = y + 15

                    let priceStr = variants["price"] as! Int
                    let bprice:String = String(format:"%d", priceStr)
                    var pricestr = "Price : "
                    pricestr += bprice

                    cell.priceLabel = UILabel(frame: CGRect(x: 10, y: y , width: Int(cell.frame.size.width), height: 15))
                    cell.priceLabel.textAlignment = NSTextAlignment.left
                    cell.priceLabel.font = cell.priceLabel.font.withSize(12)
                    cell.contentView.addSubview(cell.priceLabel)
                    cell.priceLabel.text = pricestr

                    y = y + 25
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    // SearchBar Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.categoriestableView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.categoriestableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.showsCancelButton = true
        
        DispatchQueue.global(qos: .background).async {
//            for xdata in self.categoriesArr
//            {
//                let nameRange: NSRange = xdata.rangeOfString(searchText, options: [NSString.CompareOptions.caseInsensitive ,NSString.CompareOptions.anchored])
//
//                if nameRange.location != NSNotFound{
//                    self.filteredcategoriesArr.add(xdata)
//                }
//            }
            
            
        }
        
        self.filteredcategoriesArr.removeAll()
        
//        for xdata in self.categoriesArr
//        {
//            let products = xdata["products"]
//            for productsArr in products as! [AnyObject]
//            {
//                let nameStr = productsArr["name"] as? String
//                if nameStr?.range(of:searchText) != nil {
//                    if xdata.count > 0 {
//                        self.filteredcategoriesArr.append(xdata)
//                    }
//                }
//            }
//        }
        
        for xdata in self.categoriesArr
        {
            let nsDict = xdata as! NSDictionary
            let myMutableDict: NSMutableDictionary = NSMutableDictionary(dictionary: nsDict)
            
            let products = xdata["products"] as! [AnyObject]
            for productsArr in products
            {
                let nameStr = productsArr["name"] as? String
                if nameStr?.range(of:searchText) != nil {
                    if xdata.count > 0 {
                        myMutableDict["products"] = productsArr
                        self.filteredcategoriesArr.append(myMutableDict)
                    }
                }
            }
        }
        
        if (self.filteredcategoriesArr.count == 0){
            self.searchActive = false
        }else{
            self.searchActive = true
        }
        self.categoriestableView.reloadData()
    }
    
    @IBAction func btnFiltersClicked(_ sender: Any) {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Please select", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.searchActive = false
            self.categoriestableView.reloadData()
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        for item in self.rankingsArr{
            let nameStr = item["ranking"] as? String
            
            actionSheetControllerIOS8.addAction(UIAlertAction(title: nameStr, style: .default, handler: doSomething))
        }
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func doSomething(action: UIAlertAction) {
        self.filteredcategoriesArr.removeAll()
        
        for rankdata in self.rankingsArr
        {
            let rankingStr = rankdata["ranking"] as? String
            let titleStr = action.title
            if rankingStr == titleStr{
                let rankProducts = rankdata["products"] as! [NSDictionary]
                for data in rankProducts{
                    let id = data.value(forKey: "id") as? String
                    
                    for xdata in self.categoriesArr
                    {
                        let nsDict = xdata as! NSDictionary
                        let myMutableDict: NSMutableDictionary = NSMutableDictionary(dictionary: nsDict)
                        
                        let products = xdata["products"] as! [AnyObject]
                        for productsArr in products
                        {
                            let idint = productsArr["id"] as? String
                            if(id == idint){
                                myMutableDict["products"] = productsArr
                                self.filteredcategoriesArr.append(myMutableDict)
                            }
                        }
                    }
                }
            }
        }
        
        if (self.filteredcategoriesArr.count == 0){
            self.searchActive = false
        }else{
            self.searchActive = true
        }
        self.categoriestableView.reloadData()
    }
}

