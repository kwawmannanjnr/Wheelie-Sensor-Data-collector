//
//  MotionManager.swift
//  Wheelie Sensoor Data collector
//
//  Created by Kwaw Annan on 2/22/24.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private(set) var dataFileURL: URL?
    
    @Published var isCollectingData: Bool = false
    @Published var latestAccelData: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    @Published var activityLabel: String = "Not Wheeling"
    
    init() {
        setupDataFile()
    }
    
    func startCollecting() {
        guard motionManager.isAccelerometerAvailable else { return }
        isCollectingData = true
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.latestAccelData = data.acceleration
                self.appendData(data.acceleration)
            }
        }
    }
    
    func stopCollecting() {
        isCollectingData = false
        motionManager.stopAccelerometerUpdates()
    }
    
    func updateActivityLabel(to newLabel: String) {
        activityLabel = newLabel
    }
    
    func clearData() {
        stopCollecting()
        setupDataFile()
        latestAccelData = CMAcceleration(x: 0, y: 0, z: 0)
    }
    
    private func setupDataFile() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = "sensorData.txt"
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        dataFileURL = fileURL

        if fileManager.fileExists(atPath: fileURL.path) {
            try? "".write(to: fileURL, atomically: true, encoding: .utf8)
        } else {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }
    
    private func appendData(_ acceleration: CMAcceleration) {
        guard let fileURL = dataFileURL else { return }
        let dataString = "X: \(acceleration.x), Y: \(acceleration.y), Z: \(acceleration.z), Activity: \(activityLabel)\n"

        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            if let data = dataString.data(using: .utf8) {
                fileHandle.write(data)
            }
        } else {
            try? dataString.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    func readDataFromFile() -> String {
        guard let fileURL = dataFileURL else { return "Data file not found." }
        do {
            let contents = try String(contentsOf: fileURL)
            return contents.isEmpty ? "No data collected yet." : contents
        } catch {
            return "Failed to read data from file."
        }
    }
}
