//
//  ViewController.swift
//  lab03
//
//  Created by Sooraj Suresh Krishnan on 2023-03-18.
//

import UIKit
import CoreLocation//lc

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    
    @IBOutlet weak var temparatureUnit: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        displaySymbolImage()
        searchTextField.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

       
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.endEditing(true)
        print(textField.text ?? "")
        return true
    }
    
    private func displaySymbolImage()
    {
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .systemBlue, .systemCyan])
        
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: "cloud.sun.rain")
    }
        
        
        private func onLocationTapped(_ sender: UIButton)
        {
            locationManager.startUpdatingLocation()
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
           guard let currentLocation = locations.last else { return }
           print(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
           // Use currentLocation to fetch weather data from a weather API
       }
    
    
    
        
         @IBAction func unitSwitch(_ sender: UISwitch)
         {
             
             if sender.isOn {
                    // Convert temperature from Celsius to Fahrenheit
                    let celsiusTemperature = 25.0 // Replace with your actual temperature value
                    let fahrenheitTemperature = (celsiusTemperature * 9/5) + 32
                    print("Temperature in Fahrenheit: \(fahrenheitTemperature)")
                } else {
                    // Convert temperature from Fahrenheit to Celsius
                    let fahrenheitTemperature = 77.0 // Replace with your actual temperature value
                    let celsiusTemperature = (fahrenheitTemperature - 32) * 5/9
                    print("Temperature in Celsius: \(celsiusTemperature)")
                }
             
             
             
             
         }
        @IBAction func onSearchTapped(_ sender: UIButton)
        {
            loadWeather(search: searchTextField.text)
            
        }
       private func loadWeather(search: String?)
        {
            guard let search = search else {
                return
            }
            guard  let url = getURL(query: search) else {
                print("could not get url")
                return
            }
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: url) { data, response, error in
                print("Network call completed")
                
                
                guard  error == nil else{
                    print("error received")
                    return
                }
                
                guard let data = data else {
                    print("no data found")
                    return
                }
                
                if  let weatherResponse = self.parseJson(data: data)
                {
                    print(weatherResponse.location.name)
                    print(weatherResponse.current.temp_c)
                    
                    DispatchQueue.main.async {
                        
                        self.locationLabel.text = weatherResponse.location.name
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)"
                        
                    }
                    
                    
                }
                
            }
            
            dataTask.resume()
            
            
        }
        private func getURL(query: String) -> URL?
        {
            //
            let baseUrl = "https://api.weatherapi.com/v1/"
            let currentEndpoint = "current.json"
            let apiKey = "16b91d03db974920ba9202418232003"
            // let query = "q=Toronto"
            
            guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            print(url)
            
            return URL(string: url)
        }
        
     private func parseJson(data: Data) -> WeatherResponse?{
            let decorder = JSONDecoder()
            var weather: WeatherResponse?
            do {
                weather = try decorder.decode(WeatherResponse.self, from: data)
            }catch {
                print("error decording")
            }
            return weather
            
        }
        
        
    }
    
    struct WeatherResponse: Decodable {
        let location: Location
        let current: weather
    }
    
    struct Location: Decodable {
        let name: String
    }
    struct weather: Decodable{
        let temp_c: Float
        let condition: WeatherCondition
    }
    
    struct WeatherCondition: Decodable {
        let text: String
        let code: Int
    }
    

