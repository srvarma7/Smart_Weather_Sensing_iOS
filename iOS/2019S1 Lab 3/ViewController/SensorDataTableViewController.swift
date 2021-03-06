//
//  SensorDataTableViewController.swift
//  2019S1 Lab 3
//
//  Created by Ganesh Kanchibhotla on 1/10/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

//Displays the historical data from the database in a sorted order

import UIKit

class SensorDataTableViewController: UITableViewController, DatabaseListener {
    
    var sensorDataList = [SensorData]()
    weak var databaseController: DatabaseProtocol?
    var selectedRow = SensorData()
    var listenerType = ListenerType.data

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate!.databaseController
        tableView.delegate = self
        
    }
    
    //database listener for the firebase
    func onDataListChange(change: DatabaseChange, dataList: [SensorData]) {
        sensorDataList = dataList
        sensorDataList.sort(by: {$0.unixTime > $1.unixTime})
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorDataList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        let data = sensorDataList[indexPath.row]
        cell.imageView?.image = UIImage(named: "40x40.png")
        UIView.animate(withDuration: 1, animations: {
            let red = CGFloat(Float(data.red)!/255)
            let green = CGFloat(Float(data.green)!/255)
            let blue = CGFloat(Float(data.blue)!/255)
            cell.imageView?.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
            cell.imageView?.layer.cornerRadius = ((cell.imageView?.frame.size.width)!)/2
            cell.imageView?.layer.borderWidth = 1
        })
        cell.imageView?.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.textLabel?.text = "Date " + data.date
        cell.detailTextLabel?.text = "Time: " + data.time
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = sensorDataList[indexPath.row]
        performSegue(withIdentifier: "toDetails", sender: self)
    }

    //segue to the details screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            let controller = segue.destination as! DetailsViewController
            controller.currentData = selectedRow
        }
    }
    
    //REFERENCE https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, newSize: CGFloat) -> UIImage{
        UIGraphicsBeginImageContext(CGSize(width: newSize, height: newSize))
        image.draw(in: CGRect(x: 0, y: 0, width: newSize, height: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
}
