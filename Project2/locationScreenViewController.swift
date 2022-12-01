//
//  locationScreenViewController.swift
//  Project2
//
//  Created by Charles Roy on 2022-11-30.
//

import UIKit
import CoreLocation

class locationScreenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    
    var temperature_in = "C"
    var search = ""
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBox.delegate = self
        imageDisplayBlock()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        search = searchBox.text!
        loadWeather()
        return true
    }
    
    private func imageDisplayBlock(){
        let config=UIImage.SymbolConfiguration(paletteColors: [
            .white,
            .tertiaryLabel])
        weatherIconView.preferredSymbolConfiguration=config
        weatherIconView.image=UIImage(systemName:  "exclamationmark.icloud.fill")
    }
    
    //Location button action
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    //Search button action
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        search = searchBox.text!
        loadWeather()
    }
    //Segmented Control action
    @IBAction func tempToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            temperature_in = "C"
        } else if sender.selectedSegmentIndex == 1 {
            temperature_in = "F"
        }
        loadWeather()
    }

    //Cancel button action
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func loadWeather() {
       
        //Step 1: Get URL
        guard  let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        
        //Step 2: create URLSession
        let session = URLSession.shared
        
        //Step 3: Create task fpr the session
        let dataTask = session.dataTask(with: url) { data, response, error in

            guard error == nil else {
                print("Recieved error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJSON(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.weatherCondition.text = weatherResponse.current.condition.text
                    self.checkingWeatherCode(i: weatherResponse.current.condition.code)

                    if self.temperature_in == "C" {
                        self.tempLabel.text = "\(weatherResponse.current.temp_c)\(self.temperature_in)"
                    }
                    else {
                        self.tempLabel.text = "\(weatherResponse.current.temp_f)\(self.temperature_in)"
                    }
                }
            }
        }
        
        //Step 4: Start the task
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "b88add85022e4959bc842241222311"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }
    
    private func parseJSON(data: Data) ->WeatherResponse? {
        
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error Decoding")
        }
        return weather
    }
    private func checkingWeatherCode(i:Int){

        // checking the codes and displaying the locaion images in the screen

        switch i{
        case 1000: let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "sun.max.circle.fill")
        case 1003,1006:let config=UIImage.SymbolConfiguration(paletteColors:[
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "cloud.fill")
        case 1009,1063,1180,1183,1186,1189,1192,1195,1204,1207,1240,1243,1246,1249,1252:
            let config=UIImage.SymbolConfiguration(paletteColors:[
                .systemBlue,
                .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "cloud.rain")
        case 1066,1072,1114,1198,1201,1210,1213,1216,1219,1222,1225,1237,1255,1258,1261,1264,1282:
            let config=UIImage.SymbolConfiguration(paletteColors: [
                .systemBlue,
                .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "thermometer.snowflake")
        case 1087,1273,1276,1279: let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "bolt.horizontal")
        case 1030,1135,1147: let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "cloud.fog.fill")
        case 1117,1150,1153,1168,1171: let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "wind")

        default:let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue,
            .white])
                weatherIconView.preferredSymbolConfiguration=config
                weatherIconView.image=UIImage(systemName:  "exclamationmark.icloud.fill")

        }

    }

    

}
extension locationScreenViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        search = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        manager.stopUpdatingLocation()
        loadWeather()
    }

}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}
