//
//  ContentView.swift
//  BetterRest
//
//  Created by Dogukan on 07/10/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var hoursOfSleep = 8.0
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var cupsOfCoffee = 0
    
    static private var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        DatePicker("Enter a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    } header: {
                        Text("What time do you wake up?")
                            .font(.headline)
                    }
                    
                    Section {
                        Stepper("\(hoursOfSleep.formatted()) hours", value: $hoursOfSleep, in: 4...12, step: 0.25)
                    } header: {
                        Text("Desired amount of sleep")
                            .font(.headline)
                    }
                    
                    Section {
                        Picker("Cups of coffee", selection: $cupsOfCoffee) {
                            ForEach(1..<21) {
                                Text($0 == 1 ? "1 cup" : "\($0) cups")
                            }
                        }
                        .labelsHidden()
                    } header: {
                        Text("Coffee intake per day")
                            .font(.headline)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Text("Ideal Bedtime")
                        .font(.headline)
                    Text(calculateBedtime())
                        .font(.largeTitle)
                    
                    Spacer()
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(hoursOfSleep), coffee: Double(cupsOfCoffee))
            
            let sleepTime = wakeUpTime - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Error"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
