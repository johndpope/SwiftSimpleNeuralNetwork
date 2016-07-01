//
//  Layer.swift
//  SwiftSimpleNeuralNetwork
//
//  Copyright 2016 David Kopec
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

class Layer {
    let previousLayer: Layer?
    var neurons: [Neuron]
    var outputCache: [Double]
    
    init(previousLayer: Layer? = nil, neurons: [Neuron] = [Neuron]()) {
        self.previousLayer = previousLayer
        self.neurons = neurons
        self.outputCache = Array<Double>(repeating: 0.0, count: neurons.count)
    }
    
    init(previousLayer: Layer? = nil, numNeurons: Int, activationFunction: (Double) -> Double, derivativeActivationFunction: (Double)-> Double, learningRate: Double) {
        self.previousLayer = previousLayer
        self.neurons = Array<Neuron>()
        for _ in 0..<numNeurons {
            self.neurons.append(Neuron(weights: randomWeights(number: previousLayer?.neurons.count ?? 0), activationFunction: activationFunction, derivativeActivationFunction: derivativeActivationFunction, learningRate: learningRate))
        }
        /*self.neurons = Array<Neuron>(repeating: Neuron(weights: randomWeights(number: previousLayer?.neurons.count ?? 0), activationFunction: activationFunction, derivativeActivationFunction: derivativeActivationFunction, learningRate: learningRate), count: numNeurons)*/
        self.outputCache = Array<Double>(repeating: 0.0, count: neurons.count)
    }
    
    func outputs(inputs: [Double]) -> [Double] {
        if previousLayer == nil { // input layer (first layer)
            outputCache = inputs
        } else {
            outputCache = neurons.map { $0.output(inputs: inputs) }
            /*[Double]()
            for neuron in neurons {
                outputCache.append(neuron.output(inputs: inputs))
            }*/
        }
        return outputCache
    }
    
    // should only be called on an output layer
    func calculateDeltasForOutputLayer(expected: [Double]) {
        for n in 0..<neurons.count {
            neurons[n].delta = neurons[n].derivativeActivationFunction( neurons[n].inputCache) * (expected[n] - outputCache[n])
        }
    }
    
    // should not be called on output layer
    func calculateDeltasForHiddenLayer(nextLayer: Layer) {
        for (index, neuron) in neurons.enumerated() {
            let nextWeights = nextLayer.neurons.map { $0.weights[index] }
            let nextDeltas = nextLayer.neurons.map { $0.delta }
            let sumOfWeightsXDeltas = dotProduct(nextWeights, nextDeltas)
            neuron.delta = neuron.derivativeActivationFunction( neuron.inputCache) * sumOfWeightsXDeltas
        }
    }
    
    
}