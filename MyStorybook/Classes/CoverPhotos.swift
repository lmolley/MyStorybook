//
//  CoverPhotos.swift
//  MyStorybook
//
//  Created by Quesada, David on 2/23/16.
//  Copyright © 2016 The My Storybook Team. All rights reserved.
//

import Foundation
import UIKit

internal let AvailableCoverPhotos = [
"pizza",
"soccerball",
"ic_cake_black_48dp",
"ic_domain_black_48dp",
"ic_group_black_48dp",
"ic_location_city_black_48dp",
"ic_mood_bad_black_48dp",
"ic_mood_black_48dp",
"ic_school_black_48dp",
"ic_sentiment_very_satisfied_black_48dp",
"ic_whatshot_black_48dp"
]


internal func randomCoverPhotoId() -> String
{
    return AvailableCoverPhotos[Int(arc4random()) % AvailableCoverPhotos.count]
}

internal func coverPhotoImageOrDefault(code: String) -> UIImage
{
    return UIImage(named: "CoverPhotos/\(code)") ?? UIImage(named: "file-folder-md")!
}