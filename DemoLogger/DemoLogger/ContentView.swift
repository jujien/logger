//
//  ContentView.swift
//  DemoLogger
//
//  Created by Kiên Vũ on 7/11/24.
//

import SwiftUI
import Logger

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Log.debug(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString)
            Log.tag("Test").debug("Hello, world!")
            Log.tag("ABC").warning("Warning")
            Log.tag("Hihi").info("Info")
            Log.tag("abc").trace("Trace")
            Log.tag("def").error("Error")
            Log.tag("affe").fault("Error!!!")
            
        }
        
    }
}

#Preview {
    ContentView()
}
