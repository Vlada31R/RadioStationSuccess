import UIKit
import MediaPlayer
import AVFoundation
import ChameleonFramework
import Social

var savedTrackArray = [Track]()

protocol RadioPlayerViewControllerDelegate: class {
    func didPressPlayingButton()
    func didPressStopButton()
    func didPressNextButton()
    func didPressPreviousButton()
}

class RadioPlayerViewController: UIViewController {

    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!

    //var newStation: Bool = true
    var mpVolumeSlider: UISlider?
    var playingStation: RadioStation?
    var playingTrack: Track?

    //Init radio player
    let radioPlayer = FRadioPlayer.shared

    @IBAction func facebookBtn(_ sender: Any) {
        let fbShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbShare.add(albumImage.image)
        //fbShare.add(textToImage(drawText: songLabel.text as! NSString, inImage: albumImage.image!, atPoint: CGPointMake(0, albumImage.frame.height)))
        //fbShare.setInitialText("#\(playingStation.streamURL)")
        self.present(fbShare, animated: true, completion: nil)
    }
    @IBAction func twitterBtn(_ sender: Any) {
        let tweetShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetShare.add(albumImage.image)
        self.present(tweetShare, animated: true, completion: nil)
    }

//    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
//
//
//        // Setup the font specific variables
//        var textColor = UIColor.red
//        var textFont = UIFont(name: "Helvetica Bold", size: 20)!
//
//        // Setup the image context using the passed image
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
//
//        // Setup the font attributes that will be later used to dictate how the text should be drawn
//        let textFontAttributes = [
//            NSAttributedStringKey.font: textFont,
//            NSAttributedStringKey.foregroundColor: textColor
//        ]
//
//        // Put the image into a rectangle as large as the original image
//        inImage.draw(in: CGRectMake(0, 0, inImage.size.width, inImage.size.height))
//
//        // Create a point within the space that is as bit as the image
//        var rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
//
//        // Draw the text into an image
//        drawText.draw(in: rect, withAttributes: textFontAttributes)
//
//        // Create a new image out of the images we have created
//        var newImage = UIGraphicsGetImageFromCurrentImageContext()
//
//        // End the context now that we have the image we need
//        UIGraphicsEndImageContext()
//
//        //Pass the image back up to the caller
//        return newImage!
//
//    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    func CGPointMake(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting background image
        //self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "back"))

        // Setuping Volume Slider
        setupVolumeSlider()

        // Setuping Command Center
        //setupRemoteCommandCenter()
        playerStateDidChange(radioPlayer.state)
        playbackStateDidChange(radioPlayer.playbackState)
        updateTrackMetadata(with: playingTrack)
        updateTrackArtwork(with: playingTrack)
        //newStation ? stationDidChanged() : playerStateDidChange(radioPlayer.state)
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

    func loadRadio(station: RadioStation?, track: Track?) {

        playingStation = station
        playingTrack = track
    }

    //*****************************************************************
    // MARK: - Updating Labels and Metadata
    //*****************************************************************

    func playerStateDidChange(_ playerState: FRadioPlayerState) {

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

    func playbackStateDidChange(_ playbackState: FRadioPlaybackState) {

        let message: String?

        switch playbackState {
        case .paused:
            toggleButton.setImage(#imageLiteral(resourceName: "playImageButton"), for: .normal)
            message = "Station Paused..."
        case .playing:
            toggleButton.setImage(#imageLiteral(resourceName: "pauseImageButton"), for: .normal)
            message = nil
        case .stopped:
            toggleButton.setImage(#imageLiteral(resourceName: "playImageButton"), for: .normal)
            message = "Station Stopped..."
        }

        updateLabels(with: message, animate: true)
    }

    // Update Labels
    func updateLabels(with message: String? = nil, animate: Bool = true) {
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
        playingTrack?.artworkImage = track.artworkImage
        playingTrack?.artworkLoaded = track.artworkLoaded

        albumImage.image = playingTrack?.artworkImage

        // Force app to update display
        view.setNeedsDisplay()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveSong", let songVC = segue.destination as? SaveSongViewController {
            songVC.songArray.append(Song(s: (playingTrack?.title)!, a: (playingTrack?.artist)!))
        }
    }
    //*****************************************************************
    // MARK: - Radio Station Changed
    //*****************************************************************

    // Radio Station Did Changed
    func stationDidChanged() {
        radioPlayer.radioURL = URL(string: (playingStation?.streamURL)!)
        title = playingStation?.name
    }
    func saveTrack(track: Track?) {
        savedTrackArray.append(track!)
    }

    //*****************************************************************
    // MARK: - Button Actions
    //*****************************************************************

    // Play Button
    @IBAction func playButtonPressed(_ sender: UIButton) {
        radioPlayer.togglePlaying()
    }

    // Stop Button
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        radioPlayer.stop()
    }

    // Save Button
    @IBAction func saveButtonPressed(_ sender: UIButton) {
       performSegue(withIdentifier: "saveSong", sender: self)
    }
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // End Of Class
}
