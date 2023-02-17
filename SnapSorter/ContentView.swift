//
//  ContentView.swift
//  SnapSorter
//
//  Created by Apdev on 2023-02-16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
          SnapGalleryView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
