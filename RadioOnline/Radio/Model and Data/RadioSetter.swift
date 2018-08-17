import Foundation
import AVFoundation
import MediaPlayer




class RadioSetter{
    
    var radioPlayer: RadioPlayer?
    weak var radioPlayerViewController: RadioPlayerViewController?
    
    func setupRadio(){
        // Create Audio Session
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("audioSession could not be activated")
        }
        radioPlayer = RadioPlayer()
        radioPlayer?.delegate = self
        setupRemoteCommandCenter()
    }
    
    func set(radioStation: RadioStation?) {
        radioPlayer?.station = radioStation
    }
    
    func resetCurrentStation(){
        radioPlayer?.resetRadioPlayer()
        
    }
    //*****************************************************************
    // MARK: - Remote Command Center Controls
    //*****************************************************************
    func setupRemoteCommandCenter() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Next Command
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        // Add handler for Previous Command
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
        }
    }
    // End of Class
}

//*****************************************************************
// MARK: - NowPlayingViewControllerDelegate
//*****************************************************************

extension RadioSetter: RadioPlayerDelegate {
    
    func playerStateDidChange(_ playerState: FRadioPlayerState) {
        radioPlayerViewController?.playerStateDidChange(playerState)
    }
    
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState) {
        radioPlayerViewController?.playbackStateDidChange(playbackState)
    }
    
    func trackDidUpdate(_ track: Track?) {
        radioPlayerViewController?.updateTrackMetadata(with: track)
    }
    
    func trackArtworkDidUpdate(_ track: Track?) {
        radioPlayerViewController?.updateTrackArtwork(with: track)
    }
}



