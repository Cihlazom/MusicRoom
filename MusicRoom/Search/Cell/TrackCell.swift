//
//  TrackCell.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? {get}
    var trackName: String {get}
    var artistName: String {get}
    var collectionName: String {get}
}

class TrackCell: UITableViewCell {
    
    static let identifier = "TrackCell"
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addTrackButton: UIButton!
    
    var cell: SearchViewModel.Cell?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        self.cell = viewModel

        let savedTracks = UserDefaults.standard.savedTracks()
        let hasFavourite = savedTracks.firstIndex {
            $0.trackName == self.cell?.trackName && $0.artistName == self.cell?.artistName
        } != nil
        if hasFavourite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        guard let url = URL(string: viewModel.iconUrlString ?? "") else {
            return
        }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func addtrackAction(_ sender: Any) {
        guard let cell = cell else { return }
        let defaults = UserDefaults.standard
        var listOfTracks = defaults.savedTracks()
        
        listOfTracks.append(cell)
        if let saveDta = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            defaults.set(saveDta, forKey: UserDefaults.favouriteTrackKey)
            
        }
        addTrackButton.isHidden = true
    }
}
