import UIKit
import AVFoundation

class ViewController: UIViewController {
    var audioPlayers = [AVAudioPlayerNode]()
    
    var engine = AVAudioEngine()
    
    var player = AVAudioPlayerNode()
    var constructedArrayOfNotes: [String] = ["bell_multiple", "buzzer_x", "Beep", "flatline"]
    var audioFiles = [AVAudioFile]()
    var avAudioPlayerTimePitch: AVAudioUnitTimePitch!    
    
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    var currentPlayer = 0
    let step: Float = 1.0
    
    @IBAction func stopAudioPlayer(_ sender: UIButton) {
        if (audioPlayers[sender.tag].isPlaying) {
            audioPlayers[sender.tag].pause()
        }
    }
    
    func stopAllPlayers()  {
        for player in audioPlayers {
            if(player.isPlaying){
                player.pause()
            }
        }
    }

    @IBAction func key(_ sender: UIButton) {
        stopAllPlayers()
        
        currentPlayer = sender.tag
        
        let player = audioPlayers[sender.tag]
        let audioFile = audioFiles[sender.tag]
        
        if (sender.tag == 0 || sender.tag == 1) {
            player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        } else if(sender.tag == 2){
            
            avAudioPlayerTimePitch.rate = 1.0
            avAudioPlayerTimePitch.pitch = -2400
            
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try? audioFile.read(into: buffer!)
            player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            
        } else if (sender.tag == 3){
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try? audioFile.read(into: buffer!)
            player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        }
        
        player.play()
    }
    
    @IBAction func rateSlider(_ sender: UISlider) {
        audioPlayers[currentPlayer].pause()
        
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        setLabels()
        avAudioPlayerTimePitch.pitch = pitchSlider.value
        avAudioPlayerTimePitch.rate = rateSlider.value
        audioPlayers[currentPlayer].volume = volumeSlider.value
        
        audioPlayers[currentPlayer].play()
    }
    
    @IBAction func pitchSlider(_ sender: UISlider) {
        
        audioPlayers[currentPlayer].pause()
        
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        setLabels()
        avAudioPlayerTimePitch.pitch = pitchSlider.value
        avAudioPlayerTimePitch.rate = rateSlider.value
        audioPlayers[currentPlayer].volume = volumeSlider.value
        
        audioPlayers[currentPlayer].play()
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        audioPlayers[currentPlayer].pause()
        
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        setLabels()
        
        audioPlayers[currentPlayer].volume = volumeSlider.value
        
        audioPlayers[currentPlayer].play()
    }
    
  
    func setLabels()  {
        pitchLabel.text =  String( pitchSlider.value)
        rateLabel.text = String( rateSlider.value)
        volumeLabel.text = String( volumeSlider.value)
    }
    func createPlayers() {
        
        for key in constructedArrayOfNotes {
            
            player = AVAudioPlayerNode()
            
            // Can't believe on documentation
            player.volume = 10.0
            
            /*
             let reverb = AVAudioUnitReverb()
             // We can change Preset
             reverb.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
             
             //We can change 0 - 100
             reverb.wetDryMix = 100
             */
            
            
            
            let audiopath = Bundle.main.path(forResource: key, ofType: "wav")!
            
            let url = NSURL.fileURL(withPath: audiopath)
            
            do {
                let file = try! AVAudioFile.init(forReading: url)
                
                engine.attach(player)
                
                if(key == "bell_multiple" || key == "buzzer_x"){
                    
                    engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
                    player.scheduleFile(file, at: nil, completionHandler: nil)
                } else if (key == "flatline"){
                    
                    let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                    try file.read(into: buffer!)
                    
                    engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
                    
                    player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
                } else if (key == "Beep"){
                    avAudioPlayerTimePitch.rate = 1.0
                    avAudioPlayerTimePitch.pitch = -2400
                    
                    let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                    try file.read(into: buffer!)
                    
                    //engine.attach(reverb)
                    //engine.connect(player, to: reverb, format: file.processingFormat)
                    //engine.connect(reverb, to: engine.mainMixerNode, format: file.processingFormat)
                    
                    engine.attach(avAudioPlayerTimePitch)
                    engine.connect(player, to: avAudioPlayerTimePitch, format: file.processingFormat)
                    engine.connect(avAudioPlayerTimePitch, to: engine.mainMixerNode, format: file.processingFormat)
                    
                    player.scheduleBuffer(buffer!, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
                }
                
                audioPlayers.append(player)
                
            } catch {
                print("error")
            }
        }
    }
    
    func createAudioFiles() {
        for key in constructedArrayOfNotes {
            let audiopath = Bundle.main.path(forResource: key, ofType: "wav")!
            
            let url = NSURL.fileURL(withPath: audiopath)
            let file = try! AVAudioFile.init(forReading: url)
            audioFiles.append(file)
        }
    }
    override func viewDidLoad() {
        
        avAudioPlayerTimePitch = AVAudioUnitTimePitch()
        setLabels()
        createAudioFiles()
        
        createPlayers()
        engine.prepare()
        try! engine.start()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}
