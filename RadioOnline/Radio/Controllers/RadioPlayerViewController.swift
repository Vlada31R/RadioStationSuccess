import UIKit
import MediaPlayer
import AVFoundation
import ChameleonFramework

var savedTrackArray = [Track]()

protocol RadioPlayerViewControllerDelegate: class {
    func didPressPlayingButton()
    func didPressStopButton()
    func didPressNextButton()
    func didPressPreviousButton()
}

class RadioPlayerViewController: UIViewController {
    
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    
    var newStation: Bool = true
    var mpVolumeSlider: UISlider?
    var playingStation: RadioStation!
    var playingTrack: Track!
    
    //Init radio player
    let radioPlayer = FRadioPlayer.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting background image
        //self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "back"))
        
        // Setuping Volume Slider
        setupVolumeSlider()
        
        // Setuping Command Center
        //setupRemoteCommandCenter()
        
        newStation ? stationDidChanged() : playerStateDidChange(radioPlayer.state)
        DataManager.changeColor(view: self.view)
        stationName.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        artistLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        songLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Show and Hide NavBar
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //*****************************************************************
    // MARK: - Setup Slider
    //*****************************************************************
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        for subview in MPVolumeView().subviews {
            guard let volumeSlider = subview as? UISlider else { continue }
            mpVolumeSlider = volumeSlider
        }
        
        guard let mpVolumeSlider = mpVolumeSlider else { return }
        
        volumeParentView.addSubview(mpVolumeSlider)
        
        mpVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeSlider.leftAnchor.constraint(equalTo: volumeParentView.leftAnchor).isActive = true
        mpVolumeSlider.rightAnchor.constraint(equalTo: volumeParentView.rightAnchor).isActive = true
        mpVolumeSlider.centerYAnchor.constraint(equalTo: volumeParentView.centerYAnchor).isActive = true
        
        mpVolumeSlider.setThumbImage(#imageLiteral(resourceName: "slider-ball"), for: .normal)
    }
    //*****************************************************************
    // MARK: - Load Initial Information
    //*****************************************************************
    
    // Load radio information
    func loadRadio(station: RadioStation?, track: Track?, isNew: Bool = true){
        playingStation = station
        playingTrack = track
        newStation = isNew
    }
    
    //*****************************************************************
    // MARK: - Updating Labels and Metadata
    //*****************************************************************
    
    func playerStateDidChange(_ playerState: FRadioPlayerState){
        
        var message = String()
        
        switch playerState {
        case .loading:
            message = "Loading..."
        case .loadingFinished, .readyToPlay:
            playbackStateDidChange(radioPlayer.playbackState)
        case .urlNotSet:
            message = "Station URL not valide"
        case .error:
            songLabel.text = "Error"
        }
        updateLabels(with: message, animate: true)
    }
    
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState){
        
        let message: String?
        
        switch playbackState {
        case .paused:
            message = "Station Paused..."
        case .playing:
            message = nil
        case .stopped:
            message = "Station Stopped..."
        }
        
        updateLabels(with: message, animate: true)
    }

    // Update Labels
    func updateLabels(with message: String? = nil, animate: Bool = true){
        guard let message = message else {
            songLabel.text = playingTrack?.title
            artistLabel.text = playingTrack?.artist
            stationName.text = playingStation?.name
            
            return
        }
        guard songLabel.text != message else { return }
        
        songLabel.text = message
        artistLabel.text = playingStation?.name
    }
    
    // Update Track Metadata
    func updateTrackMetadata(with track: Track?) {
        guard let track = track else { return }
        
        playingTrack = track
        
        updateLabels()
    }
    
    // Update track with new artwork
    func updateTrackArtwork(with track: Track?) {
        guard let track = track else { return }
        
        // Update track struct
        playingTrack.artworkImage = track.artworkImage
        playingTrack.artworkLoaded = track.artworkLoaded
        
        albumImage.image = playingTrack.artworkImage
        
        // Force app to update display
        view.setNeedsDisplay()
    }
    
    //*****************************************************************
    // MARK: - Radio Station Changed
    //*****************************************************************
    
    // Radio Station Did Changed
    func stationDidChanged(){
        radioPlayer.radioURL = URL(string: playingStation.streamURL)
        title = playingStation.name
    }
    func saveTrack(track: Track?){
        savedTrackArray.append(track!)
    }
    
    
    //*****************************************************************
    // MARK: - Button Actions
    //*****************************************************************
    
    // Play Button
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        switch radioPlayer.playbackState {
        case .paused, .stopped :
            sender.setImage(#imageLiteral(resourceName: "pauseImageButton"), for: .normal)
        case .playing :
            sender.setImage(#imageLiteral(resourceName: "playImageButton"), for: .normal)
            
        }
        
        radioPlayer.togglePlaying()
    }
    
    // Stop Button
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        radioPlayer.stop()
    }
    
    // Save Button
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveTrack(track: playingTrack)
        print(savedTrackArray)
    }
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // End Of Class
}

extension UIViewController{
    
    func addMusicView(parentView: UIView) -> UIView{
        let rect = CGRect(x: 0, y: parentView.frame.maxY * 0.8, width: parentView.frame.maxX, height: parentView.frame.maxY * 0.2)
        let newView = UIView(frame: rect)
        newView.backgroundColor = UIColor.gray
 
        return newView
    }
}
