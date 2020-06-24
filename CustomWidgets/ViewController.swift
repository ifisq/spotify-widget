//
//  ViewController.swift
//  CustomWidgets
//
//  Created by Aryan Nambiar on 6/24/20.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    let SpotifyClientID = "21ec911ab7df44a19f570f851bfc9104"
    let SpotifyRedirectURL = URL(string: "CustomWidgets://spotify-login-callback")!
    
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        if let tokenSwapURL = URL(string: "https://google.com"), let tokenRefreshURL = URL(string: "https://google.com") {
            self.configuration.tokenSwapURL = tokenSwapURL
            self.configuration.tokenRefreshURL = tokenRefreshURL
            self.configuration.playURI = ""
        }
        return manager
    }()
    
    var refreshTimer: Timer? = nil
    
    func startTimer() {
        
        if(refreshTimer == nil) {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800.0, repeats: true) {timer in
                let defaults = UserDefaults(suiteName: "group.dev.nambiar.CustomWidgets.app")!
                let refresh_token = defaults.string(forKey: "refreshToken")!
                
                let url = URL(string: "https://be77771c97c8.ngrok.io/refresh?refresh_token=\(refresh_token)")!
                let refreshReq = URLRequest(url: url)
                
                let session = URLSession.shared
                
                let refreshReqTask = session.dataTask(with: refreshReq) {data, response, error in
                    if (data != nil) {
                        do {
                            // make sure this JSON is in the format we expect
                            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                
                                print("REFRESHED!")
                                print(json)
                                
                                defaults.set(json["access_token"] as! String, forKey: "accessToken")
                                defaults.set(Date().addingTimeInterval(3600), forKey: "expirationTime")
                            }
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                    }
                    
                    if(response != nil) {
                    }
                }
                refreshReqTask.resume()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Loaded")
        
        startTimer()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        var spotifyInstalled: Bool = false
        if let appURL = URL(string: "spotify://test/url/") {
            let canOpen = UIApplication.shared.canOpenURL(appURL)
            spotifyInstalled = canOpen
        }
        
        if spotifyInstalled {
            let scope: SPTScope = [.userTopRead, .playlistModifyPublic, .userReadPlaybackState]
            self.sessionManager.initiateSession(with: scope, options: .default)
        }
        
        else {
            
            func installSpotify(action: UIAlertAction) {
                let url = URL(string: "https://apps.apple.com/us/app/spotify-music-and-podcasts/id324684580")!
                UIApplication.shared.open(url)
            }
            
            let alert = UIAlertController(title: "You must have Spotify installed to use this app.", message:"Please install Spotify before trying to use this app!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Install from App Store", style: .default, handler: installSpotify))
          
        }
    }
    
    func setAccessToken(accessToken: String?) {
        if (accessToken != nil) {
                    
                    let session = URLSession.shared
                    let url = URL(string: "https://be77771c97c8.ngrok.io/authorize?auth_code=" + accessToken!)!
                    
                    
                    let task = session.dataTask(with: url) { data, response, error in
                        if(data != nil) {
                            
                            do {

                                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                    
                                    let defaults = UserDefaults.init(suiteName: "group.dev.nambiar.CustomWidgets.app")!
                                    defaults.set(json["access_token"] as! String, forKey: "accessToken")
                                    defaults.set(json["refresh_token"] as! String, forKey: "refreshToken")
                                    defaults.set(Date().addingTimeInterval(3600), forKey: "expirationTime")
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        
                                        let vc = UIApplication.shared.keyWindow?.rootViewController
                                        
                                        let alert = UIAlertController(title: "You have successfully logged into Spotify,", message: "", preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                        
                                        vc!.present(alert, animated: true)
                                    }

                                }
                            } catch let error as NSError {
                                print("Failed to load: \(error.localizedDescription)")
                            }
                            
                        }
                        
                        if(response != nil) {
//                              print(response!)
                        }
                        
                        if(error != nil) {
                            print(error!)
                        }
                    }
                    task.resume()
                }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ViewController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print(session.accessToken)
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("failed",error)
    }
}
