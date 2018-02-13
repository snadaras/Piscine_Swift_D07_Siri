//
//  ViewController.swift
//  Siri
//
//  Created by Siva NADARASSIN on 1/17/18.
//  Copyright © 2018 Siva NADARASSIN. All rights reserved.
//

import UIKit
import RecastAI
import ForecastIO

class ViewController: UIViewController {
    
    var bot : RecastAIClient?
    // information about tokens from devs sites
    let RECASTAI_TOKEN = "6ee30f93507b3fc8c9b61009c028116d"
    let FORECASTIO_TOKEN = "b2da2dcd0fddd492b09eb0802d3a21b5"
    
    @IBOutlet weak var itemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var request: UITextField!
    
    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var fetchDataLbl: UILabel!
    
    @IBAction func GoButton(_ sender: UIButton) {
    
        print("goButton appelé")
        
        guard let myString = request.text, !myString.isEmpty else {
            print("String is nil or empty.")
            let alert = UIAlertController(title: "Info", message: "Search cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            }

        self.fetchDataLbl.isHidden = false
        itemActivityIndicator.startAnimating()
        itemActivityIndicator.hidesWhenStopped = true
        makeRequest(request : request.text!)
        return
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // --- Do any additional setup after loading the view, typically from a nib.
        self.bot = RecastAIClient(token : "6ee30f93507b3fc8c9b61009c028116d", language: "en")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // --- Dispose of any resources that can be recreated.
    }

    // --- Make the text-request to Recast.AI API
    
    func makeRequest(request: String)
    {
        // --- Call makeRequest with string parameter to make a text request
        print("formatage et appel a recast")
        
        self.bot?.textRequest(request, successHandler: recastRequestDone, failureHandle: processError)
    }
    /**
     Method called when the request was successful
     
     - parameter response: the response returned from the Recast API
     - returns: void
     */

    func recastRequestDone(_ response : Response)
    {
        print("recastRequestDone: \(response)")
        if let location = response.get(entity: "location") {
            print(location)
            answer.text = "Location found : \(location["raw"]!), processing.."
            
        callForecast(location: location["raw"] as! String, lat: location["lat"] as! Double, lng: location["lng"] as! Double)
        }
        else {
            DispatchQueue.main.async {
                // --- coming back to primary thread for the display
                
                self.answer.text = "Sorry, I didn't get it"
                self.itemActivityIndicator.stopAnimating()
                self.itemActivityIndicator.hidesWhenStopped = true
                self.fetchDataLbl.isHidden = true
                print("appel non abouti a recast")
                
            }
        }
    }
    
    func processError(_ err: Error) {
        DispatchQueue.main.async { // il faut revenir au thread principal pour toucher a l'affichage
            print("processError : \(err)")
            self.answer.text = "Error"
        }
    }
    
    func callForecast(location: String, lat: Double, lng: Double){
        print("call @ Forecast")
        let client = DarkSkyClient(apiKey: FORECASTIO_TOKEN)
        client.units = .si
       
        client.getForecast(latitude: lat, longitude: lng) { result in
            DispatchQueue.main.async {
                // --- coming back to primary thread for the display
                switch result {
                case .success(let currentForecast, let requestMetadata):
                    //  ---- We got the current forecast!
                    print("on a recu une reponse")
                    print("currentForecast : \(currentForecast)")
                    print("requestMetadata : \(requestMetadata)")
                    self.answer.text = location + " : " + (currentForecast.currently?.summary)! + "\nCurrent temperature : " + String(describing: (currentForecast.currently?.temperature)!) + " °C"
                case .failure(let error):
                    // ---  We have an error
                    print("Erreur : \(error)")
                    self.answer.text = "Error"
                }
                self.itemActivityIndicator.stopAnimating()
                self.itemActivityIndicator.hidesWhenStopped = true
                self.fetchDataLbl.isHidden = true            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDataLbl.isHidden = false
        itemActivityIndicator.stopAnimating()
        itemActivityIndicator.hidesWhenStopped = true
        fetchDataLbl.isHidden = true
        
    }
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("prepare appelé")
    }
}

