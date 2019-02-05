import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {
    
    var samples: [AVAudioPlayer] = []
    var audioPlayer: AVAudioPlayer!
    var editMode: Bool = false
    var selectedButton: Int = 1
    
    let noSoundFilePath: String! = "noSound"
    
    @IBOutlet weak var editButtonRef: UIBarButtonItem!
    @IBOutlet var soundButtons: [UIButton]!
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in soundButtons {
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
        }
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
    
    @IBAction func soundButtonPressed(_ sender: UIButton) {
        var buttonTitleComponents = sender.titleLabel!.text!.components(separatedBy: " ")
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
        
        animate(button: sender)
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
        button.alpha = 0.8
        UIView.transition(with: button, duration: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
            button.alpha = 1.0
        }) { (completed) in
            button.alpha = 1.0
        }
    }
    
    func playSample(index: Int) {
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
                addNoSample(index: index)
            }
        } else {
            addNoSample(index: index)
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
    
    func addAudioPlayer(player: AVAudioPlayer, index: Int) {
        samples.insert(player, at: index)
    }
}

