//
//  VenueCell.swift
//  VenuesNearby
//
//  Created by Chaise Hocking on 27/7/17.
//  Copyright © 2017 Chaise. All rights reserved.
//

import UIKit
import AFNetworking

/**
 * VenueCell is a UITableViewCell the displays details of a Venue.
 * It has name, address, hourse and an image.
 * it doesn't have the responsibility of assigning the data onto it's labels,
 * however it does clear the data upon each reuse.
 */
class VenueCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var hours: UILabel!
    @IBOutlet var photoView: UIImageView!
    
    /**
     * Clears the default values put in by the Nib
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearCellContents()
    }
    
    /**
     * Clears the default values left over by previous venue
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clearCellContents()
    }
    
    /**
     * Resets all the labels and the image in the cell.
     */
    private func clearCellContents() {
        self.name.text = "Unnamed"
        self.address.text = nil
        self.hours.text = nil
        self.photoView.cancelImageDownloadTask()
        self.photoView.image = nil
    }
}
