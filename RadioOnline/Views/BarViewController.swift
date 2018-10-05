//
//  BarViewController.swift
//  RadioOnline
//
//  Created by student on 8/22/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

protocol BarViewControllerDelegate {
    func didTapped(sender: UITapGestureRecognizer)
    func didPressPlayingButton()
    func didPressStopButton()
    func didPressNextButton()
    func didPressPreviousButton()
}

class BarViewController: UIViewController {

    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    //Init radio player
    let radioPlayer = FRadioPlayer.shared
    var newStation: Bool = true
    var delegate: BarViewControllerDelegate?
    var playingStation: RadioStation?
    var playingTrack: Track?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapG = UITapGestureRecognizer(target: self, action: #selector(didTapped))
        self.view.addGestureRecognizer(tapG)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Load radio information
    func loadRadio(station: RadioStation?, track: Track?, isNew: Bool = true) {
        if !isNew {
             delegate?.didPressPlayingButton()
            return
        }
        playingStation = station
        playingTrack = track
//        newStation = isNew
        isNew ? stationDidChanged() : playerStateDidChange(radioPlayer.state)
    }

    // Radio Station Did Changed
    func stationDidChanged() {
        radioPlayer.radioURL = URL(string: (playingStation?.streamURL)!)
        title = playingStation?.name
    }

    @objc func didTapped( sender: UITapGestureRecognizer) {
        self.delegate?.didTapped(sender: sender)
    }

    override func loadView() {
        Bundle.main.loadNibNamed("BarViewController", owner: self, options: nil)
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

    // MARK: - Navigation
     @IBAction func togglePressed(_ sender: UIButton) {

        delegate?.didPressPlayingButton()

     }
    @IBAction func stopPressed(_ sender: UIButton) {
        delegate?.didPressStopButton()
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation

}
