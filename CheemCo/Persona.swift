// Persona.swift

import UIKit

struct Persona {
    let id: String
    let name: String
    let description: String
    let image: UIImage?
    
    // Adding the examples property that was missing
    static var examples: [Persona] {
        return [
            Persona(id: "1", name: "Business Sam", description: "Professional persona", image: UIImage(named: "business")),
            Persona(id: "2", name: "Athletic Sam", description: "Sports enthusiast", image: UIImage(named: "athletic")),
            Persona(id: "3", name: "Social Sam", description: "Outgoing and friendly", image: UIImage(named: "social")),
            // Add more example personas as needed
        ]
    }
}
