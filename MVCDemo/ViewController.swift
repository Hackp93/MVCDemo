//
//  ViewController.swift
//  MVCDemo
//
//  Created by Manu Singh on 24/11/19.
//  Copyright © 2019 hackp93. All rights reserved.
//

import UIKit

//MVC design pattern
//controller fethes the data, stores the data and populates view with data
class ViewController: UIViewController {

    var cityNames : [City] = []
    
    //not initializing fetcher in view controller. It has to be injected from outside the controller(This is called dependency injection)
    var cityFetcher : CityListFetcher?
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCityList()
        // Do any additional setup after loading the view.
    }
    
    func fetchCityList(){
        cityFetcher?.getCities(completion: { (list) in
            self.cityNames = list
            self.refreshUI()
        })
    }
    
    func refreshUI(){
        tableView.reloadData()
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cityNames[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
