//
//  ContentView.swift
//  Wheelie Sensoor Data collector
//
//  Created by Kwaw Annan on 2/22/24.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @ObservedObject var motionManager = MotionManager()
    @State private var showingDataView = false  // State variable for controlling navigation
    
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 20) {
                Text("Accelerometer Data")
                Text("X: \(motionManager.latestAccelData.x)")
                Text("Y: \(motionManager.latestAccelData.y)")
                Text("Z: \(motionManager.latestAccelData.z)")
                Text("Activity: \(motionManager.activityLabel)")
                
                Button(action: {
                    if motionManager.isCollectingData {
                        motionManager.stopCollecting()
                    } else {
                        motionManager.startCollecting()
                    }
                }) {
                    Text(motionManager.isCollectingData ? "Stop Collecting" : "Start Collecting")
                }
                
                Button("Toggle Activity") {
                    motionManager.updateActivityLabel(to: motionManager.activityLabel == "Not Wheeling" ? "Wheeling" : "Not Wheeling")
                }
                
                Button("Clear Data") {
                    motionManager.clearData()
                }
                
                Button("Show Data") {
                    let data = motionManager.readDataFromFile()
                    self.showingDataView = true  // Trigger navigation
                    
                    print(data)
                }
            }
            // Use .sheet to present DataView when showingDataView is true
            .sheet(isPresented: $showingDataView) {
                // Pass the data to DataView
                DataView(data: motionManager.readDataFromFile())
            }
            
        }
    }
}



struct DataView: View {
    var data: String
    
    var body: some View {
        ScrollView {
            Text(data)
                .padding()
        }
        .navigationBarTitle("Data", displayMode: .inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}

#Preview {
    ContentView()
}
