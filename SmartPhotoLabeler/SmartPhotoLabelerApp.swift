//
//  SmartPhotoLabelerApp.swift
//  SmartPhotoLabeler
//
//  Created by Nasir Uddin on 22/4/25.
//

import SwiftUI

@main
struct SmartPhotoLabelerApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                ImageClassifierView()
            } else {
                Text("iOS 17 or higher required.")
            }
        }
    }
}
