//
//  FirebaseController.swift
//  2019S1 Lab 3
//
//  Created by Ganesh Kanchibhotla on 28/9/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

//To fetch data from Firebase in realtime

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var sensorRef: CollectionReference?
    var teamsRef: CollectionReference?
    var dataList: [SensorData]
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        dataList = [SensorData]()
        
        super.init()
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            
            self.setUpListeners()
        }
    }
    
    //To connect and get data from the database
    func setUpListeners() {
        
        sensorRef = database.collection("Sensor")
        sensorRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseHeroesSnapshot(snapshot: querySnapshot!)
            
        }
    }
    
    //Parse Data from document to Sensor class type
    func parseHeroesSnapshot(snapshot: QuerySnapshot){
        
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            
            if !dataChecker(data: change){
                return
            }
            
            let red = change.document.data()["Red"] as! String
            let green = change.document.data()["Green"] as! String
            let blue = change.document.data()["Blue"] as! String
            
            let temperature = change.document.data()["Temperature"] as! String
            let pressure = change.document.data()["Pressure"] as! String
            let altitude = change.document.data()["Altitude"] as! String
            
            let number = change.document.data()["Number"] as! Int
            let date = change.document.data()["Date"] as! String
            let unixTime = change.document.data()["UnixTime"] as! String
            let time = change.document.data()["Time"] as! String
            
            let newData = SensorData()
            newData.red = red
            newData.blue = blue
            newData.green = green
            newData.altitude = altitude
            newData.temperature = temperature
            newData.pressure = pressure
            newData.number = number
            newData.date = date
            newData.time = time
            newData.unixTime = unixTime
            newData.id = documentRef
            dataList.append(newData)
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.data || listener.listenerType == ListenerType.all {
                listener.onDataListChange(change: .update, dataList: dataList)
            }
        }
    }

    //Protocol for adding listener to a viewController
    func addListener(listener: DatabaseListener) {
        
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.data || listener.listenerType == ListenerType.all {
            listener.onDataListChange(change: .update, dataList: dataList)
        }
        
    }
    
    //Protocol tp remove listener from a viewController
    func removeListener(listener: DatabaseListener) {
        
        listeners.removeDelegate(listener)
        
    }
    
    //Function to check nil values if any when parsing the data from firebase
    func dataChecker(data: DocumentChange) -> Bool{
        let attributes = ["Red", "Blue", "Green", "Temperature", "Pressure", "Altitude", "Date", "UnixTime", "Time"]
        
        for value in attributes{
            if data.document.data()[value] as? String == nil{
                return false
            }
        }
        
        if data.document.data()["Number"] as? Int == nil{
            return false
        }
        return true
    }
    
}
