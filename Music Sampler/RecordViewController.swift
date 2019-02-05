import UIKit
import AVFoundation
import Foundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordButtonRef: UIButton!
    @IBOutlet weak var playButtonRef: UIButton!
    
    //MARK: Sound level components
    
    @IBOutlet var soundLevelLabels: [UIView]!

    public var recordingName: String!
    
    var recorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer: Timer!
    var isRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkRecordPermission()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isRecordingGranted = true
                    } else {
                        self.isRecordingGranted = false
                    }
                }
            }
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = recordingName + ".m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        print(filename)
        return filePath
    }
    
    func setupRecorder() {
        if isRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                recorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true
                recorder.prepareToRecord()
                
            } catch let error {
                print("Failed to setup: " + error.localizedDescription)
            }
        } else {
            print("No access to use the microphone")
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if recorder.isRecording {
            let hr = Int((recorder.currentTime / 60) / 60)
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            
            let avrPower = recorder.averagePower(forChannel: 1)
            let normalizedPower = pow(avrPower + 160, 2) / 1280
            
            updateAudioLevel(level: Int(normalizedPower))
            recorder.updateMeters()
        }
    }
    
    func updateAudioLevel(level: Int) {
        for i in 0...soundLevelLabels.count-1 {
            if round(Double(level)) > Double(i) {
                soundLevelLabels[i].backgroundColor = soundLevelLabels[i].backgroundColor?.withAlphaComponent(1)
            } else {
                soundLevelLabels[i].backgroundColor = soundLevelLabels[i].backgroundColor?.withAlphaComponent(0.2)
            }
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            recorder.stop()
            recorder = nil
            timer.invalidate()
            print("Recorded successfully.")
        } else {
            print("Recording failed.")
        }
        updateAudioLevel(level: 0)
    }
    
    func prepareToPlay() {
        do {
            audioPlayer = try AVAudioPlayer.init(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("Error, could not play")
        }
    }
    
    // MARK: GUI Actions
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if isRecording {
            finishAudioRecording(success: true)
            recordButtonRef.setTitle("Record", for: .normal)
            playButtonRef.isEnabled = true
        } else {
            setupRecorder()
            recorder.record()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioMeter), userInfo: nil, repeats: true)
            recordButtonRef.setTitle("Recording", for: .normal)
            playButtonRef.isEnabled = false
        }
        
        isRecording = !isRecording
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if isPlaying {
            audioPlayer.stop()
            recordButtonRef.isEnabled = true
            playButtonRef.setTitle("Play", for: .normal)
            isPlaying = false
        } else {
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                recordButtonRef.isEnabled = false
                playButtonRef.setTitle("Pause", for: .normal)
                prepareToPlay()
                audioPlayer.play()
                
                isPlaying = true
            } else {
                print("Error, could not find audio file")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButtonRef.isEnabled = true
        playButtonRef.setTitle("Play", for: .normal)
        isPlaying = false
    }
}
