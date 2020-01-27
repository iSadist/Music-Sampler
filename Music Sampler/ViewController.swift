import UIKit
import AVFoundation
import Foundation
import GoogleMobileAds

class ViewController: UIViewController {
    var samples: [AVAudioPlayer] = []
    var audioPlayer: AVAudioPlayer!
    var editMode: Bool = false {
        didSet {
            if editMode {
                self.navigationItem.title = "Tap the button to change"
            } else {
                self.navigationItem.title = "Soundboard"
            }
        }
    }
    var selectedButton: Int = 1
    
    let noSoundFilePath: String! = "noSound"
    
    @IBOutlet weak var editButtonRef: UIBarButtonItem!
    @IBOutlet weak var bannerView: DFPBannerView!
    @IBOutlet var soundButtons: [UIButton]!
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Soundboard"
        for button in soundButtons {
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
        }

        bannerView.adUnitID = "ca-app-pub-7231554980858919/4762101194"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(DFPRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPlayers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination

        if segue.identifier == "recorderSegue" && destinationViewController is RecordViewController {
            // Will this ever work? Yes!
            let rvc = destinationViewController as! RecordViewController
            rvc.recordingName = "Sound" + String(selectedButton)
        }
    }

    // MARK: IBActions
    
    @IBAction func buttonPressedDown(_ sender: UIButton) {
        let buttonTitleComponents = sender.titleLabel!.text!.components(separatedBy: " ")
        let buttonNumber = Int(buttonTitleComponents[1])!;
        
        if editMode {
            selectedButton = buttonNumber
            editMode = false
            editButtonRef.title = "Edit"
            stopAllPlayers()
            performSegue(withIdentifier: "recorderSegue", sender: self)
            
        } else {
            playSample(index: buttonNumber - 1)
        }
        
        sender.fadeAnimation()
        sender.pressDownAnimation()
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        editMode = !editMode
        var title: String?
        
        if editMode {
            title = "Done"
            } else {
            title = "Edit"
        }
        
        sender.title = title!
    }
    
    
    // MARK: Class functions
    
    private func animate(button: UIButton) {
        button.alpha = 0.75
        UIView.transition(with: button, duration: 0.05, options: UIViewAnimationOptions.curveLinear, animations: {
            button.alpha = 1.0
        }) { (completed) in
            button.alpha = 1.0
        }
    }
    
    func playSample(index: Int) {
//        guard index >= 0 && index < samples.count else { return }
        let sample = samples[index]

        if sample == nil {
            return
        }
        sample.currentTime = 0
        sample.prepareToPlay()
        sample.play()
    }
    
    func stopAllPlayers() {
        for player in samples {
            player.stop()
        }
    }
    
    func setupPlayers() {
        for i in 1...12 {
            addSample(filepath: "Sound" + String(i), index: i-1)
        }
    }
    
    func addSample(filepath: String, index: Int) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fullPath = documentsDirectory.appendingPathComponent(filepath + ".m4a")
        
        if fullPath.isFileURL {
            do {
                let player = try AVAudioPlayer.init(contentsOf: fullPath)
                addAudioPlayer(player: player, index: index)
            } catch {
                addDefaultSample(index: index)
            }
        } else {
            addDefaultSample(index: index)
        }
    }
    
    func addNoSample(index: Int) {
        if let path = Bundle.main.path(forResource: noSoundFilePath, ofType: "m4a") {
            let url = NSURL.fileURL(withPath: path)
            do {
                let player = try AVAudioPlayer.init(contentsOf: url)
                addAudioPlayer(player: player, index: index)
            } catch {
                print("Error occurred")
            }
        } else {
            print("Could not add audio")
        }
    }
    
    func addDefaultSample(index: Int) {
        print("Sound\(index)")
        if let path = Bundle.main.path(forResource: "Sound\(index)", ofType: "m4a") {
            let url = NSURL.fileURL(withPath: path)
            do {
                let player = try AVAudioPlayer.init(contentsOf: url)
                addAudioPlayer(player: player, index: index)
            } catch {
                print("Error occurred")
            }
        } else {
            print("Could not add audio")
        }
    }
    
    func addAudioPlayer(player: AVAudioPlayer, index: Int) {
        samples.insert(player, at: index)
    }
}

extension ViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription). Reason: \(String(describing: error.localizedFailureReason)). Recovery suggestion: \(String(describing: error.localizedRecoverySuggestion))")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
